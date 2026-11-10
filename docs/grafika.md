# Grafika: wnioski z game1 i pomysły dla game2

Stan: 2026-11-03. **Na tym etapie nic tu nie jest decyzją.** Wszystko poniżej to wnioski z game1, ustalenia z researchu i pomysły do sprawdzenia na makietach i w testach. Decyzje zapadną dopiero po porównaniu wyników.

Indeks wszystkich materiałów graficznych (notatki, tickety i ADR-y game1, styl, sprite'y, narzędzia, kolory światła): `docs/grafika-indeks.md`.

Źródła: notatki w `docs/research/` (51, 51b, 52, 53 oraz kopie z game1) i doświadczenia z game1 `C:/Users/bartl/Desktop/repo/game1`. Punkt wyjścia z `input-fixed.txt`: Pixellab (subskrypcja) jako główne narzędzie na start, ale bez zamykania się na nie (porównanie: `docs/research/52-narzedzia-pixel-art.md`), koncepty w ComfyUI, grafika od nowa, wyższa rozdzielczość i bardziej szczegółowe postacie, styl mniej infantylny niż w game1.

## Cel i priorytety

Grafika jest jednym z najważniejszych elementów gry. Ma być ładna i klimatyczna, a żaden sprite nie może wybijać gracza z nastroju. Jednocześnie pojedynczy mebel nie może wymagać godzin ręcznego poprawiania.

Proponowany sposób pracy: **czas inwestujemy raz w ustalenia i narzędzia, a nie w każdy asset osobno.** Najpierw sprawdzamy i ustalamy kąt, stałe rzutu, paletę, wzorzec stylu, szablony wejść dla generatorów i automatyczny test. Potem nowy mebel to wymiary, szary box, generacja, test i ocena w scenie. Jeśli asset po 2–3 generacjach dalej odstaje, poprawiamy wejście albo szablon, a nie piksele. Wyjątkiem są drobiazgi poniżej ok. 32 px, które szybciej dorysować ręcznie.

Ocena „czy nie wybija z nastroju” odbywa się w scenie, a nie na pustym tle: asset stoi w pokoju obok wzorcowych mebli i postaci, w świetle dziennym i nocnym.

## Wnioski z game1

1. **Niespójność rzutu wzięła się z tego, że każda klasa obiektów miała inne źródło kamery.** Postacie powstały z konceptu FLUX, kanapa i lodówka z `create_map_object`, lada z prowadnicy, a szafy z samego opisu. Każde z tych źródeł miało inny kąt.
2. **Prompt i referencja nie wymuszają kąta.** Dokumentacje Pixellab, Retro Diffusion, FLUX.2 i Gemini traktują opis kamery i obraz stylu jako podpowiedź. Kąt trzyma się tylko wtedy, gdy geometria jest *wejściem*: render, prowadnica albo maska (research 51, §4).
3. **Postacie wyszły dobrze, bo koncept miał już właściwy rzut.** Ten łańcuch działał: koncept, potem `image_to_pixelart`, potem `create_character` v3. Pixellab v3 obraca postać, ale nie zmienia kamery.
4. **Generowanie w ×4 i zmniejszanie niszczy detal.** Lepiej generować natywnie w docelowym rozmiarze. Drobiazgi poniżej ok. 32 px lepiej dorysować ręcznie.
5. **Bez automatycznej kontroli trudno utrzymać spójność przy kilkudziesięciu obiektach.** Warto sprawdzać skryptem paletę, alfę, wymiary względem specyfikacji i wysokość postaci.

## Rzut: korekta do researchu 51 i test do zrobienia

Research 51 (§2.3) nazywa rzut game1 „niestandardowym”. To przesada. Proporcja wierzch:front = 1:1 to zwykła kamera ortogonalna pochylona o 45°, bo wierzch skraca się o sin 45°, a front o cos 45°, czyli tyle samo. „Typowe 3/4” z poradników (Slynyrd: front „shortened compared to the top”) oznacza kamerę bardziej stromą.

Sześcian 1×1×1 m przy 40 px/m:

| Kąt kamery | Wierzch | Front | Proporcja | Charakter |
|---|---|---|---|---|
| 45° (game1) | 40 px | 40 px | 1:1 | masywne meble, wysokie fronty, mniej widać podłogi |
| ~60° (stromy) | 40 px | ~23 px | ~1,7:1 | więcej podłogi i blatów, czytelny układ pokoju, niższe meble |
| ~30° (płaski) | ~23 px | 40 px | ~0,6:1 | prawie widok z boku, rzadki przy ruchu w 8 kierunkach |

Postacie z Pixellab w game1 wyglądały jak w kamerze bardziej stromej niż 45°, bo widać było czubek głowy i ramiona. Nie pasowały przez to do mebli w 45°. Pomysł na game2: dobrać kąt do tego, co dają narzędzia, a nie odwrotnie.

1. Wygenerować w każdym rozważanym narzędziu (Pixellab z tymi samymi ustawieniami `view`, które byłyby używane w produkcji, i alternatywy) sześcian albo skrzynię 1×1×1 m i prostą ladę.
2. Zmierzyć proporcję wierzchu do frontu.
3. Jeśli wynik jest spójny, przyjąć ten kąt jako stałą rzutu dla wszystkich prowadnic i renderów (szary box, manekin).

**Chef RPG ma prawdopodobnie ten sam rzut co game1** (notatka `docs/research/54-chef-rpg-styl.md`): kafel podłogi jest na ekranie kwadratowy, wierzch obiektu to jego plan bez skrótu, front stoi pod nim w pełnej wysokości, a boków mebli nie widać. To jest dokładnie „1 m = 40 px we wszystkich osiach, bez skrótu głębokości” z game1, czyli kamera 45° z rozciągnięciem pionowym √2. Notatka 54 (§5) przedstawia to jako nowy wariant, ale to ten sam rzut. Uwaga: pomiary pochodzą z JPEG-ów i pewny jest tylko kwadratowy kafel. Nie da się z nich wykluczyć kamery ok. 55–60° ze skróconym frontem. Wniosek roboczy: rzut z game1 jest dobrym kandydatem, skoro używa go gra, której grafika nam się podoba. Test sześcianu i tak rozstrzygnie, czy narzędzia go utrzymają.

## Chef RPG jako wzorzec: co może się przenieść

Szczegóły i pomiary: `docs/research/54-chef-rpg-styl.md`. Propozycje do sprawdzenia:

- **Skala:** natywna niska rozdzielczość i skalowanie całkowite (Chef RPG: 640×360 ×3/×4, kafel 24 px, postać ok. 48 px w stylu chibi). Przy naszych realistyczniejszych proporcjach postaci potrzeba więcej pikseli na postać, np. 960×540 ×2 i 60–75 px.
- **Kontur:** selektywny, ciemny i kolorowy na postaciach i rekwizytach, bez konturu na terenie i śniegu.
- **Technika światła, bez kolorystyki:** sprite'y mają ograniczoną paletę, a światło i winieta to nakładka w silniku. **Kolorystyki Chef RPG nie przenosimy.** Punktem wyjścia zostają kolory światła z game1, które się sprawdziły: `repo/game1/game/world/lighting/lighting_director.gd` oraz notatki `22a-kolory-wnetrz.md` i `22c-gra-swiatla.md`.
- **Meble:** osiowo, bez ukosów (po skosie biegną tylko schody i fazy ścian), bez widocznych boków. Trzy widoki mają tylko krzesła. Rekwizyty tworzą małe zestawy, a podłoga zostaje wolna na ścieżki.
- **Okna:** tylko w licu tylnej ściany, z ramą, parapetem i namalowanym widokiem. U nas byłby to zaśnieżony las albo ulica, a nocą ciemne okno.
- **Fasady:** okna tylko na ścianie od strony kamery, dach z góry. Nocą część szyb jest ciemna, a reszta świeci ciepło na tle zimnego śniegu.
- **Nie przenosi się:** kolorystyka (palety i barwy światła), chibi (głowa ok. 40% postaci), bardzo wysokie ściany (ok. 2,4 wysokości postaci), cukierkowe nasycenie i różowe rekwizyty. To ton „cozy”, a nie noir.

## Narzędzia

Pixellab to punkt startowy, nie stałe założenie. Każde narzędzie (Pixellab, Retro Diffusion, modele w ComfyUI, inne) można ocenić tym samym testem: sześcian i lada w tym samym kącie, jedna postać w 4 kierunkach, zgodność z paletą, czas i koszt na asset, wygląd w scenie obok wzorca. Różne narzędzia mogą obsługiwać różne klasy assetów (np. inne do postaci i animacji, inne do mebli), pod warunkiem że wszystko przechodzi przez te same stałe rzutu, paletę i test. Porównanie i protokół testu: `docs/research/52-narzedzia-pixel-art.md`.

## Pomysły na pipeline

- **Jeden plik ze stałymi rzutu** (np. `PROJECTION.md`): kąt i proporcja wierzch:front, px/m, wysokość ściany, wysokość postaci, kontur, paleta, kierunek umownego światła. Inne dokumenty tylko do niego linkują. W game1 te liczby były rozrzucone i się rozjechały (ściana 2,6 m w STYLE.md, a 1,9 m w ADR).
- **Geometria jako wejście dla generatora.** Do mebli i budynków przygotować szary box albo prosty render w jednym kącie i podać go jako obraz wejściowy, nie tylko jako styl. Najprościej przez render kamerą ortogonalną w Blenderze, ale może wystarczyć prowadnica narysowana z siatki. Blender wymaga instalacji.
- **Postacie:** koncept w ComfyUI na szarym manekinie w tym samym kącie, potem `image_to_pixelart` i `create_character`. Warianty tej samej postaci (gracz w kurtce i bez, matka Branji w domu i w szpitalu) generować z tego samego konceptu bazowego, zmieniając tylko strój.
- **Jedna paleta i jeden kontur** dla wszystkiego, kwantyzacja bez ditheringu i bez antyaliasingu na obrysie.
- **Światło w sprite'ach** neutralne albo najwyżej ze stałą konwencją „wierzch o stopień jaśniejszy”. Nastrój budują światła 2D z normal mapami w silniku.
- **Wzorzec stylu:** arkusz referencyjny z 2–3 wzorcowymi postaciami i meblami. Każdy nowy asset oceniany obok niego.
- **Automatyczny test assetu** (Node): paleta, alfa 0/255, bbox zgodny ze specyfikacją ±1 px, wysokość postaci.
- **Zapis ustawień generacji** (prompt, seed, wejście, wersja modelu) w jednym pliku `prompts.jsonl`, tak jak w game1.

## Obroty, układ pokoju i obiekty pod kątem

Szczegóły i źródła: `docs/research/51b-obroty-i-uklad-obiektow-3-4.md`. Rachunki geometrii dotyczą kąta 45° z game1. Przy innym kącie zasady zostają te same, a zmieniają się tylko proporcje.

- **Ile orientacji na obiekt (propozycja):**
  - jedna dla rzeczy stojących przy tylnej ścianie (lodówka, aneks, szafy, regały, lada, okna);
  - dwie dla stołów, biurek i łóżek;
  - trzy dla kanap, foteli i krzeseł: przód, tył i bok, a drugi bok to lustro. Lustrzany sprite wymaga odwrócenia kanału X w normal mapie.
- **Jak je robić:** obracać obiekt, nie kamerę. Szary box albo render dostaje obrót 0/90/180/270°, a kamera i kąt zostają stałe. Narzędzie rotate w Pixellab jest według dokumentacji trenowane na postaciach, więc do mebli raczej się nie nadaje.
- **Gdzie co stawiać:**
  - przy tylnej ścianie obiekty frontowe i wszystko, co wysokie;
  - przy bocznych ścianach obiekty czytelne z góry albo z profilu (łóżka, kanapy bokiem, stoły);
  - przy dolnej ścianie tylko niskie meble widziane od tyłu.

  Wysokie meble poza tylną ścianą zasłaniają gracza.
- **Kolizja:** obszar kolizji to dolny pas sprite'a o wysokości `głębokość × px/m`. Sortowanie po stopach. W Godot `y_sort_enabled` sortuje tylko węzły z tym samym `z_index`.
- **Obiekty pod kątem:** research zaleca stawiać wszystko osiowo. Ukos 45° daje schodkowe krawędzie, romb zamiast prostokąta na wierzchu, przekrzywione fronty, wielokątną kolizję i błędne sortowanie z jednej strony. Ewentualnie jako wyjątek, z tej samej kamery. Fotel z game1 był obrócony ok. 30–45° w rzucie bliższym izometrii i odstawał od kanapy i lady.

## Ściany, drzwi i okna

Szczegóły: `docs/research/43-sciany-wnetrz-3-4.md`, `43b-chef-rpg-wnetrza.md`, `35b-okna-w-wierzchu-sciany.md`, `47-swiatlo-okien-z-roznych-scian.md`, `53-okna-boczne-i-dolne.md`, `22c-gra-swiatla.md`.

### Co robią inne gry

- **Lico tylko od strony kamery.** Każdy odcinek ściany ma wierzch, a lico pełnej wysokości tylko wtedy, gdy jego strona zwrócona do kamery graniczy z podłogą. Ściana tylna i ściana działowa nad pokojem dolnym mają więc lico, a boczne i dolna to sam wierzch. Tak robią Stardew, Graveyard Keeper, To the Moon i LimeZu.
- **Chef RPG** ma okna tylko na tylnych ścianach. Boczne i dolne to ciemny pas, za nim czerń, a podłoga przy dolnej krawędzi ciemnieje winietą. Więcej okien uzyskuje łamaną tylną ścianą (wnęki, wykusze).
- **Okien w ścianach dolnych i bocznych gry 3/4 zwykle nie rysują.** Okno pokazuje się światłem na podłodze. Próby okna narysowanego w wierzchu wyglądały w game1 źle. Wyjątek to Moonlighter („misa” z pochylonymi ścianami), dla nas pewnie za drogi.

### Pomysły do sprawdzenia

- **Drzwi w dolnej ścianie:** przerwa w wierzchu albo wystający poza obrys „języczek” podłogi, z progiem, wycieraczką i smugą światła z zewnątrz, bez skrzydła. Wycieraczka przy wejściu do budynku przyprószona śniegiem, z mokrymi śladami i grudkami śniegu na progu, zależnie od pogody i pory dnia.
- **Drzwi między pokojem dolnym a górnym:** otwór w licu pokoju dolnego, nad nim przerwa w wierzchu pokoju górnego.
- **Okna boczne i dolne: samo światło pewnie nie wystarczy** (notatka 53). Okno mogą zdradzić cztery sygnały naraz:
  1. plama światła na podłodze z cieniem ościeżnicy i szprosów;
  2. ślad otworu: parapet wystający 1–2 px, ciemne słupki ościeża, najwyżej jedna cienka linia szkła;
  3. rekwizyty okna: zasłona, kaloryfer, doniczka albo gwiazda adwentowa, szron i śnieg na parapecie;
  4. zgodność z zewnątrz: to samo okno świeci na fasadzie i rzuca poświatę na śnieg.

  Warianty z notatki 53 do porównania:
  - **S0** „światło z kratą”, bez szkła;
  - **S1** „szczelina”: S0 z linią szkła i nocnym odbiciem lampy;
  - **K** „okno bohater”: lokalne lico, tylko w kilku miejscach.

  Okna w dolnej ścianie wychodzą na północ, więc dają tylko chłodne światło nieba. Czytelność do sprawdzenia testem 5 s z notatki 53.
- **Plama z kratą na wszystkich oknach**, także tylnych, do kombinowania z rekwizytami.
- **Okna wnętrza zgodne z budynkiem z zewnątrz.** Budynek z zewnątrz może być mniejszy niż w środku, więc zgodne miałyby być liczba, kolejność, styl i świecenie okien na danej ścianie, a nie położenie w metrach. Jeden rekord okna (`WindowDef` z notatki 53) dla wnętrza i fasady. Do rozpracowania przy implementacji.
- **Plama światła a meble** (`22c` §6.1, §6.5, §6.7, §6.9; nic z tego nie było w pełni testowane). W game1 plama dziwnie zachowywała się z obiektami. Pomysł:
  - plama okna oświetla tylko podłogę i dywaniki (maska światła), więc mebel w plamie nie dostaje wzoru kraty;
  - meble i postacie w świetle okna dostają osobne, miękkie światło bez kraty (ciepłe odbicie od plamy, kontrświatło);
  - cień mebla w plamie z tekstury plamy przeliczanej przy zmianie godziny (promień z podłogi do słońca sprawdza szybę i bryły mebli). Prostszy zapas to rzutowane wielokąty cienia w trybie MUL;
  - okna bez słońca (niebo, noc) dają miękkie światło, więc problem z meblami prawie znika.
- **Bez zewnętrznych ramek (wierzchów ścian).** Tylna ściana z licem zostaje, ale bez ramki nad nią. Boki i dół bez ramek, pokój wisi w czerni jak przekrój domku dla lalek. Ramki zostają tylko między pokojami.
  - Zyski: czystszy, mniej „planszowy” obraz, mniej grafiki, czerń działa jak winieta i wzmacnia światło. Odpada problem okien w ramkach.
  - Do zastąpienia: górna krawędź lica dostaje 1–2 px listwy albo gzymsu. Podłoga kończy się krawędzią o 1 px ciemniejszą i winietą w czerń. Drzwi zewnętrzne to wystający kawałek podłogi z wycieraczką.
  - Ryzyko: okno boczne bez ramki ma za ślad tylko parapet i rekwizyty, więc może być nieczytelne. Do sprawdzenia na makiecie razem z wariantem z ramkami.

  ```
   z ramkami                     bez zewnętrznych ramek
   ██████████████████████
   █┌──────lico────────┐█          ▔▔▔▔▔listwa▔▔▔▔▔▔▔
   █│  okno    okno    │█          │ okno     okno  │
   █└──────────────────┘█          └────────────────┘
   █                ░░  █         ▕     podłoga   ░░  ▏  <- plama z okna bocznego
   █    podłoga     ▒▒  █         ▕               ▒▒▏     wchodzi z ciemności
   █                    █         ▕                   ▏
   ███████▀▀▀▀███████████          ░░░░winieta░░░░░░░
          wycieraczka                  ▔▔▔▔ wycieraczka
  ```
- **Dla generatorów:** okna i drzwi jako sprite'y frontowe generowane tylko na licu ścian tylnych, w tym samym kącie co meble. Na dolnych i bocznych ścianach rolę okien przejmują światło i propsy.

## Otwarte pytania

1. Jaki kąt kamery wyjdzie z testu sześcianu w poszczególnych narzędziach.
2. Rozdzielczość bazowa i px/m przy bardziej szczegółowych postaciach. W game1 było 960×540 i 40 px/m przy postaci ok. 75 px. Mniejszy widoczny obszar budynku jest akceptowalny.
3. Wysokość ściany wnętrz.
4. Blender do prowadnic (instalacja) czy prowadnice rysowane ręcznie lub skryptem.
5. Fasady, dachy i teren zewnętrzny: w game1 nie było dla nich wzorca.
6. Umowny wąski pasek boku (ok. 6–8 px) dla mebli stojących frontem do bocznej ściany, żeby nie wyglądały jak puste pudła.
7. Maksymalna wysokość mebli poza tylną ścianą i co robić, gdy zasłaniają gracza (np. przezroczystość).
8. Czy wyniki narzędzi w 4 kierunkach pasują do jednego kąta (ten sam test sześcianu).
9. Zewnętrzne ramki ścian: z ramkami czy bez (makieta obu wariantów).
