> Kopia z game1 (`repo/game1/docs/research/57-pixellab-meble.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Pixellab: meble i drobiazgi w rzucie gry

Data researchu: **2026-11-03**. Powód: postacie z Pixellab wyszły świetnie, a propsy (sterta gazet, szafki, krzesła, aneks) źle. Ticket 22 w `.scratch/dzien-na-posterunku/issues/22-sterta-gazet-asset.md`.

Oznaczenia przy twierdzeniach:
- **[zweryfikowane]**: wynik odpowiedzi `search_help` Pixellab (pytania tylko do czytania, bez generacji), `get_pro_flash_capabilities`, albo zapis w repo (plik w nawiasie).
- **[z pamięci]**: wiedza ogólna, niesprawdzona w tym researchu.
- **[wniosek]**: moje rozumowanie.

Nie wykonano żadnej generacji ani wywołania płatnego. Użyte: `search_help` (2x), `get_pro_flash_capabilities`, WebSearch (1x, strony docs Pixellab nie mają opisu `create_map_object`).

## Streszczenie

1. **Postacie wyszły, bo wejściem był gotowy obraz w dobrym rzucie, a Pixellab tylko go pikselizował i obracał, na natywnym płótnie bez zmniejszania** **[zweryfikowane: `docs/wayfinder/tickets/22-pipeline-assetow.md`]**. Rzut dawał koncept (ComfyUI), nie Pixellab. Propsy z samego opisu nie mają tej kotwicy.
2. **Żadne narzędzie Pixellab nie ma blokady rzutu „blat nad płaskim frontem”.** Widoki `low/high top-down` i `side` są wbudowane, a obraz stylu to „soft guidance, nie blokada geometrii” **[zweryfikowane: `search_help`]**. Rzut musi pochodzić z wejścia (prowadnica albo render), nie z promptu.
3. **Nasz główny błąd to generowanie w ×4 i zmniejszanie.** Pixellab rysuje dobrze na natywnej siatce. `unfake` na obrazie malowanym w ×4 niszczy detal, a przy 20-26 px nie zostaje nic **[wniosek, ticket 22]**. Poprawka: obiekt małych rozmiarów generować natywnie i poprawiać ręcznie (`pixelart_workbench`, darmowe).
4. **Kanapa (`sofa.png`, 96×80) wyszła dobrze, bo jest duża i ma prostą bryłę**; powstała z `create_map_object` (basic, `high top-down`, 1 gen.) w prototypie **[zweryfikowane: ticket 22, wpis o pokoju socjalnym; w repo gry nie ma śladu generacji, tylko commit portujący]**. Pixellab radzi sobie z dużymi obiektami wypełniającymi płótno. Drobiazgi 20-30 px są poza tym, w czym jest dobry.
5. **Rekomendacja:** dwa tory zależnie od rozmiaru (§5). Duże meble: `create_image_pro_flash`/`create_object_pro_flash` albo `create_image_pixflux` z prowadnicą, z `style_image` z kanapy, natywnie. Drobiazgi: AI tylko jako szkic faktury, kształt i czytelność robimy `pixelart_workbench` albo przesadzamy skalę.

## 1. Jak powstały postacie i kanapa

**Postacie** **[zweryfikowane: `docs/wayfinder/tickets/22-pipeline-assetow.md`, zakończenie ticketu; `26-skala-postaci-75px.md`]**:
- Łańcuch: arkusz konceptu z ComfyUI (FLUX.2 klein) w wysokiej kamerze 3/4 → `crop_ref.gd` (wycięcie, skala do wzrostu × 40 px, margines pod stopami) → Pixellab `image_to_pixelart` w trybie *faithful*, siła 200, **wprost 80×80** → `remove_bg.gd` → `create_character` v3 z referencją, 4 kierunki → chód `walk`/`skeleton-v3` → drobne skrypty czyszczące.
- **Nie było zmniejszania.** Płótno 80×80 jest natywne, postać 75 px wysokości.
- Dlaczego działa: (a) rzut i proporcje nadaje referencja, więc Pixellab nie zgaduje kamery; (b) postacie są *tym*, na czym model był trenowany i optymalizowany (osobny, dopracowany pipeline); (c) obrót v3 zachowuje tożsamość.
- Znane wady z tego samego ticketu: referencja z poziomu oczu daje postać z poziomu oczu (v3 „tylko obraca, kamery nie zmienia”), a Krogg z samego opisu w `high top-down` miał kamerę z góry. Czyli **widok z etykiety działa dla opisu, ale referencja go nadpisuje**.

**Meble** **[zweryfikowane: ticket 22, wpisy z 2026-10-28]**:
- `create_map_object` (basic, `high top-down`, 1 gen./szt., 15-45 s): kanapa, lodówka, tablica korkowa, kalendarz, kaloryfer „dobre”; krzesła, stół, aneks „złe proporcje i mieszane rzuty”.
- Biurko z `create_image_pixflux` 100×80 dorzuciło krzesło (obiekt bez kontekstu).
- Wniosek własny tamtego ticketu: Pixellab bez kontekstu miesza rzuty, więc meble generujemy dopiero z ustalonym kierunkiem i wymiarami w metrach.

Wzorzec: **to, co dobre, ma duże płótno i prostą bryłę**; to, co złe, ma wymagający rzut (krzesło, aneks, sterta o nieregularnym kształcie).

## 2. Co oferują narzędzia Pixellab (dla naszego rzutu)

Wszystko poniżej z `search_help` i `get_pro_flash_capabilities` **[zweryfikowane]**, o ile nie zaznaczono inaczej.

| Narzędzie | Rozmiar | Wejście obrazowe | Uwagi dla propsów |
|---|---|---|---|
| `create_map_object` | min. 32×32, szer./wys. osobno | brak obrazu startowego; `background_image` tylko jako dopasowanie stylu, tworzy nowy obiekt | widok `low/high top-down`/`side`; outline, shading, detail jako podpowiedzi; to użyliśmy dla kanapy |
| `create_1_direction_object` | tylko kwadrat 16-256 | `style_images` (PNG/JPEG, maks. 256×256), `palette`, `max_colors` | zestaw kandydatów przy małych rozmiarach; rozmiar wyniku wyznacza obraz stylu; `select_object_frames` |
| `create_object_pro_flash` | dowolny, wielokrotność 4, 16-256 (beta); presety od 16×16 | jeden `style_image`, opcje kopiowania palety, konturu, szczegółu, cieniowania | `n_directions` 1 trzyma natywny rozmiar; 0 obrazów referencyjnych treści; nie blokuje rzutu |
| `create_image_pro` | dowolny rozmiar | `reference_images` (z etykietami, treść) + `style_image` | kilku kandydatów; droższy; najlepsza kontrola palety |
| `create_image_pixflux` | z obrazem startowym | `init_image` + `init_image_strength` | trzyma rzut z prowadnicą, ale przy sile ≥150 kopiuje ją (ticket 22); kontrola `view` słabo kierująca |
| `create_image_pixen` | małe sprite'y | brak obrazu startowego | tani, czysty; bez prowadnicy nie trzyma rzutu |
| `edit_image_pro_flash` / `inpaint_image_pro_flash` | edycja od 32×32 | 1 referencja | poprawki lokalne bez konwersji pikseli |
| `image_to_pixelart` (+ `_pro_flash`) | docelowy rozmiar wprost | pełny obraz (koncept) | to samo narzędzie, co dla postaci; zachowuje rzut wejścia **[wniosek z §1]** |
| `unzoom_image`, `correct_pixelart`, `reduce_colors` | | | odzyskanie siatki z obrazu narysowanego w większej skali; czyszczenie |
| `pixelart_workbench` | | | **darmowe** rysowanie i edycja pikseli przez agenta |

Dodatkowe fakty:
- **Palette:** `palette` przyjmuje kolory hex; `palette_name` to tylko etykieta; `max_colors` ogranicza liczbę kolorów **[zweryfikowane]**.
- **Seed:** wspierany tam, gdzie jest, ale nie jest ograniczeniem rzutu ani kotwicą stylu; `project_id` to kontekst, nie blokada stylu **[zweryfikowane]**.
- **Rozmiary:** poniżej ok. 24×24 wynik bywa chwiejny; `create_map_object` wymaga min. 32 **[zweryfikowane]**.
- **Siatka pikseli:** Pro Flash sam odzyskuje siatkę (Unzoom); gdy rysunek jest zbyt gruby lub zbyt duży, jest przerysowywany przez image-to-pixel-art **[zweryfikowane: `get_pro_flash_capabilities`]**. Obraz stylu musi mieścić się natywnie w płótnie docelowym (mniejszy jest centrowany bez skalowania), więc **referencja stylu ma mieć rozmiar docelowy lub mniejszy** **[zweryfikowane]**.
- Pro Flash `create` nie przyjmuje obrazów referencyjnych treści (`max_reference_images: 0`), tylko `style_image`; `edit` i `inpaint` przyjmują 1 referencję **[zweryfikowane]**.
- Pixellab mówi wprost, że spójność zestawu daje **jedna kotwica stylu używana przy każdym obiekcie**, a sam seed czy wspólny prompt tego nie załatwia. Do małych propsów radzi prosty prompt o sylwetce i kluczowych szczegółach oraz unikanie napisów **[zweryfikowane: `search_help`]**.
- `create_normal_map` istnieje, ale własny `normals.gd` wygrał (ticket 22), więc bez zmian.

## 3. Czemu sterta gazet nie wyszła (diagnoza)

**[wniosek, na podstawie ticketu 22]**
1. **Brak kotwicy rzutu przy tekście:** model dobiera widok z zasobu typowych obrazów (sterta z boku, szafka z przodu). Prowadnica to trzyma, ale `init_image` jest pomysłem na „obraz startowy”, nie na „rzut”, więc przy sile ≥150 jest kopiowana, a przy 50-70 daje tylko trochę faktury.
2. **Zła skala generacji:** ×4 i zmniejszanie (`unfake -m dominant`) usuwa to, co model narysował jako pojedyncze piksele. Przy ×1/4 zostaje 20×26 px bez czytelnej sylwetki.
3. **Nie ma czego trenować:** sterta gazet w 3/4 z płaskim frontem i widocznym blatem to bardzo rzadki obraz. Przy 12 px blatu i 14 px frontu cała informacja to ok. 6 krawędzi kartek.
4. **Gen. 32×32 z prowadnicą 1×:** prowadnica i wynik mają tę samą siatkę, więc narzędzie nie ma luzu, żeby „dopowiedzieć” i kopiuje.

Dłuższe wnioski dla sprite'ów 20-30 px: patrz §4.

## 4. Czytelność małych obiektów (20-40 px)

Praktyka pixel artu **[z pamięci]**, spójna z tym, że 40 px/m daje dużo małych rzeczy:
- **Sylwetka ponad szczegół.** Obiekt musi być rozpoznawalny jako czarny kształt. Sterta gazet to prostokąt z postrzępionym górnym brzegiem, nie 12 kartek.
- **2-3 wartości na materiał** i wyraźna krawędź światła na górnej i przedniej krawędzi blatu. Kontur 1 px w ciemniejszym odcieniu własnego koloru (selektywny kontur) zamiast czarnego.
- **Jeden wyróżnik na obiekt:** pasek sznurka, jeden jasny prostokąt „nagłówka”, kolorowa okładka. Napisów nie rysować.
- **Przesadzenie skali:** drobiazgi na stole i podłodze (gazety, kubki, teczki, książki) rysuje się o 20-50% większe niż ścisła skala metryczna, bo gracz czyta je razem z postacią 75 px. Sterta 0,4×0,3 m to 16×12 px; przy 26×34 px (z blatem) jest już przesadzona i nadal wygląda słabo, co sugeruje, że problemem jest **jakość rysunku, nie rozmiar** **[wniosek]**.
- **Rysunek ręczny wygrywa przy < 32 px.** Przy tak małych sprite'ach każdy piksel jest decyzją; `pixelart_workbench` pozwala agentowi narysować i przejrzeć go bez kosztu generacji.
- **Cień kontaktowy** (ciemny pasek pod frontem) czyta się lepiej niż wygładzony gradient i zakotwicza obiekt w podłodze; reszta cienia i tak pochodzi ze świateł Godot.

Uwaga projektu: decyzje o wyglądzie podejmujemy przez porównanie na arkuszu obok kanapy i lady (pamięć projektu: *Look decisions by comparison*).

## 5. Rekomendowany przebieg

### Wybór toru według rozmiaru

| Klasa | Przykłady | Tor |
|---|---|---|
| A. Duży box z płaskim frontem (≥ 48 px szerokości) | kanapa, lodówka, szafy, biurka, aneks | `create_image_pro_flash` / `create_object_pro_flash` albo `create_map_object`, natywnie, z kotwicą stylu z kanapy |
| B. Meble o złożonej bryle | krzesła, ekspres | prowadnica + `create_image_pixflux`, albo kształt rysowany ręcznie |
| C. Drobiazgi (< 32 px) | sterta gazet, kubek, teczka | szkic AI w natywnym rozmiarze i **dokończenie w `pixelart_workbench`**, albo całkowicie ręcznie |

### Zalecane parametry (do potwierdzenia eksperymentem, bo to wnioski)

**Wspólne zasady**
- **Rozmiar natywny = rozmiar w grze.** Bez generacji w ×4 i bez `unfake downscale`. Gdy trzeba skalować, tylko całkowite mnożniki i `unzoom_image`.
- **Kotwica stylu:** `sofa.png` (i ew. jeden kadr postaci) jako `style_image` (Pro Flash) albo `style_images` (`create_1_direction_object`). Referencja ma mieć wymiary mniejsze lub równe płótnu docelowemu **[zweryfikowane: `style_reference_fit`]**. Dla małych propsów zrobić kotwicę docelowej wielkości: wyciąć z kanapy fragment 32×32 (róg z blatem i frontem), żeby styl odpowiadał rozmiarowi.
- **Paleta:** `palette` z `art/concept/_style/palette.hex` jako podpowiedź, nie jako twarde wymaganie (ticket 22: `--palette` zbyt mocno zmienia kolory); kwantyzacja i tak jest po stronie `unfake quantize` / `reduce_colors`.
- **Opis:** wymiary i rzut w słowach, jedno zdanie o materiale, bez napisów. Wzór: *„front-facing flat view with the top face visible directly above the front face, no side faces visible, [obiekt], pixel art, 3/4 top-down game view”*. Słowa o rzucie pomagają słabo, ale nie szkodzą.
- **Tło:** `no_background` (Pro Flash `supports_no_background: true`).
- **Wybór:** generować po kilku kandydatów i oceniać na arkuszu ×4 obok lady i kanapy.

**Tor A (duże boxy)**
1. `create_object_pro_flash(width=W, height=H, n_directions=1, style_image=sofa_crop, style: kopiuj paletę, kontur, szczegół, cieniowanie, no_background)`, W i H wielokrotności 4, wyliczone z tabeli w `STYLE.md` (40 px/m, blat + front).
2. Jeśli rzut się nie trzyma: ta sama generacja przez `create_image_pixflux` z `init_image` = prowadnica w natywnej skali, `init_image_strength` 50-70 (wartość ze zmierzonych prób), albo konwersja pełnego konceptu przez `image_to_pixelart` (jak postacie, §1), gdzie koncept ma właściwy rzut (render Blender z `46-generowanie-mebli-3-4.md` albo FLUX z szarą bryłą).
3. Poprawki lokalne: `inpaint_image_pro_flash` (od 32×32) lub `pixelart_workbench`.

**Tor C (drobiazgi)**
1. Szkic: `create_image_pro_flash` 32×32 (albo `create_1_direction_object` size 32 z `style_images`; daje 16 kandydatów w jednym strzale przy ≤ 85 px, co obniża koszt na kandydata **[z `24a`]**).
2. Wybrać najlepszą sylwetkę i **narysować fakturę i krawędzie ręcznie w `pixelart_workbench`** na tej siatce (darmowe): górna krawędź kartek, sznurek, jeden jasny prostokąt.
3. Powiększyć fizycznie o 20-30% względem metrycznej skali, jeśli czyta się słabo.
4. `unfake quantize`, selektywny kontur, `normals.gd prop`.

### Czego nie robić
- Nie generować w ×4 ze zmniejszaniem.
- Nie wymuszać rzutu samym promptem.
- Nie używać siły `init_image_strength` ≥ 150.
- Nie oczekiwać, że seed da spójność.
- Nie generować kompletnych krzeseł i aneksów bez prowadnicy lub konceptu.

## 6. Plan taniego eksperymentu (≤ 8 generacji)

Przed startem `get_balance`. Oceniamy wyniki na arkuszu ×4 obok `lada.png` i `sofa.png`. Dwa obiekty: **sterta gazet** (tor C) i **szafka na akta 0,55×0,6×1,35 m = 22×78 px** (tor A, pudełko, bardzo podobne do lady).

| # | Co | Narzędzie i parametry | Hipoteza |
|---|---|---|---|
| 1 | Sterta, 32×32 | `create_image_pro_flash`, style_image = fragment kanapy 32×32, no_background, opis sylwetki | czy kotwica stylu zastępuje prowadnicę |
| 2 | Sterta, 32×32 | to samo + zmieniony opis (wymiary, „tied stack of folded newspapers, visible page edges”) | wpływ opisu |
| 3 | Sterta, 32×32 | `create_1_direction_object`, size 32, `style_images` = ta sama kotwica | zestaw kandydatów za 1 gen. |
| 4 | Szafka, 24×80 | `create_object_pro_flash` n_directions 1, style_image = lada (fragment ≤ 24×80) | box w rzucie gry, natywny |
| 5 | Szafka, 24×80 | `create_image_pixflux` z prowadnicą w 1× (bez ×4), siła 60 | czy natywna prowadnica coś daje |
| 6 | Szafka z konceptu | `image_to_pixelart` faithful, 24×80, wejście: szara bryła z teksturą (szkic z Godot) | tor „jak postacie” |
| 7-8 | Rezerwa | powtórka najlepszego toru z innym opisem; ewentualnie wersja sterty ręcznie dorysowana w workbench (0 gen.) | |

Kryteria: (1) rzut zgodny z ladą (blat nad frontem, bez boku), (2) czytelna sylwetka w grze ×1 i ×4, (3) styl pasuje do kanapy, (4) kolory w paletowych rampach po `quantize`. Wygrywa tor, który spełnia (1) i (2) bez ręcznych poprawek; sterta ma i tak prawo skończyć w ręcznie dorysowanym wariancie, jeśli AI da tylko sylwetkę.

## 7. Otwarte pytania
- Nie zweryfikowano, ile generacji kosztuje `create_object_pro_flash` i `create_image_pro` (sprawdzić `get_balance` przed i po).
- Czy `style_image` z fragmentu kanapy faktycznie przenosi projekcję, a nie tylko paletę i kontur: to pierwsze pytanie eksperymentu (#1, #4).
- Czy `image_to_pixelart` zachowuje rzut dla przedmiotów jak dla postaci: wniosek z §1, do potwierdzenia (#6).
- Jakie dokładnie `view` ustawia `create_map_object` dla `high top-down` i czy odpowiada naszemu rzutowi: kanapa wyszła dobrze, lodówka też, więc prawdopodobnie bliskie, ale nie zmierzone.

## Źródła
- Pixellab `search_help` (2 pytania, 2026-11-03) i `get_pro_flash_capabilities` (rewizja `pro-flash-presets-48-128-2026-09-29`).
- [Pixellab: Create Map](https://pixellab.ai/docs/guides/map-tiles), [opcje szczegółowości](https://www.pixellab.ai/docs/options/details), [pixellab.ai](https://pixellab.ai/).
- Repo: `docs/wayfinder/tickets/22-pipeline-assetow.md`, `26-skala-postaci-75px.md`, `docs/research/24a-generatory-mcp.md`, `46-generowanie-mebli-3-4.md`, `art/concept/_style/STYLE.md`.
