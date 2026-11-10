# 73. Kalibracja Orient Anything V1 Large jako filtra kąta kamery

Kontynuacja `72-pomiar-kata.md`. Data: 2026-11-08. Wszystko liczone lokalnie na CPU (zero zadań w ComfyUI, zero płatnych API). Surowe wyniki: `style-lab/tools/orient/results/*.csv`.

Oznaczenia: **[zmierzone]** = z CSV w `results/`; **[wniosek]** = moja interpretacja.

## Werdykt

**Działa częściowo, jako filtr odrzucający, nie jako miernik absolutny.**

- Na cieniowanych renderach MPFB polar rośnie monotonicznie z `depth_factor` w każdym z 3 widoków, a rozrzut (σ ≈ 1,4°) jest kilka razy mniejszy niż odstęp 0,36 vs 0,60 (6-8°). **[zmierzone]**
- Na obrazach ocenionych przez człowieka **przód** i **tył** rozdzielają się dobrze na „za płasko” (polar ≤ 10°) vs „dobrze” (16-25°). Odrzucenie „za wysoko” na przodzie jest słabe (jedna próbka, 28° vs 21-25°).
- **Bok**: polar prawie nie pomaga (render saturuje od df ≈ 0,5, a dobry profil człowieka daje 16°, mniej niż render 0,60 = 27°). Dobry jest **azymut** (≈ 90° / 270°), ale 1 z 3 odrzuconych „3/4” miał azymut 85°, czyli przechodzi. Potrzebne dodatkowo górne ograniczenie polaru.
- Skala modelu jest **skompresowana i przesunięta** względem prawdziwego kąta: df 0,60 (31°) czyta jako ok. 20° (przód), 0,36 (20°) jako ok. 12°. Progi podaję więc w jednostkach modelu, nie w stopniach geometrycznych.
- Próg trzeba zawsze weryfikować człowiekiem w Poligonie (reguła z pamięci); filtr tylko tnie kandydatów. Próbek ocenionych przez człowieka jest mało (1 dobra na widok), więc progi poniżej są **wstępne**.

## 1. Środowisko (co dokładnie zainstalowano)

- `style-lab/tools/orient/venv` utworzony z Pythona ComfyUI przez `python -m venv --system-site-packages`. Uwaga: `--system-site-packages` w venv-z-venv **nie** dziedziczy pakietów venv ComfyUI (dziedziczy bazowy Python), więc dodałem plik `venv/Lib/site-packages/comfy_readonly.pth` ze ścieżką do `site-packages` ComfyUI (tylko odczyt; nic w ComfyUI nie zmieniono). Torch 2.12.1+cu130, transformers 5.20.2, Pillow 13.0.0, scipy z ComfyUI.
- **Nie wykonano żadnego `pip install`**: `requirements.txt` repo (torch 2.2.1, transformers 4.38, gradio, rembg itd.) jest niepotrzebny, bo `measure.py` nie używa gradio/rembg, a kompozyt tła robi sam. Zależności są już w ComfyUI.
- Repo: `style-lab/tools/orient/repo` (git clone `SpatialVision/Orient-Anything`, tylko do wglądu; `measure.py` go nie importuje).
- Pobrane (HF, `style-lab/tools/orient/weights`, łącznie 1,5 GB): `Viglong/Orient-Anything/croplargeEX2/dino_weight.pt` (1,2 GB, zawiera też DINOv2-L, więc **nie pobierano** `dinov2-large`) i `facebook/dinov2-base` (config + safetensors, 0,35 GB). Skrypt pobierania: `tools/orient/dl.py`.
- Odchylenia od repo (konieczne): (a) checkpoint `croplargeEX2` ma **722 wyjścia = 360 azymut + 180 polar + 180 rotacja + 2 pewność** (README `get_3angle` zakłada 360 bins rotacji, to niezgodne z tym checkpointem), więc rotacja ma zakres −90..90; (b) transformers 5 zmienił nazwy kluczy uwagi (`attention.attention.query` → `attention.q_proj` itd.), `measure.py` je mapuje; ładowanie `strict`, brak niezgodnych kluczy. (c) Konfiguracja DINOv2-L wpisana ręcznie (1024/24/16, patch 14), preprocess jak w HF (resize 256, crop 224, ImageNet).
- Czas: ok. 20 s ładowanie + ok. 0,5-1 s/kadr na CPU.

