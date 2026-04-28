import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/firestore_service.dart';
import '../../services/pedometer_service.dart';
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final int _stepGoal = 10000;

  @override
  void initState() {
    super.initState();
  }

  int _calculateStreak(List<QueryDocumentSnapshot> docs) {
     if (docs.isEmpty) return 0;
     // simple logic tracking consecutive backward days from today or yesterday
     int streak = 0;
     DateTime checkDate = DateTime.now();
     
     for (var doc in docs) {
       final dateId = doc.id;
       String checkStr = DateFormat('yyyy-MM-dd').format(checkDate);
       
       if (dateId == checkStr) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
       } else if (streak == 0 && dateId == DateFormat('yyyy-MM-dd').format(checkDate.subtract(const Duration(days: 1)))) {
          // It's okay if today is empty, check yesterday
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 2));
       } else {
          break; // streak broke
       }
     }
     return streak;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("Please login"));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Activity Tracker", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().streamWeeklyActivity(currentUser!.uid),
        builder: (context, snapshot) {
           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
           
           final docs = snapshot.data!.docs;
           int manualStepsToday = 0;
           double todayDistance = 0;

            for (var doc in docs) {
              if (doc.id == todayStr) {
                 final d = doc.data() as Map<String, dynamic>;
                 manualStepsToday = (d['steps'] ?? 0) as int;
                 todayDistance = (d['distance'] ?? 0).toDouble();
                 break; // Since it's ordered naturally
              }
           }

           int streak = _calculateStreak(docs);

           return ValueListenableBuilder<int>(
             valueListenable: PedometerService().todaySteps,
             builder: (context, localAutoSteps, child) {
               
               int todaySteps = manualStepsToday + localAutoSteps;
               
               if (todayDistance == 0 && todaySteps > 0) {
                 todayDistance = todaySteps * 0.0008; // 0.8 meters per step roughly
               }

               double progress = (todaySteps / _stepGoal).clamp(0.0, 1.0);

               return SingleChildScrollView(
                 physics: const BouncingScrollPhysics(),
                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildStreakBadge(streak),
                     const SizedBox(height: 32),
                     _buildProgressRing(todaySteps, progress),
                     const SizedBox(height: 40),
                     
                     Row(
                       children: [
                         Expanded(child: _infoCard(Icons.directions_run, "Steps", "$todaySteps", Colors.orangeAccent)),
                         const SizedBox(width: 16),
                         Expanded(child: _infoCard(Icons.route, "Distance", "${todayDistance.toStringAsFixed(2)} km", Colors.blueAccent)),
                       ]
                     ).animate().fadeIn(delay: 400.ms),
                     
                     const SizedBox(height: 40),
                     _buildWeeklyChart(docs, localAutoSteps),
                     const SizedBox(height: 100),
                   ],
                 ),
               );
             }
           );
        }
      ),
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 8),
          Text("$streak Day Streak!", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
        ],
      )
    ).animate().fadeIn().slideX();
  }

  Widget _buildProgressRing(int steps, double progress) {
     return Center(
       child: SizedBox(
         width: 220, height: 220,
         child: Stack(
           fit: StackFit.expand,
           children: [
             TweenAnimationBuilder<double>(
               tween: Tween<double>(begin: 0, end: progress),
               duration: const Duration(seconds: 2),
               curve: Curves.easeOutCubic,
               builder: (context, val, _) {
                 return CircularProgressIndicator(
                   value: val,
                   strokeWidth: 20,
                   strokeCap: StrokeCap.round,
                   backgroundColor: Colors.white.withOpacity(0.05),
                   color: Colors.orangeAccent,
                 );
               }
             ),
             Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(Icons.directions_walk, size: 40, color: Colors.orangeAccent),
                 const SizedBox(height: 8),
                 Text(NumberFormat('#,###').format(steps), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                 Text("Goal: ${NumberFormat('#,###').format(_stepGoal)}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
               ],
             )
           ],
         ),
       ).animate().scale(begin: const Offset(0.8,0.8), end: const Offset(1,1), curve: Curves.easeOutBack, duration: 600.ms),
     );
  }

  Widget _infoCard(IconData icon, String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12)
      ),
      child: Column(
        children: [
           Icon(icon, color: color, size: 32),
           const SizedBox(height: 12),
           Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6))),
           const SizedBox(height: 4),
           Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      )
    );
  }

  Widget _buildWeeklyChart(List<QueryDocumentSnapshot> rawDocs, int localAutoSteps) {
    if (rawDocs.isEmpty) return const SizedBox();
    
    // Sort docs ascending for chart (Mon -> Sun layout dynamically)
    final docs = rawDocs.reversed.toList();
    List<BarChartGroupData> barGroups = [];
    int index = 0;
    
    for (var doc in docs) {
       final d = doc.data() as Map<String, dynamic>;
       int manualSteps = (d['steps'] ?? 0) as int;
       int autoSteps = (d['auto_steps'] ?? 0) as int;
       
       if (doc.id == todayStr && localAutoSteps > autoSteps) {
           autoSteps = localAutoSteps;
       }
       
       double steps = (manualSteps + autoSteps).toDouble();
       
       barGroups.add(
         BarChartGroupData(
           x: index,
           barRods: [
             BarChartRodData(
               toY: steps,
               color: steps >= _stepGoal ? Colors.green : Colors.orangeAccent,
               width: 14,
               borderRadius: BorderRadius.circular(4)
             )
           ]
         )
       );
       index++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Weekly Activity", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                      String dateStr = docs[val.toInt()].id; // yyyy-mm-dd
                      String brief = dateStr.substring(8); // dd
                      return Text(brief, style: const TextStyle(color: Colors.white54, fontSize: 12));
                    }
                  )
                )
              )
            )
          )
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }
}
