import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../services/firestore_service.dart';
import '../../services/pedometer_service.dart';
import '../../services/notification_service.dart';
import 'widgets/vital_card.dart';
import 'widgets/bp_line_chart.dart';

import '../../theme/app_theme.dart';
import '../vitals/vitals_screen.dart';
import '../medicines/medicines_screen.dart';
import '../alerts/alerts_screen.dart';
import '../reports/reports_screen.dart';
import '../profile/profile_screen.dart';
import '../sleep/sleep_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../activity/activity_screen.dart';
import 'package:page_transition/page_transition.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _fragments = [
    const _DashboardMainFragment(),
    const VitalsScreen(),
    const MedicinesScreen(),
    const AlertsScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Controlled by main.dart Container
      bottomNavigationBar: _buildBottomNav(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _fragments[_currentIndex],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context) ? const Color(0xFF1D2B64) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.dashboard, "Dashboard", 0),
          _navItem(Icons.monitor_heart, "Vitals", 1),
          _navItem(Icons.medication, "Medicines", 2),
          
          StreamBuilder<QuerySnapshot>(
            stream: currentUser != null ? FirestoreService().streamActiveAlerts(currentUser.uid) : const Stream.empty(),
            builder: (context, snapshot) {
              int alertCount = snapshot.data?.docs.length ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _navItem(Icons.warning_amber_rounded, "Alerts", 3),
                  if (alertCount > 0)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          '$alertCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    )
                ],
              );
            }
          ),
          
          _navItem(Icons.summarize, "Reports", 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.blueAccent : AppTheme.getSubTextColor(context), size: 28),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isActive ? 20 : 0,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isActive ? [const BoxShadow(color: Colors.blueAccent, blurRadius: 5)] : [],
            ),
          )
        ],
      ).animate(target: isActive ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 200.ms),
    );
  }
}

class _DashboardMainFragment extends StatefulWidget {
  const _DashboardMainFragment();

  @override
  State<_DashboardMainFragment> createState() => _DashboardMainFragmentState();
}

