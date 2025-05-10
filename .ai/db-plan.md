# Schemat bazy danych dla AplikacjaFiszki

## 1. Lista tabel

### users
This table is managed by Supabase Auth.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | uuid | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator użytkownika |
| email | text | NOT NULL, UNIQUE | Email użytkownika |
| encrypted_password| varchar | NOT NULL | Hasło użytkownika |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Data utworzenia konta |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Data ostatniej aktualizacji |

*Uwaga: Autentykacja jest obsługiwana przez wbudowany system Supabase auth.users*

### collections
| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | uuid | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator kolekcji |
| user_id | uuid | NOT NULL, REFERENCES users(id) ON DELETE CASCADE | Identyfikator właściciela kolekcji |
| name | text | NOT NULL | Nazwa kolekcji |
| description | text | | Opis kolekcji |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Data utworzenia kolekcji |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Data ostatniej aktualizacji |

### flashcards
| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | uuid | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator fiszki |
| collection_id | uuid | NOT NULL, REFERENCES collections(id) ON DELETE CASCADE | Identyfikator kolekcji |
| front_content | text | NOT NULL, CHECK (length(front_content) <= 300) | Zawartość przedniej strony fiszki (max 300 znaków) |
| back_content | text | NOT NULL, CHECK (length(back_content) <= 500) | Zawartość tylnej strony fiszki (max 500 znaków) |
| difficulty_level | integer | DEFAULT 0, CHECK (difficulty_level BETWEEN 0 AND 5) | Poziom trudności fiszki (0-5) |
| is_ai_generated | boolean | NOT NULL, DEFAULT false | Czy fiszka została wygenerowana przez AI |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Data utworzenia fiszki |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Data ostatniej aktualizacji |

### learning_progress
| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | uuid | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator postępu |
| flashcard_id | uuid | NOT NULL, REFERENCES flashcards(id) ON DELETE CASCADE | Identyfikator fiszki |
| user_id | uuid | NOT NULL, REFERENCES users(id) ON DELETE CASCADE | Identyfikator użytkownika |
| ease_factor | float | NOT NULL, DEFAULT 2.5, CHECK (ease_factor >= 1.3) | Współczynnik łatwości dla algorytmu SM-2 |
| interval | integer | NOT NULL, DEFAULT 0 | Interwał w dniach do następnej powtórki |
| repetitions | integer | NOT NULL, DEFAULT 0 | Liczba powtórzeń |
| next_review_date | timestamptz | | Data następnej powtórki |
| last_review_date | timestamptz | | Data ostatniej powtórki |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Data utworzenia wpisu |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Data ostatniej aktualizacji |

### learning_sessions
| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | uuid | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator sesji |
| user_id | uuid | NOT NULL, REFERENCES users(id) ON DELETE CASCADE | Identyfikator użytkownika |
| start_time | timestamptz | NOT NULL, DEFAULT now() | Czas rozpoczęcia sesji |
| end_time | timestamptz | | Czas zakończenia sesji |
| cards_reviewed | integer | NOT NULL, DEFAULT 0 | Liczba przeglądniętych fiszek |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Data utworzenia wpisu |

### session_flashcards
| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | uuid | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator |
| session_id | uuid | NOT NULL, REFERENCES learning_sessions(id) ON DELETE CASCADE | Identyfikator sesji |
| flashcard_id | uuid | NOT NULL, REFERENCES flashcards(id) ON DELETE CASCADE | Identyfikator fiszki |
| user_response | integer | NOT NULL, CHECK (user_response BETWEEN 0 AND 5) | Odpowiedź użytkownika (0-5) |
| response_time_ms | integer | | Czas odpowiedzi w milisekundach |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Data utworzenia wpisu |

### ai_generation_stats
| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | uuid | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator |
| user_id | uuid | NOT NULL, REFERENCES users(id) ON DELETE CASCADE | Identyfikator użytkownika |
| period_start | timestamptz | NOT NULL | Początek okresu |
| period_end | timestamptz | NOT NULL | Koniec okresu |
| cards_generated | integer | NOT NULL, DEFAULT 0 | Liczba wygenerowanych fiszek |
| cards_accepted | integer | NOT NULL, DEFAULT 0 | Liczba zaakceptowanych fiszek |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Data utworzenia wpisu |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Data ostatniej aktualizacji |

