import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../config/liquid_glass_theme.dart';
import 'status_badge.dart';

/// Full Liquid Glass job card with scale animation and status glow.
class JobCard extends StatefulWidget {
  final JobModel job;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Color _statusGlowColor() {
    switch (widget.job.status) {
      case JobStatus.notApplied: return LiquidGlass.accentPrimary;
      case JobStatus.applied:    return LiquidGlass.accentBlue;
      case JobStatus.interview:  return LiquidGlass.accentAmber;
      case JobStatus.rejected:   return LiquidGlass.accentRed;
      case JobStatus.offer:      return LiquidGlass.accentGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = _statusGlowColor();

    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp:   (_) => _scaleCtrl.forward(),
      onTapCancel: () => _scaleCtrl.forward(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (ctx, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.20), width: 1.5),
                    left:   BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    right:  BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: Company + Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.company,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.job.role,
                                style: TextStyle(
                                  color: LiquidGlass.accentPrimary.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: widget.job.status),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Location + Date
                    Row(
                      children: [
                        if (widget.job.location != null && widget.job.location!.isNotEmpty) ...[
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              widget.job.location!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        if (widget.job.appliedDate != null && widget.job.appliedDate!.isNotEmpty) ...[
                          const Spacer(),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.job.appliedDate!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Skills + Source
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: widget.job.skills.isNotEmpty
                              ? Wrap(
                                  spacing: 5,
                                  runSpacing: 4,
                                  children: widget.job.skills.take(3).map((skill) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: LiquidGlass.accentPrimary.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: LiquidGlass.accentPrimary.withValues(alpha: 0.22),
                                        ),
                                      ),
                                      child: Text(
                                        skill,
                                        style: const TextStyle(
                                          color: LiquidGlass.accentPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : const SizedBox.shrink(),
                        ),
                        _buildSourceBadge(widget.job.source),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceBadge(JobSource source) {
    String emoji;
    Color color;
    switch (source) {
      case JobSource.extension:
        emoji = '🧩'; color = LiquidGlass.accentSecond;
        break;
      case JobSource.aiExtract:
        emoji = '✨'; color = LiquidGlass.accentAmber;
        break;
      case JobSource.manual:
        emoji = '✏️'; color = Colors.white38;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            source.displayLabel,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
