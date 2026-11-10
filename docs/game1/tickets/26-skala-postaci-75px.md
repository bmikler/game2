---
id: 26
title: Skala grafiki dla postaci ok. 75 px
labels: [wayfinder:grilling]
status: closed
assignee: bmikler
blocked_by: []
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/26-skala-postaci-75px.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Człowiek wybrał większą postać: Krogg z Pixellab (v3, płótno 80 px) ma 75 px wysokości zamiast ok. 60 px z ADR 0002, i gra ma się dostosować do tej wielkości. Co z resztą skali: czy baza zostaje 640×360 (postać zajmuje ~21% wysokości ekranu, scena posterunku przestaje się mieścić i kamera musi przewijać), czy rośnie (np. 768×432, 960×540) i jak to wpływa na skalowanie całkowite na 1080p/1440p/4K; kafel 32 px czy większy; skala mebli i drzwi względem postaci (biurko z Pixellab 100×80); zasięg światła i kamera w pięciu pomieszczeniach posterunku.

Wejście z ticketu Pipeline assetów pixel art z normal mapami: zrzuty `shots/assets_pixellab_*.png` w prototypie oświetlenia (gałąź `prototype/oswietlenie`) pokazują Krogga 75 px obok placeholderów w skali 60 px. Pixellab generuje postać w rozmiarze zadanym parametrem `size`, więc skala jest sterowalna.

Wynik zmienia ADR 0002 (skala).

Wejście z ticketu Architektura kodu szkieletu: posterunek to jedna scena `station.tscn` z pięcioma Pomieszczeniami przechodzonymi bez ładowania; do ustalenia, czy kamera przewija się płynnie za Badaczem, czy trzyma się granic Pomieszczenia.

## Resolution

- **Baza:** roboczo zostaje 640×360 ze skalowaniem całkowitym (jedyna baza 16:9 skalowana całkowicie na 720p, 1080p, 1440p i 4K). Człowiek chce zobaczyć większą bazę w tej samej proporcji, więc ostateczny wybór przechodzi do ticketu Rozdzielczość bazowa: 640×360 czy większa. Baza zmienia tylko pole kadru (640×360 to ok. 16×9 m, 960×540 to ok. 24×13,5 m), reszta decyzji poniżej od niej nie zależy.
- **Skala świata:** 1 m = 40 px, jednakowo we wszystkich osiach (szerokość, głębokość, wysokość frontu), bez skrótu głębokości. Postacie na płótnie 80×80, wzrost = rzeczywisty wzrost × 40 px (Krogg 75 px ≈ 1,88 m; osoba 1,65 m ≈ 66 px).
- **Kafel:** 32 px (0,8 m), tylko techniczna siatka podłóg i ścian, zgodna z tilesetami Pixellab (16/32 px, 64 px tylko w trybie pro; 40 px niedostępne, a skalowanie 32→40 niszczy piksele). Meble, drzwi i postacie stoją poza siatką.
- **Meble i drzwi:** w skali 40 px/m, tabela wymiarów odniesienia w dokumencie kierunku graficznego (`STYLE.md`), np. drzwi 0,9×2,1 m (36×84 px), biurko 1,6×0,8 m z blatem na 0,75 m, prycza 2×0,8 m. Biurko 100×80 z Pixellab jest za duże (ok. 2,5 m) i do ponownego wygenerowania.
- **Kamera:** Camera2D płynnie podąża za Badaczem w granicach bieżącego Pomieszczenia; małe Pomieszczenie stoi, duże się przewija; po przejściu przez drzwi kamera płynnie przechodzi do granic nowego Pomieszczenia. Sąsiednie Pomieszczenia nie są widoczne.
- **Ekrany inne niż 16:9:** stały kadr 16:9 z czarnymi pasami (np. 2560×1600 → ×4 z pasami po 80 px). Do ponownego rozważenia (`expand`) przed wydaniem.
- **Światło:** zasięgi w metrach w zasobach `.tres`, przeliczane jedną stałą `PX_PER_METER = 40`. Wartości startowe: lampa sufitowa promień ok. 3,5 m, lampka biurkowa ok. 1,5 m, monitor ok. 1 m, okno nocą tylko ambient; strojenie przy budowie.

ADR: docs/adr/0002-widok-3-4-i-drabinka-swiatla.md (zmiana skali).
