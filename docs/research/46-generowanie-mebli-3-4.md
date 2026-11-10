> Kopia z game1 (`repo/game1/docs/research/46-generowanie-mebli-3-4.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Generowanie mebli w spójnym rzucie 3/4

Ticket: `docs/wayfinder/tickets/46-generowanie-mebli-3-4.md`. Data researchu: **2026-10-29**.

Oznaczenia przy twierdzeniach:
- **[zweryfikowane]**: sprawdzone w źródle pierwotnym (link) albo na tym komputerze (`/object_info` ComfyUI, `nvidia-smi`).
- **[z pamięci]**: wiedza ogólna, niesprawdzona w tym researchu.
- **[wniosek]**: moje rozumowanie albo rachunek.

Stan maszyny sprawdzony 2026-10-29 **[zweryfikowane]**:
- GPU: RTX 4060 Laptop, 8188 MiB.
- ComfyUI 0.43.1 (Python 3.13, PyTorch 2.12 cu130). Modele: tylko `flux-2-klein-4b-fp8` i `flux3-image-klein-int8-convrot`. Folder ControlNet, LoRA i style jest pusty.
- Rdzeń ComfyUI ma już węzły: `ControlNetApplyAdvanced`, `SetUnionControlNetType`, `ModelPatchLoader`, `QwenImageDiffsynthControlnet`, `ZImageFunControlnet`, `Trellis2*` (TRELLIS.2), `Hunyuan3Dv2*`, `TextEncodeQwenImageEditPlus`, `LoadDA3Model` (Depth Anything 3), `LoadMoGeModel` oraz natywny trening LoRA `TrainLoraNode` (z opcjami `offloading`, `quantized_backward`, `gradient_checkpointing`).
- **Blender nie jest zainstalowany** (brak w Program Files, AppData i Steam).

## Streszczenie

1. **Źródło problemu:** szara bryła podana jako *referencja* (in-context) we FLUX.2 klein to tylko wskazówka, nie ograniczenie. Model może ją obrócić, dodać perspektywę albo wymyślić podstawę **[wniosek]**. Kształt trzeba **zablokować** jednym z trzech sposobów: (a) geometria pochodzi z renderu 3D i AI jej nie rysuje, (b) render jest latentem startowym (img2img, niski denoise), (c) render steruje generacją przez ControlNet.
2. **Rzut gry można uzyskać w Blenderze dokładnie i bez sztuczek.** Wystarczy kamera ortogonalna pochylona o 45° w dół, a potem rozciągnięcie obrazu w pionie o √2. Blat i front mają wtedy skalę 1:1, a boki są niewidoczne (rachunek w §2) **[wniosek]**.
3. **Rekomendacja, droga A:** bryły modeluje skrypt Pythona dla Blendera, który pisze Claude (meble posterunku to w większości skrzynie). Render daje albedo, maskę i normal mapę w rzucie gry. Opcjonalnie FLUX.2 klein robi img2img z niskim denoise, żeby dodać malarską fakturę. Na końcu obraz przechodzi przez obecną pikselizację. Kształt i wymiary są dokładne co do piksela, a normal mapa jest prawdziwa, nie heurystyczna.
4. **Droga B, ControlNet** (Z-Image Turbo + Fun ControlNet Union albo SDXL + ControlNet Union ProMax) trzyma kształt lepiej niż referencja, ale nie dokładnie. Wymaga też nowej rodziny modeli i innego stylu. Zostaje jako zapas, gdyby img2img z drogi A dawało za mało stylu.
5. **Droga C, image-to-3D** (TRELLIS.2 lub Pixal3D, natywne w ComfyUI, licencja MIT) przydaje się tylko do obiektów nieskrzynkowych: krzesło, roślina, ekspres, maszyna do pisania. Ich mesh trafia do tego samego zestawu renderującego co w drodze A. Na 8 GB działa to niepewnie. Hunyuan3D odpada w UE z powodu licencji (research 24b).
6. **LoRA stylu na 8 GB jest dziś przedwczesna.** BFL podaje minimum 12 GB VRAM dla treningu klein 4B, a my mamy za mało własnych sprite'ów na zbiór danych. Wracamy do niej po 15–30 zaakceptowanych assetach.

## 1. Co zawodzi w obecnym pipeline'ie i dlaczego

- FLUX.2 klein obsługuje edycję z jedną i wieloma referencjami **[zweryfikowane: [docs.comfy.org/tutorials/flux/flux-2-klein](https://docs.comfy.org/tutorials/flux/flux-2-klein)]**. Referencja wchodzi jednak jako kontekst, a nie jako warunek przestrzenny. W STYLE.md jest zapisane, że edycja z referencją „trzyma kadr 1:1”, ale „kamery nie zmieni”. Przy *nowej* generacji, gdzie referencją jest bryła, kadr nie jest więc zablokowany **[wniosek z naszych prób i STYLE.md]**.
- Dwie referencje naraz (bryła i koncept pokoju) mieszają widoki, co STYLE.md już odnotowuje. Kamera konceptu pokoju (lekko podwyższona, perspektywa) „przecieka” do mebla **[wniosek]**.
- Wymyślone podstawy pod drobiazgami na ladzie biorą się stąd, że model widzi obiekt bez kontekstu blatu i „stawia” go na czymś. Pomaga to, że sylwetkę daje maska z renderu, a nie wycinanie zielonego tła **[wniosek]**.

## 2. Rzut gry w Blenderze (dokładny)

Rzut ma trzy wymagania: blat (szer. × głęb.) leży bezpośrednio nad frontem (szer. × wys.), skala jest 1:1, a boków nie widać.

**Sposób 1, zalecany: kamera ortogonalna pochylona o 45° i rozciągnięcie w pionie o √2** **[wniosek: rachunek poniżej]**
- Kamera patrzy w kierunku d = (0, cos45°, −sin45°), czyli w głąb i w dół, bez obrotu wokół osi pionowej. Pionowa oś obrazu to u = (0, sin45°, cos45°).
- Punkt (x, y, z) trafia na ekran w (x, (y + z)/√2). Front (y = 0, z od 0 do h) zajmuje więc h/√2, a blat (z = h, y od 0 do d) zajmuje d/√2 i leży nad frontem. Proporcja blatu do frontu wynosi 1:1.
- Ściany boczne mają normalne ±X, czyli prostopadłe do kierunku patrzenia. Widać je tylko jako krawędź, więc boków nie ma.
- Wystarczy przeskalować obraz w pionie o √2, żeby dostać 40 px/m w obu osiach. Robimy to i tak przy zmniejszaniu (`unfake downscale` do docelowego W × H), bo render jest w ×8, więc nie trzeba osobnego kroku.
- Przykład lady 4,8 × 0,6 × 1,05 m. Cel: 192 × (0,6 + 1,05)·40 = **192 × 66 px**. Render w ×8: szerokość 1536 px, `ortho_scale` = 4,8 m (pokrywa dłuższy bok kadru **[z pamięci]**), wysokość 1536 · (1,65/√2)/4,8 ≈ **373 px**. Potem zmniejszamy do 192 × 66.
- Szafka na akta 0,55 × 0,6 × 1,35 m daje 22 × (0,6 + 1,35)·40 = **22 × 78 px**.

**Sposób 2: ścięcie geometrii.** Kamera jest pozioma, a mesh dostaje macierz ścięcia z' = z + y (np. `obj.matrix_world` z elementem shear). Wynik jest ten sam, ale ścięcie psuje normalne i oświetlenie, więc nie polecam **[wniosek]**.

**Normal mapa z renderu:**
- Nasz `normals.gd` koduje wierzch jako `UP = (0, −0.45, 0.89)`, a front jako `SOUTH = (0, 0.8, 0.6)` w przestrzeni widoku z Y w dół na ekranie **[zweryfikowane: `game1-proto/prototype/lighting/pipeline/normals.gd`]**.
- Normalne w przestrzeni kamery 45° (z Y w dół) wynoszą dla wierzchu (0, −0.71, 0.71), a dla frontu (0, 0.71, 0.71). Jest to ta sama konwencja z nieco innym nachyleniem. Mapowanie normalnych świata na wektory z `normals.gd` (wierzch→UP, front→SOUTH, boki X bez zmian) to jeden węzeł matematyczny w materiale lub compositorze **[wniosek]**.
- Pass Normal w Blenderze jest w przestrzeni świata, więc potrzebny jest osobny render z materiałem, który przelicza normalne **[zweryfikowane w 24b, [manual](https://docs.blender.org/manual/en/latest/render/layers/passes.html)]**.
- Zysk: szuflady, uchwyty i fazy dostają prawdziwe normalne zamiast „górne N wierszy = UP”.

**Render albedo:** Workbench albo EEVEE z materiałem Emission (płaski kolor, bez cieni), przezroczyste tło (`film_transparent`) i maska alfa z tego samego renderu **[z pamięci]**. Uruchamiamy headless: `blender --background --python rig.py -- spec.json` **[zweryfikowane w 24b]**.

## 3. Drogi

### Droga A (rekomendowana): Blender proceduralnie → opcjonalnie img2img FLUX.2 klein → pikselizacja

**Przebieg**
1. Claude pisze spec JSON dla obiektu: wymiary w m oraz części (cokół, korpus, szuflady, drzwiczki, uchwyty, blat z nawisem, kolor lub materiał z palety).
2. Wspólny skrypt `prop_rig.py` buduje bryły z prostopadłościanów z fazami (bevel), ustawia kamerę 45° i renderuje trzy obrazy: albedo, normal (w konwencji gry) i maskę.
3. Wariant A0, bez AI: albedo z prostymi teksturami proceduralnymi (słoje brzozy, laminat, metal), potem `unfake downscale/quantize`, kontur 1 px i paleta.
4. Wariant A1, z AI: render albedo jest latentem startowym img2img dla FLUX.2 klein 4B przy denoise 0,25–0,5. Arkusz Badacza jest referencją stylu, a prompt opisuje materiał. Wynik przycinamy **maską z Blendera** i pikselizujemy jak dotąd.
5. Normal mapa pochodzi z renderu: zmniejszamy ją tym samym `downscale`, ale bez kwantyzacji.

**Koszt**
| | |
|---|---|
| Pieniądze | 0 zł. Blender jest darmowy (instalacja ok. 0,5–1 GB, `winget install BlenderFoundation.Blender` **[z pamięci]**, decyzja człowieka). |
| VRAM | Blender: znikomy. FLUX.2 klein 4B distilled: ok. 8,4 GB według ComfyUI (pomiar na 5090) **[zweryfikowane: [docs.comfy.org](https://docs.comfy.org/tutorials/flux/flux-2-klein)]**. Na naszym 4060 już działa (offload do RAM) **[zweryfikowane: obecny pipeline]**. |
| Czas na asset | Spec i skrypt: 5–15 min pracy agenta przy nowym typie mebla, kolejne warianty to minuty. Render: sekundy. img2img: kilkanaście–kilkadziesiąt s na obraz **[wniosek/szacunek]**. |
| Trudność dla agenta | Niska. Wszystko jest CLI: `blender --background`, HTTP `/prompt` w ComfyUI i skrypty Godot. Wynik jest deterministyczny i wersjonowany w git. |

**Ryzyka**
- **„Wygląd 3D/CG”** w wariancie A0: zbyt czyste krawędzie i jednolite płaszczyzny. Łagodzą to pikselizacja 40 px/m, kwantyzacja, kontur 1 px i ewentualnie A1. Czy to wystarczy obok postaci z Pixellab, rozstrzyga tylko arkusz porównawczy (pamięć projektu: decyzje o wyglądzie przez porównanie) **[wniosek]**.
- **img2img przy zbyt wysokim denoise** znowu przesuwa krawędzie. Maska z Blendera obcina tylko to, co wyszło *poza* bryłę, a nie wnętrze. Trzeba wyznaczyć próg denoise na siatce wartości **[wniosek]**.
- **Obiekty nieskrzynkowe** (krzesło obrotowe, roślina, monitor CRT) są trudniejsze do zamodelowania skryptem. Monitor i telefon to nadal kilka brył, ale krzesło i roślina idą drogą C **[wniosek]**.

### Droga B: ControlNet z renderu bryły (depth + canny/lineart)

**Opcje mieszczące się w 8 GB**
- **Z-Image Turbo (6B) + Z-Image-Turbo-Fun-Controlnet-Union**: Canny, HED, Depth, Pose, MLSD. Plik idzie do `model_patches/` i ładuje się przez `ModelPatchLoader` **[zweryfikowane: [docs.comfy.org/tutorials/image/z-image/z-image-turbo](https://docs.comfy.org/tutorials/image/z-image/z-image-turbo)]**. Węzeł `ZImageFunControlnet` jest już w naszym ComfyUI **[zweryfikowane: object_info]**. Model mieści się w 16 GB VRAM. Na 8 GB potrzebna jest wersja fp8 lub GGUF albo offload, czego nie sprawdziłem. Poradniki zalecają siłę 0,6–0,8 **[źródło wtórne: [comfyui-wiki](https://comfyui-wiki.com/en/news/2025-12-02-z-image-turbo-controlnet-union)]**.
- **SDXL + xinsir ControlNet Union ProMax** ([HF](https://huggingface.co/xinsir/controlnet-union-sdxl-1.0)) **[zweryfikowane istnienie]**. Obsługa depth, canny i lineart **[z pamięci]**. SDXL z ControlNetem mieści się w 8 GB i ma dużo pixel-art LoRA na Civitai **[z pamięci]**.
- **FLUX.2 klein:** nie znalazłem oficjalnego ControlNetu. Jest społecznościowa LoRA „refcontrol” (referencja + mapa głębi, Apache-2.0), ale tylko dla **klein 9B base** ([HF](https://huggingface.co/thedeoxen/refcontrol-FLUX.2-klein-9B-reference-depth-lora)) **[zweryfikowane]**. Model 9B na 8 GB oznacza mocny offload i wolne generowanie **[wniosek]**.
- **FLUX.1 Depth/Canny (BFL Tools)** to pełne modele 12B, nie adaptery **[źródło wtórne: [RunComfy](https://runcomfy.com/comfyui-workflows/flux-tools-flux-depth-and-flux-canny-controlnet-model)]**. Na 8 GB działają tylko jako GGUF z offloadem **[z pamięci]**.

**Koszt:** 0 zł, ok. 10–15 GB pobierania, kilka–kilkanaście s na obraz. Trudność średnia: nowy workflow i strojenie siły.

**Ryzyka:** ControlNet trzyma *układ*, ale nie piksele. Krawędzie przesuwają się o kilka %, model potrafi dorysować bok przy depth i wymaga strojenia. Inny model bazowy oznacza inny styl niż koncepty z FLUX. Nadal potrzebujemy renderu bryły z Blendera, więc droga B jest **nadbudową** drogi A, a nie alternatywą **[wniosek]**.

### Droga C: image-to-3D dla obiektów organicznych → ten sam zestaw renderujący

**Opcje**
- **TRELLIS.2 (4B) i Pixal3D, natywnie w ComfyUI.** Kod i wagi TRELLIS.2 są na licencji MIT, a natywna wersja usuwa niekomercyjne zależności nvdiffrast. Wynik to mesh z mapami PBR (base color, roughness, metallic) oraz normal i AO. Wymaga ComfyUI ≥ 0.34. Autorzy sami przyznają, że zamknięte generatory (Hunyuan, Tripo, Rodin) dają lepsze wyniki, a tekstury „nie są idealne” **[zweryfikowane: [blog.comfy.org](https://blog.comfy.org/p/trellis2-and-pixal3d-are-now-native)]**.
- Pixal3D ma wagi bf16 i **int8** oraz tryb multi-view, licencja MIT **[zweryfikowane: [HF Comfy-Org/Pixal3D](https://huggingface.co/Comfy-Org/Pixal3D)]**.
- VRAM natywnych węzłów nie jest udokumentowany. Wersja społecznościowa na 3060 8 GB zużywa ok. 6,5–7,8 GB w trybie low-VRAM **[źródło wtórne, niesprawdzone: [przewodnik](https://book.st-hakky.com/en/data-science/trellis2-native-vs-legacy-vram-guide)]**.
- **Stable Fast 3D / SPAR3D** (Stability Community License, darmowa poniżej 1 mln USD przychodu). SF3D potrzebuje ok. 7 GB, a SPAR3D ok. 10,5 GB lub ok. 7 GB w trybie low-VRAM **[zweryfikowane licencja: [HF SPAR3D](https://huggingface.co/stabilityai/stable-point-aware-3d); VRAM: źródła wtórne]**. Oba wymagają osobnej instalacji poza ComfyUI.
- **Hunyuan3D 2.x/2.1**: licencja wag nie obowiązuje w UE, więc odpada **[zweryfikowane w 24b]**. Węzły `Hunyuan3Dv2*` w ComfyUI nie zmieniają licencji wag.

**Przebieg:** koncept obiektu z FLUX (jedno ujęcie, tło #00FF00) → TRELLIS.2/Pixal3D → `.glb` → import do `prop_rig.py` → ten sam render, normal mapa i pikselizacja co w drodze A.

**Ryzyka:** zniekształcony mesh, „rozmyte” tekstury i skala, którą trzeba dopasować skryptem (bbox → wymiary w m). Przy 40 px/m błędy detalu w dużej mierze znikają, liczy się sylwetka **[wniosek]**. Społeczność potwierdza, że meshe z AI zawsze wymagają poprawek. W jednym zgłoszeniu z partii ok. 45 modeli 35 nadawało się do użytku **[źródło wtórne: [Reddit snapshot](https://reddit.sentinel-team.org/posts/1sqo70y/snapshots/2026-04-25T00%3A45%3A58.465245Z)]**.

### Uzupełnienie: Retro Diffusion API (płatne, tanie)

- RD Pro kosztuje **0,18 USD/obraz** (styl `edit` i `pixelate` z obrazem wejściowym, do 9 `reference_images`). RD Plus kosztuje 0,06 USD, a RD Fast 0,03 USD. Jest `input_image` ze `strength` 0–1, `input_palette` i `check_cost` (sama wycena) **[zweryfikowane: [Retro-Diffusion/api-examples](https://github.com/Retro-Diffusion/api-examples)]**.
- Możliwe użycie: render z drogi A jako `input_image`, nasze sprite'y jako `reference_images`, paleta projektu jako `input_palette`. Szacunek: 60 obiektów × 4 próby × 0,18 USD ≈ **43 USD** **[wniosek]**. Ma sens tylko wtedy, gdy własna pikselizacja przegra w porównaniu. Wymaga konta i klucza API, a decyzję podejmuje człowiek.
- Pixellab: nie planujemy go do masowej produkcji (kredyty, mieszane rzuty; stan z ticketu).

## 4. Spójność stylu

- **Modele edycji (FLUX.2 klein edit, Qwen-Image-Edit 2511, FLUX Kontext dev).** Do zadania „przerysuj w tym stylu, zachowaj geometrię” najlepsze jest img2img lub edycja z **renderem jako obrazem wejściowym**, nie jako referencją. FLUX.2 klein już jest zainstalowany. Qwen-Image-Edit 2511 ma 20B parametrów. Na 8 GB działa tylko jako GGUF Q4/Q5 z offloadem do 32 GB RAM, do tego LoRA Lightning na 4 kroki **[źródło wtórne: [kombitz](https://www.kombitz.com/2025/12/23/how-to-use-qwen-image-edit-2511-gguf-in-comfyui/)]**. Spodziewam się ok. minuty na obraz **[wniosek]**. Jest to kandydat na drugi model do etapu A1, jeśli klein rozmywa krawędzie.
- **IP-Adapter / Redux.** Redux i StyleModel należą do FLUX.1 dev (węzły `StyleModelApply` są w rdzeniu). FLUX.2 klein ma referencje natywnie, więc dodatkowe adaptery nic nie dają **[z pamięci/wniosek]**.
- **LoRA stylu.**
  - BFL: trening klein 4B base wymaga 12 GB VRAM i 32 GB RAM, styl potrzebuje 1500–2500 kroków, polecane narzędzia to AI-Toolkit i Diffusers, licencja Apache-2.0 **[zweryfikowane: [docs.bfl.ai](https://docs.bfl.ai/flux_2/flux2_klein_training)]**.
  - Na 8 GB możliwy jest eksperyment z natywnym `TrainLoraNode` (offloading, quantized_backward), ale nie jest to udokumentowane dla klein **[zweryfikowane: istnienie węzła; działanie niesprawdzone]**. Inna możliwość to płatny trening w chmurze (Runware ma osobny produkt „FLUX.2 klein 4B Style LoRA Training” **[zweryfikowane istnienie: [runware.ai](https://runware.ai/docs/models/runware-flux-2-klein-4b-style-lora-training)]**).
  - Dziś mamy 2 postacie i kilka mebli, czyli za mało na zbiór danych **[wniosek]**. LoRA ma sens po zebraniu 15–30 zaakceptowanych assetów z drogi A, w powiększeniu ×4–×8.
- **Najtańszy sposób na spójność** to wspólne kroki deterministyczne dla wszystkiego: ta sama paleta (`unfake quantize --palette`), ten sam kontur `prop_outline.gd`, ta sama skala i to samo równe światło albedo. Droga A0 daje to z definicji **[wniosek]**.

## 5. Porównanie

| | A: Blender proceduralnie (+img2img) | B: ControlNet | C: image-to-3D → Blender | Retro Diffusion |
|---|---|---|---|---|
| Wierność rzutu i wymiarów | dokładna (co do px) | dobra, nie dokładna | dobra po skalowaniu bbox | zależna od `strength` |
| Styl obok postaci | do sprawdzenia (ryzyko CG) | inny model = inny styl | jak A | dobry pixel art, inny niż nasz? |
| Normal mapa | prawdziwa z renderu | heurystyka `normals.gd` | prawdziwa z renderu | heurystyka |
| VRAM | ok. 0 / 8 GB (A1) | 6–8 GB + offload | ok. 7–8 GB, niepewne | 0 |
| Pieniądze | 0 | 0 | 0 | ok. 0,18 USD/obraz |
| Czas na asset (agent) | 5–15 min nowy typ | 10–20 min strojenia | 15–30 min + poprawki | minuty |
| Instalacja | Blender | modele 10–15 GB | wagi TRELLIS.2/Pixal3D | konto + klucz |
| Do czego | skrzynie: lady, szafy, biurka, regały, prycze, drzwi | zapas dla A1 | krzesła, rośliny, sprzęt organiczny | zapas na styl |

**Rekomendacja:** jako główną drogę przyjąć **A**: Blender sterowany skryptem, kamera 45° z rozciągnięciem √2, normal mapa z renderu. Wariant A0 albo A1 rozstrzyga arkusz porównawczy. Drogę **C** dodać później dla kilku obiektów organicznych. **B** i Retro Diffusion trzymać w rezerwie.

## 6. Minimalny pierwszy eksperyment (lada + szafka na akta)

1. **Instalacja (człowiek zatwierdza):** Blender LTS (`winget install BlenderFoundation.Blender` albo portable zip), ścieżka do `blender.exe` zapisana w notatce pipeline'u.
2. **`prop_rig.py`** w `game1-proto/.../pipeline/blender/`, czyli w prototypie, nie w grze:
   - czyta spec JSON i buduje bryły (bevel 1–2 cm),
   - kamera ortogonalna, obrót X = 45°, `ortho_scale` = większy wymiar kadru, rozdzielczość ×8,
   - `film_transparent`, render albedo (Emission/Workbench flat), render normal (materiał przeliczający normalne świata na konwencję `normals.gd`) i maska,
   - wyjście: `<nazwa>_albedo.png`, `_normal.png`, `_mask.png`.
3. **Specy:**
   - lada 4,8 × 0,6 × 1,05 m: cokół, front z płyt, blat z nawisem 3 cm, brzoza i laminat, cel 192 × 66 px,
   - szafka na akta 0,55 × 0,6 × 1,35 m: 4 szuflady z uchwytami, szary metal, cel 22 × 78 px.
4. **Kontrola geometrii (automatyczna):** po zmniejszeniu bbox maski ma wymiary 192 × 66 i 22 × 78 (±1 px), a w kolumnach brzegowych nie ma pikseli boków.
5. **Warianty do arkusza:**
   - A0: albedo → `unfake downscale -m dominant` → `quantize --palette palette.hex` → `prop_outline.gd`,
   - A1: img2img FLUX.2 klein 4B (render jako latent startowy, arkusz Badacza jako referencja) przy denoise 0,25 / 0,4 / 0,55 → przycięcie maską → ta sama pikselizacja,
   - dla porównania obecna lada z `_guides/lada.png` przepuszczona przez dotychczasowy pipeline.
6. **Arkusz ×4 obok `pixel_ref.png`** (Badacz, Krogg) oraz zrzut w Godot pod światłem z normal mapą z Blendera i z `normals.gd`. Decyzję podejmuje człowiek.
7. **Kryterium sukcesu:** zero dryfu rzutu, wymiary co do piksela i styl „nie odstaje” od postaci według oceny człowieka. Jeśli A0 i A1 odstają, następny krok to Qwen-Image-Edit albo RD Pro `edit` na renderze.

Czas eksperymentu: ok. 1–2 h pracy agenta po instalacji Blendera **[wniosek]**.
