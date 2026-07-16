import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/utils/app_logger.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static const _generationChannel = AndroidNotificationDetails(
    'vegas_generation_channel',
    'Генерация и загрузки',
    channelDescription: 'Готовность генерации и сохранение фото в галерею',
    importance: Importance.high,
    priority: Priority.high,
  );

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    try {
      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e, st) {
      AppLogger.error('local_notifications_init', e, st);
    }
  }

  static Future<void> showGenerationReady() => _show(
    id: 1,
    title: 'Причёска готова',
    body: 'Генерация завершена — откройте VEGAS, чтобы посмотреть результат',
  );

  static Future<void> showDownloadComplete() => _show(
    id: 2,
    title: 'Фото сохранено',
    body: 'Изображение добавлено в галерею устройства',
  );

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: _generationChannel,
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e, st) {
      AppLogger.error('local_notification_show', e, st);
    }
  }
}
