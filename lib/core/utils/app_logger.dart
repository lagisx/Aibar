import 'dart:developer' as developer;

class AppLogger {
  static void error(String context, Object error, [StackTrace? stackTrace]) {
    developer.log(
      context,
      name: 'AIHairstyle',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
