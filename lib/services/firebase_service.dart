import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:test_app1/services/log_service.dart';
import '../firebase_options.dart';
import '../config/dev_config.dart';

/// Firebase service class to handle all Firebase operations
class FirebaseService {
  // Firebase instances
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  
  /// Initialize Firebase with platform-specific options and development support
  static Future<void> initializeFirebase() async {
    try {
      // Check if we should skip Firebase initialization for development
      if (DevConfig.skipFirebaseInit) {
        LogService.info('🚧 Development Mode: Skipping Firebase initialization');
        LogService.info(DevConfig.statusMessage);
        return;
      }
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      LogService.info('Firebase initialized successfully');
    } catch (e) {
      LogService.error('Error initializing Firebase', error: e);
      
      // In development mode, don't crash the app
      if (DevConfig.isDevelopmentMode) {
        LogService.warning('🚧 Development Mode: Continuing without Firebase due to configuration error');
        return;
      }
      
      rethrow;
    }
  }
  
  /// Check if user is authenticated
  static bool get isUserLoggedIn => auth.currentUser != null;
  
  /// Get current user
  static User? get currentUser => auth.currentUser;
  
  /// Get current user ID
  static String? get currentUserId => auth.currentUser?.uid;
  
  /// Sign out user
  static Future<void> signOut() async {
    await auth.signOut();
  }
  
  /// Log analytics event
  static Future<void> logEvent(String eventName, Map<String, Object>? parameters) async {
    await analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
  
  /// Set user properties for analytics
  static Future<void> setUserProperty(String name, String value) async {
    await analytics.setUserProperty(name: name, value: value);
  }
  
  /// Authentication state changes stream
  static Stream<User?> get authStateChanges => auth.authStateChanges();
}
