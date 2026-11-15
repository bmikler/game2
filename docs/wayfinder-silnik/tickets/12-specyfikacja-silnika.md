---
id: 12
title: Specyfikacja silnika
labels: [wayfinder:task]
status: open
assignee:
blocked_by: [07, 08, 09, 10, 11, 13, 16]
---

## Question

Złożyć specyfikację Silnika światła z rozstrzygnięć tej mapy (`/to-spec`), gotową do pocięcia przez `/to-tickets` na tickety wykonawcze dla `/implement`.

**Z zamknięcia „Krzywe doby i noc” i „Stylizacja rozproszenia w powietrzu” (poza zakresem, strojenie po wdrożeniu):** specyfikacja musi zapewnić, że da się je stroić Wariantami bez zmian w kodzie: pełny zestaw Krzywych doby (droga słońca: wysokość i azymut, kolory i natężenia słońca, nieba i ambientu, tarcza, ekspozycja, schemat zachmurzenia), godziny świecenia w profilach Źródeł; stylizacja Smug i kurzu w Zestawie strojenia (gładko / dither, gęstość i ruch drobinek, szew). Punkty startowe przeniesione ze starego silnika (game1, `style-lab/lighting/`), żeby od pierwszego ticketu wyglądało rozsądnie.

**Z zamknięcia „Migracja ze starego silnika”:** specyfikacja opisuje układ nowych Poligonów (Ulica: Uliczka, Sklep, Skwer; Dom: salon, kuchnia, pracownia), kolejność plastrów (Ulica, potem Dom), zasadę „południe na górze ekranu” i ticket „Usunięcie starego silnika” przed testem końcowym. Claude kompiluje Ściągę wyglądu ze starych ustaleń jako załącznik dla krytyków, nie jako wymagania; „punkty startowe” powyżej to tylko start, nie cel.
