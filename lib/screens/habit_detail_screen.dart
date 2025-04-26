import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../services/habit_provider.dart';
import '../widgets/streak_calendar.dart';
import '../widgets/completion_chart.dart';
import '../widgets/habit_metrics.dart';
import '../widgets/trend_chart.dart';
import '../utils/app_theme.dart';
import '../utils/habit_date_utils.dart';
import '../screens/habit_form_screen.dart';
import '../screens/reminder_settings_screen.dart';
import '../services/prediction_service.dart';
import 'package:intl/intl.dart';

class HabitDetailScreen extends StatefulWidget {
  final int habitId;

  const HabitDetailScreen({
    Key? key,
    required this.habitId,
  }) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  Habit? _habit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to execute after the current build cycle is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHabit();
    });
  }

  Future<void> _loadHabit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      // Reload all habits to make sure we have the latest data
      await habitProvider.loadHabits();
      
      // Find the habit by ID
      final habits = habitProvider.habits;
      _habit = habits.firstWhere((h) => h.id == widget.habitId);
    } catch (e) {
      if (mounted) {  // Check if widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading habit: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {  // Check if widget is still mounted before setting state
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleHabitCompletion(DateTime date) async {
    if (_habit == null) return;

    try {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      await habitProvider.toggleHabitCompletion(_habit!.id!, date, context: context);
      
      // Refresh the habit data
      setState(() {
        _habit = habitProvider.habits.firstWhere((h) => h.id == widget.habitId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling completion: ${e.toString()}')),
      );
    }
  }

  void _editHabit() {
    if (_habit == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitFormScreen(habitToEdit: _habit),
      ),
    ).then((_) => _loadHabit());
  }

  void _deleteHabit() {
    if (_habit == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                await habitProvider.deleteHabit(_habit!.id!);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Habit deleted successfully!')),
                  );
                  Navigator.pop(context); // Return to habits list
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting habit: ${e.toString()}')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStreak(BuildContext context) {
    final isGoodStreak = _habit!.currentStreak >= 3;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isGoodStreak ? AppTheme.successColor.withOpacity(0.1) : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
        border: Border.all(
          color: isGoodStreak ? AppTheme.successColor : AppTheme.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: isGoodStreak ? AppTheme.successColor : AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '${_habit!.currentStreak} day streak',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isGoodStreak ? AppTheme.successColor : AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_habit == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Habit Details'),
        ),
        body: const Center(
          child: Text('Habit not found!'),
        ),
      );
    }

    final predictionService = PredictionService();
    final isDropOffRisk = predictionService.predictDropOff(_habit!);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          // Reminder button
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Set reminder',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReminderSettingsScreen(habit: _habit),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editHabit,
            tooltip: 'Edit Habit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteHabit,
            tooltip: 'Delete Habit',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHabit,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _habit!.title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    if (_habit!.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _habit!.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildCurrentStreak(context),
                  ],
                ),
              ),

              // Weekly view
              const Divider(height: 1),
              StreakWeekView(
                habit: _habit!,
                onDaySelected: _toggleHabitCompletion,
              ),
              const Divider(height: 1),

              // Stats section
              Padding(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stats & Insights',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HabitMetrics(habit: _habit!),
                    const SizedBox(height: 24),
                    
                    // Completion chart
                    Text(
                      'Completion Chart',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: CompletionChart(habit: _habit!),
                    ),
                    const SizedBox(height: 24),
                    
                    // Trend chart
                    Text(
                      'Weekly Trend',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: TrendChart(habit: _habit!),
                    ),
                    
                    // Risk warning if needed
                    if (isDropOffRisk) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
                          border: Border.all(color: AppTheme.warningColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppTheme.warningColor,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Habit at Risk',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.warningColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Our AI predicts you might struggle with this habit. Consider adjusting your approach or setting reminders.',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Full calendar
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calendar View',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreakCalendar(
                      habit: _habit!,
                      onDaySelected: _toggleHabitCompletion,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 