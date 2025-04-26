import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// This is a dummy file to allow the app to compile without Firebase
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'dummy-api-key',
      appId: 'dummy-app-id',
      messagingSenderId: 'dummy-sender-id',
      projectId: 'dummy-project-id',
    );
  }
} 