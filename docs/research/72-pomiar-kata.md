# 72. Automatyczny pomiar kąta kamery i obrotu postaci na wygenerowanym obrazie

Ticket: `docs/wayfinder/tickets/20-pomiar-kata-research.md`. Data: 2026-11-08. Tylko odczyt: nic nie zostało zainstalowane, pobrane ani wygenerowane; żadnych zadań w ComfyUI, żadnych płatnych API. Czytane: README/karty repozytoriów, artykuły, lokalne pliki i środowisko ComfyUI.

Oznaczenia: **[repo]**, **[paper]**, **[karta]** = źródło pierwotne; **[lokalnie]** = sprawdzone w plikach na dysku; **[wniosek]** = moja inferencja; **[brak]** = nie znalazłem w źródle (do sprawdzenia w kodzie/artykule przed próbą); **[pamięć]** = wiem skądinąd, nie zweryfikowałem w tej sesji.

## Odpowiedź w skrócie

1. **Nie ma modelu, który podaje „nasz kąt gry” wprost.** Wszystkie modele mierzą kąt w innej definicji (perspektywa, obiekt 3D, zdjęcia), a Qwen „podniesienie kamery” robi jako perspektywę, nie rzut oblique (ticket 20). Każdy pomiar trzeba więc **skalibrować na własnych danych** (render MPFB w znanych kątach + sprite'y, które człowiek już uznał za dobre) i traktować jako miarę względną/porządkową, a nie absolutną.
2. **Najlepszy kandydat: Orient Anything (V1 Large, a w drugiej kolejności V2)**: wprost zwraca azymut i kąt polarny pojedynczego obiektu, wytrenowany na renderach modeli 3D (nie na zdjęciach), licencja CC-BY-4.0 (komercyjnie OK z podaniem autorstwa), mały (V1) lub średni (V2). Jawna wada: dokładność absolutna na zdjęciach to **mediana błędu 13-77°** (tab. niżej), więc bez kalibracji i uśredniania (augmentacje) nie rozróżni 20° od 31° **[wniosek]**; to trzeba sprawdzić próbą.
3. **Drugi, tani i niezależny sprawdzian: keypointy 2D (DWPose/RTMPose, Apache-2.0)** do rozpoznania azymutu (przód / profil / tył: stosunek szerokości barków do wysokości tułowia, widoczność oczu i nosa) oraz **podobieństwo cech DINOv2 do zatwierdzonych sprite'ów** (tożsamość, strój). Nie nadają się jako główny pomiar kąta polarnego.
4. **Odpadają** (licencja lub niedopasowanie): 3D człowieka z SMPL (HMR 2.0, TokenHMR, SMPLer-X, Multi-HMR) bo **model SMPL jest tylko niekomercyjny** bez licencji z Meshcapade, a Multi-HMR dodatkowo ma własną licencję kodu/wag; estymatory kamery sceny (GeoCalib, Perspective Fields, VGGT, DUSt3R) bo opierają się na horyzoncie/ścianach/podłodze, a my mamy jedną postać na jednolitym tle; głębia (Depth Anything V2) jako sama w sobie niczego nie mierzy bez płaszczyzny podłoża.
5. Środowisko: Comfy Desktop ma `.venv` z Pythonem 3.13, `pip` i `torch 2.12+cu130` **[lokalnie]**, więc da się uruchomić modele w Pythonie **bez** systemowego Pythona; ale instalować trzeba w **osobnym venv**, nie w venv ComfyUI (zob. §5).

## 1. Zestawienie metod

Licencja = kod / wagi. „Komercyjnie” dotyczy Steam, UE.

| # | Metoda | Co zwraca | Dokładność (źródło) | Ilustracje? | VRAM / czas | Licencja | Werdykt |
|---|---|---|---|---|---|---|---|
| A | **Orient Anything V1** (ICML 2025), DINOv2-L + głowice, 305M par. (Small 23M, Base 88M) | azymut (360 bin), polar (180), rotacja, pewność **[repo]** | Mediana błędu azymutu V1: SUN-RGBD 33,9°, ARKitScenes 77,6°, Pascal3D+ 22,9°, Objectron 30,7°, ImageNet3D 13,3° (Acc30° 36-71%) **[paper V2, tab. 1]**; błąd polaru osobno **[brak]** | Trenowany na 2M **renderów** 3D z adnotacją przodu **[paper V1]**; stylizacja nieopisana **[brak]**, ale render to bliższa domena niż zdjęcie **[wniosek]** | VRAM nie podany **[brak]**; 305M par. = ok. 0,7 GB fp16 **[wniosek]**; ułamek sekundy-kilka s/obraz | CC-BY-4.0 (repo i karta HF) | **Główny kandydat** |
| B | **Orient Anything V2** (NeurIPS 2025), start z VGGT 1,2B | azymut, polar, rotacja, okresowość symetrii; opcja względnej pozy dwóch obrazów **[paper]** | V2: Pascal3D+ 15,0° mediana / Acc30 72,7%; SUN-RGBD 26,0°; ARKitScenes 36,5°; Objectron 22,6°; ImageNet3D 15,3° **[paper tab. 1]**. Lepsze niż V1 poza ImageNet3D | 600K wygenerowanych assetów 3D, rendery **[paper]**; stylizacja **[brak]** | Plik wag **5,05 GB** (`rotmod_realrotaug_best.pt`, HF `Viglong/OriAnyV2_ckpt`) **[repo]**; bf16/fp16 ok. 2,5-3 GB **[wniosek]**, mieści się w 8 GB, ale nie razem z Qwen | CC-BY-4.0 kod; licencja wag nie podana w czytanych źródłach **[brak]**; VGGT bazowy bywa niekomercyjny, więc **sprawdzić kartę HF wag przed użyciem** | Drugi wybór |
| C | **Podobieństwo cech DINOv2 / CLIP** do renderów i zatwierdzonych sprite'ów w znanych kątach (kNN/regresja grzbietowa na cechach) | najbliższy znany kąt; podobieństwo tożsamości | Brak publikowanej liczby; to metoda własna, dokładność wyjdzie z kalibracji **[wniosek]** | Zależy od domeny kalibracyjnej: render MPFB (goły manekin) vs malarski strój to duży rozjazd **[wniosek]** | DINOv2-B ok. 0,2 GB, kilkadziesiąt ms | DINOv2 Apache-2.0 **[pamięć]**, CLIP MIT **[pamięć]** | Dobre do tożsamości/stroju i jako pomiar względny |
| D | **DWPose / RTMPose** (IDEA-Research), keypointy 133 | punkty ciała, twarzy, stóp | COCO-WholeBody: DWPose-l 384×288 body AP 0,722, foot 0,704, face 0,887; -m 256×192 body 0,685 **[repo]** | Brak deklaracji dla ilustracji **[brak]**; w praktyce ControlNet-owym pipeline'ach działa na stylizacji **[wtórne, pamięć]** | ONNX, <1 GB, kilkadziesiąt ms; wymaga `onnxruntime`, którego w venv Comfy nie ma **[lokalnie]** | Apache-2.0 (repo); wagi trenowane na COCO-WholeBody **[pamięć]**: sprawdzić | Pomocniczy: azymut przód/profil/tył |
| E | **HMR 2.0 / 4DHumans**, TokenHMR, SMPLer-X, **Multi-HMR** | SMPL + kamera | Podane w artykułach w mm (MPJPE), nie w stopniach kąta kamery; **brak** wyniku dla kąta pochylenia | Wytrenowane na zdjęciach **[wniosek]** | Multi-HMR 672-L: 74 ms na V100 **[repo]**; HMR2 wymaga Pythona 3.10 i pakietów z PHALP **[repo]** | HMR2 kod MIT **[repo]**; **SMPL: wyłącznie niekomercyjnie**, handel przez Meshcapade **[smpl.is.tue.mpg.de]**; Multi-HMR: własna licencja, treść niepodana **[brak]** + NC **[pamięć]** | **Odpada (licencja)** |
| F | **GeoCalib** (cvg), Perspective Fields (Adobe) | roll, pitch, FoV, grawitacja z perspektywy sceny | GeoCalib AUC 1/5/10° pitch na LaMAR 55/77/86%, MegaDepth 32/53/68% **[repo]**; Perspective Fields: bez liczb na stronie **[brak]** | Trenowane na panoramach/ulicach **[repo]**; wymagają wskazówek sceny (horyzont, krawędzie) | Mały, szybki; instalacja `pip install -e .` **[repo]** | GeoCalib: kod Apache-2.0, wagi CC-BY-4.0 **[repo]**; PF: licencji nie odczytałem **[brak]** | **Odpada (niedopasowanie)**: postać na jednolitym tle nie ma horyzontu |
| G | **VGGT** (Meta) | pozy kamer z wielu widoków | Co3D AUC@30 90,4 (wersja Commercial) **[repo]** | Zdjęcia | Nie podano VRAM; 1B par. | Oryginał niekomercyjny; **VGGT-1B-Commercial** za formularzem **[repo]** | Odpada (wiele widoków, brak dla jednego rysunku) |
| H | **Depth Anything V2** (głębia względna) | mapa głębi | Brak kąta; przydatna tylko do płaszczyzny podłoża | Działa na ilustracjach, ale płaszczyzny nie ma | Small 24,8M par. | **Small Apache-2.0; Base/Large CC-BY-NC-4.0** **[repo]** | Odpada |

Zastrzeżenie do A/B: liczby pochodzą z benchmarków zdjęciowych z pojedynczym obiektem, nie z postaci ludzkich w rysunku. Ani paper V1 w abstrakcie, ani README nie podają błędu kąta **polarnego** osobno ani nie mówią o ilustracjach **[brak]**. Definicja zakresu polaru (czy 90° = poziom oczu) nie jest w README **[brak]**; trzeba ją odczytać z kodu `get_3angle` albo wyznaczyć empirycznie na sweepie MPFB.

## 2. Dlaczego bez kalibracji każdy wynik jest nieprzenośny

- Qwen robi „elevated” jako perspektywę (skraca nogi, powiększa głowę) **[ticket 20]**, a gra to rzut ortogonalny rozciągnięty o 1/cos: wysokości zachowane, głębia podłoża ×0,60 (30,96°). Model kąta (A/B) „widzi” perspektywę; ten sam wynik polaru ma więc inne znaczenie niż u nas. Mapowanie polar → depth_factor musi być dopasowane empirycznie **[wniosek]**.
- Mediana błędu 13-77° (tab. wyżej) jest rzędu **całej** różnicy między wariantami, które chcemy rozróżnić (0,36 ≈ 20° vs 0,60 ≈ 31°). Zadanie jest więc wykonalne tylko, jeśli **rozrzut** (powtarzalność) metody jest mały, a błąd systematyczny usunie kalibracja. Rozrzut mierzymy w §4; **nie wiadomo z literatury**, jaki jest **[brak]**.
- Z definicji pomiar względny (porządek) jest łatwiejszy niż absolutny: dla serii mocy LoRA 0,9 → 1,7 z jednego konceptu (`proby/kurtka_060/przod_a*`) metryka ma rosnąć/maleć monotonicznie; człowiek ocenił już te obrazy, więc to gotowy zbiór kontrolny **[lokalnie, ticket 12]**.

## 3. Środowisko lokalne (odczyt)

- ComfyUI: `...\ComfyUI-Installs\ComfyUI\ComfyUI\.venv` z `Scripts\python.exe` (**Python 3.13.12**), `pip 26.2.2`, `torch 2.12.1+cu130`, `torchvision`, `transformers`, `kornia`, `einops`, `scipy`, `numpy`, `PIL`, `safetensors`, `huggingface_hub` **[lokalnie]**. Brak: `opencv`, `timm`, `onnxruntime`, `scikit-learn`, `xformers`.
- Węzły własne: tylko `ComfyUI-GGUF` **[lokalnie]**. Nie ma `comfyui_controlnet_aux` (DWPose), ani węzła Orient Anything; wyszukiwanie nie znalazło żadnego węzła ComfyUI dla Orient Anything **[wyszukiwarka]**. Droga: **skrypt Pythona poza ComfyUI**, nie węzeł.
- Wniosek o instalacji: pakiety do modeli A/B/D **nie powinny trafiać do `.venv` ComfyUI** (ryzyko zepsucia torcha/transformers, a Python 3.13 jest nowy dla repozytoriów pisanych pod 3.10-3.11 **[wniosek]**; repo V2 zaleca Python 3.11 **[repo]**). Bezpieczna opcja: osobny venv `style-lab/tools/pomiar/.venv` utworzony przez `...\.venv\Scripts\python.exe -m venv --system-site-packages`, który dziedziczy torcha i dokłada tylko małe pakiety (`pip install` wymaga zgody człowieka). Jeśli któraś zależność nie ma kół na 3.13, potrzebny Python 3.11 (nie ma go na maszynie; do ustalenia z człowiekiem) **[wniosek]**.
- VRAM: Qwen Q4_K_M + enkoder zajmują większość 8 GB, więc **pomiar uruchamiać w osobnym procesie po zakończeniu zadania** (lub na CPU: DINOv2-L na CPU to sekundy na obraz) **[wniosek]**.

## 4. Kalibracja i powtarzalność

**Zbiór kalibracyjny (render MPFB, znane kąty).** Rozszerzyć `tools/blender/postac_mpfb.py` (nie `kalibracja_kata.py` z butami) o sweep: depth_factor 0,20-0,90 co 0,05 × azymut 0-360° co 15°. Dwa warianty: goły manekin (szary) i wersja z kolorowymi strefami (kurtka/spodnie/buty) z `postac_chod.py`. Tło jednolite lub alfa. Kąt prawdziwy znany dokładnie: elewacja = atan(df).

**Mapowanie.** Dla każdego obrazu w sweepie zapisać surowe `azymut, polar` (A lub B). Dopasować monotoniczną regresję izotoniczną (lub wielomian 2. stopnia) `polar_raw → df`, oddzielnie dla przodu/boku/tyłu, bo błędy zależą od azymutu **[wniosek]**. Metryki: RMSE (w jednostkach df), zakres rozróżnienia 0,36 vs 0,60 (czy rozdzielone o ≥2σ).

**Luka domenowa.** Goły manekin ≠ malarska ilustracja. Dlatego drugi zbiór: sprite'y/obrazy, które człowiek już ocenił jako „dobry kąt” i „zły kąt” (kurtka 0,60 zatwierdzona, 0,36 „zbyt frontalnie”, przestrzelone próby ze wzorem MPFB). Sprawdzić, czy próg wyznaczony na MPFB rozdziela te dwie grupy; jeśli nie, dostroić próg na grupie człowieka (to jest ostateczny sędzia) **[wniosek]**.

**Powtarzalność (rozrzut).**
1. Ten sam obraz × N=10 deterministycznych zakłóceń: przesunięcie/skala ±5%, inny margines kadru, odbicie lustrzane (azymut ma się odbić symetrycznie), ±1-2° rotacji, różne tło (jednolite vs alfa). Rozrzut = odchylenie standardowe surowego polaru. Cel: σ < ½ odległości 0,36-0,60 po przeliczeniu **[wniosek]**.
2. Test-time augmentation z repo V1 (`get_3angle_infer_aug`, `get_crop_images`) jako metoda zmniejszenia rozrzutu **[repo]**.
3. Korelacja rang (Spearman) z mocą LoRA na serii `przod_a*`: oczekiwana silnie dodatnia.
4. Dla azymutu: profil prawdziwy ma azymut ±90° ±10°; tył 180° ±10° (kryterium ticketu). Zmierzyć na MPFB `postac_bok` / `postac_tyl` i na zatwierdzonych `bok_s9000`.

**Czy mierzyć pochylenie inaczej, wprost geometrycznie?** Ilustracja 2D po rozciągnięciu 1/cos zachowuje wysokości; kąt widać tylko w skrócie podstawy i wierzchów (stopy, głowa). Tą drogą poszło `kat.gd` i zawiodło (nogawka zasłania but, perspektywa Qwen) **[ticket 20]**. Rozważana alternatywa: stosunki odległości z keypointów DWPose (np. wysokość głowy i długość stopy względem szerokości barków) jako cechy do regresji z sweepu MPFB. Tani dodatek do próby (D), ale nie spodziewam się, że da pewność na ilustracji **[wniosek]**.

## 5. Rekomendacja (ranking)

1. **Orient Anything V1 Large (A)**: najtańszy start (małe wagi, CC-BY-4.0, trenowany na renderach). Pomiar: azymut do zatwierdzania widoku (przód/profil/tył), polar po kalibracji do porównania z wzorcem 0,60 (i 0,36). Raportować `(polar, azymut, pewność)`.
2. **Orient Anything V2 (B)**: tylko jeśli A ma za duży rozrzut (σ > połowy odstępu 0,36-0,60). Przed pobraniem 5 GB sprawdzić licencję wag (karta HF `Viglong/OriAnyV2_ckpt`); to jedyny punkt, gdzie nie mam potwierdzenia komercyjnej zgodności.
3. Zawsze w pętli, niezależnie od 1-2: **DINOv2 (C)** do tożsamości/stroju względem zatwierdzonego konceptu (cosinus cech kadru; próg z par „ta sama postać / inna postać” z `proby/`) oraz prosty test czystości profilu (D lub sylwetka: szerokość sylwetki profil vs przód z maski alfa **[wniosek]**).

## 6. Plan tanich prób (po zgodzie człowieka; kolejność od najtańszej)

| Krok | Co | Pobranie / koszt | Warunek |
|---|---|---|---|
| 0 | Sweep MPFB (Blender 5.2 headless, lokalnie, ok. 100-300 renderów, 0 zł) | brak | tylko modyfikacja skryptu Blendera |
| 1 | Osobny venv (`--system-site-packages`) i `pip install` pakietów Orient Anything V1 | rozmiar paczek **[brak]** (z `requirements.txt` repo, nieczytany) | zgoda na instalację |
| 2 | Wagi A: HF `Viglong/Orient-Anything` (Large, `croplargeEX2/dino_weight.pt`) | rozmiar **[brak]**; 305M par. fp32 ≈ 1,2 GB **[wniosek]** | zgoda na pobranie |
| 3 | DINOv2-B (HF `facebook/dinov2-base`, przez `transformers` z Comfy) | ok. 0,35 GB **[pamięć]** | zgoda |
| 4 | Pomiar sweepu MPFB + serii `kurtka_060` + zatwierdzonych sprite'ów; kalibracja, rozrzut (§4) | 0 zł, minuty | kroki 1-2 |
| 5 | (jeśli A zawodzi) wagi V2 5,05 GB + sprawdzenie licencji | 5,05 GB | wynik 4 + licencja |
| 6 | (opcjonalnie) DWPose ONNX (`dw-ll_ucoco_384.onnx` + `yolox_l.onnx`) i `onnxruntime` | rozmiary **[brak]** | wynik 4 |

Kryterium sukcesu próby: na sweepie MPFB błąd po kalibracji < 0,05 df, na zatwierdzonych/odrzuconych obrazach człowieka rozdzielenie ≥ 90% par, rozrzut < 0,03 df. Progi są **[wniosek]**, do korekty po kroku 4.

## 7. Szkic nocnej pętli generuj → mierz → trzymaj 3 na widok

```
dla widoku w [przód, bok, tył]:
  kandydaci = []
  siatka = {siła LoRA: 1.0..1.7 co 0.1} x {seed}      # siła LoRA nie jest przenośna między wejściami (ticket 12)
  dopóki len(kandydaci) < 3 i budżet czasu:
    wybierz (siła, seed)  # bandyta: częściej siły z najmniejszym |df - 0.60|
    qwen_kat.mjs (ComfyUI API, ~115 s)   # bok: --pose shots/mpfb_060/postac_bok.png
    zakończ proces generacji, zwolnij VRAM
    pomiar.py: kadr po masce alfa -> A (azymut, polar, pewność), D (opcjonalnie), DINOv2 cosinus do konceptu
    zapisz wiersz w log.jsonl {plik, siła, seed, az, polar, df_est, sim, ocena}
    przyjmij gdy: |df_est - 0.60| < tol  AND  |az - az_cel| < 10°  AND  pewność > próg AND  sim > próg_tożsamości
                  AND  (bok) sylwetka czysto z boku  AND  brak resztek cienia (maska)
    jeśli przyjęty: skopiuj do proby/<seria>/kandydaci/<widok>_<nr>.png
```

- Przepustowość: 8 h × 3600 / 115 s ≈ 250 obrazów **[wniosek]**, pomiar dodaje sekundy. Przy trafności choćby 10% to ok. 8 przyjętych na widok.
- Lepiej mierzyć wsadowo po każdym zadaniu niż w tym samym procesie co Qwen (VRAM).
- Człowiek zawsze wybiera ostateczne 1 z 3 w Poligonie (reguła z `judge-in-game`); pętla tylko filtruje. Zapisywać także odrzucone (log) do dostrojenia progu.
- Jeśli po 30-40 próbach żadna nie przechodzi kąta, pętla ma zatrzymać się i zgłosić (zmiana sposobu referencji, nie kolejne seedy).

## Luki w źródłach do rozstrzygnięcia próbą

- Definicja polaru i błąd polaru osobno w Orient Anything (paper V1 pełny tekst nieczytany; abstrakt bez liczb).
- Zachowanie A/B na malarskich postaciach ludzkich: brak danych.
- Licencja wag Orient Anything V2 oraz Perspective Fields; licencja Multi-HMR (tekst niepodany na stronie).
- Rozmiary plików wag A i lista zależności `requirements.txt`.
