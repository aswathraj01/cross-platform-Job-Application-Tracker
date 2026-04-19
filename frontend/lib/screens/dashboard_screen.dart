import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/search_filter_bar.dart';
import 'login_screen.dart';
import 'add_job_screen.dart';
import 'job_detail_screen.dart';
import 'ai_extract_screen.dart';
import '../widgets/ad_banner.dart';

/// Dashboard screen showing analytics and job list.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs();
    });
  }

  void _loadJobs() {
    final token = context.read<AuthProvider>().token;
    context.read<JobProvider>().fetchJobs(token);
  }

  void _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // AI Extract button
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiExtractScreen()),
              );
              _loadJobs();
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9D4EDD)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            tooltip: 'AI Extract',
          ),
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout, color: Colors.white.withValues(alpha: 0.7)),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (ctx, jobProvider, _) {
          return RefreshIndicator(
            onRefresh: () async => _loadJobs(),
            color: const Color(0xFF6C63FF),
            backgroundColor: const Color(0xFF16213E),
            child: CustomScrollView(
              slivers: [
                // Analytics Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Cards Row
                        _buildStatsRow(jobProvider),
                        const SizedBox(height: 16),

                        // Chart Card
                        Container(
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
                                'Application Overview',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AnalyticsChart(statusCounts: jobProvider.statusCounts),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Success rate card
                        if (jobProvider.totalJobs > 0)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6C63FF).withValues(alpha: 0.2),
                                  const Color(0xFF9D4EDD).withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.trending_up, color: Color(0xFF6C63FF), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Interview Rate: ${jobProvider.interviewRate.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Offer Rate: ${jobProvider.successRate.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Search & Filter
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'My Applications',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SearchFilterBar(
                        searchQuery: jobProvider.searchQuery,
                        statusFilter: jobProvider.statusFilter,
                        onSearchChanged: jobProvider.setSearchQuery,
                        onStatusChanged: jobProvider.setStatusFilter,
                        onClearFilters: jobProvider.clearFilters,
                      ),
                    ],
                  ),
                ),

                // Job List
                if (jobProvider.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    ),
                  )
                else if (jobProvider.jobs.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_off_outlined,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No jobs tracked yet',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first job application!',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = jobProvider.jobs[index];
                        return JobCard(
                          job: job,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailScreen(job: job),
                              ),
                            );
                            _loadJobs();
                          },
                        );
                      },
                      childCount: jobProvider.jobs.length,
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddJobScreen()),
          );
          _loadJobs();
        },
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Job',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildStatsRow(JobProvider provider) {
    return Row(
      children: [
        _buildStatCard(
          'Total',
          provider.totalJobs.toString(),
          Icons.dashboard,
          const Color(0xFF6C63FF),
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          'Applied',
          provider.appliedCount.toString(),
          Icons.send,
          const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          'Interview',
          provider.interviewCount.toString(),
          Icons.people,
          const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          'Offers',
          provider.offerCount.toString(),
          Icons.celebration,
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
