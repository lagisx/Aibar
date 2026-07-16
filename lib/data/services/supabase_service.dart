import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env_config.dart';

class SupabaseService {
  SupabaseService._();

  static Future<void> init() async {
    EnvConfig.assertConfigured();
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      publishableKey: EnvConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static bool get isSignedIn => currentUser != null;
}
