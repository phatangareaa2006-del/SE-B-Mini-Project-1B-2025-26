import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common_widgets.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<RequestProvider>().loadForUser(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final rp     = context.watch<RequestProvider>();
    final uid    = auth.user?.uid ?? '';
    final all    = rp.forUser(uid);
    final active = all.where((r) =>
    r.status == RequestStatus.pending ||
        r.status == RequestStatus.approved).toList();
    final completed = all.where((r) => r.status == RequestStatus.completed).toList();
    final cancelled = all.where((r) =>
    r.status == RequestStatus.rejected ||
        r.status == RequestStatus.cancelled).toList();

    return Scaffold(
      body: SafeArea(child: Column(children: [
        const SectionHeader(title: 'My Bookings', subtitle: 'Track all your requests'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: AppTheme.border.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12)),
          child: TabBar(
            controller: _tabs,
            indicator: BoxDecoration(color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10)),
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(text: 'Active (${active.length})'),
              Tab(text: 'Done (${completed.length})'),
              Tab(text: 'Cancelled (${cancelled.length})'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: TabBarView(controller: _tabs, children: [
          _BookingList(requests: active),
          _BookingList(requests: completed),
          _BookingList(requests: cancelled),
        ])),
      ])),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<AppRequest> requests;
  const _BookingList({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const EmptyState(icon: Icons.receipt_long_outlined,
          title: 'No requests here', subtitle: 'Your bookings will appear here');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: requests.length,
      itemBuilder: (_, i) => _BookingCard(req: requests[i]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final AppRequest req;
  const _BookingCard({required this.req});

  Color get _statusColor => switch (req.status) {
    RequestStatus.approved  => AppTheme.success,
    RequestStatus.completed => AppTheme.accent,
    RequestStatus.rejected  => AppTheme.error,
    RequestStatus.cancelled => AppTheme.textSecondary,
    _                       => AppTheme.warning,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(req.typeLabel, style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15))),
          StatusBadge(label: req.status.name.toUpperCase(), color: _statusColor),
        ]),
        const SizedBox(height: 6),
        Text(req.displayTitle, style: const TextStyle(
            fontSize: 13, color: AppTheme.textSecondary)),
        if (req.displayAmount > 0) ...[
          const SizedBox(height: 4),
          Text('₹${req.displayAmount.toInt()}', style: const TextStyle(
              color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 15)),
        ],
        if (req.rentalStart != null) ...[
          const SizedBox(height: 4),
          Text('${Fmt.dateTime(req.rentalStart!)} → ${Fmt.dateTime(req.rentalEnd!)}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
        if (req.serviceDate != null) ...[
          const SizedBox(height: 4),
          Text('${req.serviceDate} at ${req.serviceTime}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
        if (req.orderId != null) ...[
          const SizedBox(height: 4),
          Text('Order ID: ${req.orderId}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
        const SizedBox(height: 6),
        Text(Fmt.dateTime(req.createdAt),
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        if (req.adminNotes != null) ...[
          const Divider(height: 12),
          Text('Admin: ${req.adminNotes}', style: const TextStyle(
              fontSize: 12, color: AppTheme.primary)),
        ],
        if (req.canCancel) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.read<RequestProvider>().cancel(req.id),
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: const Text('Cancel Request'),
            ),
          ),
        ],
      ]),
    );
  }
}