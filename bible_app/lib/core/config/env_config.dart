import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loader
/// 
/// This class loads environment variables from .env file
/// and provides typed access to configuration values.
class EnvConfig {
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL not found in environment. Please check your .env file.');
    }
    return url;
  }

  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in environment. Please check your .env file.');
    }
    return key;
  }

  static String get bibleBrainApiKey {
    final key = dotenv.env['BIBLE_BRAIN_API_KEY'];
    if (key == null || key.isEmpty) {
      // Return empty string for development, but log warning
      if (kDebugMode) {
        debugPrint('⚠️ BIBLE_BRAIN_API_KEY not set. Bible Brain features will not work.');
      }
      return '';
    }
    return key;
  }

  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      if (kDebugMode) {
        debugPrint('ℹ️ GEMINI_API_KEY not set. AI Study Assistant will not work.');
      }
      return '';
    }
    return key;
  }

  static String get appName => dotenv.env['APP_NAME'] ?? 'Faith Audio Bible';
  
  static String get supportEmail => dotenv.env['SUPPORT_EMAIL'] ?? '';

  /// Initialize environment variables
  /// Call this in main() before runApp()
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('✅ Environment loaded successfully');
      debugPrint('📍 Supabase URL: ${supabaseUrl.substring(0, 30)}...');
      debugPrint('🔑 Bible Brain API: ${bibleBrainApiKey.isNotEmpty ? "configured" : "not set"}');
      debugPrint('🤖 Gemini API: ${geminiApiKey.isNotEmpty ? "configured" : "not set"}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load .env file: $e');
        debugPrint('Make sure you have copied .env.example to .env and filled in your values.');
      }
      rethrow;
    }
  }

  /// Check if all required services are configured
  static bool get isSupabaseConfigured {
    try {
      final _ = supabaseUrl;
      final __ = supabaseAnonKey;
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool get isBibleBrainConfigured => bibleBrainApiKey.isNotEmpty;
  
  static bool get isGeminiConfigured => geminiApiKey.isNotEmpty;
}
