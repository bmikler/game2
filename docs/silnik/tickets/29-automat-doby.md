---
id: 29
title: Automat doby (bramka liczbowa przewijania doby)
labels: [ready-for-agent, narzedzia]
status: closed
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

- [x] Ekspozycja i światło otwartego terenu zmieniają się w jedną stronę (noc → najjaśniejsza minuta → noc); jest już
  w `test_day_state.gd`, automat sprawdza to też na Lokacji.
- [x] Gdy Źródła mają stałe natężenie (poza godzinami przełączania z profili), piksele z ich światłem nie zmieniają
  poziomu A′ (pasy stoją); zmienia się tylko jasność z ekspozycji.
- [x] Między kolejnymi klatkami duży obszar zmienia poziom tylko w godzinach przełączania Źródeł albo wschodu/zachodu;
  poza nimi zmiana mała i lokalna (próg w stałej testu, uzasadniony).
- [x] Brak pulsowania: piksel nie zmienia poziomu tam i z powrotem w krótkim oknie (np. 3 klatki).
- [x] Bramka wykrywa celowo wprowadzone błędy z ticketu 13 (rampa okien, kotwica pasów lamp na niebie, dołek nieba o
  świcie): sprawdzone ręcznie na tymczasowej zmianie, potem cofniętej.
- [x] Czas bramki zmierzony i podany (cel: ≤ 1 min w pełnym przebiegu); plansza miniatur osobną komendą.

## Jak sprawdzić

Narzędzie: zamyka Claude po własnej weryfikacji końcowej (pamięć: tooling tickets bez sprawdzenia człowieka).
`node tools/test.mjs` zielony; trzy wstrzyknięte błędy z ticketu 13 dają czerwony wynik z godziną i miejscem.

## Stan (2026-11-21, gałąź `silnik-29-automat-doby`)

Zrobione: `tools/light_engine/day_sweep.gd` (reguły), `day_sweep_sampler.gd` + `.gdshader` (próbka na GPU, co 4. piksel),
bramka `test/engine_poligons/test_day_sweep_gpu.gd`, testy logiki `test/tools/test_day_sweep.gd` (15), plansza
`node tools/day_sheet.mjs [liczba] [plik]` (24 miniatury, ok. 20 s). Trzy błędy z ticketu 13 wstrzyknięte i cofnięte:
rampa okien → czerwono 5:40–6:00, pasy lamp na kotwicy nieba → czerwono całą noc, dołek nieba → czerwono 5:50.
Znalezisko: skoki poziomów słońca → ticket 30, w bramce na liście `KNOWN`. `node tools/test.mjs`: 221 zielonych.

**Czas:** bramka 27–29 s w pełnym przebiegu (próbkowanie na GPU ok. 13 s, analiza jednym przejściem po pikselach
na krok ok. 15 s); wcześniej 101 s, gdy cztery reguły chodziły osobno po wszystkich pikselach. Plansza: ok. 20 s.

**Znane ograniczenia (przegląd kodu):** krok, w którym któraś grupa Źródeł się przełącza, jest pomijany w całości przez
reguły pasów i dużych zmian (bramka nie wie, które piksele świecą od której grupy); pulsowanie sprawdza go dalej. Piksele
z lampą i słońcem naraz nie wchodzą do reguły pasów (słońce samo przesuwa ich poziom). Bramka zakłada gładkie niebo (B)
i sprawdza to na starcie; przy niebie A/C trzeba by inaczej wyłuskać poziomy. Dopóki ticket 30 jest otwarty, każda duża
zmiana z przewagą słońca jest zgłaszana jako „sun jump” i nie oblewa bramki, także nowa fala na nasłonecznionym terenie.

Zamknięte przez Claude po własnej weryfikacji (ticket narzędziowy): `node tools/test.mjs` 221 zielonych, trzy wstrzyknięte
błędy dały czerwony wynik z godziną i miejscem.
