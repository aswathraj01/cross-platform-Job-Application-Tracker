import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job_model.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../config/liquid_glass_theme.dart';
import '../widgets/animated_orb_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/status_badge.dart';

/// Job detail screen with Apple Liquid Glass design.
class JobDetailScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late JobModel _job;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  Future<void> _updateStatus(JobStatus newStatus) async {
    final token = context.read<AuthProvider>().token;
    final success = await context.read<JobProvider>().updateJob(
          token,
          _job.id!,
          {'status': newStatus.value},
        );
    if (success && mounted) {
      setState(() {
        _job = _job.copyWith(status: newStatus);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.value}'),
          backgroundColor: LiquidGlass.bgSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: LiquidGlass.accentGreen.withValues(alpha: 0.4)),
          ),
        ),
      );
    }
  }

  Future<void> _deleteJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Job',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete this job entry for ${_job.company}?',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Center(
                          child: Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: LiquidGlass.accentRed.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LiquidGlass.accentRed.withValues(alpha: 0.4)),
                        ),
                        child: const Center(
                          child: Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final token = context.read<AuthProvider>().token;
      final success = await context.read<JobProvider>().deleteJob(token, _job.id!);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _openLink() async {
    if (_job.applicationLink != null && _job.applicationLink!.isNotEmpty) {
      final uri = Uri.parse(_job.applicationLink!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiquidGlass.bgDeep,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          ),
        ),
        title: Text(
          'Job Details',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _deleteJob,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 8, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: LiquidGlass.accentRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: LiquidGlass.accentRed.withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 18),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Card ──
                GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(24),
                  fillColor: LiquidGlass.accentPrimary.withValues(alpha: 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Company avatar
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              gradient: LiquidGlass.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: LiquidGlass.glowShadow(LiquidGlass.accentPrimary, blur: 18),
                            ),
                            child: Center(
                              child: Text(
                                _job.company.isNotEmpty ? _job.company[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _job.company,
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _job.role,
                                  style: TextStyle(
                                    color: LiquidGlass.accentPrimary.withValues(alpha: 0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          StatusBadge(status: _job.status, fontSize: 13),
                          const SizedBox(width: 8),
                          _buildSourceTag(_job.source),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Status Update ──
                _buildSection(
                  title: 'Update Status',
                  icon: Icons.swap_horiz_rounded,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: JobStatus.values.map((status) {
                      final isActive = _job.status == status;
                      return GestureDetector(
                        onTap: () => _updateStatus(status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isActive ? LiquidGlass.primaryGradient : null,
                            color: isActive ? null : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? LiquidGlass.accentPrimary
                                  : Colors.white.withValues(alpha: 0.1),
                            ),
                            boxShadow: isActive
                                ? LiquidGlass.glowShadow(LiquidGlass.accentPrimary, blur: 14)
                                : null,
                          ),
                          child: Text(
                            status.value,
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.55),
                              fontSize: 13,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Details ──
                _buildSection(
                  title: 'Details',
                  icon: Icons.info_outline,
                  child: Column(
                    children: [
                      if (_job.location != null && _job.location!.isNotEmpty)
                        _buildDetailRow(Icons.location_on_outlined, 'Location', _job.location!),
                      if (_job.appliedDate != null && _job.appliedDate!.isNotEmpty)
                        _buildDetailRow(Icons.calendar_today_outlined, 'Applied', _job.appliedDate!),
                      if (_job.applicationLink != null && _job.applicationLink!.isNotEmpty)
                        GestureDetector(
                          onTap: _openLink,
                          child: _buildDetailRow(Icons.link, 'Link', _job.applicationLink!, isLink: true),
                        ),
                      if (_job.createdAt != null)
                        _buildDetailRow(Icons.access_time, 'Tracked', _job.createdAt!.split('T').first),
                    ],
                  ),
                ),

                // ── Skills ──
                if (_job.skills.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Skills',
                    icon: Icons.code,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _job.skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: LiquidGlass.accentPrimary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: LiquidGlass.accentPrimary.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              color: LiquidGlass.accentPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // ── Notes ──
                if (_job.notes != null && _job.notes!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Notes',
                    icon: Icons.sticky_note_2_outlined,
                    child: Text(
                      _job.notes!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: LiquidGlass.accentPrimary, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.35), size: 16),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isLink ? LiquidGlass.accentPrimary : Colors.white,
                fontSize: 13,
                decoration: isLink ? TextDecoration.underline : null,
                decorationColor: LiquidGlass.accentPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceTag(JobSource source) {
    String emoji;
    String label;
    Color color;
    switch (source) {
      case JobSource.extension:
        emoji = '🧩'; label = 'Via Extension'; color = LiquidGlass.accentSecond;
        break;
      case JobSource.aiExtract:
        emoji = '✨'; label = 'AI Extracted';  color = LiquidGlass.accentAmber;
        break;
      case JobSource.manual:
        emoji = '✏️'; label = 'Manual';        color = Colors.white38;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
