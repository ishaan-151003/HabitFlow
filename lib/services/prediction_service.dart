import 'package:intl/intl.dart';
import '../models/habit.dart';

// For MVP, we'll implement a simple rule-based prediction system
// In a future version, we can replace this with actual TensorFlow models
class PredictionService {
  static final PredictionService _instance = PredictionService._internal();
  factory PredictionService() => _instance;
  PredictionService._internal();

  // Analyze habit data and provide insights
  List<String> getHabitInsights(Habit habit) {
    List<String> insights = [];
    
    // Calculate completion rate
    final completionRate = habit.completionRate;
    
    // Check if habit is newly created (less than 7 days)
    final now = DateTime.now();
    final daysSinceCreation = now.difference(habit.createdAt).inDays;
    
    if (daysSinceCreation < 7) {
      insights.add('This is a new habit. Keep it up for the first week to build momentum!');
      return insights;
    }
    
    // Check streak
    if (habit.currentStreak > 0) {
      if (habit.currentStreak >= 21) {
        insights.add('Great job! You\'ve maintained this habit for ${habit.currentStreak} days. It\'s becoming automatic!');
      } else if (habit.currentStreak >= 7) {
        insights.add('You\'re on a ${habit.currentStreak}-day streak! Keep going to solidify this habit.');
      } else {
        insights.add('You have a ${habit.currentStreak}-day streak. Aim for 7 days to build momentum!');
      }
    } else {
      insights.add('You don\'t have an active streak. Try to get back on track today!');
    }
    
    // Analyze completion patterns
    if (completionRate > 80) {
      insights.add('You\'re doing great with this habit (${completionRate.toStringAsFixed(0)}% completion rate)!');
    } else if (completionRate > 50) {
      insights.add('You\'re making progress with this habit (${completionRate.toStringAsFixed(0)}% completion rate).');
    } else if (completionRate > 30) {
      insights.add('This habit needs more consistency (${completionRate.toStringAsFixed(0)}% completion rate).');
    } else {
      insights.add('This habit is challenging for you (${completionRate.toStringAsFixed(0)}% completion rate). Consider adjusting it.');
    }
    
    // Identify potential drop-off patterns
    final dropOffDay = identifyDropOffDay(habit);
    if (dropOffDay.isNotEmpty) {
      insights.add('You tend to skip this habit on $dropOffDay. Try to plan ahead for this day.');
    }
    
    return insights;
  }

  // Predict if the user is likely to drop the habit soon
  bool predictDropOff(Habit habit) {
    // Simple heuristic: If the user has skipped the habit 3+ times in the last 7 days,
    // they might be at risk of dropping it
    
    if (habit.completionRecord.isEmpty) return false;
    
    final now = DateTime.now();
    int missedDays = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      if (habit.completionRecord.containsKey(dateStr) && !habit.completionRecord[dateStr]!) {
        missedDays++;
      }
    }
    
