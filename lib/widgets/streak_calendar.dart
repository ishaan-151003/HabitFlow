import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';
import '../utils/habit_date_utils.dart';

class StreakCalendar extends StatelessWidget {
  final Habit habit;
  final int numMonths;
  final Function(DateTime)? onDaySelected;

  const StreakCalendar({
    Key? key,
    required this.habit,
    this.numMonths = 3,
    this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCalendarMonths(context),
      ],
    );
  }

  Widget _buildCalendarMonths(BuildContext context) {
    final now = DateTime.now();
    List<Widget> months = [];

    for (int i = 0; i < numMonths; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      months.add(_buildMonthCalendar(context, month));
      
      if (i < numMonths - 1) {
        months.add(const SizedBox(height: AppTheme.defaultPadding));
      }
    }

    return Column(
      children: months,
    );
  }

  Widget _buildMonthCalendar(BuildContext context, DateTime month) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.defaultPadding),
          child: Text(
            DateFormat('MMMM yyyy').format(month),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildMonthGrid(context, month),
      ],
    );
  }

  Widget _buildMonthGrid(BuildContext context, DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday
    
    // Calculate number of rows needed
    final numRows = ((daysInMonth + firstWeekday) / 7).ceil();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.defaultPadding),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 7 + (numRows * 7), // Header row + calendar days
      itemBuilder: (context, index) {
        // Render weekday headers
        if (index < 7) {
          return _buildWeekdayHeader(context, index);
        }
        
        // Render calendar days
        final dayIndex = index - 7;
        final day = dayIndex - firstWeekday + 1;
        
        if (day < 1 || day > daysInMonth) {
          return const SizedBox(); // Empty cell
        }
        
        final date = DateTime(month.year, month.month, day);
        return _buildDayCell(context, date);
      },
    );
  }

  Widget _buildWeekdayHeader(BuildContext context, int weekday) {
    // Adjusted weekday to start with Sunday
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Center(
      child: Text(
        days[weekday],
        style: AppTheme.captionStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final isCompleted = habit.isCompletedOnDate(date);
    final isToday = HabitDateUtils.isToday(date);
    final isPast = date.isBefore(DateTime.now()) && !isToday;
    final isSkipped = isPast && !isCompleted;
    
    // Determine the appropriate color based on completion state
    Color cellColor;
    if (isCompleted) {
      cellColor = AppTheme.successColor;
    } else if (isSkipped) {
      cellColor = AppTheme.errorColor.withOpacity(0.3);
    } else {
      cellColor = Colors.transparent;
    }
    
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
      onTap: () {
        if (onDaySelected != null && !date.isAfter(DateTime.now())) {
          onDaySelected!(date);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(AppTheme.smallRadius),
          border: isToday
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
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
    );
  }
}

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