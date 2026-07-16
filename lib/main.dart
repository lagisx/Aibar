import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/utils/app_lifecycle_tracker.dart';
import 'data/services/local_notification_service.dart';
import 'data/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  await SupabaseService.init();
  await LocalNotificationService.initialize();
  AppLifecycleTracker.instance.attach();
  runApp(const ProviderScope(child: HairstyleAiApp()));
}
