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

## Notatki z ticketu 17 (2026-11-19): co kosztuje i co można jeszcze zrobić

Pomiar: `--bench=godzina [--chod] [--npc] [--cien=walec] [--bez-postaci]` w Poligonie Ulica (kl./s bez vsync,
6 s po 2 s rozgrzewki; to jeszcze nie bench z kryteriów: bez rozbicia na GPU/CPU i bez czasu wczytania). Na
laptopie wyniki skaczą o kilka ms zależnie od zasilania; porównywać tylko w jednym przebiegu, na przemian z
punktem odniesienia (worktree ze starego commita).

- **Największy koszt to podstawa, nie postacie.** Bufor (słońce, niebo, kanały) i jego przebieg półcienia liczą
  się co klatkę na całym obszarze Lokacji (Ulica 4000×1708), także przy zatrzymanym czasie: `advance()` →
  `set_state()` → `_redraw()` każdą klatkę. Bez postaci: ok. 6,6 ms o 22:00 i 10,6 ms o 12:00 (w dzień drożej:
  promienie słońca i półcień). Kierunki: liczyć tylko kadr (+ margines półcienia), nie przeliczać, gdy Stan doby
  się nie zmienił, słońce rozłożyć na kilka klatek jak warstwy Źródeł.
- **Postacie (po ticket 17):** stojąca prawie nic nie kosztuje (okno ruchome przeliczane tylko przy zmianie), jedna
  idąca ok. +1,5–2,5 ms, trzy idące ok. +3,5 ms w dzień i +6 ms w nocy. W nocy najdroższe jest oświetlenie pikseli
  sprite'ów idących postaci (32 próbki każdego Źródła w zasięgu + 64 kierunki nieba, każdy promień po wszystkich
  Bryłach) i odejmowanie cienia na podłodze. Możliwe kroki: mniej próbek dla sprite'a ruchomego, pomijanie Źródeł,
  których udział w pikselu jest poniżej progu A′, siatka przyspieszająca Bryły (dziś każdy promień sprawdza każdą).
- **Uproszczone Bryły postaci (odłożone, decyzja człowieka 2026-11-19):** bryła z sylwetki kosztuje ok. 0,6 ms więcej
  niż walec (pętla po rzędach pikseli w `silhouette_span`). Gdyby silnik nie wyrabiał: stos z 1 elipsą na rząd,
  rzędy co 4–8 px (mniej obrotów pętli), albo kilka walców (nogi razem / tułów / głowa). Mechanizm już jest
  (`SilhouetteStack`, `MAX_SPANS`); trzeba dodać wysokość rzędu jako dane klatki (dziś 1 px, na stałe w
  `silhouette_span`) i warianty w F1 z licznikiem klatek.
