---
id: 02
title: Narzędzia, limity i koszty: lokalnie, triale, subskrypcja na Miesiąc produkcji
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Aktualizacja `docs/research/52-narzedzia-pixel-art.md` pod model kosztów game2. Najpierw darmowo lokalnie (RTX 4060 Laptop 8 GB, Comfy Desktop zainstalowany): które modele i LoRA pixel artu, FLUX.2 klein 4B, Qwen-Image-Edit-2511 (np. GGUF), ControlNet depth/normal i narzędzia pikselizacji mieszczą się w 8 GB i jakie mają licencje. Potem darmowe triale (Pixellab, Retro Diffusion, Scenario, inne): co dają za darmo, czy wymagają karty. Na końcu jedna subskrypcja ok. 100 zł/mies. na Miesiąc produkcji (maks. 2 miesiące): dla każdej limity generacji na miesiąc (ile postaci z animacjami, ile obiektów), API/MCP w tym planie, czy assety wolno używać po zakończeniu subskrypcji i komercyjnie, zakaz trenowania. Płatność za generację odpada. Gra prawdopodobnie wyjdzie na Steamie: dla każdego narzędzia i modelu (także lokalnych) jednoznacznie, czy wyniki wolno sprzedawać w grze, czy licencja nie wyłącza UE, i co wymaga ujawnienia AI wg aktualnych zasad Steama (start: `C:/Users/bartl/Desktop/repo/game1/docs/research/09-prawa.md`; sprawdzić aktualność). Narzędzie, które blokuje wydanie, odpada. Wynik: `docs/research/61-*.md` z tabelą „za darmo / na trialu / w Miesiącu produkcji” i rekomendowaną kolejnością testów. Ceny na dziś (2026-11).

## Resolution

Lokalnie (RTX 4060 8 GB + 32 GB RAM) bez blokady licencyjnej na Steam: FLUX.2 klein 4B i Qwen-Image-Edit-2511 GGUF (Apache 2.0, z offloadem, wolno), SDXL + ControlNet depth + pixel-art-xl, Blender + unfake. Odpadają FLUX.2 dev/klein 9B i Hunyuan3D 2.1. Triale: Pixellab (40 gen., bez karty), RD (20-50 kredytów, regulamin nieodczytany), Scenario (darmowy plan tylko do ewaluacji, nie do gry).
Na Miesiąc produkcji w budżecie ~100 zł mieści się tylko Pixellab Artisan (~24 USD, ceny wtórne) lub Scenario Starter; limity generacji na postać i to, czy API/MCP jest w planie, trzeba zmierzyć na koncie testowym przed zakupem.
Steam: ujawniać każdy asset AI trafiający do gry (także lokalny); narzędzia deweloperskie są poza ankietą. Pixellab: prawa do wyników u użytkownika, zakaz trenowania modeli na wynikach; Scenario self-serve może trenować na naszych treściach.
Szczegóły, tabela i kolejność testów: `docs/research/61-narzedzia-limity-koszty.md`.
