# 76. Pixellab „map creator”: teren, budynki, pokoje i obiekty w naszym rzucie

Ticket: `docs/wayfinder/tickets/21-pixellab-map-creator-research.md`. Data: 2026-11-09. **Nic nie zostało wygenerowane.** Wywołania: odczyt OpenAPI v2, `llms-full.txt`, strona MCP, ToS, `GET /v2/balance` i darmowy `GET /v2/pro-flash/cost`. Klucz nie był drukowany.

Oznaczenia: **[OpenAPI]**, **[doc]**, **[MCP]**, **[ToS]** to źródła pierwotne Pixellab; **[wcześniej]** to nasze notatki 61/70 i ticket 17; **[wniosek]** to moja inferencja; **[brak]** to nie znalazłem źródła; **[słabe]** to źródło wtórne lub prawdopodobnie nieaktualne.

## Odpowiedź w skrócie

1. „Map creator” to nie jedno narzędzie, tylko zestaw: edytor map w przeglądarce (rysowanie kafel po kaflu z tilesetami Wang, tylko top-down), narzędzia „Create/Extend map” (obraz mapy z init image), **Create tiles (Pro)** (zestawy: teren, drogi, **zestaw budowlany**: podłoga, ściany, drzwi, schody) oraz **pokoje z meblami** (`create_room`). Pokoje i mapy (`create_map`, `edit_map`) są **tylko w MCP**, nie ma ich w REST v2 **[MCP, OpenAPI]**.
2. **Rzut:** Pixellab ma tryb `oblique`, ale to rzut Tibii: głębia ścięta po przekątnej w dół i w prawo (domyślnie 45°, „cabinet” ok. 27°) **[OpenAPI: `oblique_lean`]**. Nasz rzut to frontalne fasady i podłoże skrócone × 0,60, bez ścięcia, więc `oblique` **nie pasuje**. Bliżej jest `square_topdown` z `tile_view_angle` (ciągły kąt 0-90°, nasze 0,60 ≈ 37°, **[wniosek]**), ale ściany budynków są kontrolowane osobno i nie jest sprawdzone, czy da się je mieć frontalne.
3. **Koszt jest wysoki względem wielkości inwentarza:** zestaw kafli Pro 10-15 gen., obiekt (create-object) 10-25 gen., obiekt Pro Flash 64 px 5-6 gen. (zmierzone darmowym `check_cost`). Meble po ok. 5-10 gen. to 120-660 × 5-10 = 600-6600 gen. na samych meblach.
4. **Dostęp:** tiles-pro, Pro tileset i pokoje wymagają **płatnego planu** (Apprentice 12 USD wystarcza dla pokoi i Create tiles Pro), więc **na trialu (10,5/40) ich nie sprawdzimy**. Wniosek 61 „pokoje: Artisan i wyżej” jest **nieaktualny**: strona MCP mówi Apprentice.
5. **Licencja:** bez zmian względem 61: wyniki nasze, komercyjnie, bez zapisu o utracie po anulowaniu; zakaz trenowania modeli.
6. **Rekomendacja: warto prototypować**, w dwóch krokach (§7): najpierw ≤ 3 gen. na trialu (obiekt w stylu Poligonu Ulica), potem decyzja człowieka o 12 USD na test zestawu budowlanego (zwrot możliwy).

## 1. Co dokładnie robi

