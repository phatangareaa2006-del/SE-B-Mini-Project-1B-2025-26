import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/log_vital_sheet.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabKeys = ['bp', 'heartRate', 'bloodSugar', 'spO2', 'temperature_c', 'bmi'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddVitalModal() {
    String currentType = _tabKeys[_tabController.index];
    LogVitalSheet.show(context, currentType);
  }

  bool _isSyncing = false;

  void _simulateSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    
    // Show scanning dialog
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.getCardColor(context), borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Icon(Icons.monitor_heart, size: 64, color: Colors.blueAccent).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(duration: 800.ms, begin: const Offset(1,1), end: const Offset(1.2,1.2)),
                 const SizedBox(height: 16),
                 Text("Syncing health data...", style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 16)),
              ]
            )
          )
        )
      )
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context); // close scanning
    
    // Instead of mock data, inform the user they need a real device
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No compatible smartwatch connected for sync."), 
          backgroundColor: Colors.orange
        )
      );
    }

    setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherited from dashboard stack
      body: SafeArea(
        child: Column(
          children: [
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Vitals", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.getTextColor(context))),
                  OutlinedButton.icon(
                      onPressed: _simulateSync,
                      icon: const Icon(Icons.sync, color: Colors.blueAccent, size: 20),
                      label: const Text("Sync", style: TextStyle(color: Colors.blueAccent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                      )
                  ).animate(target: _isSyncing ? 1 : 0).shimmer(duration: 1000.ms),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: AppTheme.getSubTextColor(context),
              indicatorColor: Colors.blueAccent,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "BP"),
                Tab(text: "Heart"),
                Tab(text: "Sugar"),
                Tab(text: "SpO2"),
                Tab(text: "Temp"),
                Tab(text: "BMI"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: _tabKeys.map((type) => VitalTabView(type: type)).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: StatefulBuilder(
        builder: (context, setFabState) {
          bool isPressed = false;
          return AnimatedScale(
            scale: isPressed ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.blueAccent,
              onPressed: () {
                setFabState(() => isPressed = true);
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (mounted) setFabState(() => isPressed = false);
                  _showAddVitalModal();
                });
              },
              icon: AnimatedRotation(
                turns: isPressed ? 0.125 : 0.0, // 45 degrees
                duration: const Duration(milliseconds: 150),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              label: const Text("Log Reading", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          );
        }
      ),
    );
  }
}

class VitalTabView extends StatelessWidget {
  final String type;
  const VitalTabView({super.key, required this.type});

  String get _unit {
    switch (type) {
      case 'bp': return "mmHg";
      case 'heartRate': return "BPM";
      case 'bloodSugar': return "mg/dL";
      case 'spO2': return "%";
      case 'temperature_c': return "°C";
      case 'bmi': return "kg/m²";
      default: return "";
    }
  }

  Color get _color {
    switch (type) {
      case 'bp': return Colors.blueAccent;
      case 'heartRate': return Colors.redAccent;
      case 'bloodSugar': return Colors.amber;
      case 'spO2': return Colors.teal;
      case 'temperature_c': return Colors.orange;
      case 'bmi': return Colors.purple;
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().streamVitalHistory(user.uid, type),
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
         }

         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.monitor_heart, size: 80, color: AppTheme.getTextColor(context).withOpacity(0.1)),
                 const SizedBox(height: 16),
                 Text("No $type logged yet.", style: TextStyle(color: AppTheme.getSubTextColor(context))),
               ],
             ),
           );
         }

         final docs = snapshot.data!.docs;
         
         double latestVal1 = (docs.first['value'] as num).toDouble();
         double? latestVal2;
         if (type == 'bp' && (docs.first.data() as Map<String, dynamic>).containsKey('value2')) {
           latestVal2 = (docs.first['value2'] as num).toDouble();
         }

         final chartDocs = docs.reversed.toList();

         List<double> val1List = chartDocs.map((d) => (d['value'] as num).toDouble()).toList();
         List<double> val2List = type == 'bp' 
           ? chartDocs.map((d) => (d.data() as Map<String,dynamic>).containsKey('value2') ? (d['value2'] as num).toDouble() : 0.0).toList() 
           : [];

         double maxV = val1List.reduce((curr, next) => curr > next ? curr : next);
         double minV = val1List.reduce((curr, next) => curr < next ? curr : next);
         double avgV = val1List.reduce((a,b)=>a+b) / val1List.length;

         double maxChartY = type == 'bp' ? 180 : maxV * 1.2;
         double minChartY = type == 'bp' ? 40 : minV * 0.8;

         String status = "Normal";
         Color badgeColor = Colors.green;
         
         if (type == 'bp' && latestVal2 != null) {
            if (latestVal1 > 140 || latestVal2 > 90) { status = "Critical"; badgeColor = Colors.red; }
            else if (latestVal1 >= 130) { status = "Warning"; badgeColor = Colors.amber; }
         } else if (type == 'bloodSugar' && latestVal1 > 180) { status = "Critical"; badgeColor = Colors.red;
         } else if (type == 'heartRate' && (latestVal1 < 50 || latestVal1 > 120)) { status = "Critical"; badgeColor = Colors.red;
         } else if (type == 'spO2' && latestVal1 < 95) { status = "Critical"; badgeColor = Colors.red; 
         } else if (type == 'bmi') {
            if (latestVal1 < 18.5) { status = "Underweight"; badgeColor = Colors.amber; }
            else if (latestVal1 >= 25 && latestVal1 < 30) { status = "Overweight"; badgeColor = Colors.orange; }
            else if (latestVal1 >= 30) { status = "Obese"; badgeColor = Colors.red; }
         }

         return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Latest Reading Display
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.getCardBorderColor(context)),
                    boxShadow: [BoxShadow(color: _color.withOpacity(AppTheme.isDark(context) ? 0.2 : 0.05), blurRadius: 40)],
                  ),
                  child: Column(
                    children: [
                      Text(
                        type == 'bp' && latestVal2 != null 
                            ? "${latestVal1.toInt()}/${latestVal2.toInt()}" 
                            : "${latestVal1.toStringAsFixed(1)}",
                        style: TextStyle(
                          fontSize: 56, 
                          fontWeight: FontWeight.bold, 
                          color: AppTheme.getTextColor(context),
                          shadows: [Shadow(color: _color, blurRadius: 20)],
                        ),
                      ).animate().scale(duration: 400.ms, begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                      Text(_unit, style: TextStyle(color: AppTheme.getSubTextColor(context), fontSize: 18)),
                      
                      const SizedBox(height: 24),
                      
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: badgeColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status == "Critical")
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                              ).animate(onPlay: (c)=>c.repeat(reverse:true)).scale(begin: const Offset(0.5, 0.5), end: const Offset(1.5, 1.5), duration: 400.ms)
                            else
                              Icon(Icons.check_circle, color: badgeColor, size: 16),
                            const SizedBox(width: 8),
                            Text(status, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Chart View
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.getCardBorderColor(context))
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: minChartY,
                      maxY: maxChartY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(val1List.length, (index) => FlSpot(index.toDouble(), val1List[index])),
                          isCurved: true,
                          color: _color,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: AppTheme.getCardColor(context), strokeWidth: 2, strokeColor: _color)),
                          belowBarData: BarAreaData(
                            show: true, 
                            color: _color.withOpacity(0.3),
                            gradient: LinearGradient(colors: [_color.withOpacity(0.5), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                          ),
                        ),
                        if (type == 'bp')
                          LineChartBarData(
                            spots: List.generate(val2List.length, (index) => FlSpot(index.toDouble(), val2List[index])),
                            isCurved: true,
                            color: Colors.teal,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: AppTheme.getCardColor(context), strokeWidth: 2, strokeColor: Colors.teal)),
                            belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.2)),
                          ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeInOutQuart,
                  ),
                ),

                const SizedBox(height: 16),
                
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statBlock(context, "Min", "${minV.toStringAsFixed(1)}"),
                    _statBlock(context, "Avg", "${avgV.toStringAsFixed(1)}"),
                    _statBlock(context, "Max", "${maxV.toStringAsFixed(1)}"),
                  ],
                ),
                
                const SizedBox(height: 80), 
              ],
            ),
         ).animate().fadeIn(duration: 600.ms);
      }
    );
  }

  Widget _statBlock(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.getSubTextColor(context), fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
