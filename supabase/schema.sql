-- FitFlow — esquema Supabase de partida (ajústalo a medida que crezca la app)

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

alter table public.ab_workout_logs enable row level security;
alter table public.running_workout_logs enable row level security;
alter table public.custom_running_notations enable row level security;

create policy "own rows only" on public.ab_workout_logs
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows only" on public.running_workout_logs
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows only" on public.custom_running_notations
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
