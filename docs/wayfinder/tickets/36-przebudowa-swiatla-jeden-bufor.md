---
id: 36
title: Przebudowa światła wnętrza na jeden bufor z cieniami
labels: [wayfinder:prototype]
status: open
assignee: claude
blocked_by: []
---

## Question

Czy czysto przebudowane światło wnętrza (jedna funkcja, jeden bufor) daje spójne, bezbłędne cienie postaci i mebli od każdego źródła, w stylistyce pixel art, z zachowaniem plam okien i smug z górnych okien? Architektura rozstrzygnięta w [Jeden model cienia dla postaci i obiektów](35-jeden-model-cienia.md) na podstawie `docs/research/81-spojne-cienie-architektura.md`.

**Zacznij od czystej sesji i czystej gałęzi od `main`.** Nie buduj na `t35-wersja2` (zapis nieudanych prób; można z niego czytać pomysły, np. tryb fizyki, suwaki tarczy słońca i żarówki, okno cienia na całą wysokość domu). Zasada człowieka: nie łatamy zepsutego podejścia, gdy nie idzie, krok wstecz i czysto.

Zakres (prototyp w `style-lab`, Poligon Dom, parter i piętro):
1. Jedna funkcja `light_at(punkt, normalna)` dla każdego źródła: słońce przez okna (ze szprosami), niebo przez szyby wszystkich ścian, drzwi wejściowe jako otwór, noc przez okna, lampy w pokojach. Jeden zestaw przesłon: architektura (ściany, nadproża, skorupa) i obiekty (meble, schody, postać jako walec), bez osobnych reguł dla postaci (reguły A4 odpadają).
2. Jeden bufor: dom liczony przy zmianie, okno wokół postaci przerysowywane co klatkę **w tej samej teksturze** (bez drugiej mapy i mieszania brzegów), obszar wpływu postaci z geometrii.
3. Postać jako odbiorca czyta ten sam bufor/funkcję (bez osobnego paska i `actor_mode`, chyba że research wskaże inaczej przy sprawdzeniu).
4. Wszystko świecące z bufora: **plamy okien** na podłodze jak dziś; **smugi z górnych okien** mają zachować feel i klimat z ticketu 27 (od szyby zwężają się w plamę; nie muszą być 1:1, człowiek), ale ich jasność wewnątrz z tej samej widoczności (postać i meble w smudze zostawiają cień); wstęgi okien bocznych i kurz tak samo; malowany języczek światła w drzwiach wejściowych, plamka pod stopami i inne nakładki rysowane na wierzchu podłogi znikają albo idą z bufora.
5. Miękkie cienie bez „palców”: analitycznie (rzut pudełka i walca na prostokąt szyby / tarczę słońca / żarówkę) albo próbki z ditherem Bayera; wielkość tarczy słońca i żarówki jako suwaki F1.
6. Wygląd pixel art (wymaganie człowieka): udział cienia osobno dla każdego źródła kwantyzowany do kilku poziomów z ditherem Bayera tym samym co w grze; bez rozmytych gradientów i losowego ziarna. Warianty w F1 (gładki / 3 poziomy z ditherem / 2 twarde).

Bramka jakości (Claude sprawdza sam, zanim pokaże człowiekowi):
- mebel i postać tej samej wielkości w tym samym miejscu rzucają ten sam cień;
- pudełko przed oknem / otworem drzwi ciemni każdy piksel, który dostałby jego światło (żadne światło nie przykrywa cienia);
- widok debug w F1: osobno słońce, niebo, lampy i udział cienia każdego źródła;
- scenki: postać tuż przy oknie każdej ściany, w drzwiach między pokojami, przy drzwiach wejściowych, przy lampie, wieczorne słońce, noc; cień przechodzi przez drzwi między pokojami;
- tryb „2 poziomy twarde” i porównanie z `main`: plamy bez przesłon takie same, smugi w tym samym klimacie;
- koszt `--bench`: ≥100 kl./s.

Decyzja człowieka: czy nowe światło przyjmujemy (wtedy idzie do Przepisu i na ulicę), oraz wygląd cieni (poziomy, dither) na tyle, na ile da się ocenić bez tekstur (ostateczne strojenie ambientu i cieni na makiecie z teksturami).

## Notatka dla następnej sesji (2026-11-10)

Gałąź `t36-jeden-bufor` (od `main`, commit po commicie). Stan: przebudowa zrobiona, człowiek testował na żywo i zgłaszał błędy; poprawione: opóźniony pasek cienia przy przedniej krawędzi, ręczne plamy lamp przez pierwszą minutę gry, cień nie przechodził przez przejścia, „palce” i odwrócony cień nieba pod oknem, twardy kawałek cienia na świetle przejścia.