| Narzędzie | Co daje | Rzuty | Źródło |
|---|---|---|---|
| Edytor map (web, `/map-editor`) | rysowanie map kafel po kaflu, tilesety Wang na żądanie | top-down | **[doc: llms-full.txt]** |
| `create-tileset` (standard) | 16 kafli Wang, dwa poziomy terenu (dolny/górny) + przejście; kafle 16 lub 32 px; eksport Wang, dual-grid 15, 3×3 | **zawsze high top-down** („Standard always draws high top-down”) | **[OpenAPI, doc]** |
| `create-tileset` mode `pro` | bogatsza tekstura, wzniesienia, ściany do pełnej wysokości kafla (25 kafli, `transition_size` 1.0); kafle 16/32/64; `view` honorowany | top-down (kąt przez `view`) | **[OpenAPI]** |
| `create-tiles-pro` | kafle niezależne albo zestawy: `roads` (18 konfiguracji), `tileset` (16 kafli Wang), **`building`** (podłoga, łączone ściany, drzwi, filar, schody; wysokość ściany 1-3 kafle) | `square_topdown`, `isometric`, `oblique`, hex, octagon; `tile_view_angle` ciągły 0-90° (0 = bok, 90 = z góry); rozmiar 16-128 px (zestawy: wąsko, większość do 96, drogi dokładnie 32) | **[OpenAPI, doc]** |
| `create-isometric-tile` | pojedyncze kafle izometryczne 16-64 px | izometria | **[OpenAPI]** |
| `create-map` (pixflux), Create map (new), Extend map (v1/v2) | obraz sceny/mapy malowany obszarami (inpainting) z init image i opisem, kafle 16 px | „high top-down” i sidescroller; Extend v2 ma izometrię i „oblique” | **[doc]** |
| `POST /map-objects` | obiekt z przezroczystym tłem na mapę, ok. 15-30 s; **`background_image` + inpainting do dopasowania stylu do istniejącej sceny**; widoki low/high top-down, side | niski i wysoki top-down | **[OpenAPI]** |
| `create-1/8-direction-object`, `create-object-pro-flash` | rekwizyty (1 lub 8 kierunków), stany i animacje obiektu | `view` jak postać | **[OpenAPI]** |
| `create_room`, `cut_out_room_furniture` (**tylko MCP**) | „umeblowany pokój top-down, izometryczny lub oblique z jednej linii motywu, z drzwiami tam, gdzie chcesz”; meble można wyciąć jako osobne przezroczyste sprite’y z cieniem i miejscem na podłodze (**tylko top-down i izometria**) | top-down, izometria, oblique | **[MCP]** |

**Dopasowanie do naszego rzutu** (`style-lab/config/projection.tres`: `depth_factor = 0.6`, 40 px/m, postać 72 px, frontalne fasady **[wcześniej]**):

- **Teren (podłoże):** pasuje najlepiej. `create-tiles-pro` z `square_topdown` i `tile_view_angle` ok. 37° powinien dać kafle z głębią ok. 0,6. Kafel 32 px to 0,8 m, a nasze 40 px/m daje kafel 40 px; 40 mieści się w zakresie 16-128, ale dla zestawów łączonych zakres jest węższy **[wniosek; nie sprawdzone dla konkretnej wartości]**. Alternatywa: kafel 32 px i przeskalowanie siatki układu miasta, lub 40 px jeśli API przyjmie.
- **Budynki / fasady:** kit `building` daje ściany z `building_wall_tiles` 1-3 i `building_wall_angle` (kąt wysokości piętra osobno od nachylenia podłoża, **tylko `square_topdown`**) **[OpenAPI]**. To jest najbliższe frontalnym fasadom z podłożem 0,6, ale zestaw to ściana modułowa 1-3 kafle, bez dachów i bez detalu fasady (okna, szyldy). Dach: `building_floor2_description` („powierzchnia piętra/dachu”). Nasze fasady 16-34 sztuk z oknami i drzwiami raczej zostają w Przepisie budynków; kit mógłby dać mur, parkan, schody, ściany wnętrz.
- **Wnętrza:** `create_room` w top-down/izometrii/oblique. Nasz rzut wnętrza to niskie 3/4 z chowanymi ścianami działowymi, więc nie wiadomo, czy „top-down room” da nasz kąt **[brak]**. `view` kafli to hint, nie gwarancja (por. 70: referencja nadpisuje etykietę).
- **`oblique`:** ścięcie diagonalne, nie nasz rzut **[OpenAPI]**; nie używać, chyba że zmienimy rzut.
- **Skala:** rozmiary 16-128 px dla kafli; obiekty Pro Flash do 128 (własne rozmiary do 256, krok 4, beta) **[OpenAPI: `/pro-flash/capabilities`]**; mebel 40 px/m (np. krzesło 0,9 m = 36 px) mieści się.

