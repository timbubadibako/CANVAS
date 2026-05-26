
# Database Schema Specification: CANVAS

Dokumen ini mendefinisikan struktur tabel, tipe data, relasi kunci (*foreign keys*), dan kebijakan keamanan (RLS) pada database PostgreSQL yang dikelola melalui Supabase.

---

## 1. Entity Relationship Diagram (Conceptual Overview)
```text
  [auth.users] (Supabase Built-in)
       │
       ├─ (1:1) ──► [profiles] (Data Target Fisik & Diet User)
       │
       ├─ (1:N) ──► [food_logs] (Riwayat Scan & Konsumsi Makanan)
       │
       └─ (1:N) ──► [weight_logs] (Riwayat Progres Berat Badan)

```

---

## 2. Table Definitions (DDL SQL)

### A. Tabel `profiles`

Tabel ini menyimpan data tambahan pengguna untuk kalkulasi target kalori harian berdasarkan profil fisik dan tujuan diet mereka (misal: *bulking* atau *cutting*).

```sql
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    birth_date DATE,
    gender TEXT CHECK (gender IN ('male', 'female')),
    height_cm REAL,
    fitness_goal TEXT CHECK (fitness_goal IN ('cutting', 'maintenance', 'bulking')),
    daily_calorie_target INT DEFAULT 2000,
    daily_protein_target REAL,
    daily_carbs_target REAL,
    daily_fat_target REAL,
    updated_at TIMESTAMPTZ DEFAULT now()
);

```

### B. Tabel `food_logs`

Tabel utama untuk menampung riwayat *scanning* makanan. Menyimpan nama komponen makanan, total massa, kalori, serta rincian makronutrien hasil komputasi model AI.

```sql
CREATE TABLE public.food_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    food_name TEXT NOT NULL, -- Nama menu/komponen makanan terdeteksi AI
    total_mass_g REAL NOT NULL, -- Hasil estimasi massa (gram)
    calories_kcal REAL NOT NULL, -- Hasil estimasi kalori (kcal)
    protein_g REAL DEFAULT 0.0, -- Hasil estimasi protein (gram)
    carbs_g REAL DEFAULT 0.0, -- Hasil estimasi karbohidrat (gram)
    fat_g REAL DEFAULT 0.0, -- Hasil estimasi lemak (gram)
    inference_mode TEXT CHECK (inference_mode IN ('online_2d', 'offline_2d', 'offline_depth')), -- Melacak jenis eksekusi model
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Indeks untuk mempercepat query riwayat gizi berdasarkan user dan tanggal
CREATE INDEX idx_food_logs_user_date ON public.food_logs (user_id, created_at DESC);

```

### C. Tabel `weight_logs`

Tabel pendukung untuk memfasilitasi pengguna (terutama *fitness/bodybuilding enthusiasts*) dalam melacak progres berat badan mereka secara berkala.

```sql
CREATE TABLE public.weight_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    weight_kg REAL NOT NULL, -- Berat badan pengguna (kg)
    logged_at DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Memastikan user hanya menginput maksimal 1x catatan berat badan per hari
CREATE UNIQUE INDEX idx_unique_user_weight_per_day ON public.weight_logs (user_id, logged_at);

```

---

## 3. Row Level Security (RLS) & Triggers

Supabase secara default mewajibkan penggunaan *Row Level Security* (RLS) agar user tidak bisa mengintip atau memodifikasi data milik user lain.

### A. Aktifkan RLS pada Semua Tabel

```sql
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;

```

### B. Polisi Keamanan (Security Policies)

Izinkan pengguna untuk melakukan operasi CRUD hanya pada baris data yang memiliki `user_id` cocok dengan ID autentikasi mereka (`auth.uid()`).

```sql
-- Policies untuk tabel profiles
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Policies untuk tabel food_logs
CREATE POLICY "Users can manage own food logs" ON public.food_logs 
    FOR ALL USING (auth.uid() = user_id);

-- Policies untuk tabel weight_logs
CREATE POLICY "Users can manage own weight logs" ON public.weight_logs 
    FOR ALL USING (auth.uid() = user_id);

```

### C. Otomatisasi Pembuatan Profil Baru (Trigger)

Fungsi SQL ini akan otomatis berjalan untuk membuat baris baru di tabel `public.profiles` sesaat setelah pengguna berhasil melakukan *register* akun baru di Supabase Auth.

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, fitness_goal)
    VALUES (
        new.id, 
        COALESCE(new.raw_user_meta_data-»'full_name', 'CANVAS User'), 
        'maintenance'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Pasang trigger ke auth.users
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTION FUNCTION public.handle_new_user();

