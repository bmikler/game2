---
id: 26
title: Jak ładnie pokazać przekrój domu wiszący w czerni
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Na Poligonie Dom w bryłach wnętrze bez zewnętrznych ramek wisi w czerni (decyzja człowieka). Dół i boki pokojów przechodzą w czerń prostą winietą (pasy czarnego gradientu ok. 28 px). Człowiek ocenił to jako fatalne i przypomniał, że This War of Mine miał ładne przejścia w czerń (inny rzut: przekrój z boku). Jak gry 2D i 2,5D z przekrojem budynku albo pokojami na czarnym tle (This War of Mine, Fallout Shelter, Sheltered, Unpacking, Gemini Rue, Kentucky Route Zero, Stardew, Graveyard Keeper, Eastward i inne) kończą pokój na dole i po bokach? Interesują nas: linia przekroju (ściana, strop, gruz), mgła, szum, dithering w pixel arcie, ciemnienie od światła (pokój gaśnie, bo światło nie dochodzi, a nie przez czarny pas), kształt krawędzi, co dzieje się z podłogą, ścianami między pokojami i drzwiami na krawędzi. Wynik: katalog technik z grami i źródłami, koszt w naszym Godot (shader, tekstura, światło) w rzucie niskie 3/4 (głębia × 0,60, 40 px/m, kadr 960×540) i 2–3 warianty do prototypu na Poligonie Dom. Notatka w `docs/research/78-przejscie-w-czern.md`.

Kontekst: `docs/grafika.md` (sekcja „Bez zewnętrznych ramek”), `docs/research/43-sciany-wnetrz-3-4.md`, prototyp `style-lab/poligony/dom_bryly.gd` (`_fade_bottom`, `_fade_side`).

## Resolution

Notatka: [`docs/research/78-przejscie-w-czern.md`](../../research/78-przejscie-w-czern.md).
- Gry z przekrojem (This War of Mine, Sheltered, KRZ) nie używają gładkiego czarnego gradientu. Kończą pokój twardą, nieregularną linią cięcia (czoło płyty, słup ściany, rwany brzeg), a dalej jest płaska czerń. Miękkość robi światło, nie pas alfa (zweryfikowane na zrzutach Steam, brak talków twórców o samej technice).
- Warianty do prototypu: A „płyta w przekroju” (czoło 7 px, słup boczny 6 px, rwany brzeg), B „gaśnie od światła” z ditheringiem Bayer 4×4 (32–40 px, 8 poziomów), C „poszarpana mgła” (próg z szumem, 40–48 px). Zalecana kolejność A, B, potem A+B.
- Podejrzenie do sprawdzenia: obecne pasy alfa są rysowane w liniowym HDR przed konwersją sRGB, co psuje krzywą.
- Nie zweryfikowano: Fallout Shelter, Gemini Rue, Unpacking, Eastward; źródeł pierwotnych 11 bit o krawędziach.
