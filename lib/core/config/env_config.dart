// ключи задаются через --dart-define, см. .env.example
class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
  );

  static void assertConfigured() {
    assert(
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
      'Не заданы SUPABASE_URL / SUPABASE_ANON_KEY. Передайте через --dart-define, '
      'см. .env.example.',
    );
  }
}
