import 'package:dentist_ms/app.dart';
import 'package:dentist_ms/features/patients/bloc/patient_bloc.dart';
import 'package:dentist_ms/features/patients/data/patient_remote.dart';
import 'package:dentist_ms/features/patients/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

  // 2. DEPENDENCY INJECTION Setup
  // Initialize the Data Source and Repository once
  final patientRemoteDataSource = PatientRemoteDataSource();
  final patientRepository = SupabasePatientRepository(
    remote: patientRemoteDataSource,
  );

  runApp(
    // 3. Inject the BLoC providers above the application root
    MultiBlocProvider(
      providers: [
        BlocProvider<PatientBloc>(
          // The repository is passed to the Bloc
          create: (context) => PatientBloc(repository: patientRepository),
        ),
        // Add other Blocs here as your application grows (e.g., AppointmentsBloc)
      ],

      child: const DentistApp(),
    ),
  );
}
