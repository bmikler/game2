---
id: 28
title: Porównanie „północ u góry mapy”
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [27]
---

## Co zbudować

Na koniec budowy silnika, przed strojeniem (ticket 38 mapy grafiki): przełącznik w F1 Poligonów „Góra mapy: południe / północ”, żeby człowiek jeszcze raz porównał na żywo obie orientacje na gotowym silniku. Prośba człowieka (2026-11-15, po obejrzeniu cieni w Uliczce, ticket 06): „nie wiem, czy jeszcze raz nie będziemy sprawdzać opcji północ na górze mapy”.

Dziś specyfikacja ustala południe zawsze u góry, słońce ze wschodu (lewo) na zachód (prawo), bez pola orientacji w Lokacji. Przy północy u góry słońce świeci od strony kamery (cienie padają w głąb ekranu, na fasady), wschód jest po prawej. Stare Poligony miały taką opcję (`gora_mapy`, zrzuty `shots/t31/` z prefiksami `g1_` i `g0_`); ten ticket robi to w nowym silniku.

## Kryteria akceptacji

- [ ] Przełącznik w F1 (panel silnika), także w opisie zrzutu i w `--z-zrzutu`.
- [ ] Jedna reguła w Stanie doby (kierunek słońca obrócony o 180° wokół pionu), bez zmian w Lokacjach, kontrakcie sceny i shaderach poza kierunkiem Źródeł; niebo i Źródła powierzchniowe bez zmian.
- [ ] Test Stanu doby: przy północy u góry słońce rano po prawej, w południe od strony kamery.
- [ ] Bramka: cień po przeciwnej stronie niż słońce w obu orientacjach.
- [ ] Decyzja człowieka zapisana w tickecie i w specyfikacji; jeśli zostaje południe, przełącznik znika z F1.

## Jak sprawdzić

Poligon Ulica (Uliczka i Sklep) i Poligon Dom (salon), 9:00, 12:00, 15:00: F1 „Góra mapy” południe ↔ północ. Porównać czytelność cieni na ulicy i fasadach oraz Plamy okna we wnętrzu.
