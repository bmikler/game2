---
id: 03
title: Tanie ozdoby atmosfery w 2D: para, dym, wiatr, odblaski, TV, noc w mieście i poza nim
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Jak tanio (w produkcji i wydajności) zrobić w Godot 4 2D pixel art ozdoby budujące immersję: para z ust na mrozie, dym z papierosa i komina, drzewa i krzewy poruszane wiatrem (shader vs klatki), odblaski i refleksy na szybach budynków widzianych z zewnątrz, telewizor nocą oświetlający pokój (kilka ekranów, światło zależne od obrazu), kurz w smugach światła, padający śnieg, ślady na śniegu, latarnie i różnica nocnego światła w mieście i poza nim. Plus lista innych tanich ozdób z gier o podobnym klimacie. Dla każdej: technika (cząsteczki, shader, sprite), czy wymaga assetu z generatora, przykład z gry, ryzyko dla spójności pixel artu (obroty i skalowanie łamiące siatkę pikseli). Nie powtarzać `22c` i `31`. Wynik: `docs/research/62-*.md`.

## Resolution

Wszystkie ozdoby da się zrobić tanio bez assetów z generatora: cząsteczki 1–2 px (para, dym, śnieg), jeden wspólny globalny uniform wiatru, shader wiatru z kwantyzacją UV do teksela (CC0, kaeylos, wymaga Godot 4.5+) dla drzew, decale dla śladów, sprite'y addytywne zamiast świateł (limit 16 świateł na item), TV jako jedno światło z tablicą kolorów plus halo.
Największe ryzyko dla siatki pikseli to wolny ruch podpikselowy (para, dym): niski `fixed_fps`, `interpolate` off, bez obrotów i skalowania niecałkowitego.
Miasto vs poza miastem: profile `CanvasModulate` per strefa z płynnym przejściem, w mieście wiele małych ciepłych źródeł, poza nim ciemność i chłód.
Twórcy gier prawie nie opisują tych technik; przykłady „z gier" są niezweryfikowane (oznaczone w notatce).
Notatka: `docs/research/62-ozdoby-atmosfery.md`.
