import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Analytics & Reports',
            subtitle: 'Government performance monitoring and civic data insights for public',
          ),
          const SizedBox(height: 24),

          // ── KPI Cards ────────────────────────────────────────────────────
          LayoutBuilder(builder: (ctx, constraints) {
            final cross = constraints.maxWidth > 600 ? 3 : 1;
            return GridView.count(
              crossAxisCount: cross,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: cross == 3 ? 1.6 : 2.5,
              children: const [
                _KpiCard(
                  icon: '⏱️',
                  value: '4.2 days',
                  label: 'Avg. Resolution Time',
                  trend: '↓ 0.8 days vs last month',
                  trendGood: true,
                ),
                _KpiCard(
                  icon: '😊',
                  value: '78%',
                  label: 'Citizen Satisfaction',
                  trend: '↑ 3% vs last month',
                  trendGood: true,
                ),
                _KpiCard(
                  icon: '📬',
                  value: '94.2%',
                  label: 'Response Rate',
                  trend: '↑ 1.2% vs last month',
                  trendGood: true,
                ),
              ],
            );
          }),
          const SizedBox(height: 20),

          // ── Monthly Trend + Status Distribution ───────────────────────────
          LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(child: _MonthlyTrend()),
                  SizedBox(width: 16),
                  Expanded(child: _StatusDistribution()),
                ],
              );
            }
            return const Column(children: [
              _MonthlyTrend(),
              SizedBox(height: 16),
              _StatusDistribution(),
            ]);
          }),
          const SizedBox(height: 20),

          // ── Category Performance ──────────────────────────────────────────
          const _CategoryPerformance(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── KPI Card ─────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final String trend;
  final bool trendGood;

  const _KpiCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendGood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navyPrimary,
                  fontFamily: 'Georgia')),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          Text(trend,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: trendGood
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFE74C3C))),
        ],
      ),
    );
  }
}

// ─── Monthly Trend Bar Chart ──────────────────────────────────────────────────
class _MonthlyTrend extends StatelessWidget {
  const _MonthlyTrend();

  @override
  Widget build(BuildContext context) {
    final max = Analytics.monthly.reduce(math.max).toDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Complaint Trend',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia')),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: Analytics.monthly.asMap().entries.map((e) {
                final pct = e.value / max;
                final isLast = e.key == 11;
                final opacity = 0.3 + (e.key / 11) * 0.4;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${e.value}',
                            style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: pct,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isLast
                                    ? AppTheme.navyPrimary
                                    : AppTheme.navyPrimary
                                        .withOpacity(opacity),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(Analytics.months[e.key],
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Distribution ──────────────────────────────────────────────────────
class _StatusDistribution extends StatelessWidget {
  const _StatusDistribution();

  @override
  Widget build(BuildContext context) {
    const items = [
      {'label': 'Resolved', 'count': 876, 'color': Color(0xFF27AE60)},
      {'label': 'In Progress', 'count': 163, 'color': Color(0xFF2980B9)},
      {'label': 'Pending', 'count': 245, 'color': Color(0xFFE67E22)},
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Distribution',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia')),
          const SizedBox(height: 20),
          ...items.map((s) {
            final pct =
                ((s['count'] as int) / Analytics.total * 100).round();
            final color = s['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(s['label'] as String,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ]),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF1A1A2E)),
                          children: [
                            TextSpan(
                                text:
                                    '${(s['count'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: ' ($pct%)',
                                style: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: const Color(0xFFF0F2F5),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Category Performance (donut circles) ─────────────────────────────────────
class _CategoryPerformance extends StatelessWidget {
  const _CategoryPerformance();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category-wise Resolution Performance',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia')),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (ctx, constraints) {
            final cross = constraints.maxWidth > 500
                ? 6
                : constraints.maxWidth > 360
                    ? 3
                    : 2;
            return GridView.count(
              crossAxisCount: cross,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.8,
              children:
                  Analytics.byCategory.asMap().entries.map((entry) {
                final item = entry.value;
                final catObj = categories.firstWhere(
                    (c) =>
                        c.label.toLowerCase() ==
                        (item['category'] as String).toLowerCase(),
                    orElse: () => categories[entry.key % categories.length]);
                return _DonutCard(
                    item: item, catObj: catObj);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _DonutCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Category catObj;

  const _DonutCard({required this.item, required this.catObj});

  @override
  Widget build(BuildContext context) {
    final pct = item['pct'] as int;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF0F5), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(catObj.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(item['category'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          const SizedBox(height: 8),
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(54, 54),
                  painter:
                      _DonutPainter(pct: pct, color: catObj.color),
                ),
                Text('$pct%',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: catObj.color)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('${item['count']} total',
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9CA3AF))),
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
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = const Color(0xFFE2E8F0);

    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, bgPaint);
    canvas.drawArc(
        rect, -math.pi / 2, 2 * math.pi * (pct / 100), false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
