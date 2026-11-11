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

## Raport krytyka-testera (2026-11-10)

Zrzuty i arkusze: `style-lab/shots/t36/krytyk/` (`arkusz_<miejsce>.png`: góra zwykły widok, dół udział cienia; kolumny 9:30, 12:24, 15:30, 16:30, 22:00; `p_` parter, `u_` piętro, `w_` trzy wyglądy, `e_` przypadki brzegowe). Sprawdzone: każdy pokój parteru i piętra, okno każdej ściany (tuż przy szybie i 1 m dalej), przejścia boczne i drzwi w ściance działowej, drzwi wejściowe, każda lampa, za meblem, smugi z postacią w środku, trzy wyglądy, ruch (okno vs cały dom po spacerze przez pokoje o 16:30 i 22:00).

**Błąd 1 (potwierdzony, przyczyna znaleziona): pionowa kreska cienia nieba nad głową postaci przy oknie tylnym.** Miejsce: salon (2,5; 0,5), korytarz parter (7,75; 0,5), korytarz piętro (7,75; 0,5); każda godzina, każdy wygląd. Ok. 4 px szerokości, od wierzchu ściany do głowy, także na ramie okna (`z_glowa_a.png` vs `z_glowa_b.png`, `z_kol_niebo.png`). Nie ma jej w testach „postać jako pudełko” i „pudełko w miejscu postaci”. Przyczyna: `objects_hide()` (`light_fn.gdshaderinc`) zwraca 1 („wewnątrz ciała”), gdy `dist <= r` w rzucie, bez sprawdzenia wysokości punktu; środek walca jest dociśnięty do `d = r` od tylnej ściany (`sun_map.gd`, `_actor_middle`), więc punkty ściany tuż za postacią mają `dist ≤ r` na całej wysokości. Proponowana naprawa: „wewnątrz” tylko dla `o.z <= wysokość postaci`, wyżej `continue`.

**Błąd 1, ten sam mechanizm na meblach:** postać tuż przed sofą (2,5; 5,33): walec (środek r za stopami) wchodzi w sofę, na froncie sofy za postacią pionowy pas pełnego cienia nieba (`arkusz_e_przed_sofa.png`, widok udziału cienia); na ekranie prawie cały zakryty sprite'em. Naprawa jak wyżej powinna objąć też ten przypadek (sprawdzić po naprawie: przód sofy, blat kuchni `arkusz_e_przed_blat`, wysoka szafka na piętrze `arkusz_e_szafka_g`).

**Do sprawdzenia (niepewne, raczej nie cienie):** postać ustawiona `--at` w jadalni tuż przed ścianką działową (11,5 / 14,5; d 3,78–3,95) znika z kadru między zrzutami tej samej serii (o 9:30 widoczna, o 12:24 już nie; brak też jej cienia w buforze), a o d 3,85 i 4,1 jest. Wygląda na wypchnięcie przez kolizję w grubość ścianki (ścianka nie chowa się, postać zasłonięta); nie sprawdzone, czy da się tam dojść chodząc. Przeciek cienia przez ściankę do kuchni przez to nieoceniony. Nieobejrzane: `arkusz_e_przed_blat`, `arkusz_e_szafa_pok`.

**Nie błędy (sprawdzone):**
- Kliny cienia postaci w przejściach na podłodze sąsiedniego pokoju: niebo z okien sąsiedniego pokoju przez przejście (`sky_other_k = 1`), zgodne z zamierzeniem.
- Front blatu kuchni w widoku udziału cienia na czerwono/niebiesko: samocień ściany odwróconej od słońca liczony jako udział obiektu; w świetle bez skutku (Lambert 0). Kosmetyka widoku debug.
- Ruch: okno wokół postaci = cały dom co klatkę bajt w bajt po spacerze (16:30, 22:00). Pozorna różnica 18 706 px pochodziła z trybu „cały dom” różniącego się między uruchomieniami (animacja chowania ścianki działowej 0,2 s łapana w innej fazie). Do metody: przed zrzutem po przejściu kuchnia → jadalnia czekać ≥ 0,2 s.
- Lampa sufitowa nad głową daje duży okrągły cień wokół stóp; fizycznie poprawne (strojenie kształtu).
- Widok „udział cienia” nie pokazuje lamp (tylko R/G/B: słońce, niebo, noc); cienie lamp sprawdzane widokiem „tylko lampy” z różnicą.
- „2 twarde”: twarde łuki i kliny na ścianach (znane, strojenie).

