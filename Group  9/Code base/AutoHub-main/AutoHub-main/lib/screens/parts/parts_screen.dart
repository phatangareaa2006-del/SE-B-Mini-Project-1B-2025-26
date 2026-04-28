import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../models/spare_part_model.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/parts_provider.dart';
import '../../providers/request_provider.dart';
import '../../services/upi_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/review_widgets.dart';
import '../../providers/review_provider.dart';
import '../reviews/write_review_screen.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});
  @override State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  String _cat = 'all';
  String _search = '';
  final _searchCtrl = TextEditingController();

  static const _cats = [
    (id: 'all', label: 'All'),
    (id: 'engine', label: '⚙️ Engine'),
    (id: 'brakes', label: '🛑 Brakes'),
    (id: 'electrical', label: '⚡ Electrical'),
    (id: 'tires', label: '🔵 Tires'),
    (id: 'body', label: '🔩 Body'),
  ];

  List<SparePart> _filter(List<SparePart> parts) {
    var out = _cat == 'all' ? parts.toList()
        : parts.where((p) => p.category == _cat).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      out = out.where((p) =>
      p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q)).toList();
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final pp      = context.watch<PartsProvider>();
    final cart    = context.watch<CartProvider>();
    final filtered = _filter(pp.parts);

    return Scaffold(
      body: SafeArea(child: Stack(children: [
        Column(children: [
          const SectionHeader(title: 'Spare Parts',
              subtitle: 'Genuine parts for your vehicle'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search parts, brands...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.primary : AppTheme.border),
                  ),
                  child: Text(c.label, style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppTheme.textPrimary)),
                ),
              );
            },
          )),
          const SizedBox(height: 8),
          Expanded(child: pp.loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : filtered.isEmpty
              ? const EmptyState(icon: Icons.settings_outlined,
              title: 'No parts found', subtitle: 'Try different search')
              : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _PartCard(part: filtered[i]))),
        ]),

        // Floating cart button
        if (cart.count > 0)
          Positioned(bottom: 20, right: 20,
            child: GestureDetector(
              onTap: () => _showCart(context),
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                    color: AppTheme.primary, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 12, offset: const Offset(0, 4))]),
                child: Stack(alignment: Alignment.center, children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  Positioned(top: 6, right: 6, child: Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Center(child: Text('${cart.count}',
                        style: const TextStyle(
                            color: AppTheme.primary, fontSize: 10,
                            fontWeight: FontWeight.bold))),
                  )),
                ]),
              ),
            ),
          ),
      ])),
    );
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CartSheet(),
    );
  }
}

