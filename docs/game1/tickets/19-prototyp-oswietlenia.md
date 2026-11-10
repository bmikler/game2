> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/19-prototyp-oswietlenia.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

---
id: 19
title: Prototyp oświetlenia i efektu koszmaru
labels: [wayfinder:prototype]
status: closed
assignee: bmikler
blocked_by: [10, 11]
---

## Question

Czy szczeble 1 i 2 drabinki oświetlenia z ticketu Widok kamery, poruszanie i skala grafiki dają w widoku 3/4 klimat, który masz w głowie? Scena: nocna ulica w śniegu z latarnią, fasadą domu, drzewem i autem z włączonymi reflektorami oraz ciemny pokój oświetlany latarką Badacza (kafel 32 px, postać ok. 60 px, baza 640×360). Jeśli szczebel 2 wygląda za słabo, dodać próbkę szczebla 3 (sprite'y w scenie 3D z cieniami). Do tego jedno przejście w efekt koszmaru (zniekształcenie obrazu i światła).

Wejście z ticketu Model testów umiejętności:
- Test Poczytalności ma własną oprawę graficzną (np. zniekształcenie obrazu, przygaszone światło). Warto sprawdzić ją razem z efektem koszmaru.
- Kontur obiektów interaktywnych (1 px) nie może ginąć w ciemnych scenach. Sprawdzić go pod światłami 2D.

Wejście z ticketu Zmęczenie, sen i utrata przytomności:
- Efekty Stopni Zmęczenia w post-processie: lekka winieta i odbarwienie (Zmęczony), mocniejsza winieta z „mrugnięciami” (Wyczerpany), rozmycie przed omdleniem; natężenie regulowane. Sprawdzić, czy nie gryzą się z nocnym światłem.
- Kraina Piaskuna to nie Koszmar (sen Badacza). Ustalić jej nazwę (robocza: „Odbicie”) i wpisać do słownika.

Wejście z ticketu Zakres wycinka scenariusza: jedyna scena w docelowej grafice to wnętrze posterunku (5 pomieszczeń) ze zmianą światła dnia i nocy przez okna i jarzeniówkami w nocy. Warto sprawdzić w prototypie, czy próbka wnętrza w tym stylu daje oczekiwany klimat.

## Resolution

Prototyp: gałąź `prototype/oswietlenie` (worktree `game1-proto`), projekt `prototype/lighting/`, start przez `run.bat`. Grafika to placeholdery generowane w kodzie, więc ocena dotyczy techniki, nie rysunku. Zrzuty: `prototype/lighting/shots/` na tej gałęzi.

- **Wybór: szczebel 1.** Światła 2D z normal mapami w 640×360, CanvasModulate na porę dnia, glow (HDR 2D), śnieg z cząsteczek, mgła ze sprite'ów, grading z ziarnem. Daje najlepszy klimat (ulica, ciemny pokój, posterunek dzień/noc).
- **Szczebel 2 odrzucony.** Cienie 2D (LightOccluder2D na podstawach) nie znają wysokości światła: lampy pod sufitem i latarnia rzucają długie kliny w stronę kamery. Cień jednego światła pod drugim (latarka) tylko jaśnieje. Fasady stojące za occluderem nie dostają światła.
- **Szczebel 3 odrzucony na koszt.** Sprite'y jako pionowe quady w 3D (kamera ortogonalna 45°) dają prawdziwe cienie i światło księżyca przez okno, ale:
  - każda scena potrzebuje geometrii 3D (podłogi, ściany, sufity rzucające tylko cień, otwory okien) zamiast TileMapy i Y-sortu;
  - wyszły pułapki silnika: alpha scissor zostawiał prostokąty (potrzebny własny shader z `discard`), HDR 2D przyciemniał obraz 3D, mgła wolumetryczna przy kamerze ortogonalnej dawała welon;
  - w pokoju zostały cienie, których latarka nie rozjaśnia;
  - grafika i klimat słabsze niż w szczeblu 1.
  Ma potencjał, ale dla solo deva bez doświadczenia jest wyraźnie droższy w budowie i w każdej kolejnej scenie.
- **Fakty techniczne dla szczebla 1:**
  - światła z normal mapami muszą stać wysoko (wysokość 40–110 px), bo nisko zawieszone prawie nie oświetlają płaskiej podłogi;
  - sprite'y unshaded (okna, ekrany, latarnie, kontur) nie są przyciemniane przez CanvasModulate, więc świecące elementy są tanie;
  - normal mapy autorowane w przestrzeni widoku (front ścian „na południe”, blaty „do góry”) dają czytelny wolumen w 3/4.
- **Koszmar, Test Poczytalności, Stopnie Zmęczenia:** kierunek zaakceptowany (zniekształcenie obrazu i kolorów, przygaszenie i drganie świateł, winieta, odbarwienie, mrugnięcia, rozmycie). Nie gryzą się z nocnym światłem.
- **Kontur obiektów interaktywnych:** wersja unshaded jest czytelna w ciemności, wersja oświetlana znika. Wybór między konturem a zmianą kursora po najechaniu zostaje otwarty.
- **Latarka:** działa jako stożek światła 2D, ale do przemyślenia po szkielecie: animacja chodu z latarką oraz sterowanie WASD + mysz (teraz latarka obraca się do kursora, nawet gdy mysz stoi).
- **Kraina Piaskuna:** nazwa „Odbicie”.

Słownik: nowe pojęcie Odbicie. ADR 0002: notka „Zmiana”, czyli szczebel 1 jako docelowy.
