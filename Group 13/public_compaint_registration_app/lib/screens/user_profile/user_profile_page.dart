import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart';
import 'profile_page_bundle.dart' hide UserStatsPage;
import 'user_stats_page.dart';
import '../auth/login_screen.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A3C6E),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: uid == null
          ? const Center(child: Text('Not logged in'))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get(),
              builder: (context, userSnap) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('complaints')
                      .where('userId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, compSnap) {
                    final userData =
                        userSnap.data?.data() as Map<String, dynamic>? ?? {};
                    final name =
                        user?.displayName ?? userData['name'] ?? 'User';
                    final email = user?.email ?? '';
                    final complaints = compSnap.data?.docs ?? [];
                    final resolved = complaints
                        .where((d) => (d['status'] ?? '') == 'Resolved')
                        .length;
                    final points = complaints.length * 10 + resolved * 5;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1a3c6e), Color(0xFF0f2548)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFE8A020),
                                            Color(0xFFF0C040),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '👤',
                                          style: TextStyle(fontSize: 50),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF27AE60),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xCCFFFFFF),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _StatBadge(
                                      label: 'Complaints',
                                      value: '${complaints.length}',
                                    ),
                                    const SizedBox(width: 16),
                                    _StatBadge(
                                      label: 'Resolved',
                                      value: '$resolved',
                                    ),
                                    const SizedBox(width: 16),
                                    _StatBadge(
                                      label: 'Points',
                                      value: '$points',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _ProfileSection(
                                  icon: Icons.edit,
                                  title: 'Edit Profile',
                                  subtitle: 'Update your information',
                                  color: const Color(0xFF1A3C6E),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfilePage(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ProfileSection(
                                  icon: Icons.history,
                                  title: 'Complaint History',
                                  subtitle:
                                      '${complaints.length} complaints filed',
                                  color: const Color(0xFF2980B9),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ComplaintHistoryPage(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ProfileSection(
                                  icon: Icons.bar_chart,
                                  title: 'My Statistics',
                                  subtitle:
                                      '$resolved resolved out of ${complaints.length}',
                                  color: const Color(0xFF27AE60),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const UserStatsPage(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ProfileSection(
                                  icon: Icons.emoji_events,
                                  title: 'Achievements',
                                  subtitle: 'Badges and milestones',
                                  color: const Color(0xFFE8A020),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AchievementsPage(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ProfileSection(
                                  icon: Icons.settings,
                                  title: 'Settings',
                                  subtitle: 'Preferences and privacy',
                                  color: const Color(0xFF6B7280),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsPage(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                        (r) => false,
                                      );
                                    },
                                    icon: const Icon(Icons.logout),
                                    label: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE74C3C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label, value;
  const _StatBadge({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xCCFFFFFF)),
      ),
    ],
  );
}

class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ProfileSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        ],
      ),
    ),
  );
}
