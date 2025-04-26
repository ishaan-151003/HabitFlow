import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';
import '../utils/habit_date_utils.dart';

class StreakWeekView extends StatelessWidget {
  final Habit habit;
  final Function(DateTime)? onDaySelected;

  const StreakWeekView({
    Key? key,
    required this.habit,
    this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week View',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildWeekGrid(context),
        ],
      ),
    );
  }

  Widget _buildWeekGrid(BuildContext context) {
    final today = DateTime.now();
    
    // Show days for the past week (including today)
    List<DateTime> days = [];
    for (int i = 6; i >= 0; i--) {
      // Get the day that is i days before today
      final day = today.subtract(Duration(days: i));
      days.add(day);
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((date) => _buildDayCircle(context, date)).toList(),
    );
  }

  Widget _buildDayCircle(BuildContext context, DateTime date) {
    final isCompleted = habit.isCompletedOnDate(date);
    final isToday = HabitDateUtils.isToday(date);
    final dayName = DateFormat('E').format(date).substring(0, 1);
    
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        if (onDaySelected != null) {
          onDaySelected!(date);
        }
      },
      child: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppTheme.successColor
                  : Colors.transparent,
              border: Border.all(
                color: isToday
                    ? AppTheme.primaryColor
                    : isCompleted
                        ? AppTheme.successColor
                        : AppTheme.textHintColor,
                width: isToday ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  color: isCompleted
                      ? Colors.white
                      : isToday
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimaryColor,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                dayName,
                style: TextStyle(
                  fontSize: 12,
                  color: isToday
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 