# Project Architecture & Directory Structure: CANVAS

Struktur direktori ini dirancang menggunakan kombinasi arsitektur **Clean Architecture** yang disederhanakan dan disesuaikan dengan pola **BLoC State Management**. Struktur ini memisahkan dengan tegas antara komponen UI, logika bisnis, integrasi Supabase, dan jalur eksekusi Machine Learning.

```text
canvas_app/
├── android/
├── ios/
├── assets/
│   └── models/               # Tempat menyimpan model ONNX/TFLite lokal (jika di-download)
├── lib/
│   ├── main.dart             # Entry point aplikasi & inisialisasi awal
│   │
│   ├── core/                 # Komponen global yang di-share ke seluruh aplikasi
│   │   ├── constants/        # Warna, dimensi, dan URL API Backend
│   │   ├── theme/            # Konfigurasi styling aplikasi (Dark/Light mode)
│   │   └── utils/            # Helper fungsi (format kalori, kalkulator matriks)
│   │
│   ├── data/                 # Data Layer (Mengurusi supply data mentah)
│   │   ├── datasources/
│   │   │   ├── supabase_remote_source.dart  # Handle API Auth & Table Sync ke Supabase
│   │   │   └── ai_api_client.dart          # Handle HTTP POST gambar ke FastAPI Server
│   │   └── repositories/
│   │       └── nutrition_repository_impl.dart
│   │
│   ├── domain/               # Domain Layer (Logika Bisnis / Aturan Aplikasi)
│   │   ├── models/
│   │   │   ├── user_profile.dart
│   │   │   └── food_log_entry.dart         # Model data Kalori, Mass, Protein, Carbs, Fat
│   │   └── repositories/
│   │       └── nutrition_repository.dart    # Kontrak/Interface fungsi
│   │
│   ├── ml/                   # Machine Learning Engine Layer (Pusat Otak AI Mobile)
│   │   ├── onnx_inference_service.dart     # Service untuk me-load model biner Int8 ke memori
│   │   ├── volume_estimator.dart           # Algoritma hitung volume skalar dari depth map
│   │   └── background_isolate.dart         # Dart Isolate agar running AI berada di background thread
│   │
│   └── presentation/         # Presentation Layer (Semua Urusan UI & User Interaction)
│       ├── bloc/             # Pengatur logika dan aliran data (BLoC)
│       │   ├── auth/         # BLoC untuk handle login/register session
│       │   ├── camera/       # BLoC untuk handle siklus hidup kamera & penangkapan frame
│       │   └── scanner/      # BLoC penampung state AI (Loading, Success, Failure)
│       │
│       ├── screens/          # Halaman Utama Aplikasi
│       │   ├── dashboard_screen.dart       # Riwayat gizi harian & grafik pemenuhan target
│       │   ├── camera_scanner_screen.dart  # Layar utama scanner kamera real-time
│       │   └── settings_screen.dart        # Tempat tombol opsi toggle Online/Offline Mode
│       │
│       └── widgets/          # Komponen UI kecil yang bisa dipakai berulang kali (Modular)
│           ├── custom_camera_preview.dart  # Widget dengan overlay target bounding box piring
│           ├── nutrition_facts_card.dart   # Widget penampil hasil regresi AI (Kalori & Makro)
│           └── daily_progress_bar.dart
│
└── pubspec.yaml              # Manajemen dependency proyek Flutter