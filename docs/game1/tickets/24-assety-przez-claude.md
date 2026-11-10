---
id: 24
title: Assety pixel art bez ręcznego rysowania, sterowane przez Claude
labels: [wayfinder:research]
status: closed
assignee: claude-research
blocked_by: []
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/24-assety-przez-claude.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Jak solo dev bez doświadczenia w grafice i gamedevie może wyprodukować sprite'y w docelowej grafice (kafel 32 px, postać ok. 60 px, 4 kierunki, animacja chodu, normal mapy pod światła 2D Godota), sterując narzędziami przez Claude Code (MCP, API, CLI, skrypty) zamiast rysować ręcznie? Które ścieżki są realne na Windows 11 i ile kosztują?

Ścieżki do porównania:
- generatory pixel art z API/MCP (Pixellab MCP, Retro Diffusion API, inne);
- Blender sterowany przez MCP: modele 3D (z generatorów AI 3D lub gotowe), animacja (np. Mixamo), render do pixel art w 3/4 z natywnym passem normalnych;
- skrypty i CLI: Aseprite CLI/Lua, Laigter lub generowanie normal map skryptem, pixel art rysowany kodem przez Claude.

Doprecyzowanie człowieka: grafika jest ważna, nie chodzi o generyczne assety. Workflow to najpierw ideacja (concept arty z opisu i przesłanych obrazów referencyjnych, szukanie wyglądu), potem przekucie wybranego konceptu na spójne assety. Dlatego dochodzi czwarta ścieżka: generatory concept artu z API/MCP przyjmujące obrazy referencyjne, a wszystkie ścieżki oceniamy pod kątem wierności konceptowi.

Kryteria: wierność konceptowi, spójność stylu, normal mapy, animacja w 4 kierunkach, ile pracy ręcznej zostaje, koszt, setup na Windows z Claude Code.

Kontekst: zmienia założenie z ticketu Generowanie assetów pixel art przez AI („ręczna poprawka w Aseprite konieczna”); człowiek nie poprawi assetów ręcznie. Blokuje ticket Pipeline assetów pixel art z normal mapami.

## Resolution

Łańcuch bez ręcznego rysowania, sterowany przez Claude Code:
1. **Ideacja:** lokalne ComfyUI na RTX 4060 8 GB (portable, SDXL ~16 s/obraz), sterowane przez Claude skryptem Node po HTTP API; bez kosztów za obraz. Cena: setup (ticket Setup ComfyUI do ideacji sterowanej przez Claude), słabsza spójność niż modele chmurowe, licencja modelu do sprawdzenia (FLUX dev szara strefa). Midjourney odpada (brak API, zakaz automatyzacji). Zmiana z 2026-10-28: pierwotnie ideacja w chmurowym API płatnym za obraz; człowiek wybrał ComfyUI (ścieżka darmowa).
2. **Koncept → pixel asset:** Pixellab przez oficjalny MCP (http, token poza repo): postać z concept artu w dowolnej pozie do 8 kierunków, rotacja sprite'a do 4 kierunków, szablony walk/idle, referencja stylu dla mebli i kafli, ~60 px działa. $24/mies. przez 1–2 miesiące produkcji wycinka; trial za darmo. Zapas: Retro Diffusion MCP, przedpłata bez subskrypcji, ale gotowy chód 4 kier. tylko 48 px i bez normal map.
3. **Sprzątanie:** unfake-cli (exe na Windows) dopasowuje siatkę i wymusza paletę projektu; Aseprite CLI/Lua (kontur, arkusz + JSON) opcjonalnie. Automatyka tylko czyści pixel art, malarskiego konceptu nie zamieni w czytelną postać 60 px.
4. **Normal mapy:** Pixellab `create_normal_map` i Laigter dają normalne „poduszkowe” (front do widza, nie „na południe”); do porównania z własnym skryptem (maska blat/front + bump z alfy) w zatoce assetów.
5. **Blender (3D → pixel):** tylko plan B dla animowanych postaci (Meshy image-to-3D + Mixamo + skrypty headless, bez blender-mcp, który ma otwarte zgłoszenia bezpieczeństwa); do mebli i teł przerost. Hunyuan3D odpada licencyjnie w UE.

Steam: ujawniamy AI w assetach widocznych w grze; wewnętrzne concept arty prawdopodobnie nie. Nic nie było testowane na realnych assetach.

Szczegóły: docs/research/24a-generatory-mcp.md, 24b-blender-mcp.md, 24c-skrypty-i-cli.md, 24d-concept-art.md
