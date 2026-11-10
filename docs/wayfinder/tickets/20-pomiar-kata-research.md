---
id: 20
title: Automatyczny pomiar kąta kamery i obrotu postaci na wygenerowanym obrazie
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Generujemy widoki postaci (przód, profil, tył) w Qwen-Image-Edit-2511 + LoRA Multiple Angles i potrzebujemy **pewnego, automatycznego** sprawdzenia, czy kamera ma kąt gry (niskie 3/4 oblique, depth_factor 0,60 ≈ 31° pochylenia, wzorzec: render MPFB w Blenderze, `tools/blender/postac_mpfb.py`, `kalibracja_kata.py`) i czy postać jest obrócona dokładnie przodem / profilem / tyłem. Cel: skrypt „brute force” na noc: ComfyUI generuje kolejne seedy/siły LoRA, skrypt ocenia każdy obraz i zatrzymuje się, gdy ma 3 dobre opcje każdego widoku.

Dotychczas (ticket „Przepis postaci”): ocena na oko zawiodła; pomiar wysokości butów względem wzrostu (kalibracja na manekinie z butami-prostopadłościanami) nie działa, bo widoczna wysokość buta zależy od nogawki, a „podniesienie kamery” w Qwen działa jak perspektywa (skraca nogi, powiększa głowę), nie jak nasz rzut oblique.

Do ustalenia (źródła pierwotne: model cards, repozytoria, artykuły):
1. Modele szacujące orientację/kamerę z jednego obrazu: Orient Anything (V1/V2: azymut, kąt polarny), estymacja kamery (np. VGGT, DUSt3R/MASt3R, GeoCalib, Perspective Fields), 3D człowieka z obrazu (HMR 2.0 / 4DHumans, TokenHMR, SMPLer-X, Multi-HMR: SMPL + kamera), keypointy 2D (DWPose/RTMPose) porównane z rzutem keypointów MPFB w różnych kątach, głębia/normalne (Depth Anything V2, Marigold, Metric3D) → płaszczyzna podłoża; podobieństwo cech (DINOv2/CLIP) do renderów referencyjnych w znanych kątach.
2. Dla każdego: dokładność kąta polarnego i azymutu (stopnie), działanie na ilustracjach/stylizowanych postaciach (nie zdjęciach), VRAM (RTX 4060 Laptop 8 GB) i czas na obraz, licencja wag i kodu (komercyjny Steam, UE), jak uruchomić lokalnie na Windows: węzeł ComfyUI albo Python (systemowego Pythona brak; ComfyUI Desktop ma własne środowisko Python — czy można w nim instalować paczki).
3. Kalibracja: jak przełożyć wynik (np. kąt polarny ze zdjęcia perspektywicznego) na nasz kąt gry, używając renderów MPFB w znanych kątach jako zbioru kalibracyjnego; jak sprawdzić powtarzalność (rozrzut).
4. Szkic pętli: generacja (ComfyUI API, istniejący `tools/postac/qwen_kat.mjs`) → pomiar → kryterium (np. |kąt − 0,60| < tolerancja i azymut w ±10°) → zapis kandydatów; co jeszcze sprawdzać automatycznie (tożsamość/strój względem konceptu, np. DINOv2/CLIP podobieństwo; czysty profil).

Wynik: `docs/research/72-pomiar-kata.md`: ranking metod z liczbami (dokładność, VRAM, czas, licencja), rekomendacja 1–2 metod do próby, plan tanich prób (bez pobierania przed zgodą człowieka; lista plików do pobrania z rozmiarami).

## Resolution

Zrobione 2026-11-08 (`docs/research/72-pomiar-kata.md`). Rekomendacja: Orient Anything V1 Large (azymut + kąt polarny, trening na 2 mln renderów 3D, CC-BY-4.0, 305M parametrów, mieści się w 8 GB jako osobny proces po Qwen); V2 (5 GB, VGGT 1,2B) tylko gdy V1 za bardzo się rozrzuca, licencja wag do sprawdzenia. Błędy medianowe na zdjęciach 13–77°, więc obowiązkowa kalibracja na renderach MPFB w znanych kątach i na sprite'ach zatwierdzonych/odrzuconych przez człowieka. Pomocniczo w pętli: DINOv2 (tożsamość/strój względem konceptu), opcjonalnie DWPose (przód/profil/tył). Odpadają: metody SMPL (HMR2, TokenHMR, SMPLer-X, Multi-HMR; SMPL niekomercyjny), GeoCalib/Perspective Fields/VGGT/DUSt3R (horyzont lub wiele widoków), Depth Anything V2 (brak kąta, Base/Large niekomercyjne). Środowisko: ComfyUI `.venv` Python 3.13 + torch 2.12 cu130 + transformers; osobny venv z `--system-site-packages`; brak węzła ComfyUI dla Orient Anything. Pętla nocna ~250 obrazów / 8 h.
