import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/firestore_service.dart';

class AnimatedAlertTile extends StatefulWidget {
  final String userId;
  final String alertId;
  final String type;
  final String severity; // critical, warning, normal
  final String value;
  final String message;
  final Timestamp? timestamp;
  final bool isRead;

  const AnimatedAlertTile({
    super.key,
    required this.userId,
    required this.alertId,
    required this.type,
    required this.severity,
    required this.value,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  @override
  State<AnimatedAlertTile> createState() => _AnimatedAlertTileState();
}

class _AnimatedAlertTileState extends State<AnimatedAlertTile> {
  bool _expanded = false;

  void _onTap() async {
    setState(() => _expanded = !_expanded);
    if (!widget.isRead) {
      await FirestoreService().markAlertAsRead(widget.userId, widget.alertId);
    }
  }

  Color get _severityColor {
    switch (widget.severity.toLowerCase()) {
      case 'critical': return Colors.redAccent;
      case 'warning': return Colors.amber;
      default: return Colors.green;
    }
  }

  IconData get _severityIcon {
    switch (widget.severity.toLowerCase()) {
      case 'critical': return Icons.warning_rounded;
      case 'warning': return Icons.info_outline;
      default: return Icons.check_circle_outline;
    }
  }

  String get _timeAgo {
    if (widget.timestamp == null) return 'Just now';
    final now = DateTime.now();
    final diff = now.difference(widget.timestamp!.toDate());
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    Widget card = GestureDetector(
       onTap: _onTap,
       child: AnimatedContainer(
         duration: const Duration(milliseconds: 300),
         margin: const EdgeInsets.only(bottom: 12),
         decoration: BoxDecoration(
           color: widget.isRead ? Colors.white.withOpacity(0.05) : const Color(0xFF0D1B2A),
           borderRadius: BorderRadius.circular(16),
           border: Border(left: BorderSide(color: _severityColor, width: 4)),
         ),
         child: AnimatedSize(
           duration: const Duration(milliseconds: 300),
           curve: Curves.easeInOut,
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     Icon(_severityIcon, color: _severityColor, size: 24),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Text(
                                 widget.type.toUpperCase(),
                                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                               ),
                               const SizedBox(width: 8),
                               if (!widget.isRead && widget.severity.toLowerCase() == 'critical')
                                 Container(
                                   width: 8, height: 8,
                                   decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                 ).animate(onPlay: (c)=>c.repeat(reverse:true)).scale(begin: const Offset(0.8,0.8), end: const Offset(1.5,1.5), duration: 400.ms),
                             ],
                           ),
                           const SizedBox(height: 4),
                           Text(_timeAgo, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                         ],
                       ),
                     ),
                     Text(widget.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                   ],
                 ),
                 if (_expanded) ...[
                   const SizedBox(height: 16),
                   const Divider(color: Colors.white12),
                   const SizedBox(height: 8),
                   Text(
                     widget.message,
                     style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5),
                   ),
                 ]
               ],
             ),
           ),
         ),
       ),
    );

    if (!widget.isRead && widget.severity.toLowerCase() == 'critical') {
       card = card.animate().shake(hz: 8, curve: Curves.easeInOutCubic, duration: 600.ms);
    } else {
       card = card.animate().fadeIn(duration: 400.ms);
    }
    
    return card;
  }
}
