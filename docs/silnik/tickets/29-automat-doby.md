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
