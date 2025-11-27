import 'package:supabase_flutter/supabase_flutter.dart';

/// Initialize Supabase once at app startup:
/// await SupabaseClientWrapper.init(url: 'https://...', anonKey: 'public-anon-key');
class SupabaseClientWrapper {
  SupabaseClientWrapper._();
  static final SupabaseClientWrapper _instance = SupabaseClientWrapper._();
  static SupabaseClientWrapper get instance => _instance;

  late final SupabaseClient client;

  static Future<void> init({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    instance.client = Supabase.instance.client;
  }
}