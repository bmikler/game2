---
id: 36
title: Przebudowa światła wnętrza na jeden bufor z cieniami
labels: [wayfinder:prototype]
status: open
assignee:
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
