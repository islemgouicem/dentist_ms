# 🦷 Dentist Management System — Flutter Desktop (Windows)

**One-line:** Desktop app to manage patient records, appointments, and billing for a dental clinic.  
**Tech:** Flutter (desktop).

> This README explains the repository structure, what each folder is, how to run the app, and coding/branch rules.

---

## 📁 Repo structure (brief)

lib/
├── core/ # shared utilities, widgets, theme, services
├── data/ # DTOs, local/remote data sources, repo implementations
├── features/ # features (auth, patients, appointments, billing, dashboard)
├── app.dart # app config (MaterialApp, theme, routes)
├── routes.dart # defines the app routings
└── main.dart # app entry point

---

## 🧭 Full explanation(what to put where)

### `main.dart`

App entry. Minimal code: init services and runApp(MyApp()).

### `app.dart` & `routes.dart`

Configure `MaterialApp`, theme, and named routes. Central place to change global settings.

---

### `core/` — shared tools (used across features)

- `core/constants/` → colors, text styles, route names, string constants.
  - `app_colors.dart`, `app_text_styles.dart`, `app_routes.dart`.
- `core/theme/` → `app_theme.dart` where the ThemeData lives.
- `core/widgets/` → reusable UI widgets used across many screens (buttons, dialogs).
- `core/services/` → cross-cutting services (database init, file exports, API helper).
- `core/utils/` → validators, formatters, extensions (small helper functions).
- `core/exceptions/` → central exception types.

**tip:** Put UI components used more than once in `core/widgets/`. If it’s specific to a feature, put it under `features/<feature-name>/presentation/widgets/`.

---

### `data/` — raw data & implementations(ignore for the moment)

- `data/models/` → DTOs and model classes that map to DB rows or API JSON.
  - e.g., `patient_dto.dart` with `fromJson()`/`toJson()`.
- `data/datasources/` → Code that talks to SQLite (local) or to HTTP (remote).
  - Local files: `patient_local_data_source.dart`
  - Remote files: `patient_remote_data_source.dart` (optional)
- `data/repositories_impl/` → Concrete implementations of repository interfaces defined in domain layer.
  - Example: `patient_repository_impl.dart` implements `PatientRepository`.

**tip:** Only `data/` should access the DB or APIs directly.

---

### `features/<feature>/` — feature module

Each feature follows the same internal pattern: `data/`, `domain/`, `presentation/`.

**Example: `features/patients/`**

- `data/`(ignore for the moment)

  - `datasources/` → local or remote data access
  - `models/` → DTOs for the feature
  - `patient_repository_impl.dart` → concrete repo implementation

- `domain/`(ignore for the moment)

  - `entities/` → pure Dart models used by app logic (no JSON)
  - `repositories/` → abstract repository interfaces (e.g., `PatientRepository`)
  - `usecases/` → single-responsibility classes e.g., `AddPatient`, `GetPatients`

- `presentation/`
  - `pages/` → screens (patient_list_page.dart, patient_edit_page.dart)
  - `widgets/` → UI components specific to patients (patient_card.dart)
  - `providers/` → Riverpod providers/state controllers (patient_provider.dart)

**tip:** Follow this pattern for every feature. If you need a new feature, copy the folders and adapt.

---

<!-- ### `providers/` (root)
App-level providers and dependency injection. Example: `db_provider.dart` to expose a shared database instance.

--- -->

### `assets/`

Fonts, icons, images. Update `pubspec.yaml` to include assets.

---

<!-- ### `test/`
Put unit, widget and integration tests here. Keep tests small and focused.

--- -->

## 🧠 State management (short & clear)

## 🛠 How to run (Windows desktop)

1. Install Flutter and enable Windows desktop:
   ```bash
   flutter config --enable-windows-desktop
   flutter doctor
   ```

---

