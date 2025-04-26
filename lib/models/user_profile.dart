import 'package:flutter/foundation.dart';

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLogin,
    this.preferences = const {},
  });

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: this.id,
      email: this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'preferences': preferences,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: DateTime.parse(map['lastLogin']),
      preferences: map['preferences'] ?? {},
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, displayName: $displayName)';
  }
} 