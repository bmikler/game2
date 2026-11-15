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
4. każda wartość wizualna w `.tres`; Warianty strojenia przełączane na żywo w F1 (bez ręcznych suwaków, z „Układ strojenia”);
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
- **Smugi z górnych okien są obowiązkowe (człowiek, 2026-11-15):** we wnętrzach smuga światła z górnych okien, plama światła z okna na podłodze i drobinki kurzu w smudze (dziś: `sun_beam.gdshader`, `sun_dust.gdshader`, plama w `SunMap`) muszą być w nowym silniku, z geometrii okna i słońca, nie jako dekoracja pod scenę. Okna ze wszystkich ścian: smuga i plama tam, gdzie wyliczy je silnik (zmiana w „Jeden model światła i cienia dla wszystkich źródeł”).
- **Wszystkie źródła od razu:** słońce, niebo, lampy, latarnie, świecące okna, w kontrakcie i w implementacji; chcemy widzieć, jak cienie z różnych źródeł wyglądają i się nakładają. Pełna doba (24 h) ze zmianą na żywo; godzina jest jednym wejściem silnika dla całego bufora.
- **Kto decyduje (człowiek, 2026-11-15):** człowiek jest inżynierem aplikacji biznesowych, nie grafikiem; ocenia wygląd na żywo w grze, a szczegóły techniczne rozstrzyga Claude (trudniejsze z subagentem na Opusie). Pytania do człowieka tylko o wygląd i zakres.
- **Ocena wyglądu:** prototypy (HITL) w tej mapie tylko tam, gdzie decyzja dotyczy wyglądu, oceniane na żywo w Poligonie (pamięć: judge-in-game-not-screenshots); w wykonaniu człowiek sprawdza ręcznie każdy zaimplementowany ticket (z „Strategia testów i sceny testowe”). Strojenie: wyłącznie Warianty strojenia od agentów krytyków (kilku, po 3 warianty), przełączane na żywo w F1; bez ręcznych suwaków (człowiek, 2026-11-15).
- **Już ustalone w mapie grafiki (wejście, nie do ponownego otwierania bez powodu):**
  - jedna funkcja światła i jeden bufor, postać i meble jedną funkcją cienia, cień nieba z okien dokładny (36);
  - całe światło okien z geometrii, bez strojenia okien; okna boczne tylko wstęgi (27, 31);
  - rzut 0,60, 40 px/m (09);
  - stylizacja: kierunek A′ (szew ditheru o stałej szerokości w px, kotwica `Y_ref`), research `docs/research/84-stylizacja-swiatla-plener-opus.md` (oraz 82, 83);
  - Kotwice (08): Beat Cop (rzut), NORCO (kolor, malarskość), REPLACED (postać i światło, bez pomarańczy); Referencje: Gemini Rue, Disco Elysium, Kentucky Route Zero; światło Octopath (01); baza chłodna, ciepło tylko przy źródłach;
  - strojenie kolorów i wartości poza tą mapą: ticket 38 mapy grafiki.
