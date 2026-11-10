> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/48-pipeline-mebli-blender.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

---
id: 48
title: Pipeline mebli z brył w Blenderze
labels: [wayfinder:prototype]
status: closed
assignee:
blocked_by: [46]
---

## Question

Czy droga A z Generowania mebli w spójnym rzucie 3/4 daje meble spójne z postaciami i z zaakceptowaną ladą? Skrypt Blendera (portable w `game1/tools/blender/`, instalacja za zgodą człowieka) buduje bryłę mebla z JSON (wymiary w m, części: blat, front, szuflady, cokół, uchwyty), `blender --background` renderuje w rzucie gry (kamera ortogonalna 45° + rozciągnięcie √2) albedo, maskę i normal mapę, potem obecna pikselizacja (STYLE.md, „Meble i obiekty”); wariant z img2img FLUX.2 klein (denoise 0,25 / 0,4 / 0,55) dla malarskiej faktury. Eksperyment na ladzie Krogga (4,8 × 0,6 × 1,05 m) i szafce na akta (0,55 × 0,6 × 1,35 m) obok obecnej lady, na arkuszu ×4 z `art/concept/_style/pixel_ref.png` i w grze pod światłem. Do ustalenia też: tekstury wierzchów ścian, okien w ścianach bocznych i przednich oraz kraty (ComfyUI, płaskie, bez problemu rzutu), komputer na ladzie tyłem monitora do kamery, kaloryfer pasujący pod okno tylne 1,35 m (osobny obiekt). Wynik: przepis na meble do Pipeline'u tworzenia wnętrz i lista mebli posterunku do wygenerowania.

## Poza zakresem (2026-11-01)

Decyzja człowieka: pominięte. Pierwsza wersja używa mebli, które już mamy (Pixellab lub wygenerowane przez nas), bez Blendera.
