> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/08-assety-ai.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

---
id: 08
title: Generowanie assetów pixel art przez AI
labels: [wayfinder:research]
status: closed
assignee: claude-research
blocked_by: []
---

## Question

Jakie narzędzia AI realnie generują użyteczny pixel art (sprite'y postaci z animacjami, kafelki, tła, portrety, normal mapy) ze spójnym stylem, jakie są workflowy (generowanie + ręczna poprawka, LoRA na własnym stylu) i ograniczenia, i jaki jest koszt? Dodatkowo: AI do muzyki ambient i SFX. Bez kwestii prawnych (są w osobnym tickecie).

## Resolution

Pixellab (chmura, rotacje 4/8 kierunków, animacje szkieletowe, tilesety, MCP) jest najbliżej potrzeb sprite'ów; Retro Diffusion w Aseprite (20-65 USD jednorazowo) nie robi animacji i wymaga GPU; LoRA na własnym stylu to Scenario od 45 USD/mies. (10-30 obrazów wzorcowych).
Normal mapy: brak wiarygodnego AI, Laigter (darmowy, GPL) generuje je z gotowych sprite'ów.
Audio: Stable Audio (otwarte wagi, lokalnie) do ambientu/SFX, Suno Pro 8 USD/mies. do utworów z wokalem; dynamiczna muzyka wymaga obróbki w silniku.
Luki: cennik Pixellab, limity płótna i spójność na próbce (trial). Wniosek: AI + ręczna poprawka w Aseprite jest realna.
Szczegóły: docs/research/08-assety-ai.md
