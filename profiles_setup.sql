-- GENTLEMEN'S DASHBOARD - USER PROFILES SETUP
-- Dit script regelt de tabel voor gebruikersnamen, namen en profielfoto's.

-- 1. Maak de 'profiles' tabel aan
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  updated_at timestamp with time zone default now(),
  username text unique,
  full_name text,
  avatar_url text,

  constraint username_length check (char_length(username) >= 3)
);

-- 2. Zet Row Level Security (RLS) aan
alter table profiles enable row level security;

-- 3. Policies voor beveiliging
-- Iedereen mag profielen bekijken (nodig voor weergave in de app)
create policy "Public profiles are viewable by everyone." on profiles
  for select using (true);

-- Alleen de gebruiker zelf mag zijn eigen profiel aanmaken of aanpassen
create policy "Users can insert their own profile." on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);

-- 4. Functie en Trigger om automatisch een profiel aan te maken bij een nieuwe gebruiker
-- Zo hoef je nooit handmatig een rij in 'profiles' aan te maken.
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$ language plpgsql security definer;

-- Zorg dat de trigger alleen wordt aangemaakt als hij nog niet bestaat
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
