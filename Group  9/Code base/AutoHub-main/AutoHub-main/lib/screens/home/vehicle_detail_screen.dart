import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/upi_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/review_widgets.dart';
import '../rental/rental_booking_sheet.dart';
import '../reviews/write_review_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;
  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  int _imgIdx = 0;
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<VehicleProvider>().incrementViews(widget.vehicle.id);
    context.read<ReviewProvider>().loadReviews(widget.vehicle.id);
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final reviews = context.watch<ReviewProvider>().getReviews(widget.vehicle.id);
    final isSaved = auth.isSaved(widget.vehicle.id);
    final v = widget.vehicle;

    // Rating breakdown
    final breakdown = <int, int>{};
    for (final r in reviews) {
      final s = r.rating.round();
      breakdown[s] = (breakdown[s] ?? 0) + 1;
    }

    return Scaffold(
      body: CustomScrollView(slivers: [
        // Image gallery sliver app bar
        SliverAppBar(
          expandedHeight: 280, pinned: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.black45, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.black45, shape: BoxShape.circle),
                child: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? Colors.red : Colors.white, size: 18,
                ),
              ),
              onPressed: () => auth.toggleSavedVehicle(v.id),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.black45, shape: BoxShape.circle),
                child: const Icon(Icons.share, color: Colors.white, size: 18),
              ),
              onPressed: () => Share.share(
                  'Check out ${v.title} on AutoHub!\n${v.priceLabel}'),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: [
              // Image carousel
              PageView.builder(
                itemCount: v.imageUrls.isNotEmpty ? v.imageUrls.length : 1,
                onPageChanged: (i) => setState(() => _imgIdx = i),
                itemBuilder: (_, i) => CachedNetworkImage(
                  imageUrl: v.imageUrls.isNotEmpty ? v.imageUrls[i] : '',
                  fit: BoxFit.cover, width: double.infinity,
                  placeholder: (_, __) => const ShimmerBox(
                      width: double.infinity, height: 280),
                  errorWidget: (_, __, ___) => Container(
                    color: AppTheme.border,
                    child: const Icon(Icons.directions_car, size: 80,
                        color: AppTheme.textSecondary),
                  ),
                ),
              ),
              // Image counter
              Positioned(bottom: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(
                      '${_imgIdx + 1}/${v.imageUrls.length.clamp(1, 99)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ]),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Title + price
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (v.isVerified)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.verified, size: 12, color: AppTheme.success),
                            SizedBox(width: 4),
                            Text('Verified Listing', style: TextStyle(
                                fontSize: 11, color: AppTheme.success,
                                fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      Text(v.title, style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(v.priceLabel, style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold,
                      color: AppTheme.primary)),
                  if (v.forRent)
                    Text('₹${v.rentPerHour.toInt()}/hr',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.warning,
                            fontWeight: FontWeight.w600)),
                ]),
              ]),
              const SizedBox(height: 8),

              // Rating + views
              Row(children: [
                RatingBarIndicator(
                  rating: v.averageRating, itemSize: 16,
                  itemBuilder: (_, __) => const Icon(
                      Icons.star_rounded, color: AppTheme.starColor),
                ),
                const SizedBox(width: 6),
                Text('${v.averageRating.toStringAsFixed(1)} (${v.totalRatings} reviews)',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const Spacer(),
                const Icon(Icons.remove_red_eye_outlined, size: 14,
                    color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text('${v.views} views', style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
              ]),
              const SizedBox(height: 16),

              // Specs grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12)),
                child: GridView.count(
                  crossAxisCount: 3, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2,
                  children: [
                    _SpecCell(Icons.calendar_today, '${v.year}', 'Year'),
                    _SpecCell(Icons.speed, '${v.mileageKmpl}', 'km/l'),
                    _SpecCell(Icons.local_gas_station, v.fuelType, 'Fuel'),
                    _SpecCell(Icons.settings, v.transmission, 'Gearbox'),
                    _SpecCell(Icons.people, '${v.seatingCapacity}', 'Seats'),
                    _SpecCell(Icons.engineering,
                        v.engineCC > 0 ? '${v.engineCC}cc' : 'EV', 'Engine'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Location + seller
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor)),
                child: Column(children: [
                  Row(children: [
                    const Icon(Icons.location_on, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(v.location, style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500))),
                  ]),
                  const Divider(height: 14),
                  Row(children: [
                    const Icon(Icons.store, size: 16, color: AppTheme.accent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(v.sellerName, style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600))),
                    Text(v.sellerPhone, style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),

              // Features
              if (v.features.isNotEmpty) ...[
                const Text('Features', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: v.features.map((f) =>
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(f, style: const TextStyle(
                          fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500)),
                    )).toList()),
                const SizedBox(height: 16),
              ],

              // Specs table
              if (v.specifications.isNotEmpty) ...[
                const Text('Specifications', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(children: v.specifications.entries.map((e) {
                    final isLast = e.key == v.specifications.keys.last;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          border: isLast ? null : const Border(
                              bottom: BorderSide(color: AppTheme.border))),
                      child: Row(children: [
                        Expanded(child: Text(e.key, style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary))),
                        Text(e.value, style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                    );
                  }).toList()),
                ),
                const SizedBox(height: 16),
              ],

              // Description
              const Text('Description', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AnimatedCrossFade(
                firstChild: Text(v.description,
                    maxLines: 4, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
                secondChild: Text(v.description,
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
                crossFadeState: _descExpanded
                    ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              GestureDetector(
                onTap: () => setState(() => _descExpanded = !_descExpanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_descExpanded ? 'Show less ↑' : 'Read more ↓',
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),

              // EMI Calculator
              _EmiCalc(price: v.price),
              const SizedBox(height: 24),

              // Reviews section
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Ratings & Reviews', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => WriteReviewScreen(
                          targetId: v.id, targetType: 'vehicle',
                          targetName: v.title))),
                  child: const Text('Write Review'),
                ),
              ]),
              const SizedBox(height: 10),
              RatingOverview(
                averageRating: v.averageRating,
                totalRatings: v.totalRatings,
                breakdown: breakdown,
              ),
              const SizedBox(height: 16),
              if (reviews.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No reviews yet. Be the first!',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ))
              else
                ...reviews.take(5).map((r) => ReviewCard(
                  review: r,
                  onHelpful: () => context.read<ReviewProvider>()
                      .markHelpful(r.id, v.id),
                )),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ]),

      // Bottom action bar
      bottomNavigationBar: _ActionBar(vehicle: v),
    );
  }
}