## 2. Jak działa `measure.py`

Plik: `style-lab/tools/orient/measure.py` (+ `measure.cmd`). Przetwarzanie wejścia:
1. Tło: RGBA → kompozyt alfy na jasnoszare (193,193,193); RGB z generatora → maska z odległości od mediany krawędzi, największa składowa, tło zastąpione tym samym szarym (zdejmuje gradient i winietę; cień pod postacią zostaje w masce).
2. Kadr do bbox pierwszego planu, kwadrat, pierwszy plan = 85% boku (jak `resize_foreground(…, 0.85)` w repo).
3. `--aug N` = N deterministycznych wariantów (skala 0,92-1,05, przesunięcie do 3%); wynik = średnia (azymut kołowo), kolumny `az_std`, `polar_std` = rozrzut.

Kolumny CSV: `file, azimuth, polar, rotation, confidence, az_std, polar_std, sim`. Jednostki: azymut 0-360 (0 = przodem, 90 = prawa strona postaci w kadrze, 180 = tył, 270 = lewa; renderowany `bok` zwrócony w lewo daje 270, **zgodnie ze zmierzonym**), polar w stopniach (dodatni = kamera z góry; **zmierzone**: rośnie z df), rotacja −90..90, pewność 0-1 (prawie zawsze ≈ 1,0, **nie pomaga w filtrowaniu**, nawet dla 3/4).

Polecenia (z katalogu `C:\Users\bartl\Desktop\game2\style-lab`):

```
tools\orient\measure.cmd obraz1.png obraz2.png                     (szybko, 1 kadr)
tools\orient\measure.cmd --aug 9 proby\kurtka_060\przod_a13_s9000.png   (zalecane, z rozrzutem)
tools\orient\measure.cmd --aug 1 --sim proby\koncept9\edit_kurtka_s9000.png proby\kurtka_060\*.png
tools\orient\venv\Scripts\python.exe tools\orient\measure.py --device cpu --save-prep out\prep obraz.png   (podgląd kadru po przetworzeniu)
```

Pomiar na CPU, żeby nie kolidować z ComfyUI; `--device cuda` działa (torch ma CUDA), ale nie testowano.

## 3. Kalibracja na renderach Blendera

**Istniejący zestaw `shots/kalibracja` (płaska sylwetka + brązowe buty) nie nadaje się**: tryb Workbench FLAT, ciało prawie w kolorze tła, brak cieniowania. Polar dla `przod`/`tyl` jest ≈ −2…−5° niezależnie od df (brak sygnału, a nawet lekko ujemny trend), a `tyl` odczytuje się jako azymut 0 (przód). Dla `bok` polar 0-8° bez trendu; z ciemniejszym tłem 13-24° bez trendu. **[zmierzone]** (`results` z pierwszych przebiegów nie zachowano; powtórzenie: `measure.cmd shots\kalibracja\*.png`).

Dlatego wyrenderowano **nowy sweep** cieniowanym manekinem (`tools/blender/postac_mpfb.py`, bez zmian skryptu, 19 uruchomień Blendera 5.2 headless) do **`style-lab/shots/orient_sweep/df_000…df_090`** (df 0,00-0,90 co 0,05; widoki przód/bok/tył; `bok` = zwrócony w lewo). Polar w stopniach, `--aug 9`, średnia ± σ:

