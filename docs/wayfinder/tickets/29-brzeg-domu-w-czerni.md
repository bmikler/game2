---
id: 29
title: Brzeg domu w czerni
labels: [wayfinder:prototype]
status: open
assignee:
blocked_by: [27, 35, 36]
---

## Question

Jak zakończyć dół i boki domu bez ramek, wiszącego w czerni, żeby wyglądało ładnie (człowiek pamięta This War of Mine)? Na Poligonie Dom (F1 „Brzeg w czerń”) żaden wariant nie przeszedł: gradient pasami alfa „fatalny”, A płyta w przekroju, B i C dithering Bayer „straszna pikseloza” (ocena człowieka 2026-11-09). Research [Jak ładnie pokazać przekrój domu wiszący w czerni](26-przejscie-w-czern-research.md) wskazał, że w This War of Mine miękkość daje niedoświetlenie (światło nie dochodzi do brzegu), a nie nakładka; to nie było jeszcze sprawdzone. Kierunek: brzeg gaśnie przez światło pokoju (zasięg ambientu i lamp, ekspozycja), gładko, bez ditheringu i bez czarnych pasów rysowanych na wierzchu; do sprawdzenia też podejrzenie z researchu, że nakładki alfa psuje konwersja HDR → sRGB w `display.gdshader`. Decyzja człowieka: jak dom kończy się w czerni.

Po ticketcie [Światło okien ze wszystkich ścian i orientacja mapy](27-swiatlo-okien-orientacja.md), bo brzeg zależy od tego, jak pokój jest oświetlony. Kod: `_fade_bottom`, `_fade_side`, `_slab`, `_dither` w `style-lab/poligony/dom_bryly.gd`; ambient w `style-lab/lighting/room_lighting.gd`.

Blokada (człowiek, 2026-11-10): także po [Jeden model cienia dla postaci i obiektów](35-jeden-model-cienia.md), realizowanym w [Przebudowa światła wnętrza na jeden bufor z cieniami](36-przebudowa-swiatla-jeden-bufor.md) — najpierw jeden rodzaj cieni (gładki albo z ditherem) dla postaci i obiektów; światło pokoju: zestaw krytyka C „Pośredni”, lampy z mapy.
