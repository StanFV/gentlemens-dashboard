
-- Create feature_requests table
CREATE TABLE IF NOT EXISTS public.feature_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in-progress', 'completed', 'planned')),
    upvotes INTEGER DEFAULT 0,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Enable RLS
ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Feature requests are viewable by everyone" 
ON public.feature_requests FOR SELECT 
USING (true);

CREATE POLICY "Users can insert their own feature requests" 
ON public.feature_requests FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own feature requests" 
ON public.feature_requests FOR UPDATE 
USING (auth.uid() = user_id);

-- Optional: Function to handle upvotes (preventing double voting would require a separate table, but this is a simple start)
CREATE OR REPLACE FUNCTION upvote_feature_request(request_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE public.feature_requests
    SET upvotes = upvotes + 1
    WHERE id = request_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
