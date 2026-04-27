import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'booking_history_screen.dart'; // ── ADDED ──

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  bool _darkMode = false;
  String _vehicle = '4 Wheeler';

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.accentLight,
                child: Text(
                  user?.displayName?.isNotEmpty == true
                      ? user!.displayName![0].toUpperCase()
                      : 'G',
                  style: const TextStyle(fontSize: 40,
                      fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user?.displayName ?? 'Guest User',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'guest@evchargefinder.com',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8)),
              ),
              const SizedBox(height: 24),
              _section('Vehicle Settings', [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vehicle Type',
                          style: TextStyle(fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _vehicleBtn(
                            '2 Wheeler', Icons.electric_scooter)),
                        const SizedBox(width: 12),
                        Expanded(child: _vehicleBtn(
                            '4 Wheeler', Icons.electric_car)),
                      ]),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _section('Preferences', [
                _switchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Toggle dark theme',
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                _switchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Booking alerts & reminders',
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
              ]),
              const SizedBox(height: 16),
              _section('Account', [
                // ── CHANGED: wired up Booking History navigation ──
                _menuTile(Icons.history, 'Booking History', () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const BookingHistoryScreen()));
                }),
                // ─────────────────────────────────────────────────
                _menuTile(Icons.help_outline, 'Help & Support', () {}),
                _menuTile(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
                _menuTile(Icons.info_outline, 'About App', () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'EV Charge Finder',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.ev_station,
                        color: AppColors.primary, size: 32),
                  );
                }),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                            (_) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Sign Out',
                      style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vehicleBtn(String label, IconData icon) {
    final selected = _vehicle == label;
    return GestureDetector(
      onTap: () => setState(() => _vehicle = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? Colors.white : AppColors.textSecondary,
                size: 28),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle, style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
            ])),
        Switch(value: value, onChanged: onChanged,
            activeColor: AppColors.primary),
      ]),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.primary, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14))),
          const Icon(Icons.arrow_forward_ios, size: 14,
              color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}