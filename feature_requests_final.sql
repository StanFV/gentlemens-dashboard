-- GENTLEMEN'S DASHBOARD - FEATURE REQUESTS SETUP
-- Dit script configureert de tabel voor feature requests met bewerk- en toewijzingsrechten.

-- 1. Tabel aanmaken of bijwerken
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

-- 2. Verwijder de upvotes kolom indien deze nog bestaat van een vorige versie
ALTER TABLE public.feature_requests DROP COLUMN IF EXISTS upvotes;

-- 3. Zorg voor een harde Foreign Key relatie voor de join met profiles
ALTER TABLE public.feature_requests 
  DROP CONSTRAINT IF EXISTS feature_requests_assigned_to_fkey,
  ADD CONSTRAINT feature_requests_assigned_to_fkey 
  FOREIGN KEY (assigned_to) REFERENCES public.profiles(id);

-- 4. Meta-informatie voor Supabase API relatie-detectie
COMMENT ON COLUMN public.feature_requests.assigned_to IS '{"foreignKey": "public.profiles.id"}';

-- 5. Beveiliging (Row Level Security) inschakelen
ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;

-- 6. Policies voor toegang en beheer
-- Iedereen kan de lijst zien
DROP POLICY IF EXISTS "Feature requests are viewable by everyone" ON public.feature_requests;
CREATE POLICY "Feature requests are viewable by everyone" 
ON public.feature_requests FOR SELECT 
USING (true);

-- Elke ingelogde gebruiker kan een nieuwe suggestie doen
DROP POLICY IF EXISTS "Users can insert their own feature requests" ON public.feature_requests;
CREATE POLICY "Users can insert their own feature requests" 
ON public.feature_requests FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Elke ingelogde gebruiker mag bewerken (om status aan te passen of iemand toe te wijzen)
DROP POLICY IF EXISTS "Users can update feature requests" ON public.feature_requests;
CREATE POLICY "Users can update feature requests" 
ON public.feature_requests FOR UPDATE 
USING (auth.role() = 'authenticated');
