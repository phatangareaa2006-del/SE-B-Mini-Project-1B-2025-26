import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _cancelBooking(Map<String, dynamic> b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Cancel booking at ${b['stationName']}?\nThe slot will be released.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel Booking')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('bookings').doc(b['id'])
          .update({'status': 'cancelled'});

      await FirebaseFirestore.instance
          .collection('stations').doc(b['stationId'])
          .update({'slots.${b['timeSlot']}': {'booked': false, 'userId': null}});

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Booking cancelled. Slot is now free.'),
          backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary, indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabCtrl, children: [
        _buildList('upcoming', canCancel: true),
        _buildList('completed'),
        _buildList('cancelled'),
      ]),
    );
  }

  Widget _buildList(String status, {bool canCancel = false}) {
    final userId = AuthService.instance.currentUserId;

    return StreamBuilder<QuerySnapshot>(
      // ── FIXED: removed .orderBy('createdAt', descending: true) ──
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
              color: AppColors.primary));
        }
        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(status == 'upcoming' ? Icons.calendar_today_outlined
                : status == 'completed' ? Icons.check_circle_outline
                : Icons.cancel_outlined,
                size: 64, color: AppColors.divider),
            const SizedBox(height: 16),
            Text('No $status bookings',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            const SizedBox(height: 8),
            const Text('Book a slot from the Map tab',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final b = docs[i].data() as Map<String, dynamic>;
            return _BookingCard(
                data: b,
                canCancel: canCancel,
                onCancel: () => _cancelBooking(b));
          },
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool canCancel;
  final VoidCallback? onCancel;

  const _BookingCard({
    required this.data,
    this.canCancel = false,
    this.onCancel,
  });

  Color get _statusColor {
    switch (data['status']) {
      case 'upcoming':  return AppColors.primary;
      case 'completed': return AppColors.slotAvailable;
      default:          return AppColors.slotBooked;
    }
  }

  IconData get _statusIcon {
    switch (data['status']) {
      case 'upcoming':  return Icons.access_time;
      case 'completed': return Icons.check_circle_rounded;
      default:          return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(data['date'] ?? '');

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 12, offset: const Offset(0, 2))]),
      child: Column(children: [

        // Status bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(children: [
            Icon(_statusIcon, color: _statusColor, size: 16),
            const SizedBox(width: 6),
            Text((data['status'] ?? '').toUpperCase(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: _statusColor)),
            const Spacer(),
            Text(data['id'] ?? '', style: const TextStyle(fontSize: 10,
                color: AppColors.textSecondary, fontFamily: 'monospace')),
          ]),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Station name
            Text(data['stationName'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(data['stationAddress'] ?? '',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),

            const SizedBox(height: 14),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 10),

            // Details chips
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (date != null)
                _chip(Icons.calendar_today,
                    DateFormat('EEE, MMM d yyyy').format(date),
                    AppColors.textSecondary),
              _chip(Icons.access_time, data['timeSlot'] ?? '',
                  AppColors.textSecondary),
              if (data['durationLabel'] != null)
                _chip(Icons.timer_outlined, data['durationLabel'],
                    AppColors.primary),
              _chip(Icons.electrical_services, data['chargerType'] ?? '',
                  AppColors.warning),
              if ((data['totalAmount'] ?? 0) > 0)
                _chip(Icons.currency_rupee,
                    'Paid ₹${(data['totalAmount'] as num).toStringAsFixed(0)}',
                    AppColors.success),
              _chip(Icons.payment, data['paymentMethod'] ?? '',
                  AppColors.textSecondary),
            ]),

            // Cancel button
            if (canCancel) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Cancel Booking'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1),
                    minimumSize: const Size(double.infinity, 42)),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _chip(IconData icon, String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color), const SizedBox(width: 5),
      Text(text, style: TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}