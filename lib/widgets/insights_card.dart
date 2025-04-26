import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';

class InsightsCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onDismiss;

  const InsightsCard({
    Key? key,
    required this.habit,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final predictionService = PredictionService();
    final insights = predictionService.getHabitInsights(habit);
    final isDropOffRisk = predictionService.predictDropOff(habit);
    
    if (insights.isEmpty && !isDropOffRisk) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
      ),
      color: isDropOffRisk 
          ? AppTheme.warningColor.withOpacity(0.1)
          : AppTheme.infoColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDropOffRisk ? Icons.warning_amber : Icons.lightbulb_outline,
                          color: isDropOffRisk ? AppTheme.warningColor : AppTheme.infoColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDropOffRisk ? 'Attention Needed' : 'AI Insights',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDropOffRisk ? AppTheme.warningColor : AppTheme.infoColor,
                          ),
                        ),
                      ],
                    ),
                    if (onDismiss != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: onDismiss,
                        color: AppTheme.textSecondaryColor,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isDropOffRisk) ...[
                  Text(
                    'You might be at risk of dropping this habit. Several missed days detected recently.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                ],
                ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          insight,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardInsightsCard extends StatelessWidget {
  final List<Habit> habits;
  final VoidCallback? onDismiss;
  final VoidCallback? onAddHabit;

  const DashboardInsightsCard({
    Key? key,
    required this.habits,
    this.onDismiss,
    this.onAddHabit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final predictionService = PredictionService();
    final overallInsights = predictionService.getOverallInsights(habits);
    final insights = overallInsights['insights'] as List<String>;
    final bool hasNoHabits = habits.isEmpty;
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
      ),
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Summary',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (onDismiss != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: onDismiss,
                        color: AppTheme.textSecondaryColor,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          insight,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                if (hasNoHabits && onAddHabit != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: onAddHabit,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Your First Habit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NudgeCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const NudgeCard({
    Key? key,
    required this.habit,
    this.onDismiss,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final predictionService = PredictionService();
    final nudgeMessage = predictionService.getPersonalizedNudge(habit);
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
      ),
      color: AppTheme.successColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reminder',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                    if (onDismiss != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: onDismiss,
                        color: AppTheme.textSecondaryColor,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  nudgeMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (onAction != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark as Complete'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
} 