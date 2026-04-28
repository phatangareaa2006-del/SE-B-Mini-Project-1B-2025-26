import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../services/firestore_service.dart';
import '../../services/pdf_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  String _dateRangeSelection = '7days'; // 7days, 30days, custom
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  final DateTime _endDate = DateTime.now();

  bool _includeVitals = true;
  bool _includeMedicines = true;
  bool _includeAlerts = true;
  bool _includeQuickModules = true;

  bool _isGenerating = false;
  double _progress = 0.0;
  bool _generationSuccess = false;

  void _setDateRange(String type) async {
    if (type == '7days') {
       setState(() {
         _dateRangeSelection = '7days';
         _startDate = DateTime.now().subtract(const Duration(days: 7));
       });
    } else if (type == '30days') {
       setState(() {
         _dateRangeSelection = '30days';
         _startDate = DateTime.now().subtract(const Duration(days: 30));
       });
    } else if (type == 'custom') {
       final picked = await showDatePicker(
          context: context, 
          initialDate: _startDate, 
          firstDate: DateTime(2020), 
          lastDate: DateTime.now(),
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
            _dateRangeSelection = 'custom';
            _startDate = picked;
          });
       }
    }
  }

  Future<void> _generatePdf() async {
    if (currentUser == null) return;
    
    setState(() {
      _isGenerating = true;
      _progress = 0.1;
      _generationSuccess = false;
    });

    try {
       // Simulate compilation fetching visually
       await Future.delayed(const Duration(milliseconds: 600));
       setState(() => _progress = 0.3);

       final firestore = FirestoreService();
       final profile = await firestore.fetchUserProfile(currentUser!.uid);
       
       setState(() => _progress = 0.5);
       final vitals = _includeVitals ? await firestore.fetchRangedVitals(currentUser!.uid, _startDate, _endDate) : <Map<String,dynamic>>[];
       
       setState(() => _progress = 0.7);
       final meds = _includeMedicines ? await firestore.fetchRangedMedicineLogs(currentUser!.uid, _startDate, _endDate) : <Map<String,dynamic>>[];
       
       setState(() => _progress = 0.85);
       final alerts = _includeAlerts ? await firestore.fetchRangedAlerts(currentUser!.uid, _startDate, _endDate) : <Map<String,dynamic>>[];

       setState(() => _progress = 0.90);
       final sleepLogs = _includeQuickModules ? await firestore.fetchRangedSleepLogs(currentUser!.uid, _startDate, _endDate) : <Map<String,dynamic>>[];
       final nutritionLogs = _includeQuickModules ? await firestore.fetchRangedNutritionLogs(currentUser!.uid, _startDate, _endDate) : <Map<String,dynamic>>[];
       final activityLogs = _includeQuickModules ? await firestore.fetchRangedActivityLogs(currentUser!.uid, _startDate, _endDate) : <Map<String,dynamic>>[];

       setState(() => _progress = 0.95);
       
       final bytes = await PdfService().generateHealthReport(
           userProfile: profile,
           vitals: vitals,
           medicineLogs: meds,
           alerts: alerts,
           sleepLogs: sleepLogs,
           nutritionLogs: nutritionLogs,
           activityLogs: activityLogs,
           startDate: _startDate,
           endDate: _endDate,
           includeVitals: _includeVitals,
           includeMedicines: _includeMedicines,
           includeAlerts: _includeAlerts,
           includeQuickModules: _includeQuickModules,
       );

       setState(() {
          _progress = 1.0;
          _generationSuccess = true;
       });

       await Future.delayed(const Duration(milliseconds: 1200)); 
       setState(() => _isGenerating = false);
       
       await Printing.sharePdf(bytes: bytes, filename: 'health_report_${DateFormat('MM-dd').format(DateTime.now())}.pdf');

    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
       setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("Please login"));

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PDF Reports", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),
                  
                  // Patient Preview Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12)
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 24, backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white, size: 28)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<Map<String, dynamic>>(
                                future: FirestoreService().fetchUserProfile(currentUser!.uid),
                                builder: (context, snapshot) {
                                  String name = currentUser?.displayName ?? "Unknown User";
                                  if (snapshot.hasData && snapshot.data!['name'] != null && snapshot.data!['name'].toString().isNotEmpty) {
                                    name = snapshot.data!['name'];
                                  }
                                  return Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
                                }
                              ),
                              const SizedBox(height: 4),
                              Text("ID: ${currentUser?.uid.substring(0,8).toUpperCase()}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 32),
                  const Text("Report Period", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Date Pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDatePill("7 Days", '7days'),
                      _buildDatePill("30 Days", '30days'),
                      _buildDatePill("Custom", 'custom'),
                    ],
                  ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms),

                  if (_dateRangeSelection == 'custom')
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text("Selected: ${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}", 
                          style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)).animate().fadeIn(),
                    ),

                  const SizedBox(height: 32),
                  const Text("Include Sections", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  _buildCheckOption("Vitals Summary", Icons.monitor_heart, _includeVitals, (v) => setState(() => _includeVitals = v ?? true)),
                  _buildCheckOption("Medicine Adherence", Icons.medication, _includeMedicines, (v) => setState(() => _includeMedicines = v ?? true)),
                  _buildCheckOption("Health Alerts Log", Icons.warning_amber_rounded, _includeAlerts, (v) => setState(() => _includeAlerts = v ?? true)),
                  _buildCheckOption("Quick Modules (Sleep, Nutrition, Activity)", Icons.bolt, _includeQuickModules, (v) => setState(() => _includeQuickModules = v ?? true)),

                  const SizedBox(height: 50),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generatePdf,
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: const Text("Generate PDF Report", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 10,
                        shadowColor: Colors.blueAccent.withOpacity(0.5)
                      ),
                    ),
                  ).animate(delay: 400.ms).scale(curve: Curves.easeOutBack),

                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {}, // Handled natively by Printing action later
                      icon: Icon(Icons.cloud_download, color: Colors.white.withOpacity(0.6)),
                      label: Text("Save to Device Offline", style: TextStyle(color: Colors.white.withOpacity(0.6))),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        // Full Screen Generation Overlay
        if (_isGenerating)
          Container(
            color: const Color(0xFF0A0E21).withOpacity(0.95),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_generationSuccess)
                    // Faux Document Processing Lottie alternative via flutter_animate loops
                    Container(
                      width: 100, height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent, width: 4)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(height: 4, width: 60, color: Colors.blueAccent.withOpacity(0.3), margin: const EdgeInsets.only(bottom: 8)),
                          Container(height: 4, width: 80, color: Colors.blueAccent.withOpacity(0.3), margin: const EdgeInsets.only(bottom: 8)),
                          Container(height: 4, width: 50, color: Colors.blueAccent.withOpacity(0.3), margin: const EdgeInsets.only(bottom: 8)),
                        ],
                      ),
                    ).animate(onPlay: (c)=>c.repeat()).scaleY(begin: 1.0, end: 0.8, duration: 600.ms, curve: Curves.easeInOut).then().scaleY(begin: 0.8, end: 1.0)
                  else 
                    // Success Checkmark
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.check, size: 60, color: Colors.white),
                    ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),

                  const SizedBox(height: 40),
                  Text(
                    _generationSuccess ? "Report Ready!" : "Compiling Data...", 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 20),
                  
                  // Progress Bar
                  SizedBox(
                    width: 250,
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("${(_progress * 100).toInt()}%", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms)
      ],
    );
  }

  Widget _buildDatePill(String title, String type) {
    bool isSelected = _dateRangeSelection == type;
    return GestureDetector(
      onTap: () => _setDateRange(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blueAccent : Colors.white24)
        ),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCheckOption(String title, IconData icon, bool val, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CheckboxListTile(
        value: val,
        onChanged: onChanged,
        activeColor: Colors.blueAccent,
        checkColor: Colors.white,
        title: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.2, end: 0, duration: 400.ms);
  }
}
