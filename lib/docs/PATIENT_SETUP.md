# Patient Feature Setup Guide

This guide explains how to set up and use the Patient Management feature with Supabase backend and BLoC state management.

## Prerequisites

1. Flutter SDK installed
2. A Supabase account (free tier available at https://supabase.com)

## Setup Instructions

### 1. Install Dependencies

The following dependencies have been added to `pubspec.yaml`:

```yaml
supabase_flutter: ^2.8.4
flutter_bloc: ^9.1.0
equatable: ^2.0.7
```

Run `flutter pub get` to install them.

### 2. Create Supabase Project

1. Go to https://supabase.com and create a new project
2. Wait for the project to be provisioned

### 3. Create the Patients Table

Go to the SQL Editor in your Supabase dashboard and run:

```sql
CREATE TABLE patients (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  date_of_birth DATE,
  gender TEXT,
  address TEXT,
  notes TEXT,
  status TEXT DEFAULT 'active',
  balance DECIMAL(10,2) DEFAULT 0,
  last_visit TIMESTAMP WITH TIME ZONE,
  next_appointment TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

-- Create policy for all operations (adjust based on your auth needs)
CREATE POLICY "Enable all access" ON patients
  FOR ALL USING (true);
```

### 4. Configure Supabase Credentials

1. In your Supabase project, go to Settings > API
2. Copy the **Project URL** and **anon public** key
3. Update `lib/core/services/supabase_service.dart`:

```dart
class SupabaseService {
  static const String supabaseUrl = 'YOUR_PROJECT_URL';  // e.g., https://xxxxx.supabase.co
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';  // e.g., eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  // ...
}
```

### 5. Run the App

```bash
flutter run
```

## Architecture Overview

### Directory Structure

```
lib/features/patients/
├── data/
│   ├── models/
│   │   └── patient_model.dart    # Patient data model with JSON serialization
│   └── repositories/
│       └── patient_repository.dart  # Supabase database operations
└── presentation/
    ├── bloc/
    │   ├── bloc.dart              # Barrel file for exports
    │   ├── patient_bloc.dart      # BLoC implementation
    │   ├── patient_event.dart     # BLoC events
    │   └── patient_state.dart     # BLoC states
    ├── pages/
    │   └── patients_page.dart     # Main patients UI page
    └── widgets/
        └── patient_form_dialog.dart  # Add/Edit patient form
```

### Data Flow

1. **UI** triggers **Events** (e.g., `LoadPatients`, `AddPatient`)
2. **BLoC** receives events and calls **Repository** methods
3. **Repository** communicates with **Supabase** database
4. **BLoC** emits new **States** based on results
5. **UI** rebuilds based on new states

### Available Events

- `LoadPatients` - Load all patients from database
- `LoadPatientStats` - Load patient statistics
- `AddPatient` - Create a new patient
- `UpdatePatient` - Update existing patient
- `DeletePatient` - Delete a patient
- `SearchPatients` - Search patients by query

### Available States

- `PatientInitial` - Initial state
- `PatientLoading` - Loading data
- `PatientLoaded` - Data loaded successfully
- `PatientOperationInProgress` - Operation in progress
- `PatientOperationSuccess` - Operation completed successfully
- `PatientError` - Error occurred

## Usage Examples

### Loading Patients

```dart
context.read<PatientBloc>().add(const LoadPatients());
```

### Adding a Patient

```dart
final patient = Patient(
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  phone: '+1234567890',
);
context.read<PatientBloc>().add(AddPatient(patient));
```

### Searching Patients

```dart
context.read<PatientBloc>().add(SearchPatients('john'));
```

## Security Considerations

For production use, consider:

1. **Row Level Security (RLS)**: Configure proper RLS policies based on user roles
2. **Environment Variables**: Store Supabase credentials in environment variables
3. **Authentication**: Implement Supabase Auth before enabling sensitive operations

## Troubleshooting

### Common Issues

1. **"Failed to fetch patients"**: Check Supabase credentials and RLS policies
2. **"Network error"**: Verify internet connection and Supabase URL
3. **"Permission denied"**: Check RLS policies allow the operation

### Debug Mode

Enable debug logging in the repository:

```dart
try {
  final response = await query;
  print('Response: $response');  // Debug
} catch (e) {
  print('Error: $e');  // Debug
}
```