dentist_ms/
├── pubspec.yaml
├── README.md  
├── assets/
│ ├── fonts/
│ ├── icons/
│ └── images/
│
├── lib/
│ ├── main.dart
│ ├── app.dart
│ ├── routes.dart
│ │
│ ├── core/
│ │ ├── constants/
│ │ │ ├── app_colors.dart
│ │ │ ├── app_text_styles.dart
│ │ │ └── app_routes.dart
│ │ │
│ │ ├── theme/
│ │ │ └── app_theme.dart
│ │ │
│ │ ├── widgets/
│ │ │ ├── adaptive_scaffold.dart
│ │ │ ├── custom_button.dart
│ │ │ ├── custom_dialog.dart
│ │ │
│ │ ├── services/
│ │ │ ├── db/
│ │ │ │ └── database_service.dart
│ │ │ │
│ │ │ ├── api_service.dart
│ │ │ └── file_service.dart
│ │ │
│ │ ├── utils/
│ │ │ ├── validators.dart
│ │ │ ├── formatters.dart
│ │ │ └── extensions.dart
│ │ │
│ │ └── exceptions/
│ │ └── app_exceptions.dart
│ │
│ ├── data/
│ │ ├── models/
│ │ │ ├── patient_dto.dart
│ │ │ ├── appointment_dto.dart
│ │ │ ├── invoice_dto.dart
│ │ │ └── user_dto.dart
│ │ │
│ │ ├── datasources/
│ │ │ ├── local/
│ │ │ │ ├── patient_local_data_source.dart
│ │ │ │ ├── appointment_local_data_source.dart
│ │ │ │ └── invoice_local_data_source.dart
│ │ │ └── remote/ # optional (if you add server later)
│ │ │ └── patient_remote_data_source.dart
│ │ │
│ │ └── repositories_impl/
│ │ ├── patient_repository_impl.dart
│ │ ├── appointment_repository_impl.dart
│ │ └── billing_repository_impl.dart
│ │
│ ├── features/
│ │ ├── auth/
│ │ │ ├── data/
│ │ │ │ ├── datasources/
│ │ │ │ │ └── auth_local_data_source.dart
│ │ │ │ ├── models/
│ │ │ │ │ └── user_model.dart
│ │ │ │ └── auth_repository_impl.dart
│ │ │ │
│ │ │ ├── domain/
│ │ │ │ ├── entities/
│ │ │ │ │ └── user.dart
│ │ │ │ ├── repositories/
│ │ │ │ │ └── auth_repository.dart
│ │ │ │ └── usecases/
│ │ │ │ └── login_usecase.dart
│ │ │ │
│ │ │ └── presentation/
│ │ │ ├── pages/
│ │ │ │ ├── login_page.dart
│ │ │ │ └── lock_screen.dart
│ │ │ ├── widgets/
│ │ │ └── providers/ # Riverpod providers here
│ │ │ └── auth_provider.dart
│ │ │
│ │ ├── patients/
│ │ │ ├── data/
│ │ │ │ ├── datasources/
│ │ │ │ │ └── patient_local_data_source.dart
│ │ │ │ ├── models/
│ │ │ │ │ └── patient_model.dart
│ │ │ │ └── patient_repository_impl.dart
│ │ │ │
│ │ │ ├── domain/
│ │ │ │ ├── entities/
│ │ │ │ │ └── patient.dart
│ │ │ │ ├── repositories/
│ │ │ │ │ └── patient_repository.dart
│ │ │ │ └── usecases/
│ │ │ │ ├── add_patient.dart
│ │ │ │ ├── update_patient.dart
│ │ │ │ └── get_patient_list.dart
│ │ │ │
│ │ │ └── presentation/
│ │ │ ├── pages/
│ │ │ │ ├── patient_list_page.dart
│ │ │ │ ├── patient_detail_page.dart
│ │ │ │ └── patient_edit_page.dart
│ │ │ ├── widgets/
│ │ │ │ ├── patient_card.dart
│ │ │ │ └── patient_form.dart
│ │ │ └── providers/
│ │ │ └── patient_provider.dart
│ │ │
│ │ ├── appointments/
│ │ │ ├── data/
│ │ │ ├── domain/
│ │ │ └── presentation/
│ │ │ ├── pages/
│ │ │ │ ├── appointment_calendar_page.dart
│ │ │ │ ├── appointment_list_page.dart
│ │ │ │ └── appointment_edit_page.dart
│ │ │ ├── widgets/
│ │ │ └── providers/
│ │ │
│ │ ├── billing/
│ │ │ ├── data/
│ │ │ ├── domain/
│ │ │ └── presentation/
│ │ │ ├── pages/
│ │ │ │ ├── invoice_list_page.dart
│ │ │ │ └── invoice_detail_page.dart
│ │ │ ├── widgets/
│ │ │ └── providers/
│ . │
│ ├── dashboard/
│ │ ├── data/
│ │ ├── domain/
│ │ └── presentation/
│ │ └── dashboard_page.dart
│ │
│ └── settings/
│ └── presentation/
│ └── settings_page.dart
│  
│  
│
├── test/
│ ├── unit/
│ ├── widget/
│ └── integration/
│
├── docs/
│ ├── SRS.md
│ └── ERD.png
└
