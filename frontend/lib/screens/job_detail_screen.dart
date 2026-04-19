import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job_model.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../widgets/status_badge.dart';

/// Screen for viewing and editing job details.
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
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _deleteJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Job', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this job entry for ${_job.company}?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
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
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Details',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _deleteJob,
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF).withValues(alpha: 0.2),
                    const Color(0xFF9D4EDD).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _job.company.isNotEmpty ? _job.company[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
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
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _job.role,
                              style: TextStyle(
                                color: const Color(0xFF6C63FF).withValues(alpha: 0.9),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StatusBadge(status: _job.status, fontSize: 14),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Status Update
            _buildSection(
              title: 'Update Status',
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
                        color: isActive
                            ? const Color(0xFF6C63FF)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF6C63FF)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        status.value,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Details
            _buildSection(
              title: 'Details',
              child: Column(
                children: [
                  if (_job.location != null && _job.location!.isNotEmpty)
                    _buildDetailRow(Icons.location_on_outlined, 'Location', _job.location!),
                  if (_job.appliedDate != null && _job.appliedDate!.isNotEmpty)
                    _buildDetailRow(Icons.calendar_today_outlined, 'Applied', _job.appliedDate!),
                  if (_job.applicationLink != null && _job.applicationLink!.isNotEmpty)
                    GestureDetector(
                      onTap: _openLink,
                      child: _buildDetailRow(
                        Icons.link,
                        'Link',
                        _job.applicationLink!,
                        isLink: true,
                      ),
                    ),
                  if (_job.createdAt != null)
                    _buildDetailRow(Icons.access_time, 'Tracked', _job.createdAt!.split('T').first),
                ],
              ),
            ),

            // Skills
            if (_job.skills.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                title: 'Skills',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _job.skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Notes
            if (_job.notes != null && _job.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                title: 'Notes',
                child: Text(
                  _job.notes!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isLink ? const Color(0xFF6C63FF) : Colors.white,
                fontSize: 13,
                decoration: isLink ? TextDecoration.underline : null,
                decorationColor: const Color(0xFF6C63FF),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