class _PartCard extends StatelessWidget {
  final SparePart part;
  const _PartCard({required this.part});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context, isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _PartDetailSheet(part: part),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor)),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: part.imageUrls.isNotEmpty ? part.imageUrls.first : '',
              width: 90, height: 90, fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                  width: 90, height: 90, color: AppTheme.border,
                  child: const Icon(Icons.settings, color: AppTheme.textSecondary)),
            ),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(part.name, style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${part.brand}  •  ${part.partNumber}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              Row(children: [
                if (part.discountPercent > 0) ...[
                  Text('₹${part.price.toInt()}', style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(width: 4),
                ],
                Text('₹${part.discountedPrice.toInt()}', style: const TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                if (part.discountPercent > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('${part.discountPercent.toInt()}% OFF',
                        style: const TextStyle(
                            color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Row(children: [
                RatingBarIndicator(rating: part.averageRating, itemSize: 12,
                    itemBuilder: (_, __) => const Icon(Icons.star_rounded,
                        color: AppTheme.starColor)),
                const SizedBox(width: 4),
                Expanded(child: Text('(${part.totalRatings})',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: (part.inStock ? AppTheme.success : AppTheme.error)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(part.stockLabel, style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: part.inStock ? AppTheme.success : AppTheme.error)),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (!part.inStock) return;
                    context.read<CartProvider>().addItem(CartItem(
                      id: part.id, name: part.name, brand: part.brand,
                      imageUrl: part.imageUrls.isNotEmpty ? part.imageUrls.first : '',
                      compatibility: part.compatibility.isNotEmpty
                          ? part.compatibility.first : '',
                      price: part.discountedPrice, quantity: 1, stock: part.stock,
                    ));
                    showSuccess(context, '${part.name} added to cart');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: part.inStock ? AppTheme.primary : AppTheme.border,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text('Add', style: TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }
}

// Part detail sheet
class _PartDetailSheet extends StatefulWidget {
  final SparePart part;
  const _PartDetailSheet({required this.part});
  @override State<_PartDetailSheet> createState() => _PartDetailSheetState();
}

class _PartDetailSheetState extends State<_PartDetailSheet> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewProvider>().loadReviews(widget.part.id);
  }

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<ReviewProvider>().getReviews(widget.part.id);
    final p = widget.part;

    return DraggableScrollableSheet(
      initialChildSize: 0.9, maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          const SheetHandle(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: Text(p.name, style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold))),
              IconButton(icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Expanded(child: ListView(controller: ctrl,
              padding: const EdgeInsets.all(20), children: [
                if (p.imageUrls.isNotEmpty)
                  ClipRRect(borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(imageUrl: p.imageUrls.first,
                          height: 200, width: double.infinity, fit: BoxFit.cover)),
                const SizedBox(height: 16),
                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('₹${p.discountedPrice.toInt()}', style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 22)),
                    if (p.discountPercent > 0)
                      Text('MRP ₹${p.price.toInt()}', style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12, color: AppTheme.textSecondary)),
                  ]),
                  const Spacer(),
                  Text(p.stockLabel, style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: p.inStock ? AppTheme.success : AppTheme.error)),
                ]),
                const SizedBox(height: 10),
                Text(p.description, style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
                const SizedBox(height: 14),

                // Specs
                if (p.specifications.isNotEmpty) ...[
                  const Text('Specifications', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: p.specifications.entries.map((e) {
                      final isLast = e.key == p.specifications.keys.last;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(border: isLast ? null
                            : const Border(bottom: BorderSide(color: AppTheme.border))),
                        child: Row(children: [
                          Expanded(child: Text(e.key, style: const TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary))),
                          Text(e.value, style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                        ]),
                      );
                    }).toList()),
                  ),
                  const SizedBox(height: 14),
                ],

                // Compatibility
                if (p.compatibility.isNotEmpty) ...[
                  const Text('Compatible With', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 6,
                      children: p.compatibility.map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(c, style: const TextStyle(
                            fontSize: 12, color: AppTheme.accent)),
                      )).toList()),
                  const SizedBox(height: 14),
                ],

                // Warranty + return
                Row(children: [
                  Expanded(child: _InfoBox(
                      Icons.shield, 'Warranty', p.warranty, AppTheme.success)),
                  const SizedBox(width: 10),
                  Expanded(child: _InfoBox(
                      Icons.assignment_return, 'Returns', p.returnPolicy, AppTheme.warning)),
                ]),
                const SizedBox(height: 14),

                // Reviews
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Ratings & Reviews', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => WriteReviewScreen(
                            targetId: p.id, targetType: 'part', targetName: p.name))),
                    child: const Text('Write Review'),
                  ),
                ]),
                ...reviews.take(3).map((r) => ReviewCard(review: r)),

                const SizedBox(height: 16),
                PrimaryBtn(
                  label: p.inStock ? 'Add to Cart — ₹${p.discountedPrice.toInt()}' : 'Out of Stock',
                  onTap: p.inStock ? () {
                    context.read<CartProvider>().addItem(CartItem(
                      id: p.id, name: p.name, brand: p.brand,
                      imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                      compatibility: p.compatibility.isNotEmpty ? p.compatibility.first : '',
                      price: p.discountedPrice, quantity: 1, stock: p.stock,
                    ));
                    Navigator.pop(context);
                    showSuccess(context, '${p.name} added to cart!');
                  } : null,
                ),
              ])),
        ]),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _InfoBox(this.icon, this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.bold, color: color)),
      ]),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 12)),
    ]),
  );
}

