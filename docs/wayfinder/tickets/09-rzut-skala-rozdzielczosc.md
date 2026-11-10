---
id: 09
title: Rzut, skala i rozdzielczość: test sześcianu i warianty w style-lab
labels: [wayfinder:prototype]
status: closed
assignee: claude
blocked_by: [02, 07, 08, 17]
---

## Question

Jaki kąt kamery (proporcja wierzch:front), px/m, rozdzielczość bazowa, wysokość postaci i wysokość ścian? Test sześcianu i lady 1×1×1 m w kandydatach narzędzi (lokalne i triale wg researchu Narzędzia, limity i koszty) plus postać w 4 kierunkach, pomiar proporcji; warianty przełączane w style-lab na prostym pokoju i kawałku ulicy z bryłami, z postacią w skali Kotwic stylu. Materiał: `docs/grafika.md` (rzut), `11b`, `46`, `51`, `54`. Wynik: wartości do `PROJECTION.md`.

Z Wyboru Kotwic stylu: rzut to **niskie 3/4 oblique** (Kotwica rzutu: Beat Cop), więc testujemy tylko warianty kąta w tej rodzinie (proporcja ściana:podłoga), nie izo ani wysokie 3/4. Postać w 3 rysowanych kierunkach + lustro, dorosłe proporcje 6–7 głów; warianty wysokości ok. 56–72 px (punkty pomiarowe: Drova ok. 55–70 px, Gemini Rue ok. 40–50 px). Sprawdzić przenikanie budynków z przodu.

**Bliższa kamera** (uwaga człowieka po szkielecie style-lab, 2026-11-08): sprawdzić kadr ciaśniejszy niż 960×540 przy tej samej skali. Mniej mapy na ekranie to większa postać i więcej klimatu. Wariant „Kadr” jest już w panelu F1 (960×540, 800×450, 640×360, 480×270, przy stałym px/m). Rozstrzygnąć razem z px/m, bo kadr i skala postaci zależą od siebie: ta sama postać na ekranie wychodzi z małego kadru albo z większego px/m, a różnią się wielkością piksela i szczegółem. Uwzględnić czytelność ulicy i wnętrza oraz miejsce na UI dialogów.

**Czarne tło wokół wnętrz** (uwaga człowieka, 2026-11-08): pokój węższy niż kadr stoi w czarnej pustce (demo: pokój 9 m przy kadrze 24 m). Rozstrzygnąć razem z kadrem: bliższa kamera, pokoje szersze niż kadr albo tło lub oprawa wokół pokoju. (Czarne pasy przy skalowaniu całkowitym naprawione w szkielecie: obraz wypełnia okno.)

## Postęp (2026-11-08, w toku)

