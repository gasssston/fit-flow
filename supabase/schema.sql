-- FitFlow — esquema Supabase (idempotente — seguro de re-ejecutar)

-- =============================================
-- PROFILES
-- =============================================
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    username text unique not null,
    full_name text not null default '',
    gender text,
    birthdate date,
    email text,
    avatar_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "own profile read" on public.profiles;
create policy "own profile read" on public.profiles
    for select using (auth.uid() = id);

drop policy if exists "own profile insert" on public.profiles;
create policy "own profile insert" on public.profiles
    for insert with check (auth.uid() = id);

drop policy if exists "own profile update" on public.profiles;
create policy "own profile update" on public.profiles
    for update using (auth.uid() = id);

-- Auto-crear perfil al registrarse
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (id, email, full_name)
    values (
        new.id,
        new.email,
        coalesce(new.raw_user_meta_data->>'full_name', '')
    );
    return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- =============================================
-- STORAGE (avatars)
-- =============================================
-- Crear bucket "avatars" en Dashboard > Storage > New bucket
--   Public: true, Limit: 5 MB, MIME: image/jpeg, image/png, image/webp

drop policy if exists "Avatar upload own" on storage.objects;
create policy "Avatar upload own" on storage.objects
    for insert to authenticated
    with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = 'avatars');

drop policy if exists "Avatar read public" on storage.objects;
create policy "Avatar read public" on storage.objects
    for select to public
    using (bucket_id = 'avatars');

drop policy if exists "Avatar update own" on storage.objects;
create policy "Avatar update own" on storage.objects
    for update to authenticated
    using (bucket_id = 'avatars' and (storage.foldername(name))[1] = 'avatars');

-- =============================================
-- WORKOUT LOGS
-- =============================================
create table if not exists public.ab_workout_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) not null,
    exercises text[] not null,
    work_seconds int not null,
    rest_seconds int not null,
    rounds int not null,
    completed_at timestamptz not null default now()
);

create table if not exists public.running_workout_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) not null,
    title text not null,
    raw_notation text not null,
    completed_at timestamptz not null default now()
);

create table if not exists public.custom_running_notations (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) not null,
    title text not null,
    notation text not null,
    created_at timestamptz not null default now()
);

-- =============================================
-- ABS PLANNINGS (saved circuits)
-- =============================================
create table if not exists public.abs_plannings (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) not null,
    name text not null,
    exercise_ids text[] not null,
    work_seconds int not null default 20,
    rest_seconds int not null default 10,
    rounds int not null default 1,
    created_at timestamptz not null default now()
);

alter table public.ab_workout_logs enable row level security;
alter table public.running_workout_logs enable row level security;
alter table public.custom_running_notations enable row level security;
alter table public.abs_plannings enable row level security;

drop policy if exists "own rows only" on public.ab_workout_logs;
create policy "own rows only" on public.ab_workout_logs
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own rows only" on public.running_workout_logs;
create policy "own rows only" on public.running_workout_logs
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own rows only" on public.custom_running_notations;
create policy "own rows only" on public.custom_running_notations
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own rows only" on public.abs_plannings;
create policy "own rows only" on public.abs_plannings
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
