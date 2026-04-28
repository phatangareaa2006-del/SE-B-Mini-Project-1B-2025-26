import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/complaint_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseService().analyticsStream(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snap.data!;
        final total = data['total'] as int;
        final resolved = data['resolved'] as int;
        final inProgress = data['inProgress'] as int;
        final pending = data['pending'] as int;
        final byCategory =
            List<Map<String, dynamic>>.from(data['byCategory'] as List);
        final monthly =
            List<int>.from(data['monthly'] as List);
        const monthLabels = [
          'J','F','M','A','M','J','J','A','S','O','N','D'
        ];
        final satisfaction = data['satisfaction'] as int;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Analytics & Reports',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia',
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              const Text(
                  'Government performance monitoring and civic data insights',
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              const SizedBox(height: 18),

              // ── No data state ────────────────────────────────────────
              if (total == 0) ...[
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Text('📊', style: TextStyle(fontSize: 44)),
                        SizedBox(height: 12),
                        Text('No data yet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9CA3AF))),
                        SizedBox(height: 4),
                        Text(
                            'Analytics will appear here once complaints are filed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // ── KPI cards ────────────────────────────────────────────
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _KpiCard(
                        icon: '⏱️',
                        value:
                            '${data['avgResolutionDays']} days',
                        label: 'Avg. Resolution',
                        sub: 'Time to resolve',
                        color: AppTheme.navyPrimary),
                    _KpiCard(
                        icon: '😊',
                        value: '$satisfaction%',
                        label: 'Satisfaction',
                        sub: 'Resolved / Total',
                        color: const Color(0xFF27AE60)),
                    _KpiCard(
                        icon: '📬',
                        value: total > 0
                            ? '${((resolved + inProgress) / total * 100).round()}%'
                            : '—',
                        label: 'Response Rate',
                        sub: 'Handled complaints',
                        color: const Color(0xFF2980B9)),
                    _KpiCard(
                        icon: '⚡',
                        value: '$inProgress',
                        label: 'Active Now',
                        sub: 'In progress',
                        color: const Color(0xFFE67E22)),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Monthly trend ─────────────────────────────────────────
                _ChartCard(
                  title: 'Monthly Complaint Trend',
                  child: _MonthlyBar(
                      monthly: monthly, labels: monthLabels),
                ),
                const SizedBox(height: 14),

                // ── Status distribution ───────────────────────────────────
                _ChartCard(
                  title: 'Status Distribution',
                  child: Column(
                    children: [
                      _DistBar(
                          label: 'Resolved',
                          count: resolved,
                          total: total,
                          color: const Color(0xFF27AE60)),
                      const SizedBox(height: 12),
                      _DistBar(
                          label: 'In Progress',
                          count: inProgress,
                          total: total,
                          color: const Color(0xFF2980B9)),
                      const SizedBox(height: 12),
                      _DistBar(
                          label: 'Pending',
                          count: pending,
                          total: total,
                          color: const Color(0xFFE67E22)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Category donut chart ──────────────────────────────────
                if (byCategory.isNotEmpty)
                  _ChartCard(
                    title: 'Category-wise Resolution',
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                      children: byCategory.map((item) {
                        final cat =
                            getCategoryById(item['id'] as String);
                        final pct = item['pct'] as int;
                        return _DonutCell(cat: cat, pct: pct, count: item['count'] as int);
                      }).toList(),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// ─── KPI card ─────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final String sub;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.sub,
    required this.color,
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
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Georgia')),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          Text(sub,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

// ─── Chart card wrapper ───────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

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
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia')),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Monthly bar chart ────────────────────────────────────────────────────────
class _MonthlyBar extends StatelessWidget {
  final List<int> monthly;
  final List<String> labels;
  const _MonthlyBar({required this.monthly, required this.labels});

  @override
  Widget build(BuildContext context) {
    final max = monthly.isEmpty
        ? 1
        : monthly.reduce(math.max).toDouble();

    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthly.asMap().entries.map((e) {
          final pct = max > 0 ? e.value / max : 0.0;
          final isLatest = e.key ==
              monthly.lastIndexWhere((v) => v > 0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (e.value > 0)
                    Text('${e.value}',
                        style: const TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF))),
                  const SizedBox(height: 2),
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: pct.toDouble(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLatest
                              ? AppTheme.navyPrimary
                              : AppTheme.navyPrimary
                                  .withOpacity(0.35 + pct * 0.45),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[e.key],
                      style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Distribution bar ─────────────────────────────────────────────────────────
class _DistBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  const _DistBar(
      {required this.label,
      required this.count,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                  width: 9,
                  height: 9,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
            Text('$count  ($pct%)',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E))),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: const Color(0xFFF0F2F5),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 11,
          ),
        ),
      ],
    );
  }
}

// ─── Donut cell ───────────────────────────────────────────────────────────────
class _DonutCell extends StatelessWidget {
  final CategoryMeta cat;
  final int pct;
  final int count;
  const _DonutCell(
      {required this.cat, required this.pct, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF0F5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(cat.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(cat.label.split(' ').first,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          const SizedBox(height: 6),
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(50, 50),
                  painter: _DonutPainter(pct: pct, color: cat.color),
                ),
                Text('$pct%',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cat.color)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('$count total',
              style: const TextStyle(
                  fontSize: 9, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int pct;
  final Color color;
  _DonutPainter({required this.pct, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(4, 4, size.width - 8, size.height - 8);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = const Color(0xFFE2E8F0);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, bg);
    canvas.drawArc(
        rect, -math.pi / 2, 2 * math.pi * (pct / 100), false, fg);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
