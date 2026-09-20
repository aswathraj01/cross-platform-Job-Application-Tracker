import 'package:flutter/material.dart';

/// Branded page-transition helpers for Job Tracker.
///
/// Usage:
///   Navigator.push(context, AppRoutes.fadeSlide(const SomeScreen()));
///   Navigator.push(context, AppRoutes.slideUp(const SomeScreen()));
abstract class AppRoutes {
  // ── Duration constants ────────────────────────────────────────────────────
  static const Duration _fast   = Duration(milliseconds: 280);
  static const Duration _normal = Duration(milliseconds: 380);

  // ── Curves ───────────────────────────────────────────────────────────────
  static const Curve _easeOut  = Curves.easeOutCubic;
  static const Curve _easeIn   = Curves.easeInCubic;

  /// Fade + subtle slide-up. Used for most push navigations
  /// (e.g. Login → Dashboard, Dashboard → AddJob).
  static Route<T> fadeSlide<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: _normal,
      reverseTransitionDuration: _fast,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        // Incoming: fade in + slide up from 4%
        final fadeIn = CurvedAnimation(parent: animation, curve: _easeOut);
        final slideIn = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: _easeOut));

        // Outgoing: scale down slightly + fade out
        final fadeOut = Tween<double>(begin: 1.0, end: 0.92).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: _easeIn),
        );

        return FadeTransition(
          opacity: fadeOut,
          child: SlideTransition(
            position: slideIn,
            child: FadeTransition(opacity: fadeIn, child: child),
          ),
        );
      },
    );
  }

  /// Horizontal slide — sibling screens (Login ↔ Signup).
  /// [forward] = true → slide in from right; false → slide in from left.
  static Route<T> slideHorizontal<T>(Widget page, {bool forward = true}) {
    final dir = forward ? 1.0 : -1.0;
    return PageRouteBuilder<T>(
      transitionDuration: _normal,
      reverseTransitionDuration: _fast,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final slideIn = Tween<Offset>(
          begin: Offset(dir, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: _easeOut));

        final slideOut = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(-dir * 0.3, 0),
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: _easeIn));

        final fadeIn = CurvedAnimation(parent: animation, curve: _easeOut);

        return SlideTransition(
          position: slideOut,
          child: SlideTransition(
            position: slideIn,
            child: FadeTransition(opacity: fadeIn, child: child),
          ),
        );
      },
    );
  }

  /// Full-screen slide-up with scale — used for modal-like screens
  /// (JobDetail, AiChat, AiExtract).
  static Route<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: _normal,
      reverseTransitionDuration: _fast,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final slideIn = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: _easeOut));

        final fadeIn = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        );

        // Background screen scales down slightly
        final scaleOut = Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: _easeIn),
        );

        return ScaleTransition(
          scale: scaleOut,
          child: SlideTransition(
            position: slideIn,
            child: FadeTransition(opacity: fadeIn, child: child),
          ),
        );
      },
    );
  }
}
