---
id: 24
title: Jak pokazać wchodzenie po schodach i progach w rzucie 3/4
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Na Poligonie Ulica w bryłach gracz wchodzi na taras po schodach tak, jakby szedł po płaskim terenie; człowiek to odrzucił. Jak gry 2D pixel art w rzucie z góry / 3/4 / oblique pokazują wchodzenie i schodzenie po schodach, stopniach, progu drzwi, tarasach i krawędziach? Katalog technik (przesunięcie sprite'a o stopień, zmiana prędkości, osobna animacja lub poza, schody ukośne, zasłanianie balustradą, cień, kamera, dźwięk, systemy poziomów wysokości), w jakich grach, koszt dla nas (kod czy dodatkowe klatki animacji na postać), ryzyka. Wynik: notatka w `docs/research/77-schody-zmiana-poziomu.md` i 2–3 warianty do prototypu na Poligonie Ulica (schody w murku tarasu, jeden stopień przed drzwiami) z liczbami.

## Resolution

Notatka: `docs/research/77-schody-zmiana-poziomu.md`. Pewność średnia do niskiej: brak devlogów gier z listy (Eastward, Stardew, Sea of Stars…); twarde źródła to dokumentacja Solarus i Godot, RPG Maker, CrossCode (wysokości), GDevelop, analiza Pokémon gen 1–3 (wtórna). Gry z listy człowiek może obejrzeć sam przed zatwierdzeniem.

- Dziś gracz jedzie 48 px w górę po namalowanych stopniach: to ruch po płaskim z przemalowanym tłem.
- Fundament: pozycja logiczna (kolizja, sortowanie) osobno od pionowego przesunięcia sprite'a.
- Bez nowych klatek: przesunięcie schodkowe (8 px = 0,2 m na stopień), wolniejszy chód (×0,6 w górę, ×0,7 w dół), cień na stopniu, dźwięk kroku, policzki/balustrada, wygładzenie kamery. Osobna poza wspinaczki (klatki Pixellab) zbędna na tym etapie.
- W Godot: nie zmieniać z_index gracza na schodach (psuje sortowanie).
- Schody boczne: przemapowanie wejścia (lewo/prawo → wzdłuż biegu, 1:2).
- Warianty do Poligonu: A schody czołowe z biegiem 1,8 m, B schody boczne wzdłuż muru, C próg drzwi 1 stopień z mikro-podskokiem (6 px, ~0,12 s); opcjonalnie D zeskok z tarasu.
