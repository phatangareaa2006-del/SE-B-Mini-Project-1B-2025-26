import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/parts_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminSettings extends StatelessWidget {
  const AdminSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.primary],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                    color: Colors.white24, borderRadius: BorderRadius.circular(30)),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(user.email ?? '', style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 13)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.white24, borderRadius: BorderRadius.circular(6)),
                      child: const Text('Administrator', style: TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ])),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor)),
            child: Column(children: [
              _Tile(Icons.store, 'Business UPI ID', 'chaitanya.tankar@okhdfcbank',
                  AppTheme.success, () {
                    showDialog(context: context, builder: (_) => AlertDialog(
                      title: const Text('Business UPI ID'),
                      content: const Text('chaitanya.tankar@okhdfcbank'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context),
                          child: const Text('OK'))],
                    ));
                  }),
              _Tile(Icons.sync, 'Re-seed Database (₹1–₹2)',
                  'Overwrite Firestore with test prices', AppTheme.warning,
                      () async {
                    final ok = await showDialog<bool>(context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Re-seed Database?'),
                          content: const Text(
                              'This will DELETE all existing vehicles, parts and services '
                                  'in Firestore and re-upload them with ₹1–₹2 test prices.\n\n'
                                  'Any custom listings added via admin will be lost.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Re-seed',
                                    style: TextStyle(color: AppTheme.warning))),
                          ],
                        ));
                    if (ok != true || !context.mounted) return;
                    showSuccess(context, 'Re-seeding... please wait');
                    await context.read<VehicleProvider>().forceReseed();
                    await context.read<PartsProvider>().forceReseed();
                    await context.read<ServiceProvider>().forceReseed();
                    if (context.mounted) {
                      showSuccess(context, '✅ Database re-seeded with ₹1–₹2 prices!');
                    }
                  }),
              _Tile(Icons.receipt_long, 'Payment Transactions',
                  'View all UPI payment records', AppTheme.accent,
                      () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const _TransactionScreen()))),
              _Tile(Icons.notifications_outlined, 'Notification Settings',
                  'Manage push notifications', AppTheme.warning, () {}),
              _Tile(Icons.people_outline, 'Dealer Management',
                  'Add & manage dealers', AppTheme.accent, () {}),
              _Tile(Icons.bar_chart, 'Analytics', 'View detailed reports',
                  AppTheme.primary, () {}),
              _Tile(Icons.info_outline, 'App Version', 'v3.0.0 — AutoHub',
                  AppTheme.textSecondary,
                      () => showAboutDialog(context: context,
                      applicationName: 'AutoHub', applicationVersion: '3.0.0')),
              _Tile(Icons.logout, 'Logout', 'Sign out from Admin',
                  AppTheme.error, () async {
                    final ok = await showDialog<bool>(context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Sign out from admin panel?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout',
                                    style: TextStyle(color: AppTheme.error))),
                          ],
                        ));
                    if (ok == true && context.mounted) auth.logout();
                  }, isDestructive: true),
            ]),
          ),
        ]),
      )),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon; final String title, subtitle; final Color color;
  final VoidCallback onTap; final bool isDestructive;
  const _Tile(this.icon, this.title, this.subtitle, this.color, this.onTap,
      {this.isDestructive = false});

  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(
      leading: Icon(icon, color: isDestructive ? AppTheme.error : color),
      title: Text(title, style: TextStyle(
          color: isDestructive ? AppTheme.error : null,
          fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(
          fontSize: 12, color: AppTheme.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    ),
    if (title != 'Logout')
      const Divider(height: 0, indent: 20, endIndent: 20),
  ]);
}

// ── Payment Transaction History Screen ────────────────────────────────────
class _TransactionScreen extends StatefulWidget {
  const _TransactionScreen();
  @override State<_TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<_TransactionScreen> {
  List<Map<String, dynamic>> _txns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .get();
      setState(() {
        _txns = snap.docs.map((d) => d.data()).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Transactions'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _txns.isEmpty
          ? const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 48, color: AppTheme.textSecondary),
                SizedBox(height: 12),
                Text('No transactions yet', style: TextStyle(
                    fontSize: 16, color: AppTheme.textSecondary)),
              ]))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _txns.length,
        itemBuilder: (_, i) {
          final t = _txns[i];
          final status = t['status'] ?? 'initiated';
          final statusColor = status == 'success'
              ? AppTheme.success
              : status == 'failed'
              ? AppTheme.error
              : AppTheme.warning;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: statusColor.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(t['txnRef'] ?? '—',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(status.toUpperCase(),
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold,
                              color: statusColor)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _TxnRow(Icons.currency_rupee, 'Amount',
                      '₹${t['amount'] ?? 0}',
                      color: AppTheme.primary),
                  _TxnRow(Icons.person_outline, 'Customer',
                      t['userName'] ?? '—'),
                  _TxnRow(Icons.directions_car_outlined, 'Item',
                      t['itemTitle'] ?? '—'),
                  _TxnRow(Icons.account_balance_wallet_outlined, 'UPI ID',
                      t['upiId'] ?? '—'),
                  _TxnRow(Icons.category_outlined, 'Type',
                      t['type'] ?? '—'),
                  _TxnRow(Icons.access_time, 'Time',
                      t['createdAt'] != null
                          ? t['createdAt'].toDate().toString().substring(0, 16)
                          : '—'),
                ]),
          );
        },
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  final IconData icon; final String label, value; final Color? color;
  const _TxnRow(this.icon, this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Icon(icon, size: 13, color: AppTheme.textSecondary),
      const SizedBox(width: 6),
      SizedBox(width: 80, child: Text(label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary))),
      Expanded(child: Text(value, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: color ?? AppTheme.textPrimary))),
    ]),
  );
}