### ai_generation_error_logs
| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | uuid | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator logu błędu |
| user_id | uuid | NOT NULL, REFERENCES users(id) ON DELETE CASCADE | Identyfikator użytkownika |
| collection_id | uuid | REFERENCES collections(id) ON DELETE SET NULL | Identyfikator kolekcji (opcjonalny) |
| error_code | text | | Kod błędu |
| error_message | text | NOT NULL | Treść komunikatu błędu |
| request_payload | jsonb | | Dane wysłane do API (bez wrażliwych danych) |
| source_text_excerpt | text | | Fragment tekstu źródłowego (do 200 znaków) |
| ai_model | text | | Nazwa modelu AI, który był używany |
| occurred_at | timestamptz | NOT NULL, DEFAULT now() | Data i czas wystąpienia błędu |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Data utworzenia wpisu |

## 2. Relacje między tabelami

1. **users** 1:N **collections**
   - Jeden użytkownik może mieć wiele kolekcji
   - Kolekcja należy do jednego użytkownika

2. **collections** 1:N **flashcards**
   - Jedna kolekcja może zawierać wiele fiszek
   - Fiszka należy do jednej kolekcji

3. **users** 1:N **learning_sessions**
   - Jeden użytkownik może mieć wiele sesji nauki
   - Sesja nauki należy do jednego użytkownika

4. **users** 1:N **learning_progress**
   - Jeden użytkownik może mieć wiele wpisów postępu nauki
   - Wpis postępu nauki należy do jednego użytkownika

5. **flashcards** 1:N **learning_progress**
   - Jedna fiszka może mieć wiele wpisów postępu nauki (dla różnych użytkowników)
   - Wpis postępu nauki dotyczy jednej fiszki

6. **learning_sessions** 1:N **session_flashcards**
   - Jedna sesja nauki może zawierać wiele fiszek
   - Wpis sesji fiszki należy do jednej sesji

7. **flashcards** 1:N **session_flashcards**
   - Jedna fiszka może być używana w wielu sesjach
   - Wpis sesji fiszki dotyczy jednej fiszki

8. **users** 1:N **ai_generation_stats**
   - Jeden użytkownik może mieć wiele wpisów statystyk generowania
   - Wpis statystyk generowania należy do jednego użytkownika

9. **users** 1:N **ai_generation_error_logs**
   - Jeden użytkownik może mieć wiele logów błędów generowania
   - Log błędu generowania należy do jednego użytkownika

10. **collections** 1:N **ai_generation_error_logs**
    - Jedna kolekcja może mieć wiele logów błędów generowania
    - Log błędu generowania może być powiązany z jedną kolekcją (opcjonalnie)

## 3. Indeksy

```sql
-- Indeksy dla tabeli collections
CREATE INDEX idx_collections_user_id ON collections(user_id);

-- Indeksy dla tabeli flashcards
CREATE INDEX idx_flashcards_collection_id ON flashcards(collection_id);
CREATE INDEX idx_flashcards_created_at ON flashcards(created_at);
CREATE INDEX idx_flashcards_is_ai_generated ON flashcards(is_ai_generated);

-- Indeksy dla tabeli learning_progress
CREATE INDEX idx_learning_progress_flashcard_id ON learning_progress(flashcard_id);
CREATE INDEX idx_learning_progress_user_id ON learning_progress(user_id);
CREATE INDEX idx_learning_progress_next_review_date ON learning_progress(next_review_date);
CREATE UNIQUE INDEX idx_learning_progress_user_flashcard ON learning_progress(user_id, flashcard_id);

-- Indeksy dla tabeli learning_sessions
CREATE INDEX idx_learning_sessions_user_id ON learning_sessions(user_id);
CREATE INDEX idx_learning_sessions_start_time ON learning_sessions(start_time);

-- Indeksy dla tabeli session_flashcards
CREATE INDEX idx_session_flashcards_session_id ON session_flashcards(session_id);
CREATE INDEX idx_session_flashcards_flashcard_id ON session_flashcards(flashcard_id);

-- Indeksy dla tabeli ai_generation_stats
CREATE INDEX idx_ai_generation_stats_user_id ON ai_generation_stats(user_id);
CREATE INDEX idx_ai_generation_stats_period_start ON ai_generation_stats(period_start);

-- Indeksy dla tabeli ai_generation_error_logs
CREATE INDEX idx_ai_generation_error_logs_user_id ON ai_generation_error_logs(user_id);
CREATE INDEX idx_ai_generation_error_logs_collection_id ON ai_generation_error_logs(collection_id);
CREATE INDEX idx_ai_generation_error_logs_occurred_at ON ai_generation_error_logs(occurred_at);
CREATE INDEX idx_ai_generation_error_logs_error_code ON ai_generation_error_logs(error_code);
```

