import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../providers/request_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common_widgets.dart';

class AdminRequests extends StatefulWidget {
  const AdminRequests({super.key});
  @override State<AdminRequests> createState() => _AdminRequestsState();
}

class _AdminRequestsState extends State<AdminRequests>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestProvider>().loadAll();
    });
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<RequestProvider>();
    return Scaffold(
      body: SafeArea(child: Column(children: [
        const SectionHeader(title: 'Requests', subtitle: 'Manage all customer requests'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: AppTheme.border.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12)),
          child: TabBar(
            controller: _tabs,
            isScrollable: true,
            indicator: BoxDecoration(color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10)),
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(text: '⏳ Pending (${rp.pending.length})'),
              Tab(text: '✅ Approved'),
              Tab(text: '❌ Rejected'),
              Tab(text: '📋 All'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: TabBarView(controller: _tabs, children: [
          _ReqList(rp.pending, showActions: true),
          _ReqList(rp.approved),
          _ReqList(rp.rejected),
          _ReqList(rp.all),
        ])),
      ])),
    );
  }
}

class _ReqList extends StatelessWidget {
  final List<AppRequest> reqs; final bool showActions;
  const _ReqList(this.reqs, {this.showActions = false});

  @override
  Widget build(BuildContext context) {
    if (reqs.isEmpty) {
      return const EmptyState(icon: Icons.inbox_outlined,
          title: 'No requests', subtitle: 'Nothing here yet');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: reqs.length,
      itemBuilder: (_, i) => _AdminReqCard(req: reqs[i], showActions: showActions),
    );
  }
}

// ─── Full-detail request card ──────────────────────────────────────────────
class _AdminReqCard extends StatefulWidget {
  final AppRequest req; final bool showActions;
  const _AdminReqCard({required this.req, required this.showActions});
  @override State<_AdminReqCard> createState() => _AdminReqCardState();
}

class _AdminReqCardState extends State<_AdminReqCard> {
  final _notesCtrl = TextEditingController();
  bool _expanded = false;

  Color get _statusColor => switch (widget.req.status) {
    RequestStatus.approved  => AppTheme.success,
    RequestStatus.completed => AppTheme.accent,
    RequestStatus.rejected  => AppTheme.error,
    RequestStatus.cancelled => AppTheme.textSecondary,
    _                       => AppTheme.warning,
  };

  IconData get _typeIcon => switch (widget.req.type) {
    RequestType.rental         => Icons.directions_car,
    RequestType.testDrive      => Icons.drive_eta,
    RequestType.purchase       => Icons.shopping_bag,
    RequestType.serviceBooking => Icons.build,
    RequestType.partsOrder     => Icons.inventory_2,
  };

  Color get _typeColor => switch (widget.req.type) {
    RequestType.rental         => AppTheme.warning,
    RequestType.testDrive      => AppTheme.primary,
    RequestType.purchase       => AppTheme.accent,
    RequestType.serviceBooking => AppTheme.success,
    RequestType.partsOrder     => const Color(0xFF9C27B0),
  };

