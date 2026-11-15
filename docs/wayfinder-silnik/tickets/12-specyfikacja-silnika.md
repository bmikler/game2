---
id: 12
title: Specyfikacja silnika
labels: [wayfinder:task]
status: closed
assignee: claude
blocked_by: [07, 08, 09, 10, 11, 13, 16]
---

## Question

Złożyć specyfikację Silnika światła z rozstrzygnięć tej mapy (`/to-spec`), gotową do pocięcia przez `/to-tickets` na tickety wykonawcze dla `/implement`.

**Z zamknięcia „Krzywe doby i noc” i „Stylizacja rozproszenia w powietrzu” (poza zakresem, strojenie po wdrożeniu):** specyfikacja musi zapewnić, że da się je stroić Wariantami bez zmian w kodzie: pełny zestaw Krzywych doby (droga słońca: wysokość i azymut, kolory i natężenia słońca, nieba i ambientu, tarcza, ekspozycja, schemat zachmurzenia), godziny świecenia w profilach Źródeł; stylizacja Smug i kurzu w Zestawie strojenia (gładko / dither, gęstość i ruch drobinek, szew). Punkty startowe przeniesione ze starego silnika (game1, `style-lab/lighting/`), żeby od pierwszego ticketu wyglądało rozsądnie.

**Z zamknięcia „Migracja ze starego silnika”:** specyfikacja opisuje układ nowych Poligonów (Ulica: Uliczka, Sklep, Skwer; Dom: salon, kuchnia, pracownia), kolejność plastrów (Ulica, potem Dom), zasadę „południe na górze ekranu” i ticket „Usunięcie starego silnika” przed testem końcowym. Claude kompiluje Ściągę wyglądu ze starych ustaleń jako załącznik dla krytyków, nie jako wymagania; „punkty startowe” powyżej to tylko start, nie cel.

## Resolution

2026-11-15. Specyfikacja złożona (AFK, z rozstrzygnięć ticketów 07–16): [`docs/silnik/spec.md`](../../silnik/spec.md), status `ready-for-agent`. Załącznik dla krytyków: [Ściąga wyglądu](../../silnik/sciaga-wygladu.md) (stare ustalenia jako klimat i punkty startowe, nie wymagania).

- Moduły: Kontrakt sceny (węzły `@tool`), Opis sceny (czysta kompilacja kontraktu), Stan doby, Zasoby strojenia i Warianty, Bufor światła (warstwy według zmienności, dwa kanały, jedna funkcja widoczności), Rozproszenie w powietrzu, Stylizacja (A′ w dwóch trybach, ekspozycja automatyczna), Podgląd w edytorze, Panel silnika; nowe Poligony; usunięcie starego silnika; test końcowy.
- Szwy testów (decyzja Claude'a, człowiek deleguje technikę): Lokacja → Bufor światła (GPU, bramki), węzły → Opis sceny, Krzywe doby + godzina → Stan doby, zasoby i Warianty (headless).
- Wymagania z „Krzywe doby i noc” i „Stylizacja rozproszenia w powietrzu” wpisane w moduł zasobów strojenia (pełne Krzywe doby, godziny świecenia w profilach, stylizacja Smug i kurzu w Zestawie), punkty startowe ze Ściągi.
- Proponowana kolejność 18 plastrów (Ulica, potem Dom) w „Further Notes”; wiążąca dopiero po `/to-tickets` z człowiekiem.

Dalej: `/to-tickets docs/silnik/spec.md` → tickety w `docs/silnik/tickets/`, każdy przez `/implement`.
