# Project Roadmap & TODO Board: CANVAS

Dokumen ini berfungsi sebagai papan pelacak progres pengerjaan proyek CANVAS yang dibagi ke dalam 3 Fase eksekusi taktis.

---

## 📅 FASE 1: Foundation, Data Engineering & Mobile Boilerplate
**Fokus Utama:** Menyiapkan infrastruktur database, reduksi dataset 180 GB, dan membangun kerangka dasar (boilerplate) aplikasi Flutter.

### 1. Backend & Database Setup (Supabase)
- [ ] Buat proyek baru di dashboard Supabase.
- [ ] Eksekusi skrip SQL DDL (`DATABASE_SCHEMA.md`) di SQL Editor Supabase.
- [ ] Pastikan Row Level Security (RLS) dan Trigger `on_auth_user_created` aktif.

### 2. Machine Learning Dataset Pipeline (Python Lokal)
- [ ] Unduh berkas dataset Nutrition5k secara bertahap.
- [ ] Bikin skrip Python untuk melakukan downsampling (ambil setiap frame ke-5 dari video).
- [ ] Bikin skrip otomatisasi resize gambar masal ke resolusi $256 \times 256$ piksel.
- [ ] Kelompokkan metadata anotasi berat, kalori, dan makronutrien dari USDA database ke format file `.csv` siap latih.

### 3. Mobile Frontend Setup (Flutter)
- [ ] Inisialisasi proyek Flutter menggunakan perintah `flutter create --org com.timbubadibako .` di dalam folder repo.
- [ ] Susun struktur folder paket sesuai panduan `PROJECT_ARCHITECTURE.md`.
- [ ] Pasang dependensi utama di `pubspec.yaml` (`flutter_bloc`, `supabase_flutter`, `camera`, `http`).
- [ ] Buat halaman `LoginScreen` dan `RegisterScreen` dasar.
- [ ] Implementasikan `AuthBloc` untuk memanajemeni token sesi login via Supabase Auth.

---

## 📅 FASE 2: Model Training, API Gateway & Core UI Integration
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
- [ ] Bangun halaman `DashboardScreen` dengan visualisasi ringkasan gizi harian.
- [ ] Implementasikan `CameraBloc` untuk mengontrol siklus hidup kamera di `CameraScannerScreen`.
- [ ] Buat overlay grafik *bounding box* target piring pada widget kamera.
- [ ] Implementasikan `ScannerBloc` untuk menangani Online Mode (kirim file jepretan foto via HTTP POST ke server FastAPI).
- [ ] Buat widget `NutritionFactsCard` untuk menampilkan data JSON hasil respons AI.
- [ ] Sambungkan fungsi tombol "Simpan ke Diary" untuk mengunggah entri log makanan ke tabel `food_logs` Supabase.

---

## 📅 FASE 3: Optimization, Offline Mode & Future Features
**Fokus Utama:** Memperluas kapabilitas aplikasi dengan On-Device AI lokal dan meluncurkan fitur pelacakan berat badan harian.

### 1. In-App Download Manager & Local Inference (Offline Mode)
- [ ] Taruh berkas model terkompresi (.onnx) ke cloud storage (Supabase Storage / AWS S3).
- [ ] Buat fitur tombol unduh di `SettingsScreen` beserta indikator *progress bar* unduhan model.
- [ ] Integrasikan library `onnxruntime_flutter` untuk memuat model hasil unduhan ke memori lokal HP.
- [ ] Terapkan arsitektur `Dart Isolates` (`background_isolate.dart`) agar proses inferensi gambar lokal tidak memicu UI lag.
- [ ] Sempurnakan logika `ScannerBloc` agar bisa melakukan *switching* otomatis ke lokal engine saat kuota mati atau offline mode aktif.
- [ ] Implementasikan panduan UI *Multi-Angle Prompt* untuk menyarankan user mengambil 2 foto tambahan (sudut 30° & 60°) jika menggunakan kamera ponsel standar.

### 2. Fitness Progression Features (List Masa Depan)
- [ ] Buat halaman `ProfilesScreen` untuk memperbarui data target fisik dan tujuan diet (*bulking/cutting*).
- [ ] Bangun modul UI *Weight Tracker* harian.
- [ ] Hubungkan input berat badan ke tabel `weight_logs` Supabase.
- [ ] Buat grafik tren fluktuasi berat badan mingguan di Dashboard.