---
id: 15
title: Ozdoby atmosfery na Poligonach
labels: [wayfinder:prototype]
status: open
assignee:
blocked_by: [03, 10]
---

## Question

Które ozdoby z researchu Tanie ozdoby atmosfery w 2D wchodzą do gry i w jakiej technice? Prototyp jako przełączniki na Poligonach (para z ust, dym, wiatr w drzewach, odblaski szyb, TV nocą, śnieg i inne wybrane). Decyzja człowieka: lista ozdób i technika każdej.

**Dopisane (człowiek, 2026-11-09): żaluzje w niektórych oknach.** Spuszczone do połowy albo całkiem zasłonięte, przepuszczają tylko paski światła. Okna w dzień i w nocy liczy mapa światła z geometrii (ticket [Słońce okien liczone mapą światła na makiecie pokoju](31-dynamiczne-slonce-okien-prototyp.md), `SunGeometry`/`SunMap`), więc żaluzja to dane okna (wysokość spuszczenia, szczeliny między lamelami), a paski w plamie, smudze, kurzu i na postaci wychodzą z tego samego testu promienia co szprosy, bez ręcznego rysowania. Do sprawdzenia: czytelność pasków w 3/4 przy 40 px/m (lamela ok. 2–3 px), wygląd żaluzji od ulicy.


**Zrobione gdzie indziej:** kurz w smugach (świeci tylko w promieniu słońca, `sun_dust.gdshader`) w ticketcie [31](31-dynamiczne-slonce-okien-prototyp.md).