    return missedDays >= 3;
  }

  // Identify days of week when the user tends to skip the habit
  String identifyDropOffDay(Habit habit) {
    if (habit.completionRecord.length < 14) return '';
    
    // Count failures by day of week
    Map<int, int> failuresByDay = {};
    Map<int, int> totalByDay = {};
    
    habit.completionRecord.forEach((dateStr, completed) {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      final dayOfWeek = date.weekday; // 1 = Monday, 7 = Sunday
      
      totalByDay[dayOfWeek] = (totalByDay[dayOfWeek] ?? 0) + 1;
      if (!completed) {
        failuresByDay[dayOfWeek] = (failuresByDay[dayOfWeek] ?? 0) + 1;
      }
    });
    
    // Calculate failure rates by day
    Map<int, double> failureRates = {};
    totalByDay.forEach((day, total) {
      if (total >= 2) { // Only consider days with enough data
        failureRates[day] = (failuresByDay[day] ?? 0) / total;
      }
    });
    
    // Find the day with highest failure rate (if it's significant)
    int worstDay = 0;
    double worstRate = 0;
    
    failureRates.forEach((day, rate) {
      if (rate > worstRate && rate > 0.5) { // Only consider significant failure rates
        worstDay = day;
        worstRate = rate;
      }
    });
    
    if (worstDay == 0) return '';
    
    // Convert day number to name
    final dayNames = ['', 'Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays'];
    return dayNames[worstDay];
  }

  // Get a personalized nudge message based on habit data
  String getPersonalizedNudge(Habit habit) {
    // Is this a new habit?
    final daysSinceCreation = DateTime.now().difference(habit.createdAt).inDays;
    if (daysSinceCreation < 3) {
      final newHabitMessages = [
        "Remember, it takes time to build a habit. Stay consistent with '${habit.title}' for the first week!",
        "You're just getting started with '${habit.title}'. The first week is crucial for building momentum!",
        "New habits take time to form. Keep focusing on '${habit.title}' each day this week.",
        "Give your new habit '${habit.title}' at least 7 days of consistency to make it stick.",
      ];
      
      final dayOfYear = DateTime.now().difference(DateTime(2000)).inDays;
      return newHabitMessages[dayOfYear % newHabitMessages.length];
    }
    
    // Is the user on a streak?
    if (habit.currentStreak > 0) {
      if (habit.currentStreak >= 10) {
        final longStreakMessages = [
          "Amazing! You're on a ${habit.currentStreak}-day streak with '${habit.title}'. Keep the momentum going!",
          "Impressive ${habit.currentStreak}-day streak on '${habit.title}'! You're building a strong habit.",
          "${habit.currentStreak} days in a row completing '${habit.title}'! You're making it part of your identity now.",
          "Your ${habit.currentStreak}-day streak on '${habit.title}' shows great discipline. Keep it up!",
        ];
        
        final dayOfYear = DateTime.now().difference(DateTime(2000)).inDays;
        return longStreakMessages[dayOfYear % longStreakMessages.length];
      } else {
        final shortStreakMessages = [
          "You're on a ${habit.currentStreak}-day streak with '${habit.title}'. Don't break the chain!",
          "Keep your ${habit.currentStreak}-day streak going with '${habit.title}' today!",
          "${habit.currentStreak} days and counting with '${habit.title}'. Build that momentum!",
          "Your ${habit.currentStreak}-day streak shows you're committed to '${habit.title}'. Keep going!",
        ];
        
        final dayOfYear = DateTime.now().difference(DateTime(2000)).inDays;
        return shortStreakMessages[dayOfYear % shortStreakMessages.length];
      }
    }
    
    // Did the user recently break a good streak?
    if (habit.longestStreak > 5 && habit.currentStreak == 0) {
      final brokenStreakMessages = [
        "You previously had a ${habit.longestStreak}-day streak with '${habit.title}'. You can do it again!",
        "Time to rebuild your streak for '${habit.title}'. You reached ${habit.longestStreak} days before!",
        "Your longest streak for '${habit.title}' was ${habit.longestStreak} days. Start a new streak today!",
        "Missing a day doesn't erase your progress. You can reach your ${habit.longestStreak}-day streak again!",
      ];
      
      final dayOfYear = DateTime.now().difference(DateTime(2000)).inDays;
      return brokenStreakMessages[dayOfYear % brokenStreakMessages.length];
    }
    
    // Default nudge - expanded list
    final nudges = [
      "Time to work on '${habit.title}'!",
      "Don't forget your habit: '${habit.title}'",
      "A small step today leads to big results. Complete '${habit.title}'!",
      "Building habits takes consistency. Focus on '${habit.title}' today.",
      "Remember to complete '${habit.title}' today to build momentum.",
      "One day at a time. Focus on '${habit.title}' today.",
      "Stay committed to '${habit.title}' - it gets easier with time.",
      "Just a quick reminder to complete '${habit.title}' today.",
      "Make '${habit.title}' a priority today for long-term success.",
      "Progress is built daily. Don't forget '${habit.title}' today.",
    ];
    
    // Cycle through nudges based on day of year
    final dayOfYear = DateTime.now().difference(DateTime(2000)).inDays;
    return nudges[dayOfYear % nudges.length];
  }
  
  // Get general stats and insights about all habits
  Map<String, dynamic> getOverallInsights(List<Habit> habits) {
    if (habits.isEmpty) {
      return {
        'totalHabits': 0,
        'averageCompletionRate': 0.0,
        'insights': ['Add your first habit to get started!'],
      };
    }
    
    // Calculate overall stats
    final activeHabits = habits.where((h) => h.isActive).toList();
    final avgCompletionRate = activeHabits.isEmpty
        ? 0.0
        : activeHabits.fold(0.0, (sum, h) => sum + h.completionRate) / activeHabits.length;
    
    final consistentHabits = activeHabits.where((h) => h.completionRate > 80).length;
    final strugglingHabits = activeHabits.where((h) => h.completionRate < 30 && h.completionRecord.length > 5).length;
    
    // Generate insights
    List<String> insights = [];
    
    if (activeHabits.isEmpty) {
      insights.add('You don\'t have any active habits. Add one to get started!');
    } else {
      insights.add('Your average completion rate is ${avgCompletionRate.toStringAsFixed(0)}%.');
      
      if (consistentHabits > 0) {
        insights.add('You\'re consistent with $consistentHabits habit${consistentHabits > 1 ? 's' : ''}.');
      }
      
      if (strugglingHabits > 0) {
        insights.add('You\'re struggling with $strugglingHabits habit${strugglingHabits > 1 ? 's' : ''}. Consider adjusting them.');
      }
      
      // Expanded list of tips to cycle through
      final tips = [
        'Tip: Stack new habits on existing routines for better success.',
        'Tip: Start with small, achievable habits and build from there.',
        'Tip: Track your habits daily, even when you miss them.',
        'Tip: Focus on consistency rather than perfection.',
        'Tip: Celebrate small wins to build motivation.',
        'Tip: If you miss a day, don\'t give up - just resume tomorrow.',
        'Tip: Break down complex habits into smaller steps.',
        'Tip: Connect your habits to your personal values for long-term success.',
        'Tip: Use visual cues in your environment to trigger your habits.',
        'Tip: Share your habit goals with others for accountability.',
        'Tip: Review your progress weekly to stay motivated.',
        'Tip: Adjust habit difficulty if you\'re consistently struggling.',
        'Tip: Pair a habit you want to do with one you need to do.',
        'Tip: Be specific about when and where you\'ll perform your habit.',
        'Tip: Remove friction that makes habits harder to complete.',
      ];
      
      // Use day of year + habit count to select different tips on different days
      // and for different users with different habit counts
      final dayOfYear = DateTime.now().difference(DateTime(2000)).inDays;
      final tipIndex = (dayOfYear + activeHabits.length) % tips.length;
      insights.add(tips[tipIndex]);
    }
    
    return {
      'totalHabits': activeHabits.length,
      'averageCompletionRate': avgCompletionRate,
      'consistentHabits': consistentHabits,
      'strugglingHabits': strugglingHabits,
      'insights': insights,
    };
  }
} 