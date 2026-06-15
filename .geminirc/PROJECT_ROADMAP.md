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
- [x] Implementasi **Professional Functional Theme** (Persistensi tema Light/Dark aktif).
- [x] Buat halaman `LoginScreen` dan `RegisterScreen` dengan Logo adaptif & Autofill.
- [x] Implementasikan **Smart Auth Flow**: Registrasi -> Login -> Auto-detect New User -> Onboarding.
- [x] **Guest Mode Support:** Menambahkan akses masuk tanpa akun dengan fitur lokal penuh.

---

## 📅 FASE 2: Core UI Integration & Local Persistence (PROGRESS: 100%) ✅
**Fokus Utama:** Menghubungkan scanner kamera dan memastikan data tersimpan aman secara lokal.

### 1. Core Mobile Integration
- [x] **Dynamic Dashboard:** Visualisasi gizi harian yang otomatis reset setiap hari (Sinkronisasi lokal Guest).
- [x] **BottomSheet Cropper:** Implementasi pemotong gambar 1:1 berbasis Flutter (Anti-Status Bar Bug).
- [x] **Avatar Management:** Unggah, potong, dan kompres foto profil (Sinkronisasi lokal Guest).
- [x] **Real-Time Food Logging:** Menyimpan log makanan hasil scan langsung ke memori lokal HP (JSON).
- [x] **Manual Log Management:** Menambahkan fitur hapus log makanan dari riwayat.

### 2. Rebranding & UI Cleanup
- [x] **Indentity Wipe:** Menghapus semua istilah "Studio", "Artist", "Masterpiece", dan "Layers".
- [x] **English Localization:** Mengubah semua label UI ke Bahasa Inggris fungsional yang lugas.

---

## 📅 FASE 3: AI Inference & Analysis (PROGRESS: 100%) ✅
**Fokus Utama:** Mengaktifkan mesin prediksi nutrisi berbasis ONNX.

### 1. AI Integration
- [x] **Dual-Inference Engine:** Implementasi jalur Cloud (FastAPI) dan Lokal (ONNX) dengan fallback otomatis.
- [x] **FP16/FP32 Sync:** Menangani sinkronisasi tipe data biner antara Flutter dan model ONNX.
- [x] **Multi-View Preprocessing:** Implementasi Resize 224x224 & Normalisasi ImageNet secara otomatis sebelum inferensi.
- [x] **Result Calibration:** Menyesuaikan mapping output tensor sesuai standar dataset Nutrition5k.

### 2. Physical Tracking
- [x] **Onboarding Preferences:** 5-Step Journey dengan algoritma kalkulasi gizi otomatis (Local Persistence).
- [x] **Nutrition Analytics:** Grafik mingguan, BMI, dan Nutritional Balance (PCF) yang terisi dari data lokal.

---

## 🚀 PHASE 4: HIGH-PERFORMANCE OPTIMIZATION (PROGRESS: 100%) ✅
- [x] **Background Processing:** Kompresi gambar dan decoding model berjalan asinkron - 60 FPS.
- [x] **Memory Management:** Melepaskan (release) tensor input setelah inferensi untuk mencegah memory leak.
- [x] **Premium UI polish:** Skeleton loaders (Shimmer) di Dashboard dan Diary untuk UX yang halus.

---

**Status Proyek:** STABLE (Ready for Final Commit)
**Update Terakhir:** Senin, 15 Juni 2026
