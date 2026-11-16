---
id: 09
title: Oświetlenie sprite'ów na Bryłach
labels: [ready-for-agent]
status: closed
assignee:
blocked_by: [07, 08]
---

## Co zbudować

Odbiorniki bryłowe w silniku według kontraktu poprawionego w „Poprawce kontraktu assetu”: piksel sprite'a leży na widocznej ścianie swojej Bryły (reguła dla pikseli bez ściany pod spodem z tamtego ticketu), normalna z mapy normalnych albo ze ściany Bryły, ten sam kod w obu przypadkach. Modelowanie, kontrświatło, wypełnienie z Zestawu strojenia. Sprite nie rzuca cienia. Na Uliczce skrzynia i ławka z prostymi sprite'ami.

## Kryteria akceptacji

- [x] Asset jako scena: sprite, Bryły, punkt zaczepienia, opcjonalnie mapa normalnych i przyczepione Źródła. (Przyczepione Źródła: dopiero gdy będą Źródła, ticket 13.)
- [x] Wczytanie Brył i punktu zaczepienia z eksportu „Prowadnic v2”.
- [x] Bramka: strona Bryły zwrócona do słońca jaśniejsza niż odwrócona; z mapą normalnych i bez.
- [x] Bryły assetu niewidoczne (tylko cień i zasłanianie); pozycja piksela z trafienia linii widzenia w Bryły (najbliżej kamery), głębia do zasłaniania z tego trafienia. (Punkt trafienia z głębią jest liczony; zasłanianie postaci użyje go w tickecie 17, dziś sprite'y kładzie kolejność od najdalszych.)
- [x] Reguła pikseli bez ściany Bryły pod spodem (spec, „Asset”): ponad wierzchem pionowa płaszczyzna w połowie głębokości wierzchu, reszta płaszczyzna przodu obrysu Brył; testy Opisu sceny albo rzutu.
- [x] Cienie własne z punktu odsuniętego 2 cm od ściany Bryły wzdłuż normalnej.
- [x] Normalne w kodowaniu Prowadnic v2 (128 + 127·(nx, nz, −ny)); ostrzeżenie walidacji, gdy mapa normalnych ma nieprzezroczysty piksel bez normalnej.
- [x] Parametry Odbiorników w Zestawie, punkty startowe z prototypu (normalne z mapy, modelowanie w pełnej sile jak w prototypie ticketu 02).

## Jak sprawdzić

Uliczka 9:00 i 15:00: skrzynia i ławka jaśniejsze od strony słońca, cień zgodny z obrazem, w cieniu kamienicy oświetlone niebem.

## Wykonanie (2026-11-16, Claude)

- **Asset jako scena:** węzeł kontraktu `AssetSprite` (`contract/asset_sprite.gd`, Sprite2D: sprite, opcjonalna mapa normalnych, punkt zaczepienia w px) jako dziecko Przesłony; Przesłona z `AssetSprite` jest assetem: jej Bryły rzucają cień i zasłaniają niebo, ale nie są Odbiornikami (kolor i światło bierze sprite). Sprite stawia punkt zaczepienia na całym pikselu najbliższym punktowi zaczepienia Przesłony (głębia 0,6 daje ułamki piksela). Przyczepione Źródła przyjdą z ticketem 13 (w kontrakcie nie ma jeszcze Źródeł).
- **Wczytanie z Prowadnic v2:** `contract/guides_import.gd` czyta `bryly.json` (typy `pudelko`, `uniesione`, `walec`; y eksportu w głąb → d silnika do kamery) i punkt zaczepienia `zaczepienie_gra`; `tools/light_engine/build_asset_scene.gd` zapisuje z tego scenę assetu `.tscn`. Skrypt Blendera dostał dwa meble testowe: `crate` (skrzynia, jedna Bryła) i `bench` (ławka: uniesione siedzisko, oparcie, dwie nogi).
- **Opis sceny:** lista assetów (od najdalszych) z zakresem ich Brył i płaszczyzną przodu obrysu; obszar Bufora obejmuje sprite'y.
- **Warstwa assetów** (`buffer/asset_layer.gd`): raz po zbudowaniu Opisu sceny sprite'y rysowane są do własnego viewportu: numer assetu i normalna z mapy w każdym nieprzezroczystym pikselu (dalsze najpierw, bliższy wygrywa). Bufor i warstwa nieba szukają powierzchni wspólną funkcją (`buffer/surfaces.gdshaderinc`): piksel sprite'a leży tam, gdzie jego linia widzenia opuszcza Bryły assetu najbliżej kamery (normalna ściany z tego trafienia); bez trafienia reguła ze specyfikacji (ponad wierzchem: pionowa płaszczyzna w połowie głębokości najwyższego takiego wierzchu; reszta: płaszczyzna przodu obrysu). Ta sama reguła w GDScript (`AssetEntry.rest_point`) do testów headless.
- **Cienie własne:** promienie słońca i nieba startują 2 cm od ściany Bryły wzdłuż jej normalnej (nie normalnej z mapy).
- **Zestaw strojenia, Odbiorniki:** `receiver_modelling` 1 (normalne z mapy w pełnej sile, jak w prototypie ticketu 02; 0 = normalna ściany Bryły), `receiver_rim` 0 (kontrświatło: słońce zza Bryły na krawędziach odwróconych od kamery, Bryły assetu go nie zasłaniają), `receiver_fill` 0 (wypełnienie: najmniejsze światło sprite'a jako udział ambientu i nieba otwartej ulicy). Kontrświatło i wypełnienie zostają na 0 do Wariantów krytyków (ticket 12). Zmiana modelowania przebudowuje warstwę nieba.
- **Walidacja:** ostrzeżenie konfiguracji `AssetSprite` (i ostrzeżenie silnika przy wczytaniu), gdy mapa normalnych ma inny rozmiar niż sprite albo nieprzezroczysty piksel bez normalnej (128, 128, 128).
- **Uliczka:** skrzynia (bez mapy normalnych) i ławka (z mapą normalnych z Blendera) na chodniku przy kamerze (x −2 i −7 m, d 3,5 m); proste sprite'y malowane z maski i normalnych (`tools/light_engine/paint_street_prop.gd`), pliki w `engine_poligons/street/props/`.
- **Poprawka przy okazji:** promień równoległy do osi (np. linia widzenia ma x = 0) dostaje zamiast zera bardzo małą składową; 1/0 nie jest na GPU pewną nieskończonością (linia widzenia przez to mijała Bryły). Na ulicy bez zmian co do piksela (porównane z `e5ba508` o 11:00 i 14:00).
- **Testy:** `node tools/test.mjs`: 122 zielone. Nowe: import z eksportu, miejsce assetu w Opisie sceny, reguła pikseli bez ściany (3 przypadki), dekodowanie normalnych i ostrzeżenia (headless); bramki GPU: strona zwrócona do słońca jaśniejsza bez mapy normalnych (walec rano z lewej, po południu z prawej) i z mapą (wierzch skrzyni), modelowanie 0 ignoruje mapę, wierzch dostaje pełne słońce i całe niebo (bez cienia od własnej Bryły), przód pół nieba, niewidoczne Bryły rzucają cień, przezroczyste piksele pokazują ziemię, w cieniu domu sprite dostaje niebo, kontrświatło i wypełnienie działają tylko na sprite'ach.

### Uwaga do „Jak sprawdzić”

O 9:00 i 15:00 (słońce w południe 30°, ustalone po napisaniu ticketu) kamienice cienią całą ulicę, więc meble świecą wtedy tylko niebem; słońce sięga chodnika przy kamerze ok. 10:30–14:30. Skrzynia (pudełko) pokazuje kamerze tylko wierzch i przód, a przód patrzy na północ: przy słońcu z południa wierzch jest jasny, przód w cieniu, lewa i prawa strona nie istnieją bez mapy normalnych. Siedzisko ławki leży w cieniu własnego oparcia (słońce zza oparcia), strona słońca widać na zaokrąglonych końcach desek z mapy normalnych.

## Jak sprawdzić (uzupełnienie)

`style-lab/street_engine.bat`, F1:
1. **11:00**, kamera w dół (strzałka w dół, aż chodnik przy kamerze będzie w kadrze): skrzynia z jasnym wierzchem i ciemnym przodem, cień skrzyni i ławki w prawo od słońca, prześwity między nogami ławki w cieniu; lewy koniec desek ławki jaśniejszy.
2. **14:00**: cień ławki w lewo, prawy koniec desek jaśniejszy; skrzynia w cieniu kamienicy, oświetlona niebem (nie czarna).
3. **9:00 i 15:00**: oba meble w cieniu kamienic, oświetlone niebem, z ciemniejszą obwódką na chodniku tuż przy nich (zasłaniają niebo).
4. „Widok debug” → „Odbiorniki”: piksele ławki w kolorach jej normalnych, skrzynia jednolicie (normalne ścian).

### Ocena człowieka

2026-11-16: „ok” (ławka i skrzynia dobrze oświetlone, cienie zgodne z obrazem).
