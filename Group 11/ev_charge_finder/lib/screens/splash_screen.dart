import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF388E3C)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            const Spacer(flex: 2),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(scale: _scaleAnim, child: child),
              ),
              child: Column(children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    Icon(Icons.location_on,
                        color: AppColors.primary.withOpacity(0.15), size: 80),
                    const Icon(Icons.ev_station,
                        color: AppColors.primary, size: 48),
                  ]),
                ),
                const SizedBox(height: 28),
                const Text('EV Charge Finder',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text('Charge smarter. Drive further.',
                    style: TextStyle(fontSize: 16,
                        color: Colors.white.withOpacity(0.8))),
              ]),
            ),
            const Spacer(flex: 2),
            Column(children: [
              SizedBox(width: 28, height: 28,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 12),
              Text('Finding stations near you...',
                  style: TextStyle(fontSize: 13,
                      color: Colors.white.withOpacity(0.65))),
              const SizedBox(height: 40),
            ]),
          ]),
        ),
      ),
    );
  }
}