| df | prawdziwa elewacja (atan) | przód | bok | tył |
|---|---|---|---|---|
| 0,00 | 0° | −5,1 ± 0,9 | −2,3 ± 1,1 | −3,7 ± 1,5 |
| 0,10 | 5,7° | 0,3 ± 0,5 | 6,2 ± 1,7 | 4,9 ± 2,3 |
| 0,20 | 11,3° | 6,7 ± 0,9 | 13,0 ± 1,7 | 8,6 ± 1,7 |
| 0,30 | 16,7° | 10,1 ± 0,7 | 18,3 ± 1,2 | 12,0 ± 2,1 |
| **0,36 / 0,35** | 19,3° | 12,2 ± 2,0 | 20,2 ± 1,0 | 13,1 ± 2,3 |
| 0,40 | 21,8° | 15,1 ± 1,1 | 22,9 ± 1,3 | 14,6 ± 1,4 |
| 0,50 | 26,6° | 17,7 ± 1,1 | 25,9 ± 0,9 | 16,9 ± 1,7 |
| **0,60** | 31,0° | 19,9 ± 0,3 | 27,1 ± 0,6 | 19,1 ± 1,9 |
| 0,70 | 35,0° | 23,1 ± 2,6 | 28,3 ± 0,7 | 21,9 ± 2,4 |
| 0,80 | 38,7° | 25,8 ± 0,8 | 28,8 ± 0,4 | 24,8 ± 2,0 |
| 0,90 | 42,0° | 26,6 ± 0,7 | 29,8 ± 2,2 | 26,7 ± 0,5 |

(pełne wartości co 0,05: `results/sweep_aug9.csv`; pierwsze przebiegi na jednym kadrze: `results/sweep_aug1.csv`, razem z `shots/mpfb_036/060/070`, które zgadzają się z sweepem w ±2°.)

Odpowiedzi:
- **Monotoniczność**: tak, w całym 0-0,9 dla przodu i tyłu (po uśrednieniu 9 kadrów), i dla boku do ok. 0,8 (nierówności ≤ 1° w szumie; df 0,85-0,90 szumią ±2°). Na pojedynczym kadrze (`--aug 1`) pojawiają się płaskie odcinki, nie spadki, poza krawędzią 0,05 → 0,1 na przodzie.
- **Czułość spada**: przód ok. 38°/df w 0,0-0,5, ok. 22°/df w 0,6-0,9; **bok saturuje już od df ≈ 0,5** (26° → 30° na 0,5 → 0,9), więc na boku polar nie odróżni 0,5 od 0,8.
- **Rozrzut (powtarzalność)**: model jest deterministyczny (ten sam kadr = ten sam wynik), więc rozrzut oceniono wariantami kadru (9 wariantów: skala ±8%, przesunięcie do 3%). σ polaru: średnio 1,4°, max 2,6° na renderach; azymut ≤ 0,5° dla przodu i tyłu. Na obrazach z generatora σ 0-4,7° (większy dla bocznych, do 4,7°). **Odstęp 0,36 vs 0,60 = 7,7° (przód), 6,9° (bok), 6,0° (tył)**, czyli ≥ 3-4σ: rozróżnialne, ale tylko przy `--aug 9`; na jednym kadrze błąd ±2-3° zjada część marginesu.
- **Azymut na renderach**: przód 0-3°, tył 182° (przód ↔ tył rozróżniony poprawnie na cieniowanym manekinie), bok 270° ± 9° (279° przy df 0,25).

Zalecane mapowanie do df (przód, interpolacja z tabeli): polar 10° ≈ 0,30; 12° ≈ 0,36; 15° ≈ 0,40; 18° ≈ 0,50; 20° ≈ 0,60; 23° ≈ 0,70; 26° ≈ 0,80. **[wniosek]**: ta krzywa dotyczy gołego manekina; ilustracje kurtki/płaszcza dają przesunięcie (zob. §4).

## 4. Obrazy ocenione przez człowieka

Polar ± σ (`--aug 9`); azymut w nawiasie. Kolumna „sim” = cosinus DINOv2-base do `koncept9/edit_kurtka_s9000.png` (1 kadr, pełne CSV: `results/human_aug1.csv`).

