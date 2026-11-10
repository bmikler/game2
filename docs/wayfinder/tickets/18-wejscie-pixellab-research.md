---
id: 18
title: Jakie wejście daje najlepszą postać w Pixellab
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

W jakiej formie podawać przykład (koncept) do Pixellab, żeby postać 72 px w niskim 3/4 wyszła czytelna i dorosła? Pierwsza próba w Przepisie postaci (realistyczny, prawie monochromatyczny koncept z FLUX.2 klein → `image-to-pixelart` faithful, siła 200, 80×80) wyszła słabo; w game1 rysunkowy koncept (kontur, płaskie plamy, kontrast kolorów ubrania) dał dobry wynik (`repo/game1/art/concept/characters/badacz/badacz-gora-a-7003.png`). Do ustalenia: styl wejścia (zdjęcie / ilustracja / cel-shading / kontur, kontrast i liczba kolorów), rozdzielczość i proporcja wejścia względem wyjścia, które endpointy (`image-to-pixelart` normal / faithful / pro, `create-character-v3` z referencją bezpośrednio, `correct-pixelart`, style reference), parametry (`init_image_strength`, `text_guidance_scale`, opis), oraz co robić lokalnie przed wysłaniem (posteryzacja, downscale, kontur). Źródła: oficjalna dokumentacja i OpenAPI Pixellab, blog/Discord/przykłady twórców, game1. Wynik: `docs/research/70-*.md` z rekomendacją łańcucha i listą tanich prób (koszt w generacjach).

## Resolution

Zrobione 2026-11-08 (`docs/research/70-wejscie-pixellab.md`). Pixellab nie publikuje zaleceń co do stylu wejścia; tryb faithful odtwarza wejście, łącznie z kamerą i proporcjami. Słaby wynik to wina wejścia: miękki, fotograficzny, prawie monochromatyczny koncept z mocną perspektywą (krępa postać). Wejście (średnia pewność, z game1): ilustracja z czystym ciemnym konturem, płaskie plamy, ≥5 wyraźnie różnych kolorów ubrania, płaskie tło bez cienia, docelowa kamera i 7 głów już w koncepcie, postać ~90% płótna; 320→80 (4:1) lub 256→80. `create-character-v3` z referencją ignoruje `outline`/`detail`, jakość ustala się przed v3. Koszty: image-to-pixelart 1 gen., v3 80×80 1 gen., 96×96 2 gen., pro-flash 6, create-character-pro 10–25. Luka: brak źródeł społeczności o stylu wejścia.
