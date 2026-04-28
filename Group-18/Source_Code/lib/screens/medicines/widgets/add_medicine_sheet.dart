import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore_service.dart';

class AddMedicineSheet extends StatefulWidget {
  const AddMedicineSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddMedicineSheet(),
    );
  }

  @override
  State<AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<AddMedicineSheet> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _selectedTimeSlot = 'Morning';
  bool _isSaving = false;
  Color _selectedColor = Colors.blueAccent;

  final List<Color> _colors = [Colors.blueAccent, Colors.redAccent, Colors.amber, Colors.teal, Colors.purple];

  Future<void> _submit() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirestoreService().addMedicine(
        userId: user.uid,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: "Daily",
        times: [_selectedTimeSlot], 
        instructions: _instructionsController.text.trim(),
        colorHex: _selectedColor.value.toRadixString(16),
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            const Text("Add New Medicine", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            
            _buildInput("Medicine Name", _nameController),
            const SizedBox(height: 12),
            _buildInput("Dosage (e.g. 1 Pill, 50mg)", _dosageController),
            const SizedBox(height: 16),
            const Text("Time slot", style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Morning', 'Afternoon', 'Night'].map((slot) {
                return ChoiceChip(
                  label: Text(slot),
                  selected: _selectedTimeSlot == slot,
                  onSelected: (selected) {
                     if (selected) setState(() => _selectedTimeSlot = slot);
                  },
                  selectedColor: Colors.blueAccent,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.white),
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.transparent)),
                );
              }).toList()
            ),
            const SizedBox(height: 12),
            _buildInput("Instructions (e.g. After meal)", _instructionsController),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _colors.map((c) => GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: CircleAvatar(
                   backgroundColor: c,
                   radius: _selectedColor == c ? 18 : 12,
                   child: _selectedColor == c ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                ),
              )).toList(),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Schedule", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
