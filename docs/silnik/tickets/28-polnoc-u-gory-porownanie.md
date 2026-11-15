---
id: 28
title: Porównanie „północ u góry mapy”
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [27]
---

## Co zbudować

Na koniec budowy silnika, przed strojeniem (ticket 38 mapy grafiki): decyzja człowieka, która orientacja zostaje, po porównaniu na żywo na gotowym silniku. Przełącznik „Góra mapy: południe / północ” jest już w panelu silnika od ticketu 06 (człowiek ogląda go przy kolejnych ticketach). Prośba człowieka (2026-11-15, po obejrzeniu cieni w Uliczce, ticket 06): „nie wiem, czy jeszcze raz nie będziemy sprawdzać opcji północ na górze mapy”.

Dziś specyfikacja ustala południe zawsze u góry, słońce ze wschodu (lewo) na zachód (prawo), bez pola orientacji w Lokacji. Przy północy u góry słońce świeci od strony kamery (cienie padają w głąb ekranu, na fasady), wschód jest po prawej. Stare Poligony miały taką opcję (`gora_mapy`, zrzuty `shots/t31/` z prefiksami `g1_` i `g0_`); w nowym silniku przełącznik jest od ticketu 06.

## Kryteria akceptacji

- [x] Przełącznik w F1 (panel silnika), w opisie zrzutu i w `--z-zrzutu` (ticket 06).
- [x] Jedna reguła w Stanie doby (kierunek słońca obrócony o 180° wokół pionu), bez zmian w Lokacjach i kontrakcie sceny (ticket 06).
- [x] Testy: Stan doby (rano słońce po prawej, w południe od strony kamery), bramka cienia przy północy u góry (ticket 06).
- [ ] Przełącznik działa we wszystkich Poligonach (Ulica i Dom) zbudowanych do tego czasu.
- [ ] Decyzja człowieka zapisana w tickecie i w specyfikacji; zostaje jedna orientacja, przełącznik znika z F1 (bez dwóch dróg na stałe).

## Jak sprawdzić

Poligon Ulica (Uliczka i Sklep) i Poligon Dom (salon), 9:00, 12:00, 15:00: F1 „Góra mapy” południe ↔ północ. Porównać czytelność cieni na ulicy i fasadach oraz Plamy okna we wnętrzu.
