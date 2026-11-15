---
title: Silnik światła i cieni game2
labels: [wayfinder:map]
---

<!-- SZKIC przygotowany 2026-11-15 na koniec sesji ticketu 14 mapy grafiki. Mapy jeszcze nie rozrysowano:
następna sesja zaczyna od „Chart the map” (grilling celu z człowiekiem), poprawia Destination i Notes,
dopiero potem tworzy tickety w tickets/. -->

## Destination

(Szkic, do potwierdzenia w grillingu.) Jeden silnik światła i cieni, który działa automatycznie w każdej scenie gry: wnętrza, ulica, kolejne lokacje. Ten sam kod i ta sama stylizacja pixel art wszędzie, bez kodu i przełączników pod konkretną scenę. Wynik:

- specyfikacja (kontrakt danych sceny, model źródeł i cieni, zasady przeliczania bufora);
- zaimplementowany moduł z testami;
- Poligon Dom i Poligon Ulica jako jego pierwsi użytkownicy, zbudowani jako sceny w edytorze Godota.

## Notes

- Pracujemy **po polsku**. Słownik: `GLOSSARY.md`. Tracker jak w mapie grafiki (`docs/wayfinder/map.md`, Notes: local markdown, `tickets/NN-*.md`, frontmatter `labels`, `status`, `assignee`, `blocked_by`). Numeracja ticketów tej mapy od 01.
- **Skąd ta mapa:** w mapie grafiki silnik powstawał jako prototyp do oceny wyglądu i był przebudowywany kilka razy (tickety 31, 33, 35, 36, 14). Za każdym razem coś było popsute. Dom (`SunMap`, `light_fn`) i ulica (`StreetMap`, `street_fn`) to dwie równoległe kopie z różnymi zasadami: przeliczanie bufora, świat bufora, półcień słońca (`sun_pen_max` tylko na ulicy), zasłanianie nieba (`sky_objects` tylko na ulicy), okno postaci liczone z inną godziną niż reszta bufora. Poprawka w jednej kopii psuła albo omijała drugą. Stan wyjściowy: gałąź `t14-ulica-swiatlo`, commit `135ec42`; opis w `style-lab/README.md` i w tickecie 14 mapy grafiki.
- **Zasady człowieka (twarde):**
  - jeden silnik, jedna stylizacja dla wnętrz i pleneru;
  - bez ifów i bez specjalnej obsługi pojedynczych przypadków; działa przez konstrukcję;
  - gdy poprawki się piętrzą, stop i przemyślenie modelu (pamięć: no-special-case-patches, shadows-pixel-art-clean-rebuild).
- **Już ustalone w mapie grafiki (wejście, nie do ponownego otwierania bez powodu):**
  - jedna funkcja światła i jeden bufor, postać i meble jedną funkcją cienia, cień nieba z okien dokładny (36);
  - całe światło okien z geometrii, bez strojenia okien; okna boczne tylko wstęgi (27, 31);
  - rzut 0,60, 40 px/m (09);
  - stylizacja: kierunek A′ (szew ditheru o stałej szerokości w px, kotwica `Y_ref`), research `docs/research/84-stylizacja-swiatla-plener-opus.md` (oraz 82, 83);
  - strojenie kolorów i wartości poza tą mapą: ticket 38 mapy grafiki.
- **Pomysł człowieka do grillingu:** budować w Godocie jako sceny widoczne w edytorze, a nie wszystko kodem. Przesłony, otwory (okna, drzwi) i źródła światła byłyby węzłami (`@tool`, z podglądem w edytorze), które scena układa, a silnik czyta. Dziś Poligony budują się kodem (`dom_bryly.gd`, `ulica_bryly.gd`). Do rozstrzygnięcia: które dane w scenie, a które wyliczane; podgląd światła w edytorze.
- **Testy:** implementacja test-first (skill „tdd”; brak skilla `/implement`). Kandydaci: GUT lub gdUnit4 (addon do dodania za zgodą człowieka) do logiki w GDScript; bramki buforów (`style-lab/tools/pomiar/bufor_roznica.mjs`, `bufor_ulica_roznica.mjs`: różnica pikseli w ustalonych punktach) jako testy regresji shaderów; benchmark `--bench=godzina [--ruch]`.
- **Research na Opusie** (subagent z `model: opus`; domyślny model subagentów w ustawieniach to Sonnet). Wyniki w `docs/research/` od numeru 85.
- Godot 4.7.2: `C:/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64.exe` (konsolowy: `..._console.exe`). Skille: grilling → „grilling” + „domain-modeling”; research → „research”; prototype → „prototype”; implementacja → „tdd”.
- Git: osobna gałąź na każdą próbę (pamięć: git-and-hard-look-check); commit tylko na prośbę człowieka.

## Decisions so far

<!-- jedna linia na zamknięty ticket -->

## Not yet specified

- **Cel i granice mapy:** czy silnik od razu jako kod gry (poza `style-lab/`), czy jako moduł w `style-lab/` przenoszony później; co z Poligonami (przebudowa jako sceny edytora).
- **Kontrakt danych sceny:** przesłony (pudełka, dachy, walce, pusty dół), otwory (okna, drzwi), źródła (słońce, niebo, lampy, latarnie, świecące okna), odbiorniki; węzły w edytorze czy dane wyliczane.
- **Jeden model nieba:** pod gołym niebem i przez okna jednym sposobem (dziś dom liczy niebo przez szyby, ulica jako całe niebo minus ściany brył).
- **Jeden model słońca i półcienia** (dziś półcień zawężany przy przesłonie tylko na ulicy).
- **Bufor i przeliczanie:** jedno ujęcie stanu światła dla całego bufora, okno wokół postaci, pasy, rozdzielczość względem sprite'ów (×1–×3), skala dużych map (kafle?), koszt w ms.
- **Stylizacja A′** na nowym silniku: jedna dla wszystkich scen; warianty szwu w F1.
- **Strategia testów:** co testować jednostkowo, co bramkami buforów, co wzrokiem człowieka; zestaw scen testowych (trudne przypadki: pamięć git-and-hard-look-check).
- **Migracja:** jak przejść z `SunMap`/`StreetMap` bez gubienia ustaleń mapy grafiki.

## Out of scope

- Strojenie wartości i kolorów światła (ticket 38 mapy grafiki).
- Produkcja assetów i Przepisy (mapa grafiki).