## 4. Zasady Row Level Security (RLS)

```sql
-- Włączenie RLS dla wszystkich tabel
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_generation_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_generation_error_logs ENABLE ROW LEVEL SECURITY;

-- Polityki dla tabeli users
CREATE POLICY users_select_policy ON users
    FOR SELECT USING (auth.uid() = id);
    
CREATE POLICY users_insert_policy ON users
    FOR INSERT WITH CHECK (auth.uid() = id);
    
CREATE POLICY users_update_policy ON users
    FOR UPDATE USING (auth.uid() = id);
    
CREATE POLICY users_delete_policy ON users
    FOR DELETE USING (auth.uid() = id);

-- Polityki dla tabeli collections
CREATE POLICY collections_select_policy ON collections
    FOR SELECT USING (auth.uid() = user_id);
    
CREATE POLICY collections_insert_policy ON collections
    FOR INSERT WITH CHECK (auth.uid() = user_id);
    
CREATE POLICY collections_update_policy ON collections
    FOR UPDATE USING (auth.uid() = user_id);
    
CREATE POLICY collections_delete_policy ON collections
    FOR DELETE USING (auth.uid() = user_id);

-- Polityki dla tabeli flashcards
CREATE POLICY flashcards_select_policy ON flashcards
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM collections
            WHERE collections.id = flashcards.collection_id
            AND collections.user_id = auth.uid()
        )
    );
    
CREATE POLICY flashcards_insert_policy ON flashcards
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM collections
            WHERE collections.id = flashcards.collection_id
            AND collections.user_id = auth.uid()
        )
    );
    
CREATE POLICY flashcards_update_policy ON flashcards
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM collections
            WHERE collections.id = flashcards.collection_id
            AND collections.user_id = auth.uid()
        )
    );
    
CREATE POLICY flashcards_delete_policy ON flashcards
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM collections
            WHERE collections.id = flashcards.collection_id
            AND collections.user_id = auth.uid()
        )
    );

-- Polityki dla tabeli learning_progress
CREATE POLICY learning_progress_select_policy ON learning_progress
    FOR SELECT USING (auth.uid() = user_id);
    
CREATE POLICY learning_progress_insert_policy ON learning_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);
    
CREATE POLICY learning_progress_update_policy ON learning_progress
    FOR UPDATE USING (auth.uid() = user_id);
    
CREATE POLICY learning_progress_delete_policy ON learning_progress
    FOR DELETE USING (auth.uid() = user_id);

-- Polityki dla tabeli learning_sessions
CREATE POLICY learning_sessions_select_policy ON learning_sessions
    FOR SELECT USING (auth.uid() = user_id);
    
CREATE POLICY learning_sessions_insert_policy ON learning_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);
    
CREATE POLICY learning_sessions_update_policy ON learning_sessions
    FOR UPDATE USING (auth.uid() = user_id);
    
CREATE POLICY learning_sessions_delete_policy ON learning_sessions
    FOR DELETE USING (auth.uid() = user_id);

-- Polityki dla tabeli session_flashcards
CREATE POLICY session_flashcards_select_policy ON session_flashcards
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM learning_sessions
            WHERE learning_sessions.id = session_flashcards.session_id
            AND learning_sessions.user_id = auth.uid()
        )
    );
    
CREATE POLICY session_flashcards_insert_policy ON session_flashcards
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM learning_sessions
            WHERE learning_sessions.id = session_flashcards.session_id
            AND learning_sessions.user_id = auth.uid()
        )
    );
    
CREATE POLICY session_flashcards_update_policy ON session_flashcards
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM learning_sessions
            WHERE learning_sessions.id = session_flashcards.session_id
            AND learning_sessions.user_id = auth.uid()
        )
    );
    
CREATE POLICY session_flashcards_delete_policy ON session_flashcards
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM learning_sessions
            WHERE learning_sessions.id = session_flashcards.session_id
            AND learning_sessions.user_id = auth.uid()
        )
    );

-- Polityki dla tabeli ai_generation_stats
CREATE POLICY ai_generation_stats_select_policy ON ai_generation_stats
    FOR SELECT USING (auth.uid() = user_id);
    
CREATE POLICY ai_generation_stats_insert_policy ON ai_generation_stats
    FOR INSERT WITH CHECK (auth.uid() = user_id);
    
CREATE POLICY ai_generation_stats_update_policy ON ai_generation_stats
    FOR UPDATE USING (auth.uid() = user_id);
    
CREATE POLICY ai_generation_stats_delete_policy ON ai_generation_stats
    FOR DELETE USING (auth.uid() = user_id);

-- Polityki dla tabeli ai_generation_error_logs
CREATE POLICY ai_generation_error_logs_select_policy ON ai_generation_error_logs
    FOR SELECT USING (auth.uid() = user_id);
    
CREATE POLICY ai_generation_error_logs_insert_policy ON ai_generation_error_logs
    FOR INSERT WITH CHECK (auth.uid() = user_id);
    
CREATE POLICY ai_generation_error_logs_update_policy ON ai_generation_error_logs
    FOR UPDATE USING (auth.uid() = user_id);
    
CREATE POLICY ai_generation_error_logs_delete_policy ON ai_generation_error_logs
    FOR DELETE USING (auth.uid() = user_id);
```

