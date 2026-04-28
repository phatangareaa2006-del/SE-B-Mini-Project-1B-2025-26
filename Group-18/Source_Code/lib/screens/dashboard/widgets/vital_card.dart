import 'package:flutter/material.dart';
import '../../../../widgets/glass_card.dart';

class VitalCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<double> values;
  final String format; 
  final String unit;
  final String lastUpdated;
  final Color statusColor;

  const VitalCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.values,
    required this.format,
    required this.unit,
    required this.lastUpdated,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 28),
              PulsingDot(color: statusColor),
            ],
          ),
          const Spacer(),
          if (values.length == 1)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: values[0]),
              duration: const Duration(milliseconds: 800),
              builder: (context, val, child) {
                return Text(
                  val.toStringAsFixed(title == 'Temperature' || title == 'BMI' ? 1 : 0),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                );
              },
            )
          else 
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (context, val, child) {
                int v1 = (values[0] * val).toInt();
                int v2 = (values[1] * val).toInt();
                return Text(
                  "$v1 / $v2",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                );
              },
            ),
          
          Text(
            unit,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            "Updated: $lastUpdated",
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class PulsingDot extends StatefulWidget {
  final Color color;
  const PulsingDot({super.key, required this.color});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    int durationMs = widget.color == Colors.red ? 500 : 2000;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      int durationMs = widget.color == Colors.red ? 500 : 2000;
      _controller.duration = Duration(milliseconds: durationMs);
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_controller.value * 0.4),
          child: Opacity(
            opacity: 0.5 + (_controller.value * 0.5),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2 * _controller.value,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
