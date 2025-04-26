import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';

class HabitMetrics extends StatelessWidget {
  final Habit habit;

  const HabitMetrics({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habit Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  context,
                  icon: Icons.fact_check,
                  title: "Completion Rate",
                  value: "${habit.completionRate.toStringAsFixed(1)}%",
                  color: AppTheme.infoColor,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  context,
                  icon: Icons.local_fire_department,
                  title: "Current Streak",
                  value: "${habit.currentStreak} days",
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  context,
                  icon: Icons.emoji_events,
                  title: "Best Streak",
                  value: "${habit.longestStreak} days",
                  color: AppTheme.successColor,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  context,
                  icon: Icons.calendar_today,
                  title: "Target",
                  value: "${habit.targetDays} days",
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 30,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 