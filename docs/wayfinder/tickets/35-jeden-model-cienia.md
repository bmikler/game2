---
id: 35
title: Jeden model cienia dla postaci i obiektów
labels: [wayfinder:prototype]
status: open
assignee: claude
blocked_by: []
---

## Question

Jak ma wyglądać jeden wspólny model cienia, żeby postać i obiekty (meble, ściany działowe, schody) rzucały cień tak samo od każdego źródła (słońce, niebo z okien wszystkich ścian, lampy, noc)? Wymaganie człowieka z ticketu [Cień postaci z mapy światła](33-cien-postaci-z-mapy.md): „cienie postaci i obiektów muszą działać tak samo”; wygląd cieni: gładki albo 3 poziomy z ditherem (wybór na makiecie z teksturami).

Stan wyjścia (ticket 33, preset A4): postać ma osobne reguły (lampa liczona dalej ×1,4, długość ×1,6, słońce jako punkt 10 m, gradient przez miękkość, analityczne zasłanianie nieba, AO pod stopami, kwantyzacja z ditherem tylko dla postaci, okno cienia 320×320 odejmowane od map); meble zasłaniają niebo binarnie (4 promienie), słońce i lampy próbkami tarczy/żarówki, cień twardy i pikselowy. Do sprawdzenia w Poligonie Dom: jedna reguła dla wszystkich przesłon (np. minimalna efektywna wysokość źródła względem przesłony zamiast „lampa liczona dalej” tylko dla postaci; ten sam wzór zasłaniania szyby, analityczny albo binarny; ta sama kwantyzacja i dither); czy artystyczne odstępstwa A4 (krótszy, wolniej rozszerzający się cień) przenieść na meble, czy z nich zrezygnować. Przy okazji: cień nieba postaci na ścianie z oknem i ostry prostokąt na przodzie mebla za postacią (wygasić z wysokością), „kierunkowy cień nieba” od każdego okna (propozycja krytyka). Koszt: jedno okno cienia dla wszystkich ruchomych przesłon vs mapy liczone przy zmianie. Powiązane: uwaga H w [Uwagi inżyniera do oświetlenia](34-uwagi-inzyniera-oswietlenie.md) (capsule shadows, wiele postaci).

Decyzja człowieka: wspólny model cienia (reguła długości i rozszerzania, wzór nieba, miękkość, wygląd), który trafi do Przepisu i na ulicę.

## Stan (2026-11-10, prototyp gotowy do oceny)

Poligon Dom (`style-lab/dom.bat`), opis: README style-lab, sekcja „Prototyp jednego modelu cienia”. F1 „Cienie: model (postać i meble)”:

- **osobne (jak dotąd):** stan z ticketu 33 do porównania;
- **wspólny A4 (polecany, domyślny):** meble liczone tymi samymi regułami co postać: ta sama miękkość rosnąca z odległością od przesłony, lampa liczona dalej ×1,4 i dłuższy cień ×1,6, słońce jako punkt 10 m, zakotwiczone w stopie każdej przesłony; niebo: każdy mebel zasłania szybę analitycznie jak postać (zamiast 4 promieni), te same suwaki nieba; ten sam wygląd (3 poziomy z ditherem) dla mebli i postaci;
- **wspólny fizyczny:** to samo bez odstępstw A4 (lampa i słońce takie, jakie są).

Ściany działowe, schody i bloki podniesione zostają twarde (architektura). Przy okazji: cień nieba gaśnie z wysokością (0,5→1,5 m: koniec ostrego prostokąta na przodzie łóżka), przesłona nie cieniuje własnej ściany. Koszt: wspólny 269 / 238 kl./s (9:30 / 22:00), osobne 287 / 258; przeliczenie domu przy zmianie ok. 13 ms. Zrzuty `style-lab/shots/t35/` (`arkusz.png`, `s_a_*`, `s_b_*`: kolumny osobne / A4 / fizyczny).

Niezrobione: „kierunkowy cień nieba” od każdego okna (propozycja krytyka), wiele postaci (uwaga H w ticket 34; jedno okno cienia).

Do decyzji człowieka na żywo: który model (A4 czy fizyczny) i czy wspólny wygląd mebli (miękki z ditherem zamiast twardego pikselowego) się podoba.

**Ocena człowieka (2026-11-10):** wspólny model zbugowany, dobrze widać to w wyglądzie „2 poziomy twarde”: czarne plamy pod łóżkiem, przy lampach i drzwiach, poszarpany cień postaci (`style-lab/shots/t35/z_h.png`, lewa kolumna osobne, prawa wspólny A4). Przyczyna: wygląd kwantyzuje jeden udział „zabranego światła” liczony razem dla słońca, lamp i nieba, więc szeroki, miękki cień nieba powyżej 50% robi się czarny; do tego osobne przybliżenia dla mebli (prostokąty kątowe, kotwice A4). Domyślnie wrócił model **osobne** (stan z ticketu 33). Pytanie człowieka: czy cień nie powinien wychodzić wprost z mapy światła? Następny krok: postać jako zwykła przesłona w mapie, ta sama ścieżka co meble.
