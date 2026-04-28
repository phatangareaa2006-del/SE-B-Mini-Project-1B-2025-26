import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ============ COMPLAINT HISTORY PAGE ============
class ComplaintHistoryPage extends StatelessWidget {
  const ComplaintHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Complaint History'),
        backgroundColor: const Color(0xFF1A3C6E),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No complaints filed yet.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Complaint';
              final status = data['status'] ?? 'Pending';
              final displayId = data['displayId'] ?? 'CMP-XXXX';
              final date = data['formattedDate'] ?? '';
              final isResolved = status == 'Resolved';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              displayId,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A3C6E),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: displayId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tracking ID copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Color(0xFF1A3C6E),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A3C6E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.copy_rounded,
                                  size: 14,
                                  color: Color(0xFF1A3C6E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isResolved
                                ? const Color(0xFFD4EDDA)
                                : const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isResolved
                                  ? const Color(0xFF155724)
                                  : const Color(0xFF856404),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Filed: $date',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
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

// ============ USER STATS PAGE ============
class UserStatsPage extends StatelessWidget {
  const UserStatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('My Statistics'),
        backgroundColor: const Color(0xFF1A3C6E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatCard(
              'Total Complaints',
              '24',
              Icons.receipt_long,
              const Color(0xFF1A3C6E),
            ),
            _buildStatCard(
              'Resolved',
              '18',
              Icons.check_circle,
              const Color(0xFF27AE60),
            ),
            _buildStatCard(
              'In Progress',
              '4',
              Icons.hourglass_empty,
              const Color(0xFF2980B9),
            ),
            _buildStatCard(
              'Pending',
              '2',
              Icons.pending,
              const Color(0xFFE67E22),
            ),
            _buildStatCard(
              'Civic Points',
              '340',
              Icons.star,
              const Color(0xFFE8A020),
            ),
            _buildStatCard(
              'Upvotes Received',
              '127',
              Icons.thumb_up,
              const Color(0xFF8E44AD),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ ACHIEVEMENTS PAGE ============
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final achievements = [
      {
        'icon': '🏆',
        'title': 'First Complaint',
        'desc': 'Filed your first complaint',
        'unlocked': true,
      },
      {
        'icon': '⭐',
        'title': 'Active Citizen',
        'desc': 'Filed 10 complaints',
        'unlocked': true,
      },
      {
        'icon': '🎯',
        'title': 'Resolution Champion',
        'desc': 'Got 20 complaints resolved',
        'unlocked': true,
      },
      {
        'icon': '💎',
        'title': 'Community Hero',
        'desc': 'Received 100+ upvotes',
        'unlocked': false,
      },
      {
        'icon': '🔥',
        'title': 'Streak Master',
        'desc': 'Active for 30 consecutive days',
        'unlocked': false,
      },
      {
        'icon': '👑',
        'title': 'Civic Legend',
        'desc': 'Reached Level 10',
        'unlocked': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: const Color(0xFF1A3C6E),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final a = achievements[index];
          final unlocked = a['unlocked'] as bool;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: unlocked
                    ? const Color(0xFFE8A020)
                    : const Color(0xFFE2E8F0),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  a['icon'] as String,
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.black.withOpacity(unlocked ? 1.0 : 0.3),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  a['title'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: unlocked
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  a['desc'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============ SETTINGS PAGE ============
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotif = true;
  bool _emailNotif = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1A3C6E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'NOTIFICATIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildSwitch(
            'Push Notifications',
            'Receive complaint updates',
            _pushNotif,
            (v) => setState(() => _pushNotif = v),
          ),
          _buildSwitch(
            'Email Notifications',
            'Get updates via email',
            _emailNotif,
            (v) => setState(() => _emailNotif = v),
          ),
          const SizedBox(height: 24),
          const Text(
            'APPEARANCE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildSwitch(
            'Dark Mode',
            'Switch to dark theme',
            _darkMode,
            (v) => setState(() => _darkMode = v),
          ),
          const SizedBox(height: 24),
          const Text(
            'ACCOUNT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildOption('Change Password', Icons.lock_outline, () {}),
          _buildOption('Privacy Settings', Icons.privacy_tip_outlined, () {}),
          _buildOption('Terms & Conditions', Icons.description_outlined, () {}),
          _buildOption('Help & Support', Icons.help_outline, () {}),
        ],
      ),
    );
  }

  Widget _buildSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1A3C6E),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1A3C6E)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
