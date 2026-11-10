> Kopia z game1 (`repo/game1/docs/research/24d-concept-art.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Concept art przez AI sterowane z Claude Code (etap 1: ideacja)

Ticket: `docs/wayfinder/tickets/24-assety-przez-claude.md` (część d). Zakres: generowanie concept artu, mood boardów i style frame'ów z tekstu i obrazów referencyjnych, iteracja z Claude, oraz kształt wyników pod późniejszą konwersję do pixel artu (sama konwersja to inne części ticketu). Data researchu i dostępu do źródeł: **2026-10-28**.

**Zastrzeżenia:** ceny i limity pochodzą ze stron producentów, ale część stron ładuje ceny skryptem (BFL, Ideogram) i liczb nie dało się odczytać. Ocena jakości „dla concept artu” i spójności serii to wnioski z opisów funkcji, nie z własnych testów. Tam, gdzie źródło jest wtórne (blog, agregator), jest to zaznaczone.

## TL;DR

- **Główne narzędzie: Google Gemini API, modele Nano Banana** (`gemini-nano-banana-2.1` do szybkich iteracji, `gemini-3-pro-image` „Nano Banana Pro” do finalnych style frame'ów i arkuszy postaci). Najlepszy znaleziony zestaw referencji: Pro przyjmuje do 5 referencji postaci i do 3 referencji stylu, edycja przez rozmowę wieloturową. Koszt 0,034-0,134 USD/obraz.
- **Opcjonalnie drugie: OpenAI `gpt-image-2`** (lub nowsze 2.5) do precyzyjnych edycji „zmień tylko X” (maska, przezroczyste tło). 0,006 / 0,053 / 0,211 USD za 1024x1024 (low/medium/high).
- **Sterowanie z Claude Code: mały skrypt Node w repo** wołający REST, zamiast nieoficjalnych serwerów MCP. Ani OpenAI, ani Google nie mają oficjalnego MCP do generowania obrazów (Recraft, fal.ai i Scenario mają, patrz niżej).
- **Koszt fazy ideacji (200-400 obrazów/mies.): ok. 15-40 USD**, bez subskrypcji.
- **Lokalny ComfyUI na RTX 4060 Laptop 8 GB:** wykonalny (SDXL/Illustrious ok. 16 s/obraz, FLUX GGUF ok. 60-90+ s), Claude potrafi nim sterować przez HTTP API, ale setup i nauka są duże, a jakość „concept artu z referencji” gorsza niż Nano Banana Pro. Werdykt: nie na start ideacji; wrócić, jeśli etap 2 będzie wymagał własnej LoRA stylu.
- Midjourney: brak oficjalnego API, automatyzacja łamie regulamin. Odpada.

## 1. Usługi chmurowe

### Google Gemini (Nano Banana)
- Modele (wg dokumentacji): Nano Banana 2.1 `gemini-nano-banana-2.1` (główny, „high-efficiency workhorse”), Nano Banana 2 `gemini-3.1-flash-image`, 2 Lite `gemini-3.1-flash-lite-image` (bez wielu referencji i edycji wieloturowej), Pro `gemini-3-pro-image`. Stary `gemini-2.5-flash-image` wycofywany (wyłączenie 2 października 2026). [Image generation docs](https://ai.google.dev/gemini-api/docs/image-generation)
- Referencje: do 14 obrazów w żądaniu. Obiekty: do 10 (2.1), do 6 (Pro). **Postacie: do 4 (2.1), do 5 (Pro). Referencje stylu: do 3 (tylko Pro).** Tabela w pobranej treści była spłaszczona, odczyt wiersz po wierszu, więc zweryfikować na stronie. [docs](https://ai.google.dev/gemini-api/docs/image-generation)
- Edycja: tekst + obraz → obraz (dodaj/usuń/zmień element, styl, color grading). Iteracja zalecana jako rozmowa wieloturowa (`previous_interaction_id`). Rozdzielczość do 4K, domyślnie 1K. **Każdy obraz ma znak wodny SynthID.** [docs](https://ai.google.dev/gemini-api/docs/image-generation)
- REST: `POST https://generativelanguage.googleapis.com/v1beta/interactions`, nagłówek `x-goog-api-key`, w `input` tablica z obiektami `{"type":"text"}` i `{"type":"image","mime_type":"image/png","data":"<base64>"}`, proporcje w `response_format.aspect_ratio`. Dokumentacja poleca Pro i 3.1 Flash Image do sekwencji (storyboard, komiks). [docs](https://ai.google.dev/gemini-api/docs/image-generation)
- Ceny za obraz (standard / batch): 2.1: 1K 0,0336 / 0,0168; 2K 0,0504; 4K 0,113. Pro: 1K i 2K 0,134 / 0,067; 4K 0,24. **Darmowy tier nie obejmuje generowania obrazów.** [pricing](https://ai.google.dev/gemini-api/docs/pricing)
- Warunki: Google nie rości sobie praw do wygenerowanych treści (ale może wygenerować podobne innym). Na płatnym tierze prompty i odpowiedzi nie są używane do ulepszania produktów; na darmowym są. [Gemini API terms](https://ai.google.dev/gemini-api/terms)
- MCP: tylko społecznościowe (np. conechoai/nano-banana-mcp, Pgarciapg/mcp-nano-banana, tougenrip/nano-banana-claude w Pythonie); różne wersje modeli, część przestarzała, kod niezweryfikowany. [GitHub conechoai](https://github.com/conechoai/nano-banana-mcp), [lista glama](https://glama.ai/mcp/servers/@Pgarciapg/mcp-nano-banana)

### OpenAI GPT Image
- Modele: `gpt-image-2`, `gpt-image-2.5-sunburst` (precyzja edycji), `gpt-image-2.5-flare` (szybka generacja); gpt-image-1/1.5/1-mini jako legacy. Jakość: low/medium/high, a 2.5 dodaje xhigh i max. [Image generation guide](https://developers.openai.com/api/docs/guides/image-generation)
- Edycja: wiele obrazów wejściowych (przykłady z 4, limitu nie podano), maska z kanałem alfa, ale maskowanie jest „prompt-based”, więc kształt maski jest traktowany orientacyjnie. Przezroczyste tło (`background: "transparent"`, png/webp). Rozmiary do 3840 px na bok, powyżej 2560x1440 eksperymentalnie. `gpt-image-2` zawsze przetwarza wejście w wysokiej wierności. [guide](https://developers.openai.com/api/docs/guides/image-generation)
- Ceny gpt-image-2 za obraz: 1024x1024 low 0,006, medium 0,053, high 0,211; 1536x1024 low 0,005, medium 0,041, high 0,165. Tokeny: image output 30 USD/1M, image input 8 USD/1M (batch o połowę taniej). [guide](https://developers.openai.com/api/docs/guides/image-generation), [pricing](https://developers.openai.com/api/docs/pricing)
- `gpt-image-2` może wymagać weryfikacji organizacji (inaczej HTTP 403); to informacja z README społecznościowego MCP, nie z docs OpenAI. [glama: gpt-image-mcp](https://glama.ai/mcp/servers/skyjoe66/gpt-image-mcp)
- MCP: brak oficjalnego; są społecznościowe (lpenguin/openai-image-mcp, gregpriday/create-image-mcp). Regulamin OpenAI (ownership outputu) niedostępny dla WebFetch (403), nie zweryfikowany w tej sesji.

### Black Forest Labs FLUX.2 (bfl.ai, także fal.ai i Replicate)
- Warianty: [klein] (4B Apache 2.0, 9B non-commercial; do 4 referencji), [pro], [flex], [max] (do 8 referencji przez API, 10 w playground), [dev] lokalny. Do 4 MP. **Kolory podawane kodami hex**, co pasuje do trzymania palety. [FLUX.2 overview](https://docs.bfl.ai/flux_2/flux2_overview)
- Ceny: rozliczenie za megapiksel, 1 kredyt = 0,01 USD; konkretne kwoty nie wczytały się ze strony. Kalkulator pokazał 0,048 USD/obraz bez przypisanego modelu. [pricing docs](https://docs.bfl.ai/quick_start/pricing), [bfl.ai/pricing](https://bfl.ai/pricing)
- Oficjalny MCP fal.ai: `claude mcp add --transport http --scope user fal https://mcp.fal.ai/mcp-relay`, logowanie OAuth przez `/mcp`. Narzędzia: search_models, get_pricing, run_model, upload_file itd. Wyniki są linkami CDN, więc trzeba je pobrać do repo. Daje dostęp do wielu modeli (FLUX, Nano Banana, GPT Image) przez jedno konto. [fal MCP](https://fal.ai/docs/model-apis/mcp)

### Recraft
- API: V4.1 raster 0,035, V4 0,04, V4.1 Flash 0,007, V4 Styles 0,035; referencje stylu +0,005/żądanie; **utworzenie custom style 0,005**; inpainting/outpainting V3 0,04. [API pricing](https://www.recraft.ai/docs/api-reference/pricing)
- Custom style: V4 przyjmuje 1-10 obrazów referencyjnych, bez treningu („one is enough”); `style_id` jest przypięty do modelu, z którym go utworzono. Wbudowany styl „Pixel art” tylko w V2/V3. [styles](https://www.recraft.ai/docs/api-reference/styles)
- MCP: stary `@recraft-ai/mcp-recraft-server` zarchiwizowany 13 lipca 2026; README poleca zdalny `claude mcp add --transport http recraft https://mcp.recraft.ai/mcp`. Strona docs MCP nie wczytała się (405/404), więc sposób autoryzacji jest niepotwierdzony. [GitHub](https://github.com/recraft-ai/mcp-recraft-server)
- Ocena: najtańsza „blokada stylu” z kilku obrazów. Recraft jest mocny w ilustracji i grafice wektorowej. Dla nastrojowego, oświetleniowego concept artu nie ma dowodu, że dorównuje Nano Banana Pro (niezweryfikowane).

### Scenario
- Plany: Starter 15 USD (1500 kredytów, bez treningu), Pro 45 USD (5000, trening własnych modeli), Max 75 USD. Licencja komercyjna na płatnych planach, darmowe 50 kredytów tylko do oceny. Koszt kredytów na obraz zależy od modelu (niepodany). [pricing](https://www.scenario.com/pricing)
- Oficjalny MCP: `claude mcp add --transport http scenario https://mcp.scenario.com/mcp` (OAuth). Udostępnia ponad 60 narzędzi i ponad 550 modeli, w tym własne wytrenowane. Trening odbywa się w aplikacji www. [Scenario MCP docs](https://docs.scenario.com/get-started/mcp/mcp), [blog](https://www.scenario.com/blog/Scenario-Is-Now-Available-Directly-in-Your-AI-Agent)
- Ocena: bardziej na etap 2 (własny model stylu z wybranych conceptów) niż na ideację.

### Pozostałe
- **Midjourney:** brak oficjalnego API; regulamin zakazuje automatyzacji, a nieoficjalne wrappery grożą banem konta. Źródła są wtórne (np. [myarchitectai](https://www.myarchitectai.com/blog/midjourney-apis)), oficjalnego oświadczenia nie znalazłem. Można go używać ręcznie w www, ale nie z Claude Code.
- **Ideogram:** subskrypcje Plus 20 / Pro 60 USD, pay-as-you-go 1 centa za kredyt; cennik API ładuje się skryptem (nieodczytany). Mocny w tekście w obrazie, a ten projekt tego nie potrzebuje. [pricing](https://ideogram.ai/pricing/?pricing_tab=api)
- **Leonardo:** plany 12/30/60 USD; ceny API sprzeczne w źródłach wtórnych. Nie badany dalej. [eesel (wtórne)](https://eesel.ai/blog/leonardo-ai-pricing)
- **Stability:** nie badany szczegółowo, bo nie wyróżnia się w referencjach postaci.

## 2. Lokalnie: ComfyUI na RTX 4060 Laptop (8 GB VRAM, 32 GB RAM)

### Instalacja (bez systemowego Pythona)
- **Comfy Desktop** (instalator .exe z comfy.org/download): launcher zarządzający instalacjami; modele w `%LOCALAPPDATA%\Comfy-Desktop\ComfyUI-Shared`. Przy pierwszym starcie wybiera się Comfy Cloud albo instalację lokalną. Strona nie mówi wprost, czy Python jest dołączony. [Desktop Windows](https://docs.comfy.org/installation/desktop/windows)
- **Portable** (`ComfyUI_windows_portable_nvidia.7z`): ma w paczce Python 3.13 i PyTorch CUDA 13.0, wystarczy rozpakować i uruchomić. Wymaga karty z serii 20 lub nowszej (4060 spełnia) i aktualnego sterownika. [README](https://github.com/comfyanonymous/ComfyUI)
- Rekomendacja: portable, bo jest samowystarczalny i Claude widzi go jako zwykły folder.

### Co się zmieści i jak szybko
| Model | 8 GB? | Czas / obraz 1024² | Licencja (wyniki) |
|---|---|---|---|
| SDXL + Illustrious/WAI | tak, bez `--lowvram` | ok. 15,8 s na 4060 Laptop ([jeden test](https://lilting.ch/en/articles/comfyui-local-rtx4060-wai-illustrious)) | Illustrious-XL: CreativeML OpenRAIL-M ([HF](https://huggingface.co/OnomaAIResearch/Illustrious-XL-v2.0)) |
| FLUX.1 dev / Kontext dev GGUF Q4 lub NF4 | tak, z offloadem | 60-90 s na desktopowym 8 GB, laptop wolniej ([wtórne](https://evezone.evetech.co.za/build-lab/how-to-run-flux-on-8gb-vram-using-gguf-quantised-models)) | wyniki komercyjnie OK, ale patrz uwaga niżej |
| Chroma1-HD (na bazie schnell, 8,9B) | prawdopodobnie z kwantyzacją (brak danych o VRAM) | brak danych | Apache 2.0 ([HF](https://huggingface.co/lodestones/Chroma1-HD)) |
| Qwen-Image / Qwen-Image-Edit-2509 GGUF | **niepewne**: źródła sprzeczne (od „8-12 GB” do „min. 14 GB dla Q4_K_M”) | brak danych | Apache 2.0 ([HF](https://huggingface.co/Qwen/Qwen-Image-Edit-2509)) |
| HiDream | nie badano; duży model, raczej poza 8 GB | – | – |

- **Uwaga o FLUX.1 [dev]/Kontext [dev]:** licencja mówi, że wyników można używać komercyjnie („any purpose (including for commercial purposes)”), zakazuje trenowania na nich konkurencyjnych modeli, **ale** samo uruchamianie modelu „for any commercial or production purposes” wymaga osobnej licencji. „Non-commercial purpose” wyklucza też użycie „for revenue-generating activity”. Generowanie conceptów do komercyjnej gry to szara strefa, więc to nie jest porada prawna. Ta sama uwaga dotyczy FLUX.2 [dev] i [klein] 9B. [FLUX.1-dev LICENSE](https://huggingface.co/black-forest-labs/FLUX.1-dev/blob/main/LICENSE.md), [Kontext dev](https://huggingface.co/black-forest-labs/FLUX.1-Kontext-dev)
- Licencje fine-tune'ów i LoRA z Civitai różnią się między sobą; każdy plik trzeba sprawdzać osobno.

### Referencje i kontrola
- **IPAdapter Plus** (SD1.5/SDXL): transfer stylu albo obiektu, warianty composition i FaceID. Repo jest w trybie „maintenance only” od kwietnia 2025. Nie wspiera FLUX. [GitHub](https://github.com/cubiq/ComfyUI_IPAdapter_plus)
- **Kontext dev / Qwen-Image-Edit:** lokalne odpowiedniki edycji „zmień tylko X”; na 8 GB są wolne (Kontext) albo niepewne (Qwen).
- ControlNet (pozy, krawędzie, głębia): dojrzały dla SDXL. W tej sesji nie sprawdzałem szczegółów.

### Trening LoRA stylu na 8 GB
- Kohya sd-scripts: LoRA SDXL działa na 8 GB (10 GB zalecane), jeśli trenuje się tylko U-Net, z gradient checkpointing, cache text encoderów, optymalizatorem 8-bit lub Adafactor i rangą (dim) 4-8. [kohya SDXL docs (mirror)](https://huggingface.co/datasets/ACCC1380/private-model/raw/refs%2Fpr%2F8/lora-scripts/sd-scripts/docs/train_SDXL-en.md)
- OneTrainer ma prostsze GUI. Czas treningu na 8 GB: brak twardych danych, źródło anegdotyczne mówi „od nocy do kilku dni”. [Medium](https://medium.com/@alivesin/lora-training-step-3-training-your-first-lora-da8e54a33df2)
- LoRA dla FLUX na 8 GB: nie zweryfikowano, raczej niepraktyczne.

### Sterowanie ComfyUI z Claude Code
- **HTTP API** (bez MCP): `POST /prompt` z workflow w formacie API zwraca `prompt_id`; dalej `GET /history/{id}`, `GET /view`, `POST /upload/image`, WebSocket `/ws`; `/object_info` opisuje wejścia węzłów. Claude może napisać skrypt Node, który podmienia prompt, seed i obrazy referencyjne w workflow JSON i odpala kolejkę. [routes](https://docs.comfy.org/development/comfyui-server/comms_routes)
- **Oficjalny comfy-mcp** (Comfy-Org): narzędzia `run_workflow`, `fetch_outputs`, `validate_workflow`, `search_nodes`, `search_models`, `fetch_template`. Wymaga Python 3.10+, `pip install comfy-cli comfy-mcp`, a potem `claude mcp add comfy-mcp -e COMFY_BIN=<ścieżka>\comfy.exe -- comfy-mcp`. Istnieje też `comfy-local-mcp` (early preview). **Oba wymagają Pythona, którego użytkownik nie ma**, więc instalacja wymaga jego zgody (np. Python albo uv). [Comfy agent tools: local](https://docs.comfy.org/agent-tools/local), [GitHub comfy-mcp](https://github.com/Comfy-Org/comfy-mcp)
- **Czy Claude zbuduje workflow sam?** Częściowo. Format API to zwykły JSON z węzłami, a `/object_info` i `validate_workflow` pozwalają sprawdzić poprawność. W praktyce bezpieczniej startować od oficjalnych szablonów (`fetch_template`) i modyfikować je, niż składać graf od zera. To wniosek, nie przetestowane.

### Lokalnie czy chmura: werdykt dla tego użytkownika
| | Chmura (Nano Banana / GPT Image) | Lokalnie (ComfyUI, 8 GB) |
|---|---|---|
| Jakość conceptu z referencji | wysoka, rozumie złożone polecenia | dobra w SDXL dla ilustracji/anime, słabsza w realistycznym noir; FLUX lepszy, ale wolny |
| Spójność postaci | wbudowana (5 referencji postaci w Pro) | IPAdapter, LoRA, ręczne strojenie |
| Koszt | ok. 15-40 USD/mies. | 0 USD + prąd; GPU zajęte |
| Wysiłek | klucz API i skrypt, start w godzinę | dni nauki węzłów, modeli i licencji |
| Licencje | jasne (regulaminy dostawców) | per model; szara strefa FLUX dev |

**Werdykt:** ideacja w chmurze. ComfyUI warto rozważyć dopiero, gdy etap 2 będzie potrzebował własnej LoRA pixel artu lub dużych wolumenów. Wtedy trenować SDXL LoRA lokalnie albo w Scenario.

## 3. Prawo i Steam (skrót; szczegóły w `09-prawa.md`)
- Steam zaktualizował formularz w styczniu 2026: nie trzeba ujawniać narzędzi AI użytych „za kulisami” dla efektywności; ujawnieniu podlegają treści widoczne dla gracza (assety w grze, materiały marketingowe). Czy wewnętrzny concept art, który nie trafia do gry, wymaga ujawnienia, jest niejasne; wg relacji raczej nie. Jeśli jednak assety w grze powstaną z AI (etap 2), ujawnienie będzie potrzebne. Źródła wtórne, oficjalnego tekstu Steamworks nie pobrałem. [GameMeca](https://www.gamemeca.com/en/view.php?gid=1770331), [Gigazine](https://gigazine.net/gsc_news/en/20260120-steam-updates-ai-disclosure-guidelines)
- Gemini: brak roszczeń do outputu, ale podobne obrazy mogą powstać u innych, więc nie ma wyłączności. [terms](https://ai.google.dev/gemini-api/terms)
- Ochrona prawnoautorska czysto AI-generowanych obrazów jest wątpliwa; to temat `09-prawa.md`.

## 4. Workflow w repo

### Struktura folderu
```
art/concept/
  _refs/            # obrazy wgrane przez użytkownika (zrzuty z Disco Elysium, Replaced, zdjęcia Norwegii) + SOURCES.md (skąd, tylko do inspiracji)
  _style/           # STYLE.md (blokada stylu: opis, słowa-klucze, zakazy), palette.hex/.gpl, 2-3 „kanoniczne” style frame'y
  moodboards/       # kolaże per lokacja/nastrój
  locations/<nazwa>/  vNN_<seed|id>.png + prompts.jsonl
  characters/<imię>/  turnaround_vNN.png, expressions_vNN.png, sheet.md
  picks.md          # decyzje: co wybrane, dlaczego, link do pliku
tools/concept/gen.mjs # skrypt generujący (Node, bez zależności), zapisuje PNG + linię JSON z promptem, modelem, referencjami i kosztem
```
- Każdy wynik ma w `prompts.jsonl` wpis z pełnym promptem, modelem i listą referencji, żeby dało się go odtworzyć. Duże PNG warto trzymać przez Git LFS albo poza repo (decyzja do podjęcia).
- Pliki z `_refs/` (cudze gry) służą tylko jako wejście do ideacji i nie trafiają do gry. Warto to zaznaczyć w `SOURCES.md`.

### Pętla iteracji z Claude
1. Użytkownik wrzuca referencje do `_refs/` i opisuje nastrój. Claude czyta obrazy (Read obsługuje PNG/JPG) i proponuje 3-5 kierunków jako prompty.
2. `gen.mjs` generuje po 2-4 warianty kierunku w Nano Banana 2.1 1K (tanio).
3. Claude ocenia wyniki względem `STYLE.md` (paleta, kierunek światła, czytelność sylwetek w 3/4, zgodność z lutym w Norwegii) i proponuje poprawki. Użytkownik wybiera i zapisuje decyzję w `picks.md`.
4. Wybrany kierunek staje się style frame'em: Pro 2K z referencjami stylu (do 3) i dopisaniem do `_style/`.
5. Edycje punktowe (zmień tylko X) robi Nano Banana wieloturowo albo gpt-image-2 z maską.

### Wyniki pod konwersję do pixel artu (etap 2)
- **Style frame w docelowym kadrze:** proporcje 16:9 (640x360 x3 = 1920x1080), kamera 3/4 top-down jak w grze, jedna scena na lokację. Do tego **wersja „flat-lit”** (równomierne, rozproszone światło, bez mocnych cieni) jako podstawa albedo, osobno od wersji z nastrojem i światłem, która jest celem dla oświetlenia 2D i normal map Godota.
- **Turnaround postaci:** jeden arkusz z widokami przód, 3/4 przód, bok i tył (4 kierunki gry), postać w całości, neutralna poza (A-pose albo stojąca), szare lub białe tło, równe światło, ta sama wysokość postaci we wszystkich widokach. Osobno arkusz ekspresji (portrety do dialogów). Dla postaci ok. 60 px liczy się sylwetka i 2-3 bloki koloru, więc prompt ma prosić o czytelne, uproszczone kształty.
- **Paleta:** wyciągnąć z wybranych style frame'ów 16-32 kolory (kwantyzacja skryptem Node, np. median-cut na pikselach, bez Pythona), zapisać jako `.hex` i `.gpl` (Aseprite/Godot) w `_style/`. Kody hex można podawać w promptach FLUX.2 lub GPT Image.
- **Blokada stylu:** `STYLE.md` + 2-3 kanoniczne obrazy, które dołączamy jako referencje stylu do każdej generacji (Pro: 3 sloty), a w etapie 2 jako dane treningowe dla modelu stylu (Scenario 10-30 obrazów lub LoRA).

## 5. Rekomendacja i setup (Windows + Claude Code)

**Główne: Gemini API (Nano Banana 2.1 + Pro). Opcjonalnie drugie: OpenAI gpt-image-2** do precyzyjnych edycji i przezroczystych teł. Gdy w etapie 2 przyda się wybór wielu modeli z jednego miejsca, fal.ai MCP (oficjalny, OAuth) jest wygodną alternatywą bez własnego skryptu.

Kroki:
1. Google AI Studio: utworzyć klucz API i **włączyć billing** (darmowy tier nie generuje obrazów). Ustawić limit budżetu w Google Cloud.
2. Zapisać klucz jako zmienną użytkownika (PowerShell): `[Environment]::SetEnvironmentVariable("GEMINI_API_KEY","<klucz>","User")`, a potem zrestartować terminal i Claude Code. Klucza nie trzymać w repo; jeśli powstanie `.env`, dodać go do `.gitignore`.
3. (Opcjonalnie) to samo dla `OPENAI_API_KEY` i weryfikacja organizacji w OpenAI, jeśli gpt-image-2 zwraca 403.
4. Poprosić Claude o `tools/concept/gen.mjs` (Node 22, `fetch`, bez zależności), który robi `POST .../v1beta/interactions`, dołącza referencje base64, zapisuje PNG i loguje `prompts.jsonl`. Komendy w stylu `node tools/concept/gen.mjs --model pro --refs art/concept/_style/*.png --out art/concept/locations/posterunek "prompt"`.
5. Alternatywa bez skryptu (oficjalne MCP): `claude mcp add --transport http --scope user fal https://mcp.fal.ai/mcp-relay`, potem `/mcp` i logowanie. Wyniki trzeba pobierać z CDN do repo.
6. Utworzyć strukturę `art/concept/` z sekcji 4 i `STYLE.md`.

**Szacunek kosztów fazy ideacji (miesiąc):**
| Pozycja | Ilość | Cena | Suma |
|---|---|---|---|
| Nano Banana 2.1, 1K (warianty) | 250 | 0,034 | ~8,5 USD |
| Nano Banana Pro, 2K (style frame'y, turnaroundy) | 100 | 0,134 | ~13,4 USD |
| gpt-image-2 medium (edycje) | 50 | ~0,05 | ~2,5 USD |
| tokeny wejściowe referencji, poprawki | – | – | ~2-10 USD (szacunek) |
| **Razem** | ~400 | | **ok. 25-35 USD** (przy 200 obrazach ok. 15 USD) |

Batch API Gemini obniża koszty o połowę, ale wyniki nie przychodzą od razu, więc przy iteracji na żywo raczej się nie przyda.

## Niepewności
- Limity referencji Nano Banana odczytane ze spłaszczonej tabeli; nazwy modeli zmieniają się szybko (2.5 Flash Image wyłączony 2026-10-02).
- Ceny FLUX.2, Ideogram API, Leonardo API i Recraft MCP nieodczytane albo niepotwierdzone.
- Brak własnych testów jakości: kto wygra w nastrojowym, oświetleniowym noir (Nano Banana Pro czy gpt-image-2), trzeba sprawdzić na 10-20 promptach w obu.
- Ujawnienie AI na Steam według źródeł wtórnych; sprawdzić aktualny formularz Steamworks przed premierą.
- ComfyUI: czasy na 4060 Laptop to pojedyncze testy lub szacunki; Qwen-Image-Edit na 8 GB niepotwierdzony; licencja FLUX dev przy komercyjnej grze to szara strefa.
