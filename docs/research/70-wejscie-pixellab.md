# 70. Wejście do Pixellab dla postaci 72 px w niskim 3/4

Ticket: `docs/wayfinder/tickets/18-wejscie-pixellab-research.md`. Data: 2026-11-08. Nic nie zostało wygenerowane (czytane: OpenAPI, dokumentacja, llms-full.txt, pliki lokalne).

Oznaczenia: **[OpenAPI]** i **[doc]** to pierwotne źródła Pixellab; **[log]** to własne próby (`style-lab/proby/postac_kat/log.jsonl`, game1 ticket 22); **[wniosek]** to moja inferencja; **[brak]** to nie znalazłem źródła.

## Odpowiedź w skrócie

1. Pixellab nie publikuje żadnego wprost sformułowanego „wymagania co do stylu wejścia”. Dokumentacja mówi tylko: zmniejsz ok. 4×, zachowaj proporcje, `fixer=true` + siła 100-300 = wierność źródłu **[OpenAPI, doc]**. Resztę wiemy z własnych prób.
2. Wejście **najlepiej ilustracyjne** (kontur, płaskie plamy, kontrast ubrań, jednolite tło), nie fotorealistyczne **[log, wniosek, pewność średnia]**: tryb faithful „odtwarza źródło” **[OpenAPI]**, więc to, co jest w wejściu (miękkie przejścia, jedna barwa), jest też w wyjściu.
3. Nasza pierwsza próba miała dodatkowo błąd **kamery i proporcji**, niezależny od stylu: koncept `wysoka-2200` jest z wysokiej kamery z mocną perspektywą (skrót nóg, duża głowa i ramiona), więc sprite wychodzi krępy, nie 7-głowy (zob. `ref_060.png` i `arkusz.png`). Pixellab trzyma rzut z wejścia **[log: ticket 22, „kamera wyszła z poziomu oczu”]**. Wejście musi mieć już docelową kamerę (~30-35°) i proporcje 7 głów, bo ani `image-to-pixelart`, ani `create-character-v3` ich nie naprawią.
4. Rekomendowany łańcuch (pierwszy wariant, 0 dodatkowych kosztów poza grą): lepszy koncept ilustracyjny w FLUX.2 klein → lokalna obróbka (kadr, białe/jednolite tło, brak cienia na ziemi, mocniejszy kontrast i nasycenie, ewentualny kontur) → `image-to-pixelart` fixer, siła 150-200 → `remove-background` → `create-character-v3` z referencją.
5. Próby do zatwierdzenia: do 6 generacji (zob. sekcja 5).

## 1. Styl wejścia

| Cecha | Co mówią źródła | Pewność | Rekomendacja |
|---|---|---|---|
| Zdjęcie / fotorealizm | Strona narzędzia „image to pixel art” obiecuje konwersję, bez wskazówek jakościowych **[doc: tools/image-to-pixel-art]**; FAQ: zdjęcie „zmniejsz i użyj jako init image” **[doc: faq]**. Nasze próby: rozmyte, kolory zlewają się **[log]**. | średnia | unikać; mało „plam” do zachowania na 72 px |
| Ilustracja z konturem i płaskimi plamami | Game1: badacz-gora-a-7003 (granat / krem / brąz, czysty kontur) → `badacz_gora_px.png` czytelny, „wygląda super” **[log: ticket 22]** | średnia (jedna próba, ale powtarzalna w 4 wariantach z tej samej serii) | **tak**; kontrast między garderobami i oddzielne plamy |
| Cel-shading | [brak] bezpośrednich zaleceń | niska | pośrednio, jak ilustracja (twarde progi światła zamiast gradientów) |
| Wejście już piksel-art / zmniejszone | `unzoom`: „podawanie powiększonego piksel-artu do endpointów wzorcowych marnuje detal i myli modele”, najpierw `unzoom` **[OpenAPI /unzoom]**; Pro Flash sam wykrywa natywną siatkę **[OpenAPI]** | wysoka co do zasady | nie dawać piksel-artu powiększonego nearest (bloki); lekko zmniejszone (area) wejście jest OK |
| Kontur | Parametry `outline`/`detail` w v3 działają **tylko** w trybie „od zera”, przy `reference_image` są ignorowane **[OpenAPI /create-character-v3]**. Kontur więc musi być w obrazie wejściowym. | wysoka | kontur w koncepcie (ciemny, ciągły, 1 kolor); ewentualnie dorysować lokalnie |
| Liczba kolorów / kontrast | [brak] oficjalnych liczb. Nasz przypadek: prawie monochromatyczny płaszcz + granatowe spodnie zlały się **[log]**. Game1: 3-4 wyraźne masy kolorów. | średnia | min. 4-5 wyraźnie różnych plam (np. płaszcz, szalik, spodnie, buty, skóra), różne jasności, nie same ciemne szarości |
| Tło | v3 ma `no_background` (domyślnie true) **[OpenAPI]**; `remove-background` istnieje **[OpenAPI]**. Game1: wejście na białym/szarym tle, tło usuwane po konwersji **[log]**. `image-to-pixelart` ma w doc opcję „Remove background” **[doc]** (w REST v2 jej brak). | średnia | jednolite tło o kolorze, którego nie ma w postaci; bez cienia pod stopami |
| Oświetlenie | [brak]. Cień pod stopami w naszym wejściu trafił do sprite’a jako plama **[log: `px_060.png`]**. | średnia | miękkie, równe, bez cienia rzuconego |

