import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../theme/app_theme.dart';
import 'user/dashboard_screen.dart';
import 'user/register_screen.dart';
import 'user/track_screen.dart';
import 'user/complaints_screen.dart';
import 'user/analytics_screen.dart';
import 'user_profile/user_profile_page.dart';
class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _activeTab = 0;

  void _changeTab(int i) => setState(() => _activeTab = i);

  Widget _buildBody() {
    switch (_activeTab) {
      case 0:
        return DashboardScreen(onTabChange: _changeTab);
      case 1:
        return const RegisterScreen();
      case 2:
        return const TrackScreen();
      case 3:
        return AllComplaintsScreen(onNewComplaint: () => _changeTab(1));
      case 4:
        return const AnalyticsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgGray,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────
          _UserHeader(
            onLogout: () =>
                context.read<ap.AuthProvider>().signOut(),
          ),
          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: KeyedSubtree(
                key: ValueKey(_activeTab),
                child: _buildBody(),
              ),
            ),
          ),
        ],
      ),
      // ── Mobile Bottom Navigation Bar ──────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.navyDark,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, -2))
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                    icon: '📊',
                    label: 'Dashboard',
                    active: _activeTab == 0,
                    onTap: () => _changeTab(0)),
                _NavItem(
                    icon: '📋',
                    label: 'Complaints',
                    active: _activeTab == 3,
                    onTap: () => _changeTab(3)),
                // Centre FAB-style file button
                _NavItemCenter(
                    active: _activeTab == 1,
                    onTap: () => _changeTab(1)),
                _NavItem(
                    icon: '🔍',
                    label: 'Track',
                    active: _activeTab == 2,
                    onTap: () => _changeTab(2)),
                _NavItem(
                    icon: '📈',
                    label: 'Analytics',
                    active: _activeTab == 4,
                    onTap: () => _changeTab(4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── User Header ──────────────────────────────────────────────────────────────
class _UserHeader extends StatelessWidget {
  final VoidCallback onLogout;
  const _UserHeader({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3C6E), Color(0xFF0F2548), Color(0xFF162040)],
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, 4))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE8A020), Color(0xFFF0C040)]),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Center(
                  child: Text('🏛️', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CivicVoice',
                    style: TextStyle(
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.1)),
                Text('MUNICIPAL COMPLAINT PORTAL',
                    style: TextStyle(
                        fontSize: 9,
                        color: Color(0x99FFFFFF),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const Spacer(),
            // Notifications badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(children: [
                Text('🔔', style: TextStyle(fontSize: 14)),
                SizedBox(width: 5),
                Text('Updates',
                    style: TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 11)),
              ]),
            ),
            const SizedBox(width: 8),
            // Avatar / logout
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'logout') onLogout();
                if (v == 'profile') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfilePage()));
                }
              },
              offset: const Offset(0, 44),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFFE8A020), Color(0xFFF0C040)]),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child:
                        Text('👤', style: TextStyle(fontSize: 16))),
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'profile',
                    child: Row(children: [
                      Icon(Icons.person_outline, size: 18),
                      SizedBox(width: 8),
                      Text('My Profile')
                    ])),
                const PopupMenuItem(
                    value: 'logout',
                    child: Row(children: [
                      Icon(Icons.logout_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Sign Out')
                    ])),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Nav item ─────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.gold.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(icon,
                  style: TextStyle(
                      fontSize: active ? 22 : 20)),
            ),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: active
                        ? AppTheme.gold
                        : Colors.white54)),
          ],
        ),
      ),
    );
  }
}

// ─── Centre floating nav button ───────────────────────────────────────────────
class _NavItemCenter extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _NavItemCenter({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE8A020), Color(0xFFF0C040)]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.gold.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ],
              ),
              child: const Center(
                  child: Icon(Icons.edit_rounded,
                      color: Color(0xFF1A3C6E), size: 22)),
            ),
            const SizedBox(height: 2),
            const Text('File',
                style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.gold,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
