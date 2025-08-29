import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = '';
  static const String anonKey = '';

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}

// Helper untuk akses client
final supabase = Supabase.instance.client;
