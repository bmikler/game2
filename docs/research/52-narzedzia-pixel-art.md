# Narzędzia do pixel artu 3/4: co testować poza Pixellab i jak to porównać

Data researchu: **2026-11-03**. Powód: `docs/grafika.md` zakłada Pixellab jako start, ale bez zamykania się na nie. Ta notatka **aktualizuje i rozszerza** §4 researchu 51 (nie powtarza prototypowych ocen z `08`, `24a`, `24c`, `24d`, `46`, `57`; tych plików nie czytałem ponownie w tym researchu, `51b` też nie).

Oznaczenia przy twierdzeniach:
- **[zweryfikowane]**: sprawdzone w źródle pierwotnym (link) w tym researchu.
- **[wtórne]**: recenzja, blog dostawcy lub streszczenie strony bez lektury całości.
- **[niezweryfikowane]**: wiedza ogólna albo strona nie dała się pobrać (403/404/pusta).
- **[wniosek]**: moje rozumowanie albo propozycja.

Ograniczenie metody: strony cennikowe Pixellab, Retro Diffusion, Leonardo, Midjourney, Tripo ładują się dynamicznie lub blokują pobieranie, więc ich ceny są **[niezweryfikowane]** albo **[wtórne]**. Przed zakupem czegokolwiek sprawdzić ceny ręcznie.

## TL;DR

1. **Żadne narzędzie AI nie gwarantuje kąta z promptu.** To wniosek 51 i nic go w 2026 nie zmieniło. Pixellab dokumentuje kamerę jako podpowiedź z orientacyjnymi kątami: `low top-down` ok. 20° od poziomu, `high top-down` ok. 35°, `side`, `none` **[zweryfikowane: OpenAPI Pixellab, opis `animate-with-text-v2`]**. To jest dużo płaszczej niż 45° z prototypu (a przy 20° front dominuje nad wierzchem). **[wniosek]** To kolejny argument, żeby kąt gry wybrać z testu sześcianu, a nie z założenia.
2. **Pixellab ma dziś najszerszy zestaw „w jednym miejscu”**: postać v3 z 8 rotacjami, animacja z tekstu i ze szkieletu (`estimate skeleton` + `animate with skeleton`), outfit transfer, interpolacja, tilesety top-down/sidescroll/izometryczne, `Tiles Pro`, `map objects`, rotate postaci i obiektów, normal map, unzoom/correct pixel art/reduce colors, portrety z ustami, UI, VFX, MCP i wtyczka Aseprite **[zweryfikowane: llms.txt Pixellab, strona główna]**. Nie ma dowodu, że to samo kamera/rzut dla wszystkich tych klas.
3. **Najbardziej wartościowy kontrkandydat: Retro Diffusion (API + Aseprite).** Ma natywne style `rd_pro__topdown`, `rd_plus__topdown_asset/item/map`, `rd_pro__isometric`, `rd_tile__*` i `rd_animation__four_angle_walking`, `input_palette` (twarda paleta), `reference_images` (do 9, tylko RD Pro), `check_cost` (darmowy dry-run), animacje od klatki startowej (`rd_advanced_animation__walking/idle/attack/rotate`) **[zweryfikowane: api-examples]**. Cena RD Pro 0,18 USD/obraz, animacje 0,07-0,25 USD **[zweryfikowane]**. To jedyne narzędzie z jawnym wejściem paletowym w API.
4. **Spójność rzutu daje tylko geometria jako wejście** (render Blendera, prowadnica, maska, ControlNet depth/normal). Droga 3D (Blender ortho → pikselizacja) pozostaje najpewniejsza dla sztywnych mebli i fasad; image-to-3D (TRELLIS.2, Hunyuan3D) jest tylko dla organiki i wymaga GPU 24-29 GB, więc lokalnie prawdopodobnie odpada **[wniosek: nie znam GPU użytkownika]**.
5. **Pułapki licencyjne warte uwagi:** Hunyuan3D 2.1 ma licencję **wyłączającą UE, Wielką Brytanię i Koreę Płd.** (użytkownik jest w UE) **[zweryfikowane: LICENSE]**; FLUX.2 dev jest „non-commercial” dla wag (wyniki do komercyjnych użyć wg karty modelu, ale karta sama sobie przeczy) **[zweryfikowane, niejednoznaczne]**; FLUX.2 klein 4B jest Apache 2.0, 9B nie **[zweryfikowane]**; Qwen-Image-Edit-2511 jest Apache 2.0 **[zweryfikowane]**; TRELLIS.2 jest MIT **[zweryfikowane]**.
6. **Rekomendowany zestaw do przetestowania (nie decyzja):** Pixellab (punkt odniesienia), Retro Diffusion API, pipeline „Blender ortho + pikselizacja + opcjonalna edycja AI”, ComfyUI z Qwen-Image-Edit-2511 / FLUX.2 klein 4B + własny LoRA stylu, Scenario (trening stylu) jako opcja. Nowe, mniej znane (Ludo.ai, Sorceress, LlamaGen PixelBox) tylko jako tani test wejścia, bo źródła o nich to głównie blogi dostawców.

