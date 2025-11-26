import 'package:dentist_ms/app.dart';
import 'package:dentist_ms/core/services/supabase_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  // Make sure to replace YOUR_SUPABASE_URL and YOUR_SUPABASE_ANON_KEY
  // in lib/core/services/supabase_service.dart with your actual values
  await SupabaseService.initialize();
  
  runApp(const DentistApp());
}