class _DashboardMainFragmentState extends State<_DashboardMainFragment> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  // Local state for water Gamification. Could be moved to Firestore for persistence.
  int _waterGlasses = 0;
  final int _waterGoal = 8;

  late final Stream<DocumentSnapshot>? _vitalsStream;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _loadWater();
    if (currentUser != null) {
      _vitalsStream = _firestoreService.streamLatestVitals(currentUser!.uid);
    } else {
      _vitalsStream = null;
    }
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadWater() async {
     final prefs = await SharedPreferences.getInstance();
     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
     String? savedDate = prefs.getString('water_date');
     if (savedDate == today) {
        setState(() {
           _waterGlasses = prefs.getInt('water_glasses') ?? 0;
        });
     } else {
        await prefs.setString('water_date', today);
        await prefs.setInt('water_glasses', 0);
     }
  }

  Future<void> _incrementWater() async {
     setState(() {
        _waterGlasses++;
        if (_waterGlasses == _waterGoal) {
          _confettiController.play();
        }
     });
     final prefs = await SharedPreferences.getInstance();
     await prefs.setInt('water_glasses', _waterGlasses);
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("Error: No user"));

    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: _vitalsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerLoader();
              }
              
              if (!snapshot.hasData || snapshot.data?.data() == null) {
                return _buildDashboardContent(null);
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              return _buildDashboardContent(data);
            },
          ).animate().slideY(begin: 0.5, end: 0, duration: 800.ms, curve: Curves.easeOut),
          
          // Celebration Confetti
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              maxBlastForce: 40,
              minBlastForce: 10,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
              colors: const [Colors.green, Colors.greenAccent, Colors.lightGreen, Colors.blueAccent, Colors.yellow],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(Map<String, dynamic>? data) {
    double hr = (data?['heartRate'] ?? 0).toDouble();
    double sys = (data?['systolic'] ?? 0).toDouble();
    double dia = (data?['diastolic'] ?? 0).toDouble();
    double sugar = (data?['bloodSugar'] ?? 0).toDouble();
    double spo2 = (data?['spO2'] ?? 0).toDouble();
    double temp = (data?['temperature_c'] ?? 0).toDouble();
    double bmi = (data?['bmi'] ?? 0).toDouble();

    bool hasEmergency = data?['hasEmergency'] ?? false;

    return RefreshIndicator(
      color: Colors.blueAccent,
      backgroundColor: AppTheme.getCardColor(context),
      onRefresh: () async {
         // Streams inherently refresh, but UX pull delay simulates action
         await Future.delayed(const Duration(milliseconds: 800));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Good Morning,", style: TextStyle(color: AppTheme.getSubTextColor(context), fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(currentUser?.displayName ?? "User", style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [

                  GestureDetector(
                      onTap: () => Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: const ProfileScreen())),
                      child: const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.settings, color: Colors.white, size: 24),
                      )
                  ),
                ],
              )
            ],
          ).animate().fadeIn(duration: 800.ms),

          const SizedBox(height: 24),

          if (hasEmergency)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text("Critical Vital Reading Detected!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
            ).animate().slideY(begin: -0.5, end: 0, duration: 800.ms, curve: Curves.elasticOut),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              VitalCard(title: "Heart Rate", icon: Icons.favorite, iconColor: Colors.red, values: [hr], format: "{}", unit: "BPM", lastUpdated: "Just now", statusColor: hr > 100 ? Colors.red : Colors.green).animate().slideY(begin: 0.5, end: 0, delay: 100.ms, duration: 600.ms),
              VitalCard(title: "Blood Pressure", icon: Icons.bloodtype, iconColor: Colors.blueAccent, values: [sys, dia], format: "{} / {}", unit: "mmHg", lastUpdated: "Just now", statusColor: sys > 130 ? Colors.orange : Colors.green).animate().slideY(begin: 0.5, end: 0, delay: 200.ms, duration: 600.ms),
              VitalCard(title: "Blood Sugar", icon: Icons.water_drop, iconColor: Colors.amber, values: [sugar], format: "{}", unit: "mg/dL", lastUpdated: "Just now", statusColor: Colors.green).animate().slideY(begin: 0.5, end: 0, delay: 300.ms, duration: 600.ms),
              VitalCard(title: "SpO2", icon: Icons.air, iconColor: Colors.teal, values: [spo2], format: "{}", unit: "%", lastUpdated: "Just now", statusColor: spo2 < 95 && spo2 > 0 ? Colors.red : Colors.green).animate().slideY(begin: 0.5, end: 0, delay: 400.ms, duration: 600.ms),
              VitalCard(title: "Temperature", icon: Icons.thermostat, iconColor: Colors.orange, values: [temp], format: "{}", unit: "°C", lastUpdated: "Just now", statusColor: Colors.green).animate().slideY(begin: 0.5, end: 0, delay: 500.ms, duration: 600.ms),
              VitalCard(title: "BMI", icon: Icons.monitor_weight, iconColor: Colors.purple, values: [bmi], format: "{}", unit: "kg/m2", lastUpdated: "Just now", statusColor: Colors.green).animate().slideY(begin: 0.5, end: 0, delay: 600.ms, duration: 600.ms),
            ],
          ),

          const SizedBox(height: 32),
          Text("Daily Hydration", style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildWaterTracker(),

          const SizedBox(height: 32),
          
          Text("Weekly Blood Pressure", style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
               color: AppTheme.getCardColor(context), 
               borderRadius: BorderRadius.circular(16),
               border: Border.all(color: AppTheme.getCardBorderColor(context))
            ),
            child: const BpLineChart(
              systolicData: [120, 118, 122, 125, 121, 119, 120], 
              diastolicData: [80, 78, 82, 85, 81, 79, 80],
            ),
          ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
          
          const SizedBox(height: 32),
          Text("Quick Modules", style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
             crossAxisCount: 3,
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             crossAxisSpacing: 16,
             mainAxisSpacing: 16,
             children: [
                _buildGridNode(Icons.nightlight_round, "Sleep", Colors.indigoAccent, () => Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const SleepScreen()))),
                _buildGridNode(Icons.restaurant, "Nutrition", Colors.greenAccent, () => Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const NutritionScreen()))),
                _buildGridNode(Icons.directions_run, "Activity", Colors.orangeAccent, () => Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const ActivityScreen()))),
             ]
          ).animate().fadeIn(delay: 700.ms),
          
          const SizedBox(height: 50),
        ],
      ),
      )
    );
  }

  Widget _buildWaterTracker() {
    double progress = _waterGlasses / _waterGoal;
    if (progress > 1.0) progress = 1.0;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
         color: AppTheme.getCardColor(context), 
         borderRadius: BorderRadius.circular(20),
         border: Border.all(color: AppTheme.getCardBorderColor(context))
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    height: constraints.maxHeight * progress,
                    width: double.infinity,
                    color: Colors.blueAccent.withOpacity(0.15),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                     color: Colors.blueAccent.withOpacity(0.1),
                     shape: BoxShape.circle
                  ),
                  child: const Icon(Icons.water_drop, color: Colors.blueAccent, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                            Text("$_waterGlasses / $_waterGoal Glasses", style: TextStyle(color: AppTheme.getTextColor(context), fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                         ],
                       ),
                       const SizedBox(height: 8),
                       Text("Keep hydrated!", style: TextStyle(color: AppTheme.getSubTextColor(context))),
                    ]
                  )
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _incrementWater,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildGridNode(IconData icon, String title, Color color, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
             color: AppTheme.getCardColor(context), 
             borderRadius: BorderRadius.circular(16),
             border: Border.all(color: AppTheme.getCardBorderColor(context))
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(icon, color: color, size: 32),
               const SizedBox(height: 8),
               Text(title, style: TextStyle(color: AppTheme.getTextColor(context), fontWeight: FontWeight.bold, fontSize: 14)),
            ]
          )
        )
      );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(width: 150, height: 24, color: Colors.white),
                const Spacer(),
                Container(width: 50, height: 50, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 30),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: List.generate(6, (index) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)))),
            ),
          ],
        ),
      ),
    );
  }
}
