import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBubbleBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBubbleBackground({super.key, required this.child});

  @override
  State<AnimatedBubbleBackground> createState() => _AnimatedBubbleBackgroundState();
}

class _AnimatedBubbleBackgroundState extends State<AnimatedBubbleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bubbles.isEmpty) {
      final size = MediaQuery.of(context).size;
      final random = Random();
      for (int i = 0; i < 15; i++) {
        _bubbles.add(Bubble(
          x: random.nextDouble() * size.width,
          y: random.nextDouble() * size.height,
          size: random.nextDouble() * 100 + 50,
          speed: random.nextDouble() * 0.5 + 0.2,
          color: Colors.blueAccent.withOpacity(random.nextDouble() * 0.1 + 0.05),
        ));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0E21), Color(0xFF1D2B64)],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: BubblePainter(bubbles: _bubbles, animationValue: _controller.value),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class Bubble {
  double x;
  double y;
  double size;
  double speed;
  Color color;
  Bubble({required this.x, required this.y, required this.size, required this.speed, required this.color});
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double animationValue;

  BubblePainter({required this.bubbles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      double newY = bubble.y - (animationValue * size.height * bubble.speed);
      double offset = sin((animationValue * pi * 2) + bubble.x) * 30;

      newY = newY % size.height;
      if (newY < -bubble.size) {
        newY = size.height + bubble.size;
      }

      final paint = Paint()
        ..color = bubble.color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawCircle(Offset(bubble.x + offset, newY), bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) => true;
}
