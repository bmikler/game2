---
id: 30
title: Dynamiczne oświetlenie zamiast ręcznie strojonych smug: jak i za ile
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Smugi słońca z okien, plamy na podłodze i ich ruch przez dzień robimy dziś ręcznie, osobno dla każdego rodzaju okna (`style-lab/lighting/`: `window_light.gd`, `side_window_light.gd`, `beam_canvas.gd`, `lighting_director.gd`), i ciągle wychodzą źle: smugi z okien dolnych i bocznych nie zdradzają okna, plama z krzyżem jest zła, nie zgadza się wnętrze z ulicą, a brzeg domu ma gasnąć od światła (zob. [Światło okien ze wszystkich ścian i orientacja mapy](27-swiatlo-okien-orientacja.md), [Brzeg domu w czerni](29-brzeg-domu-w-czerni.md)). Pytanie człowieka (2026-11-09): **czy da się to ograć dynamicznym oświetleniem, które samo liczy smugi, plamy i cienie z kierunku słońca i geometrii, i ile to kosztuje?**

Zbadać możliwe podejścia w Godot 4.7 dla pixel artu w naszym rzucie (niskie 3/4, głębia × 0,60, 40 px/m, postać 72 px, kadr 960×540), np.:
1. **Światła 2D Godot** (`PointLight2D`/`DirectionalLight2D`, `LightOccluder2D`, mapy normalnych, `CanvasTexture`): czy dają smugę przez okno i plamę z ramą okna, co z rzutem 3/4.
2. **Ukryta bryła 3D jako bufor światła:** niewidoczna makieta pokoju/ulicy z prostych brył (ściany, otwory okien, meble jako pudełka), prawdziwe słońce, cienie i ewentualnie mgła wolumetryczna w 3D, wynik kwantyzowany i nakładany na sprite'y 2D (czy ktoś tak robi, jak zgrać kamerę ortogonalną z naszym 0,60).
3. **Pełne 3D z shaderem pixel art** (styl t3ssel8r, sprite'y jako billboardy, HD-2D): co by to zmieniło w Przepisach.
4. **Mapy wysokości/głębi na sprite'ach** i cienie/smugi liczone w przestrzeni ekranu (raymarching 2D, SDF, radiance cascades / 2D GI).
5. **Wypiekanie** kilku klatek kluczowych dnia (z 2 lub 3) i mieszanie.

Dla każdego: jak wygląda smuga i plama okna (z podziałem na skrzydła, ruch słońca), czy trzyma pixel perfect i klimat (Kotwice: REPLACED, NORCO), wydajność na RTX 4060 Laptop i słabszym sprzęcie Steam, **koszt**: dodatkowe dane na asset (normalne, głębia, bryła), kto je robi (Pixellab `/normal-map` 0,1 gen., skrypt, Blender, ręcznie w Godot), ile pracy w kodzie, wpływ na Przepisy i Miesiąc produkcji (inwentarz: ~1500 jednostek, 120–660 mebli, 21–50 pomieszczeń, 16–34 fasady). Przykłady gier i devlogów z techniką. Rekomendacja, co prototypować na Poligonie Dom jako wariant obok obecnego.

## Resolution

Research: `docs/research/79-dynamiczne-oswietlenie.md` (2026-11-09).

- Plamę z ramą okna, jej ruch przez dzień, jeden wektor słońca dla wnętrza i ulicy oraz cienie mebli da się liczyć z danych: otwór okna, skrzydła, ściana, kierunek słońca i pudełka mebli. Plama to rzut równoległy okna na podłogę, a `_shear` już go liczy.
- Światła 2D Godota się nie nadają: cienie `DirectionalLight2D` są nieskończone i nie znają wysokości okna. Nadają się tylko do lamp.
- **Wariant F (rekomendowany):** analityczna mapa światła w shaderze. Dla piksela podłogi lub ściany sprawdza, czy promień do słońca przechodzi przez skrzydło okna i omija pudełka mebli. Szacunek: 25–35 h kodu, 0 generacji, 0 USD, poniżej 1 ms.
- **Drugi wariant:** ukryta makieta 3D z prawdziwym słońcem i mgłą wolumetryczną. Daje smugę w powietrzu. Szacunek: 35–55 h; ryzyka: mgła tylko w Forward+, migotanie, banding. Rzut 0,60 odtwarza kamera ortogonalna pochylona o ok. 31° z korektą X 0,858; to rachunek, nie sprawdzony w Godocie.
- Odpadają: pełne 3D / HD-2D (200–400 h, przepisuje Przepisy), radiance cascades (szacunkowo 5–6 ms, miękkie brzegi), 2–3 klatki kluczowe dnia (efekt „ducha”).
- Dynamika nie rozwiąże czytelności okien dolnych i bocznych (nadal potrzebny sygnał okna) ani brzegu domu w czerni (to zasięg ambientu i HDR→sRGB). F daje tylko liniową mapę światła, którą łatwo gładko wygasić.
- Koszt w Miesiącu produkcji: 0 generacji, ok. 10–15 h na metadane (obrys i wysokość mebli, otwory okien w pokojach i fasadach). Mapy normalnych (ticket 22) nie zależą od tego.
- Brak devlogów z dynamicznymi smugami przez okno w pixel arcie. Mocne źródła: Elsinore, Blessings of the Forge, dokumentacja Godota.
