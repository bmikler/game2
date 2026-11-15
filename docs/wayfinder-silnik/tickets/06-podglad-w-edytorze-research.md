---
id: 06
title: Podgląd światła w edytorze Godota 4.7
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Czy w Godot 4.7 da się zbudować Lokację z węzłów `@tool` (przesłony, otwory, źródła światła) tak, żeby edytor pokazywał na żywo bufor światła i cienie (shadery i `SubViewport` w widoku edytora, odświeżanie przy przesuwaniu węzła, koszt)? Jakie są ograniczenia `@tool` (stan, zapisywanie sceny, błędy w edytorze) i jak najprościej zbierać dane sceny z węzłów (grupy, przeszukanie drzewa, rejestracja)?

Model: Sonnet. Wynik: `docs/research/90-*.md`.

## Resolution

2026-11-15. Research: `docs/research/90-podglad-w-edytorze.md` (Sonnet, sprawdzone w próbnym projekcie poza repo).

- **Podgląd na żywo w edytorze 4.7.2 jest wykonalny:** węzły `@tool` budują `SubViewport` z shaderem, bufor odświeża się po przesunięciu przesłony.
- **Wzorzec:** węzły kontraktu `@tool` z `@export`, własna grupa dodawana w `_enter_tree`, sygnał `changed`; jeden kontroler zbiera dane przez `get_nodes_in_group`, ustawia uniformy i renderuje `UPDATE_ONCE` tylko przy fladze `dirty` (brak kosztu w spoczynku). Węzły pomocnicze bez `owner` nie trafiają do `.tscn`, więc scena zapisuje tylko węzły kontraktu.
- **Ograniczenia:** cały łańcuch skryptów musi być `@tool`; zmiany z kodu nie oznaczają sceny jako zmienionej; po zmianie skryptu czasem trzeba ponownie otworzyć scenę (GH-66381); godzina i tryb podglądu jako `@export` kontrolera.
- **Nie sprawdzono:** przeciągania myszą, dużych scen, podscen z węzłami `@tool`, kosztu pełnego bufora silnika w edytorze (luki wypisane w pliku).