class _SpecCell extends StatelessWidget {
  final IconData icon; final String value, label;
  const _SpecCell(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 18, color: AppTheme.primary),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis),
      Text(label, style: const TextStyle(
          fontSize: 10, color: AppTheme.textSecondary)),
    ],
  );
}

// EMI Calculator widget
class _EmiCalc extends StatefulWidget {
  final double price;
  const _EmiCalc({required this.price});
  @override State<_EmiCalc> createState() => _EmiCalcState();
}

class _EmiCalcState extends State<_EmiCalc> {
  double _down    = 0;
  int    _months  = 60;

  double get _principal => widget.price - _down;
  double get _emi       => _principal > 0 ? Fmt.emi(_principal, _months) : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accent.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.calculate, size: 18, color: AppTheme.accent),
          SizedBox(width: 8),
          Text('EMI Calculator', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.accent)),
        ]),
        const SizedBox(height: 12),
        Text('Down Payment: ${Fmt.currency(_down)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Slider(
          value: _down, min: 0, max: widget.price * 0.5,
          activeColor: AppTheme.accent,
          onChanged: (v) => setState(() => _down = v),
        ),
        const SizedBox(height: 4),
        Text('Tenure: $_months months',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Slider(
          value: _months.toDouble(), min: 12, max: 84, divisions: 6,
          activeColor: AppTheme.accent,
          onChanged: (v) => setState(() => _months = v.toInt()),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Monthly EMI', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
            Text(Fmt.rupees(_emi), style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 4),
        Text('@ 9.5% per annum  •  Total: ${Fmt.rupees(_emi * _months)}',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ]),
    );
  }
}

// Bottom action bar
class _ActionBar extends StatelessWidget {
  final Vehicle vehicle;
  const _ActionBar({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20,
          MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: const Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(children: [
        if (vehicle.forRent)
          Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlineBtn(
              label: '🕐  Rent',
              color: AppTheme.warning,
              onTap: () => showModalBottomSheet(
                context: context, isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => RentalBookingSheet(vehicle: vehicle),
              ),
            ),
          )),
        if (vehicle.forSale)
          Expanded(child: PrimaryBtn(
            label: vehicle.forRent ? 'Buy / Test Drive' : '🛒  Buy Now',
            onTap: () => _showBuySheet(context),
          )),
      ]),
    );
  }

  void _showBuySheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PurchasePaymentSheet(vehicle: vehicle),
    );
  }
}