| Ocena człowieka | Obraz | polar | azymut | sim |
|---|---|---|---|---|
| **DOBRY przód** (płaszcz) | koncept8/k060_a09 | **20,9 ± 1,1** | 0,8 | 0,786 |
| **DOBRY bok** (płaszcz) | koncept8/bokP060 | **16,3 ± 2,7** | 87,7 | 0,717 |
| za płasko, przód | kurtka_060/przod | 1,8 | 0,0 | 0,996 |
| za płasko, przód | koncept9/edit_kurtka (koncept) | 1,6 | 0,0 | 1,000 |
| za płasko, tył | kurtka_060/tyl | 9,6 | 179 | 0,754 |
| za płasko, tył | kurtka_060/tyl_a13 | 9,4 | 179 | 0,750 |
| za wysoko, przód | kurtka_060/przodP | **28,0** | 3,0 | 0,795 |
| 3/4 zamiast profilu | kurtka_060/bok_a13 | 39,6 ± 4,2 | **73,6** | 0,790 |
| 3/4 zamiast profilu | kurtka_060/bok_zprz_a10 | 36,3 ± 4,1 | **78,2** | 0,796 |
| 3/4 zamiast profilu | kurtka_060/bok_zprz_pose | 29,7 ± 2,9 | **85,4** | 0,793 |
| kandydat przód | przod_a13_s9000 / 9001 / 9002 | 17,3 / 23,7 / 16,1 | 0,9 / 2,0 / 0 | 0,934 / 0,907 / 0,946 |
| kandydat bok | bok_pose_a13_s9000 / 9001 / 9002 | 12,8 / 27,0 / 26,2 | 91,0 / 91,2 / 89,1 | 0,787 / 0,731 / 0,733 |
| kandydat tył | tyl_zprz_a10_s9000 / 9001 / 9002 | 21,3 / 23,7 / 19,1 | 178 / 179 / 179 | 0,696 / 0,706 / 0,710 |
| płaszcz ok. 0,36 | koncept8/k036_a05 | 6,8 | 0 | 0,831 |
| płaszcz ok. 0,70 | koncept8/k070_a12 | 25,0 | 0,3 | 0,785 |

Dodatkowo (bez oceny człowieka): `koncept8/bok036/060/070` azymut 62-66° (to wygląda na 3/4, polar 26-30), `bokL060` 302°, `tyl036/060/070` polar 15/13/16.

Wnioski **[wniosek]**:
- **Przód**: „za płasko” (1,6-2,8°) vs „dobry” (20,9°) rozdzielone z ogromnym zapasem; kandydaci 16-24° mieszczą się obok dobrego. „Za wysoko” (28°) leży o 3-7° powyżej dobrych (21-25°); to jeden obraz, a render saturuje ≈ 26-27°, więc górny próg jest niepewny. Płaszcz „0,36” daje 6,8° (płasko), niżej niż manekin 0,36 (12°): ilustracja jest odczytywana jako bardziej płaska niż manekin o tym samym kącie.
- **Tył**: płasko 9,4-10,4° vs kandydaci 19-24° vs render 0,60 = 19,1°; rozdzielone (zapas ok. 9°). Płaszcze tył 12,7-15,9 (ocena nieznana).
- **Bok**: dobry profil: azymut 87,7°, polar 16,3°. Odrzucone 3/4: azymut 73,6 / 78,2 / **85,4** (ostatni przechodzi próg azymutu), polar 39,6 / 36,3 / 29,7 (wszystkie powyżej dobrego). Kandydaci mają azymut 89-91° (czyste profile), polar 12,8 / 27,0 / 26,2: dwa ostatnie wpadają w „podejrzaną” strefę 26-30° wspólną z odrzuconym `bok_zprz_pose`. Bok jest zatem **najtrudniejszy**; oceniać azymutem **i** polarem, a `bok_pose_s9000` (91°, 12,8°) wygląda najlepiej wg modelu.
- Pewność (`confidence`) = 1,0 dla wszystkich, w tym 3/4; **nie używać**.

## 5. Proponowane progi (jednostki modelu, `--aug 9`)

Oparte na 1 dobrym obrazie na widok, więc wstępne; po zebraniu kolejnych ocen człowieka skorygować.

| Widok | azymut | polar (przyjmij) | odrzuć |
|---|---|---|---|
| **przód** | 350-10° (czyli ≤ ±10°) | **16°-25°** (≈ df 0,45-0,75; środek 20-21°) | < 14° = za płasko; > 26° = za wysoko (niepewne, jedna próbka 28°) |
| **tył** | 170-190° | **17°-25°** | < 15° = za płasko |
| **bok** (prawy 90°, lewy 270°) | 80-100° (lewy 260-280°) | **10°-26°** | azymut poza zakresem = 3/4; polar > 27° (wszystkie odrzucone 3/4 ≥ 29,7°) |

Dodatkowo: odrzucać, gdy `polar_std` > 4° (niestabilna ocena) lub `az_std` > 5° (rozjazd kadrów zwykle oznacza 3/4/niejednoznaczność).

