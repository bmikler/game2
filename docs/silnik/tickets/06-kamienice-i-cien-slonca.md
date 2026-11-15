---
id: 06
title: Kamienice i cień słońca
labels: [ready-for-agent]
status: closed
assignee:
blocked_by: [04]
---

## Co zbudować

Odcinek Uliczka: rząd kamienic od południa (pudełka) z prześwitem 2 m rzuca ostry cień słońca na ulicę, fasady (Odbiorniki) oświetlone zgodnie z kierunkiem słońca. Pierwsza wersja Bufora światła (×1, cała Lokacja, kanał naturalny w HDR) i Opisu sceny (Bryły → Odbiorniki, obszar Bufora).

## Kryteria akceptacji

- [x] Węzły Przesłona i Bryła (pudełko) w metrach, pozycja z rzutu.
- [x] Opis sceny jako czysta logika (Odbiorniki, obszar), testy.
- [x] Jedna funkcja widoczności, używana później przez wszystkie Źródła.
- [x] Bramka: cień po przeciwnej stronie niż słońce.
- [x] Widok debug: brak / Bryły / Odbiorniki.

## Jak sprawdzić

Uliczka, 8:00 → 16:00: cień kamienic sunie po ulicy z lewej na prawą, w prześwicie pas słońca. Widok debug „Bryły” pokrywa się z kamienicami.

## Wykonanie (2026-11-15, Claude)

- **Węzły kontraktu** (`addons/swiatlo/contract/`): `Occluder` (Przesłona) i `Solid` (Bryła, na razie pudełko), pola w metrach (`position_m`, `size_m`), pozycja na ekranie z rzutu. Punkt zaczepienia Bryły jak w kontrakcie assetu: środek przedniej dolnej krawędzi, względem Przesłony. Przesłona jest w grupie kontraktu i podaje Bryły w metrach Lokacji (Bryła nie sięga do rodzica); jeden zasób rzutu dla silnika i węzłów. W edytorze Bryła rysuje swoje krawędzie; ostrzeżenia: Bryła poza Przesłoną, zerowy wymiar. Pole „ruchoma” i wychylenie od wiatru dojdą z ruchomymi Przesłonami (tickety 17 i 19).
- **Opis sceny** (`addons/swiatlo/scene/`, czysta logika): `SceneDescription` (Bryły, Odbiorniki, obszar Bufora w px) i `Receiver` (Odbiornik: równoległobok w metrach z normalną). Odbiornik = ściana Bryły z normalną zwróconą do kamery (`n · (0; 1; 0,6) > 0`), bez flagi; dla pudełka wierzch i przód. Obszar = obrys wszystkich Brył na ekranie. Pakowanie do tekstur danych RGBAF (Bryła: 2 teksele, Odbiornik: 3).
- **Podłoga = wierzch Bryły:** podłoże Lokacji to płaska Bryła z wierzchem na z = 0 (w Uliczce 80 × 32 m). Bez osobnego rodzaju podłogi; podłogi na wysokościach w tickecie 07 to ta sama reguła. Poza obszarem Bufora obraz zostaje nieoświetlony.
- **Bufor światła** (`addons/swiatlo/buffer/`): `LightBuffer`, SubViewport HDR (`use_hdr_2d`) 1 px = 1 px gry nad całą Lokacją, rysowany raz przy zmianie sceny albo Stanu doby. Piksel wybiera Odbiornik najbliżej kamery na swojej linii widzenia i liczy kanał naturalny w luksach: ambient + niebo (na razie bez zasłaniania: 1 na wierzchu, ½ na ścianie, kopuła w tickecie 08) + słońce × cos × widoczność. Obraz = albedo × Bufor × ekspozycja (mnożenie nad obrazem Lokacji). Odczyt RGBAH z `get_image()` działa (decyzja odłożona w specyfikacji).
- **Jedna funkcja widoczności:** `visibility(punkt, kierunek, zasięg)` w `buffer/visibility.gdshaderinc` (promień przeciw wszystkim Bryłom, start 2 cm od ściany wzdłuż normalnej). Na razie twarda (półcień: ticket 14); każde kolejne Źródło ma jej używać.
- **Widok debug** w panelu silnika (pod przyciskiem zrzutu): brak / Bryły (różowe krawędzie wszystkich Brył) / Odbiorniki (wierzch niebieski, przód pomarańczowy). Poligon zapisuje go w zrzucie jako przełącznik „widok debug”.
- **Uliczka** (`engine_poligons/street/street.tscn`): Przesłona `Alley` z trzema kamienicami w rzędzie (front na d = −10), prześwit 2 m między zachodnią a środkową. Wysokości z ustaleń mapy grafiki (ticket 09/10, research 63): parter 2,9 m (1,6 × postać 1,8 m), piętra niższe, 2,7 m; zachodnia i wschodnia 2 kondygnacje (5,6 m), środkowa 3 (8,3 m), głębia 8 m, jak dom i sklep w starym Poligonie Ulica (uwaga człowieka: wcześniejsze 3–4 kondygnacje były dużo wyższe niż w game2 i zasłaniały całą mapę). Albedo kamienic to zastępcze płaskie kolory Poligonu (`facades.gd`) do czasu sprite'ów. Kamera wyżej (y = −200 px), żeby było widać fasady; do czasu postaci (ticket 17) akcje ruchu (WASD / strzałki) przesuwają kamerę, a jej pozycja trafia do zrzutu (przełącznik „kamera”).
- **⚠ ZMIENIONY KĄT SŁOŃCA (nie Skandynawia):** w południe **30°** zamiast ok. 15° (lutowa Norwegia ze Ściągi wyglądu). Człowiek (2026-11-15): światło nie musi być 1:1 zgodne z fizyką, ale bez letniego słońca; kąt wybrany z października–marca, najdalej na południe Polska. Południe Polski (49° N): w południe od 17,5° (21 grudnia) do ok. 45° (koniec marca); 30° to koniec października / koniec lutego (najpierw próbowane 38° i 45°: człowiek uznał za za wysoko). Zmiana tylko w `NOON_SIN_ELEVATION` (`tools/light_engine/start_values.gd`, oznaczona w komentarzu) → krzywa wysokości słońca w `day_curves.tres`. **Jeśli akcja w Skandynawii i realizm: przywrócić 0,26 i rozwiązać czytelność cieni inaczej.** Przy 15° kamienice kładły cień na całą ulicę przez cały dzień; przy 30° od ok. 10 pas słońca z prześwitu wchodzi na ulicę, 11–14 słońce na chodniku przy kamerze, 15–16 ulica w cieniu.
- **Przełącznik „Góra mapy: południe / północ”** (prośba człowieka: oglądać go przy kolejnych ticketach, decyzja na końcu w tickecie 28): w panelu silnika i w zrzucie (przełącznik „góra mapy”). Jedna reguła w Stanie doby: przy północy u góry kierunek słońca obraca się o 180° wokół pionu; Lokacje, kontrakt i shadery bez zmian. Kompas i opis strony słońca w F1 idą za orientacją. Przy północy u góry słońce świeci od strony kamery: fasady w słońcu, cienie chowają się za budynkami.
- **Testy:** `node tools/test.mjs` (ze `style-lab`): 73 zielone. Nowe: Opis sceny (10, headless), Bufor (6, GPU: obszar, bramka cienia rano i po południu, cień nie jest czarny, wierzch w słońcu a przód w cieniu w południe, widok Odbiorników), panel (widok debug), Poligon (prześwit 2 m, widok debug w F1, zrzucie i odtworzeniu). Test podłogi z ticketu 04 dostał Bryłę podłoża.
- Fasady na północ (do kamery) przy tym słońcu nie dostają słońca, tylko niebo i ambient, więc są ciemne. Jasność to strojenie (krytycy), niebo z zasłanianiem przyjdzie w tickecie 08.

