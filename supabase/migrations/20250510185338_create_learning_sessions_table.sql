-- Migration: 20250510185338_create_learning_sessions_table.sql
-- Description: Tworzenie tabeli learning_sessions

-- Create learning_sessions table
create table public.learning_sessions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.users(id) on delete cascade,
  start_time timestamptz not null default now(),
  end_time timestamptz,
  cards_reviewed integer not null default 0,
  created_at timestamptz not null default now()
);

-- Create indexes for better query performance
create index idx_learning_sessions_user_id on public.learning_sessions(user_id);
create index idx_learning_sessions_start_time on public.learning_sessions(start_time);

-- Enable RLS on learning_sessions table
alter table public.learning_sessions enable row level security;

-- Create RLS policies for learning_sessions table
create policy learning_sessions_select_policy on public.learning_sessions
  for select using (auth.uid() = user_id);
  
create policy learning_sessions_insert_policy on public.learning_sessions
  for insert with check (auth.uid() = user_id);
  
create policy learning_sessions_update_policy on public.learning_sessions
  for update using (auth.uid() = user_id);
  
create policy learning_sessions_delete_policy on public.learning_sessions
  for delete using (auth.uid() = user_id); 