## 5. Dodatkowe uwagi

1. **Algorytm spaced repetition**: Implementacja oparta na algorytmie SM-2 (SuperMemo 2), który jest dobrze udokumentowany i szeroko stosowany w aplikacjach do nauki z powtórkami.

2. **Ograniczenia długości tekstu**: Zastosowano ograniczenia CHECK dla długości tekstu fiszek zgodnie z wymaganiami (front_content ≤ 300 znaków, back_content ≤ 500 znaków).

3. **Kaskadowe usuwanie**: Zaimplementowano kaskadowe usuwanie dla wszystkich relacji, aby zapewnić integralność danych i ułatwić usuwanie kont użytkowników zgodnie z wymaganiami RODO.

4. **Timestamptz**: Wykorzystano typ timestamptz zamiast timestamp dla wszystkich dat, aby uniknąć problemów ze strefami czasowymi.

5. **Automatyczna aktualizacja timestampów**: Zaleca się implementację wyzwalaczy do automatycznej aktualizacji kolumn updated_at.

6. **Unikalny indeks**: Utworzono unikalny indeks dla kombinacji user_id i flashcard_id w tabeli learning_progress, aby zapewnić, że każda fiszka ma tylko jeden wpis postępu dla danego użytkownika.

7. **Integracja z Supabase**: Schemat jest zoptymalizowany do pracy z Supabase, wykorzystując wbudowany system autentykacji i funkcje zabezpieczeń na poziomie wierszy.

8. **Statystyki**: Tabela ai_generation_stats umożliwia śledzenie skuteczności generowania fiszek przez AI, co pozwoli na monitorowanie metryk sukcesu określonych w PRD.

9. **Logi błędów generowania**: Tabela ai_generation_error_logs przechowuje szczegółowe informacje o błędach występujących podczas generowania fiszek przez AI, co umożliwia diagnostykę i monitorowanie problemów. 