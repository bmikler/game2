---
id: 19
title: Jak sensownie wygenerować animację chodu postaci pixel art
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Mamy sprite postaci 72 px (detektyw w długim płaszczu, niskie 3/4 oblique, kąt 0,60; 3 widoki: przód, bok-profil, tył + lustro), zrobiony lokalnie: malarski koncept FLUX.2 klein → Qwen-Image-Edit-2511 + LoRA Multiple Angles (kąt kamery) → pikselizacja Lanczos do 72 px. Jak z tego sensownie zrobić animację chodu (idle, chód 6–8 klatek na kierunek) spójną z wyglądem sprite'a?

Pierwsza próba (ocena człowieka: „dramat”): 8 klatek osobno w Qwen-Image-Edit, image1 = koncept, image2 = render manekina MPFB w pozie chodu (proceduralnie w Blenderze); postać spójna, ale poza nóg słabo przeniesiona, krok prawie niewidoczny pod płaszczem, klatki niezależne (brak ciągłości).

Do ustalenia (źródła pierwotne: dokumentacja, repo modeli i węzłów ComfyUI, artykuły twórców, Pixellab docs/OpenAPI):
1. **Lokalnie (8 GB VRAM, licencja komercyjna, Steam):** wideo z obrazu (Wan 2.1/2.2 I2V, VACE z pozą/OpenPose, LTX-Video, AnimateDiff + ControlNet), generacja całego arkusza klatek naraz (sprite sheet w jednym obrazie / siatka), Qwen-Image-Edit z ControlNet pozy (DWPose/OpenPose) zamiast obrazu manekina, LoRA do sprite sheetów; co realnie chodzi na RTX 4060 Laptop 8 GB i ile trwa.
2. **Klasyczne/hybrydowe bez AI per klatka:** rig 2D (cut-out, Spine/DragonBones/Godot Skeleton2D) z pociętego sprite'a, 3D (MPFB + ubranie/proxy płaszcza, tekstura z konceptu) → render klatek → pikselizacja; jak robią to twórcy pixel artu przy 64–96 px (np. Dead Cells 3D→pixel, inni).
3. **Pixellab:** `animate-with-skeleton-v3`, `animate-with-text-v3`, szablony chodu dla własnego sprite'a; koszt w generacjach (v3), rozmiary, ile kierunków, czy trzyma nasz styl; przykłady wyników.
4. Długi płaszcz: jak animacje radzą sobie z ubraniem zakrywającym nogi (ruch poły płaszcza, kroki krótsze, bob).

Wynik: `docs/research/71-animacja-chodu.md`: porównanie dróg (jakość, spójność, koszt czasu i pieniędzy, sterowanie skryptem, licencja), rekomendacja 1–2 dróg do próby z listą tanich prób.

## Resolution

Zrobione 2026-11-08 (`docs/research/71-animacja-chodu.md`). Pierwsza próba padła, bo Qwen-Image-Edit robi każdą klatkę osobno (brak ciągłości), a manekin bez płaszcza każe zgadywać nogi. Lokalne wideo (Wan 2.2 TI2V 5B, Apache 2.0, mieści się w 8 GB) daje 24 fps z kamerą, bez kontroli klatek i pętli; VACE/LTX niepotwierdzone (pamięć, licencja LTX); LoRA arkuszy klatek bez pomiarów spójności; lokalnie brak modeli i węzłów wideo (pobranie za zgodą). Pixellab na własnym sprite'cie (OpenAPI): `animate-pixminimax` 80×80/8 kl. = 1 gen., `animate-with-text-v3` 1–2 gen., `animate-with-skeleton-v3` 8 kl. = 3 gen. (keypoints z MPFB), `estimate-skeleton` 0,1; zachowanie stylu nieudokumentowane. Długi płaszcz: chód czytelny przez krótki krok, opóźnioną połę i bob. Rekomendacja: (1) próba Pixellab na boku, ~5–6 gen. za zgodą; (2) równolegle cut-out 2D w Godot (0 zł, piksele identyczne, ~4–6 h) jako droga pewna.
