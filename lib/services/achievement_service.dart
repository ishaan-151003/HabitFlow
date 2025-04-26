import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/habit.dart';

class AchievementService extends ChangeNotifier {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();
  
  List<Achievement> _achievements = [];
  bool _isLoaded = false;
  
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.isUnlocked).toList();
  
  // Initialize achievements
  Future<void> initialize() async {
    if (_isLoaded) return;
    
    // Load achievements from shared preferences
    await _loadAchievements();
    
    // If no achievements found, initialize with defaults
    if (_achievements.isEmpty) {
      _achievements = AchievementList.defaultAchievements;
      await _saveAchievements();
    }
    
    _isLoaded = true;
    notifyListeners();
  }
  
  // Load achievements from storage
  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString('achievements');
      
      if (achievementsJson != null) {
        final List<dynamic> decodedList = json.decode(achievementsJson);
        _achievements = decodedList
            .map((item) => Achievement.fromMap(item))
            .toList();
      } else {
        _achievements = [];
      }
    } catch (e) {
      debugPrint('Error loading achievements: $e');
      _achievements = [];
    }
  }
  
  // Save achievements to storage
  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = json.encode(
        _achievements.map((a) => a.toMap()).toList()
      );
      await prefs.setString('achievements', achievementsJson);
    } catch (e) {
      debugPrint('Error saving achievements: $e');
    }
  }
  
  // Check and update achievements based on user's habits and streaks
  Future<List<Achievement>> checkAchievements({
    required List<Habit> habits,
    required int currentStreak,
    required int completedToday,
    required DateTime now,
  }) async {
    await initialize();
    
    final List<Achievement> newlyUnlocked = [];
    
    // Track which achievements we need to update
    final List<Achievement> updatedAchievements = [];
    
    // Check streak achievements
    for (final achievement in _achievements.where(
        (a) => a.category == AchievementCategory.streak && !a.isUnlocked)) {
      if (currentStreak >= achievement.requiredCount) {
        final unlockedAchievement = achievement.copyWith(unlockedAt: now);
        updatedAchievements.add(unlockedAchievement);
        newlyUnlocked.add(unlockedAchievement);
      }
    }
    
    // Check completion achievements
    final int totalCompletions = habits.fold<int>(0, 
        (sum, habit) => sum + habit.completions.length);
    
    for (final achievement in _achievements.where(
        (a) => a.category == AchievementCategory.completion && !a.isUnlocked)) {
      if (totalCompletions >= achievement.requiredCount) {
        final unlockedAchievement = achievement.copyWith(unlockedAt: now);
        updatedAchievements.add(unlockedAchievement);
        newlyUnlocked.add(unlockedAchievement);
      }
    }
    
    // Check special achievements (early bird & night owl)
    final earlyBird = _achievements.firstWhere(
        (a) => a.id == 6 && a.category == AchievementCategory.special);
        
    if (!earlyBird.isUnlocked && completedToday > 0 && now.hour < 8) {
      final unlockedAchievement = earlyBird.copyWith(unlockedAt: now);
      updatedAchievements.add(unlockedAchievement);
      newlyUnlocked.add(unlockedAchievement);
    }
    
    final nightOwl = _achievements.firstWhere(
        (a) => a.id == 7 && a.category == AchievementCategory.special);
        
    if (!nightOwl.isUnlocked && completedToday > 0 && now.hour >= 22) {
      final unlockedAchievement = nightOwl.copyWith(unlockedAt: now);
      updatedAchievements.add(unlockedAchievement);
      newlyUnlocked.add(unlockedAchievement);
    }
    
    // Update achievements list with newly unlocked ones
    if (updatedAchievements.isNotEmpty) {
      for (final updatedAchievement in updatedAchievements) {
        final index = _achievements.indexWhere((a) => a.id == updatedAchievement.id);
        if (index >= 0) {
          _achievements[index] = updatedAchievement;
        }
      }
      
      await _saveAchievements();
      notifyListeners();
    }
    
    return newlyUnlocked;
  }
  
  // Reset all achievements (for testing)
  Future<void> resetAchievements() async {
    _achievements = AchievementList.defaultAchievements;
    await _saveAchievements();
    notifyListeners();
  }
} 