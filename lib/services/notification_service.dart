import 'package:flutter/material.dart';
// Comment out flutter_local_notifications since it's causing issues with Android 15
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  // Comment out the notifications plugin initialization
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
  //     FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  
  // Helper method for platform detection - stub implementation
  bool get isWindows => false;
  bool get isAndroid => false;
  bool get isWeb => true; // Assuming we're on web for now

  // Initialize notifications
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize time zones for scheduled notifications
      tz_data.initializeTimeZones();
      
      /*
      if (isAndroid) {
        // Android initialization settings
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');
            
        // Initialize notifications
        const InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
        );
        
        await flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
            debugPrint('Notification clicked: ${notificationResponse.payload}');
          },
        );
        
        debugPrint('Android notification service initialized');
      } else {
        debugPrint('Stub notification service initialized (non-Android platform)');
      }
      */
      
      // Simplified initialization 
      debugPrint('Notification service initialized in stub mode');
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }
  
  // Request permissions for notifications
  Future<void> requestPermissions() async {
    debugPrint('Stub notification permissions requested');
  }
  
  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    debugPrint('Stub notification (not shown): $title - $body');
  }
  
  // Schedule a daily reminder
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await initialize();
    debugPrint('Stub scheduled reminder (not functional): $title at $hour:$minute');
  }
  
  // Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    debugPrint('Canceled notification: $id (stubbed)');
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    debugPrint('Canceled all notifications (stubbed)');
  }
} 