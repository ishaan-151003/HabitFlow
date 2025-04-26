import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'notification_service.dart';
import '../models/habit.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();
  
  final NotificationService _notificationService = NotificationService();
  
  // Check if we're running on Windows
  bool get isWindows => Platform.isWindows;
  
  // Global key to access navigator state from anywhere
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Schedule a reminder for a specific habit
  Future<void> scheduleHabitReminder(Habit habit, TimeOfDay reminderTime) async {
    if (habit.id == null) return;
    
    final int notificationId = habit.id!;
    final title = 'Reminder: ${habit.title}';
    final body = 'Don\'t forget to complete your habit: ${habit.title}';
    
    await _notificationService.scheduleDailyReminder(
      id: notificationId,
      title: title,
      body: body,
      hour: reminderTime.hour,
      minute: reminderTime.minute,
    );
    
    final formattedTime = '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}';
    debugPrint('Scheduled reminder for habit ${habit.title} at $formattedTime');
    
    // For Windows platforms, show confirmation dialog
    if (isWindows) {
      _showWindowsReminderConfirmation(title, body, formattedTime);
    }
  }
  
  // Cancel a reminder for a specific habit
  Future<void> cancelHabitReminder(int habitId) async {
    await _notificationService.cancelNotification(habitId);
    debugPrint('Cancelled reminder for habit ID: $habitId');
  }
  
  // Cancel all reminders
  Future<void> cancelAllReminders() async {
    await _notificationService.cancelAllNotifications();
    debugPrint('Cancelled all habit reminders');
  }
  
  // Send a test notification for debugging
  Future<void> sendTestReminder() async {
    await _notificationService.showNotification(
      id: 9999,
      title: 'Test Reminder',
      body: 'This is a test reminder notification',
    );
    debugPrint('Sent test reminder notification');
    
    // For Windows platforms, show dialog
    if (isWindows) {
      _showWindowsReminderConfirmation(
        'Test Reminder', 
        'This is a test reminder notification',
        'now'
      );
    }
  }
  
  // Show Windows reminder dialog
  void _showWindowsReminderConfirmation(String title, String body, String time) {
    // Find the navigator context
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('Cannot show Windows reminder dialog - no context available');
      return;
    }
    
    // Show a material dialog instead of system notification
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body),
            const SizedBox(height: 8),
            Text('Scheduled for: $time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              'Note: On Windows, system notifications are not fully supported. '
              'This dialog confirms your reminder has been scheduled, but you\'ll need to '
              'keep the app running to receive reminders.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  // Schedule a notification for incomplete habits
  Future<void> scheduleIncompleteHabitsReminder(List<Habit> habits, TimeOfDay reminderTime) async {
    // Filter for incomplete habits today
    final today = DateTime.now();
    final incompleteHabits = habits.where((h) => 
      h.isActive && !h.isCompletedOnDate(today)
    ).toList();
    
    if (incompleteHabits.isEmpty) return;
    
    // Create a combined notification for all incomplete habits
    final habitNames = incompleteHabits.map((h) => h.title).join(', ');
    final title = 'You have ${incompleteHabits.length} incomplete habits';
    final body = 'Remember to complete: $habitNames';
    
    // Use a fixed ID for the combined notification
    const int combinedNotificationId = 8888;
    
    await _notificationService.scheduleDailyReminder(
      id: combinedNotificationId,
      title: title,
      body: body,
      hour: reminderTime.hour,
      minute: reminderTime.minute,
    );
    
    final formattedTime = '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}';
    debugPrint('Scheduled combined reminder for ${incompleteHabits.length} incomplete habits at $formattedTime');
    
    // For Windows platforms, show confirmation dialog
    if (isWindows) {
      _showWindowsReminderConfirmation(title, body, formattedTime);
    }
  }
} 