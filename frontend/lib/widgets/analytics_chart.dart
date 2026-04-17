import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Pie chart widget for displaying job status analytics.
class AnalyticsChart extends StatelessWidget {
  final Map<String, int> statusCounts;

  const AnalyticsChart({
    super.key,
    required this.statusCounts,
  });

  static const Map<String, Color> _statusColors = {
    'Not Applied': Color(0xFF6B7280),
    'Applied': Color(0xFF3B82F6),
    'Interview': Color(0xFFF59E0B),
    'Rejected': Color(0xFFEF4444),
    'Offer': Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    final total = statusCounts.values.fold(0, (sum, count) => sum + count);

    if (total == 0) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 8),
            Text(
              'No applications yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
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
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 35,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
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
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.key} (${entry.value})',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
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