// Cart sheet
class _CartSheet extends StatelessWidget {
  const _CartSheet();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return DraggableScrollableSheet(
      initialChildSize: 0.7, maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          const SheetHandle(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text('🛒 Cart (${cart.count})', style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (!cart.isEmpty)
                TextButton(onPressed: cart.clear,
                    child: const Text('Clear all', style: TextStyle(color: AppTheme.error))),
              IconButton(icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Expanded(child: cart.isEmpty
              ? const EmptyState(icon: Icons.shopping_cart_outlined,
              title: 'Cart is empty', subtitle: 'Add some parts to get started')
              : ListView(controller: ctrl, padding: const EdgeInsets.all(20),
              children: cart.items.map((item) => _CartItem(item: item)).toList())),
          if (!cart.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.border))),
              child: Column(children: [
                InfoRow(label: 'Subtotal (${cart.count} items)',
                    value: '₹${cart.subtotal.toInt()}'),
                InfoRow(label: 'Delivery',
                    value: cart.deliveryCharge == 0 ? 'FREE ✨' : '₹${cart.deliveryCharge.toInt()}',
                    valueColor: cart.deliveryCharge == 0 ? AppTheme.success : null),
                if (cart.deliveryCharge == 0)
                  const Text('🎉 Free delivery on orders above ₹10',
                      style: TextStyle(fontSize: 11, color: AppTheme.success)),
                const Divider(height: 16),
                InfoRow(label: 'Grand Total', value: '₹${cart.grandTotal.toInt()}',
                    valueColor: AppTheme.primary),
                const SizedBox(height: 12),
                PrimaryBtn(
                  label: 'Proceed to Checkout',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                        context: context, isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const _CheckoutSheet());
                  },
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartItem item;
  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text('₹${item.price.toInt()} each',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ])),
        Row(children: [
          _QtyBtn(Icons.remove, () => cart.updateQty(item.id, item.quantity - 1)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${item.quantity}', style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16))),
          _QtyBtn(Icons.add, () => cart.updateQty(item.id, item.quantity + 1)),
          const SizedBox(width: 12),
          Text('₹${item.totalPrice.toInt()}', style: const TextStyle(
              color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
      ]),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _QtyBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 14, color: AppTheme.textSecondary),
    ),
  );
}

// Checkout sheet
class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet();
  @override State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _addrCtrl   = TextEditingController();
  final _cityCtrl   = TextEditingController();
  final _pinCtrl    = TextEditingController();
  final _cardCtrl   = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _cardExpCtrl  = TextEditingController();
  final _cardCvvCtrl  = TextEditingController();
  final _upiCtrl    = TextEditingController();
  String _payMethod = 'upi';

