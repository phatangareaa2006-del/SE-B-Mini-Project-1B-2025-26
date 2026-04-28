import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/upi_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common_widgets.dart';

class RentalBookingSheet extends StatefulWidget {
  final Vehicle vehicle;
  const RentalBookingSheet({super.key, required this.vehicle});
  @override State<RentalBookingSheet> createState() => _RentalBookingSheetState();
}

class _RentalBookingSheetState extends State<RentalBookingSheet> {
  int _step = 0; // 0=datetime, 1=details, 2=payment
  DateTime _start = DateTime.now().add(const Duration(hours: 1));
  DateTime _end   = DateTime.now().add(const Duration(hours: 3));
  bool _checking = false, _available = true;

  final _licenseCtrl  = TextEditingController();
  final _pickupCtrl   = TextEditingController();
  String _payMethod   = 'upi';
  final _upiCtrl      = TextEditingController();
  final _cardNoCtrl   = TextEditingController();
  final _cardNameCtrl = TextEditingController();

  @override
  void dispose() {
    _licenseCtrl.dispose(); _pickupCtrl.dispose();
    _upiCtrl.dispose(); _cardNoCtrl.dispose(); _cardNameCtrl.dispose();
    UpiService.dispose(); // ✅ FIX: prevent memory leaks
    super.dispose();
  }

  int get _hours => _end.difference(_start).inHours.clamp(1, 999);
  double get _total => _hours * widget.vehicle.rentPerHour;

  Future<void> _checkAvailability() async {
    setState(() => _checking = true);
    final ok = await context.read<VehicleProvider>()
        .checkAvailability(widget.vehicle.id, _start, _end);
    setState(() { _available = ok; _checking = false; });
  }