Sprawdzenie progów na obrazach człowieka: wszystkie 4 „za płasko” (przód, koncept, 2 tyły) odrzucone, „za wysoko” (28°) odrzucone, 3 z 3 odrzuconych 3/4 odrzucone (dwa azymutem, trzeci `bok_zprz_pose` polarem 29,7°), dobry przód i dobry bok przyjęte. Z 9 kandydatów 7 przechodzi; `bok_pose_a13_s9001` (27,0°) i `s9002` (26,2°) leżą na granicy bok-polaru 26° i wymagają oceny człowieka. To spójność z dotychczasowymi ocenami, nie dowód dokładności (mała próba, progi dopasowane do niej).

## 6. DINOv2-base: tożsamość względem `koncept9/edit_kurtka_s9000.png`

Cosinus cech CLS (jak w tabeli §4; mediana grup z `human_aug1.csv`):

| Widok | kurtka (kurtka_060, koncept9) | płaszcz (koncept8) |
|---|---|---|
| przód | 0,795-0,997, średnia 0,925 (n = 10) | 0,785-0,831, średnia 0,80 (n = 3) |
| bok | 0,718-0,802, średnia 0,77 (n = 8) | 0,716-0,760, średnia 0,74 (n = 5) |
| tył | 0,696-0,756, średnia 0,73 (n = 6) | 0,631-0,641, średnia 0,635 (n = 3) |

- **Przód**: kurtka vs płaszcz rozdzielone progiem ≈ 0,85 (kandydaci 0,907-0,946; przód z pozą 0,88; płaszcz max 0,83); wyjątek: `przodP` (kurtka, za wysoko) = 0,795, jak płaszcz.
- **Tył**: rozdziela słabo, ale spójnie (płaszcz 0,63-0,64 vs kurtka 0,70-0,76; próg ≈ 0,67).
- **Bok**: **nie rozdziela** (zakresy się nakładają).
- Wyniki są zależne od widoku (cosinus do konceptu frontowego spada wraz z obrotem), więc porównywać trzeba z konceptem z tego samego widoku, albo z obrazem frontowym tylko dla przodu. **[wniosek]**: jako filtr tożsamości DINOv2 wystarcza do odrzucania wyraźnych podmian (płaszcz zamiast kurtki) na przodzie i tyle; dla boku wymaga referencji bocznej (np. zatwierdzony `bok_s9000`).

## 7. Ograniczenia i dalsze kroki

- Próbki ocenione przez człowieka: 1 dobry przód, 1 dobry bok, 0 dobrych tyłów (tylko kandydaci). Progi: wstępne. Po każdej ocenie dopisywać do CSV i przeliczyć.
- Brak sweepu azymutu (np. 45°, 30° yaw) na renderze; azymut 3/4 oceniono tylko na 3 obrazach człowieka. Jeśli potrzeba, rozszerzyć kopię `postac_mpfb.py` o `--yaw` i wyrenderować do nowego katalogu.
- Przód ↔ tył: na `shots/kalibracja` (płaska sylwetka) model myli tył z przodem; na cieniowanym manekinie i ilustracjach rozróżnia poprawnie (azymut 179-182°).
- V2 (5 GB) nie pobierano: V1 spełnia kryterium rozrzutu (σ ≈ 1,4° ≪ połowa odstępu 0,36-0,60 ≈ 3-4°) tylko z `--aug 9`; bok ma zbyt płaską odpowiedź na df. Jeśli bok pozostanie problemem po zebraniu ocen, V2 to kolejny krok (wymaga zgody; ok. 5,05 GB + sprawdzenie licencji wag).
- Powtarzalność dotyczy zakłóceń kadru, nie zmiany tła/odbicia; test odbicia lustrzanego nie wykonany.

## 8. Pliki

- `style-lab/tools/orient/measure.py`, `measure.cmd`, `dl.py`, `.gitignore` (venv/weights/repo).
- `style-lab/tools/orient/results/`: `sweep_aug1.csv`, `sweep_aug9.csv`, `human_aug1.csv`, `human_aug9.csv`, `human_list.txt`.
- `style-lab/shots/orient_sweep/df_000…df_090/` (nowe rendery, widoki przód/bok/tył + depth).
