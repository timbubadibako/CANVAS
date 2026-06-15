# ⚙️ Installation Guide: CANVAS

Follow these steps to set up the CANVAS environment and run the application.

## 1. Prerequisites
- **Flutter SDK:** 3.19.0 or higher.
- **Dart SDK:** 3.3.0 or higher.
- **Android Studio / Xcode:** For mobile builds.
- **Supabase Project:** For authentication and cloud sync features.

## 2. Environment Setup
Create a file at `lib/core/constants/app_constants.dart` (if not already present) and add your credentials:

```dart
class AppConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  
  // AI Config
  static const String botModelName = 'gemini-2.5-flash-lite';
}
```

## 3. Local AI Model Installation
To enable on-device AI inference, you must provide the ONNX model files:

1. Create the directory `assets/models/`.
2. Place your `canvas_multiview_premium_fp32.onnx` file inside that directory.
3. Register the model in `pubspec.yaml`:
   ```yaml
   assets:
     - assets/models/canvas_multiview_premium_fp32.onnx
   ```

## 4. Supabase Database Setup
Execute the DDL scripts found in `.geminirc/DATABASE_SCHEMA.md` within your Supabase SQL Editor. This will:
- Create the `profiles` table.
- Create the `food_logs` and `weight_logs` tables.
- Set up RLS (Row Level Security) and triggers.

## 5. Running the App
Install dependencies and launch:

```bash
flutter pub get
flutter run
```

*Note: For production builds, ensure the ONNX model is quantized (Int8) to optimize memory usage on lower-end devices.*