  @override
  void dispose() {
    _addrCtrl.dispose(); _cityCtrl.dispose(); _pinCtrl.dispose();
    _cardCtrl.dispose(); _cardNameCtrl.dispose();
    _cardExpCtrl.dispose(); _cardCvvCtrl.dispose(); _upiCtrl.dispose();
    UpiService.dispose(); // ✅ FIX: prevent memory leaks
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    if (_addrCtrl.text.isEmpty || _cityCtrl.text.isEmpty || _pinCtrl.text.isEmpty) {
      showError(context, 'Enter complete delivery address'); return;
    }
    if (_payMethod == 'upi' && _upiCtrl.text.isEmpty) {
      showError(context, 'Enter UPI ID'); return;
    }
    final auth = context.read<AuthProvider>();
    if (auth.user == null) { showError(context, 'Please login'); return; }

    final req = await context.read<RequestProvider>().addPartsOrder(
      userId: auth.user!.uid,
      userContact: auth.user!.phone ?? auth.user!.email ?? '',
      userName: auth.user!.displayName,
      items: cart.items.toList(),
      subtotal: cart.subtotal,
      deliveryCharge: cart.deliveryCharge,
      total: cart.grandTotal,
      deliveryAddress: '${_addrCtrl.text}, ${_cityCtrl.text} - ${_pinCtrl.text}',
      paymentMethod: _payMethod,
      upiId: _payMethod == 'upi' ? _upiCtrl.text : null,
      cardLast4: _payMethod == 'card' && _cardCtrl.text.length >= 4
          ? _cardCtrl.text.substring(_cardCtrl.text.length - 4) : null,
    );

    // ✅ FIX: Launch Razorpay with proper success/failure callbacks
    if (_payMethod == 'upi') {
      final txnRef = UpiService.generateRef();
      await UpiService.launch(
        amount:    cart.grandTotal,
        note:      'AutoHub Parts Order \${req.orderId}',
        txnRef:    txnRef,
        type:      'parts',
        itemTitle: 'Parts Order \${req.orderId} (\${cart.items.length} items)',
        userId:    auth.user!.uid,
        userName:  auth.user!.displayName,
        upiId:     _upiCtrl.text,
        contact:   auth.user?.phone ?? '9999999999',
        email:     auth.user?.email ?? 'customer@autohub.com',
        onSuccess: (res) {
          debugPrint('✅ Payment success: \${res.paymentId}');
          cart.clear();
          if (mounted) {
            Navigator.pop(context);
            showSuccess(context,
                '🎉 Order placed & payment successful! ID: \${req.orderId}. '
                    'Admin will confirm within 24hrs.');
          }
        },
        onFailure: (res) {
          debugPrint('❌ Payment failed: \${res.message}');
          if (mounted) {
            final errMsg = res.message ?? 'Please try again';
            showError(context, '❌ Payment failed: $errMsg');
          }
        },
      );
      // Don't pop here — let onSuccess handle it
      return;
    }

    // For COD / card — close directly
    cart.clear();
    if (mounted) {
      Navigator.pop(context);
      showSuccess(context,
          '🎉 Order placed! ID: \${req.orderId}. Admin will confirm within 24hrs.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return DraggableScrollableSheet(
      initialChildSize: 0.92, maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          const SheetHandle(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              const Text('💳 Checkout', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Expanded(child: ListView(controller: ctrl,
              padding: const EdgeInsets.all(20), children: [
                const Text('📦 Delivery Address', style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 10),
                AppField(label: 'Street Address *', hint: 'Building, Street', controller: _addrCtrl),
                Row(children: [
                  Expanded(child: AppField(label: 'City *', hint: 'City', controller: _cityCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: AppField(label: 'Pincode *', hint: '6 digits',
                      controller: _pinCtrl, keyboard: TextInputType.number)),
                ]),
                const Text('💰 Payment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 10),
                for (final m in [
                  (id: 'upi', label: '📱 UPI (GPay / PhonePe / Paytm)'),
                  (id: 'card', label: '💳 Credit / Debit Card'),
                  (id: 'cod', label: '💵 Cash on Delivery'),
                ])
                  GestureDetector(
                    onTap: () => setState(() => _payMethod = m.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                          color: _payMethod == m.id
                              ? AppTheme.primary.withOpacity(0.06) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _payMethod == m.id ? AppTheme.primary : AppTheme.border,
                              width: _payMethod == m.id ? 1.5 : 1)),
                      child: Row(children: [
                        Text(m.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                            color: _payMethod == m.id ? AppTheme.primary : null)),
                        const Spacer(),
                        if (_payMethod == m.id)
                          const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                      ]),
                    ),
                  ),
                const SizedBox(height: 4),
                if (_payMethod == 'upi')
                  AppField(label: 'Your UPI ID', hint: 'yourname@upi', controller: _upiCtrl),
                if (_payMethod == 'card') ...[
                  AppField(label: 'Card Number', hint: '16-digit number',
                      controller: _cardCtrl, keyboard: TextInputType.number),
                  AppField(label: 'Name on Card', hint: 'As printed', controller: _cardNameCtrl),
                  Row(children: [
                    Expanded(child: AppField(label: 'Expiry', hint: 'MM/YY', controller: _cardExpCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: AppField(label: 'CVV', hint: '3 digits',
                        controller: _cardCvvCtrl, keyboard: TextInputType.number, obscure: true)),
                  ]),
                ],
                if (_payMethod == 'cod')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('💵 Pay ₹${cart.grandTotal.toInt()} on delivery.',
                        style: const TextStyle(color: AppTheme.warning, fontSize: 13)),
                  ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.background,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(children: [
                    InfoRow(label: 'Items', value: '₹${cart.subtotal.toInt()}'),
                    InfoRow(label: 'Delivery',
                        value: cart.deliveryCharge == 0 ? 'FREE' : '₹${cart.deliveryCharge.toInt()}',
                        valueColor: cart.deliveryCharge == 0 ? AppTheme.success : null),
                    const Divider(height: 12),
                    InfoRow(label: 'Grand Total',
                        value: '₹${cart.grandTotal.toInt()}', valueColor: AppTheme.primary),
                  ]),
                ),
                const SizedBox(height: 14),
                const AdminConfirmBanner(),
                PrimaryBtn(label: 'Place Order — ₹${cart.grandTotal.toInt()}',
                    onTap: _placeOrder),
                const SizedBox(height: 20),
              ])),
        ]),
      ),
    );
  }
}