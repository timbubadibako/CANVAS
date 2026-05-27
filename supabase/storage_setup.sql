-- 1. Buat Bucket 'avatars' (Jika belum ada)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Kebijakan Akses: Izinkan semua orang melihat foto (Public View)
CREATE POLICY "Public View Avatars" 
ON storage.objects FOR SELECT 
TO public 
USING (bucket_id = 'avatars');

-- 3. Kebijakan Akses: Izinkan user mengunggah ke folder miliknya sendiri
CREATE POLICY "Users can upload their own avatar" 
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (
  bucket_id = 'avatars' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);

-- 4. Kebijakan Akses: Izinkan user memperbarui foto miliknya sendiri
CREATE POLICY "Users can update their own avatar" 
ON storage.objects FOR UPDATE 
TO authenticated 
USING (
  bucket_id = 'avatars' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);

-- 5. Kebijakan Akses: Izinkan user menghapus foto miliknya sendiri
CREATE POLICY "Users can delete their own avatar" 
ON storage.objects FOR DELETE 
TO authenticated 
USING (
  bucket_id = 'avatars' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);
