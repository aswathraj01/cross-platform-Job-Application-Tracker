import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/liquid_glass_theme.dart';

/// Pie chart widget for displaying job status analytics.
class AnalyticsChart extends StatelessWidget {
  final Map<String, int> statusCounts;

  const AnalyticsChart({
    super.key,
    required this.statusCounts,
  });

  static const Map<String, Color> _statusColors = {
    'Not Applied': Color(0xFF94A3B8),
    'Applied':     LiquidGlass.accentBlue,
    'Interview':   LiquidGlass.accentAmber,
    'Rejected':    LiquidGlass.accentRed,
    'Offer':       LiquidGlass.accentGreen,
  };

  @override
  Widget build(BuildContext context) {
    final total = statusCounts.values.fold(0, (sum, count) => sum + count);

    if (total == 0) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 44,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 8),
            Text(
              'No applications yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final sections = statusCounts.entries
        .where((e) => e.value > 0)
        .map((entry) {
      final color = _statusColors[entry.key] ?? Colors.grey;
      final percentage = (entry.value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '$percentage%',
        radius: 52,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 38,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: statusCounts.entries
              .where((e) => e.value > 0)
              .map((entry) {
            final color = _statusColors[entry.key] ?? Colors.grey;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${entry.key} (${entry.value})',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
