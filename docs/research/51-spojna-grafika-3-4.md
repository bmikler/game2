> Kopia z game1 (`repo/game1/docs/research/51-spojna-grafika-3-4.md`, 2026-11-03). Ścieżki (`tools/`, `art/`, `docs/adr/`, numery notatek) odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Wnioski dla game2 i korekta §2.3 są w `docs/grafika.md`.

# Spójna grafika 3/4: jeden rzut, jeden styl dla postaci, mebli, budynków i kafli

Data researchu: **2026-11-03**. Powód: postacie z Pixellab wyszły dobrze, a meble, drobiazgi i szafy mają inny rzut (widać to na `art/reference/game/1200_dzien.png`: szafy na akta i aneks mają widoczny bok, kanapa jest w innej kamerze niż lada, drzwi i krzesła w jeszcze innej). Ta notatka **nie powtarza** ustaleń z `46`, `57`, `43`, `24d`, `08`, `11b`, tylko je spina i uzupełnia o źródła pierwotne.

Oznaczenia przy twierdzeniach:
- **[zweryfikowane]**: sprawdzone w źródle pierwotnym (link) albo w repo (ścieżka).
- **[wtórne]**: źródło wtórne lub streszczenie strony przez narzędzie, bez lektury całości.
- **[niezweryfikowane]**: wiedza ogólna, nie sprawdzona w tym researchu.
- **[wniosek]**: moje rozumowanie albo propozycja.

## TL;DR

1. **Przyczyna niespójności jest strukturalna: rzut gry istnieje tylko jako liczba w ADR 0002 (1 m = 40 px we wszystkich osiach), a nie jako coś, co *wymusza* generator.** Każde narzędzie AI (FLUX, Pixellab, Gemini) traktuje obraz referencyjny i słowa o kamerze jako podpowiedź, nie ograniczenie (§2, §4). Dobre wyniki (Badacz, Krogg, kanapa, lada) powstały tam, gdzie wejście miało już właściwy rzut albo bryła była prosta i duża.
2. **Rekomendacja: jedna kamera w Blenderze jako źródło prawdy rzutu dla WSZYSTKIEGO sztywnego** (meble, drzwi, okna, elementy budynków, kafle, rekwizyty): ortogonalna kamera 45° + rozciągnięcie pionowe o √2 (rachunek w `46` §2), jeden skrypt `rig` z jednym zestawem stałych (kąt, skala 40 px/m, paleta, kontur). Reszta tego, co robimy dziś (`unfake`, paleta 32 kolorów, `normals.gd`, `prop_outline.gd`), zostaje jako **wspólny, deterministyczny etap końcowy** dla wszystkich asset-ów.
3. **AI wchodzi *za* kamerą, nie przed nią:** tylko jako (a) tekstura/malarski wygląd na renderze (img2img z niskim denoise lub `image_to_pixelart`/`edit` z renderem jako wejściem), (b) źródło konceptów do postaci i organiki (krzesła, rośliny), które potem przechodzą przez ten sam kadr. Prompt o rzucie nie jest mechanizmem kontroli.
4. **Postacie:** zostajemy przy łańcuchu, który działa (koncept FLUX → `crop_ref` → Pixellab `image_to_pixelart` → `create_character` v3). Poprawka: koncept postaci generować z **szarego manekina wyrenderowanego tą samą kamerą Blendera** jako wejściem edycji, żeby rzut postaci i mebli pochodził z jednego źródła **[wniosek]**.
5. **Kontrola jakości automatyczna, nie wzrokowa:** test w Node (jest już `png.mjs`) sprawdzający paletę, brak pikseli boku, wymiary bbox względem specu i siatkę pikseli, odpalany na każdym asset-cie przed wejściem do `game/`. Wzrokowa ocena zostaje na arkuszu ×4 obok `pixel_ref.png` (zasada projektu).
6. **Największa nierozstrzygnięta rzecz:** czy render 3D po pikselizacji „nie odstaje” od postaci z Pixellab (ryzyko wyglądu CG, `46` §3). To rozstrzyga tylko eksperyment z `46` §6 (lada + szafka), którego wyników w repo nie ma. Blender nie był zainstalowany na 2026-10-29.

## 1. Stan obecny i co już ustalono (nie powtarzać)

