---
id: 11
title: Poligon Dom w bryłach: zgodność wnętrza z fasadą
labels: [wayfinder:prototype]
status: closed
assignee: claude
blocked_by: [10]
---

## Question

Zbudować Poligon Dom (wnętrze domu z Poligonu Ulica: parter z salonem, kuchnią, korytarzem i schodami; piętro tylko, jeśli potrzebne do testu okien) w bryłach i sprawdzić zgodność z fasadą: liczba, kolejność i świecenie okien, drzwi, skala „większy w środku”, widok za oknem zgodny z ulicą (placeholder). Warianty: ściany z zewnętrznymi ramkami i bez, okna boczne/dolne S0/S1/K (`53`). Decyzja człowieka: reguły zgodności wnętrze–fasada oraz wariant ścian i okien.

**Z Rzutu, skali i rozdzielczości:** ściany wnętrz 2,2 m, drzwi 1,85 m z nadprożem, okno: parapet 1/3 ściany, góra 0,25 m pod sufitem; ściany działowe chowane (pełne, obniżane, gdy gracz jest za nimi; światło jak przy pełnej ścianie); czerń wokół pokojów węższych niż kadr 960×540. Punkt startu: `style-lab/poligony/rzut_dom` (dwa pokoje, ściana działowa z przejściem, warianty).

**Z Poligonu Ulica w bryłach (2026-11-09):** budynki na zewnątrz mają 50% prawdziwej głębi (zwężone w głąb), a do tego są mniejsze niż mapa wnętrza; tu ustalić, jak wnętrze ma się do tak ściśniętej fasady (szerokość, głębia, okna, drzwi). Nie do każdego budynku da się wejść.

## Notatki z oceny (2026-11-09)

Prototyp: `style-lab/poligony/dom_bryly.gd` (`dom_parter.tscn`, `dom_pietro.tscn`, `style-lab/dom.bat`), README style-lab.

- Zdecydowane: dom **bez zewnętrznych ramek**, wisi w czerni; okna w ścianach dolnych i bocznych **nie są rysowane**, zdradza je tylko światło; drzwi na ulicę to języczek z progiem, wycieraczką i światłem z zewnątrz; dom piętrowy z zewnątrz ma w środku schody i dwie kondygnacje; potrzebny pokój za pokojem (przejście góra–dół przez drzwi w ścianie działowej, chowanej, gdy gracz jest za nią).
- Do poprawy po ocenie: przejście w czerń (gradient fatalny) → research [Jak ładnie pokazać przekrój domu wiszący w czerni](26-przejscie-w-czern-research.md), warianty A/B/A+B/C w F1 „Brzeg w czerń”; ściana działowa góra–dół węższa (0,1 m, lico oświetlone w całości); przejścia lewo–prawo wyraźniej (podłoga przez przerwę w wierzchu, skrzydło drzwi pod ścianą, 43 §3); korytarz za ciemny → schody wzdłuż lewej ściany w głąb i okno w tylnej ścianie korytarza.
- Wydzielone: światło okien i orientacja mapy → [Światło okien ze wszystkich ścian i orientacja mapy](27-swiatlo-okien-orientacja.md).
- Wydzielone: schody w domu działają słabo → [Schody w pomieszczeniach i wejście na piętro](28-schody-w-pomieszczeniach.md). Tu zostaje tylko zasada: dom piętrowy z zewnątrz ma w środku schody i dwie kondygnacje.

## Resolution

Prototyp: `style-lab/poligony/dom_bryly.gd` (`style-lab/dom.bat`, parter i piętro), README style-lab, sekcja „Prototyp Poligonu Dom w bryłach”.

- **Ściany:** dom bez zewnętrznych ramek, wisi w czerni; tylna ściana z licem i listwą, ściany boczne i dolna niewidoczne (decyzja człowieka). Jak ładnie zakończyć brzeg: żaden wariant nie przeszedł (gradient, płyta, dithering wyglądają jak pikseloza) → [Brzeg domu w czerni](29-brzeg-domu-w-czerni.md).
- **Zgodność wnętrza z fasadą:** kolumny okien fasady = kolumny pomieszczeń, w tej samej kolejności, na każdej kondygnacji; okno świeci nocą na fasadzie, gdy w pomieszczeniu za nim pali się lampa (jedno źródło: `DomBryly.lamps`); drzwi wejściowe w tym samym miejscu co na fasadzie; dom piętrowy z zewnątrz ma w środku schody i dwie kondygnacje.
- **Układ wnętrza:** pokój za pokojem przez drzwi w chowanej ścianie działowej (0,1 m, obniża się, gdy gracz jest za nią); przejście lewo–prawo to przerwa w wierzchu ściany, przez którą biegnie podłoga, ze skrzydłem drzwi pod ścianą (43 §3); drzwi na ulicę: języczek, próg, wycieraczka, chłodne światło z zewnątrz.
- **Poza mapą (do gry):** ile razy wnętrze jest większe od fasady i jaka głębia: dobierane przy budowie konkretnych budynków i mapy miasta (Poligon roboczo 1,5× i 8 m).
- **Wydzielone:** okna i orientacja mapy → [Światło okien ze wszystkich ścian i orientacja mapy](27-swiatlo-okien-orientacja.md); schody → [Schody w pomieszczeniach i wejście na piętro](28-schody-w-pomieszczeniach.md). Widok z tylnego okna (tył działki czy ulica) to niuans, zostaje w mgle „Widok za oknem”.
- Zmiany we wspólnym kodzie style-lab: `RoomBox` (przejścia w ścianach bocznych, ściany zewnętrzne do wyłączenia), `RzutPoligon._character_options()`, `LightingDirector.top_azimuth_deg`, bramka słońca w `WindowLight`, `SideWindowLight` (`panes`, `beam_k`, `patch`); `ulica_bryly` prowadzi do `dom_parter` i zapala okna domu według lamp.
