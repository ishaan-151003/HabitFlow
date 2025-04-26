import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

class CompletionChart extends StatelessWidget {
  final Habit habit;

  const CompletionChart({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completionData = _prepareCompletionData();

    if (completionData.isEmpty) {
      return const Center(
        child: Text('Not enough data to show chart'),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1,
        barGroups: completionData,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Show date labels
                final date = DateTime.now().subtract(Duration(days: (6 - value).toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('E').format(date), // Day of week
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.borderColor.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: false,
        ),
      ),
    );
  }

  List<BarChartGroupData> _prepareCompletionData() {
    final today = DateTime.now();
    final List<BarChartGroupData> data = [];

    // Get data for the last 7 days
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: 6 - i)); // 0 = 6 days ago, 6 = today
      final isCompleted = habit.isCompletedOnDate(date);

      data.add(
        BarChartGroupData(
          x: i.toInt(),
          barRods: [
            BarChartRodData(
              toY: isCompleted ? 1.0 : 0.0,
              color: isCompleted ? AppTheme.successColor : AppTheme.borderColor.withOpacity(0.5),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return data;
  }
} 