## 1. Kryteria i klasy assetów

Klasy zgodne z `grafika.md`: (A) postacie + animacje + warianty, (B) meble/rekwizyty, (C) budynki/fasady/kafle. Dla każdego narzędzia pytamy: skąd bierze kąt (wejście vs podpowiedź), jak trzyma styl, czy wyjście jest natywnym pixel artem, czy jest API, ile kosztuje, co mówi licencja.

## 2. Narzędzia pixel-art-natywne

### 2.1 Pixellab
- **Co robi [zweryfikowane: [llms.txt](https://api.pixellab.ai/v2/llms.txt), [strona główna](https://www.pixellab.ai)]:**
  - (A) postać v3 (8 rotacji), tryby Pro, 4 i 8 kierunków; animacja z tekstu (v3, PixMiniMax, Pro v2), ze szkieletu, interpolacja, edycja animacji, outfit transfer, nowe „states” istniejącej postaci (to jest mechanizm wariantów strojów); eksport ZIP/spritesheet.
  - (B) obiekty 1- i 8-kierunkowe, `map objects`, stany obiektów, dodane animacje obiektów.
  - (C) tilesety top-down (Wang-style), sidescroller, `Tiles Pro`, kafle izometryczne; `map object`.
  - Narzędzia: inpaint, edycja obrazu, `image to pixel art`, `unzoom`, `correct pixel art`, `reduce colors`, `normal map`, `remove background`.
  - Dodatki dla klimatu: portrety i generowanie pozycji ust (talking), VFX, UI, font.
- **Kąt:** `view` + `direction` jako podpowiedź (kąty orientacyjne: ok. 20° / 35°). `reference_image` w `create-character-v3` max 256×256 i „musi być zwrócony na południe” **[zweryfikowane: OpenAPI]**. Rotate: zgodnie z `grafika.md` trenowany na postaciach; do mebli nie ufać.
- **Styl:** `style_images` (generate-with-style), `reference_image`, `outline`, `detail` (v3 from-scratch), wymuszona paleta w animate-with-skeleton **[zweryfikowane: OpenAPI, fragment]**.
- **Wyjście:** natywny pixel art, rozmiar kwadratowy 16-256 (animacja ze szkieletu: 16/32/64/128/256) **[zweryfikowane]**. Postać bardziej szczegółowa niż 75 px zmieści się w 128 lub 256.
- **API/automatyzacja:** REST v2 z `llms.txt`, jobs/cancel, `GET /balance`, endpointy kosztu tylko dla Pro Flash; MCP; wtyczka Aseprite; Pixelorama w przeglądarce **[zweryfikowane]**.
- **Cena:** strona cen nie pobrała się (404 / ładowanie dynamiczne). Blogi: ok. 10 i 30 USD/mies. plus osobne rozliczanie API **[wtórne, niepewne: [Knowara](https://knowara.com/ai-tools/image/pixellab-review/)]**. Użytkownik ma subskrypcję, więc sprawdzi limity u siebie.
- **Licencja:** wtórne źródła: komercyjne użycie na planach płatnych, zakaz trenowania innych modeli na wynikach **[wtórne]**. Sprawdzić regulamin, jeśli planujemy LoRA na wynikach Pixellab. **[wniosek]** to jest realne ryzyko dla ścieżki „własny LoRA na zatwierdzonych assetach”, jeśli zatwierdzone assety pochodzą z Pixellab.

### 2.2 Retro Diffusion (RD)
- **Co robi [zweryfikowane: [api-examples](https://github.com/Retro-Diffusion/api-examples)]:**
  - (A) `rd_animation__four_angle_walking` (+ `_idle`; tylko 48 px), `rd_animation__8_dir_rotation`, `rd_animation__battle_sprites`; z klatki startowej 32-256 px: `rd_advanced_animation__walking/idle/jump/crouch/attack/destroy/custom_action/subtle_motion` oraz `__rotate` (8 widoków obiektu).
  - (B) `rd_plus__topdown_asset/item`, `rd_pro__topdown`, `rd_tile__tile_object`, `rd_tile__scene_object` (64-384 px).
  - (C) `rd_tile__tileset` (wang, kafle 16-32), `_advanced` (osobne tekstury wewnątrz/zewnątrz), `rd_plus__topdown_map`, `rd_pro__isometric` (12-256 px).
- **Kąt:** nazwa stylu (`topdown`, `isometric`); API nie dokumentuje ustawienia kąta, więc to podpowiedź. Kąt `topdown` trzeba zmierzyć. `img2img` (`input_image` + `strength` 0-1) pozwala podać szary box lub render jako wejście, to jest najbliższe „geometrii jako wejściu” w narzędziu pixel-art-natywnym **[zweryfikowane + wniosek]**.
- **Styl:** do 9 `reference_images` (tylko RD Pro), `input_palette` (obraz palety, <1 MB, twarde ograniczenie kolorów) + `return_pre_palette`, `seed`, style użytkownika `user__<nazwa>_<id>`, `tile_x/tile_y` (bezszwowość) **[zweryfikowane]**. Palette lock wprost w API to przewaga nad Pixellab (tam znalazłem go tylko w animate-with-skeleton).
- **Wyjście:** natywny pixel art, `upscale_output_factor=1` = piksel w piksel; `remove_bg` **[zweryfikowane]**.
- **API:** pełne, `check_cost` (dry-run bez opłaty), selektor stylów `GET /v2/styles/selector` z limitami **[zweryfikowane]**. Dla agenta to bardzo wygodne.
- **Cena [zweryfikowane]:** RD Fast 0,03 USD, Plus/Mini 0,06, Pro 0,18, tilesety 0,10, animacje 0,07 (0,25 dla `8_dir_rotation`, `any_animation`, `big_animation`), advanced animation 0,14 (`custom_action`/`subtle_motion` 0,25, `rotate` 0,10) za obraz. Płatność za użycie, więc bake-off kosztuje kilka dolarów.
- **Rozszerzenie Aseprite** (osobny produkt na itch.io/Gumroad): model trenowany na licencjonowanych assetach z zgodą artystów, redukcja kolorów, paleta z tekstu; modele działają tylko w Aseprite; model do animacji nie jest dystrybuowany lokalnie z powodu rozmiaru i licencji **[wtórne: [GitBook](https://astropulse.gitbook.io/retro-diffusion/aseprite-extension/retro-diffusion-for-aseprite), komentarze itch.io]**.
- **Licencja:** deweloper w komentarzach: wygenerowane obrazy należą do użytkownika; tekst licencji w plikach rozszerzenia **[wtórne]**. Dla API nie sprawdziłem regulaminu **[niezweryfikowane]**.

### 2.3 Inne narzędzia sprite/pixel (do taniego sprawdzenia)
- **Ludo.ai [zweryfikowane: [pricing](https://ludo.ai/pricing)]:** sprite z jednego obrazu lub tekstu, do 8 kierunków „renderowanych z jednego modelu 3D” w wybranym stylu 2D, 641 presetów ruchu, animacje do 5 s; Indie 15 USD/mies. (bez API), Pro 35 USD/mies. (API/MCP/CLI, 12 000 kredytów/rok), Studio 300 USD/mies. Strona nie wspomina pixel artu ani licencji komercyjnej **[niezweryfikowane]**. **[wniosek]** Mechanizm „jeden model 3D → 8 kierunków” jest interesujący dla spójności kamery postaci, ale styl nie musi być pixel artem. Warto tylko, jeśli próbka będzie natywnie pixelowa.
- **Sorceress, LlamaGen PixelBox, Gamelabs Studio, Sprite AI, SEELE:** pojawiają się w wynikach wyszukiwania 2026, ale to blogi dostawców i wątki Reddit **[wtórne, nie weryfikowałem produktów]**. Jeden z artykułów zauważa, że AI nadal słabo trzyma spójność klatek animacji i zaleca ręczne czyszczenie **[wtórne: [FreeGameSprites](https://freegamesprites.com/news/ai-pixel-art-generation-2026-tools-and-workflows)]**. Nie wnoszą nic ponad Pixellab/RD, dopóki nie dowiodą rzutu; zostają poza shortlistą.
- **God Mode AI:** nie znalazłem w tym researchu żadnego źródła pierwotnego **[niezweryfikowane]**.

## 3. Platformy ogólne ze stylem trenowanym

### 3.1 Scenario
- **Co [zweryfikowane: [pricing](https://www.scenario.com/pricing)]:** trenowanie własnych modeli: styl z 10-30 obrazów, postać/obiekt z 5-15, najlepiej 1024×1024, 30 min do kilku godzin, multi-LoRA (styl + podmiot); plany: Starter 15 USD/mies. (1500 kredytów), Pro 45 USD (5000 kredytów, trening modeli), Max 75 USD; „API-first”; licencja komercyjna na wszystkich płatnych planach; darmowy plan tylko do użytku osobistego.
- **Kąt:** brak warunku geometrycznego znalezionego na stronie; LoRA stylu może „nauczyć” kąt, jeśli zbiór treningowy ma jeden kąt **[wniosek]**. Strona cennika nie wspomina pixel artu **[zweryfikowane]**; wyjście trzeba będzie pikselizować.
- **Zastosowanie:** trening na zatwierdzonych assetach (z Blendera/Pixellab) bez własnego GPU. Wymaga plan Pro (45 USD/mies.).

### 3.2 Layer.ai
- **[zweryfikowane: [pricing](https://www.layer.ai/pricing)]:** od 10 USD/mies. za 300 CU; trening stylu w Studio; REST API, SDK TS, CLI; licencja komercyjna w Studio; pixel art: tylko model „Image2Pixel” 0,1 CU/generację (jakość nieznana). **[wniosek]** To agregator modeli; nie ma tu mechanizmu rzutu. Niski priorytet.

### 3.3 Leonardo, Midjourney
- Strony pobrały się z błędem 403 / brak danych w tym researchu. **[niezweryfikowane]**: Midjourney ma `--sref` (style reference) i `--oref` (omni reference), ale nie ma oficjalnego API i nie jest natywnym pixel artem. **[wniosek]** Przydatne do konceptów nastrojowych (nordic-noir), nie do assetów gry; ewentualnie obok ComfyUI. Leonardo: nie sprawdzałem, poza shortlistą.

## 4. Modele ogólne (koncept i edycja z referencją)

| Model | Fakty | Wniosek |
|---|---|---|
| **Gemini (Nano Banana)** | API: Nano Banana 2.1 0,034 USD/1K, Nano Banana 2 0,067 USD/1K, Pro 0,134 USD/1K-2K; stary `gemini-2.5-flash-image` wygasa 2027-03-15 **[zweryfikowane: [cennik](https://aistudio.google.com/docs/pricing)]**; do 14 referencji **[zweryfikowane w 51]** | Tani koncept i edycja z referencją; kąt nie jest gwarantowany. |
| **OpenAI GPT Image** | modele `gpt-image-2.5-sunburst` (precyzyjna edycja) i `-flare` (szybki); maska działa „wyłącznie przez prompt”; `background: transparent`; strona przyznaje słabą spójność powtarzających się postaci **[zweryfikowane: [dokumentacja](https://developers.openai.com/api/docs/guides/image-generation)]** | Do konceptów i napraw; maska nie jest twarda, więc nie jako źródło rzutu. |
| **FLUX.2** | klein 4B Apache 2.0, klein 9B i dev: licencja non-commercial dla wag; referencje: klein 4, dev ok. 6, pro/flex/max do 8 przez API **[zweryfikowane: [BFL](https://docs.bfl.ai/flux_2/flux2_overview), [HF dev](https://huggingface.co/black-forest-labs/FLUX.2-dev)]**; dev: 32 mld parametrów | Obecny silnik konceptów. Do własnego LoRA bezpieczny licencyjnie jest klein 4B. |
| **Qwen-Image-Edit-2511** | Apache 2.0, 20 mld parametrów, multi-image, poprawiona spójność postaci, wbudowane popularne LoRA (m.in. nowy punkt widzenia) **[zweryfikowane: [HF](https://huggingface.co/Qwen/Qwen-Image-Edit-2511)]** | Kandydat do edycji „render → wersja malarska” w ComfyUI. Wbudowany „nowy widok” nie znaczy kontrolowany kąt **[wniosek]**. |
| **ControlNet / IP-Adapter** | ControlNet: canny, depth, normal, HED, M-LSD, segmentacja, scribble, pose **[zweryfikowane w 51]**; dla SDXL/SD1.5 | Najlepszy mechanizm „geometria jako warunek” w ComfyUI, ale nie dla FLUX.2/Qwen (oficjalnego nie znaleziono w 51). IP-Adapter: nie weryfikowałem **[niezweryfikowane]**. |
| **Pixel-art LoRA w ComfyUI** | nie badałem konkretnych LoRA/licencji (Civitai/HF) **[niezweryfikowane]** | Do wyboru ręcznego w bake-off; sprawdzić licencję każdej LoRA osobno. |

## 5. Własny LoRA stylu

- **ai-toolkit (ostris)** [zweryfikowane: [GitHub](https://github.com/ostris/ai-toolkit)]: licencja MIT; obsługuje FLUX.1-dev, FLUX.2-dev, FLUX.2-klein-base (4B i 9B), Qwen-Image (2512), Qwen-Image-Edit, Z-Image, SDXL, SD1.5 i inne; ma Windows (`run_windows.bat`, instalacja przez venv + PyTorch). Wymagania VRAM nie są podane (przykładowa konfiguracja FLUX „24gb”). Kohya: nie weryfikowałem **[niezweryfikowane]**.
- **[wniosek]** LoRA stylu pomaga w spójności *wyglądu*, nie kąta. Ma sens po 15-30 zatwierdzonych assetach (jak w 51). Zbiór treningowy powinien pochodzić z Blendera lub ręcznych poprawek, żeby nie naruszyć warunków Pixellab (patrz §2.1) i by kąt był jednolity.
- Alternatywa bez GPU: Scenario (§3.1).

## 6. Pipeline 3D-wspomagany

- **Blender ortho rig → pikselizacja** (51 §5, 46). Zalety: kąt i proporcje wymuszone konstrukcją; normal mapy z renderu. Ryzyko: wygląd CG. Blender wymaga instalacji i zgody użytkownika **[z 51]**. Kamerę ortogonalną da się skonfigurować skryptem bez AI; koszt per asset: spec JSON + render.
- **TRELLIS.2** [zweryfikowane: [GitHub](https://github.com/microsoft/TRELLIS.2)]: image-to-3D, 4 mld parametrów, wyjście GLB z PBR, licencja MIT (zależności mają własne), **wymaga GPU NVIDIA ≥24 GB, testowany tylko na Linuksie**. Na Windows użytkownika to prawdopodobnie nie ruszy bez WSL/chmury **[wniosek]**.
- **Hunyuan3D 2.1** [zweryfikowane: [README](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1), [LICENSE](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1/blob/main/LICENSE)]: VRAM ok. 10 GB (kształt), 21 GB (tekstura), 29 GB (razem); licencja **nie obejmuje UE, UK i Korei Płd.**; powyżej 1 mln MAU potrzebna zgoda Tencent. **Dla użytkownika w Polsce odpada lokalnie.**
- **Tripo, Meshy:** Meshy: darmowy plan to CC BY 4.0, płatne: assety prywatne i własność klienta, API od planu Pro **[zweryfikowane: [Meshy pricing](https://www.meshy.ai/pricing), ceny podane w PLN, np. Pro 73 zł/mies. za 1000 kredytów]**. Tripo: **[niezweryfikowane]**. Image-to-3D to opcja tylko dla organiki (krzesła, rośliny), jak w 51.
- **Pikselizacja:** `unfake` (już używany w prototypie) **[zweryfikowane w 51]**; Pixellab `correct pixel art` / `reduce colors` / `unzoom` i RD `color_reducer` / `palette_converter` (0,001 USD) **[zweryfikowane]**. Pixel It i modele pikselizujące: **[niezweryfikowane]**, nie badałem.
- **Aseprite:** CLI `--batch` ("uruchamia Aseprite tylko do przetworzenia opcji") i `--script plik.lua`, `--script-param nazwa=wartość` **[zweryfikowane: [CLI](https://www.aseprite.org/docs/cli/)]**. Licencja i cena: nie sprawdzone (strona odsyła do /buy). Aseprite nie jest zainstalowany wg `CLAUDE.md`; to byłby zakup do uzgodnienia z użytkownikiem. Wtyczki Pixellab i RD wymagają Aseprite.

## 7. Tabela porównawcza

Skala: ++ dobre, + częściowe, ? brak danych, - brak. „Kąt” = czy wejście wymusza rzut.

| Narzędzie | A: postacie+anim.+warianty | B: meble | C: budynki/kafle | Kąt | Spójność stylu | Wyjście | API | Cena (zweryfikowana) | Licencja |
|---|---|---|---|---|---|---|---|---|---|
| Pixellab | ++ (v3, szkielet, outfit transfer) | + (map objects, 8-dir) | + (tilesety, izometria) | podpowiedź (~20°/~35°) | `style_images`, referencja | natywny | REST+MCP+Aseprite | subskrypcja użytkownika | wtórne: komercyjna, zakaz trenowania na wynikach |
| Retro Diffusion | + (4-angle 48 px, adv. animation od klatki) | + (topdown_asset/item) | ++ (tileset, scene_object) | podpowiedź + img2img | `input_palette`, 9 referencji, user styles | natywny | REST + `check_cost` | 0,03-0,25 USD/obraz | wtórne: wyniki własnością użytkownika |
| Ludo.ai | + (8 kier. z modelu 3D) | ? | ? | model 3D | ? | nie wiadomo | Pro+ | 15/35/300 USD/mies. | niepodane |
| Scenario | + (trening postaci) | + | + | z danych treningowych | LoRA styl/postać | pikselizować | API | 15-75 USD/mies. | komercyjna (płatne) |
| Layer.ai | ? | ? | ? | - | trening stylu (Studio) | pikselizować | tak | od 10 USD/mies. | komercyjna (Studio) |
| Gemini / GPT Image | koncept, edycja | koncept | koncept | podpowiedź | referencje (14) | pikselizować | tak | 0,03-0,13 USD/obraz (Gemini) | wg regulaminu (nie sprawdzone) |
| FLUX.2 klein 4B / Qwen-Image-Edit + LoRA (ComfyUI) | koncept; LoRA | edycja renderu | edycja renderu | podpowiedź; render jako wejście | LoRA, referencje | pikselizować | lokalnie/ComfyUI | koszt GPU | Apache 2.0 |
| ControlNet (SDXL) | pose | depth/normal | depth/canny | wymusza (zarys) | model bazowy | pikselizować | lokalnie | GPU | zależna od modelu |
| Blender ortho | ++ (manekin, rig) | ++ | ++ | wymusza | stały etap końcowy | pikselizować | skrypt | darmowy | GPL, render własny |
| TRELLIS.2 | - | + (organika) | - | przez rig | - | mesh | lokalnie (Linux, 24 GB) | GPU | MIT |
| Hunyuan3D 2.1 | - | + | - | przez rig | - | mesh | lokalnie | GPU | wyłącza UE |
| Meshy | - | + | - | przez rig | - | mesh | Pro+ | od 73 zł/mies. | własność klienta (płatne) |

## 8. Shortlista do testu (nie decyzja)

1. **Pixellab**: punkt odniesienia dla A i B, sprawdzić też `map objects` i `Tiles Pro` dla C.
2. **Retro Diffusion API**: A (4-angle walking, advanced animation z klatki startowej z Pixellab/konceptu), B/C (topdown_asset, tile_object, scene_object, tileset), z `input_palette` równą palecie projektu i `check_cost`.
3. **Blender ortho + unfake/paleta**: kontrola rzutu dla B i C (oraz manekin dla A). Wymaga instalacji (zgoda).
4. **Warstwa edycji AI na renderze:** RD `input_image`+`strength`, Pixellab `image_to_pixelart`/`edit`, albo ComfyUI Qwen-Image-Edit-2511 / FLUX.2 klein 4B z renderem jako wejściem.
5. **Opcjonalnie:** Scenario (trening stylu na zatwierdzonych assetach, jeśli LoRA lokalny odpadnie z powodu VRAM), Ludo.ai (tylko próbka 8-kierunkowej postaci).

Poza shortlistą na razie: Midjourney, Leonardo, Layer.ai, Hunyuan3D (licencja UE), TRELLIS.2 (sprzęt), nowinki z blogów.

**Który asset obsłuży które narzędzie [wniosek, do potwierdzenia testem]:** postacie i animacje: Pixellab lub RD; meble i fasady: Blender + warstwa edycji lub RD/Pixellab z boxem jako wejściem; kafle terenu: RD tilesety lub Pixellab tilesety, albo płaskie wierzchy z Blendera; organika: Pixellab/RD + ręczne dopracowanie.

## 9. Protokół bake-off (zgodny z `grafika.md`)

Wspólne zasady: ta sama paleta (`palette.hex`), ten sam test automatyczny (`tools/asset_check`, paleta, alfa 0/255, bbox ±1 px), ta sama ocena w scenie, wynik zapisany w `prompts.jsonl` (prompt, seed, wejście, wersja modelu, koszt, czas).

1. **Przygotowanie (raz, 1-2 h):** szary box 1×1×1 m, lada (np. 1,6×0,6×0,9 m), manekin ~1,75 m; render z kamery ortogonalnej pod dowolnym wstępnym kątem (np. 45°) jako wejście; plik palety; arkusz referencyjny scenki.
2. **Test A, kąt:** każde narzędzie generuje sześcian i ladę (a) tylko z promptu i ustawień kamery narzędzia, (b) z boxem jako wejściem (`input_image`, referencja, `reference_image`). Zmierzyć proporcję wierzch:front w pikselach (skrypt Node); zapisać wynik jako kąt narzędzia. Kryteria: kąt stały w 5 próbach (seedy), odchylenie ≤ ±2 px.
3. **Test B, postać:** jedna postać (koncept bazowy → ten sam wejściowy obraz) w 4 kierunkach, cykl chodu (4-8 klatek), plus 1 wariant stroju (kurtka/bez) z tego samego konceptu. Mierzyć: wysokość sylwetki, stabilność wysokości i kąta między kierunkami, dryf kolorów, migotanie konturu w animacji, liczba klatek do ręcznej poprawki.
4. **Test C, paleta:** odsetek pikseli spoza palety przed i po kwantyzacji; czy narzędzie samo trzyma paletę (RD `input_palette`, Pixellab wymuszona paleta), czy trzeba `unfake quantize`.
5. **Test D, meble i kafle:** 3 meble (kanapa, stół, regał) w 2 orientacjach oraz kafel podłogi i fragment fasady; ocena spójności z lądą i sześcianem z testu A.
6. **Koszt i czas:** dla każdego assetu: kredyty/USD (z `check_cost` albo konta), czas generacji, liczba prób do akceptacji, minuty ręcznej poprawki. Cel z `grafika.md`: ≤2-3 generacje, bez ręcznych poprawek powyżej drobiazgów.
7. **Ocena w scenie:** asset w pokoju obok wzorców, światło dzienne i nocne (normal mapa z narzędzia lub z Blendera), skala ×1 i ×4. Ocena 1-5 za: kąt, nastrój (nordic-noir, mniej „infantylnie”), czytelność, spójność z resztą. Zatwierdza użytkownik.
8. **Wynik:** tabela narzędzie × klasa assetu (kąt, % palety, koszt, czas, ocena) i wybór kąta gry z pomiarów (otwarta decyzja 1 w `grafika.md`).

## 10. Pytania otwarte

1. Dokładne ceny i limity Pixellab, RD (subskrypcja vs API), Leonardo, Tripo: nie pobrały się; do ręcznego sprawdzenia.
2. Regulamin RD API i Pixellab w sprawie praw do wyników oraz trenowania na nich.
3. Jakie GPU ma użytkownik (decyduje o ComfyUI, ai-toolkit, TRELLIS.2). Nie znam **[niezweryfikowane]**.
4. Czy kupić Aseprite (potrzebne do wtyczek i skryptów Lua).
5. Czy kąt ~20°/~35° z Pixellab, 45° z prototypu i styl `topdown` RD się pokrywają: rozstrzyga Test A.
6. Mniej znane narzędzia (Ludo.ai, Sorceress, LlamaGen PixelBox): jakość próbek nieznana.

## Źródła
- Pixellab: [llms.txt](https://api.pixellab.ai/v2/llms.txt), [OpenAPI](https://api.pixellab.ai/v2/openapi.json) (strona obcięta, przeczytane 100 tys. z 500 tys. znaków), [strona główna](https://www.pixellab.ai), [dokumentacja](https://www.pixellab.ai/docs); cennik [wtórne]: [Knowara](https://knowara.com/ai-tools/image/pixellab-review/)
- Retro Diffusion: [api-examples](https://github.com/Retro-Diffusion/api-examples); [Aseprite GitBook](https://astropulse.gitbook.io/retro-diffusion/aseprite-extension/retro-diffusion-for-aseprite), [itch.io](https://astropulse.itch.io/retrodiffusion) [wtórne]
- [Scenario pricing](https://www.scenario.com/pricing), [Ludo.ai pricing](https://ludo.ai/pricing), [Layer.ai pricing](https://www.layer.ai/pricing), [Meshy pricing](https://www.meshy.ai/pricing)
- [Gemini pricing](https://aistudio.google.com/docs/pricing), [OpenAI image generation](https://developers.openai.com/api/docs/guides/image-generation), [BFL FLUX.2](https://docs.bfl.ai/flux_2/flux2_overview), [FLUX.2-dev HF](https://huggingface.co/black-forest-labs/FLUX.2-dev), [Qwen-Image-Edit-2511](https://huggingface.co/Qwen/Qwen-Image-Edit-2511)
- [ai-toolkit](https://github.com/ostris/ai-toolkit), [TRELLIS.2](https://github.com/microsoft/TRELLIS.2), [Hunyuan3D-2.1](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1), [licencja Hunyuan3D 2.1](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1/blob/main/LICENSE)
- [Aseprite CLI](https://www.aseprite.org/docs/cli/)
- [wtórne] przegląd 2026: [LlamaGen](https://llamagen.ai/en-gb/articles/best-ai-pixel-art-generators-2026), [FreeGameSprites](https://freegamesprites.com/news/ai-pixel-art-generation-2026-tools-and-workflows), [Sorceress](https://sorceress.games/blog/quick-sprites-generate-animated-pixel-art-sprite-sheets-with-ai)
- Repo: `docs/grafika.md`, `docs/research/51-spojna-grafika-3-4.md`, `input-fixed.txt`
