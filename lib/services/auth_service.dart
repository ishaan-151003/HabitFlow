import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

// Stub classes
class User {
  final String uid;
  final String? displayName;
  final String? email;
  
  User({required this.uid, this.displayName, this.email});
}

class FirebaseAuth {
  static final FirebaseAuth instance = FirebaseAuth();
  
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
  Stream<User?> authStateChanges() {
    return Stream.value(_currentUser);
  }
  
  // Stub methods
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email, 
    required String password,
  }) async {
    final user = User(uid: 'stub-user-id', displayName: 'Stub User', email: email);
    _currentUser = user;
    return UserCredential(user: user);
  }
  
  Future<UserCredential> signInWithEmailAndPassword({
    required String email, 
    required String password,
  }) async {
    final user = User(uid: 'stub-user-id', displayName: 'Stub User', email: email);
    _currentUser = user;
    return UserCredential(user: user);
  }
  
  Future<void> signOut() async {
    _currentUser = null;
  }
}

class UserCredential {
  final User? user;
  
  UserCredential({this.user});
}

class FirebaseAuthException implements Exception {
  final String code;
  final String? message;
  
  FirebaseAuthException({required this.code, this.message});
}

class FirebaseFirestore {
  static final FirebaseFirestore instance = FirebaseFirestore();
  
  CollectionReference collection(String path) {
    return CollectionReference(path);
  }
}

class CollectionReference {
  final String path;
  
  CollectionReference(this.path);
  
  DocumentReference doc(String id) {
    return DocumentReference('$path/$id');
  }
}

class DocumentReference {
  final String path;
  
  DocumentReference(this.path);
  
  Future<DocumentSnapshot> get() async {
    return DocumentSnapshot(exists: true, data: {'id': 'stub-id', 'email': 'user@example.com', 'displayName': 'Stub User'});
  }
  
  Future<void> set(Map<String, dynamic> data) async {
    // Do nothing in stub
  }
  
  Future<void> update(Map<String, dynamic> data) async {
    // Do nothing in stub
  }
  
  Future<void> delete() async {
    // Do nothing in stub
  }
  
  CollectionReference collection(String path) {
    return CollectionReference('$this.path/$path');
  }
}

class DocumentSnapshot {
  final bool exists;
  final Map<String, dynamic>? _data;
  
  DocumentSnapshot({required this.exists, Map<String, dynamic>? data}) : _data = data;
  
  Map<String, dynamic>? data() {
    return _data;
  }
}

class Batch {
  Future<void> commit() async {
    // Do nothing in stub
  }
  
  void set(DocumentReference doc, Map<String, dynamic> data) {
    // Do nothing in stub
  }
}

// AuthService implementation using stubs
class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get userProfile => _userProfile;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _auth.currentUser;

  AuthService() {
    // Initialize with a stub user
    _userProfile = UserProfile(
      id: 'stub-user-id',
      email: 'user@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
    );
  }

  Future<bool> registerWithEmail(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      _userProfile = UserProfile(
        id: 'stub-user-id',
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Registration failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      _userProfile = UserProfile(
        id: 'stub-user-id',
        email: email,
        displayName: 'Test User',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLogin: DateTime.now(),
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Login failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
      _userProfile = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateProfile({String? displayName, String? photoUrl}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      if (displayName != null || photoUrl != null) {
        // Update the user profile with new data
        _userProfile = _userProfile?.copyWith(
          displayName: displayName ?? _userProfile?.displayName,
          photoUrl: photoUrl ?? _userProfile?.photoUrl,
          lastLogin: DateTime.now(),
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Profile update failed: $e';
      notifyListeners();
      return false;
    }
  }
} 