import 'package:flutter/foundation.dart';

/// Development configuration for the app
class DevConfig {
  // Set this to false when you have proper Firebase configuration
  static const bool isDevelopmentMode = true;
  
  // Set this to false now that we have Firebase web configuration
  static const bool skipFirebaseInit = false;
  
  // Development database simulation
  static const bool useMockData = false;
  
  // Logging configuration
  static const bool verboseLogging = kDebugMode;
  
  /// Check if we should initialize Firebase
  static bool get shouldInitializeFirebase => !skipFirebaseInit;
  
  /// Check if we should use real Firebase services
  static bool get useFirebaseServices => !skipFirebaseInit;
  
  /// Get development status message
  static String get statusMessage {
    if (isDevelopmentMode && !skipFirebaseInit) {
      return '� Development Mode: Using real Firebase with web configuration';
    } else if (isDevelopmentMode && skipFirebaseInit) {
      return '� Development Mode: Firebase disabled for testing';
    } else {
      return '🚀 Production Mode: Using live Firebase configuration';
    }
  }
}
