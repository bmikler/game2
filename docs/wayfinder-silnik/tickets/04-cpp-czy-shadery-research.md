---
id: 04
title: C++ (GDExtension) czy shadery i GDScript dla Silnika światła
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Gdzie leży koszt w silniku takim jak obecny `style-lab/lighting/` (bufor światła liczony shaderem na GPU, przeliczanie pasów i okna wokół postaci, dane sceny przygotowywane w GDScript) i czy przeniesienie części do C++ (GDExtension, Godot 4.7) realnie pomoże utrzymać >60 fps przy wszystkich źródłach naraz i dużych Lokacjach? Co zostaje na GPU niezależnie od języka, co liczy CPU, jaki jest koszt GDExtension (budowanie na Windows, utrzymanie, przenośność), jakie są alternatywy (compute shadery, RenderingDevice)? Zmierzyć lub oszacować na obecnym kodzie (`--bench=godzina [--ruch]`), nie tylko z dokumentacji.

Model: Opus. Wynik: `docs/research/88-*.md`.

## Resolution

2026-11-15. Research: `docs/research/88-cpp-czy-shadery.md` (Opus, pomiary na RTX 4060 Laptop, Godot 4.7.2; rozrzut między przebiegami do ok. 2×, linki do dokumentacji podane z wiedzy, API sprawdzone w `--doctool`).

- **Koszt jest prawie cały na GPU**, w shaderze bufora: każdy piksel × każde źródło × 9–16 próbek × każde pudło (do 128). Wnętrze w ruchu: GPU bufora 9–14 ms (61–86 kl./s); ulica 0,4–1,6 ms; cały bufor co klatkę 17–24 ms (39–63 kl./s). Piksel wnętrza ok. 125 ns, ulicy 6–9 ns; okno postaci we wnętrzu obejmuje pół domu.
- **CPU:** głównie `_actor_window()`, ok. 1–1,5 ms we wnętrzu, liczone co klatkę także przy stojącej postaci. C++ dałby najwyżej ok. 1,5 ms i nie przyspiesza GPU.
- **Rekomendacja: bez GDExtension na teraz.** 60 fps zdobywać algorytmem: światło statyczne liczone osobno od cienia ruchomych przesłon (postać); przycinanie przesłon i źródeł per kafel (koszt piksela nie rośnie z liczbą pudeł w Lokacji); ewentualnie compute shader przez RenderingDevice z GDScriptu. C++ wraca tylko, gdy profil po tych zmianach pokaże >2 ms CPU w jednej funkcji (wymaga zgody na MSVC/SCons).