// ─── Purchase Payment Gateway ──────────────────────────────────────────────
class _PurchasePaymentSheet extends StatefulWidget {
  final Vehicle vehicle;
  const _PurchasePaymentSheet({required this.vehicle});
  @override State<_PurchasePaymentSheet> createState() => _PurchasePaymentSheetState();
}

class _PurchasePaymentSheetState extends State<_PurchasePaymentSheet> {
  // Steps: 0=choose action, 1=customer details, 2=payment gateway
  int _step = 0;
  bool _isBuyNow = true;    // true=buy, false=test drive

  // Customer details
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dateCtrl   = TextEditingController();
  String _selectedTime = '';
  bool _isLoading = false;

  // Payment
  String _payMethod = 'upi';
  final _upiCtrl    = TextEditingController();
  final _cardNoCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _cardExpCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  static const _slots = [
    '10:00 AM','11:30 AM','12:00 PM',
    '02:00 PM','03:30 PM','04:00 PM','05:00 PM',
  ];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl, _addressCtrl,
      _dateCtrl, _upiCtrl, _cardNoCtrl, _cardNameCtrl, _cardExpCtrl, _cardCvvCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // For testing: charge ₹1 or ₹2 via payment gateway, show real price via EMI
  double get _tokenAmount => widget.vehicle.testPaymentPrice;

