> Kopia z game1 (`repo/game1/docs/research/47-swiatlo-okien-z-roznych-scian.md`, stan 2026-11-03). Ścieżki i numery notatek odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Wnioski dla game2 są w `docs/grafika.md`.

# Światło z okien w różnych ścianach w widoku 3/4

Ticket: „Światło z okien w różnych ścianach w widoku 3/4”. Data researchu: **2026-10-29**. Wejście: `game1-proto/prototype/lighting/kit/window_light.gd` (smugi okien tylnych), `kit/side_window_light.gd` (okna boczne i przednie), `station_layout.gd` (`_side_window`, `_front_window`), `kit/light_textures.gd`, zrzuty `shots/spread_0.05`, `shots/spread_0.1`, `shots/cmp/promienie2.png`. Wcześniejsze dokumenty: 22a, 22c (§1.3, §4.1, §6.1–6.4), 22d, 43 (§5, wzorzec A), ADR 0007, ticket 30 (rozwiązanie). Preferencja człowieka: nastrój i uroda ważniejsze niż fizyka.

Oznaczenia: **[zweryfikowane]** = sprawdzone w źródle pierwotnym (link) albo w naszym kodzie; **[z pamięci]** = wiedza ogólna, niesprawdzona dziś; **[wniosek]** = moje rozumowanie albo propozycja.

## Streszczenie i rekomendacja

- **Smugi zwężają się przez geometrię, nie przez kolory.** Otoczka wypukła rogów szyby i ich rzutów ma przy oknie szerokość całej szyby *w poprzek ukośnej osi* (szerokość i wysokość szyby naraz), a na dalekim końcu tylko jej szerokość. Przy słońcu z boku (φ ≈ ±50°) smuga z okna gabinetu zwęża się o ok. 40%, a z wąskiej szczeliny celi ok. 4,5× („igła”). Liniowy zanik do zera dodatkowo zjada brzegi dalekiego końca (§1).
- **Rozszerzanie, które nie znika:** zamiast otoczki wypukłej budować smugę jawnie jako **wstęgę**: rdzeń o stałej szerokości szyby plus miękkie pióra po bokach, które rosną z odległością (jak półcień). Daleki koniec ma ok. 1,8–2× szerokość szyby, a rdzeń zostaje jasny, więc smuga jest widoczna. Zanik wzdłuż osi, nie w poprzek (§2).
- **Okno boczne wygląda jak lampa**, bo tekstura `DOOR_SPILL` jest najjaśniejsza tuż przy ścianie i rozchodzi się klinem z punktu. Do tego ma ok. 4× więcej energii niż smugi tylnych okien, światło nieba ma kolor słońca, a kierunek jest zawsze prostopadły do ściany (§3).
- **Jedna reguła dla wszystkich okien [wniosek, sprawdzone algebrą]:** wektor rzutu słońca na ekranie `s = 40·c·(sin A_s, −cos A_s)` nie zależy od ściany. Okno daje tylko krawędź startu i bramkę `facing = max(0, cos(A_s − A_ściany))`. Wszystkie smugi w pomieszczeniu są wtedy równoległe (§4).
- **Wzorzec A (polecany, niski koszt):** jeden budowniczy wstęgi dla okien tylnych i bocznych (ten sam `k`, kolor, zanik, rozszerzanie), plus poduszka nieba `SKY_PILLOW` obrócona do ściany i w kolorze nieba. `DOOR_SPILL` dla okien odpada. **Wzorzec B (wariant do arkusza):** okna boczne bez smugi w powietrzu, tylko poduszka nieba i miękka plama na podłodze (§5).
- Okna przednie (ściana na północ) w lutym na 63°N nie dostają słońca nigdy. Mają tylko chłodną poduszkę nieba (§4.3).

## 1. Dlaczego smugi okien tylnych się zwężają

### 1.1 Geometria otoczki [zweryfikowane w kodzie, wniosek z rachunku]

`WindowLight._update_beams()` dla każdej szyby bierze 4 rogi na ścianie (jasność `k`) i 4 punkty rzutu `far = stopa + s·(H − y_rogu)/40·1,7` (jasność 0). Potem liczy `Geometry2D.convex_hull` z tych 8 punktów.

