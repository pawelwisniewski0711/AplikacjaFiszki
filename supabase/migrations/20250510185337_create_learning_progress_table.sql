-- Migration: 20250510185337_create_learning_progress_table.sql
-- Description: Tworzenie tabeli learning_progress

-- Create learning_progress table
create table public.learning_progress (
  id uuid primary key default uuid_generate_v4(),
  flashcard_id uuid not null references public.flashcards(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  ease_factor float not null default 2.5 check (ease_factor >= 1.3),
  interval integer not null default 0,
  repetitions integer not null default 0,
  next_review_date timestamptz,
  last_review_date timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Create indexes for better query performance
create index idx_learning_progress_flashcard_id on public.learning_progress(flashcard_id);
create index idx_learning_progress_user_id on public.learning_progress(user_id);
create index idx_learning_progress_next_review_date on public.learning_progress(next_review_date);
create unique index idx_learning_progress_user_flashcard on public.learning_progress(user_id, flashcard_id);

-- Enable RLS on learning_progress table
alter table public.learning_progress enable row level security;

-- Create RLS policies for learning_progress table
create policy learning_progress_select_policy on public.learning_progress
  for select using (auth.uid() = user_id);
  
create policy learning_progress_insert_policy on public.learning_progress
  for insert with check (auth.uid() = user_id);
  
create policy learning_progress_update_policy on public.learning_progress
  for update using (auth.uid() = user_id);
  
create policy learning_progress_delete_policy on public.learning_progress
  for delete using (auth.uid() = user_id);

-- Create trigger for updated_at column
create trigger set_learning_progress_updated_at
  before update on public.learning_progress
  for each row
  execute procedure public.handle_updated_at(); 