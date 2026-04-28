import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final List<Complaint> complaints;
  final Function(int) onTabChange;

  const DashboardScreen(
      {super.key, required this.complaints, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Citizen Dashboard',
            subtitle: 'Overview of civic complaints and municipal performance',
          ),
          const SizedBox(height: 24),

          // ── Stats Grid ───────────────────────────────────────────────────
          _StatsGrid(),
          const SizedBox(height: 20),

          // ── Recent Complaints + Dept Performance ─────────────────────────
          LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _RecentComplaints(
                          complaints: complaints,
                          onViewAll: () => onTabChange(3))),
                  const SizedBox(width: 16),
                  Expanded(child: _DeptPerformance()),
                ],
              );
            }
            return Column(
              children: [
                _RecentComplaints(
                    complaints: complaints,
                    onViewAll: () => onTabChange(3)),
                const SizedBox(height: 16),
                _DeptPerformance(),
              ],
            );
          }),
          const SizedBox(height: 20),

          // ── Quick Actions ────────────────────────────────────────────────
          _QuickActions(onTabChange: onTabChange),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Stats Grid ──────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final stats = const [
    {
      'label': 'Total Complaints',
      'value': '1,284',
      'icon': '📋',
      'color': AppTheme.navyPrimary,
      'sub': '+24 this week'
    },
    {
      'label': 'Resolved',
      'value': '876',
      'icon': '✅',
      'color': Color(0xFF27AE60),
      'sub': '68% resolution rate'
    },
    {
      'label': 'In Progress',
      'value': '163',
      'icon': '⚙️',
      'color': Color(0xFF2980B9),
      'sub': 'Avg 4.2 days'
    },
    {
      'label': 'Pending',
      'value': '245',
      'icon': '⏳',
      'color': Color(0xFFE67E22),
      'sub': 'Needs attention'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final cross = constraints.maxWidth > 600 ? 4 : 2;
      return GridView.count(
        crossAxisCount: cross,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: cross == 4 ? 1.35 : 1.6,
        children: stats.map((s) => _StatCard(stat: s)).toList(),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final Map<String, dynamic> stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final color = stat['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(stat['label'] as String,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500)),
              ),
              Text(stat['icon'] as String,
                  style: const TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 8),
          Text(stat['value'] as String,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1,
                  fontFamily: 'Georgia')),
          const SizedBox(height: 6),
          Text(stat['sub'] as String,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 0.65,
              backgroundColor: color.withOpacity(0.13),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent Complaints ────────────────────────────────────────────────────────
class _RecentComplaints extends StatelessWidget {
  final List<Complaint> complaints;
  final VoidCallback onViewAll;

  const _RecentComplaints(
      {required this.complaints, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Complaints',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia')),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F4FF),
                  foregroundColor: AppTheme.navyPrimary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View All →',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...complaints.take(4).map((c) {
            final cat = getCategoryById(c.category);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFFF0F2F5))),
              ),
              child: Row(
                children: [
                  CategoryIconBox(cat: cat),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E))),
                        Text('${c.id} · ${c.date}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: c.status),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Dept Performance ────────────────────────────────────────────────────────
class _DeptPerformance extends StatelessWidget {
  Color _barColor(int pct) {
    if (pct >= 80) return const Color(0xFF27AE60);
    if (pct >= 60) return const Color(0xFFE67E22);
    return const Color(0xFFE74C3C);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Department Performance',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia')),
          const SizedBox(height: 16),
          ...Analytics.byCategory.map((item) {
            final pct = item['pct'] as int;
            final color = _barColor(pct);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['category'] as String,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151))),
                      Text('$pct%',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  MiniProgressBar(pct: pct.toDouble(), color: color),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final Function(int) onTabChange;
  const _QuickActions({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'label': 'File New Complaint', 'icon': '✏️', 'tab': 1},
      {'label': 'Track My Complaint', 'icon': '🔍', 'tab': 2},
      {'label': 'View Analytics', 'icon': '📈', 'tab': 4},
      {'label': 'All Complaints', 'icon': '📋', 'tab': 3},
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia')),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: actions.map((a) {
              return _QuickActionChip(
                label: a['label'] as String,
                icon: a['icon'] as String,
                onTap: () => onTabChange(a['tab'] as int),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatefulWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _QuickActionChip(
      {required this.label, required this.icon, required this.onTap});

  @override
  State<_QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<_QuickActionChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered
                ? AppTheme.navyPrimary
                : const Color(0xFFF8F9FD),
            border: Border.all(
                color: _hovered
                    ? AppTheme.navyPrimary
                    : const Color(0xFFE2E8F0),
                width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.icon,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _hovered
                          ? Colors.white
                          : AppTheme.navyPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
