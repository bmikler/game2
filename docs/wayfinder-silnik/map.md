---
title: Silnik światła i cieni game2
labels: [wayfinder:map]
---

## Destination

Specyfikacja jednego Silnika światła, gotowa do pocięcia na tickety wykonawcze (`/to-spec` → `/to-tickets` → `/implement`). Silnik działa automatycznie w każdej Lokacji, we wnętrzach i w plenerze: wszystkie źródła (słońce, niebo, lampy, latarnie, świecące okna), pełna doba, ten sam kod i ta sama stylizacja pixel art, bez kodu i przełączników pod konkretną scenę.

Kryterium „gotowe” dla wykonania (sprawdzane w ostatnim tickecie wykonawczym, nie w tej mapie):

1. testy jednostkowe i bramki buforów zielone;
2. trudne sceny testowe ocenione przez człowieka na żywo w grze;
3. w silniku nie ma kodu ani przełączników pod scenę;
4. każda wartość wizualna w `.tres`, zmieniana na żywo w F1, zapisywana w zestawach;
5. powyżej 60 fps na sprzęcie człowieka;
6. test końcowy: nowa Lokacja wnętrza i nowa Lokacja w plenerze, zupełnie inne od Poligonów, zbudowane w edytorze wyłącznie z węzłów kontraktu sceny; cienie działają od razu. Każda potrzebna zmiana w kodzie silnika to wynik negatywny i powrót do modelu, nie łatka.

## Notes

- Pracujemy **po polsku**. Słownik: `GLOSSARY.md`. Tracker: local markdown jak w mapie grafiki (`docs/wayfinder/map.md`): `tickets/NN-*.md`, frontmatter `id`, `title`, `labels`, `status`, `assignee`, `blocked_by`; przejęcie = `assignee: claude`. Numeracja ticketów tej mapy od 01.
- **Mapa tylko planuje** (człowiek, 2026-11-15). Kończy się specyfikacją (ticket „Specyfikacja silnika”, `/to-spec`). Wykonanie: `/to-tickets` tnie specyfikację na tickety wykonawcze w osobnym katalogu, każdy robiony wyłącznie przez `/implement` (tdd + code-review + commit, jak w skillu; człowiek zgodził się na commity z `/implement`). Żadnej zmiany w silniku bez ticketu; nie powtarzamy chaotycznego poprawiania z `style-lab/lighting/`.
- **Skąd ta mapa:** w mapie grafiki silnik powstawał jako prototyp do oceny wyglądu i był przebudowywany kilka razy (tickety 31, 33, 35, 36, 14). Za każdym razem coś było popsute. Dom (`SunMap`, `light_fn`) i ulica (`StreetMap`, `street_fn`) to dwie równoległe kopie z różnymi zasadami: przeliczanie bufora, świat bufora, półcień słońca (`sun_pen_max` tylko na ulicy), zasłanianie nieba (`sky_objects` tylko na ulicy), okno postaci liczone z inną godziną niż reszta bufora. Poprawka w jednej kopii psuła albo omijała drugą. Stan wyjściowy: gałąź `t14-ulica-swiatlo`, commit `135ec42`; opis w `style-lab/README.md` i w tickecie 14 mapy grafiki.
- **Zasady człowieka (twarde):**
  - jeden silnik, jedna stylizacja dla wnętrz i pleneru; wnętrze i plener różnią się wyłącznie **danymi sceny** (wnętrze to scena z zasłoniętym niebem i otworami). Dopuszczalne są dwa zestawy strojenia (wnętrza, plener) jako `.tres`, nigdy osobna logika;
  - bez ifów i bez specjalnej obsługi pojedynczych przypadków; działa przez konstrukcję;
  - gdy poprawki się piętrzą, stop i przemyślenie modelu (pamięć: no-special-case-patches, shadows-pixel-art-clean-rebuild);
  - **oprawa artystyczna ponad realizm:** logika cieni sztywna (cień zawsze od źródła, spójny kierunek, poprawne nakładanie), ale wszystko, co jest nastrojem, to dane artystyczne, nie fizyka: droga słońca w czasie (krzywa godzina → wysokość i azymut, np. długi wschód i zachód), kolory i jasności źródeł w ciągu doby (gradienty), długość cieni, szerokość półcienia, siła nieba. Fizyka daje punkt startu, krzywe w `.tres` mogą ją wygiąć.