- Rogi górne szyby rzutują się najdalej, a dolne najbliżej (22c §1.3: góra okna ląduje najdalej). Na dalekim końcu otoczkę tworzą więc tylko **dwa rzuty rogów górnych**, czyli odcinek o długości szerokości szyby `w`.
- Przy oknie otoczkę tworzy cały prostokąt szyby. Jego szerokość w poprzek osi smugi nachylonej o kąt θ od pionu to `w·cos θ + h·sin θ`.
- Na dalekim końcu w poprzek osi zostaje tylko `w·cos θ`.

Przykład (φ ≈ −50°, `c` = 2,2, oś ok. 50° od pionu):

| Szyba | Przy szybie | Daleki koniec | Zwężenie |
|---|---|---|---|
| gabinet, ok. 40 × 24 px | 40·0,64 + 24·0,77 ≈ 44 px | 40·0,64 ≈ 26 px | ok. −40% |
| szczelina celi 6 × 18 px | 6·0,64 + 18·0,77 ≈ 18 px | 6·0,64 ≈ 4 px | ok. 4,5× |

W południe (φ ≈ 0) otoczka to prostokąt i nie ma zwężenia. Zwężenie widać więc najmocniej rano i wieczorem, czyli wtedy, kiedy smugi są najważniejsze. Na `promienie2.png` smugi celi wyglądają jak igły i to się zgadza z tabelą.

### 1.2 Kolory wierzchołków i triangulacja

