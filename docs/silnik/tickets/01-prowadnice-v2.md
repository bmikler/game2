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

- [x] Rozbudowa istniejącego skryptu prowadnic z Blendera (bez nowego narzędzia obok).
- [x] Dla trzech mebli testowych: lada (pudełko), stół z nogami (uniesione pudełko), kanapa lub fotel (kształt zaokrąglony): prowadnice, maska, normalne, Bryły, punkt zaczepienia.
- [x] Nakładka kontrolna (PNG): kontur Brył w rzucie na masce; widać, że się zgadzają.
- [x] Prowadnice w postaci, którą przyjmują drogi z Przepisu postaci (Qwen-Image-Edit: szary render w kącie gry na jasnoszarym tle, jak manekin MPFB; plus depth dla ControlNet), żeby meble mogły iść tym samym stylem co postacie.
- [x] Bez generacji obrazów w tym tickecie.

## Jak sprawdzić

Obejrzyj nakładki kontrolne trzech mebli: kontur Brył leży na sylwetce, normalne mają sensowne kolory (wierzch, front, bok).

## Wykonanie (2026-11-15, Claude)

- Skrypt: `style-lab/tools/blender/zestaw_testowy.py` (przebudowany; stare pozycje sześcian i manekiny z pudełek usunięte, manekin to dziś MPFB). Testy: `style-lab/tools/blender/test_zestaw_testowy.py` (uruchamiane w Blenderze, 9 testów).
- Uruchomienie z `style-lab/`: `"$B" -b -P tools/blender/zestaw_testowy.py -- --out shots/prowadnice_v2` (trzy meble testowe: lada, stol, fotel; sceny zapisane jako `<mebel>.blend`) albo `"$B" -b mebel.blend -P tools/blender/zestaw_testowy.py -- --out ...` dla własnej sceny z kolekcjami `Model` i `Bryly`.
- Rzut dokładny co do piksela: geometria ścinana (z += 0,6·y) i renderowana kamerą ortho z przodu zamiast rozciągania obrazu; przebiegi Workbench z płaskim atrybutem koloru (normalne, cieniowanie, głębia liczone z geometrii przed ścięciem), pośrednio EXR, PNG zapisywane z numpy.
- Rzut i siatka 40 px/m, prowadnice renderowane w 10 × 40 = 400 px/m (`--k`; ta sama skala co manekin MPFB w Przepisie postaci, generatory potrzebują ok. 1000 px), zmniejszenie ×1/10 trafia dokładnie w siatkę gry (`maska_gra`, `normalne_gra`). Płótno 96 px gry = 960 px (większe, gdy mebel się nie mieści), punkt zaczepienia na rogu piksela gry, sprawdzany rzutem kamery.
- Normalne świata: kolor = 128 + 127·(nx, nz, −ny), czyli R w prawo, G w górę (wierzch zielony), B do kamery (front niebieski).
- `bryly.json`: Bryły w metrach względem punktu zaczepienia (x w prawo, y w głąb, z w górę), typy `pudelko`, `uniesione` (spód nad podłogą), `walec` (własność obiektu `bryla = "walec"`); Bryły obrócone poza osie świata są odrzucane. Kontur w `kontrola.png` jest renderowany z `bryly.json`, więc sprawdza eksport.
- Zgodność sylwetki Brył z maską (IoU w px gry): lada 0,94, stół 0,92, fotel 0,89 (Bryły celowo uproszczone).
