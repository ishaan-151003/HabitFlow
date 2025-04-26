import 'package:flutter/material.dart';

/// Achievement model for gamification
class Achievement {
  final int id;
  final String title;
  final String description;
  final IconData icon;
  final int requiredCount;
  final AchievementCategory category;
  final DateTime? unlockedAt;
  
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.category,
    this.unlockedAt,
  });
  
  bool get isUnlocked => unlockedAt != null;
  
  Achievement copyWith({
    int? id,
    String? title,
    String? description, 
    IconData? icon,
    int? requiredCount,
    AchievementCategory? category,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      requiredCount: requiredCount ?? this.requiredCount,
      category: category ?? this.category,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'requiredCount': requiredCount,
      'category': category.index,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }
  
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      icon: IconData(
        map['iconCodePoint'],
        fontFamily: map['iconFontFamily'],
      ),
      requiredCount: map['requiredCount'],
      category: AchievementCategory.values[map['category']],
      unlockedAt: map['unlockedAt'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['unlockedAt'])
        : null,
    );
  }
}

/// Categories for different achievement types
enum AchievementCategory {
  streak,
  completion,
  consistency,
  special
}

/// Predefined achievements
class AchievementList {
  static final List<Achievement> defaultAchievements = [
    // Streak achievements
    Achievement(
      id: 1,
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: Icons.local_fire_department,
      requiredCount: 7,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 2,
      title: 'Month Master',
      description: 'Maintain a 30-day streak',
      icon: Icons.whatshot,
      requiredCount: 30,
      category: AchievementCategory.streak,
    ),
    
    // Completion achievements
    Achievement(
      id: 3,
      title: 'Habit Hunter',
      description: 'Complete 50 habits',
      icon: Icons.check_circle,
      requiredCount: 50,
      category: AchievementCategory.completion,
    ),
    Achievement(
      id: 4,
      title: 'Century Club',
      description: 'Complete 100 habits',
      icon: Icons.verified,
      requiredCount: 100,
      category: AchievementCategory.completion,
    ),
    
    // Consistency achievements
    Achievement(
      id: 5,
      title: 'Perfect Week',
      description: 'Complete all habits for 7 consecutive days',
      icon: Icons.star,
      requiredCount: 7,
      category: AchievementCategory.consistency,
    ),
    
    // Special achievements
    Achievement(
      id: 6,
      title: 'Early Bird',
      description: 'Complete a habit before 8 AM',
      icon: Icons.wb_sunny,
      requiredCount: 1,
      category: AchievementCategory.special,
    ),
    Achievement(
      id: 7,
      title: 'Night Owl',
      description: 'Complete a habit after 10 PM',
      icon: Icons.nightlight_round,
      requiredCount: 1,
      category: AchievementCategory.special,
    ),
  ];
} 