- **Kolejność (człowiek, 2026-11-15):** ta mapa i wykonanie najpierw; potem pozostałe tickety mapy grafiki (meble, makieta z teksturami, ulica, ozdoby itd.) na działającym silniku; na końcu globalne strojenie. Kontrakt danych assetu (co mebel, ściana i postać dają silnikowi) ustalić tu, bo Przepis mebli (ticket 13 mapy grafiki) ma go produkować.
- **Strojenie jest wymaganiem:** parametry w zasobach (`Resource`, `.tres`), Warianty strojenia przełączane w F1 i `--set=` w zrzutach (szczegóły: „Układ strojenia”). Strojenie nie może wymagać zmian w shaderach.
- **Testy:** wykonanie test-first. Kandydaci: GUT lub gdUnit4 (addon do dodania za zgodą człowieka) do logiki w GDScript; bramki buforów (`style-lab/tools/pomiar/bufor_roznica.mjs`, `bufor_ulica_roznica.mjs`: różnica pikseli w ustalonych punktach) jako testy regresji shaderów; benchmark `--bench=godzina [--ruch]`.
- **Research:** subagent ze skillem „research”; kluczowe na Opusie (`model: opus`; domyślny model subagentów to Sonnet), **model potwierdzany z człowiekiem przed odpaleniem**. Wyniki w `docs/research/` od numeru 85 (repo bez remote'a, więc bez gałęzi `research/*`).
- Godot 4.7.2: `C:/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64.exe` (konsolowy: `..._console.exe`). Skille: grilling → „grilling” + „domain-modeling”; research → „research”; prototype → „prototype”; specyfikacja → `/to-spec`, `/to-tickets`; wykonanie → `/implement`.
- Git: osobna gałąź na każdą próbę (pamięć: git-and-hard-look-check); poza `/implement` commit tylko na prośbę człowieka.

## Decisions so far

<!-- jedna linia na zamknięty ticket -->

- [Cienie w pixel arcie w Project Shadowglass](tickets/01-project-shadowglass-research.md): gra 3D FPP, technika nieujawniona; algorytmu do przeniesienia brak, tylko uwagi praktyczne (ambient a paleta, zanik lamp jako krzywa, słońce pod kamerę jako trudna scena).
- [Nakładanie cieni i światła z wielu źródeł w 2D i pixel arcie](tickets/02-nakladanie-cieni-wiele-zrodel-research.md): źródła się dodają w HDR, cień bez własnego koloru (kolor pozostałych źródeł), kwantyzacja sumy, nie źródeł; luka: A′ nie kwantyzuje barwy (ciepłe/chłodne).
- [Światło i cienie w Kotwicach i Referencjach](tickets/03-swiatlo-w-kotwicach-research.md): brak gotowego wzoru technicznego; reguły: cienie równoległe z jednym kierunkiem, kolor cienia jako dana pory dnia, fizykę nagina się w oświetleniu postaci, czasie i pogodzie, nie w kierunku cieni; nakładania wielu źródeł nikt nie pokazuje.
- [C++ (GDExtension) czy shadery i GDScript dla Silnika światła](tickets/04-cpp-czy-shadery-research.md): koszt prawie cały na GPU (źródła × próbki × pudła na piksel); C++ nie teraz, 60 fps algorytmem: światło statyczne osobno od ruchomych przesłon, przycinanie per kafel, ewentualnie compute.
- [Testy w Godot 4.7 dla Silnika światła](tickets/05-testy-godot-research.md): GUT 9.7.1 (za zgodą), testy shaderów nie w headless, tylko w oknie poza ekranem z GPU; jedna komenda dla /implement.
- [Podgląd światła w edytorze Godota 4.7](tickets/06-podglad-w-edytorze-research.md): wykonalny; węzły kontraktu @tool w grupie + jeden kontroler z SubViewport renderowanym tylko po zmianie; pomocnicze węzły bez owner nie trafiają do .tscn.
- [Jeden model światła i cienia dla wszystkich źródeł](tickets/07-jeden-model-swiatla.md): suma źródeł w HDR, trzy kształty Źródła (kierunkowe, kopuła, powierzchniowe), niebo zawsze kopułą, jeden półcień z geometrii, Stan doby z godziny, pogoda jako stały schemat dobowy, smugi i kurz jako rozproszenie w powietrzu (poza A′), okna ze wszystkich ścian z geometrii, postać bez reflektora, ekspozycja automatyczna.
- [Kontrakt danych sceny](tickets/08-kontrakt-danych-sceny.md): Lokacja z węzłów w metrach (Otoczenie Lokacji z profilem nieba miasto/wieś, Ściana z Otworami i wypełnieniem jak żaluzje, Przesłona z Brył, Źródło z mnożnikiem do animacji, ruchome i przyczepione); silnik nie zna pokoi ani rodzajów; asset = sprite + uproszczone Bryły + opcjonalna mapa normalnych.
- [Nakładanie cieni z kilku źródeł](tickets/09-nakladanie-cieni-prototyp.md): nakładanie z sumy w HDR wygląda dobrze; bufor niesie dwa kanały (naturalny, sztuczny, pole Źródła); stylizacja w dwóch trybach w `.tres` (A′ na sumie albo A′ na każdym kanale), wybór przy strojeniu; tryb „barwa w stopniach” odrzucony.
- [Bufor i przeliczanie](tickets/10-bufor-i-przeliczanie.md): bufor ×1 w warstwach według zmienności (niebo i nieruchome Źródła raz przy wczytaniu, słońce kaflami z przenikaniem, ruchome Przesłony i Źródła w oknach co klatkę), przycinanie kaflami, `canvas_item` bez C++; budżet 4 ms GPU, 1 ms CPU, wczytanie ≤ 2 s; cel 8 postaci + samochód + 4 drzewa; wiatr jako wychylenie Przesłony, A/B do oceny.
- [Strategia testów i sceny testowe](tickets/11-strategia-testow.md): GUT 9.7.1 + bramki buforów na syntetycznych scenach (zasady, nie wygląd) + człowiek tylko wygląd; trudne sceny w dwóch Poligonach z przełącznikiem w F1; każdy ticket wykonawczy sprawdzany ręcznie („Jak sprawdzić”, pionowe plastry, widok debug silnika w F1); test końcowy: Lokacje buduje subagent na ślepo z dokumentacji kontraktu.
- [Migracja ze starego silnika](tickets/16-migracja.md): stare Poligony nietknięte do końca jako porównanie; nowe Poligony pod testy (Ulica: Uliczka, Sklep, Skwer; Dom: salon, kuchnia, pracownia), najpierw Ulica; południe na górze ekranu w całej grze; stare ustalenia tylko jako Ściąga wyglądu; stare bramki nie przechodzą; osobny ticket usunięcia starego silnika przed testem końcowym.
- [Układ strojenia](tickets/13-uklad-strojenia.md): Krzywe doby wspólne dla całej gry + dwa Zestawy strojenia ze stałymi; stroi się tylko Wariantami krytyków (kilku krytyków, A/B/C, przeładowanie na żywo), bez suwaków; F1 minimum (godzina, tempo, Warianty, zrzut ze ścieżką w schowku, widok debug, przełączniki bieżącego ticketu).

## Not yet specified

- (pusto: został ticket „Specyfikacja silnika”)

## Out of scope

- Strojenie wartości i kolorów światła (ticket 38 mapy grafiki), Wariantami krytyków na zaimplementowanym silniku. Tu też [Krzywe doby i noc](tickets/14-krzywe-doby-i-noc.md) i [Stylizacja rozproszenia w powietrzu](tickets/15-stylizacja-rozproszenia.md): wartości i wygląd to strojenie, wymagania przeniesione do „Specyfikacja silnika” (człowiek, 2026-11-15).
- Produkcja assetów i Przepisy (mapa grafiki).
- Płynne przejście ulica → wnętrze bez wczytania (wnętrza to osobne Lokacje). Nowe Poligony nie mają też drzwi ulica → dom, pięter ani schodów (z „Migracja ze starego silnika”).
- Brzeg kadru w czerni: prototyp kilku wariantów na działającym silniku, w mapie grafiki (tamże).
- Odczyt poziomu światła przez logikę gry: żadna mechanika nie używa cienia (z „Jeden model światła i cienia dla wszystkich źródeł”).
- Pogoda zmienna między dniami: jeden stały schemat dobowy wystarczy (tamże).
