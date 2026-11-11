---
id: 37
title: Stylizacja cieni i światła w pixel arcie
labels: [wayfinder:prototype]
status: open
assignee: claude
blocked_by: [36]
---

## Question

Jak narysować poprawnie policzone, miękkie światło i cienie (bufor z ticketu [36](36-przebudowa-swiatla-jeden-bufor.md)) tak, żeby wyglądały jak pixel art (kilka poziomów, dither tym samym wzorem co w grze, bez rozmytych gradientów i losowego ziarna), a przy tym nie psuły cieni: bez krótkiego cienia przy oknie i długiego dalej, bez przypadkowych konturów daleko od postaci, bez kilku twardych cieni naraz z różnych źródeł?

Co nie działało (ticket 36): próg na udziale cienia **osobno dla każdego źródła** (każde okno, każda lampa). Postać przy dużym oknie zasłania 35–60% okna z prawie całego pokoju, czyli wokół progu 50%, więc próg rysował kontury w przypadkowych miejscach; każde źródło dawało osobny twardy cień.

Kierunki do sprawdzenia (warianty w F1, ocena na żywo w Poligonie Dom, w wyglądzie gładkim jako odniesieniu):
- poziomy z **całego światła piksela** (suma źródeł), nie z udziału każdego źródła;
- niebo z okien tylko jako miękki cień kontaktowy (krótki, pod postacią i meblami), twarde poziomy tylko od słońca i lamp;
- kwantyzacja jasności (posteryzacja z ditherem) zamiast cienia;
- inne, jeśli research znajdzie (najpierw krótki research, jak gry pixel art stylizują miękkie światło i cienie: Eastward, REPLACED, NORCO, Kotwice z ticketu 08).

Wymagania: ten sam wygląd dla postaci i mebli; plamy i smugi okien w tym samym języku co cienie (spójny język świateł i cieni); działa także na ulicy (ten sam mechanizm). Parametry stylizacji (poziomy, progi, wzór ditheru, szerokość pasa ditheru) jako pokrętła dla krytyka ([38](38-krytyk-strojenia-swiatla.md)).

Bramka (Claude sprawdza sam, zanim pokaże): postać przy oknie tylnym, bocznym i w drzwiach wejściowych, 1 m i 2 m od okna, przy lampie; brak przeskoków i konturów daleko od postaci; postać i pudełko tej samej wielkości dają ten sam obraz; w ruchu bez migotania i szwów.

Decyzja człowieka: sposób stylizacji (jeden wariant do strojenia).
