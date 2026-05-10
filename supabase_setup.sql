-- GENTLEMEN'S DASHBOARD - SUPABASE SETUP SCRIPT
-- Kopieer en plak dit script in de Supabase SQL Editor

-- 1. Verwijder bestaande tabellen (indien aanwezig) om met een schone lei te beginnen
drop table if exists projects;
drop table if exists activities;
drop table if exists stats;

-- 2. Maak de 'projects' tabel aan
create table projects (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  title text not null,
  category text,
  progress integer default 0
);

-- 3. Maak de 'activities' tabel aan
create table activities (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  description text not null,
  icon text
);

-- 4. Maak de 'stats' tabel aan
create table stats (
  id uuid default gen_random_uuid() primary key,
  label text not null,
  value text not null,
  trend text
);

-- 5. Zet Row Level Security (RLS) aan voor alle tabellen
alter table projects enable row level security;
alter table activities enable row level security;
alter table stats enable row level security;

-- 6. Sta iedereen toe om de data te lezen (Read Access)
create policy "Allow public read access on projects" on projects for select using (true);
create policy "Allow public read access on activities" on activities for select using (true);
create policy "Allow public read access on stats" on stats for select using (true);

-- 7. Voeg initiële data toe
insert into stats (label, value, trend) values 
('Active Projects', '3', '+1'),
('Total Members', '48', '+2'),
('Monthly Budget', '€4.2k', '-5%');

insert into projects (title, category, progress) values 
('Sociëteit Website', 'Design', 65),
('Whiskey Inventory', 'Logistics', 100),
('Annual Gala 2026', 'Events', 20);

insert into activities (description, icon) values 
('New member James B. approved', '👤'),
('Vault security v1.2 deployed', '⚙️'),
('Gala planning Phase 1 complete', '📅');
