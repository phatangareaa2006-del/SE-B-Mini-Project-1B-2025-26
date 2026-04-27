import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {})),
          IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: _pickDate),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Bookings'),
            Tab(text: 'Slots')
          ],
        ),
      ),
      body: TabBarView(
          controller: _tabCtrl,
          children: [_overview(), _bookingsList(), _slotsView()]),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (_, child) => Theme(
          data: Theme.of(context).copyWith(
              colorScheme:
              const ColorScheme.light(primary: AppColors.primary)),
          child: child!),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  // FIX: Was missing return statement and wrapping Column — orphaned widgets
  Widget _overview() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('date',
          isGreaterThanOrEqualTo: DateTime(_selectedDate.year,
              _selectedDate.month, _selectedDate.day)
              .toIso8601String())
          .where('date',
          isLessThan: DateTime(_selectedDate.year, _selectedDate.month,
              _selectedDate.day + 1)
              .toIso8601String())
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        final total = docs
            .where((d) => (d.data() as Map)['status'] != 'cancelled')
            .length;
        final completed = docs
            .where((d) => (d.data() as Map)['status'] == 'completed')
            .length;
        final upcoming = docs
            .where((d) => (d.data() as Map)['status'] == 'upcoming')
            .length;
        final revenue = docs
            .where((d) => (d.data() as Map)['status'] != 'cancelled')
            .fold(
            0.0,
                (s, d) =>
            s + ((d.data() as Map)['totalAmount'] ?? 0));

        // FIX: Wrapped everything in return + SingleChildScrollView + Column
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      AppColors.primaryDark,
                      AppColors.primary
                    ]),
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                      'Stats for ${DateFormat('EEEE, d MMM yyyy').format(_selectedDate)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _kpi('Total Bookings', '$total',
                      Icons.bookmark_outlined, AppColors.primary),
                  _kpi('Revenue', '₹${revenue.toStringAsFixed(0)}',
                      Icons.currency_rupee, AppColors.success),
                  _kpi('Upcoming', '$upcoming', Icons.access_time,
                      AppColors.warning),
                  _kpi('Completed', '$completed',
                      Icons.check_circle_outline, AppColors.slotAvailable),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _bookingsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
              child: Text('No bookings yet',
                  style: TextStyle(color: AppColors.textSecondary)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final b = docs[i].data() as Map<String, dynamic>;
            final sc = b['status'] == 'upcoming'
                ? AppColors.warning
                : b['status'] == 'completed'
                ? AppColors.success
                : AppColors.error;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2))
                  ]),
              child: Column(children: [
                Row(children: [
                  Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.person,
                          color: AppColors.primary, size: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b['stationName'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            Text(
                                '${b['chargerType']} · ₹${b['totalAmount']?.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ])),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: sc.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text((b['status'] ?? '').toUpperCase(),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: sc))),
                ]),
                const Divider(height: 16, color: AppColors.divider),
                Row(children: [
                  _iChip(Icons.access_time, b['timeSlot'] ?? ''),
                  const SizedBox(width: 8),
                  _iChip(
                      Icons.confirmation_number_outlined, b['id'] ?? ''),
                ]),
              ]),
            );
          },
        );
      },
    );
  }

  Widget _iChip(IconData icon, String text) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppColors.textSecondary),
      const SizedBox(width: 5),
      Text(text,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
    ]),
  );

  Widget _slotsView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stations')
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        const slots = [
          '6:00 AM', '7:00 AM', '8:00 AM', '9:00 AM', '10:00 AM',
          '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM',
          '4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM', '8:00 PM',
          '9:00 PM', '10:00 PM'
        ];

        Map<String, dynamic> slotData = {};
        if (snap.hasData && snap.data!.docs.isNotEmpty) {
          final data =
          snap.data!.docs.first.data() as Map<String, dynamic>;
          slotData = data['slots'] as Map<String, dynamic>? ?? {};
        }

        return Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(children: [
                _dot(AppColors.slotAvailable, 'Available'),
                const SizedBox(width: 16),
                _dot(AppColors.slotBooked, 'Booked'),
                const Spacer(),
                Text(
                    '${slotData.values.where((v) => v['booked'] == true).length}/${slots.length} booked',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ])),
          Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2),
                itemCount: slots.length,
                itemBuilder: (_, i) {
                  final slotKey = slots[i];
                  final isBooked = slotData[slotKey]?['booked'] == true;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                        color: isBooked
                            ? AppColors.slotBooked.withOpacity(0.1)
                            : AppColors.slotAvailable.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isBooked
                                ? AppColors.slotBooked.withOpacity(0.4)
                                : AppColors.slotAvailable
                                .withOpacity(0.4))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(slots[i],
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isBooked
                                      ? AppColors.slotBooked
                                      : AppColors.slotAvailable)),
                        ]),
                  );
                },
              )),
        ]);
      },
    );
  }

  Widget _dot(Color c, String l) => Row(children: [
    Container(
        width: 10,
        height: 10,
        decoration:
        BoxDecoration(shape: BoxShape.circle, color: c)),
    const SizedBox(width: 6),
    Text(l,
        style: const TextStyle(
            fontSize: 12, color: AppColors.textSecondary)),
  ]);
}