### Ciąg dalszy (2026-11-11), gałąź `t36-krytyk-naprawy`

- **Błąd 1 naprawiony** (`light_fn.gdshaderinc`, `objects_hide`): „wewnątrz ciała” tylko dla punktów nie wyżej niż postać, wyżej walec pomijany. Kolumna nad głową przy oknie tylnym znika (`z_fix.png`). Pas na froncie sofy i blatu za stopami zostaje: to punkty poniżej wysokości postaci w miejscu, które walec zajmuje (środek r za stopami), zakryte sylwetką; nie poprawiam.
- Bramka: `--bench` 191 kl./s (9:30), 205 (22:00). Okno vs cały dom po spacerze: 182 lub 2822 px różnicy (zależnie od uruchomienia), **tak samo przed naprawą i po niej**.
- **Uwaga 2 (drobna, nienaprawiana):** okno wokół postaci pomija bardzo słaby cień nieba sięgający przez dwa przejścia (postać w jadalni, przód salonu: niebo z okien jadalni przez przejścia, `sky_other_k = 1`). Różnica ≤ 0,009 przy świetle ok. 0,3 (≤ 3%), bez przeskoku poziomów; ślad zostaje po odejściu postaci. Do decyzji człowieka: akceptować albo poszerzyć okno o przejścia.
- **Postać „znikająca” przy ściance działowej to artefakt testu:** `--at` w jadalni na d 3,78–3,95 wstawia stopy w kolizję; postać zostaje wypchnięta do d ≈ 3,67 (w grubość ścianki, zasłonięta). Chodząc nie da się tam stanąć, przeciek cienia do kuchni nieosiągalny. Przy okazji (poza zakresem cieni): kolizja krawędzi kuchni ma 1 m grubości i wchodzi w jadalnię, warto sprawdzić, czy pas jadalni tuż przy ściance jest dostępny.
- Obejrzane: `arkusz_e_przed_blat` (ten sam pas na froncie blatu, zakryty), `arkusz_e_szafa_pok` (bez uwag).
- **Uwaga 2 naprawiona** (`sun_map.gd`, `_actor_window`): okno przeliczane co klatkę wokół postaci było za małe, gdy cień postaci przechodził przez przejście (promienie z narożników walca kończyły się na ścianie obok przejścia, środek cienia szedł dalej); poza oknem zostawał stary bufor. Teraz ściany są grupowane w płaszczyzny z przejściami (`WallPlane`), a gdy ślad cienia na płaszczyźnie zachodzi na przejście, promienie idą przez tę ścianę (do 3 ścian w głąb). Źródła nieba: narożniki całych okien zamiast każdej szybki; płaszczyzny liczone tylko przy zmianie ścian; liczenie przerywane, gdy okno obejmuje już cały dom.
- Bramka po naprawie: okno = cały dom co klatkę **bajt w bajt** (parter: spacer przez wszystkie przejścia o 9:30, 12:24, 16:30, 22:00; kuchnia z czekaniem na animację ścianki; piętro 9:30, 22:00). Koszt `--bench`: przy oknach 198–230 kl./s; w przejściach, przy drzwiach wejściowych i w jadalni 77–103 kl./s, bo okno obejmuje tam prawie cały dom (cień nieba sięga przez dwa przejścia); cały dom co klatkę w tym samym miejscu 82–84 kl./s. Próg ≥100 kl./s nie jest spełniony w tych miejscach: do decyzji człowieka.
- Metoda: przy porównaniu bajt w bajt po wejściu do kuchni lub wyjściu z niej czekać ≥ 0,2 s (animacja ścianki), inaczej tryby różnią się fazą animacji.
- **Decyzja człowieka (2026-11-11):** wydajność optymalizujemy przy tworzeniu gry, nie na Poligonach (tu ustalamy wygląd grafiki). Próg ≥100 kl./s nie blokuje; 77–103 kl./s w przejściach przyjęte.
