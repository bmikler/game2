---
id: 16
title: Płynne przewijanie doby
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [14]
---

## Co zbudować

Słońce przeliczane kaflami (rzędy 32×32 px z listą Brył i Źródeł) rozłożonymi na klatki; stary i nowy stan przenikają się, cienie doganiają godzinę w ok. ¼ s. Koszt piksela nie rośnie z rozmiarem Lokacji.

## Kryteria akceptacji

- [ ] Kafle z listami w Opisie sceny (testy).
- [ ] Przeliczanie rozłożone na klatki z przenikaniem.
- [ ] Bramka: brak skoków między kolejnymi minutami doby.
- [ ] Widok debug: kafle i warstwy.

## Jak sprawdzić

Uliczka, szybkie tempo czasu: cienie suną płynnie, bez skoku pasów.
