import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_provider.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart';
import '../widgets/insights_card.dart';
import 'habit_detail_screen.dart';

class InsightsTab extends StatefulWidget {
  const InsightsTab({super.key});

  @override
  State<InsightsTab> createState() => _InsightsTabState();
}

class _InsightsTabState extends State<InsightsTab> with AutomaticKeepAliveClientMixin {
  int _selectedPeriod = 7; // Default to weekly view
  List<Habit> _habits = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    await habitProvider.loadHabits();
    
    setState(() {
      _habits = habitProvider.habits;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No data yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create some habits to see insights',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period selector
              _buildPeriodSelector(theme),
              const SizedBox(height: 24),
              
              // Overall completion rate
              _buildCompletionRateCard(theme),
              const SizedBox(height: 16),
              
              // Streak data
              _buildStreaksCard(theme),
              const SizedBox(height: 16),
              
              // Habit completion chart
              _buildCompletionChart(theme),
              const SizedBox(height: 16),
              
              // Most consistent habits
              _buildMostConsistentHabits(theme),
              const SizedBox(height: 16),
              
              // Habits needing attention
              _buildHabitsNeedingAttention(theme),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPeriodSelector(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _periodButton(7, 'Week', theme),
            _periodButton(30, 'Month', theme),
            _periodButton(90, 'Quarter', theme),
            _periodButton(365, 'Year', theme),
          ],
        ),
      ),
    );
  }
  
  Widget _periodButton(int days, String label, ThemeData theme) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = days;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: _selectedPeriod == days
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedPeriod == days
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: _selectedPeriod == days
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompletionRateCard(ThemeData theme) {
    final completionRate = _calculateCompletionRate();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Completion Rate',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: CircularProgressIndicator(
                            value: completionRate / 100,
                            strokeWidth: 10,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getCompletionColor(completionRate, theme),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${completionRate.toStringAsFixed(0)}%',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You\'ve completed ${completionRate.toStringAsFixed(0)}% of your habits in the last ${_selectedPeriod == 7 ? "week" : _selectedPeriod == 30 ? "month" : _selectedPeriod == 90 ? "3 months" : "year"}.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getCompletionMessage(completionRate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStreaksCard(ThemeData theme) {
    final currentStreaks = _getCurrentStreaks();
    final longestStreaks = _getLongestStreaks();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Streaks',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStreakInfo(
                    icon: Icons.local_fire_department,
                    value: currentStreaks.toString(),
                    label: 'Current\nStreak',
                    color: theme.colorScheme.error,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStreakInfo(
                    icon: Icons.emoji_events,
                    value: longestStreaks.toString(),
                    label: 'Longest\nStreak',
                    color: theme.colorScheme.tertiary,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStreakInfo({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 40,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildCompletionChart(ThemeData theme) {
    final completionData = _getCompletionDataForPeriod();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Completion Trend',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.now().subtract(
                            Duration(days: _selectedPeriod - 1 - value.toInt()),
                          );
                          String text = '';
                          
                          // Label strategy based on selected period
                          if (_selectedPeriod <= 7) {
                            // For week view, show day of week
                            text = DateFormat('E').format(date);
                          } else if (_selectedPeriod <= 30) {
                            // For month view, show day number for 1, 10, 20, 30
                            if (date.day == 1 || date.day % 10 == 0) {
                              text = date.day.toString();
                            }
                          } else if (_selectedPeriod <= 90) {
                            // For quarter view, show first day of each month
                            if (date.day == 1) {
                              text = DateFormat('MMM').format(date);
                            }
                          } else {
                            // For year view, show first day of each quarter
                            if (date.day == 1 && (date.month % 3 == 1)) {
                              text = DateFormat('MMM').format(date);
                            }
                          }
                          
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(text, style: theme.textTheme.bodySmall),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}%',
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: _selectedPeriod.toDouble() - 1,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: completionData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMostConsistentHabits(ThemeData theme) {
    final consistentHabits = _getMostConsistentHabits();
    
    if (consistentHabits.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Consistent Habits',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...consistentHabits.map((habit) {
              final completionRate = _calculateHabitCompletionRate(habit);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppTheme.getPrimaryColorForHabit(habit.id),
                  child: const Icon(Icons.verified, color: Colors.white),
                ),
                title: Text(habit.title),
                subtitle: Text('${completionRate.toStringAsFixed(0)}% completion rate'),
                trailing: Text(
                  '${habit.currentStreak} days',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHabitsNeedingAttention(ThemeData theme) {
    final habitsNeedingAttention = _getHabitsNeedingAttention();
    
    if (habitsNeedingAttention.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habits Needing Attention',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...habitsNeedingAttention.map((habit) {
              final completionRate = _calculateHabitCompletionRate(habit);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppTheme.getPrimaryColorForHabit(habit.id),
                  child: const Icon(Icons.warning, color: Colors.white),
                ),
                title: Text(habit.title),
                subtitle: Text('${completionRate.toStringAsFixed(0)}% completion rate'),
                trailing: Text(
                  '${habit.currentStreak} days',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  // Helper methods for calculations
  
  double _calculateCompletionRate() {
    if (_habits.isEmpty) return 0;
    
    int totalCompletions = 0;
    int totalOpportunities = 0;
    
    for (var habit in _habits) {
      final record = habit.completionRecord;
      final now = DateTime.now();
      
      for (int i = 0; i < _selectedPeriod; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        
        // Check if this date was an opportunity for this habit based on frequency
        if (_isHabitScheduledForDate(habit, date)) {
          totalOpportunities++;
          
          // Check if habit was completed on this date
          if (record.containsKey(dateStr) && record[dateStr] == true) {
            totalCompletions++;
          }
        }
      }
    }
    
    if (totalOpportunities == 0) return 0;
    return (totalCompletions / totalOpportunities) * 100;
  }
  
  bool _isHabitScheduledForDate(Habit habit, DateTime date) {
    switch (habit.frequency) {
      case 'daily':
        return true;
      case 'weekdays':
        final weekday = date.weekday;
        return weekday >= 1 && weekday <= 5;
      case 'weekends':
        final weekday = date.weekday;
        return weekday == 6 || weekday == 7;
      case 'weekly':
        // Assume weekly habits are scheduled for Monday
        return date.weekday == 1;
      case 'monthly':
        // Assume monthly habits are scheduled for the 1st of the month
        return date.day == 1;
      case 'custom':
        // For custom, we'd need more information from the habit model
        return true;
      default:
        return true;
    }
  }
  
  int _getCurrentStreaks() {
    if (_habits.isEmpty) return 0;
    
    // Return the highest current streak among all habits
    return _habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
  }
  
  int _getLongestStreaks() {
    if (_habits.isEmpty) return 0;
    
    // Return the highest longest streak among all habits
    return _habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
  }
  
  List<double> _getCompletionDataForPeriod() {
    List<double> result = List.filled(_selectedPeriod, 0);
    final now = DateTime.now();
    
    for (int i = 0; i < _selectedPeriod; i++) {
      final date = now.subtract(Duration(days: _selectedPeriod - 1 - i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      int totalOpportunities = 0;
      int completions = 0;
      
      for (var habit in _habits) {
        if (_isHabitScheduledForDate(habit, date)) {
          totalOpportunities++;
          if (habit.completionRecord.containsKey(dateStr) && habit.completionRecord[dateStr] == true) {
            completions++;
          }
        }
      }
      
      result[i] = totalOpportunities > 0 ? (completions / totalOpportunities) * 100 : 0;
    }
    
    return result;
  }
  
  List<Habit> _getMostConsistentHabits() {
    if (_habits.isEmpty) return [];
    
    final habits = List<Habit>.from(_habits);
    habits.sort((a, b) {
      final aRate = _calculateHabitCompletionRate(a);
      final bRate = _calculateHabitCompletionRate(b);
      return bRate.compareTo(aRate);
    });
    
    // Return top 3 habits with at least 70% completion rate
    return habits
        .where((h) => _calculateHabitCompletionRate(h) >= 70)
        .take(3)
        .toList();
  }
  
  List<Habit> _getHabitsNeedingAttention() {
    if (_habits.isEmpty) return [];
    
    final habits = List<Habit>.from(_habits);
    habits.sort((a, b) {
      final aRate = _calculateHabitCompletionRate(a);
      final bRate = _calculateHabitCompletionRate(b);
      return aRate.compareTo(bRate);
    });
    
    // Return bottom 3 habits with less than 50% completion rate
    return habits
        .where((h) => _calculateHabitCompletionRate(h) < 50)
        .take(3)
        .toList();
  }
  
  double _calculateHabitCompletionRate(Habit habit) {
    final record = habit.completionRecord;
    final now = DateTime.now();
    
    int totalOpportunities = 0;
    int completions = 0;
    
    for (int i = 0; i < _selectedPeriod; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      if (_isHabitScheduledForDate(habit, date)) {
        totalOpportunities++;
        if (record.containsKey(dateStr) && record[dateStr] == true) {
          completions++;
        }
      }
    }
    
    if (totalOpportunities == 0) return 0;
    return (completions / totalOpportunities) * 100;
  }
  
  String _getCompletionMessage(double rate) {
    if (rate >= 90) {
      return 'Outstanding! Keep up the excellent work!';
    } else if (rate >= 70) {
      return 'Great job! You\'re making good progress.';
    } else if (rate >= 50) {
      return 'You\'re doing okay. Try to be more consistent.';
    } else if (rate >= 30) {
      return 'You\'re struggling a bit. Focus on one habit at a time.';
    } else {
      return 'Time to get back on track! Start small and build up.';
    }
  }
  
  Color _getCompletionColor(double rate, ThemeData theme) {
    if (rate >= 70) {
      return Colors.green;
    } else if (rate >= 50) {
      return Colors.amber;
    } else {
      return theme.colorScheme.error;
    }
  }
  
  @override
  bool get wantKeepAlive => true;
} 