> Kopia z game1 (`repo/game1/docs/research/24a-generatory-mcp.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Generatory pixel artu sterowane przez Claude Code (MCP / HTTP API)

Ticket: `docs/wayfinder/tickets/24-assety-przez-claude.md`. Rozszerza `08-assety-ai.md`. Data researchu i dostępu do wszystkich źródeł: **2026-10-28**.

Zakres (po doprecyzowaniu przez człowieka): etap **koncept → spójny asset pixel art**. Koncept-art (tekst + obrazy referencyjne → wybór wyglądu) robi osobny research. Tu: czy generator przyjmuje obraz koncepcyjny / referencję stylu / referencję postaci, jak wiernie trzyma tożsamość i styl przez wiele assetów, czy da się zablokować własny styl, plus normal mapy, autokontrola przez Claude i lokalny ComfyUI.

Wymagania gry: 640×360, widok 3/4 z góry, kafle 32 px, postacie ok. 60 px wysokości, 4 kierunki, idle + chód, światła 2D z normal mapami w przestrzeni obrazu (fronty „na południe”, blaty „do góry”, por. `game1-proto/prototype/lighting/art.gd`).

## TL;DR

- **Pixellab** ma najpełniejszy, oficjalny, hostowany serwer MCP (HTTP, jedna komenda `claude mcp add`). Robi postać z obrazu (koncept w dowolnej pozie → 8 kierunków albo gotowy sprite „na południe” → 4/8 kierunków), animacje z szablonów (`walk`, `breathing-idle`), obiekty i kafle ze stylem z obrazu, a do tego **normal mapy** (`create_normal_map`, 0.1 generacji). Abonament: 12 / 24 / 50 USD/mies. za 2000 / 5000 / 10000 generacji.
- **Retro Diffusion** ma oficjalny hostowany MCP (33 narzędzia) i REST, płatność z góry w USD bez abonamentu. Przyjmuje do 9 obrazów referencyjnych (RD Pro), konwertuje obraz w pixel art (`rd_pro__pixelate`), obraca sprite w 8 kierunków (0.10 USD) i animuje klatkę startową (walking/idle, 0.14 USD). Pozwala zapisać **własny styl** z jednego obrazu. Nie ma normal map.
- **Scenario** to jedyna droga z prawdziwym treningiem własnego modelu (LoRA) z waszych konceptów, z MCP (97+ narzędzi). Nie ma jednak narzędzi pixel-art-specyficznych (kierunki, cykle chodu) poza modelami firm trzecich (m.in. Retro Diffusion). Ludo.ai ma MCP, ale nie potwierdziłem rotacji 4 kierunków w API. God Mode AI: brak potwierdzonego API.
- **Rekomendacja:** Pixellab Tier 2 (24 USD) na 1–2 miesiące produkcji, przez MCP w Claude Code. Retro Diffusion trzymać jako tani zapas (pay-as-you-go) do propsów i konwersji koncept → piksel. Normal mapy: Pixellab `create_normal_map` plus własny skrypt „przechylający” normalne pod konwencję 3/4. Laigter CLI jako darmowa alternatywa. **Wszystko do weryfikacji na próbce Krogga i biurka** (zatoka assetów w prototypie oświetlenia).

## 1. Pixellab

### Setup w Claude Code
- Token: zaloguj się na https://api.pixellab.ai/mcp (strona daje sekret). [pixellab.ai/mcp](https://www.pixellab.ai/mcp)
- Komenda (z oficjalnej strony MCP):
  `claude mcp add pixellab https://api.pixellab.ai/mcp -t http -H "Authorization: Bearer YOUR_SECRET"` [pixellab.ai/mcp](https://www.pixellab.ai/mcp)
- Serwer jest hostowany (HTTP), nie trzeba Pythona ani Node. Repo `pixellab-code/pixellab-mcp` istnieje, ale ostatni push był 2025-08-10, a aktualny jest endpoint hostowany. [GitHub API](https://api.github.com/repos/pixellab-code/pixellab-mcp)
- Narzędzia są asynchroniczne: zwracają ID joba, a wynik daje `get_character` / `get_image` / `wait_for_jobs` (5–540 s). Typowo trwa to 2–5 min. Linki do pobrania nie wymagają autoryzacji (UUID = klucz), więc nie publikuj ich. [MCP docs](https://api.pixellab.ai/mcp/docs)
- REST v2 (`https://api.pixellab.ai/v2`, Bearer) ma też eksport postaci jako ZIP i spritesheet (`GET /characters/{id}/zip`, `/spritesheet`). [llms.txt](https://api.pixellab.ai/v2/llms.txt)

### Koncept → postać (kluczowe dla workflow)
Z [MCP docs](https://api.pixellab.ai/mcp/docs):
- `create_character`, `mode="pro"`, `concept_image_url`/`_base64`: koncept, obraz, szkic lub zdjęcie postaci **w dowolnej pozie**. Z niego projektowane jest 8 kierunków. „Wynik zachowuje wygląd, nie pozę ani płótno”. Koszt 10–25 generacji, zawsze 8 kierunków (z których bierzemy 4).
- `mode="v3"`, `reference_image_url`: gotowy sprite patrzący **prosto na widza** (south), maks. 256×256, obracany do 4/8 kierunków. Sprite odwrócony w 3/4 przesuwa wszystkie kierunki. `direction_images` pozwala podać kierunki już narysowane, a import kompletu kosztuje 0.25 generacji. Koszt v3: 2 generacje do 88 px, 2–9 zależnie od rozmiaru.
- `style_character_id` (pro): istniejąca postać 8-kierunkowa jako wzorzec stylu dla nowej. To mechanizm „blokady stylu” między postaciami. `create_character` **nie ma seeda**, więc spójność między postaciami zapewnia tylko style character albo referencja.
- `create_character_state`: wariant tej samej postaci (np. bez płaszcza) z zachowaniem tożsamości, 10–25 generacji.
- `image_to_pixelart`: obraz/render → pixel art, 1 generacja, `output_width` 16–512. Daje drogę „koncept → sprite south → v3 rotacja”.
- `create_image_pro`: `style_image_url` (kopiuje paletę, kontur, detal, cieniowanie; wybór przez `style_copy`), do 4 `reference_images` z opisem użycia, `palette`/`max_colors`. Koszt 10–25 za wywołanie, przy małych płótnach wiele kandydatów naraz (np. 16 kandydatów 52–65 px).
- `create_1_direction_object`: obiekty ze `style_images`, 10–25 generacji. Przy rozmiarze ≤85 px daje 16 kandydatów w jednym strzale. `create_map_object`: 32–400 px, widok `low/high top-down`, styl z tła mapy.
- Parametr `view`: `low top-down` (~20°, domyślny), `high top-down` (~35°), `side`. Dla 3/4 sensowne jest `low top-down`; do sprawdzenia na próbce, który pasuje do kafli 32 px.

### Rozmiar ~60 px: działa
- `size` 16–256 (maks. 128 w standard/pro, 256 w v3). Standard traktuje `size` jako rozmiar postaci na płótnie ok. 40% większym (64 → 92×92). Postać 60 px wysokości mieści się więc w `size≈64`. [MCP docs](https://api.pixellab.ai/mcp/docs)

### Animacje
- `animate_character`: szablony humanoidalne, m.in. `walk` (6 kl.), `walking-8-frames` (8), `walking-4-frames` (4), `breathing-idle` (4). Samego `idle` nie ma. Tryb `template` kosztuje 1 generację na kierunek do ~92 px płótna. `skeleton-v3` (beta) to ten sam szablon nałożony na postać („stabilniejsza tożsamość i kolory”), 3 generacje na kierunek dla 4–14 klatek. `v3` to animacja z opisu, 4–16 klatek (parzyste). Joby trwają 2–5 min na kierunek. [MCP docs](https://api.pixellab.ai/mcp/docs)

### Kafle
- `create_topdown_tileset` (Wang, 16 lub 32 px; standard 1 gen ~30 s, pro 15 gen), `create_tiles_pro` (do 16 kafli na wywołanie, `square_topdown`, 16–128 px), `create_path_tiles`, `create_building_kit`. [MCP docs](https://api.pixellab.ai/mcp/docs)

### Cennik (z publicznego endpointu planów strony i jej bundla JS, bo strona cennika renderuje się dynamicznie)
| Plan | USD/mies. | USD/rok | Generacje/mies. | Uwagi |
|---|---|---|---|---|
| Free trial | 0 | – | 40 szybkich, potem 5/dzień (do 20) | API i MCP w cenie, obrazy do 200×200, **bez narzędzi map** |
| Tier 1 Pixel Apprentice | 12 | 99 | 2000 | do 320×320, animacje, mapy |
| Tier 2 Pixel Artisan | 24 | 220 | 5000 | do 512×512, kolejka priorytetowa, 10 równoległych jobów, narzędzia eksperymentalne |
| Tier 3 Pixel Architect | 50 | 500 | 10000 | 20 równoległych jobów |

Źródła: [api.pixellab.ai/get-subscriptions](https://api.pixellab.ai/get-subscriptions) (ceny), [pixellab.ai](https://www.pixellab.ai/) (cechy i liczba generacji w kodzie strony). **Niepewność:** liczby generacji pochodzą z mapowania w kodzie front-endu, nie z opublikowanej tabeli. Sprawdź `get_balance` po zakupie.

### Licencja
- FAQ: użycie komercyjne tak, z jednym zakazem: nie trenować modeli na wynikach. Assety AI na Steam „dozwolone”, z adnotacją o ankiecie Steam o AI. [FAQ](https://www.pixellab.ai/docs/faq)
- Przypis przy planach: „The user owns the rights to the generations with the exception of using them to train models” (dotyczy też trialu wg listy cech). [pixellab.ai](https://www.pixellab.ai/)
- Ocena prawna i ujawnienie AI na Steam: ticket 09 (`docs/research/09-prawa.md`).

## 2. Retro Diffusion i inne

### Retro Diffusion (Astropulse)
- **MCP:** hostowany `https://mcp.retrodiffusion.ai/mcp`, 33 narzędzia (generacja, darmowe wyceny, joby async, edycja, Pixel Fixer, własne style, saldo). Komenda z oficjalnego repo:
  `claude mcp add --transport http retro-diffusion https://mcp.retrodiffusion.ai/mcp --header "Authorization: Bearer rdpk-YOUR-KEY"`. Jest też plugin Claude Code ze skillem workflow. [retro-diffusion-mcp](https://github.com/Retro-Diffusion/retro-diffusion-mcp), [api-examples](https://github.com/Retro-Diffusion/api-examples)
- **Płatność:** saldo USD z góry (bez abonamentu), zwrot przy błędzie, `check_cost` za darmo. Wyniki do pobrania przez 24 h. [llms.txt](https://github.com/Retro-Diffusion/api-examples/blob/main/llms.txt)
- **Koncept → piksel:**
  - `rd_pro__pixelate` + `input_image`: konwersja obrazu w pixel art. Dokumentacja wprost mówi, że to jest konwersja, a `reference_images` „re-imaginuje”.
  - `reference_images` (RD Pro, do 9) prowadzą styl i treść. Zalecenie producenta: „wygeneruj postać raz w RD Pro, potem podawaj ją jako referencję. Sam opis tekstowy nigdy nie zastąpi referencji”.
  - `input_palette` wymusza paletę.
  - **Własny styl:** `POST /v2/styles` (lub MCP `create_user_style`) z dokładnie 1 obrazem referencyjnym, opcjonalnie z wymuszoną paletą i usuwaniem tła. To „szablon referencji”, nie trening LoRA.
- **4 kierunki + chód:**
  - `rd_advanced_animation__rotate`: 8 widoków z wgranego sprite'a (32–256 px, wielokrotność 8), 0.10 USD. Klatki 2/4/6/8 to kierunki kardynalne.
  - `rd_advanced_animation__walking` / `__idle`: animuje wgraną klatkę startową (32–256 px), 0.14 USD.
  - Gotowe `rd_animation__four_angle_walking(_idle)` z promptu mają tylko **48×48**, czyli za mało na postać 60 px.
- **Ceny za obraz:** rd_fast 0.03, rd_plus 0.06, rd_pro 0.18, kafle pojedyncze 0.06, tileset 0.10 USD. Limity: RD Pro 12–256 px, style ogólnie do 384 px. [llms.txt](https://github.com/Retro-Diffusion/api-examples/blob/main/llms.txt)
- **Normal mapy:** brak w API (w llms.txt nie ma takiej funkcji).
- **Licencja:** strona ToS jest renderowana dynamicznie i nie udało się jej odczytać. Jedyne znalezione to nieformalna odpowiedź dewelopera na itch.io, że wygenerowane obrazy należą do użytkownika. [itch.io](https://astropulse.itch.io/retrodiffusion). **Do sprawdzenia ręcznie** na retrodiffusion.ai.

### Scenario
- MCP z 97+ narzędziami (`model_run`, `train` dostępny przez `?toolsets=full`). Serwer obsługuje Claude Code, ale nie znalazłem dokładnej komendy. [mcp.scenario.com](https://mcp.scenario.com), [docs MCP](https://docs.scenario.com/get-started/mcp/mcp/index.md)
- Jedyna z opcji z **treningiem własnego modelu** (LoRA) z waszych obrazów: od planu Pro 45 USD/mies. (5000 kredytów). Max kosztuje 75 USD (10000). Darmowe 50 kredytów dziennie tylko do użytku osobistego. Kredyty nie przechodzą na kolejny miesiąc. [pricing](https://www.scenario.com/pricing)
- Ma Retro Diffusion jako model firmy trzeciej. Nie znalazłem natywnych narzędzi do rotacji 4 kierunków i cykli chodu. Ma sens dopiero przy zestawie 10–30 zaakceptowanych konceptów (por. `08-assety-ai.md`).

### Ludo.ai
- MCP `https://mcp.ludo.ai/mcp`: `claude mcp add ludo-ai https://mcp.ludo.ai/mcp -t http -H "Authentication: ApiKey YOUR_API_KEY"`. Narzędzia: `createImage` (0.5 kr.), `animateSprite` (5 kr.) i inne. API wymaga planu „z dostępem API” (wg porównania Ludo: Pro 50 USD/mies., źródło drugorzędne). [blog Ludo 2026-01-29](https://ludo.ai/blog/introducing-ludo-ai-api-mcp-integration)
- Rotator 8 kierunków istnieje na stronie (beta), ale **nie potwierdziłem go w API/MCP**. [sprite-rotation-generator](https://ludo.ai/tools/sprite-rotation-generator). Nie jest wyspecjalizowany w pixel arcie.

### God Mode AI
- Tylko źródła drugorzędne: 8 kierunków, wiele animacji, ceny sprzeczne (pakiety 12 USD lub abonament 10–19 USD). **Nie znalazłem publicznego API ani MCP.** [ludo.ai/compare](https://ludo.ai/compare/best-ai-sprite-generators). Odpada dla workflow „Claude steruje”.

### Inne MCP
- `jmorais1988/pixelworks-mcp`: nieoficjalny serwer (stdio, 169 narzędzi: Retro Diffusion + bezgłowy Aseprite + Krita), utworzony 2026-09, 0 gwiazdek. Ciekawy jako pomysł, ale niezweryfikowany. [GitHub](https://github.com/jmorais1988/pixelworks-mcp)

### Porównanie: koncept → spójna postać 4-kierunkowa z chodem
| | Koncept (dowolna poza) → postać | Sprite → 4/8 kierunków | Chód/idle z tej postaci | Blokada stylu | MCP | Normal mapy |
|---|---|---|---|---|---|---|
| Pixellab | tak (`pro` + `concept_image`) | tak (`v3` + reference) | tak (szablony, skeleton-v3) | `style_character_id`, `style_image`, paleta | oficjalny, hostowany | **tak** |
| Retro Diffusion | pośrednio (`pixelate` lub refs → sprite) | tak (`rotate`, 8 widoków) | tak (`advanced_animation` z klatki) | user style (1 obraz), refs ≤9, paleta | oficjalny, hostowany | nie |
| Scenario | tak (własna LoRA) | nie natywnie | nie natywnie | **trening LoRA** | tak | nie |
| Ludo.ai | ogólnie tak | nie potwierdzone w API | `animateSprite` | ? | tak | nie |

**Wierność tożsamości i stylu:** żadne źródło pierwotne nie podaje mierzalnej wierności. Pixellab sam ostrzega, że opcje stylu to „soft guidance” i że referencja 3/4 psuje kierunki. Ocena możliwa tylko na próbce (Krogg + biurko w zatoce assetów).

## 3. Normal mapy

- **Pixellab `create_normal_map`** (MCP i REST `POST /normal-map`): wejście to rotacja albo **cała animacja** postaci/obiektu, URL lub base64. `convention`: `opengl` (green = up, dla Godota) lub `directx`. `kind`: character/object/topdown/side/iso/ui. Strojenie: `strength`, `outline_rounding`, `part_shapes`, `surface_detail`, `detail_softness`. Koszt lite 0.1 gen (sekundy, „prawie zawsze równie dobry”), pro 0.5 gen. [MCP docs](https://api.pixellab.ai/mcp/docs)
- **Laigter CLI** (GPL3, v1.14.0 z 2026-08-07, instalator Windows): `laigter --no-gui -d <plik|katalog> -n [-c] [-o] [-r preset] [-l katalog_wyjścia] [--flatten] [--check-changes] [--normal-suffix _n]`. Flagi wzięte z kodu `main.cpp`. Godot poleca Laigter w dokumentacji świateł 2D. [main.cpp](https://github.com/azagaya/laigter/blob/master/main.cpp), [release](https://github.com/azagaya/laigter/releases/tag/1.14.0), [Godot docs](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- **Problem konwencji 3/4:** oba narzędzia wyliczają normalne z kształtu i jasności („poduszka”). Płaski front biurka wyjdzie wtedy skierowany do widza, a nie „na południe” jak w `art.gd` (`SOUTH = (0, 0.8, 0.6)`, `UP = (0, -0.45, 0.89)`, obraz y w dół). **Propozycja (niezweryfikowana):** skrypt Node (np. `pngjs`, lokalna zależność npm) obraca każdą normalną o stały kąt: dla postaci i frontów o kąt odpowiadający `SOUTH`, dla kafli podłogi bez zmian. Dla mebli z blatem trzeba maski „blat/front”: prosty podział po krawędzi albo druga generacja maski przez AI. Claude może napisać ten skrypt sam. Kierunek kanału zielonego sprawdzić przełącznikiem `B` w prototypie (on/off/odwrócone Y).

## 4. Autokontrola przez Claude (iteracja bez człowieka)

- Claude Code czyta PNG narzędziem Read (obraz trafia do modelu). Sprite 60 px jest jednak za mały do oceny, więc trzeba go **powiększyć nearest-neighbor ×6–8 i złożyć w arkusz kontaktowy** (4 kierunki × klatki, obok normal mapa i podgląd na tle sceny). Do tego skrypt Node (np. `sharp`) albo Godot headless. Ścieżkę do Godota trzeba dostać od człowieka.
- Kontrole, które trzeba robić **programowo**, bo model wizyjny ich nie widzi: przezroczystość (kanał alfa; model widzi tło po kompozycji), wymiary, liczba kolorów, linia stóp (najniższy nieprzezroczysty piksel), zgodność palety z referencją. Tak samo zaleca dokumentacja Retro Diffusion. [llms.txt](https://github.com/Retro-Diffusion/api-examples/blob/main/llms.txt)
- Przy kontroli wizualnej Claude porównuje z obrazem konceptu: ten sam płaszcz, kolory, proporcje, czy kierunek „south” patrzy na widza, czy chód nie „pływa”. Przy niezgodności ponawia z poprawionym opisem lub referencją. Limit iteracji ustaw w prompcie (np. 3 próby na asset), bo każda kosztuje generacje.
- Najmocniejszy test: wrzucić asset do zatoki assetów prototypu i zrobić zrzut (`.\run.ps1 -Shots -Assets`), a potem ocenić zrzut. Ostateczna akceptacja zostaje przy człowieku. Ocena „czy to ładny pixel art” przez model wizyjny jest **niepewna**.
- Uwaga z MCP docs: przy obrazach powyżej ~32 px należy podawać **URL zamiast base64**, bo klienci MCP ucinają długie stringi. Lokalny plik wgrywa się przez `get_upload_url` lub jako `upload:<id>`.

## 5. Lokalnie: ComfyUI na RTX 4060 Laptop 8 GB

- ComfyUI Desktop / Portable (Windows, NVIDIA) ma własny Python, więc nie zależy od stuba `python` z Microsoft Store. Według README działa nawet od 4 GB VRAM dzięki strumieniowaniu wag. Ma HTTP API (`/prompt`), więc Claude może nim sterować. [ComfyUI README](https://github.com/comfyanonymous/ComfyUI)
- Modele pixel art: `nerijs/pixel-art-xl` (LoRA SDXL, 33k pobrań, licencja OpenRAIL-M; autor zaleca zmniejszenie wyniku ×8 nearest-neighbor i poprawiony VAE). [HF](https://huggingface.co/nerijs/pixel-art-xl). LoRA FLUX/FLUX.2 klein, np. `adirik/pixel-art-lora-flux.2-klein-4B`, `Muapi/top-down-pixel-art-flux-lora` (licencje do sprawdzenia per model). [HF search](https://huggingface.co/models?search=pixel%20art%20flux)
- „Lokalny model Retro Diffusion” to rozszerzenie Aseprite (65 USD, wygaszane przez autora, bez animacji). `LostMedia/RetroDiffusion` na HF jest nieoficjalny. Zob. `08-assety-ai.md`.
- Koncept → sprite lokalnie: img2img z konceptu + LoRA pixel art + ControlNet (pose/lineart) + IP-Adapter dla stylu, potem downscale i czyszczenie palety. **Spójność 4 kierunków i cykli chodu jest tu najsłabsza:** nie znalazłem otwartego odpowiednika rotacji postaci i szablonów chodu Pixellab. Trzeba by składać pozy przez ControlNet klatka po klatce i ręcznie pilnować tożsamości (np. trenując własną LoRA postaci). To wymaga oceny i poprawek, czyli tego, czego człowiek nie umie.
- **Wniosek:** na 8 GB SDXL + LoRA działa (wniosek z wymagań, nietestowany), ale dla osoby bez doświadczenia artystycznego lokalny ComfyUI **nie bije** Pixellab/RD w kroku koncept → spójna postać 4-kierunkowa z animacją. Ma sens do koncept-artu (osobny research) i ewentualnie do propsów, gdzie spójność kierunków nie gra roli.

## Rekomendacja i setup krok po kroku (Windows + Claude Code)

**Wybór:** Pixellab przez MCP, plan Tier 2 na czas produkcji. Retro Diffusion MCP jako uzupełnienie (konwersja koncept → piksel, tanie propsy, pay-as-you-go).

1. Zarejestruj się na pixellab.ai (trial bez karty: 40 generacji, MCP działa, ale bez narzędzi map). Na trialu przetestuj jedną postać.
2. Pobierz token z https://api.pixellab.ai/mcp. Nie wpisuj go do repo.
3. W katalogu projektu (PowerShell): `claude mcp add pixellab https://api.pixellab.ai/mcp -t http -H "Authorization: Bearer <TOKEN>"`. Sprawdź: `claude mcp list`, a w sesji `/mcp`. Domyślny zakres to lokalny/użytkownika. **Nie** używaj `-s project`, bo token trafiłby do `.mcp.json` w repo.
4. (Opcjonalnie) RD: klucz z https://www.retrodiffusion.ai/app/devtools, potem `claude mcp add --transport http retro-diffusion https://mcp.retrodiffusion.ai/mcp --header "Authorization: Bearer rdpk-..."`. Doładuj saldo np. 10 USD.
5. Laigter: instalator `laigter-setup-1.14.0.exe` z GitHub Releases, jako zapas dla normal map.
6. Pierwszy test (Krogg): zaakceptowany koncept → `create_character(mode="pro", concept_image_url=..., view="low top-down", size=64)`. Alternatywnie `image_to_pixelart` → ręczny wybór sprite'a south → `create_character(mode="v3", reference_image_url=..., n_directions=4)`. Dalej `animate_character` z `walk` i `breathing-idle` (najpierw `template`, przy dryfie `skeleton-v3`), potem `create_normal_map(kind="character", convention="opengl")` dla rotacji i animacji, na koniec eksport ZIP do `assets/pixellab/` w zatoce prototypu i zrzuty `.\run.ps1 -Shots -Assets`.
7. Gdy wygląd zaakceptowany: tę postać ustaw jako `style_character_id` dla kolejnych. Dla propsów `create_1_direction_object` / `create_map_object` ze `style_images` z zaakceptowanego biurka. Dla podłóg `create_topdown_tileset` 32 px.
8. Po teście trialowym kup Tier 2 (24 USD) na miesiąc produkcji. Po zakończeniu anuluj. Licencja wg przypisu dotyczy wygenerowanych plików (warto to potwierdzić w ToS przed anulacją).

### Szacunek kosztu (10 postaci × 4 kier. × idle + chód, ~100 propsów/kafli)
| Pozycja | Pixellab (generacje) | Retro Diffusion (USD) |
|---|---|---|
| 10 postaci (pro z konceptu 10–25 gen; v3 z referencji 2 gen) × ~3 próby | 60–750 | 10 × (3 × 0.18 + 2 × 0.10) ≈ 7.4 |
| Animacje: 10 × 4 kier. × 2 (template 1 gen / skeleton-v3 3 gen) × ~2 próby | 160–480 | 10 × 4 × 2 × 0.14 × 2 ≈ 22.4 |
| Normal mapy (~120 wywołań, lite 0.1–pro 0.5) | 12–60 | brak (Laigter, 0 USD) |
| 100 propsów/kafli (1–25 gen, ~2 próby) | 200–2500 | 100 × 0.06–0.18 × 2 ≈ 12–36 |
| **Razem** | **~430–3800 gen** | **~42–66 USD jednorazowo** |

Pixellab: realistycznie **Tier 2 (24 USD/mies., 5000 gen) przez 1–2 miesiące ≈ 24–48 USD**. Tier 1 (12 USD) wystarczy tylko przy oszczędnej ścieżce (v3 + template + tanie kafle). Ceny RD za animację z klatki są liczone za kierunek, bo animacja przyjmuje jedną klatkę startową w danym kierunku (wniosek z opisu, do potwierdzenia przez `check_cost`).

## Niepewności (jawnie)
- Liczby generacji w planach Pixellab wzięte z kodu front-endu (publiczna tabela się nie ładuje).
- Koszt `animate_character` w trybie `v3` (bez szablonu) i dokładny koszt `create_map_object` nie są podane w przeczytanych fragmentach.
- Wierność tożsamości z konceptu, przydatność widoku `low top-down` do 3/4 i jakość normal map Pixellab w konwencji „front na południe”: tylko test na próbce.
- Licencja Retro Diffusion: ToS nieodczytane.
- Ludo: rotacja w API niepotwierdzona. God Mode AI: brak API.
- ComfyUI na 8 GB: wniosek z dokumentacji, nie z testu.
- Ocena estetyki przez model wizyjny jest zawodna; kontrole techniczne (alfa, wymiary, paleta) muszą być skryptowe.
