# Project Roadmap & TODO Board: CANVAS

Dokumen ini berfungsi sebagai papan pelacak progres pengerjaan proyek CANVAS yang dibagi ke dalam 4 Fase eksekusi taktis.

---

## 📅 FASE 1: Foundation, Data Engineering & Mobile Boilerplate (PROGRESS: 100%) ✅
**Fokus Utama:** Menyiapkan infrastruktur database, reduksi dataset 180 GB, dan membangun kerangka dasar aplikasi Flutter.

### 1. Backend & Database Setup (Supabase)
- [x] Buat proyek baru di dashboard Supabase.
- [x] Eksekusi skrip SQL DDL (`DATABASE_SCHEMA.md`) di SQL Editor Supabase.
- [x] Pastikan Row Level Security (RLS) dan Trigger `on_auth_user_created` aktif.
- [x] **Setup Storage:** Buat bucket `avatars` untuk penyimpanan foto profil pengguna.

### 2. Mobile Frontend Setup (Flutter)
- [x] Inisialisasi proyek Flutter menggunakan Clean Architecture.
- [x] Susun struktur folder paket sesuai panduan `PROJECT_ARCHITECTURE.md`.
- [x] Pasang dependensi utama (`flutter_bloc`, `supabase_flutter`, `image_picker`, `google_generative_ai`, `shared_preferences`, `shimmer`).
- [x] Implementasi **Artistic Studio Theme** (Persistensi tema Light/Dark aktif).
- [x] Buat halaman `LoginScreen` dan `RegisterScreen` dengan Logo adaptif & Autofill.
- [x] Implementasikan **Smart Auth Flow**: Registrasi -> Login -> Auto-detect New User -> Onboarding.

---

## 📅 FASE 2: Model Training, API Gateway & Core UI Integration (PROGRESS: 75%) 🚀
**Fokus Utama:** Melatih model AI, mendeploy API, dan menghubungkan core scanner kamera.

### 1. Core Mobile Integration
- [x] **Dynamic Dashboard:** Visualisasi gizi harian yang otomatis reset setiap hari.
- [x] **Studio Bottom Sheet Cropper:** Implementasi pemotong gambar 1:1 berbasis Flutter (Anti-Status Bar Bug).
- [x] **Avatar Management:** Unggah, potong, dan kompres foto profil langsung ke Supabase Storage.
- [x] **Real-Time Food Logging:** Sambungkan tombol "LOG TO GALLERY" untuk menyimpan data gizi asli ke Supabase.
- [ ] **CameraBloc:** Refaktor logika kamera ke BLoC (Cleanup `ai_scanner_screen.dart`).

### 2. Backend & AI Integration (NEXT TASK)
- [ ] **Gemini Vision Integration:** Hubungkan scanner ke Gemini API untuk analisis makanan asli (Bukan Mockup).
- [ ] **Backend API (FastAPI):** Deploy server untuk melayani Online Mode Inference.

---

## 📅 FASE 3: Optimization & Progression Features (PROGRESS: 40%) 🛠️
**Fokus Utama:** Memperluas kapabilitas aplikasi dan pengujian otomatis.

### 1. Automation & Analysis
- [x] **Appium Testing Suite:** Skrip pengujian E2E untuk alur registrasi hingga dashboard.
- [x] **README Showcase:** Galeri visual premium (Dark/Light) dan dokumentasi Nutrition5k.
- [x] **Studio Bot Enhancement:** Injeksi konteks gizi real-time (Bot tau apa yang kamu makan hari ini).

### 2. Physical Tracking
- [x] **Onboarding Preferences:** 5-Step Journey dengan algoritma kalkulasi gizi otomatis.
- [ ] **Weight Tracker DB Sync:** Hubungkan input berat badan ke tabel `weight_logs` Supabase.

---

## 🚀 PHASE 4: HIGH-PERFORMANCE OPTIMIZATION (PROGRESS: 100%) ✅
- [x] **Background Isolates:** Kompresi gambar berjalan di Isolate (`compute()`) - 60 FPS.
- [x] **Repaint Boundaries:** Isolasi rendering animasi scanner (Efisiensi Baterai).
- [x] **Parallel Pre-fetching:** Loading data profil dan logs secara paralel di Dashboard.
- [x] **Premium Shimmer UI:** Skeleton loaders mewah di seluruh aplikasi.

---

**Last Status Update:** Rabu, 27 Mei 2026, 15:00 WIB
**Current Focus:** Integrasi Gemini Vision API untuk Real-Time Detection.
