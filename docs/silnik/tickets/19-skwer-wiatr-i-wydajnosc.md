---
id: 19
title: Skwer, wiatr i wydajność
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [16, 17, 18]
---

## Co zbudować

Odcinek Skwer: 8 chodzących postaci, samochód z reflektorami, 4 iglaki na wietrze. Wspólny wiatr Lokacji daje wychylenie Przesłon z polem wiatru. W F1 A (cień stały, kołysze się tylko sprite) / B (cień z koroną). Benchmark i bramka wydajności.

## Kryteria akceptacji

- [ ] Wychylenie od wiatru na Przesłonie, wiatr w Otoczeniu (bez kodu pod drzewa).
- [ ] Przełącznik A/B.
- [ ] `--bench=godzina [--ruch]`: ms GPU, ms CPU, czas wczytania.
- [ ] Bramka: ≤ 4 ms GPU, ≤ 1 ms CPU na RTX 4060 Laptop; wczytanie Poligonu Ulica ≤ 2 s. Jeśli nie mieści się: pomiar i decyzja (compute shader albo zostaje A), nie łatka.
- [ ] Ponad 60 fps na Skwerze.

## Jak sprawdzić

Skwer o 12:00 i 22:00: postacie chodzą, samochód jedzie, iglaki się kołyszą. Wybierz A albo B. Licznik klatek powyżej 60.
