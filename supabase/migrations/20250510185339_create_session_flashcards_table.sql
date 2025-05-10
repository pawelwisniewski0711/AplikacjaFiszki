-- Migration: 20250510185339_create_session_flashcards_table.sql
-- Description: Tworzenie tabeli session_flashcards

-- Create session_flashcards table
create table public.session_flashcards (
  id uuid primary key default uuid_generate_v4(),
  session_id uuid not null references public.learning_sessions(id) on delete cascade,
  flashcard_id uuid not null references public.flashcards(id) on delete cascade,
  user_response integer not null check (user_response between 0 and 5),
  response_time_ms integer,
  created_at timestamptz not null default now()
);

-- Create indexes for better query performance
create index idx_session_flashcards_session_id on public.session_flashcards(session_id);
create index idx_session_flashcards_flashcard_id on public.session_flashcards(flashcard_id);

-- Enable RLS on session_flashcards table
alter table public.session_flashcards enable row level security;

-- Create RLS policies for session_flashcards table
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