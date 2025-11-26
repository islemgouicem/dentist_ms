import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service for database operations.
/// 
/// Initialize with your Supabase URL and anon key from the Supabase dashboard.
/// 
/// To setup:
/// 1. Create a Supabase project at https://supabase.com
/// 2. Create a 'patients' table with the following SQL:
/// 
/// ```sql
/// CREATE TABLE patients (
///   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
///   first_name TEXT NOT NULL,
///   last_name TEXT NOT NULL,
///   email TEXT,
///   phone TEXT,
///   date_of_birth DATE,
///   gender TEXT,
///   address TEXT,
///   notes TEXT,
///   status TEXT DEFAULT 'active',
///   balance DECIMAL(10,2) DEFAULT 0,
///   last_visit TIMESTAMP WITH TIME ZONE,
///   next_appointment TIMESTAMP WITH TIME ZONE,
///   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
///   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
/// );
/// 
/// -- Enable Row Level Security
/// ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
/// 
/// -- Create policy for all operations (adjust based on your auth needs)
/// CREATE POLICY "Enable all access for authenticated users" ON patients
///   FOR ALL USING (true);
/// ```
/// 
/// 3. Copy your project URL and anon key from Settings > API
/// 4. Replace the values below
class SupabaseService {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
