## 📐 Outline Pemetaan Algoritma Berdasarkan 5 Prefs

Berikut adalah bagaimana setiap data dari *Onboarding Preferences* akan dikonsumsi oleh fungsi matematika di backend/mobile kalian:

### 1. Prefs 2 & 3: Penentu **BMR (Basal Metabolic Rate)**

Data fisik awal digunakan untuk menghitung kalori minimal yang dibutuhkan tubuh untuk bertahan hidup dalam kondisi istirahat total.

* **Algoritma Acuan:** Rumus **Mifflin-St Jeor** (Standar industri kebugaran modern).
* **Cara Kerja:** Menyatukan data *Height (CM)*, *Weight (KG)*, dan *Gender/Age* (Variabel tambahan wajib, lihat di bawah).

### 2. Prefs 3 (Activity Level): Penentu **TDEE (Total Daily Energy Expenditure)**

Menghitung total kalori riil yang dibakar user dalam satu hari setelah diakumulasikan dengan aktivitas fisik mereka.

* **Algoritma Acuan:** *Activity Multiplier (Katch-McArdle / Harris-Benedict Matrix)*.
* **Cara Kerja:** Nilai BMR dari tahap 1 akan dikalikan dengan bobot aktivitas:
* *Sedentary:* $BMR \times 1.2$
* *Moderate:* $BMR \times 1.55$
* *Active:* $BMR \times 1.725$



### 3. Prefs 4 (Strategy - Intensity): Penentu **Target Kalori Harian**

Menentukan apakah user harus makan di bawah atau di atas nilai TDEE mereka berdasarkan tujuan jangka pendek mereka.

* **Algoritma Acuan:** *Caloric Deficit / Surplus Formula*.
* **Cara Kerja:**
* **Cutting (Defisit):** $TDEE - 500 \text{ kcal}$ (Atau defisit aman 15-20%).
* **Maintenance:** Sama dengan nilai $TDEE$.
* **Bulking (Surplus):** $TDEE + 300 \text{ s.d } 500 \text{ kcal}$ (Surplus bersih untuk *lean muscle building*).



### 4. Prefs 1 (Primary Goal) & Prefs 3 (Dietary Style): Penentu **Rasio Makronutrien (P / C / F)**

Bagian krusial untuk memecah total kalori harian menjadi satuan gram Protein, Karbohidrat, dan Lemak.

* **Algoritma Acuan:** *Macronutrient Gram-per-KG Distribution*.
* **Cara Kerja:**
* **Build Muscle / Bulking:** Target Protein dikunci tinggi di angka $2.0 \text{ s.d } 2.2 \text{ gram per KG berat badan}$ user. Sisa kalori dibagi untuk Lemak (25%) dan Karbohidrat.
* **Weight Loss / Cutting:** Protein tetap dijaga tinggi ($2.0 \text{g/KG}$) untuk mencegah otot menyusut, namun rasio Karbohidrat dipangkas lebih rendah.
* **Dietary Style (Vegetarian):** Jika memilih Vegetarian, algoritma *auto-suggest* bahan makanan di UI aplikasi akan memprioritaskan sumber protein nabati (tempe, tahu, sejenisnya) alih-alih dada ayam hasil deteksi AI *scanner* piring kalian.



### 5. Prefs 5 (Motivation): Penentu **Psikologi & Notifikasi Engine**

Data ini tidak masuk ke rumus matematika gizi, melainkan ke sistem *engagement* pengguna.

* **Cara Kerja:** Jika motivasinya *Athletic Peak*, teks motivasi harian di Dashboard atau *push notification* aplikasi akan bergaya *high-intensity* khas atlet. Jika *Health Recovery*, bahasanya akan lebih lembut dan berfokus pada kesehatan jantung/vitalitas tubuh.

---

## 🚨 Tambahan Prefs yang Masih Kurang Wajib

Bro, rumus **Mifflin-St Jeor** atau **Harris-Benedict** untuk menghitung BMR **MUSTAHIL** bisa dieksekusi kalau lu gak tahu **Umur (Age)** dan **Jenis Kelamin (Gender)** biologis user. Karena kebutuhan kalori pria $55\text{kg}$ dan wanita $55\text{kg}$ dengan tinggi yang sama itu hasil akhirnya beda jauh.

Gua sarankan lu **selipkan 2 pertanyaan ini ke dalam Tahap 2 (Body Canvas)** agar layat inputnya menyatu dan efisien:

### Pertanyaan Tambahan 1 (Single Answer - Masuk Tahap 2)

* **Judul:** Biological Sex
* **Pertanyaan Utama:** What is your biological sex?
* **Opsi Jawaban:** * `[ ] Male`
* `[ ] Female`


* **Alasan Teknis:** Di dalam rumus BMR Mifflin-St Jeor, konstanta untuk Pria adalah $+5$, sedangkan Wanita adalah $-161$.

### Pertanyaan Tambahan 2 (Input Angka - Masuk Tahap 2)

* **Judul:** Age
* **Pertanyaan Utama:** How old are you?
* **Opsi Input:** Angka berupa tahun (Umur: `[ 22 ]` Years old).
* **Alasan Teknis:** Metabolisme tubuh menurun seiring bertambahnya usia. Rumus matematika BMR membutuhkan pengali $- (4.92 \times \text{Usia})$.

class AppConstants {
  static const String supabaseUrl = 'https://hjgzhzmzafsxnedlogdg.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_qud9xDOXC8eX1nYhD-kYlA_uzackR8G';
}
class AppConstants {
  static const String supabaseUrl = 'https://hjgzhzmzafsxnedlogdg.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_qud9xDOXC8eX1nYhD-kYlA_uzackR8G';
  static const String geminiApiKey = 'AIzaSyAr4YAJ-PuDIE_CIGIU_ElivMGbyyknlSM';
}