## 2. Rozdzielczość, proporcja, margines

- `image-to-pixelart`: wejście 16-2048, wyjście 16-512; „zalecany rozmiar wyjścia = 1/4 wejścia, ta sama proporcja” **[OpenAPI]**; doc: „obraz jest zazwyczaj zmniejszany 4×” **[doc]**. Nasz łańcuch 320→80 to dokładnie 4:1 **[log]**; game1 256→80 (ok. 3,2:1) też działał **[log: ticket 22]**. Brak źródła, że inna proporcja jest gorsza; **[wniosek]** warto sprawdzić 3,2:1 i 4:1.
- Postać w kadrze: game1 ok. 90% wysokości płótna, margines pod stopami ≥5-8 px w wyjściu (inaczej szablon chodu ucina podeszwy) **[log: ticket 22]**. U nas 288/320 = 90%, w normie.
- `create-character-v3`, referencja: **maks. 256×256**, powinna być zwrócona **na południe**, a „użyte są wymiary wgranej klatki, `image_size` jest tylko podpowiedzią” **[OpenAPI]**. Czyli płótno wyjścia = płótno referencji (u nas 80×80 lub większe, jeśli je dopełnimy).
- Wyjście `image-to-pixelart` ma stały rozmiar zamawiany przez nas; Pro i Pro Flash same wykrywają skalę i wybierają rozmiar **[OpenAPI]**, więc nie nadają się do ścisłych 72 px bez przeskalowania (które psuje siatkę).

## 3. Endpointy i parametry

| Endpoint | Koszt | Co robi / parametry | Ocena dla nas |
|---|---|---|---|
| `POST /image-to-pixelart` | **1 gen.** **[log: usage 1/zadanie]** | `output_size`, `text_guidance_scale` 1-20 (domyślnie 8), `init_image_strength` 0-999 (użyteczne 100-300; 0 = od zera z wejściem jako sugestią; wysokie wartości zwracają źródło prawie bez zmian), `fixer` (faithful), `seed`. **Brak parametru `description`.** **[OpenAPI]** | główny kandydat; test siły 120/200 |
| `POST /image-to-pixelart-pro` | **[brak w OpenAPI]** (zapytać konto / `/v2/balance` przed i po) | `description` (do 2000 zn.), `target_palette` (`colors` / `max_colors` 2-64); rozmiar wyjścia automatyczny **[OpenAPI]** | nieprzewidywalny rozmiar; niekoniecznie 72 px |
| `POST /image-to-pixelart-pro-flash` | **6 gen.** **[OpenAPI]** | j.w., `description`, `target_palette`; rozmiar automatyczny | drogi jak 6 prób; zostawić na później |
| `POST /correct-pixelart` | **[brak]** (w OpenAPI bez liczby) | czyści krawędzie i zbłąkane piksele bez zmiany rozmiaru, `strength` 0-1, „zacznij od 0,1”; kilka klatek naraz dla spójności **[OpenAPI]** | opcjonalnie po konwersji, nie naprawi rozmycia semantycznego |
| `POST /create-character-v3` (referencja) | `ceil(w*h*8/65536)`: **80×80 = 1**, 96×96 = 2, 128×128 = 2 **[OpenAPI]** | `reference_image`, `view` (`low top-down` domyślnie), `n_directions` 4/8, `template_id` `mannequin`, `direction_images`, `seed`, `no_background`. `outline`/`detail`/`enhance_prompt` nie działają z referencją. | po konwersji; jest „tylko obracaniem” **[log]** |
| `POST /create-character-v3` (od zera) | 1 (pixen) + `ceil(s²*8/65536)` **[OpenAPI]** | `outline`, `detail`, `image_size` 32-256 | opcja awaryjna: sprite z samego opisu bez konceptu |
| `POST /create-character-pro` | 10-25 gen. **[OpenAPI]** | `create_from_concept`: `concept_image` do 1024×1024 + `reference_image` (styl) do 168; `image_size` 32-168; `style_character_id` | **jedyna ścieżka, w której koncept 1024 trafia wprost**, ale 10-25 gen. (zob. §6) |
| `POST /create-character-pro-flash` | wg `/pro-flash/cost` (darmowy GET) | `first_frame`/`source_image_id` (reuse, płacisz tylko obroty), `style_image` + `style_options` (kopiuj paletę, kontur, detal, cieniowanie), `target_palette`, `image_size` w wielokrotnościach 4, natywne 24,32,48,64,96,128 **[OpenAPI]** | style_image (do 128) może narzucić „ostry” styl; do zbadania |

