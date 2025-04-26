import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/habit_provider.dart';
import 'services/database_service.dart';
import 'services/theme_preference_service.dart';
import 'services/reminder_service.dart';
import 'services/notification_service.dart';
import 'services/achievement_service.dart';
import 'services/auth_service.dart';
import 'services/user_data_service.dart';
import 'utils/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/theme_preference_dialog.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.initializeDatabaseFactory();
  
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  
  // Initialize achievement service
  final achievementService = AchievementService();
  await achievementService.initialize();
  
  // Load theme preference
  final themeService = ThemePreferenceService();
  await themeService.loadThemePreference();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemePreferenceService _themeService = ThemePreferenceService();
  final ReminderService _reminderService = ReminderService();
  final NotificationService _notificationService = NotificationService();
  final AchievementService _achievementService = AchievementService();
  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    // We'll check for theme preference after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkThemePreference();
    });
  }
  
  Future<void> _checkThemePreference() async {
    // Use navigatorKey.currentContext to get a valid context after build is complete
    final hasShownDialog = await _themeService.hasShownPreferenceDialog();
    if (!hasShownDialog && _reminderService.navigatorKey.currentContext != null) {
      _showThemePreferenceDialog(_reminderService.navigatorKey.currentContext!);
    }
  }
  
  void _showThemePreferenceDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ThemePreferenceDialog(
        onThemeSelected: (isDarkMode) {
          setState(() {
            // This will rebuild the app with the new theme
          });
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HabitProvider()),
        Provider<ReminderService>(create: (context) => _reminderService),
        Provider<NotificationService>(create: (context) => _notificationService),
        ChangeNotifierProvider<AchievementService>(create: (context) => _achievementService),
        ChangeNotifierProvider<AuthService>(create: (context) => _authService),
        ChangeNotifierProxyProvider<AuthService, UserDataService>(
          create: (context) => UserDataService(_authService),
          update: (context, auth, previous) => previous ?? UserDataService(auth),
        ),
      ],
      child: MaterialApp(
        title: 'HabitFlow',
        theme: AppTheme.getTheme(),
        home: _authService.isLoggedIn ? const HomeScreen() : const LoginScreen(),
        navigatorKey: _reminderService.navigatorKey,
        debugShowCheckedModeBanner: false,
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
