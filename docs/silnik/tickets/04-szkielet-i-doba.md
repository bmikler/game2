---
id: 04
title: Szkielet silnika i doba na podłodze
labels: [ready-for-agent]
status: closed
assignee:
blocked_by: [03]
---

## Co zbudować

Samodzielny addon Silnika światła i pierwszy widoczny efekt: w nowym, pustym Poligonie Ulica płaska podłoga zmienia światło z godziną (słońce, niebo, ambient, bez cieni). Godzina jest jedynym wejściem czasu; z Krzywych doby powstaje Stan doby raz na klatkę. Panel silnika w F1: godzina, tempo czasu, odczyt Stanu doby.

## Kryteria akceptacji

- [x] Addon w osobnym katalogu, bez odwołań do reszty `style-lab`.
- [x] GUT 9.7.1 (poza katalogiem silnika); jedna komenda `node tools/test.mjs` uruchamia testy headless i testy GPU w oknie poza ekranem.
- [x] Test „bez kodu pod scenę”: katalog silnika nie odwołuje się do `style-lab` ani do nazw scen.
- [x] Zasób Krzywych doby (wszystkie krzywe ze specyfikacji, w tym zachmurzenie i ekspozycja) z punktami startowymi ze Ściągi wyglądu; Stan doby jako czysta funkcja godziny z testami (wschód po lewej, zachód po prawej, południe u góry; zachmurzenie osłabia słońce).
- [x] Zasób rzutu (0,60, 40 px/m) w addonie; test metry → ekran.
- [x] Kadr 960×540 jak w game2 (ticket rzutu 09: „kadr 960×540 wszędzie”, ×2 na 1080p); przełącznik kadru w F1 Poligonu (960×540 / 640×360, środek widoku stały), bo prototypy mapy silnika (proto-09) liczyły 640×360 i pokazywały mniejszy obszar ulicy (uwaga człowieka, 2026-11-15).
- [x] Węzeł Otoczenie Lokacji.
- [x] Nowy Poligon Ulica (scena z węzłów kontraktu) ze starterem `.bat`; stare Poligony nietknięte.
- [x] Panel silnika osadzony w F1 Poligonu.

## Jak sprawdzić

Uruchom nowy Poligon Ulica, F1: przewiń godzinę od 0 do 24. Podłoga przechodzi płynnie przez noc, świt, dzień, zmierzch; odczyt pokazuje słońce wschodzące po lewej i zachodzące po prawej.

## Wykonanie (2026-11-15, Claude)

- Kod po angielsku (uwaga człowieka): `LightEngine` (kontroler), `DayState` (Stan doby), `DayCurves` (Krzywe doby), `SkyProfile` (profil nieba: `sky_city`, `sky_village`), `TuningSet` (Zestaw strojenia: `outdoor`, `interior`; pola dochodzą w kolejnych ticketach), `LocationEnvironment` (Otoczenie Lokacji), `LightProjection` (`projection.tres`), `EnginePanel` (panel silnika). Katalog `style-lab/addons/swiatlo/` jak w specyfikacji.
- Osie świata: x w prawo (zachód), d w stronę kamery (północ, w dół ekranu), z w górę; ekran = (x, d·0,60 − z) · 40 px.
- Punkty startowe: generator `style-lab/tools/light_engine/start_values.gd` (droga słońca, kolory nieba i ambientu, kolory słońca z Ściągi 4.1; natężenia nieba i ambientu oraz krzywa ekspozycji dobrane tak, by dzień dawał ok. 0,85 albedo, zmierzch ok. 0,4, noc miasta ok. 0,18). Zachmurzenie płaskie 0 (bez hacka z game1); schemat ustala krytyk. Ekspozycja: EV sceny → EV bieli; `Y_ref` dojdzie w tickecie 11.
- Światło podłogi na razie jako mnożnik całego obrazu Lokacji (bez Bufora, ten od ticketu 06).
- GUT 9.7.1 w `style-lab/addons/gut/`; w `project.godot` ostrzeżenia typów włączone z powrotem dla `res://addons/swiatlo` (GUT dalej wyłączony). `node tools/test.mjs` (z `style-lab`): 41 testów zielonych, w tym GPU.
- Poligon: `style-lab/street_engine.bat` → `engine_poligons/street/poligon_street.tscn`. Kadr skalowany do wysokości okna (jak stary LitView; przy oknie ok. 990 px skala całkowita dawała ×1).
- Poprawka po sprawdzeniu: zasoby silnika (`LightProjection`, `DayCurves`, `SkyProfile`, `TuningSet`) jako `@tool`, bo w edytorze były zaślepkami i `street.tscn` był czarny.

### Ocena człowieka

2026-11-15: „ok teraz to widać, wygląda że działa” (ulica widoczna w edytorze, doba w Poligonie).
