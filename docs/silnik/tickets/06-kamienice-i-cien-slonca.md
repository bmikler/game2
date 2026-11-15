---
id: 06
title: Kamienice i cień słońca
labels: [ready-for-agent]
status: do sprawdzenia
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
- **Uliczka** (`engine_poligons/street/street.tscn`): Przesłona `Alley` z trzema kamienicami (front na d = −10, głębokość 10 m, wysokości 12 / 14 / 11 m), prześwit 2 m między zachodnią a środkową, plac 6 m za środkową. Albedo kamienic to zastępcze płaskie kolory Poligonu (`facades.gd`) do czasu sprite'ów. Kamera wyżej (y = −200 px), żeby było widać fasady.
- **Dlaczego plac 6 m:** przy lutowym słońcu (najwyżej ok. 15°) kamienice głębokie na 10 m kładą cień na całą ulicę przez cały dzień, a prześwit 2 m wpuszcza pas słońca tylko ok. 11–13 (wcześniej i później przesłania go ściana sąsiedniej kamienicy). Przez plac pas słońca sunie po ulicy mniej więcej od 10 do 14. To geometria, nie usterka; układ Uliczki do decyzji człowieka.
- **Testy:** `node tools/test.mjs` (ze `style-lab`): 73 zielone. Nowe: Opis sceny (10, headless), Bufor (6, GPU: obszar, bramka cienia rano i po południu, cień nie jest czarny, wierzch w słońcu a przód w cieniu w południe, widok Odbiorników), panel (widok debug), Poligon (prześwit 2 m, widok debug w F1, zrzucie i odtworzeniu). Test podłogi z ticketu 04 dostał Bryłę podłoża.
- Fasady na północ (do kamery) przy tym słońcu nie dostają słońca, tylko niebo i ambient, więc są ciemne. Jasność to strojenie (krytycy), niebo z zasłanianiem przyjdzie w tickecie 08.

- **Po przeglądzie, otwarte:** Opis sceny budowany raz przy starcie (przebudowa po zmianie węzła z podglądem w edytorze, ticket 15); brak ostrzeżenia, gdy obszar Bufora przekroczy limit tekstury; kolory widoku debug stałe w kodzie (tylko debug). Pierwotne „8:00 → 16:00” nie da się spełnić przy prześwicie 2 m i tym słońcu (patrz wyżej).

## Jak sprawdzić (uzupełnienie)

`style-lab/street_engine.bat`, F1: godzina 10:00 → 14:00 (pas słońca przez prześwit ok. 11–13, przez plac po prawej od ok. 10), „Widok debug”: „Bryły” (różowe krawędzie na kamienicach) i „Odbiorniki”.

