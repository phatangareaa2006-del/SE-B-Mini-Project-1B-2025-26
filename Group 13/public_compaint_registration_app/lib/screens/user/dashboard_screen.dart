import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint_model.dart';
import '../../services/firebase_service.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabChange;
  const DashboardScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final uid = auth.user?.uid ?? '';

    return StreamBuilder<List<ComplaintModel>>(
      stream: FirebaseService().userComplaintsStream(uid),
      builder: (ctx, snap) {
        final complaints = snap.data ?? [];
        final total = complaints.length;
        final resolved =
            complaints.where((c) => c.status == 'Resolved').length;
        final inProgress =
            complaints.where((c) => c.status == 'In Progress').length;
        final pending =
            complaints.where((c) => c.status == 'Pending').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                      Text(
                        auth.displayName.isNotEmpty
                            ? auth.displayName
                            : 'Citizen',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Georgia',
                            color: Color(0xFF1A1A2E)),
                      ),
                    ],
                  ),
                ),
                const Text('🏛️', style: TextStyle(fontSize: 32)),
              ]),
              const SizedBox(height: 4),
              const Text(
                  'Overview of civic complaints and municipal performance',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              const SizedBox(height: 20),

              // ── Stats Grid ─────────────────────────────────────────────
              if (!snap.hasData)
                const _StatsSkeletonGrid()
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.65,
                  children: [
                    _StatCard(
                        label: 'Total Complaints',
                        value: '$total',
                        icon: '📋',
                        color: AppTheme.navyPrimary,
                        sub: total == 0
                            ? 'No complaints yet'
                            : 'All filed complaints'),
                    _StatCard(
                        label: 'Resolved',
                        value: '$resolved',
                        icon: '✅',
                        color: const Color(0xFF27AE60),
                        sub: total > 0
                            ? '${(resolved / total * 100).round()}% resolved'
                            : '—'),
                    _StatCard(
                        label: 'In Progress',
                        value: '$inProgress',
                        icon: '⚙️',
                        color: const Color(0xFF2980B9),
                        sub: 'Being handled'),
                    _StatCard(
                        label: 'Pending',
                        value: '$pending',
                        icon: '⏳',
                        color: const Color(0xFFE67E22),
                        sub: pending > 0
                            ? 'Needs attention'
                            : 'All clear!'),
                  ],
                ),
              const SizedBox(height: 18),

              // ── Community complaints ──────────────────────────────────
              StreamBuilder<List<ComplaintModel>>(
                stream: FirebaseService().complaintsStream(),
                builder: (ctx, tSnap) {
                  if (!tSnap.hasData || tSnap.data!.isEmpty) return const SizedBox.shrink();
                  final allC = tSnap.data!.take(4).toList();
                  return Column(
                    children: [
                      _SectionCard(
                        title: 'All Complaints in Area',
                        action: 'View All →',
                        onAction: () => onTabChange(3),
                        child: Column(
                          children: allC.map((c) {
                            final cat = getCategoryById(c.category);
                            final bool hasUpvoted = c.upvotedBy.contains(uid);
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFFF0F2F5))),
                              ),
                              child: Row(children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: cat.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 18))),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                                      Text('${c.displayId} · ${c.formattedDate}',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => FirebaseService().toggleUpvote(c.docId, uid),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: hasUpvoted ? AppTheme.navyPrimary : AppTheme.navyPrimary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_upward, size: 12, color: hasUpvoted ? Colors.white : AppTheme.navyPrimary),
                                        const SizedBox(width: 4),
                                        Text('${c.upvotes}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: hasUpvoted ? Colors.white : AppTheme.navyPrimary)),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                },
              ),

              // ── Recent & Dept Layout ──
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 700) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _SectionCard(
                title: 'Your Recent Complaints',
                action: 'View All →',
                onAction: () => onTabChange(3),
                child: complaints.isEmpty
                    ? _EmptyState(
                        icon: '📭',
                        message: 'No complaints yet',
                        sub: 'Be the first to file one!',
                        onAction: () => onTabChange(1),
                        actionLabel: '+ File Complaint')
                    : Column(
                        children: complaints.take(4).map((c) {
                          final cat = getCategoryById(c.category);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Color(0xFFF0F2F5))),
                            ),
                            child: Row(children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: cat.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                    child: Text(cat.icon,
                                        style: const TextStyle(
                                            fontSize: 18))),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(c.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A1A2E))),
                                    Text(
                                        '${c.displayId} · ${c.formattedDate}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF9CA3AF))),
                                  ],
                                ),
                              ),
                              _StatusBadge(status: c.status),
                            ]),
                          );
                        }).toList(),
                      ),
              ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _DeptPerformanceCard(complaints: complaints),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        _SectionCard(
                title: 'Your Recent Complaints',
                action: 'View All →',
                onAction: () => onTabChange(3),
                child: complaints.isEmpty
                    ? _EmptyState(
                        icon: '📭',
                        message: 'No complaints yet',
                        sub: 'Be the first to file one!',
                        onAction: () => onTabChange(1),
                        actionLabel: '+ File Complaint')
                    : Column(
                        children: complaints.take(4).map((c) {
                          final cat = getCategoryById(c.category);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Color(0xFFF0F2F5))),
                            ),
                            child: Row(children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: cat.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                    child: Text(cat.icon,
                                        style: const TextStyle(
                                            fontSize: 18))),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(c.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A1A2E))),
                                    Text(
                                        '${c.displayId} · ${c.formattedDate}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF9CA3AF))),
                                  ],
                                ),
                              ),
                              _StatusBadge(status: c.status),
                            ]),
                          );
                        }).toList(),
                      ),
              ),
                        const SizedBox(height: 14),
                        _DeptPerformanceCard(complaints: complaints),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 14),
              // ── Quick actions ──────────────────────────────────────────
              _SectionCard(
                title: 'Quick Actions',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QuickChip(
                        icon: '🔍',
                        label: 'Track Status',
                        onTap: () => onTabChange(2)),
                    _QuickChip(
                        icon: '📋',
                        label: 'All Complaints',
                        onTap: () => onTabChange(3)),
                    _QuickChip(
                        icon: '📈',
                        label: 'Analytics',
                        onTap: () => onTabChange(4)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// ─── Dept performance (dynamic from complaints) ───────────────────────────────
class _DeptPerformanceCard extends StatelessWidget {
  final List<ComplaintModel> complaints;
  const _DeptPerformanceCard({required this.complaints});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> total = {};
    final Map<String, int> resolved = {};

    for (final c in complaints) {
      total[c.category] = (total[c.category] ?? 0) + 1;
      if (c.status == 'Resolved') {
        resolved[c.category] = (resolved[c.category] ?? 0) + 1;
      }
    }

    final categories = total.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _SectionCard(
      title: 'Department Performance',
      child: categories.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No data yet — performance updates as complaints are resolved.',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF))),
            )
          : Column(
              children: categories.take(6).map((e) {
                final cat = getCategoryById(e.key);
                final tot = e.value;
                final res = resolved[e.key] ?? 0;
                final pct = tot > 0 ? (res / tot * 100).round() : 0;
                final color = pct >= 80
                    ? const Color(0xFF27AE60)
                    : pct >= 60
                        ? const Color(0xFFE67E22)
                        : const Color(0xFFE74C3C);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(children: [
                    Row(children: [
                      Text(cat.icon,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(cat.label,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151)))),
                      Text('$pct%',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ]),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: const Color(0xFFE8EDF5),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 7,
                      ),
                    ),
                  ]),
                );
              }).toList(),
            ),
    );
  }
}

// ─── Reusable stat card ───────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;
  final String sub;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500)),
              ),
              Text(icon, style: const TextStyle(fontSize: 20)),
            ],
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Georgia',
                  height: 1)),
          Text(sub,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 0.6,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSkeletonGrid extends StatelessWidget {
  const _StatsSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: List.generate(
          4,
          (_) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )),
    );
  }
}

// ─── Section card wrapper ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.action,
    this.onAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia',
                      color: Color(0xFF1A1A2E))),
              if (action != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF0F4FF),
                    foregroundColor: AppTheme.navyPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(action!,
                      style: const TextStyle(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String icon;
  final String message;
  final String sub;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.sub,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF))),
            const SizedBox(height: 4),
            Text(sub,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF))),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(actionLabel!,
                    style: const TextStyle(fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Quick action chip ────────────────────────────────────────────────────────
class _QuickChip extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _QuickChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FD),
          border: Border.all(
              color: const Color(0xFFE2E8F0), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.navyPrimary)),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable status badge ────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final sc = kStatusColors[status] ?? kStatusColors['Pending']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: sc.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: sc.dot, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(status,
            style: TextStyle(
                color: sc.text,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
