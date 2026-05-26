# Technical Stack Specification: CANVAS

## 1. Frontend & Mobile Architecture (Multiplatform)
- **Core Framework:** Flutter (Latest Stable Branch)
- **Language:** Dart
- **State Management:** BLoC (Business Logic Component) - Dipilih khusus untuk mengisolasi manajemen state asinkronus yang padat (seperti image stream kamera dan inferensi matriks AI) agar terprediksi dan bebas kebocoran memori (memory leak).
- **Design Pattern:** Component-Driven UI (Pecah komponen widget sekecil mungkin agar modular).
- **Camera API:** `camera` plugin (Flutter official) dengan konfigurasi penangkapan citra intermiten.

## 2. Machine Learning & Execution Engine (Hybrid Deployment)
- **Inference Library:** `onnxruntime_flutter` (ONNX Runtime Mobile) untuk pemrosesan lokal.
- **Model Optimization:** Post-Training Quantization (PTQ) Float32 ke Int8 untuk memotong ukuran file biner model on-device menjadi ringkas (~50 MB - 100 MB).
- **Deployment Strategy:**
  * **Online Mode (Default):** Gambar dikirim via HTTP multipart POST ke Python FastAPI server untuk mengeksekusi model mentah (.pth/.h5 seberat ~400 MB) di cloud.
  * **Offline Local Mode (Optional):** Pengguna mengunduh model biner Int8 (.onnx) secara mandiri ke penyimpanan lokal perangkat melalui in-app download manager.
- **Optimasi Akurasi Non-LiDAR:** Implementasi panduan UI *Multi-Angle Prompt*. [cite_start]Jika pengguna menggunakan kamera 2D biasa, UI akan menyarankan pengambilan sampel foto tambahan dari sudut kemiringan 30° dan 60° (mengikuti metode rotasi kamera paper original Nutrition5k) untuk meningkatkan akurasi estimasi porsi[cite: 144].

## 3. Backend & Cloud Infrastructure
- **BaaS Provider:** Supabase
- **Database:** PostgreSQL (Managed by Supabase) - Untuk menyimpan data user profile, target gizi harian, dan ringkasan data historis log makanan.
- **Authentication:** Supabase Auth (JWT Session via Email/Password).
- **External API Connection:** Python FastAPI Server (Dideploy di RunPod / Hugging Face Spaces untuk melayani request Online Mode Inference menggunakan GPU cloud).