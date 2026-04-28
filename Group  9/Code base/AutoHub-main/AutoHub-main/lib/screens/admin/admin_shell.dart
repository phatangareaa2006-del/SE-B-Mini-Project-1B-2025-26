import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/parts_provider.dart';
import '../../providers/service_provider.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard.dart';
import 'admin_requests.dart';
import 'admin_inventory.dart';
import 'admin_settings.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _idx = 0;

  static const _screens = [
    AdminDashboard(), AdminRequests(), AdminInventory(), AdminSettings(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestProvider>().loadAll();
      context.read<VehicleProvider>().load();
      context.read<PartsProvider>().load();
      context.read<ServiceProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}