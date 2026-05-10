-- GENTLEMEN'S DASHBOARD - PROJECTS TABLE SETUP
-- Dit script maakt de uitgebreide projecten tabel aan.

-- 1. Verwijder de oude tabel (indien aanwezig) om de nieuwe structuur toe te passen
drop table if exists projects;

-- 2. Maak de nieuwe 'projects' tabel aan
create table projects (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  title text not null,
  client text,
  start_date date,
  end_date date,
  files_url text,
  category text default 'General',
  progress integer default 0,
  user_id uuid references auth.users(id) on delete cascade
);

-- 3. Zet Row Level Security (RLS) aan
alter table projects enable row level security;

-- 4. Policies voor beveiliging
-- Iedereen in de societeit (ingelogde gebruikers) mag alle projecten zien
create policy "Authenticated users can view all projects." on projects
  for select using (auth.role() = 'authenticated');

-- Alleen ingelogde gebruikers mogen projecten toevoegen
create policy "Authenticated users can insert projects." on projects
  for insert with check (auth.role() = 'authenticated');

-- Projecten mogen worden aangepast door ingelogde gebruikers
create policy "Authenticated users can update projects." on projects
  for update using (auth.role() = 'authenticated');
