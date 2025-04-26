import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/theme_preference_service.dart';

class ThemePreferenceDialog extends StatelessWidget {
  final Function(bool) onThemeSelected;
  
  const ThemePreferenceDialog({
    Key? key,
    required this.onThemeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select your preferred theme for HabitFlow:'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildThemeOption(
                context, 
                'Light', 
                Icons.light_mode,
                false,
              ),
              _buildThemeOption(
                context, 
                'Dark', 
                Icons.dark_mode,
                true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, 
    String label, 
    IconData icon,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: () {
        _selectTheme(context, isDarkMode);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isDarkMode ? Colors.white : AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTheme(BuildContext context, bool isDarkMode) async {
    // Save the preference
    final themeService = ThemePreferenceService();
    await themeService.saveThemePreference(isDarkMode);
    await themeService.setHasShownPreferenceDialog();
    
    // Call the callback
    onThemeSelected(isDarkMode);
    
    // Close the dialog
    Navigator.of(context).pop();
  }
} 