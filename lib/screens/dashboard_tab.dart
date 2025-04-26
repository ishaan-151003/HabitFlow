import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_provider.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import '../utils/habit_date_utils.dart';
import '../widgets/habit_card.dart';
import '../widgets/insights_card.dart';
import '../widgets/stats_card.dart';
import 'habit_detail_screen.dart';
import 'habit_form_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final ScrollController _scrollController = ScrollController();
  Habit? _nudgeHabit;
  bool _dismissedInsights = false;
  bool _refreshing = false;
  int _quoteIndex = 0;
  final Random _random = Random();
  
  // List of motivational quotes about habits and consistency
  final List<Map<String, String>> _quotes = [
    {
      'quote': 'Habits are the compound interest of self-improvement.',
      'author': 'James Clear',
    },
    {
      'quote': 'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
      'author': 'Aristotle',
    },
    {
      'quote': 'Your habits will determine your future.',
      'author': 'Jack Canfield',
    },
    {
      'quote': 'Motivation is what gets you started. Habit is what keeps you going.',
      'author': 'Jim Ryun',
    },
    {
      'quote': 'First we make our habits, then our habits make us.',
      'author': 'Charles C. Noble',
    },
    {
      'quote': 'Successful people are simply those with successful habits.',
      'author': 'Brian Tracy',
    },
    {
      'quote': 'The secret of your future is hidden in your daily routine.',
      'author': 'Mike Murdock',
    },
    {
      'quote': 'Habits change into character.',
      'author': 'Ovid',
    },
    {
      'quote': 'You\'ll never change your life until you change something you do daily.',
      'author': 'John C. Maxwell',
    },
    {
      'quote': 'Good habits formed at youth make all the difference.',
      'author': 'Aristotle',
    },
    {
      'quote': 'The difference between an amateur and a professional is in their habits.',
      'author': 'Amanda Ibey',
    },
    {
      'quote': 'Small habits can have a surprising power to transform your life.',
      'author': 'BJ Fogg',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _selectNudgeHabit();
    _selectRandomQuote();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // Select a random quote from the list
  void _selectRandomQuote() {
    setState(() {
      _quoteIndex = _random.nextInt(_quotes.length);
    });
  }
  
  Future<void> _refreshData() async {
    setState(() {
      _refreshing = true;
    });
    
    try {
      await Provider.of<HabitProvider>(context, listen: false).loadHabits();
      _selectNudgeHabit();
      _selectRandomQuote(); // Get a new quote on refresh
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }
  
  void _selectNudgeHabit() {
    // Get a random active habit for nudging that isn't completed today
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final activeHabits = habitProvider.activeHabits;
    
    if (activeHabits.isEmpty) {
      _nudgeHabit = null;
      return;
    }
    
    // Filter habits that aren't completed today
    final today = HabitDateUtils.today();
    final incompleteHabits = activeHabits
        .where((h) => !h.isCompletedOnDate(today))
        .toList();
    
    if (incompleteHabits.isEmpty) {
      _nudgeHabit = null;
      return;
    }
    
    // Prefer habits with current streaks
    final habitsWithStreaks = incompleteHabits
        .where((h) => h.currentStreak > 0)
        .toList();
    
    if (habitsWithStreaks.isNotEmpty) {
      // Sort by streak, take the highest
      habitsWithStreaks.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
      _nudgeHabit = habitsWithStreaks.first;
    } else {
      // Take a random habit from incomplete ones
      _nudgeHabit = incompleteHabits[DateTime.now().millisecondsSinceEpoch % incompleteHabits.length];
    }
  }
  
  void _navigateToHabitDetail(Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(habitId: habit.id!),
      ),
    ).then((_) => _refreshData());
  }
  
  void _toggleHabitCompletion(Habit habit) async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    
    await habitProvider.toggleHabitCompletion(habit.id!, DateTime.now());
    
    // If this was the nudge habit, select a new one
    if (_nudgeHabit?.id == habit.id) {
      _selectNudgeHabit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final habits = habitProvider.activeHabits;
        final isLoading = habitProvider.isLoading;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('HabitFlow'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshing ? null : _refreshData,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: habits.isEmpty && !isLoading
                ? _buildEmptyState()
                : _buildDashboard(habits, isLoading),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_task,
                size: 72,
                color: AppTheme.primaryColorLight,
              ),
              const SizedBox(height: 16),
              Text(
                'No Habits Yet',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first habit by tapping the + button below.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildQuoteCard(), // Add motivational quote even to empty state
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate directly to the HabitFormScreen instead of using reflection
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HabitFormScreen(),
                    ),
                  ).then((_) => _refreshData());
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Habit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDashboard(List<Habit> habits, bool isLoading) {
    final todayHabits = habits.where((h) => !h.isCompletedOnDate(DateTime.now())).toList();
    final completedHabits = habits.where((h) => h.isCompletedOnDate(DateTime.now())).toList();
    
    final predictionService = PredictionService();
    final insights = predictionService.getOverallInsights(habits);
    
    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Today's progress
        Padding(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Progress',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                HabitDateUtils.formatDateLong(DateTime.now()),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: habits.isEmpty ? 0 : completedHabits.length / habits.length,
                backgroundColor: AppTheme.backgroundColor,
                color: AppTheme.successColor,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${completedHabits.length}/${habits.length} habits completed',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    habits.isEmpty
                        ? '0%'
                        : '${(completedHabits.length / habits.length * 100).round()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Quote of the day
        _buildQuoteCard(),
        
        // Habit Nudge - show if there's an active habit to complete
        if (_nudgeHabit != null) ...[
          _buildNudgeCard(_nudgeHabit!),
        ],
        
        // AI Insights Section
        _buildInsightsSummary(habits),
        
        // Streak overview
        _buildStreakOverview(habits),
        
        // Completion rate chart
        _buildCompletionRateChart(habits),
        
        // Today's habits
        if (todayHabits.isNotEmpty) ...[
          _buildTodayHabitsSection(todayHabits),
        ],
        
        // Today's completed habits
        if (completedHabits.isNotEmpty) ...[
          _buildCompletedHabitsSection(completedHabits),
        ],
        
        // Loading indicator
        if (isLoading) ...[
          const Padding(
            padding: EdgeInsets.all(AppTheme.defaultPadding),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
        
        // Bottom space for better UX
        const SizedBox(height: 40),
      ],
    );
  }
  
  // Build the motivational quote card
  Widget _buildQuoteCard() {
    final quote = _quotes[_quoteIndex];
    
    return Card(
      margin: const EdgeInsets.all(AppTheme.defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
      ),
      color: AppTheme.primaryColorLight.withOpacity(0.08),
      elevation: 1,
      child: InkWell(
        onTap: _selectRandomQuote, // Tap to get a new quote
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Inspiration',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.refresh,
                    color: AppTheme.primaryColor.withOpacity(0.6),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '"${quote['quote']}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '— ${quote['author']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNudgeCard(Habit habit) {
    return NudgeCard(
      habit: habit,
      onDismiss: () => setState(() {
        _selectNudgeHabit();
      }),
      onAction: () => _toggleHabitCompletion(habit),
    );
  }

  Widget _buildInsightsSummary(List<Habit> habits) {
    final predictionService = PredictionService();
    final insights = predictionService.getOverallInsights(habits);
    final insightList = insights['insights'] as List<String>;
    
    return Card(
      margin: const EdgeInsets.all(AppTheme.defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insightList.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(insight),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStreakOverview(List<Habit> habits) {
    if (habits.isEmpty) return const SizedBox.shrink();
    
    // Get the top 3 habits by streak
    final sortedHabits = List<Habit>.from(habits);
    sortedHabits.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    final topStreakHabits = sortedHabits.take(3).toList();
    
    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.defaultPadding,
        AppTheme.defaultPadding / 2,
        AppTheme.defaultPadding,
        AppTheme.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Streak Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topStreakHabits.map((habit) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      habit.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: habit.currentStreak / (habit.bestStreak > 0 ? habit.bestStreak : 10),
                      backgroundColor: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        habit.currentStreak >= habit.bestStreak
                            ? AppTheme.successColor
                            : AppTheme.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${habit.currentStreak} day${habit.currentStreak != 1 ? 's' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
            if (habits.length > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Since insights is merged with dashboard, just scroll to relevant section
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View all habits in the Habits tab')),
                    );
                  },
                  child: const Text('View All Habits'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompletionRateChart(List<Habit> habits) {
    if (habits.isEmpty) return const SizedBox.shrink();
    
    // Get completion data for the past week
    final today = HabitDateUtils.today();
    final dates = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    
    // Calculate completion rate for each day
    final completionRates = dates.map((date) {
      final dueHabits = habits.where((h) => h.shouldCompleteOnDate(date)).toList();
      if (dueHabits.isEmpty) return 0.0;
      
      final completedHabits = dueHabits.where((h) => h.isCompletedOnDate(date)).toList();
      return completedHabits.length / dueHabits.length;
    }).toList();
    
    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.defaultPadding,
        AppTheme.defaultPadding / 2,
        AppTheme.defaultPadding,
        AppTheme.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.insights,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completion Rate (Last 7 Days)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1.0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final percentage = (rod.toY * 100).toInt();
                        return BarTooltipItem(
                          '$percentage%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dates.length) return const Text('');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('E').format(dates[index]), // Short day name (Mon, Tue, etc.)
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final text = '${(value * 100).toInt()}%';
                          return Text(
                            text,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          );
                        },
                        reservedSize: 36,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    completionRates.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: completionRates[i],
                          color: i == completionRates.length - 1 
                              ? AppTheme.primaryColor // Today
                              : AppTheme.primaryColorLight, // Past days
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayHabitsSection(List<Habit> todayHabits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.defaultPadding,
            AppTheme.defaultPadding,
            AppTheme.defaultPadding,
            AppTheme.smallPadding,
          ),
          child: Text(
            'To Complete Today',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...todayHabits.map((habit) => HabitCard(
          habit: habit,
          onTap: () => _navigateToHabitDetail(habit),
          onToggleCompletion: (_) => _toggleHabitCompletion(habit),
        )),
      ],
    );
  }

  Widget _buildCompletedHabitsSection(List<Habit> completedHabits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.defaultPadding,
            AppTheme.defaultPadding,
            AppTheme.defaultPadding,
            AppTheme.smallPadding,
          ),
          child: Text(
            'Completed Today',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...completedHabits.map((habit) => HabitCard(
          habit: habit,
          onTap: () => _navigateToHabitDetail(habit),
          onToggleCompletion: (_) => _toggleHabitCompletion(habit),
        )),
      ],
    );
  }
} 