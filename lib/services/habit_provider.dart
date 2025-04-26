import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'package:intl/intl.dart';
import 'database_service.dart';
import 'achievement_service.dart';

class HabitProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final AchievementService _achievementService = AchievementService();
  List<Habit> _habits = [];
  bool _isLoading = false;

  // Getters
  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  List<Habit> get activeHabits => _habits.where((h) => h.isActive).toList();

  // Initialize provider and load habits
  Future<void> loadHabits({bool activeOnly = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _databaseService.getHabits(activeOnly: activeOnly);
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new habit
  Future<void> addHabit(Habit habit) async {
    try {
      final id = await _databaseService.insertHabit(habit);
      final newHabit = habit.copyWith(id: id);
      _habits.add(newHabit);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding habit: $e');
    }
  }

  // Update an existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    try {
      await _databaseService.updateHabit(updatedHabit);
      final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (index != -1) {
        _habits[index] = updatedHabit;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
    }
  }

  // Delete a habit
  Future<void> deleteHabit(int id) async {
    try {
      await _databaseService.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting habit: $e');
    }
  }

  // Archive a habit
  Future<void> archiveHabit(int id) async {
    try {
      await _databaseService.archiveHabit(id);
      final index = _habits.indexWhere((h) => h.id == id);
      if (index != -1) {
        final updatedHabit = _habits[index].copyWith(isActive: false);
        _habits[index] = updatedHabit;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error archiving habit: $e');
    }
  }

  // Toggle habit completion for a specific date
  Future<void> toggleHabitCompletion(int habitId, DateTime date, {BuildContext? context}) async {
    try {
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        final updatedHabit = _habits[index].toggleCompletion(date);
        await _databaseService.updateHabit(updatedHabit);
        _habits[index] = updatedHabit;
        
        // Check for achievements after completing a habit
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        if (date.year == today.year && date.month == today.month && date.day == today.day) {
          final streakData = getStreakData();
          final completedToday = _habits.where((h) => 
            h.isActive && h.isCompletedOnDate(today)).length;
            
          final newAchievements = await _achievementService.checkAchievements(
            habits: _habits,
            currentStreak: streakData['totalCurrent'] ?? 0,
            completedToday: completedToday,
            now: now,
          );
          
          // Show achievement earned notifications if there are any new achievements
          if (newAchievements.isNotEmpty && context != null) {
            for (final achievement in newAchievements) {
              _showAchievementEarned(context, achievement.title);
            }
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling habit completion: $e');
    }
  }
  
  // Show a notification when an achievement is earned
  void _showAchievementEarned(BuildContext context, String achievementTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Achievement Unlocked: $achievementTitle',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to achievements screen
            // This will be implemented in a later update
          },
        ),
      ),
    );
  }

  // Get habits with highest completion rate
  List<Habit> getTopHabits({int limit = 5}) {
    final activeHabits = _habits.where((h) => h.isActive).toList();
    activeHabits.sort((a, b) => b.completionRate.compareTo(a.completionRate));
    return activeHabits.take(limit).toList();
  }

  // Get habits with lowest completion rate (needs attention)
  List<Habit> getHabitsNeedingAttention({int limit = 5}) {
    final activeHabits = _habits.where((h) => h.isActive).toList();
    // Only include habits with at least a few days of data
    final habitsWithData = activeHabits.where((h) => h.completionRecord.length > 3).toList();
    habitsWithData.sort((a, b) => a.completionRate.compareTo(b.completionRate));
    return habitsWithData.take(limit).toList();
  }

  // Get streak data with proper calculations
  Map<String, int> getStreakData() {
    final activeHabits = _habits.where((h) => h.isActive).toList();
    
    // Calculate the accurate streak totals
    int totalCurrentStreak = 0;
    int totalLongestStreak = 0;
    int streakCount = 0;
    
    // Process each habit individually for accurate counting
    for (final habit in activeHabits) {
      // Only count current streak if it's actually active (> 0)
      if (habit.currentStreak > 0) {
        totalCurrentStreak += habit.currentStreak;
        streakCount++;
      }
      
      // Always add the longest streak to the total
      totalLongestStreak += habit.longestStreak;
    }
    
    return {
      'totalCurrent': totalCurrentStreak,
      'totalLongest': totalLongestStreak,
      'streakCount': streakCount,
    };
  }
} 