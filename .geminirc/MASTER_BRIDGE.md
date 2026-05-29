# 🚀 MASTER BRIDGING SPECIFICATION: CANVAS ENGINE (DUAL-INFERENCE ARCHITECTURE)

**Dokumen ini adalah Source of Truth (Kebenaran Mutlak)** untuk sinkronisasi pengembangan antara Backend AI (Python) dan Mobile App (Flutter). Tolong baca instruksi di bawah ini sesuai dengan peran (Agent) Anda.

## 1. CORE ENGINE RULES (Ketetapan Matematis AI)
Semua pemrosesan gambar, baik di server maupun di HP pengguna, **WAJIB** mengikuti standar input model EfficientNet berikut. Jika melanggar, hasil prediksi akan hancur (garbage in, garbage out).

* **Resolusi Tensor:** `224 x 224` piksel. (Bukan 256x256).
* **Format Warna:** RGB.
* **Normalisasi (ImageNet Standard):**
    * Mean: `[0.485, 0.456, 0.406]`
    * Std: `[0.229, 0.224, 0.225]`
* **Multi-View Tactic:** Model menerima input dari sudut atas (Overhead 90°) dan sudut samping (30°/60°). Jika tidak menggunakan LiDAR, hasil prediksi akhir adalah hasil *Ensemble/Averaging* dari inference masing-masing gambar.

---

## 2. BUSINESS LOGIC: DUAL-INFERENCE ROUTING (FastAPI vs ONNX)
Aplikasi menerapkan strategi **Reverse Cloud** untuk efisiensi server dan penawaran fitur premium:

* **Free Tier (FastAPI - Cloud):** Komputasi dilakukan di server. Menggunakan model yang lebih ringan (misal: EfficientNet-B0). Respons bergantung pada latensi jaringan.
* **Premium Tier (ONNX - On-Device):** Komputasi dilakukan secara lokal di HP pengguna tanpa internet (Offline Mode). Kecepatan instan, akurasi lebih tajam (misal menggunakan bobot model EfficientNet-B2). 

---

## 3. INSTRUKSIONAL UNTUK PYTHON AGENT (BACKEND & AI)
Tugas Anda adalah memperbarui script `.ipynb` dan membuat `api.py` (FastAPI).

**A. Ekspor Model di `.ipynb`:**
1.  Pastikan model PyTorch diekspor menggunakan `torch.onnx.export`.
2.  Buat *dynamic axes* untuk `batch_size` agar model bisa menerima input 1 gambar tunggal `[1, 3, 224, 224]` ataupun 3 gambar sekaligus `[3, 3, 224, 224]` dalam sekali eksekusi.
3.  Simpan model final dengan nama `canvas_multiview_premium.onnx`.

**B. Pembuatan FastAPI (`api.py`):**
1.  Buat endpoint `POST /api/v1/predict/multimodal`.
2.  Endpoint menerima `multipart/form-data` dengan field: `image_top`, `image_side_1`, dan `image_side_2`.
3.  Lakukan preprocessing manual (Resize 224x224 & ImageNet Normalization) menggunakan OpenCV/Pillow + PyTorch Transforms.
4.  Lakukan *forward pass* ke model PyTorch ringan (Free Tier).
5.  Kembalikan JSON berstruktur:
    ```json
    {
      "calories": float,
      "mass": float,
      "fat": float,
      "carb": float,
      "protein": float,
      "source": "cloud_fastapi"
    }
    ```

---

## 4. INSTRUKSIONAL UNTUK FLUTTER AGENT (MOBILE)
Tugas Anda adalah membangun arsitektur routing inferensi dan mengeksekusi model ONNX secara lokal di Dart.

**A. Arsitektur Polimorfisme (Routing):**
Buat *Abstract Class* atau *Interface* `NutritionInferenceService`. Buat dua implementasi:
1.  `CloudInferenceService`: Membungkus file gambar ke `MultipartRequest` HTTP Dio dan menembak FastAPI.
2.  `LocalOnnxService`: Menjalankan inference secara lokal menggunakan package `onnxruntime` atau `tflite_flutter` (jika ONNX dikonversi ke TFLite).
3.  Buat BLoC/Controller yang mengecek status langganan (*subscription*) user. Jika Premium -> gunakan `LocalOnnxService`, jika Free -> gunakan `CloudInferenceService`.

**B. Preprocessing Lokal (CRITICAL untuk ONNX):**
Di dalam `LocalOnnxService`, Anda **wajib** menulis fungsi image preprocessing mandiri menggunakan package `image`.
1.  Resize gambar ke `224x224`.
2.  Lakukan iterasi per piksel (R, G, B) dan konversi ke skala Float32.
3.  Terapkan normalisasi ImageNet secara manual pada struktur list array/Float32List sebelum dilempar ke session ONNX:
    * `R_norm = ((R / 255.0) - 0.485) / 0.229`
    * `G_norm = ((G / 255.0) - 0.456) / 0.224`
    * `B_norm = ((B / 255.0) - 0.406) / 0.225`
4.  Lakukan prediksi beruntun untuk ketiga gambar (Atas, Samping 1, Samping 2) lalu rata-ratakan hasil array numeriknya untuk mendapatkan nilai akhir nutrisi.