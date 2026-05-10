-- GENTLEMEN'S DASHBOARD - FEATURE REQUESTS SETUP (FINAL VERSION)
-- Dit script configureert de tabel voor feature requests met volledige beheerfunctionaliteit.

-- 1. Tabel aanmaken of bijwerken
CREATE TABLE IF NOT EXISTS public.feature_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'planned' CHECK (status IN ('planned', 'in-progress', 'completed')),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    assigned_to UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- 2. Update bestaande 'pending' records naar 'planned'
UPDATE public.feature_requests SET status = 'planned' WHERE status = 'pending';

-- 2. Foreign Key relatie optimaliseren
ALTER TABLE public.feature_requests 
  DROP CONSTRAINT IF EXISTS feature_requests_assigned_to_fkey,
  ADD CONSTRAINT feature_requests_assigned_to_fkey 
  FOREIGN KEY (assigned_to) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- 3. Row Level Security (RLS) configureren
ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;

-- 4. Policies voor beheer (Select, Insert, Update, Delete)
DROP POLICY IF EXISTS "Feature requests are viewable by everyone" ON public.feature_requests;
CREATE POLICY "Feature requests are viewable by everyone" 
ON public.feature_requests FOR SELECT 
USING (true);

DROP POLICY IF EXISTS "Users can insert their own feature requests" ON public.feature_requests;
CREATE POLICY "Users can insert their own feature requests" 
ON public.feature_requests FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can update feature requests" ON public.feature_requests;
CREATE POLICY "Users can update feature requests" 
ON public.feature_requests FOR UPDATE 
USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can delete feature requests" ON public.feature_requests;
CREATE POLICY "Users can delete feature requests" 
ON public.feature_requests FOR DELETE 
USING (auth.role() = 'authenticated');
