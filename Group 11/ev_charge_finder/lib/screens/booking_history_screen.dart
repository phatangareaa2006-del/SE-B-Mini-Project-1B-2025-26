import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.instance.currentUserId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking History',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final docs = snap.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.history, size: 72, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('No booking history yet',
                    style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                const Text('Your past bookings will appear here',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ]),
            );
          }

          // Sort by createdAt descending in memory
          final sorted = docs.toList()
            ..sort((a, b) {
              final aDate = (a.data() as Map)['createdAt'] ?? '';
              final bDate = (b.data() as Map)['createdAt'] ?? '';
              return bDate.compareTo(aDate);
            });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final b = sorted[i].data() as Map<String, dynamic>;
              return _HistoryCard(data: b);
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _HistoryCard({required this.data});

  Color get _statusColor {
    switch (data['status']) {
      case 'upcoming':  return AppColors.primary;
      case 'completed': return AppColors.slotAvailable;
      case 'cancelled': return AppColors.error;
      default:          return AppColors.textSecondary;
    }
  }

  IconData get _statusIcon {
    switch (data['status']) {
      case 'upcoming':  return Icons.access_time;
      case 'completed': return Icons.check_circle_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      default:          return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(data['date'] ?? '');
    final createdAt = DateTime.tryParse(data['createdAt'] ?? '');

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12, offset: const Offset(0, 2))]),
      child: Column(children: [
        // Status bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.08),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(children: [
            Icon(_statusIcon, color: _statusColor, size: 16),
            const SizedBox(width: 6),
            Text((data['status'] ?? '').toUpperCase(),
                style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700, color: _statusColor)),
            const Spacer(),
            if (createdAt != null)
              Text(DateFormat('d MMM yyyy').format(createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['stationName'] ?? '',
                style: const TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(data['stationAddress'] ?? '',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            Text('Booking ID: ${data['id'] ?? ''}',
                style: const TextStyle(fontSize: 10,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace')),
          ]),
        ),
      ]),
    );
  }

  Widget _chip(IconData icon, String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 5),
      Text(text, style: TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}