- **Przenikanie odpada** (decyzja człowieka): budynki z przodu nie są przezroczyste; ogrywamy to planem miasta (od kamery tylko niskie rzeczy: murek, zaspy, płot, krawędź mapy). Plan ulicy pod kamerę: Poligon Ulica.
- **Pomysł człowieka: różne zbliżenie na zewnątrz i we wnętrzu.** Propozycja: jedno px/m dla assetów, inny kadr (całkowita skala), np. ulica 640×360 (×3), wnętrze 480×270 (×4). Do oceny na arkuszu.
- Prototyp: `style-lab/rzut.bat` (Poligony `poligony/rzut_ulica` ↔ `rzut_dom`, budowane kodem w `RzutPoligon`). F1: Kąt (głębia : szerokość 1,00 / 0,75 / 0,60 / 0,50), px/m (32 / 36 / 40 → postać 58 / 65 / 72 px), Kadr ulicy, Kadr wnętrza, Piętro fasady (1,3 / 1,6 / 1,9 × postaci), Ściana pokoju (2,4 / 2,6 / 3,0 m), Wokół pokoju (czerń / szerszy / oprawa), Siatka 1 m, Odczyt wymiarów, Okno dialogu (pasek / kolumna). Placeholder postaci 7 głów w 3 widokach + lustro (`world/figure.gd`), rząd wzorców: sześcian 1 m, lada 2×0,6×1 m, trzy manekiny. Światło z game1 poprawione pod `depth_factor` (smugi, plamy lamp, powierzchnia podłogi).
- Arkusz porównawczy (lokalny): `node tools/arkusz_rzutu.mjs` → `style-lab/shots/arkusz_rzut/arkusz.html`; zrzuty wsadowe z `--set=id=indeks,...`.
- Prowadnice z Blendera 5.2 (`C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`): `tools/blender/zestaw_testowy.py --df <kąt> --ppm <px/m>` → szary box + depth (sześcian, lada, manekin przód/bok/tył/skos) w rzucie gry (kamera ortho θ = atan(df), pion rozciągnięty o 1/cos θ).
- ComfyUI: pobierane SDXL base, ControlNet depth SDXL, LoRA pixel-art-xl, VAE fp16 fix do `C:\Users\bartl\AppData\Local\Comfy-Desktop\ComfyUI-Shared\models`.
- Dalej: człowiek wybiera kąt, px/m i kadry na arkuszu i w `rzut.bat` → render prowadnic dla wybranego kąta → ComfyUI (lokalnie) i Pixellab (za zgodą przed każdą generacją, ok. 4–5 gen.), RD przez web (człowiek, mierzony czas) → wyniki w Poligonie obok brył → wartości do `PROJECTION.md`.
- Uwagi człowieka (2026-11-08): dialogi i mechaniki są w game1, tu tylko oprawa (szkic okna dialogu usunięty); ocena tylko w grze, nie na zdjęciach (F2–F4); mapa musi pozwalać chodzić w głąb (kwartał: dwie ulice, podwórka, przecznica); wnętrze z dwoma pokojami i ścianą działową (warianty pełna / obcięta 1 m / sam wierzch). Kadr 960 i 640 wyglądały tak samo przez zaokrąglanie skali całkowitej na oknie ok. 990 px: teraz kadr pokazuje dokładnie zadaną wysokość.
- Pomiar z Poligonu: bez przenikania budynek lub ściana zasłania za sobą pas **wysokość ÷ kąt** (2 piętra przy 0,60: 9,6 m; ściana działowa 2,6 m przy 0,60: 4,3 m z 4,5 m tylnego pokoju; przy 1,00: 2,6 m).
- Wariant z game1 (prośba człowieka): ściany wnętrz celowo niższe, 1,9 m (ADR 0002 game1), drzwi z nadprożem min(2,0; ściana − 0,35) ≈ 1,55 m, okno: parapet na 1/3 ściany, góra 0,25 m pod sufitem; ściana działowa z pełnym licem w tej wysokości. W Poligonie domyślne; przy kącie 1,00 zasłania 1,9 m tylnego pokoju.
- Wariant człowieka: ściana działowa pełna, a gdy gracz jest w tylnym pokoju, obcina się (0,2 s) do 1 m albo do wierzchu (`pelna>obcieta`, `pelna>wierzch`); zmienia się tylko rysunek, światło jak przy pełnej ścianie (pokoje mają osobne maski). Poprawka: przy zmianie kąta postać trafiała w inne miejsce (pozycja czytana już w nowej skali).

### Decyzje człowieka (2026-11-08, na Poligonie)

- **Kąt 0,60** (proporcja głębi podłogi do szerokości; sześcian 1 m: front 40 px, wierzch 24 px; kamera ortho ok. 31° nad poziomem, ok. 59° od pionu). W dokumentach podawać jako proporcję, nie w stopniach.
- **40 px/m**, postać 1,8 m = 72 px (głowa ok. 10 px).
- **Kadr 960×540 wszędzie** (ulica i wnętrza; jedna skala, ×2 na 1080p).
- **Wokół wnętrz czerń** (pokoje nie muszą wypełniać kadru, jak w game1).
- **Chowane ściany działowe** na pewno (animacja do dopracowania w grze); światło jak przy pełnej ścianie.
- **Ściany wnętrz 2,2 m** wszędzie (zamiast 1,9 działowych / 2,2 tylnej: jeden „sufit”, drzwi min(2,0; 2,2 − 0,35) = 1,85 m, bez migania głowy nad nadprożem).
- **Wchodzenie za budynki zablokowane** układem miasta (reguła: dostępny teren co najmniej wysokość ÷ 0,6 za tylną krawędzią budynku; 2 piętra ≈ 9,6 m); szczegóły przy projektowaniu miasta w grze.
- **Piętro fasady 1,6 × wzrost postaci** (2,9 m, obniżone względem realnego): prawdopodobnie, do potwierdzenia na docelowej grafice ścian. Dom 2-piętrowy zasłania wtedy ok. 9,6 m za sobą.
- Do sprawdzenia w grze: chód w pionie przy 0,60 wygląda na wolniejszy (60% drogi na ekranie).
- Pytanie człowieka: czy dopasować kąt do standardu generatorów. Pixellab (OpenAPI, orientacyjnie): low top-down ok. 20° (proporcja ok. 0,36), high top-down ok. 35° (ok. 0,70); nasze 0,60 ≈ 31°. Dodano kąty 0,70 i 0,36 do F2. Plan: zmierzyć realny kąt Pixellab sześcianem bez obrazu wejściowego (low i high), potem ewentualnie przesunąć kąt gry do najbliższego (prawdopodobnie 0,70); meble i budynki z prowadnic Blendera i tak nie zależą od etykiety widoku.
- Próba lokalna ComfyUI (2026-11-08): SDXL base + ControlNet depth SDXL (0,85, do 80%) + pixel-art-xl, prowadnice Blendera 1024 przy kącie 0,60; ok. 25 s/obraz na RTX 4060 Laptop, 0 zł. Skrzynia i lada trzymają kąt i skalę (w Poligonie: F1 „Rząd wzorców”, maska z renderu, zmniejszenie ×1/8 nearest), tło generator dorabia własne (wycinane maską); postać przejmuje kanciasty kształt manekina (prowadnica depth za sztywna dla postaci). Skrypt: `style-lab/tools/comfy_proba.mjs`, wyniki `style-lab/proby/comfy_060/` z `prompts.jsonl`.

