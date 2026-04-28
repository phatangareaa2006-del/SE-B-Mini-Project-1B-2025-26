import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../services/firestore_service.dart';
import 'widgets/medicine_card.dart';
import 'widgets/add_medicine_sheet.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late String _selectedDateStamp;

  @override
  void initState() {
    super.initState();
    _selectedDateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _showAddMedicineSheet() {
    AddMedicineSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("Please login", style: TextStyle(color: Colors.white)));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Medicines", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              
              const Text("Weekly Adherence", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              _buildAdherenceGrid(),
              const SizedBox(height: 32),

              _buildMedicinesList(),
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 15, spreadRadius: 5)
          ]
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: _showAddMedicineSheet,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05), duration: 2.seconds),
    );
  }

  Widget _buildAdherenceGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().streamWeeklyMedicineLogs(currentUser!.uid),
      builder: (context, snapshot) {
        List<Widget> dayBlocks = [];
        final now = DateTime.now();
        
        for (int i = 6; i >= 0; i--) {
           DateTime day = now.subtract(Duration(days: i));
           String dayStr = DateFormat('yyyy-MM-dd').format(day);
           String dayLetter = DateFormat('E').format(day).substring(0, 1);
           
           bool hasData = snapshot.hasData;
           List<QueryDocumentSnapshot> logsForDay = hasData 
             ? snapshot.data!.docs.where((doc) => doc['date'] == dayStr).toList()
             : [];

           Color blockColor = Colors.white.withOpacity(0.1);
           
           if (i == 0) {
             // Today is fluid
             blockColor = logsForDay.isNotEmpty ? Colors.amber : Colors.blueAccent; 
           } else if (logsForDay.isNotEmpty) {
             blockColor = Colors.green;
           } else if (i > 0) {
             blockColor = Colors.redAccent.withOpacity(0.5);
           }

           dayBlocks.add(
             GestureDetector(
               onTap: () {
                 setState(() {
                   _selectedDateStamp = dayStr;
                 });
               },
               child: Column(
                 children: [
                   Text(dayLetter, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                   const SizedBox(height: 8),
                   Container(
                     width: 35, height: 35,
                     decoration: BoxDecoration(
                       color: blockColor,
                       borderRadius: BorderRadius.circular(10),
                       border: _selectedDateStamp == dayStr ? Border.all(color: Colors.white, width: 2) : null,
                     ),
                   )
                 ],
               ),
             )
           );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayBlocks,
          ),
        ).animate().fadeIn();
      }
    );
  }

  Widget _buildMedicinesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().streamMedicines(currentUser!.uid),
      builder: (context, medSnapshot) {
        if (medSnapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        }
        
        if (!medSnapshot.hasData || medSnapshot.data!.docs.isEmpty) {
           return Center(
             child: Column(
               children: [
                 const SizedBox(height: 40),
                 Icon(Icons.medication, size: 80, color: Colors.white.withOpacity(0.2)),
                 const SizedBox(height: 16),
                 const Text("No medicines scheduled.", style: TextStyle(color: Colors.white70)),
               ],
             )
           );
        }

        final medicines = medSnapshot.data!.docs;

        return StreamBuilder<QuerySnapshot>(
          stream: FirestoreService().streamTodayMedicineLogs(currentUser!.uid, _selectedDateStamp),
          builder: (context, logSnapshot) {
            
            final Set<String> takenMedicineTimeIds = {};
            if (logSnapshot.hasData) {
               for (var doc in logSnapshot.data!.docs) {
                  takenMedicineTimeIds.add(doc['medicineId']);
               }
            }

            List<Widget> morning = [];
            List<Widget> afternoon = [];
            List<Widget> night = [];

            for (var med in medicines) {
              final data = med.data() as Map<String, dynamic>;
              List<dynamic> times = data['times'] ?? [];
              Color baseColor = Color(int.parse(data['color'], radix: 16)).withOpacity(1.0);

              for (String time in times) {
                String uniqueMedTimeId = "${med.id}_$time";
                bool isTaken = takenMedicineTimeIds.contains(uniqueMedTimeId);

                int hour = 8;
                if (time.toLowerCase() == 'morning') hour = 8;
                else if (time.toLowerCase() == 'afternoon') hour = 14;
                else if (time.toLowerCase() == 'night') hour = 20;
                else hour = int.tryParse(time.split(":")[0]) ?? 8;
                
                Widget card = Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: MedicineCard(
                    userId: currentUser!.uid,
                    medicineId: uniqueMedTimeId,
                    name: data['name'],
                    dosage: data['dosage'],
                    time: time,
                    instructions: data['instructions'] ?? "",
                    color: baseColor,
                    initialTakenStatus: isTaken,
                    dateStamp: _selectedDateStamp,
                  ),
                );

                if (hour < 12) {
                  morning.add(card);
                } else if (hour < 18) {
                  afternoon.add(card);
                } else {
                  night.add(card);
                }
              }
            }

            List<Widget> finalLayout = [];
            
            Widget section(String title, List<Widget> items) {
              if (items.isEmpty) return const SizedBox();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...items
                ],
              );
            }

            finalLayout.add(section("Morning", morning));
            finalLayout.add(section("Afternoon", afternoon));
            finalLayout.add(section("Night", night));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimateList(
                interval: 80.ms,
                effects: [SlideEffect(begin: const Offset(1, 0), end: Offset.zero, curve: Curves.easeOutQuart), const FadeEffect()],
                children: finalLayout,
              ),
            );
          }
        );
      }
    );
  }
}
