CREATE TABLE IF NOT EXISTS time_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    notes TEXT,
    duration_minutes INTEGER,        -- null when timer is still running
    started_at TIMESTAMP WITH TIME ZONE,  -- set when using the timer
    ended_at TIMESTAMP WITH TIME ZONE,    -- set when timer stops
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE time_entries ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read every entry (overview)
CREATE POLICY "Authenticated users can read time entries"
    ON time_entries FOR SELECT
    USING (auth.role() = 'authenticated');

-- Users can insert their own entries
CREATE POLICY "Users can insert their own time entries"
    ON time_entries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own entries (needed for stopping the timer)
CREATE POLICY "Users can update their own time entries"
    ON time_entries FOR UPDATE
    USING (auth.uid() = user_id);

-- Users can delete their own entries
CREATE POLICY "Users can delete their own time entries"
    ON time_entries FOR DELETE
    USING (auth.uid() = user_id);
