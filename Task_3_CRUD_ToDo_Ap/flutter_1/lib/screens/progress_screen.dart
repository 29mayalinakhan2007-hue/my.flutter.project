import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Study Activity', style: AppTypography.title(isDark)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: true),
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: AppColors.primary)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 8, color: AppColors.primary)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 3, color: AppColors.primary)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 9, color: AppColors.primary)]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 6, color: AppColors.primary)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}