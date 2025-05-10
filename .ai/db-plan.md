<database_planning_output>
<pytania>
1. Czy kolekcje fiszek będą miały jakieś dodatkowe atrybuty (np. nazwa, opis, kategoria)?
2. Jakie dokładnie informacje będą przechowywane w ramach sesji nauki (np. data sesji, czas trwania, liczba przeglądniętych fiszek)?
3. Jak będzie reprezentowany poziom trudności fiszki (np. jako liczba w określonej skali, czy jako kategoria)?
4. Czy algorytm spaced repetition będzie wymagał przechowywania dodatkowych parametrów dla każdej fiszki (np. interwał powtórek, współczynnik łatwości)?
5. Jakie konkretnie zasady bezpieczeństwa na poziomie wierszy (RLS) będą potrzebne dla poszczególnych tabel?
6. Czy będzie potrzebna funkcjonalność wyszukiwania tekstowego w fiszkach?
7. Czy istnieją jakieś szczególne wymagania dotyczące wydajności dla konkretnych operacji na bazie danych?
</pytania>

<rekomendacje>
1. Utworzenie struktury bazy danych z następującymi głównymi tabelami: `users`, `collections`, `flashcards`, `learning_sessions`, `learning_progress`, i `ai_generation_stats`.
2. W tabeli `collections` przechowywać nazwę, opis i datę utworzenia kolekcji.
3. W tabeli `flashcards` przechowywać dwa pola tekstowe: `front_content` i `back_content` dla dwóch stron fiszki, oraz poziom trudności.
4. Implementacja relacji jeden-do-wielu między `users` i `collections` (użytkownik może mieć wiele kolekcji).
5. Implementacja relacji jeden-do-wielu między `collections` i `flashcards` (kolekcja zawiera wiele fiszek).
6. Utworzenie tabeli `learning_progress` do przechowywania parametrów algorytmu spaced repetition dla każdej fiszki.
7. Zaprojektowanie tabeli `learning_sessions` z polami dla daty rozpoczęcia, daty zakończenia, liczby przeglądniętych fiszek i czasu trwania.
8. Dodanie tabeli `session_flashcards` do śledzenia, które fiszki były przeglądane w danej sesji.
9. Implementacja tabeli `ai_generation_stats` do przechowywania statystyk generowania fiszek przez AI w określonych okresach.
10. Zastosowanie RLS w Supabase z politykami dostępu opartymi na user_id dla wszystkich tabel.
11. Dodanie kaskadowego usuwania dla relacji między użytkownikami, kolekcjami i fiszkami.
12. Implementacja indeksów dla kolumn często używanych w zapytaniach.
13. Wykorzystanie typów timestamptz zamiast timestamp dla wszystkich dat.
14. Dodanie pola `is_ai_generated` w tabeli `flashcards` do oznaczenia czy fiszka została utworzona przez AI czy manualnie.
15. Implementacja funkcji i wyzwalaczy PostgreSQL do automatycznego aktualizowania statystyk po operacjach na fiszkach.
</rekomendacje>
</database_planning_output>

Bazując na dostarczonych informacjach, poniżej znajduje się schemat bazy danych PostgreSQL dla aplikacji AplikacjaFiszki:

# Schemat bazy danych dla AplikacjaFiszki

## 1. Lista tabel

### users
| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | uuid | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator użytkownika |
| username | text | NOT NULL, UNIQUE | Nazwa użytkownika |
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
| front_content | text | NOT NULL | Zawartość przedniej strony fiszki |
| back_content | text | NOT NULL | Zawartość tylnej strony fiszki |
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

4. **flashcards** 1:N **learning_progress**
   - Jedna fiszka ma jeden wpis postępu nauki dla danego użytkownika
   - Wpis postępu nauki dotyczy jednej fiszki

5. **learning_sessions** 1:N **session_flashcards**
   - Jedna sesja nauki może zawierać wiele fiszek
   - Wpis sesji fiszki należy do jednej sesji

6. **flashcards** 1:N **session_flashcards**
   - Jedna fiszka może być używana w wielu sesjach
   - Wpis sesji fiszki dotyczy jednej fiszki

7. **users** 1:N **ai_generation_stats**
   - Jeden użytkownik może mieć wiele wpisów statystyk generowania
   - Wpis statystyk generowania należy do jednego użytkownika

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
```

## 4. Zasady Row Level Security (RLS)

```sql
-- Włączenie RLS dla wszystkich tabel
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_generation_stats ENABLE ROW LEVEL SECURITY;

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

-- Podobne polityki dla pozostałych tabel...
```

## 5. Dodatkowe uwagi

1. **Algorytm spaced repetition**: Implementacja oparta na algorytmie SM-2 (SuperMemo 2), który jest dobrze udokumentowany i szeroko stosowany w aplikacjach do nauki z powtórkami.

2. **Soft delete**: Nie zaimplementowano mechanizmu soft delete, ponieważ zgodnie z wymaganiami, usunięcie konta powinno skutkować trwałym usunięciem wszystkich powiązanych danych.

3. **Skalowalność**: Schemat został zaprojektowany z myślą o skalowalności. Indeksy zostały dodane dla kolumn używanych w częstych zapytaniach, co powinno zapewnić dobrą wydajność nawet przy dużej liczbie rekordów.

4. **Bezpieczeństwo**: Row Level Security zapewnia, że użytkownicy mają dostęp tylko do własnych danych, co jest zgodne z wymaganiami bezpieczeństwa i RODO.

5. **Integracja z Supabase**: Schemat jest zoptymalizowany do pracy z Supabase, wykorzystując wbudowany system autentykacji i funkcje zabezpieczeń na poziomie wierszy.

6. **Statystyki**: Tabela ai_generation_stats umożliwia śledzenie skuteczności generowania fiszek przez AI, co pozwoli na monitorowanie metryk sukcesu określonych w PRD.
