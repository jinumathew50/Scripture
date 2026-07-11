class AppConfig {
  // Supabase Configuration - Replace with your actual values
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // Bible Brain API (accessed via Edge Functions)
  static const String bibleBrainApiVersion = 'v4';
  
  // App Settings
  static const String appName = 'Bible App';
  static const int maxDownloadSizeMB = 500;
  static const bool wifiOnlyDownloads = true;
  
  // AI Assistant
  static const bool aiAssistantEnabled = true;
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  // Notification Settings
  static const String defaultReminderTime = '08:00';
  
  // Theme Settings
  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double defaultFontSize = 18.0;
}
