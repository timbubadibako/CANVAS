# **CANVAS**

**Project Name:** CANVAS (*Computerized Automated Nutrition & Volume Analysis System*)

**Framework Stack:** Flutter (Mobile) & Supabase (Backend/Database)

**Core Technology:** On-Device Computer Vision & Multimodal Regression Models 

---

## 1. Executive Summary (Latar Belakang)

Masalah utama pada aplikasi pelacak nutrisi saat ini (*Nutritional Tracking Apps*) adalah ketergantungan pada input manual pengguna yang rumit dan tidak akurat karena keterbatasan manusia dalam mengestimasi porsi makanan secara visual.

**CANVAS** hadir sebagai solusi sistem otomatis berbasis visi komputer multiplatform (Flutter) untuk memprediksi nilai kalori dan makronutrien (karbohidrat, lemak, protein) secara langsung dari makanan dunia nyata (*generic food*). Berdasarkan penelitian pada paper *Nutrition5k*, estimasi porsi visual manusia memiliki tingkat kesalahan (*error*) hingga 41%–53%. CANVAS mengadaptasi metodologi penelitian tersebut untuk memangkas *error* prediksi menggunakan pendekatan *multimodal* (RGB + Estimasi Volume Skalar).

---

## 2. Core Objectives (Tujuan Proyek)

* **Otomatisasi Pelacakan Nutrisi:** Membantu pengguna mencatat asupan kalori dan makronutrien harian hanya dengan mengarahkan kamera ponsel ke arah makanan.
* **Optimasi Estimasi Porsi:** Mengatasi kelemahan kamera 2D standar dalam memprediksi berat/porsi makanan dengan menerapkan logika estimasi volume skalar.
* **Implementasi On-Device AI:** Menjalankan inferensi model *machine learning* langsung di dalam perangkat *smartphone* (*on-device*) untuk menjamin kecepatan, privasi, dan efisiensi biaya server.

---

## 3. Key Features & Scope (Fitur Utama)

### A. Dual-Engine Scanner (Fitur Utama)

Sistem pemindaian pintar yang mendeteksi jenis makanan sekaligus porsinya menggunakan dua skenario *hardware*:

* **Mode Flagship (LiDAR/Depth Assisted):** Menggunakan sensor kedalaman fisik pada *smartphone* (seperti iPhone Pro series) untuk menghitung volume skalar makanan secara presisi guna mencapai akurasi optimal (Target MAE ~16.5%).
* **Mode Standar (2D Direct Prediction & Multi-Angle):** Menggunakan kamera 2D biasa pada ponsel umum dengan estimasi regresi langsung (Target MAE ~26.1%) atau opsi pengambilan foto dari beberapa sudut (*multi-view*) untuk rekonstruksi volume tiruan.

### B. Daily Diet Log & Analytics

* Sinkronisasi riwayat makanan harian pengguna ke dalam database cloud.
* Grafik perkembangan kalori harian dan pemenuhan target makronutrien (Lemak, Karbohidrat, Protein).

### C. Localized Food Database Integration

* Integrasi model awal menggunakan *USDA Food Database* (berdasarkan dataset Nutrition5k) yang dikombinasikan dengan pemetaan nutrisi makanan lokal untuk adaptasi kuliner harian pengguna.

---

## 4. Technical Architecture (Arsitektur Teknologi)

### Mobile Frontend (Flutter)

* **UI/UX:** Menggunakan pendekatan *Component-Driven UI* (Widget dekoratif yang modular dan reaktif terhadap *state* AI).
* **Camera Handling:** Memanfaatkan *stream* kamera *real-time* per frame untuk kalkulasi matriks gambar.
* **ML Inference Engine:** Menggunakan **ONNX Runtime Mobile** atau **TFLite Flutter** untuk mengeksekusi model hasil *training* yang sudah dikompresi (Kuantisasi parameter ke *Int8* seberat ~50 MB).

### Machine Learning Pipeline (Python - Eksperimental Tim)

* **Backbone Model:** Inception V2/V3 atau MobileNetV3 (Pre-trained).
* **Dataset:** *Nutrition5k Dataset* (180 GB mentah, di-downsample menjadi porsi frame esensial untuk efisiensi *training*).
* **Output Model:** *Multi-task learning head* yang mengeluarkan 5 output regresi sekaligus: Kalori, Total Massa, Karbohidrat, Lemak, dan Protein.

### Backend & Storage (Supabase)

* PostgreSQL Database untuk menyimpan data user profile, target diet harian, dan riwayat *food logging*.
* Supabase Auth untuk manajemen *login/register* tim dan pengguna.

---

## 5. Timeline & Pembagian Tugas Tim (3-Phase Workflow)

### Fase 1: Data Engineering & Preprocessing (Keroyokan PC Lokal)

* Pembagian tugas mengunduh dan memotong frame video dataset Nutrition5k secara sekuensial (tiap kelipatan 5 frame).
* Melakukan *resize* massal gambar ke ukuran $256 \times 256$ piksel dan konversi ke format biner untuk memangkas ukuran data dari 180 GB ke ukuran yang siap latih.

### Fase 2: Model Training & Mobile Boilerplate (Paralel)

* **Sub-Tim AI:** Melatih model *multi-task regressor* di cloud/lokal dan melakukan optimasi kuantisasi model menjadi file ringan.
* **Sub-Tim Mobile:** Membuat kerangka aplikasi Flutter, integrasi SDK Supabase, dan implementasi fitur akses kamera.

### Fase 3: Integrasi & Pengujian Engine

* Memasukkan file model AI ke dalam aset aplikasi Flutter.
* Menghubungkan *output* inferensi kamera on-device ke dalam fungsi *auto-fill* log makanan di UI aplikasi.
* Pengujian akurasi sistem (*user acceptance testing*).
