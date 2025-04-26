import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io' show Platform;
import '../models/habit.dart';
import 'dart:async'; // Add this for timeout handling
import 'package:intl/intl.dart'; // Add this for DateFormat

// For web support
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const int _timeoutSeconds = 5; // Timeout after 5 seconds for operations

  // Initialize database factory based on platform
  Future<void> initializeDatabaseFactory() async {
    try {
      if (kIsWeb) {
        // Initialize for web
        sqflite_ffi.databaseFactory = databaseFactoryFfiWeb;
      } else if (Platform.isAndroid) {
        // Use the standard sqflite implementation for Android
        // No need to change the database factory
        debugPrint('Using standard SQLite for Android');
      } else {
        // Initialize for desktop (Windows, macOS, Linux)
        sqflite_ffi.sqfliteFfiInit();
        sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
      }
    } catch (e) {
      debugPrint('Error initializing database factory: $e');
      rethrow;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    try {
      // Ensure database factory is initialized
      await initializeDatabaseFactory();
      
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      debugPrint('Error getting database: $e');
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      final path = join(await getDatabasesPath(), 'habitflow.db');
      debugPrint('Database path: $path');
      
      return await openDatabase(
        path,
        version: 5,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
      ).timeout(Duration(seconds: _timeoutSeconds), onTimeout: () {
        throw TimeoutException('Database connection timed out');
      });
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    try {
      // Handle migrations based on version changes
      if (oldVersion < 5) {
        // Remove photo proof field if upgrading from before version 5
        // We don't actually drop columns in SQLite, but we'll make sure new records don't use them
      }
    } catch (e) {
      debugPrint('Error upgrading database: $e');
      rethrow;
    }
  }

  Future<void> _createDb(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE habits(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          created_at TEXT,
          frequency TEXT,
          target_days INTEGER,
          current_streak INTEGER,
          longest_streak INTEGER,
          is_active INTEGER,
          completion_record TEXT
        )
      ''');
    } catch (e) {
      debugPrint('Error creating database tables: $e');
      rethrow;
    }
  }

  // CRUD Operations for Habits

  // Create a new habit
  Future<int> insertHabit(Habit habit) async {
    try {
      final db = await database;
      return await db.insert('habits', habit.toMap())
        .timeout(Duration(seconds: _timeoutSeconds), onTimeout: () {
          throw TimeoutException('Insert habit operation timed out');
        });
    } catch (e) {
      debugPrint('Error inserting habit: $e');
      rethrow;
    }
  }

  // Get all habits
  Future<List<Habit>> getHabits({bool activeOnly = false}) async {
    try {
      final db = await database;
      
      List<Map<String, dynamic>> maps;
      if (activeOnly) {
        maps = await db.query('habits', where: 'is_active = ?', whereArgs: [1])
          .timeout(Duration(seconds: _timeoutSeconds), onTimeout: () {
            throw TimeoutException('Get habits operation timed out');
          });
      } else {
        maps = await db.query('habits')
          .timeout(Duration(seconds: _timeoutSeconds), onTimeout: () {
            throw TimeoutException('Get habits operation timed out');
          });
      }

      return List.generate(maps.length, (i) {
        return Habit.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('Error getting habits: $e');
      return []; // Return empty list on error
    }
  }

  // Get a single habit by id
  Future<Habit?> getHabit(int id) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'habits',
        where: 'id = ?',
        whereArgs: [id],
      ).timeout(Duration(seconds: _timeoutSeconds), onTimeout: () {
        throw TimeoutException('Get habit operation timed out');
      });

      if (maps.isNotEmpty) {
        return Habit.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting habit: $e');
      rethrow;
    }
  }

  // Update a habit
  Future<int> updateHabit(Habit habit) async {
    try {
      final db = await database;
      return await db.update(
        'habits',
        habit.toMap(),
        where: 'id = ?',
        whereArgs: [habit.id],
      ).timeout(Duration(seconds: _timeoutSeconds), onTimeout: () {
        throw TimeoutException('Update habit operation timed out');
      });
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    }
  }

  // Delete a habit
  Future<int> deleteHabit(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'habits',
        where: 'id = ?',
        whereArgs: [id],
      ).timeout(Duration(seconds: _timeoutSeconds), onTimeout: () {
        throw TimeoutException('Delete habit operation timed out');
      });
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    }
  }

  // Archive a habit (set is_active to false)
  Future<int> archiveHabit(int id) async {
    try {
      final db = await database;
      return await db.update(
        'habits',
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [id],
      ).timeout(Duration(seconds: _timeoutSeconds), onTimeout: () {
        throw TimeoutException('Archive habit operation timed out');
      });
    } catch (e) {
      debugPrint('Error archiving habit: $e');
      rethrow;
    }
  }
} 