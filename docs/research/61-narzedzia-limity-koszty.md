# Narzędzia, limity i koszty: lokalnie, triale, subskrypcja na Miesiąc produkcji

Data researchu: **2026-11-08**. Ticket: `docs/wayfinder/tickets/02-narzedzia-limity-koszty.md`. Ta notatka **aktualizuje** `52-narzedzia-pixel-art.md` pod model kosztów game2 (lokalnie, potem triale, potem jedna subskrypcja ~100 zł/mies. na Miesiąc produkcji). Nie powtarzam opisu funkcji z 52; tu tylko licencje, limity, ceny, Steam i kolejność testów. To nie jest porada prawna.

Oznaczenia: **[zweryfikowane]** = przeczytane w źródle pierwotnym w tym researchu; **[wtórne]** = recenzja, blog, komentarz, wyszukiwarka; **[niezweryfikowane]** = nie udało się odczytać; **[wniosek]** = moje rozumowanie.

Ograniczenie metody: strona cen Pixellab ładuje plany dynamicznie („Loading subscription plans...”), strony regulaminu Retro Diffusion (RD) i dokumentacja GitBook RD są puste lub „work in progress”, regulamin Ludo.ai nie dał się odczytać. Wszystkie ceny Pixellab to **[wtórne]**. Przed zakupem człowiek czyta je na koncie.

## TL;DR

1. **Sprzęt zmierzony lokalnie [zweryfikowane]:** RTX 4060 Laptop 8 GB VRAM, 32 GB RAM. 32 GB RAM jest kluczowe: ComfyUI ma offloading wag do RAM i modele kwantyzowane, więc większe modele „wejdą”, ale wolniej **[wniosek]**.
2. **Lokalnie za darmo i bez blokady licencyjnej na Steam:** FLUX.2 klein 4B (Apache 2.0), Qwen-Image-Edit-2511 (Apache 2.0, GGUF), SDXL + ControlNet depth + LoRA pixel-art-xl (OpenRAIL; komercyjnie dozwolone, bez ograniczeń terytorialnych), unfake (MIT), Blender (GPL, render własny). **Odpadają:** FLUX.2 dev i klein 9B (niekomercyjne), Hunyuan3D 2.1 (wyłącza UE).
3. **Triale:** Pixellab (40 szybkich generacji, bez karty, tylko najprostsze narzędzia), Scenario (50 kredytów, bez karty, ale **wyniki tylko do użytku osobistego/ewaluacji, nie do gry**), RD (20 lub 50 kredytów według dwóch źródeł wtórnych; wymóg karty nieznany), Ludo.ai (brak opisu triala).
4. **Subskrypcja na Miesiąc produkcji:** w budżecie ~100 zł mieści się tylko plan średni Pixellab (Artisan ok. 24 USD **[wtórne]**) lub Scenario Starter (15 USD **[zweryfikowane]**). Pixellab Architect (50 USD) i Scenario Pro (45 USD) są ponad budżet. **Najważniejsza niewiadoma:** czy API/MCP Pixellab jest wliczone w subskrypcję, czy rozliczane osobno (strona API podaje ceny w USD za wywołanie, a limity generacji planów nie są potwierdzone w źródle pierwotnym). Rozstrzygnie to konto testowe (`GET /balance`).
5. **Steam [zweryfikowane + wtórne]:** każdy asset AI, który trafia do gry i jest oglądany przez graczy, trzeba ujawnić w Content Survey, niezależnie od narzędzia (lokalne też). Narzędzia „za kulisami” nie są przedmiotem ankiety. Żadne z badanych narzędzi nie blokuje wydania na Steamie na podstawie samej licencji; RD i Ludo.ai są nierozstrzygnięte (brak odczytanego regulaminu).
6. **Pułapki:** (a) Pixellab zakazuje trenowania modeli na wynikach, więc LoRA na wynikach Pixellab odpada **[zweryfikowane]**; (b) Scenario w planie self-serve może używać naszych treści do ulepszania swoich modeli **[zweryfikowane]**, więc nie wgrywać tam treści scenariusza „Drugiej”; (c) po zakończeniu subskrypcji Scenario daje 30 dni na eksport, więc wszystko pobrać przed końcem miesiąca.

