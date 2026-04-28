import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parts_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<RequestProvider>();
    final vp = context.watch<VehicleProvider>();
    final pp = context.watch<PartsProvider>();
    final sp = context.watch<ServiceProvider>();

    final totalRevenue = rp.approved.fold<double>(
        0, (s, r) => s + r.displayAmount);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<RequestProvider>().loadAll(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header
              const Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Panel 🛡️', style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('AutoHub Management Dashboard',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ])),
              ]),
              const SizedBox(height: 20),

              // KPI cards
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _KpiCard('${rp.pending.length}', 'Pending',
                      Icons.pending_actions, AppTheme.warning),
                  _KpiCard('${rp.approved.length}', 'Approved',
                      Icons.check_circle, AppTheme.success),
                  _KpiCard('${vp.vehicles.length}', 'Vehicles',
                      Icons.directions_car, AppTheme.primary),
                  _KpiCard('₹${(totalRevenue/1000).toStringAsFixed(0)}K',
                      'Revenue', Icons.currency_rupee, AppTheme.accent),
                ],
              ),
              const SizedBox(height: 20),

              // Inventory summary
              const Text('Inventory', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _InventoryTile(
                    '${vp.vehicles.length}', 'Vehicles',
                    Icons.directions_car, AppTheme.primary)),
                const SizedBox(width: 10),
                Expanded(child: _InventoryTile(
                    '${pp.parts.length}', 'Parts',
                    Icons.settings, AppTheme.accent)),
                const SizedBox(width: 10),
                Expanded(child: _InventoryTile(
                    '${sp.services.length}', 'Services',
                    Icons.build, AppTheme.success)),
              ]),
              const SizedBox(height: 20),

              // Recent requests
              const Text('Recent Requests', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...rp.pending.take(5).map((r) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.typeLabel, style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(r.userName, style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                        Text('₹${r.displayAmount.toInt()}', style: const TextStyle(
                            color: AppTheme.primary, fontWeight: FontWeight.w600)),
                      ])),
                  Column(children: [
                    StatusBadge(label: 'PENDING', color: AppTheme.warning),
                    const SizedBox(height: 6),
                    Row(children: [
                      _ActionBtn('✅', () => context.read<RequestProvider>().approve(r.id)),
                      const SizedBox(width: 6),
                      _ActionBtn('❌', () => context.read<RequestProvider>().reject(r.id)),
                    ]),
                  ]),
                ]),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String value, label; final IconData icon; final Color color;
  const _KpiCard(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 24),
      const Spacer(),
      Text(value, style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(
          fontSize: 12, color: AppTheme.textSecondary)),
    ]),
  );
}

class _InventoryTile extends StatelessWidget {
  final String count, label; final IconData icon; final Color color;
  const _InventoryTile(this.count, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 4),
      Text(count, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(
          fontSize: 11, color: AppTheme.textSecondary)),
    ]),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _ActionBtn(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: AppTheme.border, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    ),
  );
}