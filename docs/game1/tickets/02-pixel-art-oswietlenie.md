> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/02-pixel-art-oswietlenie.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

---
id: 02
title: Pixel art z dynamicznym oświetleniem
labels: [wayfinder:research]
status: closed
assignee: claude-research
blocked_by: []
---

## Question

Jakie techniki dają pixel art z klimatycznym, dynamicznym oświetleniem (referencje: Replaced, Octopath Traveler/HD-2D, Soulbound, nastrój Disco Elysium i Fahrenheita, zima i noc), jak trudne jest każde dla początkującego i co wymaga od assetów? Rozważ m.in. 2D lights + normal mapy, sprite'y w scenie 3D (HD-2D), 3D renderowane do niskiej rozdzielczości z pixel shaderem, volumetryczne światło, mgła, śnieg, post-processing. Wskaż, jak każda technika wygląda w Godocie 4.

## Resolution

Trzy rodziny technik: światła 2D + normal mapy (natywne w Godocie, najłatwiejsze; wymaga normal map; światło liczone w rozdzielczości ekranu, więc potrzebny niskorozdzielczy viewport, by wyglądało pixel-artowo), HD-2D (sprite'y w scenie 3D; najbogatsze, ale trudne, pełnia efektów w Forward+) i 3D w niskiej rozdzielczości (inny styl, modele 3D zamiast sprite'ów).
Śnieg (cząsteczki), fałszywa mgła i post-processing to tanie dodatki do każdej z nich; wolumetryczna mgła tylko 3D i tylko Forward+.
Nie znaleziono zweryfikowanych źródeł pierwotnych o technice Octopath, Replaced i Soulbound (wywiad Epic za logowaniem).
Wstępna rekomendacja: światła 2D + niski viewport + dodatki, HD-2D jako opcja po decyzji o widoku i pipeline'ie assetów.

Szczegóły: docs/research/02-pixel-art-oswietlenie.md
