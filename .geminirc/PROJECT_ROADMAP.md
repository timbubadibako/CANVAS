# Project Roadmap & TODO Board: CANVAS

Dokumen ini berfungsi sebagai papan pelacak progres pengerjaan proyek CANVAS yang dibagi ke dalam 3 Fase eksekusi taktis.

---

## 📅 FASE 1: Foundation, Data Engineering & Mobile Boilerplate (PROGRESS: 95%)
**Fokus Utama:** Menyiapkan infrastruktur database, reduksi dataset 180 GB, dan membangun kerangka dasar (boilerplate) aplikasi Flutter.

### 1. Backend & Database Setup (Supabase)
- [x] Buat proyek baru di dashboard Supabase.
- [x] Eksekusi skrip SQL DDL (`DATABASE_SCHEMA.md`) di SQL Editor Supabase.
- [x] Pastikan Row Level Security (RLS) dan Trigger `on_auth_user_created` aktif.

### 2. Machine Learning Dataset Pipeline (Python Lokal)
- [ ] Unduh berkas dataset Nutrition5k secara bertahap.
- [ ] Bikin skrip Python untuk melakukan downsampling (ambil setiap frame ke-5 dari video).
- [ ] Bikin skrip otomatisasi resize gambar masal ke resolusi $256 \times 256$ piksel.
- [ ] Kelompokkan metadata anotasi berat, kalori, dan makronutrien dari USDA database ke format file `.csv` siap latih.

### 3. Mobile Frontend Setup (Flutter)
- [x] Inisialisasi proyek Flutter menggunakan Clean Architecture.
- [x] Susun struktur folder paket sesuai panduan `PROJECT_ARCHITECTURE.md`.
- [x] Pasang dependensi utama di `pubspec.yaml` (`flutter_bloc`, `supabase_flutter`, `camera`, `http`, `lucide_icons`, `google_fonts`, `image_picker`, `google_generative_ai`).
- [x] Implementasi **Artistic Studio Theme** (Poppins/Open Sans, Dark & Light Ready).
- [x] Buat halaman `LoginScreen` dan `RegisterScreen` dengan transisi side-by-side artistik & Autofill support.
- [x] Implementasikan `AuthBloc` untuk memanajemeni token sesi login via Supabase Auth (Sesi Persisten Aktif).

---

## 📅 FASE 2: Model Training, API Gateway & Core UI Integration (PROGRESS: 55%)
**Fokus Utama:** Melatih model AI multi-task regressor, mendeploy API FastAPI, dan menghubungkan core scanner kamera di Flutter.

### 1. Model Training & Export (AI Sub-Team)
- [ ] Latih model backbone (MobileNetV3/Inception) menggunakan data latih hasil reduksi.
- [ ] Optimalkan fungsi multi-task loss (MAE) untuk mengejar target akurasi kalori.
- [ ] Ekspor model terbaik menjadi format mentah Float32 (`.pth`/`.savedmodel`) seberat ~400 MB untuk disematkan di server.
- [ ] Lakukan Post-Training Quantization (PTQ) ke format Int8 (`.onnx`/`.tflite`) seberat ~50-100 MB untuk persiapan offline mode.

### 2. Backend API Development (FastAPI)
- [ ] Bangun kerangka web server menggunakan Python FastAPI.
- [ ] Implementasikan endpoint `/api/v1/scan/predict-2d` untuk menerima unggahan gambar multipart dari mobile.
- [ ] Buat logika pemrosesan gambar masuk ke dalam pipeline inferensi model mentah 400 MB.
- [ ] Deploy server FastAPI ke cloud provider (RunPod / Hugging Face Spaces).

### 3. Core Mobile Integration (Flutter Integration)
- [x] Bangun halaman `DashboardScreen` dengan visualisasi ringkasan gizi harian & sinkronisasi data nyata.
- [x] Bangun halaman `MealDiaryScreen` dengan konsep "Layers" & fungsional filter.
- [x] Implementasikan fungsionalitas UI `CameraScannerScreen` (UI Live Camera Ready + Fallback).
- [ ] Implementasikan `CameraBloc` untuk mengontrol siklus hidup kamera.
- [x] Buat overlay grafik *organic frame* target piring pada widget kamera.
- [x] Implementasikan Otak AI (Gemini AI Client) untuk bantuan analisis & asisten chatbot proaktif.
- [x] Buat widget `NutritionReviewScreen` dengan fungsionalitas edit & slider porsi.
- [ ] Sambungkan fungsi tombol "Simpan ke Diary" untuk mengunggah entri log makanan ke tabel `food_logs` Supabase.

---

## 📅 FASE 3: Optimization, Offline Mode & Future Features (PROGRESS: 20%)
**Fokus Utama:** Memperluas kapabilitas aplikasi dengan On-Device AI lokal dan meluncurkan fitur pelacakan berat badan harian.

### 1. In-App Download Manager & Local Inference (Offline Mode)
- [ ] Taruh berkas model terkompresi (.onnx) ke cloud storage (Supabase Storage / AWS S3).
- [ ] Buat fitur tombol unduh di `SettingsScreen` beserta indikator *progress bar* unduhan model.
- [ ] Integrasikan library `onnxruntime_flutter` untuk memuat model hasil unduhan ke memori lokal HP.
- [ ] Terapkan arsitektur `Dart Isolates` (`background_isolate.dart`) agar proses inferensi gambar lokal tidak memicu UI lag.
- [ ] Sempurnakan logika `ScannerBloc` agar bisa melakukan *switching* otomatis ke lokal engine saat kuota mati atau offline mode aktif.
- [x] Implementasikan panduan UI *Multi-Angle Prompt* (30° & 60°) dengan animasi notifikasi kustom.

### 2. Fitness Progression Features (List Masa Depan)
- [x] Buat halaman `ProfilesScreen` (Account Reveal, Avatar Mgt, Studio Docs).
- [x] Implementasikan alur **Onboarding Preferences** (5-Step Journey + Auto-Calculation Algoritma Gizi).
- [x] Buat layar **Stats Analytics** dengan grafik mingguan & Weight Tracker harian.
- [ ] Hubungkan input berat badan ke tabel `weight_logs` Supabase.
- [x] Implementasi sistem **StudioToast** notification di pojok kanan atas.
