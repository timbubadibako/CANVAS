# 🌁 Bridging Specification: Mobile Scanner to Python AI Engine

Dokumen ini mendefinisikan sinkronisasi antara alur **3-Step Capture** di Flutter dengan **Multi-View Task Regressor** di Python untuk mencapai akurasi estimasi volume makanan yang optimal.

---

## 1. Input Mapping (Data Alignment)
Aplikasi mobile menangkap 3 lapisan gambar (*layers*) yang harus dipetakan secara presisi ke dalam *tensor input* model Python:

| Step di Flutter | Sudut Pandang (Camera Angle) | Variabel di API / Python | Peran dalam Model |
| :--- | :--- | :--- | :--- |
| **Step 0 (Base)** | **Overhead (90°)** | `image_top` / `overhead` | Identifikasi jenis bahan makanan & estimasi area piring. |
| **Step 1 (Capture 1)**| **Side View (30°)** | `image_side_30` | Estimasi ketebalan/tinggi makanan (Depth cues). |
| **Step 2 (Capture 2)**| **Side View (60°)** | `image_side_60` | Rekonstruksi volume 3D untuk kalkulasi massa (gram). |

---

## 2. Preprocessing Pipeline (Normalization)
Agar hasil prediksi tidak meleset, gambar dari HP harus melalui standarisasi sebelum masuk ke model:

1.  **Resolution:** Semua gambar akan di-resize menjadi **$256 \times 256$ piksel** (menggunakan *Center Crop* untuk mempertahankan fokus piring).
2.  **Color Space:** Konversi ke RGB (hilangkan transparansi jika ada).
3.  **Normalization:** Skalakan nilai piksel ke rentang `[0, 1]` atau `[-1, 1]` sesuai dengan konfigurasi backbone (MobileNet/Inception) yang digunakan di Python.

---

## 3. Hardware-Aware Inference Logic
Aplikasi mobile akan mendeteksi kapabilitas sensor perangkat sebelum memulai proses scanning untuk menentukan jalur inferensi:

| Jalur Inferensi | Kriteria Hardware | Input Data | Akurasi Target |
| :--- | :--- | :--- | :--- |
| **Flagship Path** | Memiliki LiDAR / ToF Sensor | RGB-D (RGB + Depth Map Asli) | **Tinggi (MAE < 15%)** |
| **Standard Path** | Hanya Kamera RGB Standar | Multi-View RGB (3-Angle) | **Menengah (MAE < 25%)** |

### A. Mekanisme Fallback Kedalaman
Jika perangkat **tidak memiliki sensor LiDAR**, sistem akan beralih ke salah satu opsi berikut:
1.  **Monocular Depth Estimation (Saran Model):** Menjalankan model AI tambahan di backend/mobile untuk memprediksi peta kedalaman (depth map) secara sintetis dari gambar *overhead* RGB tunggal.
2.  **Multi-View Regression:** Mengandalkan perbedaan perspektif dari 3 sudut (0°, 30°, 60°) untuk mengestimasi volume tanpa peta kedalaman eksplisit.

---

## 4. Prediction Averaging Strategy
Untuk menjamin stabilitas hasil, Python Engine tidak hanya memprediksi satu kali, melainkan melakukan agregasi dari 3 input gambar:

1.  **Independent Inference:** Model melakukan prediksi kalori & makro pada masing-masing gambar (`pred_top`, `pred_30`, `pred_60`).
2.  **Weighted Averaging:** Hasil akhir dihitung menggunakan rata-rata tertimbang, di mana sudut *Overhead* biasanya memiliki bobot lebih besar untuk identifikasi bahan, sementara sudut samping memiliki bobot lebih besar untuk estimasi volume/tinggi.
    *   `Final_Kcal = (W1 * pred_top) + (W2 * pred_30) + (W3 * pred_60)`

---

## 5. API Contract (Enhanced Multipart)
**Endpoint:** `POST /api/v1/predict/multimodal`

**Payload:**
- `images`: List of Files
- `metadata`: 
  ```json
  {
    "has_lidar": true/false,
    "depth_data": "base64_encoded_depth_map" // Dikirim jika has_lidar true
  }
  ```

---

## 5. Sinkronisasi Logika (Flutter Side)
Untuk memastikan data tidak tertukar, `CameraBloc` (yang akan kita buat) akan membungkus ketiga file gambar tersebut ke dalam `Map<String, File>` sebelum memicu proses upload:

```dart
final Map<String, File> captureBundle = {
  'top': file0,
  'side_30': file1,
  'side_60': file2,
};
```

**Status:** Dokumen ini siap dijadikan acuan untuk penulisan endpoint FastAPI dan integrasi `CameraBloc`.
**Update Terakhir:** 28 Mei 2026
