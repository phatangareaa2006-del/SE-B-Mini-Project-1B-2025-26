import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle_model.dart';
import '../../models/spare_part_model.dart';
import '../../models/service_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/parts_provider.dart';
import '../../providers/service_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';
import 'add_vehicle_screen.dart';
import 'add_part_screen.dart';
import 'add_service_screen.dart';

class AdminInventory extends StatefulWidget {
  const AdminInventory({super.key});
  @override State<AdminInventory> createState() => _AdminInventoryState();
}

class _AdminInventoryState extends State<AdminInventory>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final vp = context.watch<VehicleProvider>();
    final pp = context.watch<PartsProvider>();
    final sp = context.watch<ServiceProvider>();

    return Scaffold(
      body: SafeArea(child: Column(children: [
        const SectionHeader(title: 'Inventory', subtitle: 'Manage vehicles, parts & services'),
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
              Tab(text: '🚗 Vehicles (${vp.vehicles.length})'),
              Tab(text: '⚙️ Parts (${pp.parts.length})'),
              Tab(text: '🔧 Services (${sp.services.length})'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: TabBarView(controller: _tabs, children: [
          _VehicleTab(vehicles: vp.vehicles.toList()),
          _PartsTab(parts: pp.parts.toList()),
          _ServicesTab(services: sp.services.toList()),
        ])),
      ])),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          ['Add Vehicle', 'Add Part', 'Add Service'][_tabs.index],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => [
            const AddVehicleScreen(),
            const AddPartScreen(),
            const AddServiceScreen(),
          ][_tabs.index],
        )),
      ),
    );
  }
}

// ── Vehicle Tab ──────────────────────────────────────────────────────────────
class _VehicleTab extends StatelessWidget {
  final List<Vehicle> vehicles;
  const _VehicleTab({required this.vehicles});

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) return const EmptyState(
        icon: Icons.directions_car_outlined,
        title: 'No vehicles yet', subtitle: 'Tap + to add your first vehicle');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: vehicles.length,
      itemBuilder: (_, i) {
        final v = vehicles[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor)),
          child: ListTile(
            leading: v.imageUrls.isNotEmpty
                ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(v.imageUrls.first,
                    width: 56, height: 56, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.directions_car)))
                : const Icon(Icons.directions_car, size: 36, color: AppTheme.primary),
            title: Text(v.title, style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(
              '₹${v.price >= 100000 ? (v.price/100000).toStringAsFixed(1) + "L" : v.price >= 1000 ? (v.price/1000).toStringAsFixed(0) + "K" : v.price.toInt().toString()}  •  '
                  '${v.city}  •  ${v.isVerified ? '✅ Verified' : '⏳ Pending'}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'delete') {
                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: const Text('Delete Vehicle'),
                    content: Text('Delete "${v.title}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          context.read<VehicleProvider>().deleteVehicle(v.id);
                          Navigator.pop(context);
                          showSuccess(context, 'Vehicle deleted');
                        },
                        child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
                      ),
                    ],
                  ));
                } else if (action == 'edit') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddVehicleScreen(vehicle: v)));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('✏️ Edit')),
                const PopupMenuItem(value: 'delete', child: Text('🗑️ Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Parts Tab ────────────────────────────────────────────────────────────────
class _PartsTab extends StatelessWidget {
  final List<SparePart> parts;
  const _PartsTab({required this.parts});

  @override
  Widget build(BuildContext context) {
    if (parts.isEmpty) return const EmptyState(
        icon: Icons.settings_outlined,
        title: 'No parts yet', subtitle: 'Tap + to add your first part');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: parts.length,
      itemBuilder: (_, i) {
        final p = parts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor)),
          child: ListTile(
            leading: p.imageUrls.isNotEmpty
                ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(p.imageUrls.first,
                    width: 56, height: 56, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.settings)))
                : const Icon(Icons.settings, size: 36, color: AppTheme.accent),
            title: Text(p.name, style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(
              '₹${p.discountedPrice.toInt()}  •  Stock: ${p.stock}  •  ${p.brand}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'delete') {
                  context.read<PartsProvider>().deletePart(p.id);
                  showSuccess(context, 'Part deleted');
                } else if (action == 'edit') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddPartScreen(part: p)));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('✏️ Edit')),
                const PopupMenuItem(value: 'delete', child: Text('🗑️ Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Services Tab ─────────────────────────────────────────────────────────────
class _ServicesTab extends StatelessWidget {
  final List<ServiceItem> services;
  const _ServicesTab({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const EmptyState(
        icon: Icons.build_outlined,
        title: 'No services yet', subtitle: 'Tap + to add your first service');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: services.length,
      itemBuilder: (_, i) {
        final s = services[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor)),
          child: ListTile(
            leading: s.imageUrls.isNotEmpty
                ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(s.imageUrls.first,
                    width: 56, height: 56, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.build)))
                : const Icon(Icons.build, size: 36, color: AppTheme.success),
            title: Text(s.title, style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(
              '₹${s.price.toInt()}  •  ${s.durationLabel}  •  ${s.category}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'delete') {
                  context.read<ServiceProvider>().deleteService(s.id);
                  showSuccess(context, 'Service deleted');
                } else if (action == 'edit') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddServiceScreen(service: s)));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('✏️ Edit')),
                const PopupMenuItem(value: 'delete', child: Text('🗑️ Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}