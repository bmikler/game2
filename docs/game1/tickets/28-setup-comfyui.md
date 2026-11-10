---
id: 28
title: Setup ComfyUI do ideacji sterowanej przez Claude
labels: [wayfinder:task]
status: closed
assignee: bmikler
blocked_by: []
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/28-setup-comfyui.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Postawić lokalne ComfyUI na laptopie człowieka (RTX 4060 Laptop 8 GB VRAM, 32 GB RAM, Windows 11, bez systemowego Pythona) tak, żeby Claude Code generował concept arty skryptem, bez klikania w GUI. Gotowe, gdy Claude jednym poleceniem wygeneruje obraz z promptu i obrazu referencyjnego, a plik i prompt trafią do `art/concept/`.

Kroki (szczegóły i źródła: docs/research/24d-concept-art.md, sekcja 2):
1. **Człowiek:** zainstalować Comfy Desktop (instalator z https://www.comfy.org/download, instalacja lokalna, GPU NVIDIA). Zmiana z 2026-10-28: zamiast portable, człowiek zna instalator. Sterownik NVIDIA 621.01, aktualny.
2. **Człowiek:** uruchomić aplikację; Claude znajduje port API (Desktop domyślnie 8000, portable 8188).
3. **Claude + człowiek:** model startowy: człowiek akceptuje ok. 1 min/obraz, więc zamiast SDXL model Apache 2.0. Główny kandydat Qwen-Image-Edit (najnowsza wersja, GGUF Q3/Q4 + Lightning LoRA 4 kroki, offload do 32 GB RAM), bo natywnie przyjmuje kilka obrazów referencyjnych; Chroma1-HD (Apache 2.0, GGUF Q4 ok. 5,6 GB) tylko tekst → obraz, referencje wymagałyby osobnego adaptera. Zapas: SDXL + IPAdapter. Przed pobraniem sprawdzić licencję i wersję pliku.
4. **Claude:** węzły: ComfyUI-GGUF (city96) przez ComfyUI-Manager; IPAdapter Plus tylko przy zapasie SDXL.
5. **Claude:** skrypt Node `tools/concept/comfy.mjs` w repo: wczytuje workflow w formacie API (`tools/concept/workflows/*.json`), podmienia prompt, seed i obrazy referencyjne (`POST /upload/image`), wysyła `POST /prompt`, czeka na `/history/{id}`, pobiera wynik z `/view` do `art/concept/...` i dopisuje wpis do `art/concept/prompts.jsonl`. Bez systemowego Pythona (comfy-mcp go wymaga).
6. **Claude:** struktura `art/concept/` (`_refs`, `_style`, `locations`, `characters`, `picks.md`, `prompts.jsonl`), surowe PNG w `.gitignore`, commitujemy tylko wybrane (`picks.md`) i `_style` (decyzja człowieka 2026-10-28, bez LFS).
7. **Test:** 4 warianty posterunku nocą i Badacz (komendant posterunku; decyzja człowieka 2026-10-28: najpierw postać gracza, nie Krogg; bez referencji człowieka na start) w 4 widokach plus zbliżenie twarzy z tej samej referencji (sprawdzić, czy postać jest rozpoznawalna między ujęciami, bo portret w rozmowie ma pasować do sprite'a); zmierzyć czas na obraz.

Wynik zapisać jako fakty: ścieżka instalacji, model i jego licencja, czas na obraz, komenda skryptu.

## Resolution

Zrobione 2026-10-28. Claude generuje concept art jednym poleceniem, z promptem i opcjonalnymi referencjami; plik trafia do `art/concept/...`, a wpis do `art/concept/prompts.jsonl`.

- **Instalacja:** Comfy Desktop (ComfyUI 0.43.1, własne środowisko Python, nic globalnie) w `%LOCALAPPDATA%\Comfy-Desktop`; modele w `%LOCALAPPDATA%\Comfy-Desktop\ComfyUI-Shared\models`. API: http://127.0.0.1:8188 (nie 8000), działa tylko przy otwartej aplikacji. ComfyUI-Manager wbudowany (`--enable-manager`). Bez węzłów dodatkowych: GGUF i IPAdapter niepotrzebne.
- **Model:** FLUX.2 [klein] 4B distilled fp8 (Apache 2.0, 4,1 GB) + enkoder `qwen_3_4b_fp8_mixed` (5,6 GB) + `flux2-vae` (0,3 GB); natywnie przyjmuje obrazy referencyjne (`ReferenceLatent`), 4 kroki. Odrzucone: Qwen-Image 2.1 (Qwen Research License, niekomercyjna), Qwen-Image-Edit-2511 (Apache 2.0, ale fp8 to 20,5 GB, na 8 GB VRAM tylko GGUF; zapas, jeśli spójność postaci okaże się za słaba), Chroma (bez referencji). Licencję VAE FLUX.2 warto potwierdzić przed wydaniem.
- **Czas na obraz:** 5 s (1344×768, bez referencji, model w pamięci), 8–11 s z referencją; pierwszy obraz z wczytaniem modelu 9 s. Dużo szybciej niż szacowana minuta, więc iteracja może iść seriami.
- **Komenda:** `node tools/concept/comfy.mjs --out art/concept/characters/badacz --name badacz-sheet --ref <png> --count 4 --seed 1000 --w 1344 --h 768 "prompt"`. Workflow jako moduł JS budujący graf (`tools/concept/workflows/flux2-klein.mjs`), bo liczba referencji jest zmienna. Zmienna `COMFY_URL` nadpisuje adres.
- **Repo:** `.gitignore` pomija surowe PNG z `art/concept/` (poza `_style`); wybrane dodajemy `git add -f` i wpisujemy do `picks.md`. `.git/info/exclude` zawężony do `tools/godot/`.
- **Test:** arkusz Badacza w 4 widokach wyszedł spójny i w klimacie (zmęczony, zwyczajny, znoszona kurtka). Portret z arkuszem jako referencją zachowuje kurtkę, sweter i siwiznę, ale twarz i fryzura dryfują (szczuplejsza twarz, dłuższe włosy): spójność umiarkowana, do pracy w Kierunku graficznym (np. kilka referencji, opis twarzy w `STYLE.md`, ewentualnie Qwen-Image-Edit-2511). Posterunek nocą w kamerze 3/4 z góry: 4 warianty, czytelne i nastrojowe (świetlówka, CRT, śnieg za oknem). Wyniki: `art/concept/characters/badacz/`, `art/concept/locations/posterunek/`.
