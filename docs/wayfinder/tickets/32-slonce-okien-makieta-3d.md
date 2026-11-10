---
id: 32
title: Słońce okien z ukrytej makiety 3D
labels: [wayfinder:prototype]
status: closed
assignee:
blocked_by: [31]
---

## Question

Czy ukryta makieta 3D z prawdziwym słońcem i mgłą wolumetryczną daje na tyle lepszą smugę w powietrzu, że warta jest wyższego kosztu i ryzyka? Wariant 2 z researchu [Dynamiczne oświetlenie zamiast ręcznie strojonych smug: jak i za ile](30-dynamiczne-oswietlenie-research.md) (`docs/research/79-dynamiczne-oswietlenie.md` §2): niewidoczna scena 3D ze ścian z otworami i pudełek mebli, `DirectionalLight3D` + `FogVolume`, kamera ortogonalna pochylona o ok. 31° z korektą X 0,858 (rachunek, do sprawdzenia), wynik w `SubViewport` 960×540, posteryzowany i nałożony na 2D (MUL cień, ADD smuga). Wariant tańszy: tylko podłoga, kamera z góry, skalowanie y×0,60.

Na tej samej makiecie pokoju i danych `SunGeometry` co [Słońce okien liczone mapą światła na makiecie pokoju](31-dynamiczne-slonce-okien-prototyp.md), trzecia pozycja przełącznika F1. Mierzyć: smuga w powietrzu, migotanie i pływanie krawędzi cienia przy ruchu słońca, banding, czas klatki (z mgłą i bez), wymóg Forward+. Decyzja człowieka: czy makieta 3D zastępuje lub uzupełnia mapę światła.

## Resolution

Odrzucone bez prototypu (człowiek, 2026-11-10): mapa światła z ticketu [31](31-dynamiczne-slonce-okien-prototyp.md) i cienie z niej (ticket [33](33-cien-postaci-z-mapy.md)) wyglądają dobrze, więc ukrytej makiety 3D nie robimy.
