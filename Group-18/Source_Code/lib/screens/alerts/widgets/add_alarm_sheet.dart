import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore_service.dart';
import '../../../services/notification_service.dart';

class AddAlarmSheet extends StatefulWidget {
  const AddAlarmSheet({super.key});

  @override
  State<AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends State<AddAlarmSheet> {
  final _titleCtrl = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  List<int> _selectedDays = []; // 1=Mon, ..., 7=Sun

  final Map<int, String> _dayMap = {
    1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'
  };

  void _submit() async {
     final user = FirebaseAuth.instance.currentUser;
     if (user == null || _titleCtrl.text.isEmpty) return;

     final data = {
        'title': _titleCtrl.text,
        'hour': _time.hour,
        'minute': _time.minute,
        'daysOfWeek': _selectedDays,
        'isActive': true,
     };

     String newId = await FirestoreService().addPillAlarm(user.uid, data);

     // Schedule Notification
     await NotificationService().schedulePillAlarm(
        id: newId.hashCode,
        title: "Pill Reminder",
        body: "Time to take: ${_titleCtrl.text}",
        hour: _time.hour,
        minute: _time.minute,
        daysOfWeek: _selectedDays,
     );

     if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
       decoration: const BoxDecoration(
         color: Color(0xFF1D2B64),
         borderRadius: BorderRadius.vertical(top: Radius.circular(24))
       ),
       child: SingleChildScrollView(
         child: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text("New Pill Alarm", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
             const SizedBox(height: 20),
             
             TextField(
               controller: _titleCtrl, 
               style: const TextStyle(color: Colors.white), 
               decoration: const InputDecoration(labelText: "Pill Name", labelStyle: TextStyle(color: Colors.white54), prefixIcon: Icon(Icons.medication, color: Colors.blueAccent))
             ),
             const SizedBox(height: 24),

             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                  const Text("Alarm Time", style: TextStyle(color: Colors.white, fontSize: 16)),
                  TextButton.icon(
                     icon: const Icon(Icons.access_time, color: Colors.greenAccent),
                     label: Text(_time.format(context), style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                     onPressed: () async {
                        final res = await showTimePicker(context: context, initialTime: _time);
                        if (res != null) setState(() => _time = res);
                     }
                  )
               ]
             ),
             const SizedBox(height: 24),
             
             const Text("Repeat Days", style: TextStyle(color: Colors.white, fontSize: 16)),
             const SizedBox(height: 12),
             Wrap(
               spacing: 8,
               children: _dayMap.entries.map((e) {
                  final isSelected = _selectedDays.contains(e.key);
                  return FilterChip(
                     selected: isSelected,
                     label: Text(e.value),
                     labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white54),
                     selectedColor: Colors.blueAccent,
                     backgroundColor: Colors.white.withOpacity(0.05),
                     checkmarkColor: Colors.white,
                     onSelected: (val) {
                        setState(() {
                           if (val) _selectedDays.add(e.key);
                           else _selectedDays.remove(e.key);
                        });
                     }
                  );
               }).toList(),
             ),
             Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: Text(_selectedDays.isEmpty ? "Will repeat everyday." : "Will repeat on selected days.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
             ),

             SizedBox(
               width: double.infinity, height: 50,
               child: ElevatedButton(
                 onPressed: _submit,
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                 child: const Text("Save Alarm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
               )
             ),
             const SizedBox(height: 24),
           ],
         )
       )
    );
  }
}
