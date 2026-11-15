---
id: 13
title: Przepis mebli i rekwizytów w spójnym rzucie
labels: [wayfinder:prototype]
status: open
assignee:
blocked_by: [02, 08, 09, 11, 36]
---

## Question

Jak produkować meble i rekwizyty w przyjętym rzucie: prowadnice/render z Blendera jako wejście generatora vs generator z obrazem stylu vs kod? Test na zestawie do salonu Poligonu Dom (kanapa w 2–3 orientacjach, stół, regał, telewizor, lampa, drobiazgi), wstawionym do sceny obok postaci z Przepisu postaci, jeśli jest. Materiał: `46`, `51`, `51b`, `57`. Mierzyć jak w Przepisie postaci. Wynik: Przepis mebli (pierwsza wersja).

**Plan i koszt** (zasada z Notes mapy): Przepis zapisuje minimalny wymagany plan (tier Pixellab lub plan RD) i koszt jednego assetu w generacjach lub USD, z uwzględnieniem prób.

**Z Rzutu, skali i rozdzielczości:** prowadnice z Blendera (`style-lab/tools/blender/zestaw_testowy.py --df 0.6 --ppm 320 --canvas 1024`) + SDXL ControlNet depth + pixel-art-xl (`style-lab/tools/comfy_proba.mjs`) trzymają kąt 0,60 i skalę lokalnie, 0 zł, ok. 25 s/obraz; tło wycinane maską z renderu, zmniejszenie ×1/8 nearest. W Poligonie: F1 „Rząd wzorców”. Pytanie otwarte: jakość i styl vs Pixellab z obrazem wejściowym.

**Ze światła (2026-11-10):** mebel w Przepisie dostaje metadane do mapy światła (`SunGeometry`: obrys, wysokość, ewentualnie złożona bryła / pusty dół, `receives`); które i w jakiej postaci, wynika z [Przebudowa światła wnętrza na jeden bufor z cieniami](36-przebudowa-swiatla-jeden-bufor.md) (przesłony jako pudełka i walce w jednym buforze); do rozważenia przy Przepisie uwagi inżyniera z `docs/research/80-ocena-oswietlenia-inzynier.md`: A (bufor pozycji zamiast `surface_at`), G (jawne metadane przesłon i otworów), I (złożone bryły / pusty dół, walidator metadanych). Wskazówkę co do map normalnych mebli da ticket 22.

**Z mapy silnika (2026-11-15):** kontrakt assetu ustalony w [Kontrakt danych sceny](../../wayfinder-silnik/tickets/08-kontrakt-danych-sceny.md): scena `.tscn` = sprite + uproszczone Bryły (pudełko, z dachem, walec, uniesione; nie 1:1, na start z tej samej sceny Blendera co prowadnice) + punkt zaczepienia (środek przedniej dolnej krawędzi) + opcjonalnie mapa normalnych i przyczepione Źródła. Zastępuje `SunGeometry`/`receives` z notatki wyżej.
