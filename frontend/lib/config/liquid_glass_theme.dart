import 'package:flutter/material.dart';

/// Apple Liquid Glass design system — single source of truth for all
/// colors, blur values, gradients, and shared decoration factories.
abstract class LiquidGlass {
  // ─── Background ──────────────────────────────────────────────────────────
  static const Color bgDeep    = Color(0xFF05071A);
  static const Color bgMid     = Color(0xFF0A0E28);
  static const Color bgSurface = Color(0xFF0D1230);

  // ─── Orb / glow colours ──────────────────────────────────────────────────
  static const Color orbPurple = Color(0xFF6C63FF);
  static const Color orbViolet = Color(0xFF9D4EDD);
  static const Color orbCyan   = Color(0xFF22D3EE);
  static const Color orbIndigo = Color(0xFF4F46E5);

  // ─── Glass surface ───────────────────────────────────────────────────────
  static const Color glassFill          = Color(0x0FFFFFFF); // 6% white
  static const Color glassFillMed       = Color(0x18FFFFFF); // ~9% white
  static const Color glassBorder        = Color(0x14FFFFFF); // 8% white
  static const Color glassSpecular      = Color(0x28FFFFFF); // 16% white — top edge
  static const double glassBlurSigma    = 20.0;
  static const double glassBlurSigmaSm  = 12.0;

  // ─── Accents ─────────────────────────────────────────────────────────────
  static const Color accentPrimary  = Color(0xFF6C63FF);
  static const Color accentSecond   = Color(0xFF9D4EDD);
  static const Color accentGreen    = Color(0xFF10B981);
  static const Color accentAmber    = Color(0xFFF59E0B);
  static const Color accentBlue     = Color(0xFF3B82F6);
  static const Color accentRed      = Color(0xFFEF4444);

  // ─── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPrimary, accentSecond],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get backgroundGradient => const LinearGradient(
    colors: [bgDeep, bgMid, bgSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Glow shadows ────────────────────────────────────────────────────────
  static List<BoxShadow> glowShadow(Color color, {double intensity = 0.45, double blur = 24}) =>
    [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: blur,
        spreadRadius: -4,
      ),
    ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: accentPrimary.withValues(alpha: 0.06),
      blurRadius: 32,
      spreadRadius: -8,
    ),
  ];

  // ─── Decoration factories ─────────────────────────────────────────────────

  /// Standard glass panel decoration (no blur — use with GlassContainer).
  static BoxDecoration glassDecoration({
    Color? fillColor,
    Color? borderColor,
    double borderRadius = 20,
    bool specularTop = true,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: fillColor ?? glassFill,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border(
        top: BorderSide(
          color: specularTop ? glassSpecular : (borderColor ?? glassBorder),
          width: specularTop ? 1.5 : 1.0,
        ),
        left:   BorderSide(color: borderColor ?? glassBorder),
        right:  BorderSide(color: borderColor ?? glassBorder),
        bottom: BorderSide(color: borderColor ?? glassBorder),
      ),
      boxShadow: shadows ?? cardShadow,
    );
  }

  /// Decoration for a glowing primary button (filled gradient + glow).
  static BoxDecoration glowButtonDecoration({double borderRadius = 14}) {
    return BoxDecoration(
      gradient: primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: glowShadow(accentPrimary, blur: 20),
    );
  }

  /// Input field decoration — frosted glass.
  static InputDecoration glassInputDecoration({
    required String hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentRed, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );
  }
}
