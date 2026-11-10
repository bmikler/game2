---
id: 14
title: Światło w Poligonach: smugi, plama słońca, noc w mieście i poza nim
labels: [wayfinder:prototype]
status: open
assignee:
blocked_by: [11, 34]
---

## Question

Jakie światło daje najlepszy klimat w nowym rzucie i skali? Na Poligonach przenieść i poeksperymentować: smugi z okien, drobinki kurzu, plama słońca na podłodze z meblami (pomysły z `docs/grafika.md`, „Plama światła a meble”), kolory za oknem, nocne światło przez okno w mieście (latarnie) vs poza miastem, oświetlenie fasad i śniegu nocą. Kolory z `docs/swiatlo-kolory-game1.md` jako start. Decyzja człowieka: zestaw technik światła i ich strojenie.

Z Wyboru Kotwic stylu: smugi i ciepłe punkty z bloomem jak w REPLACED, kolor jak NORCO; zasada temperatury: baza chłodna, zimowa, ciepło tylko przy źródłach. Referencje: Disco Elysium (paleta zimy), Kentucky Route Zero (małe ciepłe źródło w wielkiej ciemności).

## Zakres po ticketach 27, 31, 33 (2026-11-10)

Wnętrze jest rozstrzygnięte: światło okien, drzwi, lamp i kurz w smudze liczy mapa (ticket [31](31-dynamiczne-slonce-okien-prototyp.md)), orientacja: południe na górze (ticket [27](27-swiatlo-okien-orientacja.md)), cień postaci (ticket [33](33-cien-postaci-z-mapy.md)). Ten ticket zostaje dla **ulicy i zgodności z wnętrzem**:

- światło na Poligonie Ulica (`ulica_bryly`) zgodne z wnętrzem: kierunek słońca (fasady w słońcu lub w cieniu), okna widziane z ulicy w dzień i w nocy, przejście drzwiami (ADR 0007 z game1: stała ekspozycja na przestrzeń);
- zasłanianie nieba przez sąsiednie budynki (różnica między oknami w tej samej ścianie);
- latarnie, noc w mieście i poza nim, oświetlenie fasad i śniegu nocą, kolory za oknem;
- pomysły ze stanu ticketu 27 (do oceny, nie decyzje): bez cieni budynków albo tylko jako wariant, błysk w co trzecim oknie, poświata zapalonych okien na śniegu, ciepła krawędź śniegu na dachach i parapetach przy fasadach w cieniu; pytanie człowieka: czy smugi słońca wpadające do okna pokazać na zewnątrz, czy tylko kolor;
- cień postaci na ulicy wzorem z ticketu [35](35-jeden-model-cienia.md).

Blokada: [Uwagi inżyniera do oświetlenia](34-uwagi-inzyniera-oswietlenie.md), punkt C (jak mapa skaluje się na ulicę: mapa wysokości, kafle, portale) i D (wiele postaci).
