import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../widgets/glass_card.dart';
import '../../../services/firestore_service.dart';

class MedicineCard extends StatefulWidget {
  final String userId;
  final String medicineId;
  final String name;
  final String dosage;
  final String time;
  final String instructions;
  final Color color;
  final bool initialTakenStatus;
  final String dateStamp;

  const MedicineCard({
    super.key,
    required this.userId,
    required this.medicineId,
    required this.name,
    required this.dosage,
    required this.time,
    required this.instructions,
    required this.color,
    required this.initialTakenStatus,
    required this.dateStamp,
  });

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _isFlipped = widget.initialTakenStatus;
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    if (_isFlipped) _flipController.value = 1.0;
  }

  @override
  void didUpdateWidget(MedicineCard oldWidget) {
    if (widget.initialTakenStatus != oldWidget.initialTakenStatus) {
      if (widget.initialTakenStatus && !_isFlipped) {
        _isFlipped = true;
        _flipController.forward();
      } else if (!widget.initialTakenStatus && _isFlipped) {
         _isFlipped = false;
         _flipController.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _onToggleTaken() async {
    if (_isFlipped) return;

    setState(() => _isFlipped = true);
    _flipController.forward();
    
    await FirestoreService().logMedicineTaken(
      userId: widget.userId,
      medicineId: widget.medicineId,
      status: 'taken',
      dateStamp: widget.dateStamp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
         double angle = _flipAnimation.value * pi;
         bool showBack = angle >= pi / 2;
         
         Matrix4 transform = Matrix4.identity()
           ..setEntry(3, 2, 0.001)
           ..rotateX(angle);

         return Transform(
           transform: transform,
           alignment: Alignment.center,
           child: GlassCard(
             padding: EdgeInsets.zero,
             child: showBack 
                 ? Transform(
                     transform: Matrix4.identity()..rotateX(pi),
                     alignment: Alignment.center,
                     child: _buildBackContent(),
                   )
                 : _buildFrontContent(),
           ),
         );
      },
    );
  }

  Widget _buildFrontContent() {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: widget.color, width: 6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(widget.dosage, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.white.withOpacity(0.5), size: 16),
                    const SizedBox(width: 4),
                    Text(widget.time, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: widget.color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text(widget.instructions, style: TextStyle(color: widget.color, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _onToggleTaken,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBackContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24)
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 36),
            const SizedBox(width: 12),
            Text("Taken at ${widget.time}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
