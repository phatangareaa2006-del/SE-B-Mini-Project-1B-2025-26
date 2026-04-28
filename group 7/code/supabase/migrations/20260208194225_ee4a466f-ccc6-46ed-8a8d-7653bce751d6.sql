-- Create storage bucket for profile uploads
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-uploads', 'profile-uploads', true);

-- Policy: Anyone can view profile uploads
CREATE POLICY "Profile uploads are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile-uploads');

-- Policy: Users can upload their own files
CREATE POLICY "Users can upload their own profile files"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profile-uploads' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy: Users can update their own files
CREATE POLICY "Users can update their own profile files"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'profile-uploads' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy: Users can delete their own files
CREATE POLICY "Users can delete their own profile files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profile-uploads' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);