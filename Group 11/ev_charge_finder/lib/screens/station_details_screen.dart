import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../models/charging_station.dart';
import 'booking_screen.dart';

class StationDetailsScreen extends StatelessWidget {
  final ChargingStation station;
  const StationDetailsScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(station.name,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Station card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  // FIX: was Colors.black..withValues (cascade ..) → single dot .
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 2))
                ]),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.ev_station,
                            color: AppColors.primary, size: 30)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(station.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(station.address,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ])),
                  ]),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 12),

                  // Info grid
                  Row(children: [
                    _infoTile(Icons.star, '${station.rating}', 'Rating',
                        AppColors.warning),
                    const SizedBox(width: 12),
                    _infoTile(Icons.near_me, station.distanceLabel,
                        'Distance', AppColors.primary),
                    const SizedBox(width: 12),
                    _infoTile(Icons.currency_rupee,
                        '${station.pricePerUnit}/kWh', 'Price',
                        AppColors.success),
                  ]),
                  const SizedBox(height: 12),

                  // Charger types
                  const Text('Charger Types',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: station.chargerTypes
                          .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius:
                            BorderRadius.circular(20)),
                        child: Text(t,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ))
                          .toList()),
                  const SizedBox(height: 12),

                  // Amenities
                  if (station.amenities.isNotEmpty) ...[
                    const Text('Amenities',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: station.amenities
                            .map((a) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius:
                              BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.divider)),
                          child: Text(a,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ))
                            .toList()),
                  ],
                ]),
          ),

          const SizedBox(height: 16),

          // Live slot count from Firestore
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('stations')
                .doc(station.id)
                .snapshots(),
            builder: (context, snap) {
              int available = station.availableSlots;
              if (snap.hasData && snap.data!.exists) {
                final data =
                snap.data!.data() as Map<String, dynamic>;
                final slots =
                    data['slots'] as Map<String, dynamic>? ?? {};
                available = slots.values
                    .where((v) => v['booked'] == false)
                    .length;
              }
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: available > 0
                      ? AppColors.slotAvailable.withOpacity(0.08)
                      : AppColors.slotBooked.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: available > 0
                          ? AppColors.slotAvailable.withOpacity(0.3)
                          : AppColors.slotBooked.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Icon(
                      available > 0
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: available > 0
                          ? AppColors.slotAvailable
                          : AppColors.slotBooked),
                  const SizedBox(width: 12),
                  Text(
                      available > 0
                          ? '$available slots available right now'
                          : 'No slots available',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: available > 0
                              ? AppColors.slotAvailable
                              : AppColors.slotBooked)),
                ]),
              );
            },
          ),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('stations')
                .doc(station.id)
                .snapshots(),
            builder: (context, snap) {
              int available = station.availableSlots;
              if (snap.hasData && snap.data!.exists) {
                final data =
                snap.data!.data() as Map<String, dynamic>;
                final slots =
                    data['slots'] as Map<String, dynamic>? ?? {};
                available = slots.values
                    .where((v) => v['booked'] == false)
                    .length;
              }
              return ElevatedButton.icon(
                onPressed: available > 0
                    ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            BookingScreen(station: station)))
                    : null,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(available > 0
                    ? 'Book a Slot ($available free)'
                    : 'No Slots Available'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoTile(
      IconData icon, String value, String label, Color color) {
    return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ));
  }
}