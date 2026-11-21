---
id: 29
title: Automat doby (bramka liczbowa przewijania doby)
labels: [ready-for-agent, narzedzia]
status: open
assignee:
blocked_by: [13]
---

## Co zbudować

Bramka GPU w `node tools/test.mjs`, która przewija dobę w Poligonie co 10 min (144 klatki) i liczbami szuka tego, co
człowiek dotąd łapał okiem w ticketach 11 i 13: fal, skoków i pulsowania światła. Bez oglądania zrzutów (tokeny):
wynik to zielono / czerwono z godziną, miejscem i opisem. Na żądanie plansza 12–24 miniatur doby w jednym PNG do
szybkiego przeglądu.

Kontekst (ticket 13): stała latarnia skakała między poziomami A′ (kotwica na niebie), okna zapalane rampą przesuwały
pasy po chodniku, a niebo o świcie miało dołek (noc opisana dwa razy). Żaden test tego nie łapał: sprawdzały tylko brak
skoku między minutami, nie kierunek ani ruch pasów.

## Kryteria akceptacji

- [ ] Ekspozycja i światło otwartego terenu zmieniają się w jedną stronę (noc → najjaśniejsza minuta → noc); jest już
  w `test_day_state.gd`, automat sprawdza to też na Lokacji.
- [ ] Gdy Źródła mają stałe natężenie (poza godzinami przełączania z profili), piksele z ich światłem nie zmieniają
  poziomu A′ (pasy stoją); zmienia się tylko jasność z ekspozycji.
- [ ] Między kolejnymi klatkami duży obszar zmienia poziom tylko w godzinach przełączania Źródeł albo wschodu/zachodu;
  poza nimi zmiana mała i lokalna (próg w stałej testu, uzasadniony).
- [ ] Brak pulsowania: piksel nie zmienia poziomu tam i z powrotem w krótkim oknie (np. 3 klatki).
- [ ] Bramka wykrywa celowo wprowadzone błędy z ticketu 13 (rampa okien, kotwica pasów lamp na niebie, dołek nieba o
  świcie): sprawdzone ręcznie na tymczasowej zmianie, potem cofniętej.
- [ ] Czas bramki zmierzony i podany (cel: ≤ 1 min w pełnym przebiegu); plansza miniatur osobną komendą.

## Jak sprawdzić

Narzędzie: zamyka Claude po własnej weryfikacji końcowej (pamięć: tooling tickets bez sprawdzenia człowieka).
`node tools/test.mjs` zielony; trzy wstrzyknięte błędy z ticketu 13 dają czerwony wynik z godziną i miejscem.

## Stan (2026-11-21, gałąź `silnik-29-automat-doby`)

Zrobione: `tools/light_engine/day_sweep.gd` (reguły), `day_sweep_sampler.gd` + `.gdshader` (próbka na GPU, co 4. piksel),
bramka `test/engine_poligons/test_day_sweep_gpu.gd`, testy logiki `test/tools/test_day_sweep.gd` (15), plansza
`node tools/day_sheet.mjs [liczba] [plik]` (24 miniatury, ok. 20 s). Trzy błędy z ticketu 13 wstrzyknięte i cofnięte:
rampa okien → czerwono 5:40–6:00, pasy lamp na kotwicy nieba → czerwono całą noc, dołek nieba → czerwono 5:50.
Znalezisko: skoki poziomów słońca → ticket 30, w bramce na liście `KNOWN`. `node tools/test.mjs`: 221 zielonych.

**Otwarte:** czas bramki 36 s w pierwszym przebiegu, 101 s w ostatnim (laptop na baterii; sama analiza `check()` na
zapisanym przebiegu 19 s → 81 s). Cel ≤ 1 min niepotwierdzony: zmierzyć na zasilaniu, ewentualnie przyspieszyć `check()`
(np. lista aktywnych pikseli liczona raz). Przegląd kodu (`code-review`) jeszcze nie zrobiony.