  @override
  Widget build(BuildContext context) {
    final r = widget.req;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _typeColor.withOpacity(0.3)),
          boxShadow: [BoxShadow(
              color: _typeColor.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Card header (always visible) ────────────────────────────────
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _typeColor.withOpacity(0.06),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(16),
                bottom: _expanded ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Column(children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: _typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(_typeIcon, color: _typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.typeLabel, style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15,
                      color: _typeColor)),
                  const SizedBox(height: 2),
                  Text(r.displayTitle, style: const TextStyle(
                      fontSize: 13, color: AppTheme.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusBadge(label: r.status.name.toUpperCase(), color: _statusColor),
                  const SizedBox(height: 4),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.textSecondary, size: 18),
                ]),
              ]),
              const SizedBox(height: 10),
              // Quick summary row
              Row(children: [
                _QuickInfo(Icons.person_outline, r.userName.isNotEmpty ? r.userName : 'Unknown'),
                const SizedBox(width: 16),
                _QuickInfo(Icons.access_time_outlined, _timeAgo(r.createdAt)),
                const Spacer(),
                if (r.displayAmount > 0)
                  Text('₹${r.displayAmount.toInt()}',
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.bold,
                          fontSize: 16)),
              ]),
            ]),
          ),
        ),

        // ── Expanded detail section ─────────────────────────────────────
        if (_expanded) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Section: Customer Information ──────────────────────────
              _SectionLabel('👤 Customer Information'),
              _DetailRow(Icons.person, 'Name', r.userName.isNotEmpty ? r.userName : '—'),
              _DetailRow(Icons.phone, 'Contact', r.userContact.isNotEmpty ? r.userContact : '—',
                  copyable: true),
              if (r.customerName != null && r.customerName!.isNotEmpty)
                _DetailRow(Icons.badge_outlined, 'Customer Name', r.customerName!),
              if (r.customerPhone != null && r.customerPhone!.isNotEmpty)
                _DetailRow(Icons.phone_android, 'Customer Phone', r.customerPhone!,
                    copyable: true),
              _DetailRow(Icons.key, 'User ID', r.userId, copyable: true, small: true),

              const SizedBox(height: 12),

              // ── Section: Request Details (varies by type) ───────────────
              _SectionLabel('📋 Request Details'),
              _DetailRow(Icons.receipt_long, 'Request ID', r.id, copyable: true, small: true),
              _DetailRow(Icons.calendar_today, 'Submitted', Fmt.dateTime(r.createdAt)),

              // Vehicle info
              if (r.vehicleTitle != null) ...[
                _DetailRow(Icons.directions_car, 'Vehicle', r.vehicleTitle!),
                if (r.vehiclePrice != null && r.vehiclePrice! > 0)
                  _DetailRow(Icons.currency_rupee, 'Vehicle Price',
                      '₹${r.vehiclePrice!.toInt()}'),
              ],

              // Rental specific
              if (r.type == RequestType.rental) ...[
                const SizedBox(height: 4),
                _SectionLabel('🕐 Rental Details'),
                if (r.rentalStart != null)
                  _DetailRow(Icons.play_circle_outline, 'Start',
                      Fmt.dateTime(r.rentalStart!)),
                if (r.rentalEnd != null)
                  _DetailRow(Icons.stop_circle_outlined, 'End',
                      Fmt.dateTime(r.rentalEnd!)),
                if (r.rentalHours != null)
                  _DetailRow(Icons.timer_outlined, 'Duration',
                      '${r.rentalHours} hour${r.rentalHours! != 1 ? "s" : ""}'),
                if (r.rentalTotalCost != null)
                  _DetailRow(Icons.currency_rupee, 'Rental Cost',
                      '₹${r.rentalTotalCost!.toInt()}', highlight: true),
                if (r.licenseNo != null && r.licenseNo!.isNotEmpty)
                  _DetailRow(Icons.badge, 'License No.', r.licenseNo!, copyable: true),
                if (r.pickupLocation != null && r.pickupLocation!.isNotEmpty)
                  _DetailRow(Icons.location_on_outlined, 'Pickup', r.pickupLocation!),
                if (r.dropoffLocation != null && r.dropoffLocation!.isNotEmpty)
                  _DetailRow(Icons.location_off_outlined, 'Dropoff', r.dropoffLocation!),
              ],

              // Purchase specific
              if (r.type == RequestType.purchase) ...[
                const SizedBox(height: 4),
                _SectionLabel('🛒 Purchase Details'),
                if (r.dealerName != null && r.dealerName!.isNotEmpty)
                  _DetailRow(Icons.store, 'Dealer', r.dealerName!),
                if (r.dealerAddress != null && r.dealerAddress!.isNotEmpty)
                  _DetailRow(Icons.map_outlined, 'Dealer Location', r.dealerAddress!),
              ],

              // Test drive specific
              if (r.type == RequestType.testDrive) ...[
                const SizedBox(height: 4),
                _SectionLabel('🚗 Test Drive Details'),
                if (r.testDriveDate != null)
                  _DetailRow(Icons.event, 'Date', r.testDriveDate!),
                if (r.testDriveTime != null)
                  _DetailRow(Icons.schedule, 'Time', r.testDriveTime!),
                if (r.dealerName != null && r.dealerName!.isNotEmpty)
                  _DetailRow(Icons.store, 'Dealer', r.dealerName!),
                if (r.dealerAddress != null && r.dealerAddress!.isNotEmpty)
                  _DetailRow(Icons.location_pin, 'Dealer Address', r.dealerAddress!),
              ],

              // Service booking specific
              if (r.type == RequestType.serviceBooking) ...[
                const SizedBox(height: 4),
                _SectionLabel('🔧 Service Details'),
                if (r.serviceName != null)
                  _DetailRow(Icons.build_outlined, 'Service', r.serviceName!),
                if (r.servicePrice != null)
                  _DetailRow(Icons.currency_rupee, 'Price',
                      '₹${r.servicePrice!.toInt()}', highlight: true),
                if (r.serviceDate != null)
                  _DetailRow(Icons.event, 'Date', r.serviceDate!),
                if (r.serviceTime != null)
                  _DetailRow(Icons.schedule, 'Time', r.serviceTime!),
                if (r.serviceLocation != null && r.serviceLocation!.isNotEmpty)
                  _DetailRow(Icons.location_on_outlined, 'Location', r.serviceLocation!),
                if (r.serviceNotes != null && r.serviceNotes!.isNotEmpty)
                  _DetailRow(Icons.notes, 'Customer Notes', r.serviceNotes!),
              ],

              // Parts order specific
              if (r.type == RequestType.partsOrder) ...[
                const SizedBox(height: 4),
                _SectionLabel('📦 Order Details'),
                if (r.orderId != null)
                  _DetailRow(Icons.receipt, 'Order ID', r.orderId!, copyable: true),
                if (r.orderItems != null && r.orderItems!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Items (${r.orderItems!.length})',
                            style: const TextStyle(fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary)),
                        const SizedBox(height: 6),
                        ...r.orderItems!.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(children: [
                            Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600)),
                                  Text('${item.brand} • Qty: ${item.quantity}',
                                      style: const TextStyle(
                                          fontSize: 11, color: AppTheme.textSecondary)),
                                ])),
                            Text('₹${item.totalPrice.toInt()}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold,
                                    color: AppTheme.primary)),
                          ]),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (r.orderSubtotal != null)
                    _DetailRow(Icons.calculate, 'Subtotal', '₹${r.orderSubtotal!.toInt()}'),
                  if (r.orderDeliveryCharge != null)
                    _DetailRow(Icons.local_shipping_outlined, 'Delivery',
                        '₹${r.orderDeliveryCharge!.toInt()}'),
                  if (r.orderTotal != null)
                    _DetailRow(Icons.currency_rupee, 'Total',
                        '₹${r.orderTotal!.toInt()}', highlight: true),
                  if (r.deliveryAddress != null && r.deliveryAddress!.isNotEmpty)
                    _DetailRow(Icons.home_outlined, 'Delivery Address', r.deliveryAddress!),
                ],
              ],

              // ── Section: Payment Information ────────────────────────────
              if (r.paymentMethod != null || r.upiId != null ||
                  r.cardLast4 != null || r.upiTransactionId != null) ...[
                const SizedBox(height: 12),
                _SectionLabel('💳 Payment Information'),
                if (r.paymentMethod != null)
                  _DetailRow(Icons.payment, 'Payment Method',
                      r.paymentMethod!.toUpperCase()),
                if (r.upiId != null && r.upiId!.isNotEmpty)
                  _DetailRow(Icons.account_balance_wallet_outlined,
                      'UPI ID', r.upiId!, copyable: true),
                if (r.cardLast4 != null && r.cardLast4!.isNotEmpty)
                  _DetailRow(Icons.credit_card, 'Card',
                      '•••• •••• •••• ${r.cardLast4}'),
                if (r.upiTransactionId != null && r.upiTransactionId!.isNotEmpty)
                  _DetailRow(Icons.tag, 'Transaction ID',
                      r.upiTransactionId!, copyable: true),
                _DetailRow(Icons.check_circle_outline, 'Payment Status',
                    r.paymentStatus.name.toUpperCase(),
                    color: r.paymentStatus == PaymentStatus.paid
                        ? AppTheme.success : AppTheme.warning),
              ],

              // ── Admin notes ─────────────────────────────────────────────
              if (r.adminNotes != null && r.adminNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SectionLabel('📝 Admin Notes'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
                  child: Text(r.adminNotes!, style: const TextStyle(
                      fontSize: 13, color: AppTheme.primary,
                      fontStyle: FontStyle.italic)),
                ),
              ],

              // ── Amount summary ──────────────────────────────────────────
              if (r.displayAmount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total Amount', style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('₹${r.displayAmount.toInt()}', style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.bold,
                        fontSize: 20)),
                  ]),
                ),
              ],

              // ── Action buttons ──────────────────────────────────────────
              if (widget.showActions && r.status == RequestStatus.pending) ...[
                const SizedBox(height: 16),
                TextField(controller: _notesCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Add admin note (optional)...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () => context.read<RequestProvider>().approve(
                        r.id, notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () => context.read<RequestProvider>().reject(
                        r.id, notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  )),
                ]),
              ],
            ]),
          ),
        ],

        // Tap to expand hint (when collapsed)
        if (!_expanded)
          GestureDetector(
            onTap: () => setState(() => _expanded = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.border.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.expand_more, size: 16, color: AppTheme.textSecondary),
                SizedBox(width: 4),
                Text('Tap to view full details',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ]),
            ),
          ),

        // Quick approve/reject when collapsed
        if (!_expanded && widget.showActions && r.status == RequestStatus.pending)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(children: [
              Expanded(child: ElevatedButton(
                onPressed: () => context.read<RequestProvider>().approve(r.id),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('✅ Approve', style: TextStyle(fontSize: 12)),
              )),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(
                onPressed: () => context.read<RequestProvider>().reject(r.id),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('❌ Reject', style: TextStyle(fontSize: 12)),
              )),
            ]),
          ),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Helper widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3)),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool copyable, small;
  final Color? color;
  final bool highlight;

  const _DetailRow(this.icon, this.label, this.value,
      {this.copyable = false, this.small = false,
        this.color, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = highlight ? AppTheme.primary : color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        SizedBox(width: 100, child: Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
        Expanded(child: GestureDetector(
          onTap: copyable ? () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied: $value'), duration: const Duration(seconds: 1)),
            );
          } : null,
          child: Row(children: [
            Flexible(child: Text(value,
                style: TextStyle(
                    fontSize: small ? 11 : 12,
                    fontWeight: effectiveColor != null ? FontWeight.bold : FontWeight.w600,
                    color: effectiveColor ?? AppTheme.textPrimary,
                    fontFamily: small ? 'monospace' : null),
                overflow: TextOverflow.ellipsis, maxLines: 3)),
            if (copyable) const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.copy, size: 12, color: AppTheme.textSecondary),
            ),
          ]),
        )),
      ]),
    );
  }
}

class _QuickInfo extends StatelessWidget {
  final IconData icon; final String text;
  const _QuickInfo(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: AppTheme.textSecondary),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
  ]);
}