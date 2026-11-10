---
id: 29
title: Rozdzielczość bazowa: 640×360 czy większa
labels: [wayfinder:prototype]
status: closed
assignee: bmikler
blocked_by: []
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/29-rozdzielczosc-bazowa.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Czy baza zostaje 640×360, czy rośnie w tej samej proporcji 16:9? Porównać obok siebie w prototypie (gałąź `prototype/oswietlenie`), z Kroggiem 75 px, skalą 1 m = 40 px i światłem, trzy bazy:

- 640×360: kadr ok. 16×9 m; skala całkowita 720p ×2, 1080p ×3, 1440p ×4, 4K ×6;
- 960×540: kadr ok. 24×13,5 m; 1080p ×2, 4K ×4, ale 1440p tylko ×2 z ramkami;
- 1280×720: kadr ok. 32×18 m; 1440p ×2, 4K ×3, ale 1080p (1,5) nie jest całkowite.

Udział ekranów w ankiecie Steama: 1080p ok. 55%, 1440p ok. 20%. Ocenić czytelność postaci i obiektów, klimat (ile świata i ciemności w kadrze) oraz zachowanie na 1080p i 1440p.

Wejście z ticketu Skala grafiki dla postaci ok. 75 px: skala świata, kafel 32 px, kamera w granicach Pomieszczenia i czarne pasy na ekranach innych niż 16:9 są ustalone niezależnie od bazy. Baza zmienia tylko pole kadru i współczynnik skalowania. Wynik zmienia ADR 0002.

## Postęp

**Prototyp (2026-10-28).** Gałąź `prototype/oswietlenie`, scena `prototype/lighting/res_compare.tscn` (`run_res.bat` albo `.\run.ps1 -Res`). Trzy miejsca w skali 1 m = 40 px: główna sala 12×7 m, pokój socjalny 5×4 m i ulica 40×14 m; Krogg 75 px z Pixellab jako postać gracza i NPC przy biurku; światła o promieniach w metrach. Klawisze: `R` baza, `O` rozmiar okna (do pełnego ekranu), `P` skalowanie (całkowite z pasami, ułamkowe najbliższe, ułamkowe wygładzone), `N` wieczór/dzień, `1/2/3` miejsce. Zrzuty: `shots/res/` (każda baza 1:1 oraz jak na 1080p i 1440p; 1280×720 na 1080p ułamkowo, 960×540 na 1440p ułamkowo).

Pierwsza obserwacja ze zrzutów: realistyczne wnętrza są mniejsze od kadru. Sala 12×7 m (480×400 px) przy 640×360 przewija się w pionie i ma pasy po bokach, przy 960×540 i 1280×720 stoi w całości otoczona czernią. Większa baza wymaga więc większych pomieszczeń albo przybliżenia kamery we wnętrzach.

## Resolution

- **Baza 960×540** (kadr ok. 24×13,5 m). 640×360 daje za mały wycinek świata przy postaci 75 px, 1280×720 za małą postać na 1080p (75 px przy ×1). Skala świata, kafel, kamera w granicach Pomieszczenia i czarne pasy poza 16:9 bez zmian (Skala grafiki dla postaci ok. 75 px).
- **Skalowanie:** 1080p ×2 i 4K ×4 całkowicie, pełnym ekranem. Domyślnie skala dopasowana do ekranu, więc 1440p to ×2,67, a 720p ×1,33, z lekko nierównymi pikselami. W Ustawieniach przełącznik „pixel perfect”: tylko skala całkowita z czarną ramką (1440p ×2, ramka 320/180 px).
- **Większe pomieszczenia:** wnętrza projektujemy tak, żeby w większości wypełniały kadr (np. główna sala ok. 18–20 × 9 m zamiast 12×7 m). Małe pokoje (socjalny, cela, archiwum) zostają małe i stoją na środku kadru w ciemności jako świadoma klaustrofobia. Bez przybliżania kamery (jedna skala pikseli w całej grze) i bez pokazywania sąsiednich Pomieszczeń.
- **UI natywnie:** interfejs (dialogi, Dziennik, menu, napisy) na osobnej warstwie w rozdzielczości ekranu, zwykłe czcionki; baza dotyczy tylko świata. Potwierdza ustalenie z Widoku kamery, poruszania i skali grafiki.

Prototyp: gałąź `prototype/oswietlenie`, `prototype/lighting/res_compare.tscn`, zrzuty `shots/res/`. ADR: docs/adr/0002-widok-3-4-i-drabinka-swiatla.md (zmiana bazy).
