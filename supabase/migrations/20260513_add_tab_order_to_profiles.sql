-- Add tab_order column to profiles so each user can persist their mobile tab bar order
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS tab_order text[];