| Temat | Ustalenie | Gdzie |
|---|---|---|
| Rzut | Widok 3/4, 1 m = 40 px we wszystkich osiach, bez skrótu głębokości; kafel 32 px to tylko siatka podłóg i ścian; baza 960×540; skala pikseli jedna w całej grze | `docs/adr/0002-widok-3-4-i-drabinka-swiatla.md` |
| Światło | Sprite'y w neutralnym, równym świetle (albedo); nastrój daje światło 2D z normal mapami w Godot; kontur ciemnym kolorem z palety | `art/concept/_style/STYLE.md` |
| Paleta | 32 kolory (`palette.hex`, `.gpl`), median cut z konceptów plus akcenty; `unfake quantize --palette` bez ditheringu | `art/concept/_style/` |
| Wzorzec stylu | `pixel_ref.png` (Badacz, Krogg, lada, prycza); każdy nowy obiekt oceniany obok niego | STYLE.md |
| Postacie | Koncept FLUX → `image_to_pixelart` faithful 80×80 → `create_character` v3, bez zmniejszania; „v3 tylko obraca, kamery nie zmienia” | `57` §1 |
| Meble | Pixellab bez kontekstu miesza rzuty; `style_image` to „soft guidance”; generować natywnie, nie w ×4 + `unfake`; drobiazgi <32 px lepiej dorysować ręcznie | `57` |
| Droga do rzutu | Blender ortho 45° + √2, normal mapa z renderu, A0 (bez AI) / A1 (img2img) | `46` |
| Precedens | Graveyard Keeper 2 modeluje prawie wszystko w 3D i rzutuje pixel art ze stałego kąta | `11b` §1 |
| Ściany | Wzorzec A: lico 104 px na każdym odcinku ściany z podłogą pod spodem, reszta to wierzch | `43` |

**Nierozwiązane (stan na repo):**
- Nie ma jeszcze żadnego skryptu Blender ani wyniku eksperymentu z `46` §6 (`tools/` zawiera tylko `concept`, `godot`, `reference_shots`, `unfake`, `variant_sheets`) **[zweryfikowane: repo]**.
- Brak automatycznych testów spójności assetów (są testy porównywania zrzutów `compare.mjs`, ale to inny poziom).
- Nie ma tabeli „ścian i budynków z zewnątrz” w jednym rzucie: ściany wnętrz mają wzorzec A, ale fasady, dachy i kafle zewnętrzne (śnieg, drogi) nie mają zdefiniowanego pipeline'u.
- Spójność świata zewnętrznego i fasad: w `art/concept/locations/` są tylko `okno` i `posterunek`.

## 2. Zdiagnozowane przyczyny niespójności

Diagnoza oparta na repo (`art/concept/prompts.jsonl`, 452 wpisy, STYLE.md, `57`, zrzut `1200_dzien.png`) i źródłach z §4. Przyczyny w kolejności wpływu **[wniosek]**:

