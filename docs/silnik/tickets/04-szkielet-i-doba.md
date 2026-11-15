---
id: 04
title: Szkielet silnika i doba na podłodze
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [03]
---

## Co zbudować

Samodzielny addon Silnika światła i pierwszy widoczny efekt: w nowym, pustym Poligonie Ulica płaska podłoga zmienia światło z godziną (słońce, niebo, ambient, bez cieni). Godzina jest jedynym wejściem czasu; z Krzywych doby powstaje Stan doby raz na klatkę. Panel silnika w F1: godzina, tempo czasu, odczyt Stanu doby.

## Kryteria akceptacji

- [ ] Addon w osobnym katalogu, bez odwołań do reszty `style-lab`.
- [ ] GUT 9.7.1 (poza katalogiem silnika); jedna komenda `node tools/test.mjs` uruchamia testy headless i testy GPU w oknie poza ekranem.
- [ ] Test „bez kodu pod scenę”: katalog silnika nie odwołuje się do `style-lab` ani do nazw scen.
- [ ] Zasób Krzywych doby (wszystkie krzywe ze specyfikacji, w tym zachmurzenie i ekspozycja) z punktami startowymi ze Ściągi wyglądu; Stan doby jako czysta funkcja godziny z testami (wschód po lewej, zachód po prawej, południe u góry; zachmurzenie osłabia słońce).
- [ ] Zasób rzutu (0,60, 40 px/m) w addonie; test metry → ekran.
- [ ] Kadr 960×540 jak w game2 (ticket rzutu 09: „kadr 960×540 wszędzie”, ×2 na 1080p); przełącznik kadru w F1 Poligonu (960×540 / 640×360, środek widoku stały), bo prototypy mapy silnika (proto-09) liczyły 640×360 i pokazywały mniejszy obszar ulicy (uwaga człowieka, 2026-11-15).
- [ ] Węzeł Otoczenie Lokacji.
- [ ] Nowy Poligon Ulica (scena z węzłów kontraktu) ze starterem `.bat`; stare Poligony nietknięte.
- [ ] Panel silnika osadzony w F1 Poligonu.

## Jak sprawdzić

Uruchom nowy Poligon Ulica, F1: przewiń godzinę od 0 do 24. Podłoga przechodzi płynnie przez noc, świt, dzień, zmierzch; odczyt pokazuje słońce wschodzące po lewej i zachodzące po prawej.
