import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import 'database_service.dart';
import 'auth_service.dart';

class UserDataService with ChangeNotifier {
  final DatabaseService _localDatabase = DatabaseService();
  final AuthService _authService;
  bool _isSyncing = false;
  String? _syncError;

  bool get isSyncing => _isSyncing;
  String? get syncError => _syncError;

  UserDataService(this._authService) {
    // Listen to auth changes to sync data when user logs in/out
    _authService.addListener(_handleAuthChange);
  }

  @override
  void dispose() {
    _authService.removeListener(_handleAuthChange);
    super.dispose();
  }

  void _handleAuthChange() async {
    if (_authService.isLoggedIn) {
      // User just logged in, sync data from local storage
      await syncDataFromCloud();
    }
  }

  // Sync all user habits from local database
  Future<bool> syncDataFromCloud() async {
    _isSyncing = true;
    _syncError = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error syncing data from cloud: $e');
      _syncError = 'Failed to sync data from cloud';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }
  
  // Save a habit to local database
  Future<bool> saveHabit(Habit habit) async {
    try {
      // Save to local database
      await _localDatabase.insertHabit(habit);
      return true;
    } catch (e) {
      debugPrint('Error saving habit: $e');
      _syncError = 'Failed to save habit';
      notifyListeners();
      return false;
    }
  }
  
  // Update a habit in local database
  Future<bool> updateHabit(Habit habit) async {
    try {
      await _localDatabase.updateHabit(habit);
      return true;
    } catch (e) {
      debugPrint('Error updating habit: $e');
      _syncError = 'Failed to update habit';
      notifyListeners();
      return false;
    }
  }
  
  // Delete a habit from local database
  Future<bool> deleteHabit(int id) async {
    try {
      await _localDatabase.deleteHabit(id);
      return true;
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      _syncError = 'Failed to delete habit';
      notifyListeners();
      return false;
    }
  }
  
  // Push all local data (dummy method for compatibility)
  Future<bool> pushAllDataToCloud() async {
    _isSyncing = true;
    _syncError = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network delay
      
      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error pushing data to cloud: $e');
      _syncError = 'Failed to sync data to cloud';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }
} 