- `Polygon2D` bez ustawionego `polygons` dzieli cały obrys jednym wywołaniem `Geometry2D::triangulate_polygon(points)`. Kolory są per wierzchołek (`vertex_colors`, gdy liczba się zgadza), a renderer interpoluje je liniowo w trójkącie. **[zweryfikowane]** [polygon_2d.cpp (Godot master)](https://github.com/godotengine/godot/blob/master/scene/2d/polygon_2d.cpp). Że jest to ear clipping, wiem **[z pamięci]**.
- Skutek **[wniosek]**: trójkąty łączą jasne wierzchołki na ścianie z ciemnymi na końcu po przekątnej, a nie wzdłuż osi smugi. Jeden brzeg smugi gaśnie na długim odcinku, drugi na krótkim, więc smuga jest asymetryczna i wygląda na zwężającą się do jednego boku.
- Liniowy zanik `k → 0`: w drugiej połowie smugi brzegi mają wartość bliską tła i ziarna z `display.gdshader`. Oko widzi tylko jaśniejszy środek, więc daleka część wydaje się węższa niż jest **[wniosek]**.

### 1.3 Dlaczego `beam_spread` 0,1 dał szeroką słabą poświatę

`far.x += sign(c.x − środek)·|far − róg|·spread` **[zweryfikowane w kodzie]**:
- Przesunięcie jest proporcjonalne do **długości** smugi, a nie do szerokości szyby. Przy długości ~150 px i `spread` 0,1 daleki koniec rośnie o ~15 px na stronę, więc 6-pikselowa szczelina rozszerza się ok. 6×. Ten sam `k` rozłożony liniowo do zera na dużym polu daje słaby kontrast na całej powierzchni.
- Rozszerzanie jest tylko poziome (oś x ekranu), a nie w poprzek osi. Przy ukośnej smudze część przesunięcia idzie wzdłuż osi, a rogi dolne rosną mniej niż górne, więc kształt otoczki zmienia się z godziną.
- Sąsiednie szyby nachodzą na siebie: przerwy po słupkach znikają i okno daje jedną plamę zamiast pasm.

## 2. Jak rozszerzać smugę i zostawić ją widoczną

### 2.1 Fizyka a nastrój [z pamięci + wniosek]

Promienie słońca są równoległe, a rozbieganie się smug to efekt perspektywy (Gurney, cytowany w 22c §4.1 [Sunbeams](http://gurneyjourney.blogspot.com/2008/05/sunbeams.html)). Rozszerzanie się smugi w głąb pokoju ma jednak uzasadnienie: **półcień rośnie z odległością od otworu** (22c §1.3: ok. 0,9 cm na metr od słońca), a w zakurzonym powietrzu rozpraszanie poszerza brzegi. W stylizacji wolno to przesadzić. Ważne, żeby **rdzeń** smugi zachował szerokość szyby, a rosły **miękkie brzegi**. Wtedy smuga czyta się jako szersza, a nie traci jasności.

### 2.2 Geometria: wstęga z jawnymi trójkątami [wniosek]

Dla każdej szyby:
1. Oś: od środka szyby `C0` do rzutu środka `C1 = C0 + s·(H − y_środka)/40·BEAM_EXTEND`. Długość `L = |C1 − C0|`, kierunek `a`, normalna `n ⟂ a`.
2. Szerokość bliska `w0` = szerokość szyby w poprzek osi (`w·|cos θ|` + mały dodatek, np. `h·|sin θ|·0,5`, żeby szyba nie była cieńsza od rysunku). Tak smuga zaczyna się na szkle i nie wygląda jak igła.
3. Rdzeń o stałej szerokości `w0` (albo lekko rosnący, ×1,1 na końcu).
4. Pióra po obu stronach: szerokość `f(v) = lerp(f0, f1, v)`, `f0` = 1 px, `f1` = `0,45·w0` (ograniczyć do 3–16 px, żeby szczeliny celi nie puchły, a duże szyby nie zlewały się z sąsiadami). Daleki koniec ma więc `w0·(1 + 2·0,45) ≈ 1,9·w0`.
5. Wzdłuż osi `N` = 5–6 odcinków. Każdy odcinek to 3 czworoboki (pióro L, rdzeń, pióro P), czyli 6 trójkątów. Indeksy podawać przez `Polygon2D.polygons` (każdy czworobok to osobny wielokąt, triangulowany osobno [zweryfikowane, ten sam plik źródła]), żeby to my decydowali o przekątnych.
6. Kolor: rdzeń `k·g(v)`, wewnętrzny brzeg pióra `k·g(v)`, zewnętrzny 0. Profil wzdłuż osi, np. `g(v) = 1` do `v = 0,12`, potem `(1 − v')^1,4`. Odcinki pozwalają dać dowolną krzywą przy kolorach wierzchołków.
7. Cięcie do wnętrza zostaje (`_clip_edge` Sutherlanda–Hodgmana), tylko per czworobok.

Dlaczego bez szwów: wartość zależna tylko od położenia wzdłuż osi jest funkcją afiniczną położenia, więc interpolacja w trójkącie jest dokładna. Szew dałaby współrzędna „w poprzek” znormalizowana do szerokości trapezu (to nie jest funkcja afiniczna). Dlatego brzegi robią osobne pióra, a nie tekstura rozciągnięta na trapez **[wniosek; mapowanie afiniczne na trapezie znam z pamięci]**.

### 2.3 Tekstura gradientu zamiast kolorów wierzchołków (opcja)

`Polygon2D` z `texture` i `uv`: UV liczone z `uv` albo z pozycji punktów, przez `texture_offset`, `texture_scale`, `texture_rotation`, dzielone przez rozmiar tekstury **[zweryfikowane]** ([polygon_2d.cpp](https://github.com/godotengine/godot/blob/master/scene/2d/polygon_2d.cpp)). Pasek 1 × 32 px z profilem `g(v)` i filtrem `NEAREST`, mapowany tylko wzdłuż osi (`v`), daje **pikselowe stopnie jasności** (6–8 poziomów) bez shadera. To przydaje się, jeśli płynny gradient będzie wyglądał „cyfrowo” na tle pixel artu. Pióra i tak zostają geometrią.

### 2.4 Parametry startowe

| Parametr | Teraz | Start | Na arkusz |
|---|---|---|---|
| `BEAM_EXTEND` | 1,7 | 1,7 | 1,5 / 1,7 |
| rozszerzenie (daleki : bliski) | ~0,6 (zwężanie) | 1,9 | 1,5 / 1,9 / 2,4 |
| pióro `f0 → f1` | brak | 1 px → 0,45·`w0`, 3–16 px | 0,25 / 0,45 / 0,7 |
| jasność rdzenia `k` | `0,13·sun_k` | bez zmian | — |
| profil `g(v)` | liniowy 1 → 0 | płasko 12%, potem `(1−v)^1,4` | wykładnik 1,0 / 1,4 / 2,0 |
| odcinki `N` | — | 6 | — |

Nie kompensować jasności rozszerzeniem (`k·w0/w(v)`): fizycznie poprawne, ale to dokładnie ten efekt, który zgasił smugi przy `spread` 0,1.

## 3. Okno boczne: dlaczego wygląda jak lampa [zweryfikowane w kodzie, wniosek z rachunku]

- **Kształt:** `DOOR_SPILL` ma maksimum na krawędzi przy otworze (`pow(1 − t, 1,5)` = 1 przy drzwiach) i klin od pół-szerokości 0,4 do 0,9. To kształt źródła punktowego w ścianie, czyli lampy albo uchylonych drzwi. Okno ma parapet ok. 0,9 m nad podłogą, więc słońce pada **z odsunięciem od ściany** (`0,9·c` m), a przy samej ścianie jest tylko miękkie światło nieba.
- **Siła:** smuga słońca ma `Exposure.energy(sun_lux·facing·0,5)`, czyli ok. połowę energii plamy, na teksturze 64 × 2,2 ≈ 140 px (3,5 m). Okna tylne mają `show_patch = false`, więc na podłodze dają tylko addytywne smugi `0,13·sun_k` plus poduszkę nieba. Okno boczne świeci więc ok. 4× mocniej (rząd wielkości: 0,5 do 0,13, dalej zależnie od albedo).
- **Kolor:** `_sky_shaft.color = sun.sun_color`. Światło nieba z okna bocznego jest ciepłe, a z tylnego (`_sky.color = sun.sky_color`) chłodne. Stąd niespójność barwy.
- **Rozmiar:** `flux()` liczy `span · 1 m`, a energia nie zależy od powierzchni szkła (u okien tylnych smuga ma `sqrt(A/1,42)` w przedziale 0,6–1).
- **Kierunek:** smuga zawsze prostopadła do ściany, bez ścięcia od azymutu słońca. Smugi okien tylnych idą ukośnie, więc w sali oba okna świecą w różnych kierunkach o tej samej godzinie.

## 4. Jedna reguła dla wszystkich ścian

### 4.1 Wspólny wektor słońca [wniosek, sprawdzone algebrą]

Konwencja posterunku: góra ekranu to południe, lewa ściana to wschód (`station_layout.gd`: `wall_azimuth_deg = 90` dla lewej). Kierunek wędrówki światła słońca o azymucie `A_s` na ekranie:

```
s = 40 · c · (sin A_s, −cos A_s)        # px na metr wysokości
```

Dla okna tylnego (`A_w` = 180°, φ = A_s − 180°) daje to dokładnie obecne `(−sin φ, cos φ)·40c`, więc to ta sama formuła. Okno w dowolnej ścianie:
- bierze **ten sam** `s` (smugi równoległe w całym pomieszczeniu; Gurney: widz wybacza długość, nie wybacza nierównoległych promieni, 22c §1.3),
- daje bramkę `facing = max(0, cos(A_s − A_w))`, wygładzoną `smoothstep(0, 0,25, facing)`, żeby smuga nie gasła skokowo przy muskaniu ściany,
- daje krawędź startu smugi (§4.2).

### 4.2 Krawędź startu dla okna bocznego [wniosek]

W rzucie ukośnym ściana boczna jest widziana na krawędź, więc szkło na wysokości `z` przy głębokości `d` leży na linii ściany w `(x_ściany, FY + 40d − 40z)`. Okno o długości `span` to pionowy odcinek na linii ściany. Startowe „szyby” okna bocznego to więc odcinek `[d0, d1]` na linii ściany, podniesiony o `z_mid` = 1,6 m (środek otworu 0,9–2,3 m) albo dokładniej czworobok od parapetu do nadproża. Ten sam budowniczy wstęgi przesuwa go o `s` i rozszerza tak samo jak szyby tylne. Słupki okna bocznego w wierzchu dzielą odcinek na 2–3 pasma, jak u okien tylnych.

### 4.3 Kolor: niebo a słońce [zweryfikowane w kodzie + wniosek]

- **Słońce** (smugi, rim, odbicie): `sun.sun_color` × `CLEAR` (krzywa zachmurzenia, 22c §1.1) × `facing`. Tylko gdy słońce stoi przed ścianą.
- **Niebo** (poduszka): zawsze `sun.sky_color`, energia `Exposure.energy(sky_lux · df_near, X, peak)` jak u okien tylnych (ADR 0007: jasność tylko z luksów). Każde okno w każdej ścianie, każda pora. Nocą działa nastrojowe minimum `night_sky_lux`.
- Okno przednie (północ, `A_w` = 0°): w lutym na 63°N słońce ma azymut 114–244° (22c §1.1), więc `facing` = 0 przez cały dzień. Okno przednie daje tylko chłodną poduszkę nieba. To jest poprawne fizycznie i daje miły kontrast: ciepłe smugi od południa i wschodu, chłodny pas od północy.

### 4.4 Siła względem okien tylnych i powierzchni szkła [wniosek]

- Smuga: `k = 0,13 · sun_k · clamp(sqrt(A_szkła / 1,42), 0,6, 1) · facing`, ten sam wzór co dziś w `_update_beams()`. Dla okna bocznego `A_szkła = span_m × 1,4 m` (0,9–2,3 m). Okno boczne 1,4 m ma 1,96 m² → mnożnik 1.
- Ponieważ okno boczne widać tylko jako kilka pikseli w wierzchu, a smuga „bez źródła” łatwo czyta się jak lampa, dać mnożnik `side_k` 0,6–0,8 na arkusz (nastrój: okno tylne jest głównym bohaterem kadru).
- Poduszka nieba: ta sama energia co u okna tylnego, przeskalowana `sqrt(A/1,42)` jak smuga.

## 5. Wzorce

### Wzorzec A: wspólna wstęga + obrócona poduszka (polecany)

- **Okno tylne:** wstęga z §2 zamiast otoczki. Reszta bez zmian.
- **Okno boczne i przednie:** `SideWindowLight` przestaje używać `DOOR_SPILL`. Dostaje:
  - wstęgi z §2 i §4.2 (ten sam kod co okno tylne, wydzielony do statycznej funkcji, np. `WindowLight.build_beam(a, b, s, k, ...)`), z bramką `facing` i `side_k`;
  - poduszkę `SKY_PILLOW` obróconą tak, żeby krawędź „ściany” tekstury leżała na linii ściany (lewa ściana: `rotation = −PI/2`, prawa: `PI/2`, przednia: `PI`). Szerokość wzdłuż ściany ok. 2,2 × długość szkła (tak jak 192 px tekstury przy 88 px szkła w oknie tylnym), głębokość w pokój ok. 100–140 px. Kolor `sky_color`, `height` 70, bliźniak `ActorLight` jak teraz.
- **Koszt:** niski. Ok. 80–120 linii (budowniczy wstęgi + przeróbka `SideWindowLight`), mniej świateł niż teraz (okno boczne: 1 światło + bliźniak zamiast 2 + 2), smugi to addytywne wielokąty (tani overdraw, 22d). Bez nowych assetów.
- **Ryzyko:** smuga z okna bocznego przecina podłogę po skosie od linii ściany i może czytać się jak „deska światła” leżąca na podłodze. Dlatego `side_k` < 1 i wariant B na arkuszu.

### Wzorzec B: okno boczne tylko na podłodze

- Poduszka nieba jak w A, a słońce jako miękka plama na podłodze: istniejące ciasteczko i `_shear()` (22c §6.1) z tym samym `s`, odsunięte od ściany o `sill·c`, z miękką krawędzią 2–3 px. Energia dobrana tak, żeby średni przyrost jasności podłogi był równy wstędze okna tylnego (mierzyć różnicą zrzutów z oknem i bez).
- **Koszt:** niski (jedno światło + bliźniak, kod `_shear()` już jest).
- **Minus:** okna tylne mają dziś `show_patch = false`, więc w jednym pokoju byłyby dwa różne języki: smuga w powietrzu z tyłu, plama na podłodze z boku.

### Co robią inne gry (krótko)

- **Stardew Valley:** okna są tylko w ścianach tylnych, pod nimi pionowe smugi na podłodze (43 §5, obserwacja ze zrzutów). Gra ma osobne właściwości mapy na światło okien: typ światła „indoor window” we właściwości `Light` i właściwość `WindowLight` od wersji 1.4 **[zweryfikowane częściowo, z wiki]**: [Modding:Migrate to Stardew Valley 1.4](https://stardewvalleywiki.com/Modding:Migrate_to_Stardew_Valley_1.4), [diff wiki o typach `Light`](https://stardewvalleywiki.com/Special:MobileDiff/99445). Składni i zachowania przy deszczu nie sprawdziłem (strona Modding:Maps zwróciła 403). Że światło okien znika w deszczu i nocą, wiem **[z pamięci]**.
- **Moonlighter:** okna w ścianach bocznych tylko dlatego, że ściany boczne mają lico; pod nimi ciepłe plamy na podłodze (43 §5, obserwacja ze zrzutów).
- **Eastward, Sea of Stars, Octopath, Replaced, Children of Morta:** brak źródeł pierwotnych o tym, jak rysują światło z niewidocznych ścian (22c §7). Z pamięci: Eastward i Octopath rysują okna głównie w ścianie tylnej, a światło z boków dają raczej poświata i kolorowy ambient niż smuga **[z pamięci]**.
- **Wniosek:** gatunek prawie zawsze unika okien w niewidocznych ścianach. Jeśli już są, to jako miękkie światło na podłodze, nie snop od ściany. Nasz wzorzec A jest więc odważniejszy niż konwencja, a B bliżej niej. Dlatego oba na arkusz.

## 6. Arkusz porównawczy

Pomieszczenia: **sala** (okno tylne + boczne we wschodniej ścianie), **gabinet** (duża szyba), **cela** (szczeliny 6 px, najgorszy przypadek zwężania). Pory: **9:00** (słońce z ESE: okno boczne i tylne świecą), **12:30 pochmurno** (tylko niebo), **15:30** (słońce z WSW: wschodnie okno tylko niebo), **niebieska godzina**, **noc**.

Wiersze:
1. Teraz (otoczka, `DOOR_SPILL`).
2. A: wstęga 1,5×, pióro 0,25, `side_k` 0,6.
3. A: wstęga 1,9×, pióro 0,45, `side_k` 0,8.
4. A: wstęga 2,4×, pióro 0,7, `side_k` 0,8.
5. B: wstęga 1,9× z tyłu, z boku plama na podłodze + poduszka.

Na co patrzeć:
- czy smugi w sali są **równoległe** między oknem tylnym a bocznym o 9:00;
- czy okno boczne czyta się jako **okno**, a nie lampa (brak gorącego punktu przy ścianie);
- czy smugi celi przestały być igłami i czy przerwy po słupkach zostają widoczne przy 1,9× i 2,4×;
- **zgodność siły:** średni przyrost jasności podłogi od okna bocznego vs tylnego (różnica zrzutów z oknem i bez, w tym samym oknie pikseli), docelowo 0,6–1,0;
- **zgodność barwy:** o 15:30 i w pochmurne południe okno boczne ma być chłodne jak poduszka okna tylnego.

## 7. Czego nie zweryfikowano

- Nic z tego dokumentu nie zostało uruchomione. Liczby zwężenia w §1.1 są z rachunku dla typowych wymiarów szyb, a nie zmierzone na zrzutach.
- Że `triangulate_polygon` w Godocie to ear clipping, i że mapowanie tekstury na trapezie daje szew na przekątnej: wiedza z pamięci.
- Zachowanie Stardew przy deszczu i nocą: z pamięci. Wiki Modding:Maps zwróciła 403.
- Sposób rysowania światła z bocznych okien w Eastward, Octopath, Sea of Stars, Replaced, Children of Morta, Pentiment, KRZ i Disco Elysium: nie znalazłem źródeł pierwotnych, opis z pamięci albo z wcześniejszych obserwacji (22c §7, 43 §1, §5).
- Konwencja „góra ekranu = południe, lewa ściana = wschód” odczytana z `station_layout.gd` i 43 §8. Jeśli zmieni się układ, zmienia się tylko znak w `s`.
