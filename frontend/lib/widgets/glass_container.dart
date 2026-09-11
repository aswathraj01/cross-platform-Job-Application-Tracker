import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/liquid_glass_theme.dart';

/// A reusable frosted‑glass panel.
///
/// Wraps [child] with ClipRRect → BackdropFilter (blur) → Container
/// so any widget can trivially gain the Apple Liquid Glass look.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final Color? fillColor;
  final Color? borderColor;
  final bool specularTop;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.blurSigma = LiquidGlass.glassBlurSigma,
    this.fillColor,
    this.borderColor,
    this.specularTop = true,
    this.shadows,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? LiquidGlass.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: LiquidGlass.glassDecoration(
              fillColor: fillColor,
              borderColor: borderColor,
              borderRadius: borderRadius,
              specularTop: specularTop,
              shadows: [],          // shadows live on outer Container
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
