import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/firestore_service.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;

  @override
  void initState() {
    super.initState();
    _loadCachedSleepData();
  }

  Future<void> _loadCachedSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedH = prefs.getInt('sleep_bedTime_h');
    final cachedM = prefs.getInt('sleep_bedTime_m');
    final cachedDate = prefs.getString('sleep_bedTime_date');
    
    // Only reload if it was set today or yesterday, not from an old orphaned sess.
    if (cachedH != null && cachedM != null && cachedDate != null) {
      final savedDate = DateTime.parse(cachedDate);
      if (DateTime.now().difference(savedDate).inHours < 24) {
        setState(() {
          _bedTime = TimeOfDay(hour: cachedH, minute: cachedM);
        });
      } else {
        _clearCachedSleepData(); // expire orphans > 24 hours
      }
    }
  }

  Future<void> _clearCachedSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sleep_bedTime_h');
    await prefs.remove('sleep_bedTime_m');
    await prefs.remove('sleep_bedTime_date');
  }

  Future<void> _selectTime(bool isBedtime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
         return Theme(
           data: ThemeData.dark().copyWith(
             colorScheme: const ColorScheme.dark(primary: Colors.blueAccent, surface: Color(0xFF1D2B64)),
             dialogBackgroundColor: const Color(0xFF0A0E21)
           ),
           child: child!,
         );
      }
    );
    if (picked != null) {
       setState(() {
          if (isBedtime) {
            _bedTime = picked;
            _cacheBedTime(picked);
          } else {
            _wakeTime = picked;
          }
       });
    }
  }

  Future<void> _cacheBedTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sleep_bedTime_h', time.hour);
    await prefs.setInt('sleep_bedTime_m', time.minute);
    await prefs.setString('sleep_bedTime_date', DateTime.now().toIso8601String());
  }

  void _saveSleepLog() async {
    if (_bedTime == null || _wakeTime == null || currentUser == null) return;

    final now = DateTime.now();
    DateTime bedDT = DateTime(now.year, now.month, now.day, _bedTime!.hour, _bedTime!.minute);
    DateTime wakeDT = DateTime(now.year, now.month, now.day, _wakeTime!.hour, _wakeTime!.minute);
    
    if (wakeDT.isBefore(bedDT)) {
       wakeDT = wakeDT.add(const Duration(days: 1));
    }

    final durationMin = wakeDT.difference(bedDT).inMinutes;
    final hours = durationMin / 60.0;
    
    String quality = 'Poor';
    if (hours >= 7) quality = 'Excellent';
    else if (hours >= 5.5) quality = 'Good';
    else if (hours >= 4) quality = 'Fair';

    await FirestoreService().addSleepLog(currentUser!.uid, {
       'date': DateFormat('yyyy-MM-dd').format(now),
       'bedTime': _bedTime!.format(context),
       'wakeTime': _wakeTime!.format(context),
       'durationHours': hours,
       'quality': quality,
    });

    setState(() {
      _bedTime = null;
      _wakeTime = null;
    });
    _clearCachedSleepData();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sleep tracked successfully!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
  }

  Color _getBadgeColor(String quality) {
    if (quality == 'Excellent') return Colors.green;
    if (quality == 'Good') return Colors.blueAccent;
    if (quality == 'Fair') return Colors.amber;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Sleep Tracker", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _buildArc(),
             _buildLogCard(),
             const SizedBox(height: 32),
             _buildWeeklyChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildArc() {
     return Container(
       height: 120,
       margin: const EdgeInsets.symmetric(vertical: 10),
       child: Stack(
         alignment: Alignment.bottomCenter,
         children: [
            CustomPaint(size: const Size(double.infinity, 120), painter: _ArcPainter()),
            Positioned(bottom: 0, left: 40, child: const Icon(Icons.nightlight_round, color: Colors.indigoAccent, size: 40).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.1,1.1), duration: 2.seconds)),
            Positioned(bottom: 0, right: 40, child: const Icon(Icons.wb_sunny, color: Colors.orange, size: 40).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.2,1.2), duration: 1.seconds)),
         ],
       )
     ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildLogCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               _timePill("Bedtime", _bedTime?.format(context) ?? "Set Time", Icons.bed, () => _selectTime(true)),
               Container(height: 40, width: 2, color: Colors.white24),
               _timePill("Wake Up", _wakeTime?.format(context) ?? "Set Time", Icons.alarm, () => _selectTime(false)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _bedTime != null && _wakeTime != null ? _saveSleepLog : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save Sleep Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      )
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _timePill(String title, String val, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    if (currentUser == null) return const SizedBox();
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().streamSleepLogs(currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No sleep data this week.", style: TextStyle(color: Colors.white54)));
        }

        final docs = snapshot.data!.docs.reversed.toList(); // ascending
        List<BarChartGroupData> barGroups = [];
        int index = 0;
        
        for (var doc in docs) {
           final data = doc.data() as Map<String, dynamic>;
           double hrs = (data['durationHours'] ?? 0).toDouble();
           String q = data['quality'] ?? 'Poor';
           
           barGroups.add(BarChartGroupData(
             x: index,
             barRods: [
               BarChartRodData(
                 toY: hrs,
                 color: _getBadgeColor(q),
                 width: 16,
                 borderRadius: BorderRadius.circular(4)
               )
             ]
           ));
           index++;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Sleep Patterns", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              height: 200,
              padding: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          if (val.toInt() >= docs.length) return const SizedBox();
                          final d = docs[val.toInt()].data() as Map<String, dynamic>;
                          String dateStr = d['date'] ?? '';
                          String brief = dateStr.isNotEmpty ? dateStr.substring(8) : '';
                          return Text(brief, style: const TextStyle(color: Colors.white54, fontSize: 12));
                        }
                      )
                    )
                  )
                )
              )
            ).animate().slideX(begin: 0.2, end: 0, duration: 500.ms),
            
            const SizedBox(height: 20),
            const Text("Recent Logs", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...snapshot.data!.docs.map((doc) {
               final d = doc.data() as Map<String,dynamic>;
               final hrs = (d['durationHours'] ?? 0).toDouble().toStringAsFixed(1);
               final q = d['quality'] ?? 'Poor';
               return Container(
                 margin: const EdgeInsets.only(bottom: 8),
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                 decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                      Text("${d['date']}", style: const TextStyle(color: Colors.white70)),
                      Text("${d['bedTime']} - ${d['wakeTime']}", style: const TextStyle(color: Colors.white70)),
                      Row(
                        children: [
                           Text("${hrs}h", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                           const SizedBox(width: 8),
                           Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: _getBadgeColor(q).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                              child: Text(q, style: TextStyle(color: _getBadgeColor(q), fontSize: 10, fontWeight: FontWeight.bold)),
                           )
                        ]
                      )
                   ]
                 )
               );
            }),
            const SizedBox(height: 50),
          ],
        );
      }
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    path.moveTo(40, size.height);
    path.quadraticBezierTo(size.width / 2, -60, size.width - 40, size.height);
    
    // Draw dashed effect
    final dashWidth = 8.0;
    final dashSpace = 4.0;
    double distance = 0.0;
    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
            pathMetric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
