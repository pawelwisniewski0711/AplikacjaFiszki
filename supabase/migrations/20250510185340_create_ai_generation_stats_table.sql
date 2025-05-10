-- Migration: 20250510185340_create_ai_generation_stats_table.sql
-- Description: Tworzenie tabeli ai_generation_stats

-- Create ai_generation_stats table
create table public.ai_generation_stats (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.users(id) on delete cascade,
  period_start timestamptz not null,
  period_end timestamptz not null,
  cards_generated integer not null default 0,
  cards_accepted integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Create indexes for better query performance
create index idx_ai_generation_stats_user_id on public.ai_generation_stats(user_id);
create index idx_ai_generation_stats_period_start on public.ai_generation_stats(period_start);

-- Enable RLS on ai_generation_stats table
alter table public.ai_generation_stats enable row level security;

-- Create RLS policies for ai_generation_stats table
create policy ai_generation_stats_select_policy on public.ai_generation_stats
  for select using (auth.uid() = user_id);
  
create policy ai_generation_stats_insert_policy on public.ai_generation_stats
  for insert with check (auth.uid() = user_id);
  
create policy ai_generation_stats_update_policy on public.ai_generation_stats
  for update using (auth.uid() = user_id);
  
create policy ai_generation_stats_delete_policy on public.ai_generation_stats
  for delete using (auth.uid() = user_id);

-- Create trigger for updated_at column
create trigger set_ai_generation_stats_updated_at
  before update on public.ai_generation_stats
  for each row
  execute procedure public.handle_updated_at(); 