  Future<void> _submitPurchase() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) { showError(context, 'Please login first'); return; }
    if (_payMethod == 'upi' && _upiCtrl.text.isEmpty) {
      showError(context, 'Enter your UPI ID'); return;
    }
    if (_payMethod == 'card' && (_cardNoCtrl.text.length < 16 || _cardCvvCtrl.text.isEmpty)) {
      showError(context, 'Enter valid card details'); return;
    }

    setState(() => _isLoading = true);

    // Submit to request provider
    await context.read<RequestProvider>().addPurchase(
      userId: auth.user!.uid,
      userContact: auth.user!.phone ?? auth.user!.email ?? '',
      userName: auth.user!.displayName,
      vehicleId: widget.vehicle.id,
      vehicleTitle: widget.vehicle.title,
      vehiclePrice: widget.vehicle.price,
      dealerName: widget.vehicle.sellerName,
      dealerAddress: widget.vehicle.location,
      customerName: _nameCtrl.text,
      customerPhone: _phoneCtrl.text,
    );

    // Launch UPI + save transaction to Firestore
    if (_payMethod == 'upi') {
      final txnRef = UpiService.generateRef();
      await UpiService.launch(
        amount:    _tokenAmount,
        note:      'Token: ${widget.vehicle.title}',
        txnRef:    txnRef,
        type:      'purchase',
        itemTitle: widget.vehicle.title,
        userId:    auth.user!.uid,
        userName:  auth.user!.displayName,
        upiId:     _upiCtrl.text,
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      showSuccess(context,
          '🎉 Purchase request submitted! Token ₹${_tokenAmount.toInt()} paid. '
              'Admin will contact you within 24 hrs.');
    }
  }

  Future<void> _submitTestDrive() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) { showError(context, 'Please login first'); return; }
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty ||
        _dateCtrl.text.isEmpty || _selectedTime.isEmpty) {
      showError(context, 'Please fill all required fields'); return;
    }

    await context.read<RequestProvider>().addTestDrive(
      userId: auth.user!.uid,
      userContact: auth.user!.phone ?? auth.user!.email ?? '',
      userName: auth.user!.displayName,
      vehicleId: widget.vehicle.id,
      vehicleTitle: widget.vehicle.title,
      vehiclePrice: widget.vehicle.price,
      date: _dateCtrl.text, time: _selectedTime,
      dealerName: widget.vehicle.sellerName,
      dealerAddress: widget.vehicle.location,
      customerName: _nameCtrl.text,
      customerPhone: _phoneCtrl.text,
    );

    if (mounted) {
      Navigator.pop(context);
      showSuccess(context, '✅ Test drive booked for ${_dateCtrl.text} at $_selectedTime. Admin will confirm.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    return DraggableScrollableSheet(
      initialChildSize: _step == 2 ? 0.92 : 0.75, maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          const SheetHandle(),

          // Step indicator
          if (_step > 0) _StepIndicator(current: _step, total: _isBuyNow ? 2 : 1),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(children: [
              if (_step > 0)
                GestureDetector(
                  onTap: () => setState(() => _step--),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  _step == 0 ? v.title
                      : _step == 1 ? (_isBuyNow ? '👤 Your Details' : '🚗 Test Drive Details')
                      : '💳 Payment Gateway',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_step == 0) Text(v.priceLabel, style: const TextStyle(
                    fontSize: 18, color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ])),
            ]),
          ),
          const SizedBox(height: 12),

          Expanded(child: ListView(controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [

                // ── STEP 0: Choose action ────────────────────────────────────
                if (_step == 0) ...[
                  _ActionTile(
                    icon: Icons.shopping_bag_outlined, color: AppTheme.accent,
                    title: 'Buy Now',
                    subtitle: 'Pay ₹${_tokenAmount.toInt()} token online — rest on delivery',
                    selected: _isBuyNow,
                    onTap: () {
                      setState(() { _isBuyNow = true; _step = 1; });
                    },
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.drive_eta_outlined, color: AppTheme.primary,
                    title: 'Book Test Drive',
                    subtitle: 'Schedule a free test drive at dealer',
                    selected: !_isBuyNow,
                    onTap: () {
                      setState(() { _isBuyNow = false; _step = 1; });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Price breakdown box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accent.withOpacity(0.2))),
                    child: Column(children: [
                      _PriceRow('Vehicle Price', v.priceLabel),
                      const Divider(height: 12),
                      _PriceRow('Test Payment Amount', '₹${_tokenAmount.toInt()}',
                          color: AppTheme.success),
                      _PriceRow('(Real price shown above for EMI reference)', '',
                          color: AppTheme.textSecondary),
                    ]),
                  ),
                ],

                // ── STEP 1: Details form ─────────────────────────────────────
                if (_step == 1) ...[
                  AppField(label: 'Full Name *', hint: 'As per ID',
                      controller: _nameCtrl),
                  AppField(label: 'Mobile Number *', hint: '+91 XXXXXXXXXX',
                      controller: _phoneCtrl, keyboard: TextInputType.phone),
                  AppField(label: 'Email', hint: 'optional',
                      controller: _emailCtrl, keyboard: TextInputType.emailAddress),

                  if (_isBuyNow) ...[
                    AppField(label: 'Address *', hint: 'Delivery/contact address',
                        controller: _addressCtrl),
                    const SizedBox(height: 16),
                    // Summary
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
                      child: Column(children: [
                        _PriceRow('Vehicle', v.title),
                        _PriceRow('Total to Pay', '₹${_tokenAmount.toInt()}',
                            color: AppTheme.primary),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    PrimaryBtn(
                      label: 'Continue to Payment →',
                      onTap: () {
                        if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
                          showError(context, 'Please fill all required fields');
                          return;
                        }
                        setState(() => _step = 2);
                      },
                    ),
                  ] else ...[
                    AppField(label: 'Preferred Date *', hint: 'DD/MM/YYYY',
                        controller: _dateCtrl),
                    const SizedBox(height: 8),
                    const Text('Preferred Time *', style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: _slots.map((t) {
                      final sel = _selectedTime == t;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTime = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: sel ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: sel ? AppTheme.primary : AppTheme.border)),
                          child: Text(t, style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: sel ? AppTheme.primary : AppTheme.textSecondary)),
                        ),
                      );
                    }).toList()),
                    const SizedBox(height: 16),
                    const AdminConfirmBanner(),
                    const SizedBox(height: 12),
                    PrimaryBtn(
                      label: 'Confirm Test Drive',
                      onTap: _submitTestDrive,
                    ),
                  ],
                ],

                // ── STEP 2: Payment Gateway ──────────────────────────────────
                if (_step == 2) ...[
                  // Amount due
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, Color(0xFFB71C1C)],
                        ),
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      const Icon(Icons.lock, color: Colors.white70, size: 20),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Secure Token Payment',
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text('₹${_tokenAmount.toInt()}',
                            style: const TextStyle(color: Colors.white,
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        Text(v.title, style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                      ]),
                      const Spacer(),
                      const Icon(Icons.security, color: Colors.white54, size: 32),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Payment method tabs
                  const Text('Select Payment Method',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _PayMethodBtn('UPI', Icons.account_balance_wallet_outlined,
                        _payMethod == 'upi', () => setState(() => _payMethod = 'upi')),
                    const SizedBox(width: 10),
                    _PayMethodBtn('Card', Icons.credit_card,
                        _payMethod == 'card', () => setState(() => _payMethod = 'card')),
                    const SizedBox(width: 10),
                    _PayMethodBtn('Net Banking', Icons.account_balance_outlined,
                        _payMethod == 'netbanking', () => setState(() => _payMethod = 'netbanking')),
                  ]),
                  const SizedBox(height: 16),

                  // UPI section
                  if (_payMethod == 'upi') ...[
                    AppField(label: 'UPI ID *', hint: 'yourname@upi',
                        controller: _upiCtrl),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.withOpacity(0.2))),
                      child: const Row(children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(child: Text(
                          'Your UPI app will open to confirm payment. '
                              'Money will be credited to AutoHub.',
                          style: TextStyle(fontSize: 11, color: Colors.blue),
                        )),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    // Popular UPI apps
                    const Text('Or pay with:', style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 10, children: ['GPay', 'PhonePe', 'Paytm', 'BHIM'].map((app) =>
                        GestureDetector(
                          onTap: () {
                            _upiCtrl.text = 'autohub@okhdfcbank';
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Text(app, style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ).toList()),
                  ],

                  // Card section
                  if (_payMethod == 'card') ...[
                    AppField(label: 'Card Number *', hint: '1234 5678 9012 3456',
                        controller: _cardNoCtrl, keyboard: TextInputType.number),
                    AppField(label: 'Cardholder Name *', hint: 'As on card',
                        controller: _cardNameCtrl),
                    Row(children: [
                      Expanded(child: AppField(label: 'Expiry MM/YY *', hint: '01/28',
                          controller: _cardExpCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: AppField(label: 'CVV *', hint: '***',
                          controller: _cardCvvCtrl, keyboard: TextInputType.number,
                          obscure: true)),
                    ]),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.withOpacity(0.2))),
                      child: const Row(children: [
                        Icon(Icons.shield_outlined, size: 14, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(child: Text(
                          '256-bit SSL encrypted. Your card info is safe & never stored.',
                          style: TextStyle(fontSize: 11, color: Colors.green),
                        )),
                      ]),
                    ),
                  ],

                  // Net banking
                  if (_payMethod == 'netbanking') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(children: [
                        for (final bank in ['SBI', 'HDFC Bank', 'ICICI Bank', 'Axis Bank', 'Kotak Bank'])
                          ListTile(
                            dense: true, contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.account_balance, size: 20),
                            title: Text(bank, style: const TextStyle(fontSize: 13)),
                            trailing: const Icon(Icons.chevron_right, size: 18),
                            onTap: () { /* would open bank netbanking */ },
                          ),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 20),
                  // Secure payment note
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.lock_outline, size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    const Text('100% Secure Payment • AutoHub Verified',
                        style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  ]),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryBtn(
                    label: '🔒  Pay ₹${_tokenAmount.toInt()} Now',
                    onTap: _submitPurchase,
                  ),
                  const SizedBox(height: 8),
                  const Center(child: Text(
                    'After payment, admin will verify and confirm your purchase within 24 hours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  )),
                ],

              ])),
        ]),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final Color color;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.color,
    required this.title, required this.subtitle,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? color : AppTheme.border,
              width: selected ? 1.5 : 1)),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15)),
          Text(subtitle, style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary)),
        ])),
        Icon(Icons.arrow_forward_ios, color: color, size: 14),
      ]),
    ),
  );
}

// ─── Payment helper widgets ────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current, total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
    child: Row(children: [
      for (int i = 1; i <= total; i++) ...[
        Expanded(child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 4,
          decoration: BoxDecoration(
            color: i <= current ? AppTheme.primary : AppTheme.border,
            borderRadius: BorderRadius.circular(2),
          ),
        )),
        if (i < total) const SizedBox(width: 6),
      ],
    ]),
  );
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _PriceRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      Text(value, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.bold,
          color: color ?? AppTheme.textPrimary)),
    ]),
  );
}

class _PayMethodBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _PayMethodBtn(this.label, this.icon, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.08) : Colors.white,
          border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.border,
              width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: selected ? AppTheme.primary : AppTheme.textSecondary),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: selected ? AppTheme.primary : AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    ),
  );
}