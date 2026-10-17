class AppConfig {
  static const String appVersion = '1.0.0';
  static const String appName = 'UniSelection';
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  // Supabase REST endpoint configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder-uniselection.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const int apiTimeoutSeconds = int.fromEnvironment('API_TIMEOUT_SECONDS', defaultValue: 10);
  static const bool enableOfflineSeedMode = bool.fromEnvironment('ENABLE_OFFLINE_SEED_MODE', defaultValue: true);

  /// Checks if valid live Supabase credentials are configured
  static bool get isSupabaseConfigured {
    return supabaseUrl.isNotEmpty &&
        !supabaseUrl.contains('placeholder') &&
        supabaseAnonKey.isNotEmpty;
  }
}