  Future<void> _confirmBooking() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) { showError(context, 'Please login'); return; }
    if (_licenseCtrl.text.isEmpty || _pickupCtrl.text.isEmpty) {
      showError(context, 'Fill all required fields'); return;
    }
    if (_payMethod == 'upi' && _upiCtrl.text.isEmpty) {
      showError(context, 'Enter your UPI ID for receipt'); return;
    }

    // Book slot in Firestore
    final slot = BookedSlot(
      id:            'slot-${DateTime.now().millisecondsSinceEpoch}',
      vehicleId:     widget.vehicle.id,
      userId:        auth.user!.uid,
      userName:      auth.user!.displayName,
      startDateTime: _start,
      endDateTime:   _end,
      status:        'pending',
      totalCost:     _total,
    );
    final booked = await context.read<VehicleProvider>().bookSlot(slot);
    if (!booked) { showError(context, 'Booking failed. Try again.'); return; }

    // Save request
    await context.read<RequestProvider>().addRental(
      userId: auth.user!.uid,
      userContact: auth.user!.phone ?? auth.user!.email ?? '',
      userName: auth.user!.displayName,
      vehicleId: widget.vehicle.id,
      vehicleTitle: widget.vehicle.title,
      vehiclePrice: widget.vehicle.price,
      start: _start, end: _end, hours: _hours, totalCost: _total,
      licenseNo: _licenseCtrl.text,
      pickupLocation: _pickupCtrl.text,
      paymentMethod: _payMethod,
      upiId: _payMethod == 'upi' ? _upiCtrl.text : null,
      cardLast4: _payMethod == 'card' && _cardNoCtrl.text.length >= 4
          ? _cardNoCtrl.text.substring(_cardNoCtrl.text.length - 4) : null,
    );

    // ✅ FIX: Launch Razorpay with proper success/failure callbacks
    if (_payMethod == 'upi') {
      final txnRef = UpiService.generateRef();
      await UpiService.launch(
        amount:    _total,
        note:      'Rent: ${widget.vehicle.title}',
        txnRef:    txnRef,
        type:      'rental',
        itemTitle: widget.vehicle.title,
        userId:    auth.user?.uid ?? '',
        userName:  auth.user?.displayName ?? '',
        upiId:     _upiCtrl.text,
        contact:   auth.user?.phone ?? '9999999999',
        email:     auth.user?.email ?? 'customer@autohub.com',
        onSuccess: (res) {
          debugPrint('✅ Payment success: ${res.paymentId}');
          if (mounted) {
            Navigator.pop(context);
            showSuccess(context,
                '✅ Payment successful! Rental booked for $_hours hrs. '
                    'Admin will confirm shortly.');
          }
        },
        onFailure: (res) {
          debugPrint('❌ Payment failed: ${res.message}');
          if (mounted) {
            showError(context,
                '❌ Payment failed: ${res.message ?? 'Please try again'}');
          }
        },
      );
      // Don't pop here — let onSuccess handle it
      return;
    }

    // For COD / card — close sheet directly
    if (mounted) {
      Navigator.pop(context);
      showSuccess(context, '✅ Rental booked! ₹${_total.toInt()} for $_hours hrs. '
          'Admin will confirm shortly.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92, maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          const SheetHandle(),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: Text('Rent ${widget.vehicle.title}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              IconButton(icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(children: [
              for (int i = 0; i < 3; i++) ...[
                _StepDot(index: i, current: _step,
                    label: ['Date & Time', 'Details', 'Payment'][i]),
                if (i < 2) Expanded(child: Container(
                    height: 2,
                    color: _step > i ? AppTheme.primary : AppTheme.border)),
              ],
            ]),
          ),

          Expanded(child: ListView(controller: ctrl,
              padding: const EdgeInsets.all(20), children: [
                if (_step == 0) _buildStep0(),
                if (_step == 1) _buildStep1(),
                if (_step == 2) _buildStep2(),
              ])),

          // Bottom buttons
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20,
                MediaQuery.of(context).padding.bottom + 12),
            child: Row(children: [
              if (_step > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 90,
                    child: OutlineBtn(
                      label: 'Back',
                      onTap: () => setState(() => _step--),
                    ),
                  ),
                ),
              Expanded(child: _step < 2
                  ? PrimaryBtn(
                label: _step == 0
                    ? (_checking ? 'Checking...'
                    : _available ? 'Next →' : '⚠️ Not Available')
                    : 'Next →',
                loading: _checking,
                onTap: !_available && _step == 0 ? null : () async {
                  if (_step == 0) { await _checkAvailability(); if (_available) setState(() => _step++); }
                  else if (_step == 1) {
                    if (_licenseCtrl.text.trim().isEmpty) {
                      showError(context, 'Please enter your driving license number'); return;
                    }
                    if (_pickupCtrl.text.trim().isEmpty) {
                      showError(context, 'Please enter your pickup location'); return;
                    }
                    setState(() => _step++);
                  }
                  else { setState(() => _step++); }
                },
              )
                  : PrimaryBtn(
                label: 'Confirm & Pay ₹${_total.toInt()}',
                onTap: _confirmBooking,
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildStep0() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Pricing summary
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.warning, Color(0xFFE07000)]),
            borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.vehicle.title, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
          Text('₹${widget.vehicle.rentPerHour.toInt()}/hr',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
      ),
      const SizedBox(height: 16),

      // Date-time pickers
      const Text('Pick-up Date & Time', style: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      _DateTimeTile(
        label: '📅  Start', dt: _start,
        onTap: () async {
          final d = await showDatePicker(
            context: context, initialDate: _start,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 60)),
          );
          if (d == null) return;
          final t = await showTimePicker(
              context: context, initialTime: TimeOfDay.fromDateTime(_start));
          if (t == null) return;
          setState(() {
            _start = DateTime(d.year, d.month, d.day, t.hour, t.minute);
            if (_end.isBefore(_start.add(const Duration(hours: 1)))) {
              _end = _start.add(const Duration(hours: 2));
            }
          });
        },
      ),
      const SizedBox(height: 10),
      _DateTimeTile(
        label: '📅  End', dt: _end,
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: _end.isAfter(_start) ? _end : _start,
            firstDate: _start.add(const Duration(hours: 1)),
            lastDate: _start.add(const Duration(days: 30)),
          );
          if (d == null) return;
          final t = await showTimePicker(
              context: context, initialTime: TimeOfDay.fromDateTime(_end));
          if (t == null) return;
          setState(() {
            _end = DateTime(d.year, d.month, d.day, t.hour, t.minute);
          });
        },
      ),
      const SizedBox(height: 16),

      // Cost preview
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$_hours hour${_hours > 1 ? 's' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('₹${_total.toInt()}',
              style: const TextStyle(
                  color: AppTheme.success, fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ]),
      ),

      // Availability status
      if (!_available) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.error.withOpacity(0.3))),
          child: const Row(children: [
            Icon(Icons.warning_amber, color: AppTheme.error, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text(
                '⚠️ This vehicle is already booked for the selected time slot. '
                    'Please choose a different time.',
                style: TextStyle(color: AppTheme.error, fontSize: 12))),
          ]),
        ),
      ],
    ]);
  }

  Widget _buildStep1() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📋 Required Documents', style: TextStyle(
              fontWeight: FontWeight.w700, color: AppTheme.warning)),
          SizedBox(height: 4),
          Text('• Valid Driving License  •  Age 21+',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ),
      const SizedBox(height: 16),
      AppField(label: 'Driving License Number *', hint: 'MH01 2023 1234567',
          controller: _licenseCtrl),
      AppField(label: 'Pickup Location *', hint: 'Enter your pickup address',
          controller: _pickupCtrl, maxLines: 2),
      const AdminConfirmBanner(),
    ]);
  }

  Widget _buildStep2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Summary
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          InfoRow(label: 'Vehicle',  value: widget.vehicle.title),
          InfoRow(label: 'Duration', value: '$_hours hrs'),
          InfoRow(label: 'Rate',     value: '₹${widget.vehicle.rentPerHour.toInt()}/hr'),
          const Divider(height: 16),
          InfoRow(label: 'Total', value: '₹${_total.toInt()}',
              valueColor: AppTheme.primary),
        ]),
      ),
      const SizedBox(height: 16),

      // Payment method
      const Text('Payment Method', style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      _PayRow(id: 'upi', label: '📱  UPI (GPay / PhonePe / Paytm)',
          selected: _payMethod, onTap: (v) => setState(() => _payMethod = v)),
      _PayRow(id: 'card', label: '💳  Credit / Debit Card',
          selected: _payMethod, onTap: (v) => setState(() => _payMethod = v)),
      _PayRow(id: 'cod', label: '💵  Cash on Delivery',
          selected: _payMethod, onTap: (v) => setState(() => _payMethod = v)),
      const SizedBox(height: 14),

      if (_payMethod == 'upi')
        AppField(label: 'Your UPI ID (for receipt)', hint: 'yourname@upi',
            controller: _upiCtrl),
      if (_payMethod == 'card') ...[
        AppField(label: 'Card Number', hint: '16-digit number',
            controller: _cardNoCtrl, keyboard: TextInputType.number),
        AppField(label: 'Name on Card', hint: 'As printed',
            controller: _cardNameCtrl),
      ],
      if (_payMethod == 'cod')
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10)),
          child: Text('💵 Pay ₹${_total.toInt()} when you pick up the vehicle.',
              style: const TextStyle(color: AppTheme.warning, fontSize: 13)),
        ),
    ]);
  }
}

