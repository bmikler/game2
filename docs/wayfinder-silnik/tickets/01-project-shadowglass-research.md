---
id: 01
title: Cienie w pixel arcie w Project Shadowglass
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Jak „Project Shadowglass” liczy i rysuje światło i cienie w pixel arcie (model źródeł, przesłony, półcień, nakładanie wielu źródeł, stylizacja do pikseli, wydajność, narzędzia edytora), i które z tych rozwiązań da się przenieść do jednego Silnika światła game2 (rzut 0,60, 40 px/m, wnętrza i plener jednym kodem, stylizacja A′)? Najpierw ustalić, czym dokładnie jest projekt (gra, technologia, autor) i jakie są źródła pierwotne (devlogi, posty autora, kod, wideo).

Model: Opus. Wynik: `docs/research/85-*.md`.

## Resolution

2026-11-15. Research: `docs/research/85-project-shadowglass.md` (Opus).

- **Czym jest:** skradanka immersive sim FPP w 3D (Dominick John, Starhelm Studios, solo), na zmodyfikowanym Godocie z własnymi shaderami. To nie 2D pixel art z rzutem.
- **Technika nieopublikowana:** autor w wywiadzie 80.lv (19.05.2026) celowo nie ujawnił szczegółów; brak devlogu i kodu. Znane tylko ogólniki: point filtering, LUT-y, ograniczona paleta, twarde cienie, toon lighting, „stabilizacja pikseli” kamery 3D (nie dotyczy stałego rzutu 0,60).
- **Do przeniesienia nie ma algorytmu.** Zostają uwagi praktyczne: zły ambient przy ograniczonej palecie niszczy detal (kryterium dla siły nieba); domyślne krzywe zaniku zamazują nasadę cienia (zanik lamp jako krzywa w `.tres`); słońce skierowane w kamerę spłaszcza formę (taką godzinę dodać do trudnych scen w „Strategia testów i sceny testowe”).
- **Otwarte pytania dla „Jeden model światła i cienia dla wszystkich źródeł”:** czy mgła i atmosfera są bez kwantyzacji (stylizacja zależna od rodzaju składnika, nie od sceny); czy logika gry odczytuje poziom światła (jak w skradance).
