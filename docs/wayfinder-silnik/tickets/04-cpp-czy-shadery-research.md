---
id: 04
title: C++ (GDExtension) czy shadery i GDScript dla Silnika światła
labels: [wayfinder:research]
status: open
assignee: claude
blocked_by: []
---

## Question

Gdzie leży koszt w silniku takim jak obecny `style-lab/lighting/` (bufor światła liczony shaderem na GPU, przeliczanie pasów i okna wokół postaci, dane sceny przygotowywane w GDScript) i czy przeniesienie części do C++ (GDExtension, Godot 4.7) realnie pomoże utrzymać >60 fps przy wszystkich źródłach naraz i dużych Lokacjach? Co zostaje na GPU niezależnie od języka, co liczy CPU, jaki jest koszt GDExtension (budowanie na Windows, utrzymanie, przenośność), jakie są alternatywy (compute shadery, RenderingDevice)? Zmierzyć lub oszacować na obecnym kodzie (`--bench=godzina [--ruch]`), nie tylko z dokumentacji.

Model: Opus. Wynik: `docs/research/88-*.md`.
