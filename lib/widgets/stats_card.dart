import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';
import '../utils/habit_date_utils.dart';

class StatsCard extends StatelessWidget {
  final Habit habit;

  const StatsCard({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatsRow(context),
            const SizedBox(height: 24),
            Text(
              'Last 30 Days',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: CompletionChart(habit: habit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(
          context,
          'Current Streak',
          '${habit.currentStreak}',
          Icons.local_fire_department,
          AppTheme.warningColor,
        ),
        _buildStatItem(
          context,
          'Longest Streak',
          '${habit.longestStreak}',
          Icons.emoji_events,
          AppTheme.accentColor,
        ),
        _buildStatItem(
          context,
          'Completion Rate',
          '${habit.completionRate.toStringAsFixed(0)}%',
          Icons.check_circle_outline,
          AppTheme.successColor,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CompletionChart extends StatelessWidget {
  final Habit habit;

  const CompletionChart({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = 30;
    final completionData = _getCompletionData(days);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1,
        minY: 0,
        groupsSpace: 12,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = DateTime.now().subtract(Duration(days: days - 1 - groupIndex));
              return BarTooltipItem(
                '${HabitDateUtils.formatDateShort(date)}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: rod.toY == 1 ? 'Completed' : 'Missed',
                    style: TextStyle(
                      color: rod.toY == 1 ? AppTheme.successColor : AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Only show some dates to avoid crowding
                if (value.toInt() % 5 == 0 || value.toInt() == days - 1) {
                  final date = DateTime.now().subtract(Duration(days: days - 1 - value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        gridData: const FlGridData(
          show: false,
        ),
        barGroups: completionData,
      ),
    );
  }

  List<BarChartGroupData> _getCompletionData(int days) {
    final result = <BarChartGroupData>[];
    final today = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: days - 1 - i));
      
      // Only include dates after habit creation
      if (!date.isBefore(habit.createdAt)) {
        final isCompleted = habit.isCompletedOnDate(date);
        result.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: isCompleted ? 1 : 0,
                color: isCompleted ? AppTheme.successColor : AppTheme.errorColor.withOpacity(0.3),
                width: 6,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        );
      }
    }
    
    return result;
  }
}

class WeeklyStatsCard extends StatelessWidget {
  final List<Habit> habits;

  const WeeklyStatsCard({
    Key? key,
    required this.habits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekStats = _calculateWeeklyStats();
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week\'s Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: WeeklyChart(weekStats: weekStats),
            ),
            const SizedBox(height: 16),
            Text(
              'Weekly Completion Rate: ${(weekStats.completionRate * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  _WeeklyStats _calculateWeeklyStats() {
    final now = DateTime.now();
    final startOfWeek = HabitDateUtils.getFirstDayOfWeek(now);
    
    int totalCompletions = 0;
    int totalPossible = 0;
    
    // Calculate completions by day of week
    Map<int, int> completionsByDay = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    Map<int, int> possibleByDay = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    
    // For each habit
    for (final habit in habits) {
      if (!habit.isActive) continue;
      
      // For each day of the week
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        
        // Skip future dates and dates before habit was created
        if (date.isAfter(now) || date.isBefore(habit.createdAt)) {
          continue;
        }
        
        final dayOfWeek = date.weekday;
        possibleByDay[dayOfWeek] = (possibleByDay[dayOfWeek] ?? 0) + 1;
        totalPossible++;
        
        if (habit.isCompletedOnDate(date)) {
          completionsByDay[dayOfWeek] = (completionsByDay[dayOfWeek] ?? 0) + 1;
          totalCompletions++;
        }
      }
    }
    
    // Calculate completion rates by day
    Map<int, double> ratesByDay = {};
    for (int day = 1; day <= 7; day++) {
      if (possibleByDay[day]! > 0) {
        ratesByDay[day] = completionsByDay[day]! / possibleByDay[day]!;
      } else {
        ratesByDay[day] = 0;
      }
    }
    
    return _WeeklyStats(
      completionsByDay: completionsByDay,
      possibleByDay: possibleByDay,
      ratesByDay: ratesByDay,
      completionRate: totalPossible > 0 ? totalCompletions / totalPossible : 0,
    );
  }
}

class WeeklyChart extends StatelessWidget {
  final _WeeklyStats weekStats;

  const WeeklyChart({
    Key? key,
    required this.weekStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1,
        minY: 0,
        groupsSpace: 12,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
              final dayName = dayNames[group.x];
              final completions = weekStats.completionsByDay[group.x] ?? 0;
              final possible = weekStats.possibleByDay[group.x] ?? 0;
              
              return BarTooltipItem(
                '$dayName\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '$completions/$possible completed',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final dayNames = ['', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dayNames[value.toInt()],
                    style: const TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        gridData: const FlGridData(
          show: false,
        ),
        barGroups: List.generate(7, (i) {
          final dayIndex = i + 1; // 1 = Monday, 7 = Sunday
          final rate = weekStats.ratesByDay[dayIndex] ?? 0;
          final possible = weekStats.possibleByDay[dayIndex] ?? 0;
          
          // Skip days with no possible completions
          if (possible == 0) {
            return BarChartGroupData(
              x: dayIndex,
              barRods: [
                BarChartRodData(
                  toY: 0,
                  color: Colors.grey.withOpacity(0.3),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }
          
          return BarChartGroupData(
            x: dayIndex,
            barRods: [
              BarChartRodData(
                toY: rate,
                color: _getColorForRate(rate),
                width: 20,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 1,
                  color: AppTheme.backgroundColor,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  Color _getColorForRate(double rate) {
    if (rate >= 0.8) return AppTheme.successColor;
    if (rate >= 0.5) return AppTheme.infoColor;
    if (rate >= 0.3) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}

class _CompletionData {
  final int index;
  final bool isCompleted;
  final bool isSkipped;

  _CompletionData({
    required this.index,
    required this.isCompleted,
    required this.isSkipped,
  });
}

class _WeeklyStats {
  final Map<int, int> completionsByDay;
  final Map<int, int> possibleByDay;
  final Map<int, double> ratesByDay;
  final double completionRate;

  _WeeklyStats({
    required this.completionsByDay,
    required this.possibleByDay,
    required this.ratesByDay,
    required this.completionRate,
  });
} 