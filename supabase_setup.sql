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

-- 8. Maak de 'profiles' tabel aan
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  updated_at timestamp with time zone,
  username text unique,
  avatar_url text,
  full_name text,

  constraint username_length check (char_length(username) >= 3)
);

-- Zet RLS aan voor profiles
alter table profiles enable row level security;

create policy "Public profiles are viewable by everyone." on profiles
  for select using (true);

create policy "Users can insert their own profile." on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);

-- 9. Trigger voor automatische profiel aanmaak bij nieuwe user
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 10. Storage setup (moet handmatig in dashboard of via API, maar hier zijn de policies)
-- Maak handmatig een bucket genaamd 'avatars' aan in Supabase Storage en zet deze op 'Public'
-- Of gebruik deze policies als de bucket al bestaat:
/*
create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_id = 'avatars');

create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_id = 'avatars' AND auth.uid() = owner);
*/