- **Po przeglądzie, otwarte:** Opis sceny budowany raz przy starcie (przebudowa po zmianie węzła z podglądem w edytorze, ticket 15); brak ostrzeżenia, gdy obszar Bufora przekroczy limit tekstury; kolory widoku debug stałe w kodzie (tylko debug). 

## Jak sprawdzić (uzupełnienie)




`style-lab/street_engine.bat` (WASD / strzałki przesuwają kamerę), F1:
1. Godzina 10:00 → 14:00 (suwak powoli): pas słońca w prześwicie obraca się z prawego skosu (rano) na lewy (po południu); cień kamienic na chodniku przy kamerze cofa się do ok. 12 i znów wydłuża, zawsze po stronie przeciwnej niż słońce (słońce rano po lewej, po południu po prawej). Uskok w cieniu: niższa kamienica zachodnia rzuca krótszy cień niż środkowa. Cień jest niebieskawy, nie czarny.
2. 9:00 i 15:00–16:00: cała ulica w cieniu, słońce tylko na tle za prześwitem.
3. „Widok debug” → „Bryły”: różowe krawędzie leżą na kamienicach i podłożu.
4. „Widok debug” → „Odbiorniki”: przody kamienic pomarańczowe, podłoże i wierzchy niebieskie.
5. „Góra mapy” → „północ”, 10:00 i 14:00: słońce od strony kamery (kompas: N u góry, rano słońce po prawej), fasady w słońcu, cień w prześwicie pada w głąb ekranu.

### Ocena człowieka

2026-11-15: „wygląda ok” (Uliczka przy 30°, ruch kamery, przełącznik góry mapy).
