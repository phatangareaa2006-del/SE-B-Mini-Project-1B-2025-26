import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      icon: Icons.directions_car_filled,
      color: AppTheme.primary,
      title: 'Find Your Dream Vehicle',
      subtitle: 'Browse 500+ verified cars and bikes for sale and rent — sedans, SUVs, electric, luxury and more.',
    ),
    _Slide(
      icon: Icons.calendar_month,
      color: AppTheme.accent,
      title: 'Book or Buy Instantly',
      subtitle: 'Rent by the hour or day with real-time availability. No conflicts — we block slots instantly when you book.',
    ),
    _Slide(
      icon: Icons.build_circle,
      color: AppTheme.success,
      title: 'Genuine Parts & Services',
      subtitle: 'Shop certified spare parts and book professional services with live slot availability.',
    ),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Background gradient
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _slides[_page].color.withOpacity(0.12),
                Colors.white,
              ],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),

        SafeArea(child: Column(children: [
          // Skip button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ),
          ),

          // Pages
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) => _SlideWidget(slide: _slides[i]),
            ),
          ),

          // Dots + button
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
            child: Column(children: [
              SmoothPageIndicator(
                controller: _ctrl,
                count: _slides.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: _slides[_page].color,
                  dotColor: AppTheme.border,
                  dotHeight: 8, dotWidth: 8, expansionFactor: 3,
                ),
              ),
              const SizedBox(height: 32),
              PrimaryBtn(
                label: _page == _slides.length - 1 ? 'Get Started 🚀' : 'Next',
                onTap: _next,
                color: _slides[_page].color,
              ),
            ]),
          ),
        ])),
      ]),
    );
  }
}

class _Slide {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _Slide({required this.icon, required this.color,
    required this.title, required this.subtitle});
}

class _SlideWidget extends StatelessWidget {
  final _Slide slide;
  const _SlideWidget({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 140, height: 140,
          decoration: BoxDecoration(
            color: slide.color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(slide.icon, size: 70, color: slide.color),
        ),
        const SizedBox(height: 40),
        Text(slide.title, style: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(slide.subtitle, style: const TextStyle(
            fontSize: 16, color: AppTheme.textSecondary, height: 1.6),
            textAlign: TextAlign.center),
      ]),
    );
  }
}