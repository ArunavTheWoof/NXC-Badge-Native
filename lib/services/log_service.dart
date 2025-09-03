import 'dart:developer' as developer;

/// Logging service for the application
class LogService {
  static const String _appName = 'NXC-Badge-Native';
  
  /// Log info message
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _appName,
      level: 800, // INFO level
    );
  }
  
  /// Log warning message
  static void warning(String message, {Object? error, String? tag}) {
    developer.log(
      message,
      name: tag ?? _appName,
      level: 900, // WARNING level
      error: error,
    );
  }
  
  /// Log error message
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    developer.log(
      message,
      name: tag ?? _appName,
      level: 1000, // SEVERE level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log debug message (only in debug mode)
  static void debug(String message, {String? tag}) {
    assert(() {
      developer.log(
        message,
        name: tag ?? _appName,
        level: 700, // CONFIG level
      );
      return true;
    }());
  }
}
