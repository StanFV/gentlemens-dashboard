
-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id), -- The user who triggered the notification
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    link TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notification Reads (to track who has seen what)
CREATE TABLE IF NOT EXISTS notification_reads (
    notification_id UUID REFERENCES notifications(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (notification_id, user_id)
);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_reads ENABLE ROW LEVEL SECURITY;

-- Policies for notifications
CREATE POLICY "Everyone can view notifications" ON notifications
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert notifications" ON notifications
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policies for notification_reads
CREATE POLICY "Users can view their own reads" ON notification_reads
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can mark notifications as read" ON notification_reads
    FOR INSERT WITH CHECK (auth.uid() = user_id);
