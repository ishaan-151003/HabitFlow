import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habit_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';
import 'dashboard_tab.dart';
import 'habits_tab.dart';
import 'insights_tab.dart';
import 'habit_form_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = const [
    DashboardTab(),
    HabitsTab(),
    InsightsTab(),
    ProfileScreen(),
  ];
  
  final PageController _pageController = PageController();
  
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to defer the service initialization until after the build phase
    Future.microtask(() => _initializeServices());
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeServices() async {
    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermissions();
    
    // Load habits
    if (mounted) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      await habitProvider.loadHabits();
    }
  }
  
  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: AppTheme.defaultAnimationDuration,
      curve: AppTheme.defaultAnimationCurve,
    );
    setState(() {
      _currentIndex = index;
    });
  }
  
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 3 ? null : AppBar(
        title: const Text('HabitFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping between pages
        children: _tabs,
      ),
      floatingActionButton: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _currentIndex == 1 ? 1.0 : 0.0, // Only show on Habits tab
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToAddHabit(),
          icon: const Icon(Icons.add),
          label: const Text('New Habit'),
          elevation: 4,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                activeIcon: Icon(Icons.dashboard, size: 28),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.repeat),
                activeIcon: Icon(Icons.repeat, size: 28),
                label: 'Habits',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insert_chart),
                activeIcon: Icon(Icons.insert_chart, size: 28),
                label: 'Insights',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                activeIcon: Icon(Icons.person, size: 28),
                label: 'Profile',
              ),
            ],
            elevation: 0,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondaryColor,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
  
  void _navigateToAddHabit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HabitFormScreen(),
      ),
    );
  }
} 