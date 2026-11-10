---
id: 06
title: Oprawa dialogów i scen konfrontacji, plecak i dziennik w pixel arcie o klimacie noir
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Jak gry narracyjne (Disco Elysium, Citizen Sleeper, Norco, Kentucky Route Zero, Pentiment, Signalis, gry Wadjet Eye, Replaced i inne) pokazują: (a) rozmowę: kolumna vs duże portrety vs postacie w świecie; (b) sceny konfrontacji rozgrywane jak dialog z animacjami postaci w świecie (opcja „wyciągnij broń” → animacja → reakcja przeciwnika), z ruchem kamery lub bez; (c) plecak i dziennik spójne z grafiką gry. Ile animacji i portretów to wymaga (koszt produkcji). Nie powtarzać `27b`, `27c` i ticketów UI z game1 (`docs/game1/`); uzupełniać. Wynik: `docs/research/65-*.md`.

## Resolution

- Trzy rodziny oprawy rozmowy: kolumna z małym portretem (Disco, Norco), duże portrety (Wadjet Eye), tekst w świecie (Thimbleweed, Pentiment, KRZ). Dla game2 najtańsza jest kolumna z portretem z game1 plus scena w tle z krótkimi animacjami postaci.
- Dialogowych konfrontacji nie ma wzorca w grach z listy; źródła pierwotne słabe (Replaced: tylko jakościowo, ręczna animacja i ręczne kamery). Propozycja: węzeł dialogu z „bitem” animacji, stała kamera, najazd x2 i drgnięcie; zestaw bitów zamrozić w Przepisie postaci.
- Plecak i dziennik: osobna warstwa 2D spójna paletą, konturem, czcionką bitmapową i 9-slice/siatką ikon, bez światła.
- Koszt: portrety 3-5 min na postać tanio; bity konfrontacji (ok. 20-25 klatek x kierunki x warianty stroju) to największa pozycja.
- Szczegóły, tabela kosztów i pytania do człowieka: `docs/research/65-oprawa-dialogow-konfrontacje-plecak.md`.