## Resolution

Zamknięte 2026-11-08 decyzjami człowieka na grywalnym Poligonie (`style-lab/rzut.bat`: kwartał miasta i dom z dwoma pokojami, F2 kąt, F3 px/m, F4 kadr). Wartości do `PROJECTION.md`:

| Stała | Wartość |
|---|---|
| Rzut | niskie 3/4 oblique: front w pełnej wysokości, głębia podłogi × **0,60** (sześcian 1 m: front 40 px, wierzch 24 px; odpowiada kamerze ortho ok. 31° nad poziomem). Podawać jako proporcję, nie w stopniach. |
| Skala | **40 px/m** we wszystkich wymiarach pionowych i poziomych; głębia × 0,60 |
| Postać | 1,8 m = **72 px** (głowa ok. 10 px, 7 głów); 3 rysowane widoki + lustro |
| Kadr | **960×540 wszędzie** (ulica i wnętrza; ×2 na 1080p), czerń wokół wnętrz węższych niż kadr |
| Ściany wnętrz | **2,2 m** (jeden „sufit”); drzwi min(2,0; ściana − 0,35) = 1,85 m z nadprożem; okno: parapet 1/3 ściany, góra 0,25 m pod sufitem |
| Ściana działowa | **chowana**: pełna, a gdy gracz jest w pokoju za nią, obniża się (do ok. 1 m lub do wierzchu); zmienia się tylko rysunek, światło jak przy pełnej ścianie (osobne maski pokojów). Animacja do dopracowania w grze. |
| Fasady | piętro **1,6 × wzrost postaci** (2,9 m), prawdopodobnie; do potwierdzenia na docelowej grafice ścian |
| Zasłanianie | bez przenikania; obiekt o wysokości H zasłania za sobą pas **H ÷ 0,60** (dom 2-piętrowy ≈ 9,6 m, ściana 2,2 m ≈ 3,7 m). Teren za budynkami blokuje układ miasta (projekt miasta w grze). |

Ustalenia narzędziowe:
- **Prowadnice z Blendera wymuszają kąt** na lokalnym generatorze: SDXL + ControlNet depth + pixel-art-xl w ComfyUI (0 zł, ok. 25 s/obraz) dał skrzynię i ladę w kącie 0,60 i skali 40 px/m. Postać tą drogą wychodzi źle (kanciasta po manekinie): postacie robić łańcuchem z game1 (koncept → `image_to_pixelart` → v3).
- Pixellab ma widoki orientacyjne low top-down ok. 20° (proporcja ok. 0,36) i high top-down ok. 35° (ok. 0,70); nasze 0,60 jest najbliżej high. **Kąt może się jeszcze przesunąć (np. 0,60 → 0,70)**, jeśli Przepis postaci pokaże, że postacie z Pixellab lepiej pasują do standardowego widoku; meble i budynki z prowadnic idą za dowolnym kątem.
- Pixellab trial nie był używany w tym tickecie (0 generacji).

Narzędzia i materiał (prototyp, nie kod gry): `style-lab/poligony/rzut_*` (`RzutPoligon`, `Figure`, `Mannequin`), `style-lab/tools/arkusz_rzutu.mjs` (arkusz zrzutów), `style-lab/tools/blender/zestaw_testowy.py` (prowadnice: szary box i depth w rzucie gry, `--df --ppm --canvas`), `style-lab/tools/comfy_proba.mjs` (próba SDXL), `style-lab/proby/` (wyniki i koncepty). Blender 5.2: `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`. Modele ComfyUI: SDXL base, ControlNet depth SDXL, pixel-art-xl, VAE fp16 fix, FLUX.2 klein 4B (fp8) w `C:\Users\bartl\AppData\Local\Comfy-Desktop\ComfyUI-Shared\models`. Zmiany w style-lab poza Poligonem: kadr pokazuje dokładnie zadaną wysokość (skala niecałkowita), światło liczy głębię z `depth_factor`, `DebugRegistry` pamięta wartości i przyjmuje `--set`, F2–F4.