Jak działa (kod):
- `lighting/light_fn.gdshaderinc`: jedna funkcja `light_parts(p, n, px, with_actor)`: słońce (próbki tarczy z obrotem Bayera), wstęgi okien bocznych (człon podłogi, prawdziwe promienie słońca), niebo każdej szyby i drzwi wejściowych (współczynnik kształtu × architektura próbkami 3×3 × obiekty analitycznie: rzut sylwetki pudełka / walca na płaszczyznę szyby), noc, lampy (próbki żarówki). Wygląd (`look`) kwantyzuje tylko udział obiektów (meble, schody, postać), osobno: słońce, każda szyba, każda lampa; architektura (ściany, nadproża, działówki: `box_arch`) zostaje gładka.
- `lighting/sun_geometry.gdshaderinc`: geometria i przesłony (`occlusion`, `arch_blocked`, walec postaci trzymany w skorupie).
- `lighting/light_map.gdshader` + `lighting/sun_map.gd` (`SunMap`): jeden bufor (SubViewport bez czyszczenia): cały dom przy zmianie, co klatkę okno wokół postaci liczone z geometrii (źródła zasłonięte ścianami pomijane, cień przycięty na pierwszej ścianie), pasek ciała postaci w tym samym buforze. `lit.gdshader` czyta jeden bufor.
- Smugi okien górnych: wielokąty t27 (`BeamCanvas`) z shaderem `sun_beam.gdshader` (widoczność na linii wzroku); kurz `sun_dust.gdshader` z tą samą widocznością. Usunięte: `sun_ribbon.gdshader`, stary `sun_map.gdshader`, poświata drzwi (`entrance_spill`), plamka pod stopami, presety A4, stare warianty F1.
- F1 (Poligon Dom): „Cienie: wygląd” (gładki / 3 poziomy z ditherem / 2 twarde), suwaki tarczy słońca i żarówki, „Widok debug (bufor)” (słońce, niebo, noc, lampy, udział cienia R/G/B), „Smugi okien górnych” (wielokąt / wolumetryczne), „Test cieni” (postać jako pudełko, pudełko w miejscu postaci, pudełko przed drzwiami, przed oknem). Ukryte (`--set=`): `liczenie` (okno / cały dom co klatkę), suwaki ambientu, ekspozycji, lamp, nocy, `postac_jasnosc`.

Narzędzia: `main.gd --path=x,d;x,d;…` (postać przechodzi punkty przed zrzutem), przy każdym zrzucie zapis surowego bufora `.bufor`; `node tools/pomiar/bufor_roznica.mjs a.bufor b.bufor 652` (bajt po bajcie); `--lights` wypisuje włączone światła 2D. Skrypt zrzutów sesji: zrzut + przeniesienie do `shots/t36/<katalog>/<nazwa>_<HHMM>.png`.

Poprawione później w tej sesji: postać oświetlona od kamery pod tylnym oknem. Współczynnik kształtu nieba liczony był z abs(), więc powierzchnia tyłem do szyby dostawała jej światło (przód postaci, przody mebli); teraz ze znakiem, a postać to walec widziany od kamery (normalna kolumny pikseli od przodu do boków), `actor_k` 1.

Też: niebo w wyglądzie progowane per okno (szybki razem); per szybka postać przed słupkiem okna dawała w trybie „2 twarde” jasny klin na wprost. Do oceny testera: w „2 twarde” meble rysują w innych pokojach słabe, twarde kliny (próg 50% światła każdego okna).

Bramka (sprawdzone): okno postaci = cały dom co klatkę, bajt w bajt, po przejściu przez wszystkie pokoje (9:30, 12:24, 15:30, 22:00); zamiana kształtu: postać jako pudełko = pudełko w miejscu postaci (bufor domu identyczny); pudełko przed drzwiami / oknem ciemni światło za sobą; koszt `--bench`: 106–183 kl./s z oknem (najgorzej w przejściu), cały dom co klatkę 101 kl./s. Niesprawdzone jeszcze: „2 poziomy twarde” vs `main` (plamy bez przesłon), smugi w tym samym klimacie, piętro (schody), wieczorne słońce we wstęgach bocznych, jasność postaci vs `main` (`actor_k` 1,5 na oko). Uwaga: przy 3 poziomach bardzo słaby cień jednej szyby (daleko od okna) znika zaokrąglony do zera.

Następna sesja (człowiek, 2026-11-10): **krytyk – tester gamedev** szuka błędów cieniowania: miejsca, gdzie cień zachowuje się niezgodnie z oczekiwaniem, go brak albo wygląda dziwnie. Proponowany zakres: każdy pokój parteru i piętra, postać przy oknie każdej ściany (tuż przy szybie i 1 m dalej), w każdym przejściu (lewo–prawo i góra–dół), przy drzwiach wejściowych, przy każdej lampie, za meblem, na schodach; godziny 9:30, 12:24 (pochmurno: samo niebo), 15:30, 16:30 (nisko, wstęgi), 22:00; trzy wyglądy; widoki debug do diagnozy; zrzuty zrobione przez człowieka w `shots/` (najnowsze). Raport: lista błędów z miejscem (x, d, godzina, wygląd), zrzutem i przypuszczalną przyczyną; naprawy dopiero po raporcie, każda z bramką (bajt w bajt, `--bench`).

**Zakres krytyka-testera (człowiek, 2026-11-10): tylko błędy w działaniu cieni** (cień w złym miejscu, brak cienia tam, gdzie powinien być, odwrócony, ucięty, przeskakujący, światło przykrywające cień, różnica postać / mebel, szwy przy ruchu). **Strojenie** (długość, gradient, miękkość, poziomy i dither, siła) idzie osobno, nie zgłaszać jako błąd. Znane i świadome: w „2 poziomach twardych” cień kończy się twardym łukiem (próg 50% zasłonięcia okna) i meble rysują słabe twarde kliny w innych pokojach; to strojenie wyglądu, nie błąd.
