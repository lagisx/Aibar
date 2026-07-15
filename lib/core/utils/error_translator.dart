import 'app_logger.dart';

// прячет технические детали (Supabase/Realtime/сеть) от пользователя,
// но пишет их в лог, чтобы мы могли разобраться, что случилось
String friendlyErrorMessage(Object error, {String context = 'unknown', StackTrace? stackTrace}) {
  AppLogger.error(context, error, stackTrace);

  final text = error.toString();

  if (text.contains('SocketException') || text.contains('Failed host lookup')) {
    return 'Нет подключения к интернету. Проверьте сеть и попробуйте снова.';
  }
  if (text.contains('RealtimeSubscribeException') || text.contains('WebSocketChannelException')) {
    return 'Не удалось подключиться к серверу для обновлений в реальном времени.';
  }
  if (text.contains('TimeoutException') || text.contains('timed out')) {
    return 'Сервер долго не отвечает. Попробуйте ещё раз.';
  }
  if (text.contains('AuthException') || text.contains('Invalid or expired session')) {
    return 'Сессия истекла. Войдите в аккаунт заново.';
  }
  if (text.contains('PostgrestException')) {
    return 'Ошибка при обращении к базе данных. Попробуйте позже.';
  }

  return 'Что-то пошло не так. Попробуйте ещё раз.';
}
