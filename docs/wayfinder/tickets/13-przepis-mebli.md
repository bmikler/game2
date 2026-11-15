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

**Ze Sprawdzianu assetu (ticket silnika 02, 2026-11-15) i Poprawki kontraktu assetu (ticket silnika 03), wymagania dla Przepisu:**

- **Droga generacji (styl jak postacie):** Qwen-Image-Edit-2511 w ComfyUI (`style-lab/tools/postac/qwen_kat.mjs`, lokalnie, 0 zł, ok. 1,5–2 min na obraz): obraz 1 = szary render z Prowadnic v2 (`prowadnica_szary.png`, tylko rzut, położenie i wielkość, jak manekin MPFB przy postaci), obraz 2 = postać z Przepisu postaci jako wzór stylu, LoRA kątów 0. Mebel ze szczegółami (poduszki, narzuta, przedmioty na blacie) powstaje w generatorze, w jednym assecie. Przykładowe skrypty: `style-lab/proby/meble/{prompt,generuj}.sh`. Bogactwo szczegółów jest jeszcze za małe (mapa, „Przepis mebli i rekwizytów: bogactwo szczegółów”); to pytanie Przepisu, nie kontraktu.
- **Światło w sprite'cie:** prompt wymaga miękkiego, równego światła bez rzuconego cienia („soft even light, no cast shadow”). Sprite to albedo z tym słabym namalowanym światłem; nie spłaszczamy go. Cień generatora pod meblem odcina maska.
- **Maska i sito:** tło zalane od krawędzi, wszystko poniżej linii podłogi z Blendera odcięte; sito względem maski z Blendera: podstawa pokryta ≥ 95%, dodatki poza podstawą ≤ 30% jej powierzchni, dolna krawędź na linii podłogi ±1 px gry. Do HTML wyboru tylko zgodne wersje.
- **Pikselizacja i paleta:** `style-lab/tools/meble/mebel_piksele.gd` (jeden skrypt dla wszystkich mebli): płótno ×1/10 do 40 px/m wyrównane do punktu zaczepienia, twarda alfa (> 0,5), paleta 40 kolorów.
- **Siatka i Bryły:** Bryły, punkt zaczepienia (na rogu piksela gry), maska i normalne z tej samej sceny Blendera co prowadnice (`style-lab/tools/blender/zestaw_testowy.py`, `bryly.json`, `normalne_gra.png`); asset stawiany na siatce 1/40 m.
- **Normalne:** z Blendera (`normalne_gra.png`; wybór człowieka w prototypie: modelowanie z Blendera wygląda dobrze, normalna ściany Bryły robi szczegóły na wierzchu przezroczystymi). Mapa musi pokrywać **każdy** nieprzezroczysty piksel sprite'a. Piksele dodatków spoza modelu z Blendera (słój, książka, narzuta: dziś (128, 128, 128), czyli brak normalnej) Przepis wypełnia normalnymi „nadmuchanymi” z sylwetki samego dodatku (obszar = alfa sprite'a minus maska Blendera; wysokość z odległości od brzegu obszaru, normalna z jej spadku: w środku do kamery, przy brzegu na zewnątrz). Jedna reguła dla każdego dodatku, bez zewnętrznych narzędzi. Sprawdzian na meblu z bogatymi dodatkami w tickecie silnika 10; jeśli wygląda źle, następna droga to estymator normalnych z obrazu generatora w ComfyUI (pytanie do człowieka przed generacją).
- **Wynik Przepisu:** scena `.tscn` według kontraktu (`docs/silnik/spec.md`, „Asset”): sprite, Bryły, punkt zaczepienia, mapa normalnych, opcjonalnie przyczepione Źródła.
