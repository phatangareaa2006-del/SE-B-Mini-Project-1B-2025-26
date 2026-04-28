import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shows a full-screen coffee brewing animation overlay for ~2 seconds,
/// then removes itself. Call [BrewAnimationOverlay.show] to trigger.
class BrewAnimationOverlay {
  static OverlayEntry? _currentEntry;

  static void show(BuildContext context) {
    // Don't stack multiple overlays
    if (_currentEntry != null) return;

    final overlay = Overlay.of(context);
    _currentEntry = OverlayEntry(
      builder: (_) => const _BrewOverlayWidget(),
    );

    overlay.insert(_currentEntry!);

    Future.delayed(const Duration(milliseconds: 2200), () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
  }
}

class _BrewOverlayWidget extends StatefulWidget {
  const _BrewOverlayWidget();

  @override
  State<_BrewOverlayWidget> createState() => _BrewOverlayWidgetState();
}

class _BrewOverlayWidgetState extends State<_BrewOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _brewCtrl;
  late AnimationController _exitCtrl;

  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _exitOpacity;

  // Steam wisps
  late List<_SteamWisp> _wisps;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _brewCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));

    _scaleAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut);
    _opacityAnim =
        Tween<double>(begin: 0, end: 1).animate(_entryCtrl);
    _exitOpacity =
        Tween<double>(begin: 1, end: 0).animate(_exitCtrl);

    _wisps = List.generate(
      3,
      (i) => _SteamWisp(
        vsync: this,
        delayMs: i * 200,
        dxOffset: (i - 1) * 18.0,
      ),
    );

    _entryCtrl.forward().then((_) {
      _brewCtrl.repeat();
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _brewCtrl.stop();
          _exitCtrl.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _brewCtrl.dispose();
    _exitCtrl.dispose();
    for (final w in _wisps) {
      w.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([_entryCtrl, _exitCtrl]),
      builder: (ctx, _) {
        final visible = _exitCtrl.isAnimating || !_exitCtrl.isCompleted;
        if (!visible && _exitCtrl.isCompleted) return const SizedBox.shrink();

        final opacity = _exitCtrl.isAnimating
            ? _exitOpacity.value
            : _opacityAnim.value;

        return Opacity(
          opacity: opacity,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 160,
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primary.withAlpha(80),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                    border: Border.all(
                      color: theme.primary.withAlpha(100),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Steam wisps area
                      SizedBox(
                        height: 60,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: _wisps
                              .map((w) => AnimatedBuilder(
                                    animation: w.controller,
                                    builder: (_, __) => Positioned(
                                      bottom: 0,
                                      left: 80 + w.dxOffset - 3,
                                      child: Opacity(
                                        opacity: w.opacityAnim.value,
                                        child: Transform.translate(
                                          offset: Offset(
                                            math.sin(w.controller.value *
                                                        math.pi *
                                                        2 +
                                                    w.dxOffset) *
                                                6,
                                            -w.riseAnim.value * 50,
                                          ),
                                          child: Container(
                                            width: 6,
                                            height: 6 +
                                                w.controller.value * 14,
                                            decoration: BoxDecoration(
                                              color: theme.primary
                                                  .withAlpha(120),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),

                      // Coffee Cup icon
                      AnimatedBuilder(
                        animation: _brewCtrl,
                        builder: (_, __) {
                          final wobble =
                              math.sin(_brewCtrl.value * math.pi * 4) * 2;
                          return Transform.rotate(
                            angle: wobble * math.pi / 180,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.coffee_rounded,
                                  size: 56,
                                  color: theme.primary,
                                ),
                                // Liquid fill shimmer
                                Positioned(
                                  bottom: 6,
                                  child: AnimatedBuilder(
                                    animation: _brewCtrl,
                                    builder: (_, __) => Container(
                                      width: 22,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: theme.primary.withAlpha(
                                          (math.sin(_brewCtrl.value *
                                                          math.pi *
                                                          2) *
                                                      100 +
                                                  100)
                                              .toInt(),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      // Label
                      Text(
                        'Brewing...',
                        style: TextStyle(
                          color: theme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Dot loader
                      AnimatedBuilder(
                        animation: _brewCtrl,
                        builder: (_, __) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (i) {
                            final phase = (_brewCtrl.value * 3 - i) % 1.0;
                            final size = 6.0 +
                                math.sin(phase * math.pi).clamp(0, 1) * 4;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 50),
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.primary.withAlpha(
                                    (100 +
                                            (math.sin(phase * math.pi)
                                                    .clamp(0, 1) *
                                                155))
                                        .toInt(),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SteamWisp {
  final AnimationController controller;
  final double dxOffset;
  late final Animation<double> riseAnim;
  late final Animation<double> opacityAnim;

  _SteamWisp({
    required TickerProvider vsync,
    required int delayMs,
    required this.dxOffset,
  }) : controller = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 900),
        ) {
    riseAnim = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.7), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.7), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0), weight: 20),
    ]).animate(controller);

    Future.delayed(Duration(milliseconds: delayMs), () {
      controller.repeat();
    });
  }

  void dispose() => controller.dispose();
}
