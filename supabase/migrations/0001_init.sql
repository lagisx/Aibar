-- AI Hairstyle MVP: initial schema
-- Run via `supabase db push` or paste into the Supabase SQL editor.

create extension if not exists "pgcrypto";

-- Users (extends Supabase Auth's built-in auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  display_name text,
  created_at timestamptz not null default now()
);

-- Subscriptions (MVP mock, no real billing yet — see section 7 of the plan)
create table if not exists public.subscriptions (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  tier text not null default 'free' check (tier in ('free', 'pro', 'max')),
  requests_used_this_period int not null default 0,
  period_reset_at timestamptz not null default (now() + interval '30 days'),
  status text not null default 'active' check (status in ('active', 'canceled', 'expired')),
  updated_at timestamptz not null default now()
);

-- Chat messages (both user prompts and assistant replies)
create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  role text not null check (role in ('user', 'assistant')),
  type text not null check (type in ('text', 'image_prompt', 'image_result')),
  content text,
  image_url text,
  created_at timestamptz not null default now()
);

-- Generation requests (one per user photo + prompt sent to the AI provider)
create table if not exists public.generation_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  message_id uuid references public.chat_messages (id) on delete set null,
  prompt_text text not null,
  source_photo_url text not null,
  result_urls text[],
  status text not null default 'pending' check (status in ('pending', 'done', 'failed')),
  created_at timestamptz not null default now()
);

create index if not exists chat_messages_user_id_created_at_idx
  on public.chat_messages (user_id, created_at);

create index if not exists generation_requests_user_id_created_at_idx
  on public.generation_requests (user_id, created_at);

-- Auto-create a profile + free subscription row when a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;

  insert into public.subscriptions (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Row Level Security: every user only sees/writes their own rows.
alter table public.profiles enable row level security;
alter table public.subscriptions enable row level security;
alter table public.chat_messages enable row level security;
alter table public.generation_requests enable row level security;

drop policy if exists "own profile" on public.profiles;
create policy "own profile" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "own subscription" on public.subscriptions;
create policy "own subscription" on public.subscriptions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own messages" on public.chat_messages;
create policy "own messages" on public.chat_messages
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own generation requests" on public.generation_requests;
create policy "own generation requests" on public.generation_requests
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Storage bucket for user-uploaded source photos.
insert into storage.buckets (id, name, public)
values ('source-photos', 'source-photos', true)
on conflict (id) do nothing;

drop policy if exists "own source photos read" on storage.objects;
create policy "own source photos read" on storage.objects
  for select using (
    bucket_id = 'source-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "own source photos write" on storage.objects;
create policy "own source photos write" on storage.objects
  for insert with check (
    bucket_id = 'source-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "own source photos delete" on storage.objects;
create policy "own source photos delete" on storage.objects
  for delete using (
    bucket_id = 'source-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
