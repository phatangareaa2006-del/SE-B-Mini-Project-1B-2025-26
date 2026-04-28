import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/service_provider.dart';
import '../../services/upi_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/review_widgets.dart';
import '../../providers/review_provider.dart';
import '../reviews/write_review_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _cat = 'all';
  static const _cats = [
    (id: 'all', label: 'All'),
    (id: 'servicing', label: '🔧 Servicing'),
    (id: 'cleaning', label: '🧹 Cleaning'),
    (id: 'repair', label: '🛠️ Repair'),
    (id: 'customization', label: '🎨 Custom'),
  ];

  @override
  Widget build(BuildContext context) {
    final sp  = context.watch<ServiceProvider>();
    final svcs = sp.servicing(_cat);

    return Scaffold(
      body: SafeArea(child: Column(children: [
        const SectionHeader(title: 'Services',
            subtitle: 'Book professional vehicle services'),
        SizedBox(height: 44, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = _cats[i]; final sel = _cat == c.id;
            return GestureDetector(
              onTap: () => setState(() => _cat = c.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primary : AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? AppTheme.primary : AppTheme.border),
                ),
                child: Text(c.label, style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppTheme.textPrimary)),
              ),
            );
          },
        )),
        const SizedBox(height: 8),
        Expanded(child: sp.loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : svcs.isEmpty
            ? const EmptyState(icon: Icons.build_outlined,
            title: 'No services', subtitle: 'Check back soon')
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemCount: svcs.length,
          itemBuilder: (_, i) => _ServiceCard(service: svcs[i]),
        )),
      ])),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context, isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ServiceDetailSheet(service: service),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            child: CachedNetworkImage(
              imageUrl: service.imageUrls.isNotEmpty ? service.imageUrls.first : '',
              width: 100, height: 100, fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                  width: 100, height: 100, color: AppTheme.border,
                  child: const Icon(Icons.car_repair, color: AppTheme.textSecondary)),
            ),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(service.title, style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(service.description, maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('₹${service.price.toInt()}',
                    style: const TextStyle(color: AppTheme.primary,
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Row(children: [
                  const Icon(Icons.schedule, size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 3),
                  Text(service.durationLabel,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ]),
              ]),
              const SizedBox(height: 4),
              RatingBarIndicator(rating: service.averageRating, itemSize: 12,
                  itemBuilder: (_, __) => const Icon(Icons.star_rounded,
                      color: AppTheme.starColor)),
              Text('${service.averageRating.toStringAsFixed(1)} '
                  '(${service.totalRatings})',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ]),
          )),
        ]),
      ),
    );
  }
}

// Service detail & booking sheet
class _ServiceDetailSheet extends StatefulWidget {
  final ServiceItem service;
  const _ServiceDetailSheet({required this.service});
  @override State<_ServiceDetailSheet> createState() => _ServiceDetailSheetState();
}

class _ServiceDetailSheetState extends State<_ServiceDetailSheet> {
  final _dateCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl    = TextEditingController();
  String _selectedTime = '', _payMethod = 'upi';
  final _upiCtrl = TextEditingController();
  bool _showBooking = false;

  @override
  void initState() {
    super.initState();
    context.read<ReviewProvider>().loadReviews(widget.service.id);
  }

  @override
  void dispose() {
    _dateCtrl.dispose(); _locationCtrl.dispose();
    _notesCtrl.dispose(); _upiCtrl.dispose();
    UpiService.dispose(); // ✅ FIX: prevent memory leaks
    super.dispose();
  }

  int _slotsLeft(String time) {
    final booked = context.read<RequestProvider>()
        .slotCount(widget.service.id, _dateCtrl.text, time);
    return (widget.service.slotCapacity - booked).clamp(0, widget.service.slotCapacity);
  }

