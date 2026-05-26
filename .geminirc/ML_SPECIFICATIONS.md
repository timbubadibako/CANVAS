
# Machine Learning & API Specifications: CANVAS

Dokumen ini mendefinisikan arsitektur data, metodologi training model, spesifikasi optimasi biner untuk on-device AI, serta kontrak endpoint API untuk mode pemindaian online.

---

## 1. Dataset Breakdown (Nutrition5k Source)
Model CANVAS dilatih menggunakan acuan dasar dari **Nutrition5k Dataset** seberat kurang lebih **180 GB** yang dirilis oleh Google Research. Berdasarkan paper original, dataset ini bertumpu pada data multimodal biner dunia nyata dengan rincian isi sebagai berikut:
- [cite_start]**Skala Data:** Terdiri dari sekitar 5.000 hidangan unik (*unique dishes*) dunia nyata yang dikonstruksi dari 250 lebih variasi bahan makanan berbeda[cite: 17, 109].
- [cite_start]**Video Streams:** Berisi 20.000 video pendek berdurasi ~8 detik dengan resolusi $1920 \times 1080$[cite: 109, 145]. [cite_start]Video diambil menggunakan array 4 kamera samping yang menyapu sudut 360 derajat piring[cite: 143, 144].
- [cite_start]**Overhead Depth Images:** Berisi citra kedalaman (RGB-D) dari sudut tegak lurus (*overhead*) yang ditangkap menggunakan sensor kamera *Intel RealSense D435* dengan nilai unit kedalaman $1e-4$[cite: 111, 146].
- [cite_start]**Ground Truth Component Weights:** Setiap piring memiliki anotasi berat komponen asli yang dicatat secara inkremental menggunakan timbangan digital presisi tinggi (+/- 1 gram) saat bahan makanan ditambahkan satu per satu[cite: 17, 64, 134, 147].
- [cite_start]**Nutritional Annotations:** Nilai kalori dan makronutrien agregat yang dihitung secara akurat menggunakan referensi basis data *USDA Food and Nutrient Database*[cite: 17, 110].

---

## 2. Training Methodology & Data Reduction
Untuk mengolah data sebesar 180 GB secara keroyokan di komputer tim yang berbeda, diterapkan taktik reduksi data dan arsitektur *multi-task learning* sebagai berikut:

### A. Data Preprocessing & Reduction
- **Frame Downsampling:** Video 1080p tidak ditelan mentah-mentah. [cite_start]Tim hanya akan mengekstrak **setiap frame ke-5 (kelipatan 5)** dari video[cite: 277]. Langkah ini memangkas ukuran penyimpanan hingga 80%.
- [cite_start]**Spatial Resolution Normalization:** Frame RGB dan peta *depth* di-resize masal menjadi resolusi **$256 \times 256$ piksel** dengan teknik *center cropping* untuk mempertahankan area salient piring[cite: 246].

### B. Model Architecture & Multi-Task Loss
- [cite_start]**Backbone Network:** Menggunakan arsitektur *Inception V2/V3* atau *MobileNetV3* (Pre-trained pada JFT-300M / ImageNet) sebagai *feature extractor* dasar[cite: 245, 248].
- [cite_start]**Multi-Task Regression Head:** Output dari tulang punggung network dihubungkan ke 3 atau 5 cabang *Fully Connected (FC) Layers* paralel untuk memprediksi beberapa metrik sekaligus[cite: 262, 265]:
  - [cite_start]Cabang 1: Regresi Nilai Kalori (kcal) [cite: 125, 262]
  - [cite_start]Cabang 2: Regresi Total Massa Makanan (gram) [cite: 125, 262]
  - [cite_start]Cabang 3-5: Regresi Massa Makronutrien (Lemak, Karbohidrat, Protein dalam gram)[cite: 125, 262, 265].
- [cite_start]**Loss Function:** Menggunakan *Mean Absolute Error* (MAE) sebagai fungsi kerugian untuk semua sub-task regresi[cite: 273]. [cite_start]Total *loss* ($l_{multi}$) dihitung secara simultan menggunakan formula[cite: 266, 272]:
$$l_{multi} = l_{macronutrient} + l_{calorie} + l_{total\_weight}$$

---

## 3. Model Saving & Deployment Strategy (Hybrid Target)
Setelah proses *training* mencapai konvergensi, model akan diekspor menjadi dua varian target *deployment* yang berbeda:

### A. Server API Deployment (Online Mode)
- **Format File:** `.pth` (PyTorch) atau `.savedmodel` (TensorFlow).
- **Kondisi Data:** Tetap mempertahankan tipe data *Float32* (Unquantized) seberat **~400 MB** demi akurasi puncak (Target Calorie MAE ~16.5% via data volume).
- **Tempat Host:** Disimpan di server cloud dan dijalankan di balik framework Python FastAPI.

### B. Mobile Device Deployment (Offline Local AI)
- **Format File:** `.onnx` (ONNX Runtime Mobile) atau `.tflite` (TensorFlow Lite).
- **Kondisi Data:** Model mentah 400 MB dikonversi menggunakan teknik **Post-Training Quantization (PTQ)** dari format *Float32* ke *Int8*. Ukuran biner akan menyusut secara ekstrem menjadi **~50 MB - 100 MB**, sehingga aman untuk diunduh masuk ke memori internal smartphone harian pengguna.

---

## 4. FastAPI Backend Endpoint Contracts
Berikut adalah daftar *endpoint* API yang harus disediakan oleh server Python FastAPI untuk melayani *Online Mode Scanning* dari aplikasi Flutter CANVAS:

### A. Endpoint Pemindaian Citra 2D (Standard)
Menerima kiriman gambar RGB tunggal dari kamera ponsel standar.
- **URL:** `/api/v1/scan/predict-2d`
- **Method:** `POST`
- **Content-Type:** `multipart/form-data`
- **Request Body:**
  - `image`: File (Binary image `.jpg`/`.png` hasil jepretan kamera Flutter)
- **Response (200 OK - JSON):**
```json
{
  "status": "success",
  "food_name_estimation": "Grilled Chicken Salad with Broccoli",
  "predictions": {
    "total_mass_g": 215.4,
    "calories_kcal": 255.0,
    "macronutrients": {
      "protein_g": 18.0,
      "carbohydrates_g": 19.4,
      "fat_g": 12.7
    }
  }
}

```

### B. Endpoint Pemindaian Multimodal (Flagship / Multi-Angle)

Menerima kiriman gambar gabungan (*multiview* / citra kedalaman tiruan software) untuk mengejar presisi kalkulasi volume skalar.

* **URL:** `/api/v1/scan/predict-multimodal`
* **Method:** `POST`
* **Content-Type:** `multipart/form-data`
* **Request Body:**
* `primary_image`: File (Foto sudut atas / *overhead*)
* `angle_30_image`: File (Opsional, foto sudut kemiringan 30°)
* `angle_60_image`: File (Opsional, foto sudut kemiringan 60°)


* **Response (200 OK - JSON):**

```json
{
  "status": "success",
  "food_name_estimation": "Grilled Chicken Salad with Broccoli",
  "predictions": {
    "total_mass_g": 215.4,
    "calories_kcal": 255.0,
    "macronutrients": {
      "protein_g": 18.0,
      "carbohydrates_g": 19.4,
      "fat_g": 12.7
    }
  },
  "volume_meta": {
    "estimated_volume_cm3": 36.15,
    "accuracy_boost_applied": true
  }
}