1. **Rzut nie jest wejściem, tylko życzeniem.** Prompty gazet (`prompts.jsonl`, ostatnie wpisy) mówią „keep exactly the same footprint, size and camera as the grey box”, a model dostaje szarą bryłę jako *kontekst*, nie jako warunek przestrzenny. Pixellab dokumentuje `view` (`none`, `low top-down`, `high top-down`, `side`) jako podpowiedź **[zweryfikowane: [OpenAPI Pixellab](https://api.pixellab.ai/v2/openapi.json) (strona obcięta, enum widoczny w opisie `animate-with-text-v2`), [wtórne]]**, a `57` odnotowuje wprost, że obraz stylu nie blokuje geometrii. FLUX.2 przyjmuje do 4 referencji (klein) i obiecuje „identity”, nie geometrię **[zweryfikowane: [BFL FLUX.2 overview](https://docs.bfl.ai/flux_2/flux2_overview)]**; Gemini podobnie obiecuje spójność postaci i stylu, nie kamery **[zweryfikowane: [Gemini image generation](https://aistudio.google.com/docs/image-generation)]**.
2. **Różne źródła rzutu dla różnych klas obiektów.** Postacie: koncept FLUX w wysokiej kamerze. Kanapa i lodówka: `create_map_object` `high top-down`. Lada: prowadnica + Pixellab. Szafy i aneks: Pixellab z opisu, więc „pod kątem lub z przodu” (STYLE.md). Każda droga ma własną kamerę.
3. **Nasz rzut jest niestandardowy, a opisy w sieci i dane treningowe zakładają inny.** ADR 0002 mówi: głębokość 1:1 (wierzch blatu `d × 40 px`, front `h × 40 px`). W literaturze pixel-artowej „3/4 top-down” to zwykle widok z ok. 45° z *skróconym* frontem względem wierzchu (Slynyrd: „about 3/4 of both the roof and facade”, front „shortened compared to the top”) **[zweryfikowane: [Slynyrd, Pixelblog 3](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)]**, a dyskusje o grach typu Ultima VII opisują oblique z połową głębokości (cabinet) i 2:1 dla ścian **[wtórne: [OpenGameArt](https://opengameart.org/node/3541), [OpenGameArt komentarz](https://opengameart.org/comment/5729)]**. Model „zna” więc inny kąt niż nasz, a słowa „3/4 top-down” w prompcie ciągną w jego stronę **[wniosek]**.
4. **Skala generacji ≠ skala w grze.** Generacja w ×4 i `unfake downscale` niszczy detal (STYLE.md, `57` §3); natywne generowanie małych obiektów (<32 px) wychodzi poza zakres Pixellab (`create_map_object` min. 32×32, wyniki <24 px chwiejne, `57` §2).
5. **Brak twardej definicji światła w sprite'ach.** STYLE.md każe rysować albedo bez światła, ale generator i tak wypieka cieniowanie z góry-lewej lub z przodu (różnie dla każdego obiektu); normal mapy z `normals.gd` są heurystyką („górne N wierszy = UP”), co dodatkowo zależy od tego, czy bok jest widoczny **[wniosek z `46` §2]**.
6. **Brak automatycznej kontroli.** Zgodność rzutu, palety i wymiarów sprawdza człowiek wzrokiem na arkuszu (zasada „decyzje przez porównanie”), co nie skaluje się na kilkadziesiąt obiektów.

## 3. Rzut 3/4: definicja i konkretna specyfikacja dla gry

### Co mówią źródła
- Slynyrd: widok 3/4 to „45 stopni z góry”, widać ok. 3/4 dachu i fasady, „uniformity takes priority over realism”; wszystkie elementy sceny mają trzymać te same zasady; światło najnaturalniej z jednego górnego rogu; kontur można pominąć przy planowanej palecie **[zweryfikowane: [Slynyrd](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)]**.
- Retronator: rzuty równoległe dzielą się na ortograficzne i oblique; 3/4 w grach to rodzina rzutów osiowych/oblique, a „cabinet” jest najczęstszym obliquem **[wtórne: [Retronator, część 1](https://medium.com/retronator-magazine/aa3d051c137d)]**. (Strona zapowiada definicje techniczne w kolejnych częściach, ich nie czytałem.)
- Praktyczna metoda z dyskusji: narysuj obrys z góry, a wysokość przesuń w pionie; wysokość i głębokość mają stałe współczynniki **[wtórne: [OpenGameArt](https://opengameart.org/comment/5729)]**.
- Dla animacji i pixel artu *wierzchy* i *fronty* to dwa różne obszary: wierzch rośnie z głębokością, front z wysokością.

### Rzut projektu (wniosek z ADR 0002 i `46` §2)
- **Nazwa robocza: oblique 1:1 („planometryczny”, głębokość nieskrócona).** Punkt (x, y, z) ↦ ekran (x, y + z) w px·40 **[wniosek]**; pojęcie „military/planometric” to moje nazewnictwo, niezweryfikowane.
- Realizacja w Blenderze: kamera ortogonalna pochylona o 45° w dół bez obrotu wokół pionu; obraz rozciągnięty w pionie o √2, wtedy blat i front mają skalę 1:1, a boki (normalne ±X) są prostopadłe do kierunku patrzenia, więc niewidoczne **[wniosek, rachunek w `46` §2]**. Blender dokumentuje kamerę ortogonalną z parametrem „Orthographic Scale” **[niezweryfikowane w tym researchu: strona manuala obcięta przy pobraniu, zob. [Blender Cameras](https://docs.blender.org/manual/en/latest/render/cameras.html)]**.
- **Stałe do wpisania w jednym miejscu (nowy plik `art/concept/_style/PROJECTION.md` lub sekcja w STYLE.md):**

| Parametr | Wartość | Źródło |
|---|---|---|
| Skala | 1 m = 40 px (x, y, z) | ADR 0002 |
| Wierzch obiektu | szer. × głęb. · 40 px, leży nad frontem | `46` §2 |
| Front obiektu | szer. × wys. · 40 px, płasko do kamery | `46` §2 |
| Boki obiektów | **niewidoczne** (0 px) | `46` §2 |
| Ściana tylna | 2,6 m = 104 px lico (w wnętrzach 1,9 m = 76 px wg ADR; do uzgodnienia, patrz §7) | STYLE.md vs ADR 0002 |
| Kafel | 32 px (0,8 m), tylko siatka podłóg i ścian | ADR 0002 |
| Postać | wzrost × 40 px, płótno 80×80 | ADR 0002 |

- **Konsekwencja dla postaci:** w rzucie 1:1 postać to *front* skalowany 40 px/m plus głowa z odrobiną wierzchu. Obecni Badacz i Krogg są narysowani z wyraźnym spojrzeniem z góry na głowę i ramiona (`pixel_ref.png`), co jest zgodne z „wysoką kamerą” z Pixellab, ale **nie jest tym samym nachyleniem co lada** (czysty front + prosty wierzch). Czy to różnica widoczna dla gracza, rozstrzyga arkusz porównawczy; w grze (`1200_dzien.png`) wygląda akceptowalnie **[wniosek z obrazu]**.
- **Rozstrzygnięcie, które trzeba zapisać:** ADR mówi „bez skrótu głębokości”, a STYLE.md podaje ścianę 2,6 m, ADR 0002 zmianą z ticketu posterunku 1,9 m (76 px). Jedna liczba w jednym pliku.

### Zasady rzemieślnicze (z źródeł pierwotnych i ustaleń projektu)
- **Skala pikseli:** jedna dla wszystkiego, bez zmieniania skali ani rotacji sprite'ów (ADR 0002: kamera nie przybliża się we wnętrzach).
- **Kontur:** jeden: 1 px ciemny kolor z palety (`15181f`/`1e1a17`), *selektywny* (ciemniejszy odcień własnego koloru) dla drobiazgów (`57` §4). Slynyrd dopuszcza brak konturu; trzymamy się konturu, bo tak są narysowane postacie **[wniosek]**.
- **Paleta:** 32 kolory projektu; rampy zdefiniowane w STYLE.md. Format: `palette.hex` (jeden kolor na linię) jest formatem Lospec **[zweryfikowane: [Lospec palette list](https://lospec.com/palette-list/tag/pixel-art), „.HEX file”]**.
- **Światło:** w sprite'ach neutralne albedo (STYLE.md); jedyne „wypieczone” światło to stała konwencja form: wierzch o 1 stopień rampy jaśniejszy niż front, dolna krawędź frontu o 1 stopień ciemniejsza, światło umowne z lewej-góry (zgodnie z zaleceniem Slynyrda o górnym rogu) **[wniosek, propozycja do zatwierdzenia]**. Wszystko inne to normal mapa + światła 2D.
- **Normal mapy:** z renderu Blendera, nie z heurystyki `normals.gd` (`46` §2), a przynajmniej tą samą konwencją dla wszystkich asset-ów (wierzch → UP, front → SOUTH).
- **Brak ditheringu**, brak antialiasingu na krawędziach silhouette.

## 4. Narzędzia AI: co faktycznie obsługują

| Narzędzie | Co daje do kontroli rzutu/stylu (wg dokumentacji) | Czego NIE daje | Ocena dla nas |
|---|---|---|---|
| **Pixellab** | `view` (`low top-down`/`high top-down`/`side`), `direction` (8 kierunków), `style_images` w `generate-with-style-v2` (rozmiar wyjścia z obrazów), `reference_image` w `create-character-v3`, `/rotate`, `create-tileset` (top-down), `create-isometric-tile` [zweryfikowane: [OpenAPI](https://api.pixellab.ai/v2/openapi.json), [llms.txt](https://api.pixellab.ai/v2/llms.txt)] | blokady geometrii; `view` to podpowiedź (`57`) | Dobry do postaci i dużych boxów natywnie; nie jako źródło rzutu |
| **Retro Diffusion API** | style `rd_pro__topdown`, `rd_plus__topdown_asset/item/map`, `rd_pro__isometric`; do 9 obrazów referencyjnych (tylko RD Pro) „guide style and content without being redrawn”; `input_palette` (obraz palety, <1 MB); `return_pre_palette`; seed; `GET /v2/styles/selector` [zweryfikowane: [api-examples](https://github.com/Retro-Diffusion/api-examples)] | brak ustawienia perspektywy (strona go nie opisuje); styl `topdown` to ich definicja kąta, nie nasza | Dobra paleta i referencje; kąt trzeba zmierzyć na próbkach; płatne (cena w `46`) |
| **Scenario** | trening własnych modeli/LoRA stylu; MCP | nie sprawdziłem szczegółów (strona docs zwróciła 404 przy tej próbie) | **[niezweryfikowane]**; patrz `08`, `24a` |
| **FLUX.2 (BFL), klein/dev** | edycja z referencjami: klein do 4, dev do 6 zalecanych, max/pro/flex do 8 (API) [zweryfikowane: [BFL overview](https://docs.bfl.ai/flux_2/flux2_overview)]; LoRA stylu (klein 4B base: min. 12 GB VRAM, wg `46`) | referencja to kontekst; ControlNet oficjalny nie znaleziony (`46`) | Nasz obecny silnik konceptów; potrzebuje renderu jako wejścia, nie jako „podpowiedzi” |
| **Gemini (Nano Banana)** | do 14 referencji; Pro: do 5 postaci i 3 stylu; edycja wieloturowa [zweryfikowane: [Gemini image generation](https://aistudio.google.com/docs/image-generation)] | brak twardej kontroli kamery | Wygodne do konceptu; rzutu nie gwarantuje |
| **ControlNet (SD/SDXL)** | warunki: canny, depth, normal, HED, M-LSD, segmentacja, scribble, pose [zweryfikowane: [lllyasviel/ControlNet](https://github.com/lllyasviel/ControlNet)] | nie trzyma pikseli; zmiana modelu bazowego zmienia styl | Zapas (droga B w `46`); siła warunku do strojenia |
| **GPT Image** | edycja z maską, przezroczyste tło (wg `24d`) | brak kontroli kamery | Nie sprawdzałem ponownie; patrz `24d` |

Wniosek: **żaden z tych produktów nie gwarantuje rzutu z promptu lub referencji**. Gwarancję daje tylko geometria, która *jest* wejściem (render, prowadnica, maska). To jest ten sam wniosek co w `46`/`57`, teraz potwierdzony dokumentacją ze strony producentów.

## 5. Pipeline 3D-wspomagany i pikselizacja

- **Precedens:** Graveyard Keeper 2 (3D + pixel art ze stałego kąta) i HD-2D (`02` §2-3, `11b` §1). Nie wymaga 3D w grze: 3D służy tylko do generowania sprite'ów.
- **Render:** Blender headless (`blender --background --python rig.py -- spec.json`), trzy wyjścia: albedo (płaskie/Emission), normal (w konwencji gry), maska alfa (`46` §2, `24b`).
- **Pikselizacja:** `unfake` (`tools/unfake/unfake.exe`) ma podkomendy `detect`, `snap`, `downscale`, `quantize`; metody `dominant`, `median`, `content-adaptive`; paleta stała lub `libimagequant`; wykrywanie siatki (runs/edge) i siatki ułamkowe [zweryfikowane: [unfake.js README](https://github.com/jenissimo/unfake.js); README nie podaje listy flag]. To już mamy, więc zachowujemy jako wspólny etap końcowy.
- **Aseprite:** skrypty Lua od wersji 1.2.10, API `app.sprite`, `Sprite()`; niektóre funkcje (`os.execute`, `io.open`) pytają o zgodę [zweryfikowane: [Aseprite API](https://www.aseprite.org/api/)]. Uruchomienie `--batch --script` nie było w pobranym tekście, więc **[niezweryfikowane]**; Aseprite nie jest w `CLAUDE.md` wśród zainstalowanych narzędzi (Node, .NET, Git, LÖVE), więc zakładamy, że nie jest dostępny, dopóki użytkownik nie potwierdzi. Do ręcznego dorysowywania małych rzeczy mamy `pixelart_workbench` Pixellab (`57`).
- **Obiekty organiczne:** TRELLIS.2/Pixal3D → mesh → ten sam rig (`46` droga C).

## 6. Opcje porównane i rekomendowany pipeline

| Opcja | Spójność rzutu | Spójność stylu | Koszt/wysiłek | Uwagi |
|---|---|---|---|---|
| 0. Status quo (Pixellab/FLUX per klasa obiektu) | niska (3+ źródła kamery) | średnia | niski | dokładnie to, co dziś psuje |
| 1. **Blender rig dla wszystkiego sztywnego + wspólny etap końcowy** | dokładna co do piksela | wysoka (ten sam `unfake`/paleta/kontur), ryzyko „CG” | instalacja Blendera, 1-2 h na rig, potem minuty na obiekt | rekomendowane jako rdzeń |
| 2. 1 + img2img/`image_to_pixelart`/RD `edit` z renderem jako wejściem | jak 1 (maska z renderu przycina dryf) | najlepsza obok postaci, jeśli denoise niski | + czas GPU lub 0,18 USD/obraz (RD Pro wg `46`) | warstwa na 1, jeśli A0 odstaje |
| 3. ControlNet (depth/canny z renderu) | dobra, nie dokładna | inny model = inny styl | nowe modele 10-15 GB | zapas (`46` droga B) |
| 4. LoRA stylu | nie dotyczy rzutu | wysoka | min. 12 GB VRAM wg BFL; za mało danych dziś | po 15-30 zaakceptowanych assetach |
| 5. Ręcznie w Aseprite/workbench | pełna | pełna | wolne; dobre dla <32 px | dla drobiazgów |

### Rekomendowany pipeline (do potwierdzenia eksperymentem)

**Klasa 1: sztywne bryły (meble, drzwi, okna, szafy, aneks, kaloryfery, elementy ścian i fasad, kafle)**
1. Spec JSON (wymiary w m, części, materiał z palety) → `prop_rig.py` → render albedo / normal / maska kamerą 45° ortho z rozciągnięciem √2.
2. Wariant A0: `unfake downscale` → `quantize --palette art/concept/_style/palette.hex` → `prop_outline.gd`. Wariant A1: ten sam render jako wejście edycji (FLUX.2 klein img2img 0,25-0,5 lub Pixellab/RD `edit`), wynik przycięty maską z renderu.
3. Automatyczny test (§7a) → arkusz ×4 obok `pixel_ref.png` → zatwierdzenie człowieka → `game/world/.../sprites/`.

**Klasa 2: postacie**
1. Szary manekin (wysokość z rosteru) wyrenderowany tą samą kamerą → wejście edycji FLUX/Gemini do arkusza konceptu w rzucie gry **[wniosek, do sprawdzenia: czy model utrzyma kamerę manekina]**.
2. Dalej jak dziś: `crop_ref` → Pixellab `image_to_pixelart` 80×80 → `create_character` v3 → chód → skrypty czyszczące → ten sam test palety.

**Klasa 3: organika i drobiazgi (krzesła, rośliny, kubki, gazety)**
- Krzesła/rośliny: TRELLIS.2/Pixal3D → mesh → rig klasy 1.
- Drobiazgi <32 px: szkic AI natywnie, dokończenie w `pixelart_workbench` (`57` §5).

**Klasa 4: budynki z zewnątrz i kafle** (luka): fasada jako moduły w rig (ściana, okno, drzwi, dach) renderowane tą samą kamerą; kafle terenu 32 px jako płaskie wierzchy z render albedo (bez przesunięcia kamery, bo wierzch ma skalę 1:1). Pixellab `create-tileset` (top-down) jest dostępny, ale jego kąt nie jest zmierzony **[wniosek, niezweryfikowane]**.

## 7. Guardrails

### a) Automatyczne kontrole (propozycja, `tools/asset_check/check.mjs`, Node, bez zależności)
- **Paleta:** każdy nieprzezroczysty piksel należy do `palette.hex` (zero tolerancji po `unfake quantize`).
- **Siatka:** brak pół-przezroczystości (alfa tylko 0/255), brak antyaliasingu na obrysie.
- **Wymiary:** bbox maski = (szer.+…)·40 px zgodnie ze specem ±1 px (np. lada 192×66, szafka 22×78 wg `46`).
- **Brak boku:** w skrajnych kolumnach frontu nie ma pikseli innej rampy niż front (heurystyka); dla renderu pewniejsze: bok ma 0 px z konstrukcji.
- **Konwencja światła:** średnia luminancja wierzchu ≥ front (+1 stopień rampy), bo to nasza stała konwencja.
- **Kontur:** obrys 1 px w kolorze z listy konturowej.
- **Rozmiar postaci:** wysokość sylwetki = wzrost·40 ±1 px.
- Wynik: lista błędów; asset nie wchodzi do `game/` bez zielonego testu.

### b) Dokumenty i szablony
- `PROJECTION.md` z tabelą z §3 jako jedyna kopia stałych; STYLE.md i ADR do niej linkują.
- Jedna tabela spec obiektów (JSON) = źródło dla rigu i dla testu wymiarów (STYLE.md ma tabelę wymiarów, dziś w Markdown).
- Szablon promptu *tylko* dla etapu A1/konceptu; nie opisuje kamery, bo kamerę niesie wejście (wzór z STYLE.md plus zdanie o materiale).
- Referencja stylu dla Pixellab/RD: fragment kanapy lub lady w skali docelowej (`57` §5; Pixellab wymaga, by obraz stylu mieścił się w płótnie docelowym).

### c) Porządek pracy
- Seed i parametry zapisywane w `prompts.jsonl` (już jest) + spec JSON w repo.
- Zmiany rzutu tylko przez `PROJECTION.md` + przerenderowanie, nie przez poprawki pojedynczych sprite'ów.

## 8. Pytania otwarte

1. Czy render Blendera po `unfake`+paleta+kontur nie odstaje od postaci Pixellab (eksperyment `46` §6, jeszcze niewykonany)? Jeśli tak, następny krok to A1 lub RD Pro `edit`.
2. Wysokość ściany: 2,6 m (STYLE.md, 104 px) czy 1,9 m (ADR 0002, 76 px w wnętrzach)? Do ujednolicenia przed pierwszym renderem fasad.
3. Czy postacie w obecnym kącie z Pixellab (głowa widziana z góry) mają być przerobione na „front + wierzch głowy”, żeby pasować do ładnych boxów, czy to akceptowalna różnica? Decyzja przez porównanie na arkuszu.
4. Konwencja światła w sprite'ach: czy dopuszczamy wypieczone „1 stopień rampy” (§3), czy ściśle neutralne albedo plus tylko normal mapa (STYLE.md)?
5. Czy kąt `high top-down` w Pixellab i `rd_*__topdown` w Retro Diffusion jest zgodny z naszym 1:1 (nie zmierzone; potrzeba próbki: kostka 1×1×1 m i pomiar proporcji wierzchu do frontu)?
6. Aseprite: czy jest zainstalowany i czy mamy `--batch --script`? Dziś zakładamy, że nie.
7. Fasady i teren zewnętrzny: nie ma wzorca i nie sprawdzałem precedensów (`43` dotyczy wnętrz).
8. Blender: instalacja wymaga zgody człowieka (zasada globalna: pytać przed instalacją globalnych pakietów).

## Źródła
- [Slynyrd, Pixelblog 3: Graphical Projections](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)
- [Retronator, Game developer's guide to graphical projections, część 1](https://medium.com/retronator-magazine/aa3d051c137d) [wtórne]
- [OpenGameArt: dyskusja o oblique/cabinet](https://opengameart.org/node/3541), [komentarz](https://opengameart.org/comment/5729) [wtórne]
- [Retro Diffusion api-examples](https://github.com/Retro-Diffusion/api-examples)
- [Pixellab API: OpenAPI](https://api.pixellab.ai/v2/openapi.json), [llms.txt](https://api.pixellab.ai/v2/llms.txt)
- [BFL FLUX.2 overview](https://docs.bfl.ai/flux_2/flux2_overview)
- [Gemini image generation](https://aistudio.google.com/docs/image-generation)
- [lllyasviel/ControlNet](https://github.com/lllyasviel/ControlNet)
- [unfake.js](https://github.com/jenissimo/unfake.js)
- [Aseprite API](https://www.aseprite.org/api/)
- [Lospec palette list](https://lospec.com/palette-list/tag/pixel-art)
- Repo: `docs/adr/0002-widok-3-4-i-drabinka-swiatla.md`, `art/concept/_style/STYLE.md`, `art/concept/prompts.jsonl`, `art/reference/game/1200_dzien.png`, `docs/research/02`, `08`, `11b`, `24d`, `43`, `46`, `57`.