  Future<void> _submit() async {
    if (_dateCtrl.text.isEmpty || _selectedTime.isEmpty || _locationCtrl.text.isEmpty) {
      showError(context, 'Fill all required fields'); return;
    }
    if (_slotsLeft(_selectedTime) <= 0) {
      showError(context, 'Slot full — choose another time'); return;
    }
    final auth = context.read<AuthProvider>();
    if (auth.user == null) { showError(context, 'Please login'); return; }

    await context.read<RequestProvider>().addServiceBooking(
      userId: auth.user!.uid,
      userContact: auth.user!.phone ?? auth.user!.email ?? '',
      userName: auth.user!.displayName,
      serviceId: widget.service.id, serviceName: widget.service.title,
      servicePrice: widget.service.price,
      date: _dateCtrl.text, time: _selectedTime,
      location: _locationCtrl.text, notes: _notesCtrl.text,
      paymentMethod: _payMethod,
      upiId: _payMethod == 'upi' ? _upiCtrl.text : null,
    );

    // ✅ FIX: Launch Razorpay with proper success/failure callbacks
    if (_payMethod == 'upi') {
      final txnRef = UpiService.generateRef();
      await UpiService.launch(
        amount:    widget.service.price,
        note:      '${widget.service.title} booking',
        txnRef:    txnRef,
        type:      'service',
        itemTitle: widget.service.title,
        userId:    auth.user!.uid,
        userName:  auth.user!.displayName,
        upiId:     _upiCtrl.text,
        contact:   auth.user?.phone ?? '9999999999',
        email:     auth.user?.email ?? 'customer@autohub.com',
        onSuccess: (res) {
          debugPrint('✅ Payment success: ${res.paymentId}');
          if (mounted) {
            Navigator.pop(context);
            showSuccess(context, '✅ Service booked & payment successful! '
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

    // For COD — close directly
    if (mounted) {
      Navigator.pop(context);
      showSuccess(context, '✅ Service booked! Admin will confirm shortly.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc     = widget.service;
    final reviews = context.watch<ReviewProvider>().getReviews(svc.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.92, maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          const SheetHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: Text(svc.title, style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold))),
              IconButton(icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Expanded(child: ListView(controller: ctrl,
              padding: const EdgeInsets.all(20), children: [
                // Image
                if (svc.imageUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                        imageUrl: svc.imageUrls.first, height: 180,
                        width: double.infinity, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 16),

                // Price + duration
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('₹${svc.price.toInt()}', style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 24)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(svc.durationLabel, style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 12),

                // Description
                Text(svc.description, style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
                const SizedBox(height: 16),

                // Includes
                _ListSection('✅ What\'s Included', svc.includes, AppTheme.success),
                _ListSection('❌ What\'s NOT Included', svc.excludes, AppTheme.error),
                _ListSection('📋 What to Bring', svc.requirements, AppTheme.warning),
                const SizedBox(height: 8),

                // Ratings
                RatingOverview(averageRating: svc.averageRating,
                    totalRatings: svc.totalRatings, breakdown: {}),
                const SizedBox(height: 8),
                ...reviews.take(3).map((r) => ReviewCard(review: r)),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => WriteReviewScreen(
                          targetId: svc.id, targetType: 'service',
                          targetName: svc.title))),
                  child: const Text('Write a Review'),
                ),
                const Divider(height: 24),

                // Booking form toggle
                GestureDetector(
                  onTap: () => setState(() => _showBooking = !_showBooking),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: _showBooking ? AppTheme.primary : AppTheme.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.calendar_month,
                          color: _showBooking ? Colors.white : AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(_showBooking ? 'Hide Booking Form' : 'Book This Service',
                          style: TextStyle(
                              color: _showBooking ? Colors.white : AppTheme.primary,
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ]),
                  ),
                ),

                if (_showBooking) ...[
                  const SizedBox(height: 16),
                  AppField(label: '🗓️ Date *', hint: 'DD/MM/YYYY', controller: _dateCtrl),
                  const Text('⏰ Time Slot *', style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8,
                      children: svc.timeSlots.map((t) {
                        final left   = _slotsLeft(t);
                        final isFull = left <= 0;
                        final sel    = _selectedTime == t;
                        return GestureDetector(
                          onTap: isFull ? null : () => setState(() => _selectedTime = t),
                          child: Opacity(opacity: isFull ? 0.5 : 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                  color: isFull ? AppTheme.error.withOpacity(0.06)
                                      : sel ? AppTheme.primary.withOpacity(0.12) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: isFull ? AppTheme.error.withOpacity(0.3)
                                          : sel ? AppTheme.primary : AppTheme.border)),
                              child: Column(children: [
                                Text(t, style: TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isFull ? AppTheme.error
                                        : sel ? AppTheme.primary : AppTheme.textPrimary)),
                                Text(isFull ? '🔴 Full' : '🟢 $left left',
                                    style: TextStyle(fontSize: 10,
                                        color: isFull ? AppTheme.error : AppTheme.success)),
                              ]),
                            ),
                          ),
                        );
                      }).toList()),
                  const SizedBox(height: 14),
                  AppField(label: '📍 Your Location *', hint: 'Enter address',
                      controller: _locationCtrl, maxLines: 2),
                  AppField(label: '📝 Special Instructions',
                      hint: 'Any notes...', controller: _notesCtrl, maxLines: 3),
                  const Text('Payment', style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  for (final m in [
                    (id: 'upi', label: '📱 UPI (GPay / PhonePe / Paytm)'),
                    (id: 'card', label: '💳 Credit / Debit Card'),
                    (id: 'cod', label: '💵 Cash on Delivery'),
                  ])
                    GestureDetector(
                      onTap: () => setState(() => _payMethod = m.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            color: _payMethod == m.id
                                ? AppTheme.primary.withOpacity(0.06) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _payMethod == m.id ? AppTheme.primary : AppTheme.border)),
                        child: Row(children: [
                          Text(m.label, style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _payMethod == m.id ? AppTheme.primary : null)),
                          const Spacer(),
                          if (_payMethod == m.id)
                            const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                        ]),
                      ),
                    ),
                  if (_payMethod == 'upi')
                    AppField(label: 'Your UPI ID', hint: 'yourname@upi',
                        controller: _upiCtrl),
                  // ✅ FIX: Card option now shows info — Razorpay handles card input natively
                  if (_payMethod == 'card')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text(
                          '💳 Card details will be entered securely in the Razorpay checkout.',
                          style: TextStyle(fontSize: 13, color: AppTheme.primary)),
                    ),
                  if (_payMethod == 'cod')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('💵 Pay ₹${svc.price.toInt()} at the time of service.',
                          style: const TextStyle(color: AppTheme.warning, fontSize: 13)),
                    ),
                  const SizedBox(height: 12),
                  const AdminConfirmBanner(),
                  PrimaryBtn(label: 'Confirm Booking — ₹${svc.price.toInt()}',
                      onTap: _submit),
                ],
                const SizedBox(height: 20),
              ])),
        ]),
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  const _ListSection(this.title, this.items, this.color);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            Icon(Icons.circle, size: 6, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(item, style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary))),
          ]),
        )),
      ]),
    );
  }
}