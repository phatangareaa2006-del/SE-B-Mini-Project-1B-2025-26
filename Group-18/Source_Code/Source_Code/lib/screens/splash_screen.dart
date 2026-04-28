import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import '../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ecgController;

  @override
  void initState() {
    super.initState();
    
    // Draw the ECG line over 2 seconds
    _ecgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    // After 3.5 seconds, evaluate auth and fade to next screen
    Timer(const Duration(milliseconds: 3500), _checkAuthAndNavigate);
  }

  void _checkAuthAndNavigate() {
    // Check if the user is already authenticated
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
       // Silently sync device notifications with Firestore state
       NotificationService().syncAlarmsToDevice(user.uid);
    }
    
    final targetScreen = user != null ? const DashboardScreen() : const LoginScreen();

    // Smooth page fade transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _ecgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF1D2B64),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Glowing pulsing heart
            const Icon(
              Icons.favorite,
              size: 90,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0xFF00FF88),
                  blurRadius: 30,
                  offset: Offset(0, 0),
                ),
              ],
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 800.ms,
              curve: Curves.easeInOut,
            ),
            
            const SizedBox(height: 40),
            
            // 2. Animated green ECG heartbeat line
            AnimatedBuilder(
              animation: _ecgController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(200, 60),
                  painter: EcgPainter(_ecgController.value),
                );
              },
            ),

            const SizedBox(height: 40),

            // 3. Typewriter "Health Monitor" Text
            SizedBox(
              height: 40,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Health Monitor',
                      speed: const Duration(milliseconds: 100),
                      cursor: '|',
                    ),
                  ],
                  isRepeatingAnimation: false,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 4. Delayed Tagline
            const Text(
              "Your personal health companion",
              style: TextStyle(
                color: Color(0xFFD3D3D3), // Light grey
                fontSize: 14,
              ),
            )
            .animate(delay: 1500.ms)
            .fadeIn(duration: 800.ms, curve: Curves.easeIn)
            .slideY(begin: 0.5, end: 0, duration: 800.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}

class EcgPainter extends CustomPainter {
  final double progress;
  EcgPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = const Color(0xFF00FF88)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 0.2, size.height / 2);
    path.lineTo(size.width * 0.3, size.height * 0.2); // sharp spike up
    path.lineTo(size.width * 0.4, size.height * 0.9); // sharp dive down
    path.lineTo(size.width * 0.5, size.height * 0.1); // highest peak
    path.lineTo(size.width * 0.6, size.height * 0.7); // secondary drop
    path.lineTo(size.width * 0.7, size.height / 2);   // recover to baseline
    path.lineTo(size.width, size.height / 2);

    for (final metric in path.computeMetrics()) {
      final extractPath = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(EcgPainter oldDelegate) => oldDelegate.progress != progress;
}