- **Granice:** silnik powstaje jako samodzielny katalog w projekcie `style-lab/` (np. `style-lab/addons/swiatlo/`), bez zależności od reszty `style-lab` (`config/`, `world/`, debug); do gry przenoszony przez skopiowanie katalogu. Nowy silnik obok starego; Poligony przechodzą na nowy; stary `lighting/` (`SunMap`, `StreetMap` itd.) usuwany na końcu wykonania (zostaje w historii gita).
- **Poligony jako sceny edytora:** Poligon Dom i Poligon Ulica przebudowane jako sceny układane w edytorze z węzłów kontraktu sceny; nie muszą być 1:1 jak dziś, ważne, żeby była Lokacja w plenerze i Lokacja wnętrza. Wnętrza to osobne Lokacje z wczytaniem; płynnego przejścia ulica → dom bez przeskoku nie przewidujemy.
- **Wszystkie źródła od razu:** słońce, niebo, lampy, latarnie, świecące okna, w kontrakcie i w implementacji; chcemy widzieć, jak cienie z różnych źródeł wyglądają i się nakładają. Pełna doba (24 h) ze zmianą na żywo; godzina jest jednym wejściem silnika dla całego bufora.
- **Ocena wyglądu:** prototypy (HITL) w tej mapie tylko tam, gdzie decyzja dotyczy wyglądu, oceniane na żywo w Poligonie (pamięć: judge-in-game-not-screenshots); reszta na końcu wykonania w scenach testowych. Strojenie: dobra praktyka ze `style-lab` to agent krytyk proponujący 3 warianty strojenia, więc silnik musi wczytywać zestawy wartości na żywo, żeby warianty dało się przeklikać w grze.
- **Już ustalone w mapie grafiki (wejście, nie do ponownego otwierania bez powodu):**
  - jedna funkcja światła i jeden bufor, postać i meble jedną funkcją cienia, cień nieba z okien dokładny (36);
  - całe światło okien z geometrii, bez strojenia okien; okna boczne tylko wstęgi (27, 31);
  - rzut 0,60, 40 px/m (09);
  - stylizacja: kierunek A′ (szew ditheru o stałej szerokości w px, kotwica `Y_ref`), research `docs/research/84-stylizacja-swiatla-plener-opus.md` (oraz 82, 83);
  - Kotwice (08): Beat Cop (rzut), NORCO (kolor, malarskość), REPLACED (postać i światło, bez pomarańczy); Referencje: Gemini Rue, Disco Elysium, Kentucky Route Zero; światło Octopath (01); baza chłodna, ciepło tylko przy źródłach;
  - strojenie kolorów i wartości poza tą mapą: ticket 38 mapy grafiki.
- **Kolejność (człowiek, 2026-11-15):** ta mapa i wykonanie najpierw; potem pozostałe tickety mapy grafiki (meble, makieta z teksturami, ulica, ozdoby itd.) na działającym silniku; na końcu globalne strojenie. Kontrakt danych assetu (co mebel, ściana i postać dają silnikowi) ustalić tu, bo Przepis mebli (ticket 13 mapy grafiki) ma go produkować.
- **Strojenie jest wymaganiem:** parametry w zasobach (`Resource`, `.tres`), suwaki F1 na żywo, zapis zestawów (presetów) i `--set=` w zrzutach. Strojenie nie może wymagać zmian w shaderach.
- **Testy:** wykonanie test-first. Kandydaci: GUT lub gdUnit4 (addon do dodania za zgodą człowieka) do logiki w GDScript; bramki buforów (`style-lab/tools/pomiar/bufor_roznica.mjs`, `bufor_ulica_roznica.mjs`: różnica pikseli w ustalonych punktach) jako testy regresji shaderów; benchmark `--bench=godzina [--ruch]`.
- **Research:** subagent ze skillem „research”; kluczowe na Opusie (`model: opus`; domyślny model subagentów to Sonnet), **model potwierdzany z człowiekiem przed odpaleniem**. Wyniki w `docs/research/` od numeru 85 (repo bez remote'a, więc bez gałęzi `research/*`).
- Godot 4.7.2: `C:/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64.exe` (konsolowy: `..._console.exe`). Skille: grilling → „grilling” + „domain-modeling”; research → „research”; prototype → „prototype”; specyfikacja → `/to-spec`, `/to-tickets`; wykonanie → `/implement`.
- Git: osobna gałąź na każdą próbę (pamięć: git-and-hard-look-check); poza `/implement` commit tylko na prośbę człowieka.

## Decisions so far

<!-- jedna linia na zamknięty ticket -->

## Not yet specified

- **Stylizacja A′ na nowym silniku:** jedna dla wszystkich Lokacji, przy wielu źródłach naraz; warianty szwu w F1. Wyklaruje się po „Jeden model światła i cienia” i prototypie nakładania.
- **Strojenie:** układ zasobów (`.tres`) i zestawów (wnętrza, plener, warianty krytyka), F1, `--set=`; które parametry są krzywymi doby.
- **Noc i pora dnia:** szczegóły przejść (zmierzch, włączanie lamp, świecące okna) po ustaleniu modelu źródeł.
- **Migracja:** jak przejść z `SunMap`/`StreetMap` bez gubienia ustaleń mapy grafiki; co z bramkami buforów liczonymi na starym silniku.

## Out of scope

- Strojenie wartości i kolorów światła (ticket 38 mapy grafiki).
- Produkcja assetów i Przepisy (mapa grafiki).
- Płynne przejście ulica → wnętrze bez wczytania (wnętrza to osobne Lokacje).
