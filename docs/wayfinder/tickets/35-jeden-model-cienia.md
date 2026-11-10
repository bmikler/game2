---
id: 35
title: Jeden model cienia dla postaci i obiektów
labels: [wayfinder:prototype]
status: open
assignee:
blocked_by: []
---

## Question

Jak ma wyglądać jeden wspólny model cienia, żeby postać i obiekty (meble, ściany działowe, schody) rzucały cień tak samo od każdego źródła (słońce, niebo z okien wszystkich ścian, lampy, noc)? Wymaganie człowieka z ticketu [Cień postaci z mapy światła](33-cien-postaci-z-mapy.md): „cienie postaci i obiektów muszą działać tak samo”; wygląd cieni: gładki albo 3 poziomy z ditherem (wybór na makiecie z teksturami).

Stan wyjścia (ticket 33, preset A4): postać ma osobne reguły (lampa liczona dalej ×1,4, długość ×1,6, słońce jako punkt 10 m, gradient przez miękkość, analityczne zasłanianie nieba, AO pod stopami, kwantyzacja z ditherem tylko dla postaci, okno cienia 320×320 odejmowane od map); meble zasłaniają niebo binarnie (4 promienie), słońce i lampy próbkami tarczy/żarówki, cień twardy i pikselowy. Do sprawdzenia w Poligonie Dom: jedna reguła dla wszystkich przesłon (np. minimalna efektywna wysokość źródła względem przesłony zamiast „lampa liczona dalej” tylko dla postaci; ten sam wzór zasłaniania szyby, analityczny albo binarny; ta sama kwantyzacja i dither); czy artystyczne odstępstwa A4 (krótszy, wolniej rozszerzający się cień) przenieść na meble, czy z nich zrezygnować. Przy okazji: cień nieba postaci na ścianie z oknem i ostry prostokąt na przodzie mebla za postacią (wygasić z wysokością), „kierunkowy cień nieba” od każdego okna (propozycja krytyka). Koszt: jedno okno cienia dla wszystkich ruchomych przesłon vs mapy liczone przy zmianie. Powiązane: uwaga H w [Uwagi inżyniera do oświetlenia](34-uwagi-inzyniera-oswietlenie.md) (capsule shadows, wiele postaci).

Decyzja człowieka: wspólny model cienia (reguła długości i rozszerzania, wzór nieba, miękkość, wygląd), który trafi do Przepisu i na ulicę.

