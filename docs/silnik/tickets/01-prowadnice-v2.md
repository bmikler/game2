---
id: 01
title: Prowadnice v2
labels: [ready-for-agent]
status: open
assignee:
blocked_by: []
---

Spec: `docs/silnik/spec.md`. Słownik: `GLOSSARY.md`. Narzędzie, nie kod silnika.

## Co zbudować

Z jednej sceny Blendera z meblem powstaje komplet zgodny co do piksela: prowadnice dla ComfyUI (depth w rzucie 0,60, 40 px/m), maska sylwetki, mapa normalnych, uproszczone Bryły (osobna kolekcja, prostsza od modelu do prowadnic) z eksportem w metrach i punkt zaczepienia (środek przedniej dolnej krawędzi) policzony z kamery. Płótno w wielokrotności siatki pikseli, wyrównane do punktu zaczepienia.

## Kryteria akceptacji

- [ ] Rozbudowa istniejącego skryptu prowadnic z Blendera (bez nowego narzędzia obok).
- [ ] Dla trzech mebli testowych: lada (pudełko), stół z nogami (uniesione pudełko), kanapa lub fotel (kształt zaokrąglony): prowadnice, maska, normalne, Bryły, punkt zaczepienia.
- [ ] Nakładka kontrolna (PNG): kontur Brył w rzucie na masce; widać, że się zgadzają.
- [ ] Prowadnice w postaci, którą przyjmują drogi z Przepisu postaci (Qwen-Image-Edit: szary render w kącie gry na jasnoszarym tle, jak manekin MPFB; plus depth dla ControlNet), żeby meble mogły iść tym samym stylem co postacie.
- [ ] Bez generacji obrazów w tym tickecie.

## Jak sprawdzić

Obejrzyj nakładki kontrolne trzech mebli: kontur Brył leży na sylwetce, normalne mają sensowne kolory (wierzch, front, bok).