## 1. Steam: ujawnianie AI wg aktualnych zasad

Źródło pierwotne: [Steamworks Content Survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey) **[zweryfikowane, strona bez daty]**.

- **Pre-generated AI** = „any kind of content that ships with your game and is consumed by players”, stworzona narzędziami AI w trakcie produkcji. Steam ocenia ją tak samo jak treści bez AI. Trzeba opisać użycie AI w ankiecie. (Cytat o oświadczeniu, że gra „will not include illegal or infringing content”, pochodzi z `09-prawa.md` i z mojego pobrania nie wyszedł dosłownie; traktować jako **[wtórne wobec 09]**.)
- **Live-generated AI** (podczas działania gry): dodatkowo opis zabezpieczeń (guardrails). Nie dotyczy nas, jeśli nie generujemy w grze.
- **Narzędzia deweloperskie:** strona mówi, że „efficiency gains” z narzędzi AI „nie są przedmiotem tej sekcji” **[zweryfikowane]**. Doniesienia prasowe (PC Gamer, Tweaktown, VGC, styczeń 2026) opisują to jako przeredagowanie z 16-17 stycznia 2026 i zwolnienie asystentów kodu i podobnych **[wtórne; oryginalnego posta Valve nie odczytałem]**.
- **Zgodność z 09-prawa:** dane z 09 (2026-10-27) są nadal zgodne ze stroną Steamworks. Dodatkowe doprecyzowanie z 2026: sedno ankiety to **treści konsumowane przez graczy**, nie sposób pracy.
- **Pixellab FAQ** potwierdza: generowane obrazy komercyjnie OK, jedyne zastrzeżenie to zakaz trenowania modeli; „AI assets are allowed in games, subject to Steam's AI disclosure rules” **[zweryfikowane: [FAQ](https://www.pixellab.ai/docs/faq)]**.
- **[wniosek] Co wymaga ujawnienia w game2:** każdy sprite, tło, portret, tekstura lub UI, który jest wynikiem generacji AI (Pixellab, RD, Scenario, ComfyUI/FLUX/Qwen/SDXL, także jeśli potem poprawiony), a nawet render Blendera zmodyfikowany przez AI. **Nie wymaga:** czysty Blender + algorytmiczna pikselizacja (unfake, kwantyzacja palety), kod pisany z asystentem, koncepty AI, które nie trafiają do gry (granica: nie „konsumowane”; ostrożnie, jeśli koncept jest widoczny w grze). Prowadzić `prompts.jsonl` (jak w 52) jako dokumentację na potrzeby ankiety.

## 2. Lokalnie (RTX 4060 Laptop 8 GB, 32 GB RAM, Comfy Desktop)