## 2. Wejścia i spójność

- **`style_images` w `create-tiles-pro`:** referencyjne **kafle** (nie ilustracje); wymiary i kształt wynikają z nich, a `tile_type`, `tile_size`, `tile_view`, `tile_view_angle` są ignorowane. **Nie łączy się z `tile_feature`** (zestawy roads/tileset/building) **[OpenAPI]**. Czyli styl referencyjny działa tylko dla kafli niezależnych, nie dla zestawów łączonych.
- **`create-tileset`:** `lower/upper/transition_reference_image` (obrazy referencyjne terenów), `shading`, `detail`, `target_palette` (w Pro: każdy piksel z palety lub limit kolorów 2-64), `seed`; w Pro referencja daje „dokładne dopasowanie wspólnego terenu do istniejącego tilesetu”, co pozwala łańcuchować tilesety **[OpenAPI]**.
- **`map-objects`:** `init_image` (siła domyślnie 300), `color_image` (wymuszona paleta), **`background_image` do dopasowania stylu sceny**, `seed` **[OpenAPI]**. To jedyna ścieżka, w której zrzut naszego Poligonu trafia wprost jako kontekst stylu.
- **`create-object-pro-flash`:** `style_image` + `style_options` (kopiowanie palety, konturu, detalu, cieniowania), `target_palette` **[OpenAPI]**.
- **Paleta:** `target_palette` w tiles-pro, tileset Pro, obiektach Pro Flash **[OpenAPI]**; można więc narzucić paletę gry.
- **Spójność między wywołaniami:** [brak] zapewnień w dokumentacji. Mechanizmy: wspólna paleta, `seed`, referencje stylu, łańcuch tilesetów. Czy sąsiednie zestawy z różnych wywołań będą wyglądać jak jedna rodzina, wymaga próby (`style_images` w tiles-pro, `lower_reference_image` w tilesecie).
- Nasz sprite postaci czy ilustracja z FLUX jako wejście: tylko jako `init_image` (map-objects, obiekty) lub `style_image` (Pro Flash), nie jako referencja budynku.

## 3. Dostęp i koszt

**Plany [wcześniej, ticket 17; API `get-subscriptions` potwierdzone dziś]:** Apprentice 12 USD, Artisan 24 USD, Architect 50 USD miesięcznie (rocznie 99/220/500). Limity 2000/5000/10 000 obrazów to ticket 17 (z kodu strony). **[słabe]** przykład w OpenAPI (`/balance`) pokazuje „Tier 2: Pixel Artisan … total 2000”, co koliduje z 5000; to prawdopodobnie przykład nieaktualny, ale **przed zakupem sprawdzić limit na koncie**.

**Wymagany tier:**

| Funkcja | Wymóg | Źródło |
|---|---|---|
| `create-tileset` standard, `map-objects`, Create map (pixflux) | dostępne także na trialu (limity płótna 200×200 w darmowym) | **[doc]** |
| `create-tileset` Pro | „Tier 1+ (nie trial)” | **[OpenAPI]** |
| Create tiles (Pro) | „paid subscription (tier 1 or above)” | **[doc]** |
| Pokoje (`create_room`, `cut_out_room_furniture`) | „Pixel Apprentice tier and up” | **[MCP]** |
| Extend map v2 | Tier 2 (eksperymentalne) | **[doc]** |
| Create map (new), edytor `create_map`/`edit_map` w MCP | tier nie podany | **[brak]** |

Poprawka do 61: tam „tworzenie pokoi … Pixel Artisan i wyżej”; strona MCP dziś mówi Apprentice (nie wiadomo, kiedy zmieniono).

**API/MCP vs web:** tiles-pro, tilesety, obiekty, map-objects są w REST v2 i w MCP. **Pokoje i mapy: tylko MCP (i web)**, nie REST **[OpenAPI: brak ścieżek; MCP]**. MCP działa z Claude Code, więc masowa generacja przez Claude jest możliwa; to wymaga zainstalowania serwera MCP (zmiana konfiguracji do zatwierdzenia).

