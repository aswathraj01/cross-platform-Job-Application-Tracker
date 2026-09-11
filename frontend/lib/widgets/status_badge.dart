import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../config/liquid_glass_theme.dart';

/// Liquid Glass status badge with coloured glow border.
class StatusBadge extends StatelessWidget {
  final JobStatus status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  Color _getColor() {
    switch (status) {
      case JobStatus.notApplied: return const Color(0xFF94A3B8);
      case JobStatus.applied:    return LiquidGlass.accentBlue;
      case JobStatus.interview:  return LiquidGlass.accentAmber;
      case JobStatus.rejected:   return LiquidGlass.accentRed;
      case JobStatus.offer:      return LiquidGlass.accentGreen;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case JobStatus.notApplied: return Icons.schedule;
      case JobStatus.applied:    return Icons.send;
      case JobStatus.interview:  return Icons.people;
      case JobStatus.rejected:   return Icons.close;
      case JobStatus.offer:      return Icons.celebration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.20),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: fontSize, color: color),
          const SizedBox(width: 4),
          Text(
            status.value,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