class _StepDot extends StatelessWidget {
  final int index, current; final String label;
  const _StepDot({required this.index, required this.current, required this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index <= current ? AppTheme.primary : AppTheme.border,
      ),
      child: Center(child: index < current
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : Text('${index + 1}', style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold,
          color: index == current ? Colors.white : AppTheme.textSecondary))),
    ),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(
        fontSize: 9, color: index <= current ? AppTheme.primary : AppTheme.textSecondary,
        fontWeight: FontWeight.w600)),
  ]);
}

class _DateTimeTile extends StatelessWidget {
  final String label; final DateTime dt; final VoidCallback onTap;
  const _DateTimeTile({required this.label, required this.dt, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const Spacer(),
        Text('${Fmt.date(dt)}, ${Fmt.time(dt)}',
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        const Icon(Icons.edit, size: 14, color: AppTheme.textSecondary),
      ]),
    ),
  );
}

class _PayRow extends StatelessWidget {
  final String id, label, selected;
  final ValueChanged<String> onTap;
  const _PayRow({required this.id, required this.label,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onTap(id),
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: selected == id ? AppTheme.primary.withOpacity(0.06) : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected == id ? AppTheme.primary : AppTheme.border,
              width: selected == id ? 1.5 : 1)),
      child: Row(children: [
        Text(label, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500,
            color: selected == id ? AppTheme.primary : null)),
        const Spacer(),
        if (selected == id)
          const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
      ]),
    ),
  );
}