Zasada ComfyUI: oficjalne README mówi o „smart VRAM and RAM management, model offloading, quantized models” i deklaruje działanie dużych modeli „na 4 GB VRAM + 8 GB RAM” z asynchronicznym streamingiem wag **[zweryfikowane: [GitHub](https://github.com/Comfy-Org/ComfyUI), kod GPL-3.0; licencja aplikacji Desktop nieodczytana]**. Strona nie rozstrzyga praw do wyników; wyniki wynikają z licencji modelu.

| Model / narzędzie | Rozmiar / VRAM | Zmieści się w 8 GB? | Licencja i Steam/UE | Źródło |
|---|---|---|---|---|
| **FLUX.2 klein 4B** (distilled, fp8) | ~8,4 GB VRAM; base ~9,2 GB (wg Comfy); karta HF: „~13 GB” (bf16) | **Raczej tak z offloadem**, wolniej; do sprawdzenia na sprzęcie **[wniosek]** | **Apache 2.0**, komercyjnie; bez terytorium; 9B niekomercyjny. Wymóg: nie sugerować aprobaty marki | [HF klein-4B](https://huggingface.co/black-forest-labs/FLUX.2-klein-4B), [Comfy docs](https://docs.comfy.org/tutorials/flux/flux-2-klein) **[zweryfikowane]** |
| **FLUX.2 dev / klein 9B** | 32 mld / 9 mld parametrów | nie dotyczy | **niekomercyjne** → **odpada** (zgodnie z notą w mapie) | 52 **[zweryfikowane]** |
| **Qwen-Image-Edit-2511** (GGUF, 20B) | Q2_K 7,7 GB; Q3_K_M 9,9 GB; Q4_K_M 12,8 GB; Q8_0 22,4 GB; dodatkowo enkoder Qwen2.5-VL 7B | Bez offloadu nie; **z offloadem do 32 GB RAM Q3-Q4 prawdopodobnie tak, wolno** **[wniosek]**. Jakość niskich kwantów: nieznana | **Apache 2.0**; bez terytorium | [unsloth GGUF](https://huggingface.co/unsloth/Qwen-Image-Edit-2511-GGUF) **[zweryfikowane]**; praca na 8 GB: tylko wtórne relacje |
| **SDXL base + ControlNet depth + LoRA pixel-art-xl** | SDXL ~3B (fp16 ok. 6-7 GB), ControlNet 1B | **Tak** (karty zalecają `enable_model_cpu_offload` przy małej pamięci) **[wniosek]** | SDXL: CreativeML OpenRAIL++-M, licencja światowa, bezwarunkowa dla wyników („Licensor claims no rights in the Output”), restrykcje użycia (nieletni, nękanie itd.) nie blokują gry; karta modelu mówi „research purposes only”, co sprzeczne z LICENSE.md, trzymać się LICENSE.md. ControlNet depth: openrail++. pixel-art-xl: creativeml-openrail-m (treść licencji nieczytana) | [SDXL LICENSE](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/blob/main/LICENSE.md) **[zweryfikowane]**, [pixel-art-xl](https://huggingface.co/nerijs/pixel-art-xl), [controlnet-depth-sdxl](https://huggingface.co/diffusers/controlnet-depth-sdxl-1.0) **[zweryfikowane: etykiety licencji]**; komercyjność OpenRAIL-M **[wtórne/wniosek]** |
| **LoRA pixel art do klein 4B** (limbicnation, svntax-dev) | LoRA; wymaga bazy klein | tak, jak klein | deklaracja Apache 2.0 przez autora; **licencje zbiorów treningowych nieznane**; autor jednego z nich: distilled psuje jakość, zalecany base 9,2 GB | [limbicnation](https://huggingface.co/limbicnation/pixel-art-lora) **[wtórne]** |
| **ControlNet depth/normal dla klein/Qwen** | brak oficjalnego | nie dotyczy | nie znaleziono (jak w 52). Dla kontroli geometrii zostaje SDXL lub render Blendera jako obraz referencyjny | 52 / **[niezweryfikowane]** |
| **unfake** (pikselizacja, paleta, CLI w Rust) | lekkie | tak | **MIT**; algorytmiczne, **nie jest AI** → bez ujawnienia | [GitHub](https://github.com/jenissimo/unfake.js) **[zweryfikowane]** |
| **Blender** (ortho + rig) | CPU/GPU | tak | GPL; render własny; nie AI | 52 |
| **Hunyuan3D 2.1** | 10-29 GB | nie | **wyłącza UE** → **odpada** | 52 **[zweryfikowane]** |
| **TRELLIS.2** | ≥24 GB | nie | MIT, ale sprzęt odpada | 52 |
| **RD Aseprite extension** (lokalna) | wg dewelopera RTX 3060 12 GB „odpowiedni”, 8 GB nieznane; animacje i spritesheety tylko przez API (kredyty) | **niepewne** | zakup jednorazowy: Lite 20 USD, pełna 65+ USD; deweloper w komentarzu: „you own the images generated by it”; osobny dokument licencji nieodczytany; wymaga Aseprite | [itch.io](https://astropulse.itch.io/retrodiffusion) **[wtórne]** |

Wniosek lokalny **[wniosek]**: do bake-offu lokalnie wybrać dwa tory. Tor 1: Blender (render + normal) → unfake (paleta) → opcjonalnie FLUX.2 klein 4B lub Qwen GGUF jako „malarska” edycja renderu. Tor 2: SDXL + ControlNet depth + pixel-art-xl (jedyny tu, w którym geometria wymusza kąt). Trening własnego LoRA stylu lokalnie na 8 GB: nie zweryfikowałem wymagań ai-toolkit dla klein 4B **[niezweryfikowane]**; patrz Scenario jako zastępstwo.

## 3. Triale i regulaminy

| Narzędzie | Co za darmo | Karta? | Regulamin: wyniki w grze, po końcu subskrypcji, trenowanie, UE |
|---|---|---|---|
| **Pixellab** | „Try for free”; 40 szybkich generacji **[wtórne: cinevva]**; FAQ: „limited number of generations, only the easiest tools” **[zweryfikowane]** | **Nie** („No credit card required”) **[zweryfikowane]** | ToS §1.3 / §3.3: „You own the copyrights to your creations”, komercyjnie bez pytania; §3.3: trzymasz prawa do tego, co stworzysz. **Brak zapisu o utracie praw po anulowaniu** (§8.1 mówi tylko, że Pixellab może zakończyć dostęp w każdej chwili) **[zweryfikowane]** → **[wniosek]** prawa do już wygenerowanych wyników nie są związane z subskrypcją, ale warto zapytać support na piśmie. **Zakaz trenowania modeli** na wynikach bez zgody (§1.2, §3.3). Brak ograniczeń terytorialnych; prawo szwedzkie. Regulamin nie rozróżnia darmowych od płatnych. Zwrot: pełny, jeśli użyto <50 generacji, w ciągu 30 dni, minus 5%+0,5 USD [zweryfikowane: [ToS](https://www.pixellab.ai/termsofservice), [refund](https://www.pixellab.ai/refundpolicy)] |
| **Retro Diffusion (web/API)** | 20 kredytów (Gumroad) lub 50 (katalog) **[wtórne, sprzeczne]**; dokumentacja API nie wspomina o darmowych kredytach | nieznane | **Nie udało się odczytać żadnego regulaminu** (strona główna i GitBook puste lub WIP). API: płatność z przedpłaconego salda USD, kredytów nie kupuje się przez API **[zweryfikowane: [api-examples](https://github.com/Retro-Diffusion/api-examples)]**. Wyniki własnością użytkownika: tylko komentarz dewelopera przy rozszerzeniu **[wtórne]**. Status: **[niezweryfikowane]** do przeczytania ToS na koncie |
| **Scenario** | 50 kredytów dziennie wg strony cen (cinevva: 50 kredytów), jedno konto darmowe na osobę | **Nie** | **Wyniki z darmowego planu: tylko użytek osobisty i ewaluacja** (nie do gry) **[zweryfikowane: [pricing](https://www.scenario.com/pricing)]**. Płatne: ToS §4.3 „You own your Generated Assets”, komercyjnie. Koniec subskrypcji: licencja kończy się, **30 dni na eksport**, potem możliwe usunięcie; niewykorzystane jednostki nie przechodzą. **Self-serve: Scenario może używać Twoich treści i zagregowanych danych do ulepszania swoich modeli** (§4.6); zakaz trenowania modeli na wynikach: brak. Odnośnie UE: standardowe klauzule, dane w USA **[zweryfikowane: [ToS](https://www.scenario.com/terms-of-service)]** |
| **Ludo.ai** | strona „Free Trial” bez opisu | nieznane | Plany tylko roczne (ceny podane przy rozliczeniu rocznym). **Prawa do wyników, trenowanie, UE: nieodczytane** (pobrany PDF dotyczył innego produktu). **[niezweryfikowane]** |
| **Gemini/GPT Image** | brak darmowego API w tym researchu | – | poza zakresem (koncepty, nie assety do gry) |

## 4. Subskrypcja na Miesiąc produkcji (~100 zł, maks. 2 miesiące)

Przeliczenie: ~100 zł ≈ 25-28 USD **[wniosek; kurs nie sprawdzany, VAT i opłaty kartą mogą podnieść cenę]**. Płatność za generację (RD API pay-per-use) odpada wg mapy; zostają plany miesięczne.

| Plan | Cena | Limity generacji/mies. | API/MCP w planie | Prawa po końcu subskrypcji, komercyjnie, trenowanie | Mieści się w budżecie |
|---|---|---|---|---|---|
| **Pixellab Pixel Apprentice** (Tier 1) | 12 USD **[wtórne: G2, cinevva]** | do ~2000 (cinevva) lub ~3000 (Knowara) generacji **[wtórne, sprzeczne]** | API token na koncie; endpoint PixMiniMax (animacja, beta) wymaga „Tier 1 lub wyżej” **[zweryfikowane]**; MCP: `pixelart_workbench` „free for subscribers” **[zweryfikowane]** | Komercyjnie na wszystkich planach **[zweryfikowane: llms.txt]**; ToS jw.; zakaz trenowania | tak |
| **Pixellab Pixel Artisan** (Tier 2) | 24 USD **[wtórne]** | nieznane; kolejka priorytetowa, obrazy do 400×400, wczesny dostęp do narzędzi eksperymentalnych **[wtórne]** | MCP: tworzenie pokoi i wycinanie mebli „Pixel Artisan i wyżej” **[zweryfikowane]** | jw. | **tak (kandydat)** |
| **Pixellab Pixel Architect** (Tier 3) | 50 USD **[wtórne]** | 10 000 generacji, 20 równoległych zadań **[wtórne]** | jw. | jw. | **nie** (~190 zł) |
| **Scenario Starter** | 15 USD | 1500 kredytów (nie przechodzą) | API-first, ale **plan-po-planie niepodane** | płatne = licencja komercyjna; po końcu 30 dni eksportu; Scenario może trenować na treściach | tak, ale 1500 kredytów to mało; trening modeli dopiero w Pro (wg 52) |
| **Scenario Pro** | 45 USD | 5000 kredytów | niepodane | jw. | **nie** (~170 zł) |
| **Ludo.ai Pro** | 35 USD/mies. przy rozliczeniu rocznym (420 USD z góry) | 12 000 kredytów/rok; „unlimited” tylko w aplikacji web | API/MCP/CLI tak, ale **zawsze zużywa kredyty** **[zweryfikowane: [pricing](https://ludo.ai/pricing)]** | prawa nieodczytane | **nie** (zobowiązanie roczne łamie zasadę „maks. 2 miesiące”) |
| **RD API** | przedpłacone saldo USD, 0,03-0,25 USD/obraz (52 + api-examples) | brak limitów, tylko saldo | pełne API + `check_cost` | prawa nieodczytane | **odpada z zasady** („płatność za generację”), chyba że człowiek zmieni zasadę; w teście kosztuje kilka USD |

**Ile postaci z animacjami i ile obiektów na miesiąc** nie da się podać ze źródeł pierwotnych: żadna strona nie podaje liczby generacji na postać (v3 z 8 rotacjami, animacje to osobne wywołania, wiele endpointów liczy się jako wiele „generacji” wg refund policy: „some tools use more than one generation per use”). **[wniosek]** Policzyć na koncie testowym: koszt (w generacjach i salda) jednej postaci 8 kierunków + 1 chód + 1 wariant stroju, potem podzielić limit planu przez ten koszt (minus ~2-3 próby na asset, cel z `grafika.md`). To jest pierwsze, co zmierzyć przed zakupem.

**Wniosek o planie [wniosek]:** domyślnym kandydatem na Miesiąc produkcji jest **Pixellab Artisan (~24 USD)**, pod warunkiem że konto testowe potwierdzi (1) tier i limity dokładnie, (2) że API/MCP używa subskrypcyjnych generacji, a nie osobnego salda, (3) że wyniki są prawnie nasze po anulowaniu (e-mail do support@pixellab.ai, pisemnie). Jeśli (2) się nie potwierdzi, dla masowej generacji przez Claude'a Pixellab traci przewagę nad ręcznym użyciem w Aseprite/Pixelorama.

## 5. Tabela: za darmo / na trialu / w Miesiącu produkcji

| Narzędzie | Za darmo (lokalnie) | Na trialu | W Miesiącu produkcji (plan) | Steam: wyniki sprzedawalne? | Ujawnić AI? | UE |
|---|---|---|---|---|---|---|
| Blender + unfake | tak | – | – | tak | **nie** (jeśli bez AI) | OK |
| FLUX.2 klein 4B (+LoRA) | tak, z offloadem | – | – | tak (Apache 2.0) | tak | OK |
| Qwen-Image-Edit-2511 GGUF | tak, wolno (Q3-Q4) | – | – | tak (Apache 2.0) | tak | OK |
| SDXL + ControlNet depth + pixel-art-xl | tak | – | – | tak (OpenRAIL; sprawdzić tekst pixel-art-xl) | tak | OK |
| FLUX.2 dev / klein 9B | – | – | – | **nie** (niekomercyjne) | – | – |
| Hunyuan3D 2.1 | – | – | – | **nie** (UE) | – | **wyłączone** |
| Pixellab | – | 40 gen., bez karty | Artisan ~24 USD (kandydat) | tak (ToS 1.3, 3.3) | tak | brak zapisu o wyłączeniu |
| Retro Diffusion | rozszerzenie lokalne 20-65 USD (jednorazowo), 8 GB niepewne | 20-50 kredytów | API pay-per-use (poza zasadą) | niezweryfikowane (komentarz: własność użytkownika) | tak | niezweryfikowane |
| Scenario | – | 50 kr./dzień, **tylko ewaluacja** | Starter 15 USD (mało) / Pro 45 USD (za drogo) | tak (płatne) | tak | OK; uwaga: może trenować na naszych treściach |
| Ludo.ai | – | niejasny | Pro 35 USD/mies. tylko rocznie | niezweryfikowane | tak | niezweryfikowane |

## 6. Rekomendowana kolejność testów

1. **Lokalnie, 0 zł:** Blender ortho → unfake (paleta); ComfyUI: SDXL + depth ControlNet + pixel-art-xl oraz FLUX.2 klein 4B (distilled fp8, sprawdzić czas i VRAM na 4060 Laptop); Qwen GGUF Q3/Q4 jako edycja renderu (sprawdzić czas na 8 GB + 32 GB RAM). Cel: kąt z pomiaru (Test A z 52 §9) i czy lokalnie da się dostać akceptowalny styl.
2. **Pixellab, nowe konto testowe, bez karty (zgoda człowieka):** 40 generacji. Zmierzyć: które narzędzia dostępne w triale; czy `GET /balance` pokazuje generacje, czy USD; koszt jednej postaci 8-kierunkowej i animacji. Zrzuty cen planów z konta zapisać do tej notatki.
3. **Retro Diffusion:** najpierw przeczytać regulamin na koncie; potem darmowe kredyty + `check_cost` (darmowy) do wyceny; testy tylko jeśli ToS pozwala na grę komercyjną.
4. **Scenario free:** tylko do ewaluacji jakości stylu LoRA; **nie** używać w grze i **nie** wgrywać treści scenariusza. Pomijalne, jeśli lokalne wyniki wystarczą.
5. **Ludo.ai:** tylko jeśli Pixellab i RD zawiodą w postaciach 8-kierunkowych; plan roczny wyklucza.
6. **Wykupienie planu** dopiero po gotowych Przepisach (zasada mapy) i po punktach (1)-(3) z §4.

## 7. Do decyzji człowieka

- Czy założyć konta testowe: Pixellab (bez karty), RD (karta?), Scenario (opcjonalnie).
- Czy kupić Aseprite (cena niezweryfikowana; cinevva podaje 19,99 USD **[wtórne]**) i/lub rozszerzenie RD (20-65 USD).
- Czy wysłać pisemne pytanie do Pixellab (prawa po anulowaniu, API w planie) i do RD (ToS, własność wyników, EU).

## Luki

- Ceny i limity Pixellab tylko ze źródeł wtórnych; plan Artisan bez podanej liczby generacji.
- Regulamin RD (web/API) i Ludo.ai nieodczytany; darmowe kredyty RD sprzeczne (20 vs 50).
- Licencja Comfy Desktop (aplikacja) i pełny tekst OpenRAIL-M dla pixel-art-xl nieodczytane.
- Praca Qwen GGUF na 8 GB VRAM: tylko relacje wtórne; klein 4B 8,4 GB wg dokumentacji Comfy to wartość dla 5090, nie pomiar na 4060.
- Oryginalny komunikat Valve ze stycznia 2026 nieodczytany; Steamworks nie pokazuje daty.

## Źródła

- Steam: [Content Survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey); [wtórne] [PC Gamer](https://www.pcgamer.com/software/ai/steam-updates-ai-disclosure-form-to-specify-that-its-focused-on-ai-generated-content-that-is-consumed-by-players-not-efficiency-tools-used-behind-the-scenes/), [Tweaktown](https://www.tweaktown.com/news/109743/valve-changes-ai-disclosure-guidelines-ai-powered-tools-are-now-exempt/index.html)
- Pixellab: [ToS](https://www.pixellab.ai/termsofservice), [refund](https://www.pixellab.ai/refundpolicy), [FAQ](https://www.pixellab.ai/docs/faq), [llms.txt](https://www.pixellab.ai/llms.txt), [API](https://www.pixellab.ai/pixellab-api), [MCP](https://www.pixellab.ai/mcp); [wtórne] [cinevva](https://app.cinevva.com/guides/ai-pixel-art-generators), [G2](https://ai.g2.com/marketplace/tools/pixellab)
- Retro Diffusion: [api-examples](https://github.com/Retro-Diffusion/api-examples), [itch.io](https://astropulse.itch.io/retrodiffusion), [GitBook](https://astropulse.gitbook.io/retro-diffusion)
- [Scenario pricing](https://www.scenario.com/pricing), [Scenario ToS](https://www.scenario.com/terms-of-service), [Ludo pricing](https://ludo.ai/pricing)
- Modele: [FLUX.2 klein 4B](https://huggingface.co/black-forest-labs/FLUX.2-klein-4B), [Comfy klein](https://docs.comfy.org/tutorials/flux/flux-2-klein), [Qwen-Image-Edit-2511 GGUF](https://huggingface.co/unsloth/Qwen-Image-Edit-2511-GGUF), [SDXL LICENSE](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/blob/main/LICENSE.md), [pixel-art-xl](https://huggingface.co/nerijs/pixel-art-xl), [controlnet-depth-sdxl](https://huggingface.co/diffusers/controlnet-depth-sdxl-1.0), [limbicnation LoRA](https://huggingface.co/limbicnation/pixel-art-lora), [ComfyUI](https://github.com/Comfy-Org/ComfyUI), [unfake.js](https://github.com/jenissimo/unfake.js)
- Repo: `docs/research/52-narzedzia-pixel-art.md`, `C:/Users/bartl/Desktop/repo/game1/docs/research/09-prawa.md`
