import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/parts_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'browse_screen.dart';
import '../services/services_screen.dart';
import '../parts/parts_screen.dart';
import '../bookings/my_bookings_screen.dart';
import '../profile/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _idx = 0;

  static const _screens = [
    BrowseScreen(),
    ServicesScreen(),
    PartsScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<VehicleProvider>().load(); // load once, use pull-to-refresh for updates
      context.read<PartsProvider>().load();
      context.read<ServiceProvider>().load();
      if (auth.user != null) {
        context.read<RequestProvider>().loadForUser(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.directions_car_outlined),
                activeIcon: Icon(Icons.directions_car),
                label: 'Browse'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.build_outlined),
                activeIcon: Icon(Icons.build),
                label: 'Services'),
            BottomNavigationBarItem(
              icon: _CartIcon(count: cart.count),
              activeIcon: _CartIcon(count: cart.count, active: true),
              label: 'Parts',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Bookings'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  final int count; final bool active;
  const _CartIcon({required this.count, this.active = false});

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Icon(active ? Icons.settings : Icons.settings_outlined),
      if (count > 0)
        Positioned(top: -4, right: -6,
          child: Container(
            width: 14, height: 14,
            decoration: const BoxDecoration(
                color: AppTheme.error, shape: BoxShape.circle),
            child: Center(child: Text('$count',
                style: const TextStyle(
                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
          ),
        ),
    ],
  );
}