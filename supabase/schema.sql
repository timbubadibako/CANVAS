-- 0. Tipe ENUM untuk Preferensi
CREATE TYPE public.primary_goal_enum AS ENUM ('Weight Loss', 'Build Muscle', 'Stay Healthy');
CREATE TYPE public.dietary_palette_enum AS ENUM ('Everything', 'Vegetarian', 'Keto / Low Carb');
CREATE TYPE public.activity_level_enum AS ENUM ('Sedentary', 'Moderate', 'Active');
CREATE TYPE public.motivation_enum AS ENUM ('Health Recovery', 'Athletic Peak', 'Self Confidence', 'Longevity');
CREATE TYPE public.fitness_strategy_enum AS ENUM ('cutting', 'maintenance', 'bulking');
CREATE TYPE public.gender_enum AS ENUM ('Male', 'Female');

-- 1. Tabel Profiles (Menampung Data Fisik & Onboarding)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    gender public.gender_enum,
    age INT,
    height_cm INT,
    weight_kg REAL,
    primary_goal public.primary_goal_enum,
    dietary_palette public.dietary_palette_enum,
    activity_level public.activity_level_enum,
    motivation public.motivation_enum,
    fitness_strategy public.fitness_strategy_enum,
    daily_calorie_target INT DEFAULT 2000,
    daily_protein_target REAL,
    daily_carbs_target REAL,
    daily_fat_target REAL,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Tabel Food Logs (Riwayat Makan & Hasil AI)
CREATE TABLE public.food_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    food_name TEXT NOT NULL,
    image_url TEXT, -- URL Foto Makanan (Studio Style)
    total_mass_g REAL NOT NULL,
    calories_kcal REAL NOT NULL,
    protein_g REAL DEFAULT 0.0,
    carbs_g REAL DEFAULT 0.0,
    fat_g REAL DEFAULT 0.0,
    inference_mode TEXT CHECK (inference_mode IN ('online_2d', 'offline_2d', 'offline_depth')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Tabel Weight Logs (Pelacakan Progres Berat Badan)
CREATE TABLE public.weight_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    weight_kg REAL NOT NULL,
    logged_at DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Indeks & Keamanan (RLS)
CREATE INDEX idx_food_logs_user_date ON public.food_logs (user_id, created_at DESC);
CREATE UNIQUE INDEX idx_unique_user_weight_per_day ON public.weight_logs (user_id, logged_at);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can manage own profile" ON public.profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "Users can manage own food logs" ON public.food_logs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own weight logs" ON public.weight_logs FOR ALL USING (auth.uid() = user_id);

-- 5. Trigger Otomatis untuk User Baru
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, fitness_strategy)
    VALUES (
        new.id, 
        COALESCE(new.raw_user_meta_data->>'full_name', 'Canvas Artist'), 
        'maintenance'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
