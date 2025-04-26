import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../services/habit_provider.dart';
import '../services/reminder_service.dart';
import '../utils/app_theme.dart';

class ReminderSettingsScreen extends StatefulWidget {
  final Habit? habit; // Optional - if provided, we set reminder for specific habit

  const ReminderSettingsScreen({
    Key? key,
    this.habit,
  }) : super(key: key);

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final ReminderService _reminderService = ReminderService();
  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0); // Default to 8:00 PM
  
  // Keys for storing reminder preferences
  static const String _keyReminderEnabled = 'reminder_enabled';
  static const String _keyReminderHour = 'reminder_hour';
  static const String _keyReminderMinute = 'reminder_minute';
  static const String _keyHabitReminderPrefix = 'habit_reminder_';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  // Load saved reminder settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (widget.habit != null) {
      // Habit-specific reminder
      final habitKey = _keyHabitReminderPrefix + widget.habit!.id.toString();
      final isEnabled = prefs.getBool('${habitKey}_enabled') ?? false;
      final hour = prefs.getInt('${habitKey}_hour') ?? 20;
      final minute = prefs.getInt('${habitKey}_minute') ?? 0;
      
      setState(() {
        _isReminderEnabled = isEnabled;
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
      });
    } else {
      // General reminder for all habits
      final isEnabled = prefs.getBool(_keyReminderEnabled) ?? false;
      final hour = prefs.getInt(_keyReminderHour) ?? 20;
      final minute = prefs.getInt(_keyReminderMinute) ?? 0;
      
      setState(() {
        _isReminderEnabled = isEnabled;
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
      });
    }
  }
  
  // Pick time for reminder
  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null) {
      setState(() {
        _reminderTime = pickedTime;
      });
    }
  }
  
  // Save reminder settings
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (widget.habit != null) {
      // For habit-specific reminder
      final habitKey = _keyHabitReminderPrefix + widget.habit!.id.toString();
      
      // Save to SharedPreferences
      await prefs.setBool('${habitKey}_enabled', _isReminderEnabled);
      await prefs.setInt('${habitKey}_hour', _reminderTime.hour);
      await prefs.setInt('${habitKey}_minute', _reminderTime.minute);
      
      // Schedule or cancel reminder
      if (_isReminderEnabled) {
        await _reminderService.scheduleHabitReminder(widget.habit!, _reminderTime);
      } else {
        await _reminderService.cancelHabitReminder(widget.habit!.id!);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit reminder settings saved!')),
      );
    } else {
      // For all habits reminder
      // Save to SharedPreferences
      await prefs.setBool(_keyReminderEnabled, _isReminderEnabled);
      await prefs.setInt(_keyReminderHour, _reminderTime.hour);
      await prefs.setInt(_keyReminderMinute, _reminderTime.minute);
      
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final habits = habitProvider.activeHabits;
      
      if (_isReminderEnabled) {
        await _reminderService.scheduleIncompleteHabitsReminder(habits, _reminderTime);
        
        // Send a test notification to confirm it's working
        await _reminderService.sendTestReminder();
      } else {
        await _reminderService.cancelAllReminders();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder settings saved!')),
      );
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isHabitSpecific = widget.habit != null;
    final String title = isHabitSpecific 
        ? 'Reminder for ${widget.habit!.title}'
        : 'Reminder Settings';
        
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Description
            Text(
              'Set Reminder',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              isHabitSpecific
                  ? 'Configure a daily reminder for this habit.'
                  : 'Configure daily reminders for your habits.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // Enable/Disable Reminder Switch
            SwitchListTile(
              title: Text(
                'Enable Reminder',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Get notified at a specific time',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _isReminderEnabled,
              activeColor: AppTheme.accentColor,
              onChanged: (value) {
                setState(() {
                  _isReminderEnabled = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Time Picker
            ListTile(
              title: Text(
                'Reminder Time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Select when you want to receive the reminder',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: TextButton(
                onPressed: _isReminderEnabled ? _pickTime : null,
                child: Text(
                  _reminderTime.format(context),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isReminderEnabled
                        ? AppTheme.accentColor
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 