Dodatkowe wskazówki [doc]:
- Widok kamery to „luźna kontrola”; init image często działa lepiej niż etykieta widoku (`low top-down` ≈ 20°, `high top-down` ≈ 35°) **[doc: options/camera]**. Nasz cel 30-35° leży bliżej `high top-down`, a `view` w v3 to tylko podpowiedź; w game1 referencja nadpisała etykietę **[log]**.
- `text_guidance_scale` zbyt duże powoduje artefakty i przesycenie (ogólnie o „guidance weight”) **[doc: options/guidance]**. Zostawić 8.
- Init image strength: niskie = luźne wskazówki koloru; środek = kształty i kolory; 600-900 = poprawki prawie gotowej pracy **[doc: options/init-image]**; w REST v2 użyteczne 100-300 **[OpenAPI]**.

## 4. Co v3 robi i czego nie robi

- Referencja jest dla v3 „sprite’em południowym do obrotu” **[OpenAPI]**; ostrość i szczegół są dziedziczone z referencji (nie ma parametrów detalu w trybie referencji). **[wniosek, średnia]** Poprawa jakości musi nastąpić **przed** v3, w konwersji.
- Większe płótno (96/128) **nie dodaje detalu przy tej samej figurze 72 px**; dodaje tylko margines. Natywne rozmiary modeli to 64/96/128 **[OpenAPI Pro Flash]**, więc teoretycznie 96×96 z postacią 72 px może być „przyjaźniejsze” dla modelu niż 80×80 **[niska pewność, do testu]**. Przycięcie wyniku do 80×80 jest bezstratne (piksele zostają).
- Ceny wersji większych: 96 i 128 kosztują 2 gen. zamiast 1 **[OpenAPI]**.

## 5. Obróbka lokalna przed wysłaniem

Dowodów Pixellab brak **[brak]**; poniżej wnioski z mechaniki endpointów i z naszych prób, do sprawdzenia lokalnie (darmowe).

| Zabieg | Po co | Ryzyko |
|---|---|---|
| Kadr 1:1, postać ~90% wysokości, tło jednolite, bez cienia | tak jak game1; usuwa plamy nie-postaci | brak |
| Skala do 320 (4:1) lub 256 (3,2:1) **area/Lanczos** | wejście bez „bloków”; nearest dałby aliasing, `unzoom` jest dla powiększonego piksel-artu | miękka krawędź jeśli źle |
| Zwiększenie kontrastu i nasycenia (S ×1,2-1,4, kontrast 10-20%) | rozdziela plamy, które model zlewa | nienaturalny kolor, kontrolować podglądem |
| Posteryzacja lekka (np. 12-16 kolorów, bez ditheringu) | płaskie plamy jak w game1; model dostaje „gotowe” masy | utrata mikrodetali twarzy |
| Kontur (ciemny, 1 px w skali 320 ⇒ ~0,25 px na wyjściu) | czytelność sylwetki | cienki kontur zginie; potrzebny ≥3-4 px w wejściu 320 |
| Szkic „w FLUX” zamiast dopracowanej fotografii | prompt: *flat colour illustration, clean black outline, cel-shaded, plain background, full body, 7 heads, camera 30 degrees, no cast shadow, high-contrast clothing colours* | FLUX klein bywa fotorealistyczny; wariant „ilustracja” bez LoRA może wymagać kilku seedów |

