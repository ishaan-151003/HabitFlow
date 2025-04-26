import 'package:flutter/material.dart';
import '../services/reminder_service.dart';
import '../services/theme_preference_service.dart';
import '../utils/app_theme.dart';
import 'reminder_settings_screen.dart';
import 'achievements_screen.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ReminderService _reminderService = ReminderService();
  final ThemePreferenceService _themeService = ThemePreferenceService();

  // Toggle dark theme and save preference
  Future<void> _toggleDarkTheme(bool value) async {
    await _themeService.saveThemePreference(value);
    
    setState(() {
      // Theme is already updated in the service
    });
    
    // Restart the app to apply theme changes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => 
        const RestartWidget(child: MyAppRoot())),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Section: Notifications
          _buildSectionHeader(context, 'Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Reminders'),
            subtitle: const Text('Configure daily habit reminders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReminderSettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notification_important_outlined),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification'),
            trailing: const Icon(Icons.send),
            onTap: () async {
              await _reminderService.sendTestReminder();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test notification sent!')),
              );
            },
          ),
          const Divider(),
          
          // Section: App Settings
          _buildSectionHeader(context, 'App Settings'),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Habit Insights'),
            subtitle: const Text('View detailed analytics and trends'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to insights or show a coming soon message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.celebration_outlined),
            title: const Text('Achievements'),
            subtitle: const Text('View your earned badges and milestones'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to achievements screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AchievementsScreen()),
              );
            },
          ),
          SwitchListTile(
            secondary: Icon(
              AppTheme.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.isDarkMode ? Colors.white70 : null,
            ),
            title: const Text('Dark Theme'),
            subtitle: Text(AppTheme.isDarkMode ? 'Using dark theme' : 'Using light theme'),
            value: AppTheme.isDarkMode,
            onChanged: _toggleDarkTheme,
          ),
          const Divider(),
          
          // Section: Data & Privacy
          _buildSectionHeader(context, 'Data & Privacy'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Backup your habit data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // To be implemented: Backup & Restore
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all habits and settings'),
            trailing: const Icon(Icons.warning, color: Colors.red),
            onTap: () {
              _showClearDataConfirmation();
            },
          ),
          const Divider(),
          
          // Section: About
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.accentColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
  
  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This action will delete all your habits, progress data, and settings. This cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              // To be implemented: Clear all data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}

// Widget to restart the app when theme changes
class RestartWidget extends StatefulWidget {
  final Widget child;
  
  const RestartWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
  
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();
  
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

// Placeholder for MyAppRoot, reference to main app widget
class MyAppRoot extends StatelessWidget {
  const MyAppRoot({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // This should match your main app structure from main.dart
    return MaterialApp(
      title: 'HabitFlow',
      theme: AppTheme.getTheme(),
      home: const MainAppEntry(),
    );
  }
}

// Temporary widget to redirect to home screen
class MainAppEntry extends StatefulWidget {
  const MainAppEntry({Key? key}) : super(key: key);
  
  @override
  State<MainAppEntry> createState() => _MainAppEntryState();
}

class _MainAppEntryState extends State<MainAppEntry> {
  @override
  void initState() {
    super.initState();
    // Navigate to home screen on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 