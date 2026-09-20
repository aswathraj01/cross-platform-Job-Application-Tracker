import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../config/liquid_glass_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/job_card.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/animated_orb_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/ad_banner.dart';
import 'login_screen.dart';
import 'add_job_screen.dart';
import 'job_detail_screen.dart';
import 'ai_extract_screen.dart';
import 'ai_chat_screen.dart';

/// Dashboard screen with Apple Liquid Glass design.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        AppRoutes.fadeSlide(const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarOpacity = (_scrollOffset / 80).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: LiquidGlass.bgDeep,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: appBarOpacity * 20,
              sigmaY: appBarOpacity * 20,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: LiquidGlass.bgDeep.withValues(alpha: appBarOpacity * 0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: appBarOpacity * 0.08),
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          gradient: LiquidGlass.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: LiquidGlass.glowShadow(LiquidGlass.accentPrimary, intensity: 0.4, blur: 14),
                        ),
                        child: const Icon(Icons.work_outline, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Dashboard',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      // AI Chat button
                      _buildAppBarAction(
                        icon: Icons.smart_toy,
                        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                        tooltip: 'AI Job Coach',
                        onTap: () => Navigator.push(
                          context,
                          AppRoutes.slideUp(const AiChatScreen()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // AI Extract button
                      _buildAppBarAction(
                        icon: Icons.auto_awesome,
                        gradient: LiquidGlass.primaryGradient,
                        tooltip: 'AI Extract',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            AppRoutes.slideUp(const AiExtractScreen()),
                          );
                          _loadJobs();
                        },
                      ),
                      const SizedBox(width: 8),
                      // Logout
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Icon(Icons.logout, color: Colors.white.withValues(alpha: 0.6), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Orb background ──
          const Positioned.fill(child: AnimatedOrbBackground()),

          // ── Main content ──
          Consumer<JobProvider>(
            builder: (ctx, jobProvider, _) {
              return RefreshIndicator(
                onRefresh: () async => _loadJobs(),
                color: LiquidGlass.accentPrimary,
                backgroundColor: LiquidGlass.bgSurface,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // top padding for app bar
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),

                    // ── Analytics Section ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats Row
                            _buildStatsRow(jobProvider),
                            const SizedBox(height: 14),

                            // Chart Card
                            GlassContainer(
                              borderRadius: 20,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 6, height: 20,
                                        decoration: BoxDecoration(
                                          gradient: LiquidGlass.primaryGradient,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Application Overview',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  AnalyticsChart(statusCounts: jobProvider.statusCounts),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Success rate card
                            if (jobProvider.totalJobs > 0)
                              GlassContainer(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(16),
                                fillColor: LiquidGlass.accentPrimary.withValues(alpha: 0.08),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LiquidGlass.primaryGradient,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: LiquidGlass.glowShadow(LiquidGlass.accentPrimary, blur: 14),
                                      ),
                                      child: const Icon(Icons.trending_up, color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(width: 14),
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
                                              color: Colors.white.withValues(alpha: 0.55),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ShaderMask(
                                      shaderCallback: (b) => LiquidGlass.primaryGradient.createShader(b),
                                      child: Text(
                                        '${jobProvider.interviewRate.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ── Search & Filter header ──
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'My Applications',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                if (jobProvider.sourceFilter != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: LiquidGlass.accentSecond.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: LiquidGlass.accentSecond.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      'Filtered by: ${jobProvider.sourceFilter!}',
                                      style: TextStyle(color: LiquidGlass.accentSecond, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SearchFilterBar(
                            searchQuery: jobProvider.searchQuery,
                            statusFilter: jobProvider.statusFilter,
                            sourceFilter: jobProvider.sourceFilter,
                            onSearchChanged: jobProvider.setSearchQuery,
                            onStatusChanged: jobProvider.setStatusFilter,
                            onSourceChanged: jobProvider.setSourceFilter,
                            onClearFilters: jobProvider.clearFilters,
                          ),
                        ],
                      ),
                    ),

                    // ── Job List ──
                    if (jobProvider.isLoading && jobProvider.allJobs.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: LiquidGlass.accentPrimary),
                        ),
                      )
                    else if (jobProvider.error != null && jobProvider.allJobs.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withValues(alpha: 0.05),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
                                ),
                                child: Icon(
                                  Icons.wifi_off_rounded,
                                  size: 36,
                                  color: Colors.red.withValues(alpha: 0.4),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Could not load jobs',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  jobProvider.error ?? '',
                                  style: TextStyle(color: Colors.red.withValues(alpha: 0.5), fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: _loadJobs,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                                  decoration: BoxDecoration(
                                    gradient: LiquidGlass.primaryGradient,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: LiquidGlass.glowShadow(LiquidGlass.accentPrimary, blur: 14),
                                  ),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (jobProvider.jobs.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.05),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                ),
                                child: Icon(
                                  jobProvider.allJobs.isEmpty
                                      ? Icons.work_off_outlined
                                      : Icons.search_off_rounded,
                                  size: 36,
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                jobProvider.allJobs.isEmpty
                                    ? 'No jobs tracked yet'
                                    : 'No matching jobs',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                jobProvider.allJobs.isEmpty
                                    ? 'Use the extension or AI Extract to add jobs!'
                                    : 'Try adjusting your search or filters.',
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
                      SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.crossAxisExtent > 700;
                          if (isWide) {
                            return SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.6,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final job = jobProvider.jobs[index];
                                    return JobCard(
                                      job: job,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          AppRoutes.fadeSlide(JobDetailScreen(job: job)),
                                        );
                                        _loadJobs();
                                      },
                                    );
                                  },
                                  childCount: jobProvider.jobs.length,
                                ),
                              ),
                            );
                          }
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final job = jobProvider.jobs[index];
                                return JobCard(
                                  job: job,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      AppRoutes.fadeSlide(JobDetailScreen(job: job)),
                                    );
                                    _loadJobs();
                                  },
                                );
                              },
                              childCount: jobProvider.jobs.length,
                            ),
                          );
                        },
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _buildGlowingFAB(),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required LinearGradient gradient,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildGlowingFAB() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          AppRoutes.slideUp(const AddJobScreen()),
        );
        _loadJobs();
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: LiquidGlass.primaryGradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: LiquidGlass.glowShadow(LiquidGlass.accentPrimary, intensity: 0.55, blur: 28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Add Job',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(JobProvider provider) {
    return Row(
      children: [
        _buildStatCard('Total',     provider.totalJobs.toString(),     Icons.dashboard,   LiquidGlass.accentPrimary),
        const SizedBox(width: 8),
        _buildStatCard('Applied',   provider.appliedCount.toString(),   Icons.send,        LiquidGlass.accentBlue),
        const SizedBox(width: 8),
        _buildStatCard('Interview', provider.interviewCount.toString(), Icons.people,      LiquidGlass.accentAmber),
        const SizedBox(width: 8),
        _buildStatCard('Offers',    provider.offerCount.toString(),     Icons.celebration, LiquidGlass.accentGreen),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        fillColor: color.withValues(alpha: 0.08),
        shadows: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
