# Project Brief: CANVAS (Computerized Automated Nutrition & Volume Analysis System)

## 1. Project Overview
CANVAS adalah sistem pelacakan nutrisi otomatis multimodal yang dikembangkan untuk mendeteksi jenis makanan sekaligus mengestimasi nilai kalori dan makronutrien (carbs, protein, fat) secara real-time langsung melalui perangkat mobile. 

Proyek ini merupakan implementasi dan adaptasi dari metodologi paper riset "Nutrition5k" (Google Research, 2021) yang membuktikan bahwa integrasi data kedalaman (depth map) untuk menghitung volume skalar makanan dapat memangkas error prediksi hingga mengalahkan kemampuan estimasi visual ahli gizi profesional.

## 2. Problem Statement
- Pelacakan nutrisi konvensional lewat aplikasi seperti MyFitnessPal sangat menyita waktu karena pengguna harus memasukkan tiap komponen porsi secara manual.
- Estimasi porsi secara visual oleh manusia sangat tidak akurat; masyarakat awam meleset hingga 53% dan ahli gizi profesional pun masih meleset hingga 41% saat menebak kalori lewat mata telanjang.
- Kamera 2D pada smartphone standar kehilangan informasi spasial (kedalaman/ketebalan makanan), menyebabkan AI komputer visi biasa sering salah membedakan porsi besar dan kecil pada jenis makanan yang sama (Error kalori 2D murni mencapai 26.1%).

## 3. Core Objectives & Scope
- **Automated Food Logging:** Menggantikan input teks manual dengan pemindaian kamera pintar berbasis machine learning.
- **Volume-Assisted Estimation:** Mengintegrasikan komputasi depth data (LiDAR/ToF pada iOS flagship) untuk mendapatkan estimasi massa makanan yang presisi dengan target akurasi optimal (Error kalori ~16.5%).
- **Cross-Platform Fallback:** Menyediakan mekanisme fallback pintar untuk perangkat non-LiDAR (Android/iOS standar) menggunakan regresi langsung dari 1x foto RGB (Error kalori ~26.1%).
- **Hybrid AI Execution Engine:** Menyediakan opsi pemrosesan fleksibel:
  * *Online Mode (Default):* Gambar dikirim via API untuk menjaga ukuran awal aplikasi tetap ringan.
  * *Offline Local Mode:* User bisa men-download model biner hasil training secara opsional agar proses AI berjalan 100% lokal tanpa internet.

## 4. Target Audience & Use Cases
- **Fitness & Bodybuilding Enthusiasts:** Mempermudah tracking surplus/defisit kalori dan pemenuhan target protein harian secara presisi.
- **Medical & Diet Care:** Membantu kontrol porsi karbohidrat dan lemak harian tanpa ketergantungan penuh pada timbangan digital fisik.