**Koszt w generacjach:**

| Element | Koszt | Źródło |
|---|---|---|
| Zestaw kafli Pro (teren 16 kafli lub kit budowlany) | **10 lub 15** (większe rozmiary 64/96/128 = 15; ze `style_images` 10-25) | **[doc: create-tiles-pro]** |
| `create-tileset` standard / Pro | **[brak]** (nie podano; zmierzyć saldem przed i po) | |
| `map-objects` | **[brak]** (nie podano) | |
| Obiekt `create-1/8-direction-object` | **10-25** (zależnie od rozmiaru) | **[OpenAPI]** |
| Obiekt Pro Flash 64×64 | **5** (1 kierunek), **6** (8 kierunków) | zmierzone `GET /v2/pro-flash/cost`, darmowe |
| Pokój, wycięcie mebli | **[brak]** | |
| Obraz Create S-XL (Pro), kafelki wariantów | 10-25 za siatkę wariantów | **[doc]** |

Szacunek **[wniosek]**: typowy kafel terenu = zestaw 16 kafli za 10 gen., czyli teren całej ulicy (asfalt, śnieg, chodnik, trawa: 3-5 zestawów) ≈ 30-75 gen. Fasady: kit budowlany 10-15 gen. za zestaw modułowy, ale pełna fasada z oknami i dachem to osobna praca (Przepis budynków). Meble: Pro Flash 5-6 gen. za sprite 64 px, czyli 120-660 mebli ≈ 600-4000 gen.; to mieści się w Artisan (5000) tylko bez prób i bez postaci (ok. 10 gen. na postać z chodem **[wcześniej]**). Pokoje: koszt nieznany.

## 4. Licencja wyników (Steam, także po anulowaniu)

- **[ToS §1.3]** „You own the copyrights to your creations, permitting usage for both commercial and non-commercial purposes with no need for permission.” **[ToS §1.2]** zakaz trenowania własnych modeli na wynikach. **[ToS §8.1]** Pixellab może zakończyć dostęp w każdej chwili; **brak zapisu o utracie praw do wyników po anulowaniu**. **[FAQ]** „Can I use the generated images commercially? Yes, we only ask that you do not train new models with the images.” Regulamin nie rozróżnia narzędzi, więc obejmuje tiles-pro, tilesety, obiekty, pokoje tak samo **[wniosek]**. Brak ograniczenia terytorialnego (`supported_countries_code: ALL`, API `get-subscriptions`).
- Steam: wyniki AI do ujawnienia w ankiecie (Notes mapy). FAQ Pixellab: „AI assets are allowed in games, subject to Steam's AI disclosure rules” **[wcześniej, 61]**.
- Otwarte: pisemna odpowiedź supportu o prawa po anulowaniu (ticket 17: człowiek załatwia poza sesją). Dla map i pokoi nic szczególnego w regulaminie [brak].

## 5. Czy da się sprawdzić na trialu bez wydawania

Stan konta (dziś, `GET /v2/balance`): **trial, 10,5 z 40 generacji, 0 USD** (zgadza się z ticketem).

- **Nie da się** na trialu sprawdzić tego, co najciekawsze: tiles-pro (zestaw budowlany, `tile_view_angle`), Pro tileset i pokoje wymagają płatnego planu **[doc, OpenAPI, MCP]**.
- **Da się** sprawdzić `map-objects` z `background_image` (zrzut Poligonu Ulica) i standardowy `create-tileset`, ale standard rysuje zawsze high top-down (słaby test rzutu).
- Darmowa wycena (`check_cost`) istnieje tylko dla Pro Flash (`/pro-flash/cost`); dla tiles-pro, tilesetów, map-objects i pokoi **[brak]**, koszt mierzymy saldem przed i po.

## 6. Ryzyka i luki

