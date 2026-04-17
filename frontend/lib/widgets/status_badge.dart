import 'package:flutter/material.dart';
import '../models/job_model.dart';

/// Color-coded status badge widget.
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
      case JobStatus.notApplied:
        return const Color(0xFF6B7280);
      case JobStatus.applied:
        return const Color(0xFF3B82F6);
      case JobStatus.interview:
        return const Color(0xFFF59E0B);
      case JobStatus.rejected:
        return const Color(0xFFEF4444);
      case JobStatus.offer:
        return const Color(0xFF10B981);
    }
  }

  IconData _getIcon() {
    switch (status) {
      case JobStatus.notApplied:
        return Icons.schedule;
      case JobStatus.applied:
        return Icons.send;
      case JobStatus.interview:
        return Icons.people;
      case JobStatus.rejected:
        return Icons.close;
      case JobStatus.offer:
        return Icons.celebration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
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
            ),
          ),
        ],
      ),
    );
  }
}
