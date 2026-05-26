# Application Flow & User Journey Map: CANVAS

Dokumen ini memetakan alur navigasi pengguna, logika percabangan fitur (Online/Offline), dan mekanisme interaksi UI di dalam aplikasi CANVAS.

---

## 1. Onboarding & Authentication Flow
Alur pertama kali pengguna berinteraksi dengan aplikasi untuk mengamankan sesi token JWT melalui Supabase Auth.

```text
[ Start: Buka Aplikasi ]
           │
           ▼
[ Check Session Session via Supabase ]
           │
           ├───► (Ada Sesi Aktif) ────► [ Langsung ke DashboardScreen ]
           │
           └───► (Sesi Kosong) ───────► [ Tampilkan LoginScreen ]
                                               │
                                               ├─► Input Email & Password ──► [ Submit Auth Event ]
                                               │                                      │
                                               │                                      ▼
                                               │                           [ Supabase Auth Success ]
                                               │                                      │
                                               ▼                                      ▼
                                     [ Register Akun Baru ] ──────────────► [ Masuk ke Dashboard ]

```

---

## 2. Main Dashboard & Tracking Flow

Pusat informasi gizi harian pengguna. Menampilkan ringkasan konsumsi dan tombol aksi utama untuk membuka kamera *scanner*.

* **Dashboard View:**
* BLoC memicu pengambilan data historis gizi dari tabel `food_logs` Supabase berdasarkan *User ID*.
* UI merender diagram lingkaran pemenuhan target Kalori, Protein, Karbohidrat, dan Lemak hari ini.


* **Aksi Pengguna:**
* Pengguna menekan *Floating Action Button* (FAB) bergambar kamera $\rightarrow$ Navigasi ke `CameraScannerScreen`.



---

## 3. Core AI Scanner Flow (The Hybrid Architecture)

Ini adalah jantung mekanis dari aplikasi **CANVAS**. Logika program terpecah menjadi dua jalur berdasarkan preferensi mode yang dipilih pengguna di halaman pengaturan (`SettingsScreen`).

```text
                  [ Pengguna Membuka CameraScannerScreen ]
                                    │
                                    ▼
                     [ Tampilkan Live Camera Preview ]
                     [ Overlay Target Bounding Box ]
                                    │
                                    ▼
                        [ Tombol Shutter Ditekan ]
                                    │
                                    ▼
                     [ Pengecekan Mode Status di BLoC ]
                                    │
           ┌────────────────────────┴────────────────────────┐
           ▼                                                 ▼
   [ 1. ONLINE MODE ]                                [ 2. OFFLINE MODE ]
(Default / Ukuran App Ringan)                     (Model Terunduh Lokal Lokal)
           │                                                 │
           ▼                                                 ▼
[ Ambil 1x Foto RGB ]                              [ Cek Ketersediaan Hardware ]
           │                                                 │
           ▼                                                 ├─► (Ada LiDAR/Depth - iOS Pro)
[ Kirim multipart/form-data ]                                │   Kalkulasi volume skalar matriks 3D
[cite_start][ POST ke FastAPI Server ]                                   │   Target MAE: ~16.5%[cite: 18, 311].
           │                                                 │
           ▼                                                 ├─► (Kamera 2D Standar - Android/iOS)
[ Server Memproses Model ]                                   │   Jalankan Regresi Langsung 2D.
[cite_start][ Mentah Float32 (~400MB) ]                                  │   Target MAE: ~26.1%[cite: 286].
           │                                                 │   │
           ▼                                                 │   ▼
[ Return JSON Data Gizi ]                                    │   [ Trigger Multi-Angle Prompt UI ]
           │                                                 │   Saran ambil 2 foto tambahan
           [cite_start]│                                                 │   dari sudut kemiringan 30° & 60°[cite: 144].
           │                                                 │   │
           └────────────────────────┬────────────────────────┘   ▼
                                    │                     [ Gabungkan Fitur Vektor ]
                                    ▼                                │
                        [ Tampilkan Teks Output ] ◄──────────────────┘
                    [ di NutritionFactsCard Widget ]
                                    │
                                    ▼
                [ Tekan Tombol "Simpan ke Diary" ]
                                    │
                                    ▼
                 [ Kirim Payload Data via BLoC ]
                 [ Sinkronisasi ke Tabel Supabase ] ──► [ Back to Dashboard ]

```

---

## 4. Detailed Step-by-Step UI Scanner Experience

### Langkah 1: Pemosisian Kamera (*Overhead Positioning*)

* UI menampilkan instruksi: *"Posisikan piring makanan tepat di dalam kotak tengah, foto tegak lurus dari atas makanan."* 


* Sensor akselerometer internal HP diakses secara pasif untuk memastikan sudut pengambilan gambar benar-benar lurus (*overhead view*).



### Langkah 2: Proses Eksekusi & Kondisi Loading State

* Saat gambar diambil, `ScannerBloc` memancarkan `ScannerLoadingState`.
* UI menghentikan sementara (*freeze*) *preview* kamera dan menampilkan animasi *loading shimmer* di atas gambar makanan tersebut.

### Langkah 3: Tampilan Hasil (*Success State*)

* `ScannerBloc` memancarkan `ScannerSuccessState` setelah mendapatkan respons (baik dari server cloud maupun inferensi lokal ONNX).
* Widget `NutritionFactsCard` meluncur muncul dari bawah layar (*bottom sheet*), menampilkan rincian:
* Nama Makanan Terdeteksi (Estimasi Komponen).


* Estimasi Berat Total Makanan (gram).


* Total Kalori (kcal).


* Makronutrien: Protein (g), Karbohidrat (g), Lemak (g).





### Langkah 4: Penyimpanan (*Log Finalization*)

* Pengguna dapat melakukan *editing* nama makanan atau koreksi porsi kasarnya secara manual jika diperlukan sebelum disimpan.
* Saat tombol *"Simpan"* diketuk, data dikirim langsung ke database Supabase, memicu penghapusan *cache memory tracking* gambar di lokal HP, dan mengembalikan navigator halaman ke `DashboardScreen`.
