import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

class TrendChart extends StatelessWidget {
  final Habit habit;

  const TrendChart({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trendData = _prepareTrendData();
    
    if (trendData.isEmpty) {
      return const Center(
        child: Text('Not enough data to show trend'),
      );
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          ),
          handleBuiltInTouches: true,
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.borderColor.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Show date labels for the past 6 weeks
                final weekAgo = DateTime.now().subtract(Duration(days: 7 * (6 - value.toInt())));
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "W${value.toInt() + 1}",
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  "${(value * 100).toInt()}%",
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                );
              },
              interval: 0.2,
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: trendData,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: AppTheme.primaryColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _prepareTrendData() {
    final List<FlSpot> spots = [];
    final today = DateTime.now();
    
    // Calculate weekly completion rate for the past 7 weeks
    for (int week = 0; week < 7; week++) {
      int completed = 0;
      int total = 0;
      
      // Check each day in the week
      for (int day = 0; day < 7; day++) {
        final date = today.subtract(Duration(days: 7 * (6 - week) + (6 - day)));
        
        // Only count days if habit exists at that point
        if (!date.isBefore(habit.createdAt)) {
          total++;
          if (habit.isCompletedOnDate(date)) {
            completed++;
          }
        }
      }
      
      double rate = total > 0 ? completed / total : 0;
      spots.add(FlSpot(week.toDouble(), rate));
    }
    
    return spots;
  }
} 