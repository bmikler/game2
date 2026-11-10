---
id: 46
title: Generowanie mebli w spójnym rzucie 3/4
labels: [wayfinder:research]
status: closed
assignee: bmikler
blocked_by: []
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/46-generowanie-mebli-3-4.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Jak lokalnie (RTX 4060 8 GB, ComfyUI) albo tanio generować meble i obiekty do wnętrz w jednym, stałym rzucie gry i w stylu spójnym z postaciami, bez ręcznego rysowania? Rzut: 3/4 z góry, ortogonalny, blat (szer. × głęb.) nad frontem (szer. × wys.) w skali 1:1, bez widocznych boków, 40 px/m (ADR 0002). Stan z Układu posterunku i mebli wycinka: FLUX.2 [klein] i FLUX 3 Klein z szarą bryłą jako referencją trzymają kształt tylko częściowo (perspektywa, obrócone bryły, „zabawkowy” wygląd), styl malarski z arkuszem Badacza jako referencją jest lepszy, ale kąt dalej pływa; Pixellab też dawał mieszane rzuty i ma za mało kredytów. Zbadać m.in.: ControlNet/depth/canny dla FLUX lub SDXL z wyrenderowaną bryłą, podejście 3D-first (model 3D z obrazu: Hunyuan3D, TRELLIS, Stable Fast 3D itp. → render w Blenderze kamerą ortogonalną pod kątem gry → pikselizacja; normal mapy z renderu), LoRA stylu/pixel artu, IP-Adapter, modele edycji (Qwen-Image-Edit, FLUX Kontext), Retro Diffusion i inne narzędzia pixel art. Wynik: 2–3 drogi z kosztem (czas, VRAM, pieniądze, trudność dla Claude sterującego przez CLI/API) i rekomendacja. Wyniki w `docs/research/46-generowanie-mebli-3-4.md`.

## Resolution

Wyniki: `docs/research/46-generowanie-mebli-3-4.md` (tagi zweryfikowane / z pamięci / wniosek).

- Przyczyna pływającego kąta: szara bryła jako referencja FLUX.2 klein jest tylko kontekstem, nie warunkiem przestrzennym; kształt trzeba zablokować renderem 3D, latentem startowym (img2img) albo ControlNetem.
- Rzut gry da się dokładnie odtworzyć w Blenderze: kamera ortogonalna pochylona o 45° i rozciągnięcie obrazu w pionie o √2 (blat i front 1:1, bez boków); wyprowadzenie w §2.
- **Rekomendacja, droga A:** skrypt Blendera (pisany przez Claude) buduje bryłę mebla z JSON, `blender --background` renderuje albedo, maskę i normal mapę w konwencji `normals.gd`, potem obecna pikselizacja; wariant A1 dodaje img2img FLUX.2 klein (denoise 0,25–0,55) dla malarskiej faktury, przycięty maską. 0 zł, wymiary co do piksela, prawdziwa normal mapa.
- Droga C (TRELLIS.2 / Pixal3D w ComfyUI) tylko dla obiektów nieskrzynkowych (krzesło, roślina, ekspres), do tego samego renderu; VRAM na 8 GB niepotwierdzony. Hunyuan3D odpada (licencja w UE).
- Droga B (ControlNet: Z-Image Turbo + Fun ControlNet Union albo SDXL + xinsir Union ProMax + LoRA pixel art) w rezerwie: trzyma układ, ale zmienia model i styl; dla klein 4B brak oficjalnego ControlNetu.
- Retro Diffusion Pro (0,18 USD/obraz, ~43 USD za ~60 obiektów) jako zapas stylu. LoRA stylu przedwczesna (BFL: min. 12 GB dla klein 4B, za mało własnych sprite'ów); wrócić po 15–30 zaakceptowanych assetach.
- Stan maszyny: RTX 4060 Laptop 8 GB, w ComfyUI tylko modele klein, brak ControlNet/LoRA; **Blender nie jest zainstalowany**.
- Pierwszy eksperyment (po instalacji Blendera, za zgodą człowieka): lada i szafka w A0 (render + pikselizacja) i A1 (img2img 0,25/0,4/0,55) obok obecnej lady, na arkuszu ×4 z `pixel_ref.png` i w Godot pod światłem; automatyczna kontrola wymiarów maski ±1 px.
