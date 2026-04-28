import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore_service.dart';

class LogVitalSheet extends StatefulWidget {
  final String activeTab; 
  
  const LogVitalSheet({super.key, required this.activeTab});

  static void show(BuildContext context, String activeTab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogVitalSheet(activeTab: activeTab),
    );
  }

  @override
  State<LogVitalSheet> createState() => _LogVitalSheetState();
}

class _LogVitalSheetState extends State<LogVitalSheet> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController(); // For diastolic
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _val1Controller.dispose();
    _val2Controller.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.activeTab) {
      case 'bp': return "Log Blood Pressure";
      case 'heartRate': return "Log Heart Rate";
      case 'bloodSugar': return "Log Blood Sugar";
      case 'spO2': return "Log SpO2 Level";
      case 'temperature_c': return "Log Temperature";
      case 'bmi': return "Log BMI";
      default: return "Log Vitals";
    }
  }

  String get _unit {
    switch (widget.activeTab) {
      case 'bp': return "mmHg";
      case 'heartRate': return "BPM";
      case 'bloodSugar': return "mg/dL";
      case 'spO2': return "%";
      case 'temperature_c': return "°C";
      case 'bmi': return "kg/m²";
      default: return "";
    }
  }

  Future<void> _submitData() async {
    if (_val1Controller.text.isEmpty) return;
    double val1 = double.tryParse(_val1Controller.text) ?? 0;
    double? val2;
    
    if (widget.activeTab == 'bp') {
      if (_val2Controller.text.isEmpty) return;
      val2 = double.tryParse(_val2Controller.text) ?? 0;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirestoreService().addVitalReading(
        userId: user.uid,
        type: widget.activeTab,
        value: val1,
        value2: val2,
        unit: _unit,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
    }
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1D2B64),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            if (widget.activeTab == 'bp')
              Row(
                children: [
                  Expanded(child: _buildInput("Systolic", _val1Controller)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("/", style: TextStyle(color: Colors.white, fontSize: 32)),
                  ),
                  Expanded(child: _buildInput("Diastolic", _val2Controller)),
                ],
              )
            else
              _buildInput("Measurement", _val1Controller),
              
            const SizedBox(height: 16),
            _buildInput("Notes (Optional)", _noteController, isNumber: false),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _submitData,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Reading", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {bool isNumber = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      ),
    );
  }
}
