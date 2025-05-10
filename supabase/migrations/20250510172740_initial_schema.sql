-- Migration: 20250510172740_initial_schema.sql
-- Description: Initial database schema for AplikacjaFiszki
-- This migration creates all tables, indexes, and RLS policies required for the application

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create users table
-- Note: This table extends Supabase auth.users with additional user information
create table public.users (
  id uuid primary key default uuid_generate_v4(),
  username text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Enable RLS on users table
alter table public.users enable row level security;

-- Create collections table
create table public.collections (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Enable RLS on collections table
alter table public.collections enable row level security;

-- Create flashcards table
create table public.flashcards (
  id uuid primary key default uuid_generate_v4(),
  collection_id uuid not null references public.collections(id) on delete cascade,
  front_content text not null,
  back_content text not null,
  difficulty_level integer default 0 check (difficulty_level between 0 and 5),
  is_ai_generated boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Enable RLS on flashcards table
alter table public.flashcards enable row level security;

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

-- Enable RLS on learning_progress table
alter table public.learning_progress enable row level security;

-- Create learning_sessions table
create table public.learning_sessions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.users(id) on delete cascade,
  start_time timestamptz not null default now(),
  end_time timestamptz,
  cards_reviewed integer not null default 0,
  created_at timestamptz not null default now()
);

-- Enable RLS on learning_sessions table
alter table public.learning_sessions enable row level security;

-- Create session_flashcards table
create table public.session_flashcards (
  id uuid primary key default uuid_generate_v4(),
  session_id uuid not null references public.learning_sessions(id) on delete cascade,
  flashcard_id uuid not null references public.flashcards(id) on delete cascade,
  user_response integer not null check (user_response between 0 and 5),
  response_time_ms integer,
  created_at timestamptz not null default now()
);

-- Enable RLS on session_flashcards table
alter table public.session_flashcards enable row level security;

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

-- Enable RLS on ai_generation_stats table
alter table public.ai_generation_stats enable row level security;

-- Create indexes for better query performance

-- Indexes for collections table
create index idx_collections_user_id on public.collections(user_id);

-- Indexes for flashcards table
create index idx_flashcards_collection_id on public.flashcards(collection_id);
create index idx_flashcards_created_at on public.flashcards(created_at);
create index idx_flashcards_is_ai_generated on public.flashcards(is_ai_generated);

-- Indexes for learning_progress table
create index idx_learning_progress_flashcard_id on public.learning_progress(flashcard_id);
create index idx_learning_progress_user_id on public.learning_progress(user_id);
create index idx_learning_progress_next_review_date on public.learning_progress(next_review_date);
create unique index idx_learning_progress_user_flashcard on public.learning_progress(user_id, flashcard_id);

-- Indexes for learning_sessions table
create index idx_learning_sessions_user_id on public.learning_sessions(user_id);
create index idx_learning_sessions_start_time on public.learning_sessions(start_time);

-- Indexes for session_flashcards table
create index idx_session_flashcards_session_id on public.session_flashcards(session_id);
create index idx_session_flashcards_flashcard_id on public.session_flashcards(flashcard_id);

-- Indexes for ai_generation_stats table
create index idx_ai_generation_stats_user_id on public.ai_generation_stats(user_id);
create index idx_ai_generation_stats_period_start on public.ai_generation_stats(period_start);

-- Create RLS policies for each table

-- RLS policies for users table
-- Only allow users to see and modify their own profile
create policy users_select_policy on public.users
  for select using (auth.uid() = id);

create policy users_insert_policy on public.users
  for insert with check (auth.uid() = id);

create policy users_update_policy on public.users
  for update using (auth.uid() = id);

create policy users_delete_policy on public.users
  for delete using (auth.uid() = id);

-- RLS policies for collections table
-- Only allow users to see and modify their own collections
create policy collections_select_policy on public.collections
  for select using (auth.uid() = user_id);

create policy collections_insert_policy on public.collections
  for insert with check (auth.uid() = user_id);

create policy collections_update_policy on public.collections
  for update using (auth.uid() = user_id);

create policy collections_delete_policy on public.collections
  for delete using (auth.uid() = user_id);

-- RLS policies for flashcards table
-- Only allow users to see and modify flashcards in their collections
create policy flashcards_select_policy on public.flashcards
  for select using (
    exists (
      select 1 from public.collections
      where collections.id = flashcards.collection_id
      and collections.user_id = auth.uid()
    )
  );

create policy flashcards_insert_policy on public.flashcards
  for insert with check (
    exists (
      select 1 from public.collections
      where collections.id = flashcards.collection_id
      and collections.user_id = auth.uid()
    )
  );

create policy flashcards_update_policy on public.flashcards
  for update using (
    exists (
      select 1 from public.collections
      where collections.id = flashcards.collection_id
      and collections.user_id = auth.uid()
    )
  );

create policy flashcards_delete_policy on public.flashcards
  for delete using (
    exists (
      select 1 from public.collections
      where collections.id = flashcards.collection_id
      and collections.user_id = auth.uid()
    )
  );

-- RLS policies for learning_progress table
-- Only allow users to see and modify their own learning progress
create policy learning_progress_select_policy on public.learning_progress
  for select using (auth.uid() = user_id);

create policy learning_progress_insert_policy on public.learning_progress
  for insert with check (auth.uid() = user_id);

create policy learning_progress_update_policy on public.learning_progress
  for update using (auth.uid() = user_id);

create policy learning_progress_delete_policy on public.learning_progress
  for delete using (auth.uid() = user_id);

-- RLS policies for learning_sessions table
-- Only allow users to see and modify their own learning sessions
create policy learning_sessions_select_policy on public.learning_sessions
  for select using (auth.uid() = user_id);

create policy learning_sessions_insert_policy on public.learning_sessions
  for insert with check (auth.uid() = user_id);

create policy learning_sessions_update_policy on public.learning_sessions
  for update using (auth.uid() = user_id);

create policy learning_sessions_delete_policy on public.learning_sessions
  for delete using (auth.uid() = user_id);

-- RLS policies for session_flashcards table
-- Only allow users to see and modify flashcards in their sessions
create policy session_flashcards_select_policy on public.session_flashcards
  for select using (
    exists (
      select 1 from public.learning_sessions
      where learning_sessions.id = session_flashcards.session_id
      and learning_sessions.user_id = auth.uid()
    )
  );

create policy session_flashcards_insert_policy on public.session_flashcards
  for insert with check (
    exists (
      select 1 from public.learning_sessions
      where learning_sessions.id = session_flashcards.session_id
      and learning_sessions.user_id = auth.uid()
    )
  );

create policy session_flashcards_update_policy on public.session_flashcards
  for update using (
    exists (
      select 1 from public.learning_sessions
      where learning_sessions.id = session_flashcards.session_id
      and learning_sessions.user_id = auth.uid()
    )
  );

create policy session_flashcards_delete_policy on public.session_flashcards
  for delete using (
    exists (
      select 1 from public.learning_sessions
      where learning_sessions.id = session_flashcards.session_id
      and learning_sessions.user_id = auth.uid()
    )
  );

-- RLS policies for ai_generation_stats table
-- Only allow users to see and modify their own stats
create policy ai_generation_stats_select_policy on public.ai_generation_stats
  for select using (auth.uid() = user_id);

create policy ai_generation_stats_insert_policy on public.ai_generation_stats
  for insert with check (auth.uid() = user_id);

create policy ai_generation_stats_update_policy on public.ai_generation_stats
  for update using (auth.uid() = user_id);

create policy ai_generation_stats_delete_policy on public.ai_generation_stats
  for delete using (auth.uid() = user_id);

-- Create function to update updated_at timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql security definer;

-- Create triggers to automatically update updated_at columns
create trigger set_users_updated_at
  before update on public.users
  for each row
  execute procedure public.handle_updated_at();

create trigger set_collections_updated_at
  before update on public.collections
  for each row
  execute procedure public.handle_updated_at();

create trigger set_flashcards_updated_at
  before update on public.flashcards
  for each row
  execute procedure public.handle_updated_at();

create trigger set_learning_progress_updated_at
  before update on public.learning_progress
  for each row
  execute procedure public.handle_updated_at();

create trigger set_ai_generation_stats_updated_at
  before update on public.ai_generation_stats
  for each row
  execute procedure public.handle_updated_at(); 