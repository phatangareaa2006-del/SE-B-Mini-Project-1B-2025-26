import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatsPage extends StatelessWidget {
  const UserStatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3C6E),
        elevation: 0,
        title: const Text(
          'My Statistics',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: uid == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .where('userId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? [];
                final total = docs.length;
                final resolved = docs
                    .where((d) => d['status'] == 'Resolved')
                    .length;
                final inProgress = docs
                    .where((d) => d['status'] == 'In Progress')
                    .length;
                final pending = docs
                    .where((d) => d['status'] == 'Pending')
                    .length;
                final points = total * 10 + resolved * 5;

                // Avg resolution (mock: just show pending count for now)
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _statCard(
                        '📊',
                        'Total Complaints',
                        '$total',
                        'All time complaints filed',
                        const Color(0xFF1A3C6E),
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        '✅',
                        'Resolved',
                        '$resolved',
                        total > 0
                            ? '${((resolved / total) * 100).toStringAsFixed(0)}% resolution rate'
                            : '0% resolution rate',
                        const Color(0xFF27AE60),
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        '🔄',
                        'In Progress',
                        '$inProgress',
                        'Being worked on',
                        const Color(0xFF2980B9),
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        '⏳',
                        'Pending',
                        '$pending',
                        'Awaiting action',
                        const Color(0xFFE67E22),
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        '⭐',
                        'Civic Points',
                        '$points',
                        'Earned for civic engagement',
                        const Color(0xFFE8A020),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _statCard(
    String emoji,
    String title,
    String value,
    String subtitle,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
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
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
