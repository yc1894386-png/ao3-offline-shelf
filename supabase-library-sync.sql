create table if not exists public.library_states (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.library_states enable row level security;

drop policy if exists "Users can read own library" on public.library_states;
create policy "Users can read own library"
on public.library_states
for select
using (auth.uid() = user_id);

drop policy if exists "Users can insert own library" on public.library_states;
create policy "Users can insert own library"
on public.library_states
for insert
with check (auth.uid() = user_id);

create table if not exists public.shared_library_states (
  sync_code text primary key,
  state jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.shared_library_states enable row level security;

drop policy if exists "Anyone with code can read shared library" on public.shared_library_states;
create policy "Anyone with code can read shared library"
on public.shared_library_states
for select
using (true);

drop policy if exists "Anyone with code can insert shared library" on public.shared_library_states;
create policy "Anyone with code can insert shared library"
on public.shared_library_states
for insert
with check (sync_code ~ '^[A-Z0-9-]{8,32}$');

drop policy if exists "Anyone with code can update shared library" on public.shared_library_states;
create policy "Anyone with code can update shared library"
on public.shared_library_states
for update
using (true)
with check (sync_code ~ '^[A-Z0-9-]{8,32}$');

drop policy if exists "Users can update own library" on public.library_states;
create policy "Users can update own library"
on public.library_states
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
