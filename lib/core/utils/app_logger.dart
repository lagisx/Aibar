import 'dart:developer' as developer;

// технические логи для нас, не для пользователя — смотреть через consumer
// логов IDE/adb logcat, фильтр по name: AIHairstyle
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
