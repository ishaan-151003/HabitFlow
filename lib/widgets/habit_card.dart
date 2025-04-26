import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final Function()? onTap;
  final Function()? onLongPress;
  final Function(bool)? onToggleCompletion;
  final bool showDetails;
  final bool isToday;

  const HabitCard({
    Key? key,
    required this.habit,
    this.onTap,
    this.onLongPress,
    this.onToggleCompletion,
    this.showDetails = true,
    this.isToday = true,
  }) : super(key: key);

  // Calculate the habit's "level" based on completion and streak
  int get habitLevel {
    final rate = habit.completionRate / 100; // Convert to 0-1 range
    final streakFactor = habit.currentStreak / 30; // 30 days as max reference
    
    // Combined score weighted towards completion rate
    final score = (rate * 0.7) + (streakFactor * 0.3);
    
    // Convert to level 1-5
    if (score >= 0.9) return 5;
    if (score >= 0.7) return 4;
    if (score >= 0.5) return 3;
    if (score >= 0.3) return 2;
    return 1;
  }

  // Calculate experience points (XP) for next level
  double get experienceProgress {
    final level = habitLevel;
    final rate = habit.completionRate / 100;
    
    // Different thresholds based on current level
    switch (level) {
      case 1: return rate / 0.3; // Need 30% completion to reach level 2
      case 2: return (rate - 0.3) / 0.2; // Need 50% for level 3
      case 3: return (rate - 0.5) / 0.2; // Need 70% for level 4
      case 4: return (rate - 0.7) / 0.2; // Need 90% for level 5
      case 5: return 1.0; // Max level
      default: return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = HabitDateUtils.today();
    final isCompleted = isToday ? habit.isCompletedOnDate(today) : false;
    final levelColor = AppTheme.getLevelColor(habitLevel);
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
          border: isCompleted
              ? Border.all(color: AppTheme.successColor, width: 2)
              : null,
          // Add subtle gradient based on level
          gradient: LinearGradient(
            colors: [
              Colors.white,
              levelColor.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level indicator
                    _buildLevelBadge(context, levelColor),
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (habit.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                habit.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                          // XP Progress bar
                          const SizedBox(height: 8),
                          _buildXpProgressBar(context, levelColor),
                        ],
                      ),
                    ),
                    if (isToday && onToggleCompletion != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: CompletionCheckbox(
                          isCompleted: isCompleted,
                          onChanged: (value) {
                            if (onToggleCompletion != null) {
                              onToggleCompletion!(value ?? false);
                            }
                          },
                        ),
                      ),
                  ],
                ),
                if (showDetails) ...[
                  const SizedBox(height: 16),
                  _buildDetailsRow(context),
                ],
                
                // Streak visualization
                if (habit.currentStreak > 0) ...[
                  const SizedBox(height: 12),
                  _buildStreakIndicator(context),
                ],
                
                // Show achievement badges if unlocked
                if (habit.longestStreak >= 7 || habit.completionRate >= 80) ...[
                  const SizedBox(height: 12),
                  _buildAchievementBadges(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge(BuildContext context, Color levelColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: levelColor.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: levelColor.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$habitLevel',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildXpProgressBar(BuildContext context, Color levelColor) {
    final progress = experienceProgress.clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $habitLevel',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            if (habitLevel < 5)
              Text(
                'Level ${habitLevel + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailItem(
          context,
          'Streak',
          '${habit.currentStreak} day${habit.currentStreak == 1 ? '' : 's'}',
          Icons.local_fire_department,
          AppTheme.warningColor,
        ),
        _buildDetailItem(
          context,
          'Best',
          '${habit.longestStreak} day${habit.longestStreak == 1 ? '' : 's'}',
          Icons.emoji_events,
          AppTheme.accentColor,
        ),
        _buildDetailItem(
          context,
          'Success',
          '${habit.completionRate.toStringAsFixed(0)}%',
          Icons.bar_chart,
          AppTheme.infoColor,
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTheme.captionStyle.copyWith(
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.subtitleStyle.copyWith(
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreakIndicator(BuildContext context) {
    // Create visualization for streak days (last 7 days)
    final today = HabitDateUtils.today();
    final streakDots = <Widget>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = HabitDateUtils.formatDate(date);
      final isCompleted = habit.completionRecord[dateKey] ?? false;
      
      streakDots.add(
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppTheme.successColor : Colors.grey.shade300,
            border: Border.all(
              color: isCompleted ? AppTheme.successColor.withOpacity(0.3) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last 7 days:',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: streakDots,
        ),
      ],
    );
  }
  
  Widget _buildAchievementBadges(BuildContext context) {
    final badges = <Widget>[];
    
    // Add badges based on achievements
    if (habit.longestStreak >= 30) {
      badges.add(_buildBadge(
        'Master Streak', 
        Icons.workspace_premium, 
        AppTheme.goldColor,
      ));
    } else if (habit.longestStreak >= 14) {
      badges.add(_buildBadge(
        'Pro Streak', 
        Icons.star_border, 
        AppTheme.silverColor,
      ));
    } else if (habit.longestStreak >= 7) {
      badges.add(_buildBadge(
        'Streak Week', 
        Icons.trending_up, 
        AppTheme.bronzeColor,
      ));
    }
    
    if (habit.completionRate >= 90) {
      badges.add(_buildBadge(
        'Perfection', 
        Icons.verified, 
        AppTheme.goldColor,
      ));
    } else if (habit.completionRate >= 80) {
      badges.add(_buildBadge(
        'Consistency', 
        Icons.thumb_up, 
        AppTheme.silverColor,
      ));
    }
    
    if (badges.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements:',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: badges,
        ),
      ],
    );
  }
  
  Widget _buildBadge(String tooltip, IconData icon, Color color) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.smallRadius),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }
}

class CompletionCheckbox extends StatelessWidget {
  final bool isCompleted;
  final Function(bool?)? onChanged;

  const CompletionCheckbox({
    Key? key,
    required this.isCompleted,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          if (onChanged != null) {
            onChanged!(!isCompleted);
          }
        },
        child: AnimatedContainer(
          duration: AppTheme.defaultAnimationDuration,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppTheme.successColor.withOpacity(0.2)
                : AppTheme.backgroundColor,
            border: Border.all(
              color: isCompleted
                  ? AppTheme.successColor
                  : AppTheme.textHintColor,
              width: isCompleted ? 2 : 1,
            ),
            boxShadow: isCompleted ? [
              BoxShadow(
                color: AppTheme.successColor.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  color: AppTheme.successColor,
                  size: 24,
                )
              : null,
        ),
      ),
    );
  }
} 