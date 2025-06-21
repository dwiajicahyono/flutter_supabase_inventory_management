import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://zwhwdzispxviuzmxodyd.supabase.co/';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3aHdkemlzcHh2aXV6bXhvZHlkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0ODAyMTcsImV4cCI6MjA2NjA1NjIxN30.3plM9D0Rp3w2Jr1I0iGSGgMr4tzrDAXHf0WiXQZVTCI';

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}

// Helper untuk akses client
final supabase = Supabase.instance.client;
