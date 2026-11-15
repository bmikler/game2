---
id: 07
title: Pozostałe kształty Brył i podłoga na wysokościach
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [06]
---

## Co zbudować

Wszystkie kształty Bryły: pudełko z dachem (spad wzdłuż x albo d), walec, uniesione pudełko (pusty dół). Podłoga na wysokościach jako wierzch Bryły. W Uliczce: dachy, słup ogłoszeniowy, podest, markiza na słupkach.

## Kryteria akceptacji

- [x] Każdy kształt rzuca cień i daje Odbiorniki; testy Opisu sceny.
- [x] Bramka: pod uniesionym pudełkiem światło wpada z boku.
- [x] Ta sama funkcja widoczności.
- [x] Jeśli podłoga na wysokościach okaże się droga: zapis i rezygnacja (decyzja ze specyfikacji). Nie jest droga: zostaje.

## Jak sprawdzić

Uliczka o 9:00 i 15:00: skośny cień dachu zgodny ze spadem, okrągły cień słupa, cień pod markizą ze światłem z boku.

## Wykonanie (2026-11-15, Claude)

- **Kształty Bryły** (pole `shape` węzła `Solid`): pudełko; pudełko z dachem dwuspadowym `ROOF_X` (połacie opadają wzdłuż x, kalenica wzdłuż d, szczyt do kamery) i `ROOF_D` (połacie wzdłuż d, kalenica wzdłuż x), `size_m.z` = kalenica, `eave_m` = wysokość ścian; walec pionowy (średnice = szerokość i głębia); uniesione pudełko `RAISED_BOX`, pusty dół do `clearance_m` (punkt zaczepienia zostaje na podłodze). Ostrzeżenia: okap poza zakresem podłoga–kalenica, prześwit poza zakresem podłoga–wierzch.
- **Opis sceny:** Bryła to `SolidShape` (rodzaj, obrys, okap; czysta logika). Każdy kształt jest wypukły i mieści się w obrysie, więc jedna reguła dla wszystkich. Odbiorniki mają rodzaj: równoległobok, trójkąt (szczyt dachu), dysk (wierzch walca), bok walca (zakrzywiony, normalna liczona w punkcie). Odbiorniki dalej wynikają tylko z geometrii (normalna do kamery). Dane: Bryła 2 teksele (min + rodzaj, max + okap), Odbiornik 4 teksele.
- **Ta sama funkcja widoczności** (`visibility.gdshaderinc`): promień przeciw obrysowi, potem przycięcie dwiema płaszczyznami połaci (dach) albo elipsą (walec). Bufor szuka Odbiornika na linii widzenia jak dotąd; krawędzie Odbiornika nie muszą być prostopadłe.
- **Podłoga na wysokościach zostaje:** to wierzch Bryły, dla Silnika światła bez dodatkowego kosztu (ten sam Odbiornik co podłoże). Postać na wysokości stóp dojdzie z ticketem 17.
- **Uliczka:** dachy (zachodnia i środkowa `ROOF_D`, okap na dotychczasowej wysokości, kalenica +2,5 m; wschodnia `ROOF_X` szczytem do ulicy, kalenica 9 m). Na prośbę człowieka **przejście w głąb** (6 m między środkową a wschodnią; wschodnia przesunięta o 6 m) do **oficyny na podwyższeniu** 0,9 m (podest 16 × 13 m, dwa stopnie po 0,3 m, oficyna `ROOF_D`). **Słup ogłoszeniowy** (walec ⌀ 1,2 m × 3,2 m z daszkiem-walcem) na wschodnim końcu chodnika (x = −40), **markiza na słupkach** (uniesione pudełko 4 × 3 m, prześwit 2,3 m, cztery słupki) na zachodnim (x = 45). Podłoże powiększone do 100 × 56 m (chodnik od kamery do d = 16, żeby cień markizy o 15:00 miał na czym leżeć). Albedo zastępcze (`facades.gd`): jedno na Przesłonę.
- **Testy:** `node tools/test.mjs` (ze `style-lab`): 96 zielonych. Nowe: Opis sceny (10: Odbiorniki każdego kształtu, trójkąt szczytu, niewidoczna stroma tylna połać, walec, obszar do kalenicy, kształty z węzłów, ostrzeżenia, pakowanie), GPU (5: **bramka** — słońce z boku pod uniesionym pudełkiem, jego cień przesunięty od słońca; cień walca szeroki na średnicę o 10 i 14; ostry cień szczytu wzdłuż połaci; cień słupa na wierzchu podestu; widok Odbiorników na łuku walca i obok trójkąta szczytu). Sprawdzone, że bramki walca i dachu nie przechodzą, gdy shader ich nie zna.
- **Uwagi, poza zakresem:** w Uliczce „HouseWest” stoi po lewej, czyli na wschodzie (x w prawo = zachód); nazwy z ticketu 06 zostawione. Test zrzutu `test_shot_path_goes_to_the_clipboard` czasem pada w pełnym przebiegu (schowek Windows; było tak też przed ticketem); sam i w kolejnych przebiegach zielony.

## Jak sprawdzić (uzupełnienie)

`style-lab/street_engine.bat`, WASD / strzałki przesuwają kamerę, F1 → godzina:
1. **9:00**, kamera w lewo do słupa (x ≈ −40 m): słup w słońcu, okrągły cień z zaokrąglonym końcem w prawo w dół.
2. **9:00 i 15:00**, kamera w prawo nad wschodnią kamienicę (szczyt do ulicy): jasna i ciemna połać zamieniają się, cień szczytu na ulicy skośny, zgodnie ze spadem.
3. **15:00**, kamera w prawo i w dół do markizy (x ≈ 45 m): cień daszka przesunięty w lewo w dół, pod markizą jasno (słońce wpada z boku), cienkie cienie słupków.
4. Kamera w górę nad przejście między środkową a wschodnią kamienicą: oficyna na podwyższeniu, dwa stopnie, cień kamienic na podeście.
5. „Widok debug” → „Bryły”: różowe krawędzie dachów, walców (elipsy) i markizy leżą na kształtach.
