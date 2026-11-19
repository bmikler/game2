---
id: 17
title: Postać i jej cień
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [09, 13]
---

## Co zbudować

Chodząca postać jako ruchoma Przesłona (walec): cień od wszystkich Źródeł, cień kontaktowy, zasłanianie nieba wzorem. Liczone co klatkę w oknie wokół postaci i dla Źródeł w zasięgu; cień mnoży gotowe warstwy. Postać oświetlona jak Odbiornik bryłowy co klatkę (modelowanie, kontrświatło), z mapą normalnych, jeśli jest.

## Kryteria akceptacji

- [ ] Flaga „ruchoma”, ścieżka ruchomych w Opisie sceny (testy).
- [ ] Sterowanie postacią w Poligonie (Input Map), poza addonem.
- [ ] Ten sam Stan doby dla okna postaci i reszty Bufora.
- [ ] Bramka: cień ruchomej Bryły = cień tej samej Bryły nieruchomej.
- [ ] Okno liczone tylko w kadrze.

## Jak sprawdzić

Sklep o 22:00: przejdź między latarniami, kilka cieni obraca się i wydłuża, bok postaci jaśniejszy od latarni. W południe jeden cień i ciemniejsza plamka pod stopami.

## Plan (2026-11-18, czeka na „ruszamy” człowieka)

Pomysł człowieka: zamiast walca uproszczona bryła postaci z klatek jej animacji chodu, żeby cień miał osobne nogi i
krok, a podłoga między nogami nie ciemniała (wada walca z wayfindera 33; płaska sylwetka odpadła tam, bo przy lampie
wyglądała dziwnie). **Najpierw próba, potem decyzja:** bryła z sylwetki to wariant do porównania z walcem na żywo w F1;
spec (kontrakt assetu, rodzaje Brył) zmieniamy dopiero, gdy człowiek ją przyjmie. Gałąź z `main`.

1. **Ruchoma Przesłona z walcem** (zakres ticketu jak wyżej): flaga „ruchoma” i ścieżka ruchomych w Opisie sceny,
   okno wokół postaci liczone co klatkę dla Źródeł w zasięgu, cień mnoży gotowe warstwy, plamka kontaktowa, niebo
   wzorem analitycznym, postać jako Odbiornik bryłowy, sterowanie w Poligonie (Input Map). Bramka: cień ruchomej
   Bryły = cień tej samej Bryły nieruchomej.
2. **Narzędzie „bryła z sylwetki”** (offline, 0 zł, bez nowych generacji): z każdej klatki chodu
   (`proby/pixellab_chod_D`, przód / bok / tył) po rzędach pikseli odcinki sylwetki (w rzucie 0,60 przeliczone na
   wysokość w metrach); grubość w drugą stronę z sylwetki stania z widoku prostopadłego; każdy odcinek = eliptyczny
   plaster. Wynik: stos plastrów na klatkę jako dane assetu (Resource), nie kod.
3. **Próbny rodzaj Bryły w silniku**: stos plastrów z numerem klatki zmienianym z animacją; ta sama funkcja widoczności
   dla słońca, lamp i okien. Ta sama bryła daje pozycję pikseli postaci przy oświetlaniu jej samej (nogi na właściwej
   głębi). Niebo i plamka kontaktowa zostają na obrysie (miękkie, szczegół nóg i tak znika).
4. **Porównanie w F1**: przełącznik kształtu cienia walec / bryła z sylwetki. Ocena człowieka na żywo: Sklep 22:00
   (kilka latarni), południe (słońce 30°, długi cień z krokiem), chód bokiem i do kamery.
5. **Po ocenie**: przyjęta → dopisanie „bryły z sylwetki” do spec jako reguły ogólnej dla każdej ruchomej postaci
   (NPC, zwierzę), walec zostaje jako Bryła ogólna; odrzucona → zostaje walec, narzędzie i kod próby usunięte.

Znane ograniczenie: przy chodzie do kamery / od kamery krok jest w głąb ekranu, sylwetka przodu go nie pokazuje, więc
cień z boku pokaże nogi obok siebie, nie krok. Wydajność (8 postaci na Skwerze) dopiero w tickecie 19.
