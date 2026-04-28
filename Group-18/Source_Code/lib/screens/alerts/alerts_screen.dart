import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import 'widgets/animated_alert_tile.dart';
import 'widgets/add_alarm_sheet.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _hasPurged = false;

  @override
  void initState() {
    super.initState();
    // Execute silent purge of > 30 day old alerts once per view
    if (currentUser != null && !_hasPurged) {
      _hasPurged = true;
      FirestoreService().purgeOldAlerts(currentUser!.uid);
    }
  }

  // Faux AI logic mapping
  String _generateAITip(List<QueryDocumentSnapshot> recentAlerts) {
    if (recentAlerts.isEmpty) {
      return "Your vitals are stable. Keep up the good work and maintain your baseline routines!";
    }

    int criticalBp = 0;
    int criticalSugar = 0;
    for (var doc in recentAlerts) {
       final data = doc.data() as Map<String, dynamic>;
       if (data['severity'] == 'critical') {
         if (data['type'] == 'bp') criticalBp++;
         if (data['type'] == 'bloodSugar') criticalSugar++;
       }
    }

    if (criticalBp > 1) {
      return "Your BP has spiked recently. Excessive sodium or stress might be factors. Consider exploring DASH diet principles and tracking your rest intervals.";
    }
    if (criticalSugar > 1) {
      return "Your blood sugar variance is high. Ensure you are taking your medications exactly on schedule and balancing your carbohydrate intake.";
    }
    
    return "You've had some recent fluctuations. Ensure you are staying hydrated and resting well.";
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("Please login"));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Alerts & Reminders", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const TabBar(
                 indicatorColor: Colors.blueAccent,
                 labelColor: Colors.white,
                 unselectedLabelColor: Colors.white54,
                 dividerColor: Colors.transparent,
                 tabs: [
                    Tab(icon: Icon(Icons.warning_amber), text: "Health Alerts"),
                    Tab(icon: Icon(Icons.alarm), text: "Pill Alarms"),
                 ]
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildHealthAlertsTab(),
                    _buildPillAlarmsTab(),
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }

  Widget _buildHealthAlertsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().streamAllAlerts(currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No alerts found. You are perfectly healthy!", style: TextStyle(color: Colors.white54)));
        }

        final docs = snapshot.data!.docs;

        List<QueryDocumentSnapshot> critical = [];
        List<QueryDocumentSnapshot> warning = [];
        List<QueryDocumentSnapshot> normal = [];

        for (var doc in docs) {
           final data = doc.data() as Map<String, dynamic>;
           String severity = data['severity'] ?? 'normal';
           if (severity.toLowerCase() == 'critical') {
              critical.add(doc);
           } else if (severity.toLowerCase() == 'warning') {
              warning.add(doc);
           } else {
              normal.add(doc);
           }
        }

        String aiTip = _generateAITip(docs);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 24, top: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2B64).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("AI Health Insights", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text("Based on your last 7 days", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                          const SizedBox(height: 8),
                          Text(aiTip, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.4)),
                        ],
                      ),
                    )
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),

              if (critical.isNotEmpty) ...[
                 _buildSectionHeader("Critical", Colors.redAccent),
                 ...critical.map((d) => _buildTile(d)),
                 const SizedBox(height: 16),
              ],
              if (warning.isNotEmpty) ...[
                 _buildSectionHeader("Warning", Colors.amber),
                 ...warning.map((d) => _buildTile(d)),
                 const SizedBox(height: 16),
              ],
              if (normal.isNotEmpty) ...[
                 _buildSectionHeader("Resolved / Normal", Colors.green),
                 ...normal.map((d) => _buildTile(d)),
                 const SizedBox(height: 32),
              ],
            ],
          ),
        );
      }
    );
  }

  Widget _buildPillAlarmsTab() {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirestoreService().streamPillAlarms(currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.alarm_off, size: 64, color: Colors.white.withOpacity(0.2)),
                     const SizedBox(height: 16),
                     Text("No alarms set.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18))
                   ]
                 )
               );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                
                final bool isActive = data['isActive'] ?? true;
                final List<dynamic> days = data['daysOfWeek'] ?? [];
                final int h = data['hour'] ?? 0;
                final int m = data['minute'] ?? 0;
                
                String timeStr = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
                String subtitle = days.isEmpty ? "Everyday" : "Selected Days";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(timeStr, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("${data['title']} • $subtitle", style: TextStyle(color: isActive ? Colors.greenAccent : Colors.white24)),
                          ]
                        )
                      ),
                      Switch(
                        value: isActive,
                        activeColor: Colors.greenAccent,
                        onChanged: (val) async {
                           await FirestoreService().togglePillAlarm(currentUser!.uid, doc.id, val);
                           if (val) {
                             await NotificationService().schedulePillAlarm(
                                id: doc.id.hashCode,
                                title: "Pill Reminder",
                                body: "Time to take: ${data['title']}",
                                hour: h,
                                minute: m,
                                daysOfWeek: List<int>.from(days),
                             );
                           } else {
                             await NotificationService().cancelPillAlarm(doc.id.hashCode, days);
                           }
                        }
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                           await FirestoreService().deletePillAlarm(currentUser!.uid, doc.id);
                           await NotificationService().cancelPillAlarm(doc.id.hashCode, days);
                        }
                      )
                    ]
                  )
                );
              }
            );
          }
        ),
        Positioned(
          bottom: 20, right: 20,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.blueAccent,
            onPressed: () {
               showModalBottomSheet(
                 context: context, 
                 isScrollControlled: true,
                 backgroundColor: Colors.transparent,
                 builder: (context) => const AddAlarmSheet()
               );
            },
            icon: const Icon(Icons.add_alarm, color: Colors.white),
            label: const Text("New Alarm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ).animate().scale(curve: Curves.easeOutBack),
        )
      ]
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      )
    );
  }

  Widget _buildTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnimatedAlertTile(
      userId: currentUser!.uid,
      alertId: doc.id,
      type: data['type'] ?? 'sys',
      severity: data['severity'] ?? 'normal',
      value: data['value'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'],
      isRead: data['isRead'] ?? false,
    );
  }
}
