import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../models/charging_station.dart';
import '../services/auth_service.dart';

class BookingScreen extends StatefulWidget {
  final ChargingStation station;
  const BookingScreen({super.key, required this.station});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  int _selectedDuration = 60;
  bool _isBooking = false;

  static const List<String> _timeSlots = [
    '6:00 AM','7:00 AM','8:00 AM','9:00 AM',
    '10:00 AM','11:00 AM','12:00 PM','1:00 PM',
    '2:00 PM','3:00 PM','4:00 PM','5:00 PM',
    '6:00 PM','7:00 PM','8:00 PM','9:00 PM','10:00 PM',
  ];

  // ── CHANGED: added 1 min for demo ──
  static const List<Map<String, dynamic>> _durations = [
    {'label': '1 min',   'minutes': 1,   'kWh': 1.0},
    {'label': '30 min',  'minutes': 30,  'kWh': 5.0},
    {'label': '1 hour',  'minutes': 60,  'kWh': 10.0},
    {'label': '2 hours', 'minutes': 120, 'kWh': 20.0},
  ];

  double get _sessionKwh => _durations
      .firstWhere((d) => d['minutes'] == _selectedDuration)['kWh'] as double;

  double get _totalAmount => _sessionKwh * widget.station.pricePerUnit;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (_, child) => Theme(
          data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary)),
          child: child!),
    );
    if (d != null) setState(() { _selectedDate = d; _selectedSlot = null; });
  }

  void _onProceedTap() {
    if (_selectedSlot == null) return;
    _showPaymentSheet();
  }

  void _showPaymentSheet() {
    String selectedMethod = 'upi';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24, left: 24, right: 24),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Payment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Select payment method to confirm slot',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.accentLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  _sRow('Station', widget.station.name),
                  const SizedBox(height: 8),
                  _sRow('Date', DateFormat('EEE, MMM d yyyy').format(_selectedDate)),
                  const SizedBox(height: 8),
                  _sRow('Time Slot', _selectedSlot!),
                  const SizedBox(height: 8),
                  _sRow('Duration',
                      _durations.firstWhere((d) => d['minutes'] == _selectedDuration)['label'] as String),
                  const Divider(height: 20, color: AppColors.divider),
                  _sRow('Rate', '₹${widget.station.pricePerUnit}/kWh × ${_sessionKwh.toInt()} kWh'),
                  const SizedBox(height: 4),
                  _sRow('Total', '₹${_totalAmount.toStringAsFixed(0)}', isTotal: true),
                ]),
              ),
              const SizedBox(height: 20),

              const Text('Select Payment Method',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),

              ...[
                ['upi',  Icons.account_balance_wallet_outlined, 'UPI', 'Google Pay, PhonePe, Paytm — QR shown'],
                ['card', Icons.credit_card_outlined,            'Credit / Debit Card', 'Visa, Mastercard, RuPay'],
                ['net',  Icons.account_balance_outlined,        'Net Banking', 'All major banks'],
                ['cash', Icons.money_outlined,                  'Pay at Station', 'Cash on arrival'],
              ].map((m) => GestureDetector(
                onTap: () => setModal(() => selectedMethod = m[0] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                      color: selectedMethod == m[0]
                          ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selectedMethod == m[0]
                              ? AppColors.primary : AppColors.divider, width: 1.5)),
                  child: Row(children: [
                    Icon(m[1] as IconData,
                        color: selectedMethod == m[0]
                            ? AppColors.primary : AppColors.textSecondary, size: 22),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m[2] as String, style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedMethod == m[0]
                              ? AppColors.primary : AppColors.textPrimary)),
                      Text(m[3] as String, style: const TextStyle(fontSize: 11,
                          color: AppColors.textSecondary)),
                    ])),
                    if (selectedMethod == m[0])
                      const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 20),
                  ]),
                ),
              )),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (selectedMethod == 'upi') {
                    _showQRSheet();
                  } else {
                    _processPayment(selectedMethod);
                  }
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Text(selectedMethod == 'upi'
                    ? 'Continue to QR Payment'
                    : 'Pay ₹${_totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  void _showQRSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('Scan & Pay via UPI',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('₹${_totalAmount.toStringAsFixed(0)} · ${widget.station.name}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(16)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.qr_code_2, size: 160, color: AppColors.primary),
              const Text('UPI QR Code',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              const Text('Pay to UPI ID',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const Text('evcharge@ybl',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 8),
          const Text('Google Pay • PhonePe • Paytm • Any UPI App',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _processPayment('upi');
            },
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text('Payment Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: AppColors.slotAvailable,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ]),
      ),
    );
  }

  Widget _sRow(String l, String v, {bool isTotal = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: TextStyle(fontSize: isTotal ? 14 : 13,
          color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal)),
      Flexible(child: Text(v, style: TextStyle(fontSize: isTotal ? 16 : 13,
          fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
          color: isTotal ? AppColors.primary : AppColors.textPrimary),
          textAlign: TextAlign.end)),
    ],
  );

  Future<void> _processPayment(String method) async {
    setState(() => _isBooking = true);
    await Future.delayed(const Duration(seconds: 1));

    try {
      final bookingId = 'BK-${DateTime.now().millisecondsSinceEpoch}';
      final userId = AuthService.instance.currentUserId;
      print('QUERYING BOOKINGS FOR: $userId');
      final endTime = DateTime.now().add(Duration(minutes: _selectedDuration));

      await FirebaseFirestore.instance
          .collection('bookings').doc(bookingId).set({
        'id': bookingId,
        'stationId': widget.station.id,
        'stationName': widget.station.name,
        'stationAddress': widget.station.address,
        'date': _selectedDate.toIso8601String(),
        'timeSlot': _selectedSlot,
        'duration': _selectedDuration,
        'durationLabel': _durations.firstWhere(
                (d) => d['minutes'] == _selectedDuration)['label'],
        'status': 'upcoming',
        'pricePerUnit': widget.station.pricePerUnit,
        'chargerType': widget.station.chargerTypes.isNotEmpty
            ? widget.station.chargerTypes.first : 'AC',
        'userId': userId,
        'totalAmount': _totalAmount,
        'paymentStatus': 'paid',
        'paymentMethod': method,
        'slotExpiresAt': endTime.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      await FirebaseFirestore.instance
          .collection('stations').doc(widget.station.id)
          .update({'slots.$_selectedSlot': {
        'booked': true,
        'userId': userId,
        'bookingId': bookingId,
        'expiresAt': endTime.toIso8601String(),
      }});

      // ── Auto-release after selected duration ──
      Timer(Duration(minutes: _selectedDuration), () async {
        try {
          await FirebaseFirestore.instance
              .collection('stations').doc(widget.station.id)
              .update({'slots.$_selectedSlot': {
            'booked': false, 'userId': null, 'bookingId': null}});
          await FirebaseFirestore.instance
              .collection('bookings').doc(bookingId)
              .update({'status': 'completed'});
        } catch (_) {}
      });

      setState(() => _isBooking = false);
      if (mounted) _showSuccess(bookingId);

    } catch (e) {
      setState(() => _isBooking = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  void _showSuccess(String bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: AppColors.slotAvailable.withOpacity(0.1),
                    border: Border.all(
                        color: AppColors.slotAvailable.withOpacity(0.3), width: 3)),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.slotAvailable, size: 48)),
            const SizedBox(height: 20),
            const Text('Booking Confirmed! 🎉',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Your slot is confirmed & saved.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.background,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                _dRow('Booking ID', bookingId),
                const SizedBox(height: 6),
                _dRow('Station', widget.station.name),
                const SizedBox(height: 6),
                _dRow('Date', DateFormat('EEE, MMM d').format(_selectedDate)),
                const SizedBox(height: 6),
                _dRow('Time', _selectedSlot ?? ''),
                const SizedBox(height: 6),
                _dRow('Duration',
                    _durations.firstWhere(
                            (d) => d['minutes'] == _selectedDuration)['label'] as String),
                const SizedBox(height: 6),
                _dRow('Amount Paid', '₹${_totalAmount.toStringAsFixed(0)}'),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.info_outline,
                    color: AppColors.warning, size: 16),
                const SizedBox(width: 8),
                // ── CHANGED: shows actual selected duration label ──
                Expanded(child: Text(
                    'Slot auto-releases after ${_durations.firstWhere((d) => d['minutes'] == _selectedDuration)['label']}',
                    style: const TextStyle(fontSize: 12, color: AppColors.warning))),
              ]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { Navigator.of(context)..pop()..pop()..pop(); },
              child: const Text('Done'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _dRow(String l, String v) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      Flexible(child: Text(v, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          textAlign: TextAlign.end)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book a Slot',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [

            // Station info card
            _card(Row(children: [
              Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.ev_station,
                      color: AppColors.primary, size: 26)),
              const SizedBox(width: 14),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.station.name, style: const TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${widget.station.distanceLabel} · '
                    '${widget.station.totalSlots} charging points',
                    style: const TextStyle(fontSize: 13,
                        color: AppColors.textSecondary)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('₹${widget.station.pricePerUnit}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
                const Text('per kWh', style: TextStyle(fontSize: 11,
                    color: AppColors.textSecondary)),
              ]),
            ])),
            const SizedBox(height: 14),

            // Duration selector
            _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Charging Duration',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Row(children: _durations.map((d) {
                final isSelected = _selectedDuration == d['minutes'];
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _selectedDuration = d['minutes'] as int),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: 2)),
                    child: Column(children: [
                      Text(d['label'] as String, style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textPrimary)),
                      Text('${d['kWh']} kWh', style: TextStyle(fontSize: 11,
                          color: isSelected ? Colors.white70 : AppColors.textSecondary)),
                    ]),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.currency_rupee, color: AppColors.primary, size: 16),
                  Expanded(child: Text(
                      'Estimated cost: ₹${_totalAmount.toStringAsFixed(0)} for ${_sessionKwh.toInt()} kWh',
                      style: const TextStyle(fontSize: 12, color: AppColors.primary,
                          fontWeight: FontWeight.w600))),
                ]),
              ),
            ])),
            const SizedBox(height: 14),

            // Date picker
            _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Select Date',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              InkWell(onTap: _pickDate, borderRadius: BorderRadius.circular(12),
                  child: Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: const Border.fromBorderSide(
                            BorderSide(color: AppColors.divider))),
                    child: Row(children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textSecondary, size: 20),
                    ]),
                  )),
            ])),
            const SizedBox(height: 14),

            // Time slots
            _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Select Time Slot',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Spacer(),
                _dot(AppColors.slotAvailable, 'Available'),
                const SizedBox(width: 10),
                _dot(AppColors.slotBooked, 'Booked'),
              ]),
              const SizedBox(height: 14),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stations').doc(widget.station.id).snapshots(),
                builder: (context, snap) {
                  final bookedSlots = <String>{};
                  if (snap.hasData && snap.data!.exists) {
                    final data = snap.data!.data() as Map<String, dynamic>;
                    final slots = data['slots'] as Map<String, dynamic>? ?? {};
                    for (final entry in slots.entries) {
                      if (entry.value['booked'] == true) {
                        bookedSlots.add(entry.key);
                      }
                    }
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, childAspectRatio: 2.4,
                        mainAxisSpacing: 8, crossAxisSpacing: 8),
                    itemCount: _timeSlots.length,
                    itemBuilder: (_, i) {
                      final slot = _timeSlots[i];
                      final isBooked = bookedSlots.contains(slot);
                      final isSelected = _selectedSlot == slot;
                      Color bg, text, border;
                      if (isBooked) {
                        bg = AppColors.slotBooked.withOpacity(0.08);
                        text = AppColors.slotBooked.withOpacity(0.5);
                        border = AppColors.slotBooked.withOpacity(0.2);
                      } else if (isSelected) {
                        bg = AppColors.primary; text = Colors.white;
                        border = AppColors.primary;
                      } else {
                        bg = AppColors.slotAvailable.withOpacity(0.08);
                        text = AppColors.primary;
                        border = AppColors.slotAvailable.withOpacity(0.4);
                      }
                      return GestureDetector(
                        onTap: isBooked ? null
                            : () => setState(() => _selectedSlot = slot),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(color: bg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: border)),
                            alignment: Alignment.center,
                            child: Text(slot, style: TextStyle(fontSize: 11,
                                fontWeight: FontWeight.w600, color: text))),
                      );
                    },
                  );
                },
              ),
            ])),

            if (_selectedSlot != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                      'Slot: $_selectedSlot  ·  '
                          '${_durations.firstWhere((d) => d['minutes'] == _selectedDuration)['label']}  ·  '
                          '₹${_totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.primary,
                          fontWeight: FontWeight.w500))),
                ]),
              ),
            ],
            const SizedBox(height: 24),
          ]),
        )),

        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          decoration: BoxDecoration(color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                  blurRadius: 12, offset: const Offset(0, -4))]),
          child: ElevatedButton.icon(
            onPressed: (_selectedSlot != null && !_isBooking) ? _onProceedTap : null,
            icon: _isBooking
                ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2,
                    color: Colors.white))
                : const Icon(Icons.payment, size: 20),
            label: Text(_isBooking ? 'Processing...' : 'Proceed to Payment'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
          ),
        ),
      ]),
    );
  }

  Widget _card(Widget child) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, 2))]),
    child: child,
  );

  Widget _dot(Color c, String l) => Row(children: [
    Container(width: 10, height: 10,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
    const SizedBox(width: 4),
    Text(l, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);
}