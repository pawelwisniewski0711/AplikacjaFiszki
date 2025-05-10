-- Migration: 20250510185334_create_users_table.sql
-- Description: Tworzenie tabeli users

-- Create users table
-- Note: Authentication is handled by Supabase auth.users
-- This table extends Supabase auth.users with additional user information
create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Enable RLS on users table
alter table public.users enable row level security;

-- Create RLS policies for users table
create policy users_select_policy on public.users
  for select using (auth.uid() = id);
  
create policy users_insert_policy on public.users
  for insert with check (auth.uid() = id);
  
create policy users_update_policy on public.users
  for update using (auth.uid() = id);
  
create policy users_delete_policy on public.users
  for delete using (auth.uid() = id);

-- Create function to update updated_at timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql security definer;

-- Create trigger for updated_at column
create trigger set_users_updated_at
  before update on public.users
  for each row
  execute procedure public.handle_updated_at(); 