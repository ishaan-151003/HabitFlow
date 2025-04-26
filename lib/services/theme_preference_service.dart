import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class ThemePreferenceService {
  static final ThemePreferenceService _instance = ThemePreferenceService._internal();
  factory ThemePreferenceService() => _instance;
  ThemePreferenceService._internal();
  
  static const String _themePreferenceKey = 'theme_preference';
  static const String _hasShownPreferenceDialogKey = 'has_shown_theme_preference_dialog';
  
  // Check if we have shown the theme preference dialog before
  Future<bool> hasShownPreferenceDialog() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasShownPreferenceDialogKey) ?? false;
  }
  
  // Mark that we have shown the theme preference dialog
  Future<void> setHasShownPreferenceDialog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasShownPreferenceDialogKey, true);
  }
  
  // Save theme preference
  Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, isDarkMode);
    AppTheme.isDarkMode = isDarkMode;
  }
  
  // Load saved theme preference
  Future<bool> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
    AppTheme.isDarkMode = isDarkMode;
    return isDarkMode;
  }
} 