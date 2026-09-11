import 'dart:math';
import 'package:flutter/material.dart';
import '../config/liquid_glass_theme.dart';

/// Animated floating radial‑gradient orbs rendered behind all content.
///
/// Place this as the first child of a [Stack] in any full‑screen view.
/// The orbs slowly drift using a repeating [AnimationController].
class AnimatedOrbBackground extends StatefulWidget {
  const AnimatedOrbBackground({super.key});

  @override
  State<AnimatedOrbBackground> createState() => _AnimatedOrbBackgroundState();
}

class _AnimatedOrbBackgroundState extends State<AnimatedOrbBackground>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;
  late final AnimationController _ctrl3;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _ctrl2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat(reverse: true);

    _ctrl3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: Listenable.merge([_ctrl1, _ctrl2, _ctrl3]),
      builder: (ctx, _) {
        return Stack(
          children: [
            // Deep background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [LiquidGlass.bgDeep, LiquidGlass.bgMid, LiquidGlass.bgSurface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Orb 1 — purple, top-left drift
            _buildOrb(
              color: LiquidGlass.orbPurple,
              radius: size.width * 0.55,
              dx: Tween(begin: -0.15, end: 0.1).evaluate(_ctrl1) * size.width,
              dy: Tween(begin: -0.05, end: 0.15).evaluate(_ctrl1) * size.height,
              opacity: 0.28,
            ),

            // Orb 2 — cyan, bottom-right
            _buildOrb(
              color: LiquidGlass.orbCyan,
              radius: size.width * 0.45,
              dx: size.width - Tween(begin: 0.0, end: 0.2).evaluate(_ctrl2) * size.width * 0.6,
              dy: size.height - Tween(begin: 0.1, end: 0.35).evaluate(_ctrl2) * size.height,
              opacity: 0.18,
            ),

            // Orb 3 — violet, center-right
            _buildOrb(
              color: LiquidGlass.orbViolet,
              radius: size.width * 0.35,
              dx: size.width * (0.55 + sin(_ctrl3.value * pi) * 0.1),
              dy: size.height * (0.35 + cos(_ctrl3.value * pi) * 0.12),
              opacity: 0.22,
            ),

            // Subtle noise / grain overlay
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [
                      Colors.white.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrb({
    required Color color,
    required double radius,
    required double dx,
    required double dy,
    required double opacity,
  }) {
    return Positioned(
      left: dx - radius,
      top:  dy - radius,
      child: IgnorePointer(
        child: Container(
          width:  radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
