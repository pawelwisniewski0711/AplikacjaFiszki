-- Migration: 20250510185335_create_collections_table.sql
-- Description: Tworzenie tabeli collections

-- Create collections table
create table public.collections (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Create index on user_id for better query performance
create index idx_collections_user_id on public.collections(user_id);

-- Enable RLS on collections table
alter table public.collections enable row level security;

-- Create RLS policies for collections table
create policy collections_select_policy on public.collections
  for select using (auth.uid() = user_id);
  
create policy collections_insert_policy on public.collections
  for insert with check (auth.uid() = user_id);
  
create policy collections_update_policy on public.collections
  for update using (auth.uid() = user_id);
  
create policy collections_delete_policy on public.collections
  for delete using (auth.uid() = user_id);

-- Create trigger for updated_at column
create trigger set_collections_updated_at
  before update on public.collections
  for each row
  execute procedure public.handle_updated_at(); 