## 6. Rekomendowany łańcuch

1. **Koncept** (FLUX.2 klein, lokalnie, 0 gen.): styl ilustracyjny jak w game1, proporcje 7 głów, kamera 30-35° bez silnej perspektywy (obiektyw „długi”, nogi nie skrócone), 5+ odrębnych plam kolorów, kontur, jednolite tło, bez cienia.
2. **Obróbka** (Godot/skrypt, 0 gen.): kadr, 320×320 (postać 288 px) i wariant 256×256 (postać 230 px), kontrast/nasycenie, ewentualny kontur.
3. **`image-to-pixelart`**: `fixer=true`, `init_image_strength` 150-200, `text_guidance_scale` 8, 80×80 (1 gen.).
4. **`remove-background`** lokalnie (`remove_bg.gd`) lub endpoint.
5. **`create-character-v3`** z referencją (1 gen., 80×80) albo na 96×96 (2 gen.), `view: low top-down`, `template_id: mannequin`, 4 lub 8 kierunków (ten sam koszt).
6. Opcjonalnie `correct-pixelart` strength 0,1 na wynikach.

`create-character-pro` `create_from_concept` (koncept 1024 wprost, 10-25 gen.) to droższa alternatywa; testować dopiero po wyczerpaniu tańszej drogi.

## 7. Lista tanich prób (≤ 6 generacji) do zatwierdzenia

Wszystkie używają nowego konceptu ilustracyjnego z §6 (kroki 1-2 lokalnie, 0 gen.). Wejście jest dokładnie to samo w T1-T3, by porównać tylko jeden parametr.

| # | Próba | Endpoint, parametry | Koszt |
|---|---|---|---|
| T1 | baza: nowy koncept 320×320 | `image-to-pixelart` fixer, siła 200, 80×80 | 1 |
| T2 | niższa siła (więcej „piksel-artowego” przerysowania) | to samo wejście, siła 120 | 1 |
| T3 | inna proporcja: wejście 256×256 (3,2:1, jak game1) | siła 200 | 1 |
| T4 | v3 z najlepszego z T1-T3, 80×80, 8 kierunków | `create-character-v3` referencja | 1 |
| T5 | ten sam sprite dopełniony do 96×96 (przezroczysty margines) | `create-character-v3`, 96×96 | 2 |
| **Razem** | | | **6** |

Kryteria oceny: czytelność kolorów ubrania, wysokość postaci 72 px (nie krępa), twarz/ręce, ostre krawędzie, czy v3 zachowuje kamerę. Oceniać na żywo w Poligonie (notatka pamięci). Nie ujęte w limicie: Pro Flash (6 gen./obraz) i `create-character-pro` (10-25); zapytać o `GET /v2/pro-flash/cost` (darmowy) i o saldo przed i po T1, żeby poznać koszt Pro.

## Luki

- Brak oficjalnego tekstu o najlepszym stylu wejścia; potwierdzenie z Discorda/YouTube/Reddit **nie znalezione** (wyszukiwania dały tylko ogólne i stronnicze poradniki oraz zrzuty Reddita bez wątków o Pixellab w tym temacie).
- Brak źródła kosztu `image-to-pixelart-pro` i `correct-pixelart`.
- Wpływ `text_guidance_scale` na `image-to-pixelart` nie ma opisu poza zakresem i domyślną 8.

## Źródła

- OpenAPI: `https://api.pixellab.ai/v2/openapi.json` (endpointy wyżej), `https://api.pixellab.ai/v2/llms.txt`.
- Dokumentacja: `https://www.pixellab.ai/docs/tools/image-to-pixel-art`, `/docs/options/init-image`, `/docs/options/guidance`, `/docs/options/camera`, `/docs/guides/rotating-a-character`, `/docs/tools/create-8-rotations-pro`, `/docs/tools/consistent-style`, `/docs/faq`, `/docs/getting-started`, `https://www.pixellab.ai/llms-full.txt`.
- Lokalnie: `style-lab/proby/postac_kat/{arkusz.png,log.jsonl}`, `style-lab/proby/koncept/wysoka-2200.png`, `docs/game1/tickets/22-pipeline-assetow.md`, `docs/research/52-narzedzia-pixel-art.md`, `57-pixellab-meble.md`, game1 `pipeline/out/badacz_gora_{ref,px}.png`.
