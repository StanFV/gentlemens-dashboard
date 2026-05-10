
-- Create feature_requests table
CREATE TABLE IF NOT EXISTS public.feature_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in-progress', 'completed', 'planned')),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    assigned_to UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Ensure Supabase knows about the relationship for joins
COMMENT ON COLUMN public.feature_requests.assigned_to IS '{"foreignKey": "public.profiles.id"}';

-- Enable RLS
ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Feature requests are viewable by everyone" 
ON public.feature_requests FOR SELECT 
USING (true);

CREATE POLICY "Users can insert their own feature requests" 
ON public.feature_requests FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update feature requests" 
ON public.feature_requests FOR UPDATE 
USING (auth.role() = 'authenticated');
