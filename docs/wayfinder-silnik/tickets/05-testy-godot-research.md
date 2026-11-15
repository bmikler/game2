---
id: 05
title: Testy w Godot 4.7 dla Silnika światła
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Którym narzędziem testować Silnik światła w Godot 4.7.2: GUT czy gdUnit4 (zgodność z 4.7, uruchamianie headless z linii poleceń na Windows, typowany GDScript, raporty, szybkość)? Jak testować shadery i bufory (render offscreen bez okna, odczyt tekstury, porównanie pikseli w ustalonych punktach jak `style-lab/tools/pomiar/bufor_roznica.mjs`)? Czy da się złożyć jedną komendę uruchamiającą wszystkie testy, wygodną dla skilla `/implement`?

Model: Sonnet. Wynik: `docs/research/89-*.md`.

## Resolution

2026-11-15. Research: `docs/research/89-testy-godot.md` (Sonnet, sprawdzone na Godot 4.7.2 w kopii poza repo).

- **Shadery nie testują się w `--headless`** (dummy renderer, `get_image()` zwraca null). Działa prawdziwe okno poza ekranem: `--resolution 64x64 --position -3000,-3000`, odczyt pikseli w ok. 2 s. Testy shaderów wymagają GPU.
- **Narzędzie:** GUT 9.7.1 (MIT, deklaruje zgodność z 4.7) w `style-lab/addons/gut/`, poza katalogiem silnika; alternatywy gdUnit4 6.2.x lub własny skrypt `extends SceneTree`. **Dodanie addonu wymaga zgody człowieka** (do potwierdzenia w „Strategia testów i sceny testowe”).
- **Jedna komenda:** `--path style-lab --resolution 64x64 --position -3000,-3000 -s addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit -gjunit_xml_file=...`; `-gselect=` do szybkiej pętli TDD; propozycja opakowania w `tools/test.mjs` razem z bramkami `.mjs`.
- **Niesprawdzone:** powtarzalność bajtów między uruchomieniami i GPU (bramki porównują bajt w bajt, więc pewnie potrzebna tolerancja), odczyt formatu RGBAH.
