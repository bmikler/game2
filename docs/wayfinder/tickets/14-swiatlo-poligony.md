---
id: 14
title: Światło w Poligonach: smugi, plama słońca, noc w mieście i poza nim
labels: [wayfinder:prototype]
status: open
assignee: claude
blocked_by: [11, 36]
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

Blokada: [Przebudowa światła wnętrza na jeden bufor z cieniami](36-przebudowa-swiatla-jeden-bufor.md) (model światła i cieni wnętrza, który idzie na ulicę). Do uwzględnienia przy ulicy uwagi inżyniera z `docs/research/80-ocena-oswietlenia-inzynier.md`: C (skala na ulicę: mapa wysokości, kafle, portale, pomiar w ms) i D (wiele postaci, test z 5 NPC).

## Zakres po tickecie 36 (2026-11-11)

Model światła wnętrza przyjęty ([36](36-przebudowa-swiatla-jeden-bufor.md)): jedna funkcja i jeden bufor, cień nieba dokładny, postać i meble jedną funkcją. **Najpierw ten sam model na ulicy** (nowe cienie postaci, budynków i obiektów od słońca, nieba, latarni i okien; człowiek chce sprawdzić, jak działają na ulicy, przed strojeniem). Ten ticket rozstrzyga techniki i poprawność na ulicy; **strojenie** (wartości, kolory, złota godzina) idzie do [Krytyka strojenia światła i cieni: wnętrze i ulica](38-krytyk-strojenia-swiatla.md), raz dla wnętrza i ulicy. Stylizacja pixel art: [37](37-stylizacja-cieni-pixel-art.md) (ten sam mechanizm na ulicy). Decyzja człowieka tutaj: zestaw technik światła na ulicy, nie strojenie.