- Nie wiemy, czy `tile_view_angle` ≈ 37° daje nasze 0,6 i czy fasada z `building_wall_angle` wyjdzie frontalna (test wymaga planu płatnego).
- Spójność stylu między wywołaniami niepotwierdzona; `style_images` nie działa z zestawami łączonymi.
- Koszt tilesetów, map-objects i pokoi nie jest podany.
- Pokoje tylko w MCP; trzeba skonfigurować serwer MCP.
- Nasz rzut wnętrz (ściany chowane, niskie 3/4) jest inny niż „top-down room”.
- Limit planu Artisan: 5000 (ticket 17) vs 2000 (przykład OpenAPI **[słabe]**).
- Nie sprawdzałem filmów i społeczności; **[brak]** niezależnych opinii o jakości map creatora.

## 7. Rekomendacja: **warto prototypować**

Nie „wchodzi” jeszcze do Przepisu, bo najważniejsze (rzut, kit budowlany, pokoje) wymaga płatnego planu, a koszt mebli i pokoi jest nieznany. Nie „odpada”: teren (kafle 16-set Wang, 10 gen.) i obiekty w stylu sceny (`map-objects` z `background_image`) wyglądają na zgodne z naszymi potrzebami i mają czystą licencję.

**Próba taniej (trial, wymaga zgody człowieka z kosztem):** na Poligonie Ulica wygenerować **jeden rekwizyt uliczny** (np. zaśnieżona ławka lub kosz, ok. 48×48 px, widok `low top-down`), `POST /map-objects` z `background_image` = zrzut Poligonu Ulica (obszar inpaintingu: miejsce na ławkę), ewentualnie `init_image` = nasza ilustracja rekwizytu. Ocena na żywo w Poligonie (czy kąt i paleta pasują obok postaci 72 px). **Koszt: nieznany z dokumentacji, spodziewany 1-2 gen. (słabe), plan: maks. 2 próby ≤ 3-4 gen. z 10,5.** Saldo `GET /v2/balance` przed i po pierwszej próbie, stop jeśli koszt > 2.

**Krok 2 (tylko jeśli krok 1 się udał i człowiek zatwierdzi wydatek):** miesiąc Apprentice (12 USD) i jeden zestaw `create-tiles-pro` `tile_feature: building`, `square_topdown`, `tile_view_angle` 37, ściana 2 kafle, `building_wall_angle` do zmierzenia, 32 px: **10 gen.** (ewentualnie drugi zestaw terenu `tileset` „śnieg do asfaltu” 10 gen.); razem ≤ 20-30 gen. Refund: pełny zwrot, jeśli użyto < 50 generacji w 30 dni, minus 5% + 0,5 USD **[wcześniej, 61: refund policy]**. Ta próba rozstrzyga rzut, spójność i koszt przed Miesiącem produkcji.

## Źródła

- OpenAPI: `https://api.pixellab.ai/v2/openapi.json` (`/create-tileset`, `/create-tiles-pro`, `/create-isometric-tile`, `/map-objects`, `/create-1-direction-object`, `/create-8-direction-object`, `/create-object-pro-flash`, `/pro-flash/cost`, `/pro-flash/capabilities`, `/balance`), `https://api.pixellab.ai/v2/llms.txt`.
- Dokumentacja: `https://www.pixellab.ai/llms-full.txt` (Create tiles (Pro), Create Tileset, Create map, Extend map, Create map (new), Projection, FAQ), `https://www.pixellab.ai/docs/guides/map-tiles`, `https://www.pixellab.ai/map-editor` (tytuł), `https://www.pixellab.ai/mcp` (maps, tilesets, rooms; „Pixel Apprentice tier and up”).
- Regulamin: `https://www.pixellab.ai/termsofservice` (§1.2, §1.3, §8.1); plany: `https://api.pixellab.ai/get-subscriptions`.
- Lokalnie: `docs/research/61-narzedzia-limity-koszty.md`, `70-wejscie-pixellab.md`, `docs/wayfinder/tickets/17-konta-testowe.md`, `style-lab/config/projection.tres`, `docs/grafika/przepis-postaci.md`.
