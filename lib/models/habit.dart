import 'dart:convert';
import 'package:intl/intl.dart';

class Habit {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String frequency; // daily, weekly, etc.
  final int targetDays; // target number of days to build habit
  final int currentStreak;
  final int longestStreak;
  final bool isActive;
  final Map<String, bool> completionRecord; // date string -> completed (true/false)

  Habit({
    this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.targetDays,
    DateTime? createdAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isActive = true,
    Map<String, bool>? completionRecord,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.completionRecord = completionRecord ?? {};

  // Convert Habit to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': DateFormat('yyyy-MM-dd').format(createdAt),
      'frequency': frequency,
      'target_days': targetDays,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'is_active': isActive ? 1 : 0,
      'completion_record': jsonEncode(completionRecord),
    };
  }

  // Create Habit from Map (from database)
  factory Habit.fromMap(Map<String, dynamic> map) {
    // Parse completion record from JSON string
    String completionRecordStr = map['completion_record'] ?? '{}';
    Map<String, bool> completionRecord = {};
    
    try {
      // First try to parse as JSON (for newly created records)
      Map<String, dynamic> jsonMap = jsonDecode(completionRecordStr);
      jsonMap.forEach((key, value) {
        completionRecord[key] = value == true;
      });
    } catch (e) {
      // Fallback for old records using the string format
      if (completionRecordStr.length > 2) {
        completionRecordStr = completionRecordStr.substring(1, completionRecordStr.length - 1);
        completionRecordStr.split(',').forEach((item) {
          List<String> keyValue = item.trim().split(':');
          if (keyValue.length == 2) {
            String key = keyValue[0].trim();
            // Remove any quotes from the key
            key = key.replaceAll('"', '').replaceAll("'", '');
            
            bool value = keyValue[1].trim().toLowerCase() == 'true';
            completionRecord[key] = value;
          }
        });
      }
    }

    return Habit(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateFormat('yyyy-MM-dd').parse(map['created_at']),
      frequency: map['frequency'],
      targetDays: map['target_days'],
      currentStreak: map['current_streak'],
      longestStreak: map['longest_streak'],
      isActive: map['is_active'] == 1,
      completionRecord: completionRecord,
    );
  }

  // Create a copy of Habit with given fields replaced with new values
  Habit copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? frequency,
    int? targetDays,
    int? currentStreak,
    int? longestStreak,
    bool? isActive,
    Map<String, bool>? completionRecord,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      isActive: isActive ?? this.isActive,
      completionRecord: completionRecord ?? Map.from(this.completionRecord),
    );
  }

  // Check if habit was completed on a specific date
  bool isCompletedOnDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return completionRecord[dateStr] ?? false;
  }
  
  // Check if habit should be completed on a specific date
  bool shouldCompleteOnDate(DateTime date) {
    // For now, we'll assume all habits should be completed daily
    // You can enhance this with more complex logic based on frequency
    return true;
  }
  
  // Get the best streak for this habit
  int get bestStreak => longestStreak;

  // Toggle completion status for a specific date
  Habit toggleCompletion(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final newCompletionRecord = Map<String, bool>.from(completionRecord);
    
    // Toggle completion status
    newCompletionRecord[dateStr] = !(completionRecord[dateStr] ?? false);
    
    // Calculate new streak
    final streakData = calculateStreaks(newCompletionRecord);
    
    return copyWith(
      completionRecord: newCompletionRecord,
      currentStreak: streakData['currentStreak'],
      longestStreak: streakData['longestStreak'],
    );
  }

  // Calculate current and longest streaks based on completion record
  Map<String, int> calculateStreaks(Map<String, bool> record) {
    int currentStreak = 0;
    int longestStreak = this.longestStreak;
    int tempStreak = 0;
    
    // Get sorted dates from completion record
    List<DateTime> dates = record.keys
        .map((dateStr) => DateFormat('yyyy-MM-dd').parse(dateStr))
        .toList();
    dates.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
    
    if (dates.isEmpty) {
      return {'currentStreak': 0, 'longestStreak': longestStreak};
    }
    
    // Calculate streaks correctly, accounting for consecutive days
    DateTime lastDate = DateTime.now();
    bool isCurrentStreak = true;
    
    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final completed = record[dateStr] ?? false;
      
      if (!completed) {
        // Not completed, reset temp streak
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        
        if (isCurrentStreak) {
          currentStreak = tempStreak;
          isCurrentStreak = false;
        }
        
        tempStreak = 0;
        continue;
      }
      
      // Check for day break (more than 1 day gap)
      if (i > 0) {
        final dayDifference = lastDate.difference(date).inDays;
        
        if (dayDifference > 1) {
          // Break in streak, reset temp streak
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          
          if (isCurrentStreak) {
            currentStreak = tempStreak;
            isCurrentStreak = false;
          }
          
          tempStreak = 1; // Start a new streak with this completed day
          lastDate = date;
          continue;
        }
      }
      
      // Increment streak (consecutive day completed)
      tempStreak++;
      lastDate = date;
    }
    
    // Check if the final streak is the longest
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }
    
    // If we're still in the current streak, update it
    if (isCurrentStreak) {
      currentStreak = tempStreak;
    }
    
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  // Get completion rate as percentage
  double get completionRate {
    if (completionRecord.isEmpty) return 0.0;
    
    int completed = completionRecord.values.where((v) => v).length;
    return completed / completionRecord.length * 100;
  }
  
  // Get completed entries as a list
  List<String> get completions {
    return completionRecord.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
} 