-- Migration: 20250510185336_create_flashcards_table.sql
-- Description: Tworzenie tabeli flashcards

-- Create flashcards table
create table public.flashcards (
  id uuid primary key default uuid_generate_v4(),
  collection_id uuid not null references public.collections(id) on delete cascade,
  front_content text not null check (length(front_content) <= 300),
  back_content text not null check (length(back_content) <= 500),
  difficulty_level integer default 0 check (difficulty_level between 0 and 5),
  is_ai_generated boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Create indexes for better query performance
create index idx_flashcards_collection_id on public.flashcards(collection_id);
create index idx_flashcards_created_at on public.flashcards(created_at);
create index idx_flashcards_is_ai_generated on public.flashcards(is_ai_generated);

-- Enable RLS on flashcards table
alter table public.flashcards enable row level security;

-- Create RLS policies for flashcards table
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

-- Create trigger for updated_at column
create trigger set_flashcards_updated_at
  before update on public.flashcards
  for each row
  execute procedure public.handle_updated_at(); 