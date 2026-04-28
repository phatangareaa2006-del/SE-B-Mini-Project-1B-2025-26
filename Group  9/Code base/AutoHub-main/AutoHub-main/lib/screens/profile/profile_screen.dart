import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final rp     = context.watch<RequestProvider>();
    final vp     = context.watch<VehicleProvider>();
    final user   = auth.user!;
    final myReqs = rp.forUser(user.uid);
    final saved  = vp.vehicles.where((v) => auth.isSaved(v.id)).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: 12),
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  backgroundImage: user.profilePhoto != null
                      ? NetworkImage(user.profilePhoto!) : null,
                  child: user.profilePhoto == null
                      ? Text(user.initials, style: const TextStyle(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user.displayName, style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(user.email ?? user.phone ?? '', style: TextStyle(
                    color: Colors.white.withOpacity(0.85), fontSize: 13)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _Stat('${myReqs.length}', 'Total'),
                  _Stat('${myReqs.where((r) => r.status.name == 'pending').length}', 'Pending'),
                  _Stat('${saved.length}', 'Saved'),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            // Menu
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor)),
              child: Column(children: [
                _MenuItem(Icons.favorite_outline, 'Saved Vehicles',
                    '${saved.length} saved', AppTheme.error, () {}),
                _MenuItem(Icons.history, 'Booking History',
                    '${myReqs.length} requests', AppTheme.primary, () {}),
                _MenuItem(Icons.help_outline, 'Help & Support',
                    'support@autohub.com', AppTheme.accent, () {}),
                _MenuItem(Icons.info_outline, 'About AutoHub',
                    'v3.0.0', AppTheme.textSecondary, () => showAboutDialog(
                        context: context, applicationName: 'AutoHub',
                        applicationVersion: '3.0.0')),
                _MenuItem(Icons.logout, 'Logout',
                    'Sign out of AutoHub', AppTheme.error, () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout',
                                    style: TextStyle(color: AppTheme.error))),
                          ],
                        ),
                      );
                      if (ok == true && context.mounted) auth.logout();
                    }, isDestructive: true),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(
        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
    Text(label, style: TextStyle(
        color: Colors.white.withOpacity(0.8), fontSize: 12)),
  ]);
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String title, subtitle; final Color color;
  final VoidCallback onTap; final bool isDestructive;

  const _MenuItem(this.icon, this.title, this.subtitle,
      this.color, this.onTap, {this.isDestructive = false});

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