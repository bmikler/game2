> Kopia z game1 (`repo/game1/docs/research/51b-obroty-i-uklad-obiektow-3-4.md`, 2026-11-03). Ścieżki (`game/`, `tools/`, `art/`, numery notatek) odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Wnioski dla game2 są w `docs/grafika.md`.

# Obroty obiektów i układ wnętrz w 3/4: tył, bok, ukos, zasłanianie, kolizje

Data researchu: **2026-11-03**. Dopełnienie `51-spojna-grafika-3-4.md`. Powód: pierwszy fotel w grze (`game/world/station/sprites/armchair.png`, 56×72) jest obrócony po przekątnej, a kanapa, lada i szafy stoją frontem. Pytania: jak rysować/generować tył i bok mebli, jak je układać w pokoju i czy ukośne ustawienie ma sens w naszym rzucie. Ta notatka **nie powtarza** `51` (pipeline Blender → `unfake` → kontur, kontrole spójności), `43`/`43b` (ściany), `46` (rachunek rzutu), `57` (Pixellab), `22b` (układ pokoju socjalnego), tylko się na nich opiera.

Oznaczenia jak w `51`:
- **[zweryfikowane]**: sprawdzone w źródle pierwotnym (link) albo w repo (ścieżka).
- **[wtórne]**: źródło wtórne, streszczenie strony przez narzędzie albo forum/sklep z assetami.
- **[niezweryfikowane]**: wiedza ogólna, nie sprawdzona.
- **[wniosek]**: moje rozumowanie albo propozycja.

Uczciwie o lukach: **nie znalazłem** pierwotnych tutoriali Saint11, Brandona Jamesa Greera, Pixel Pete'a ani MortMorta o tyłach/bokach mebli w 3/4, ani devlogów Stardew Valley, Eastward czy Chef RPG o obrotach mebli. Wyszukiwarka zwróciła głównie sklepy z assetami i strony SEO. Gdzie coś o tych grach jest poniżej, jest oznaczone jako niezweryfikowane.

## TL;DR

1. **W naszym rzucie (ADR 0002, 1 m = 40 px we wszystkich osiach) ekran = (x, y + z): głębokość i wysokość przesuwają punkt w pionie o tyle samo.** Z tego wynika wszystko poniżej **[wniosek, ta sama konstrukcja co `46` §2]**: boki (normalne ±X) mają 0 px, wierzch i front są w skali 1:1, a obiekt obrócony o 90° nie pokazuje „boku”, tylko swoją inną ścianę jako nowy front.
2. **Reguła główna: meble i rekwizyty stoją osiowo (0°/90°/180°/270°), nigdy po przekątnej ani pod dowolnym kątem.** Ukośny obiekt łamie trzy rzeczy naraz: reprezentację bryły (patrz niżej), zgodność z kolizją `Rect2` w `WalkArea` i spójność z resztą mebli. Wyjątek: pojedyncze, świadomie wykonane dekoracje (§5).
3. **Liczba orientacji na rekwizyt** (tabela w §1): drobiazgi i sprzęt „frontowy” 1 (tylko ściana tylna); stoły, biurka, regały, łóżka 2 (poziomo/pionowo, lustro za darmo); kanapy, fotele, krzesła 3 (przód, tył, bok + lustro boku). Czwarta orientacja to lustro trzeciej, **pod warunkiem odwrócenia kanału X normal mapy** (§1).
4. **Boki i tyły generujemy w Blenderze obracając obiekt (nie kamerę)** o `yaw` ∈ {0, 90, 180, 270} z tym samym rigiem co `51`. AI (Pixellab rotate itd.) jest do tego nieprzydatne: narzędzie rotate jest wytrenowane na postaciach (§4).
5. **Ściany: obiekt „frontowy” (lodówka, szafa, aneks, tablica) stawiamy przy ścianie tylnej.** Przy ścianie bocznej jego front jest niewidoczny (0 px). Przy ścianie bocznej stawiamy obiekty czytelne z wierzchu i z profilu: łóżko, kanapa bokiem, stół, biurko bokiem, roślina, skrzynie. Przy ścianie przedniej (niewidocznej) stawiamy tylko niskie meble pokazane od tyłu (§2).
6. **Zasłanianie gracza:** wysokie meble (> ok. 1,2 m) tylko przy ścianie tylnej, gdzie gracz nie może wejść za nie; reszta niska. Y-sort po punkcie stóp w dolnej krawędzi *sylwetki podstawy*; kolizja to dolne `głębokość × 40 px` sprite'a, nie cały sprite (§2).
7. **Werdykt o fotelu (§4): obecny `armchair.png` jest w innym rzucie niż reszta (bliżej rzutu izometrycznego/dimetrycznego niż naszego 1:1) i ma kolizję osiową niepasującą do obrotu.** Zalecenie: przerenderować jako fotel frontem + bokiem w rigu, nie utrzymywać wersji ukośnej jako standardu.

## 1. Tył i bok mebla w naszym rzucie

### Co się zmienia geometrycznie [wniosek]
Oznaczmy osie: x w prawo, y w głąb pokoju (od kamery), z w górę. Rzut: ekran = (x, y + z)·40 px. Widoczna jest pionowa ściana, jeśli jej normalna wskazuje na kamerę (−y); ściana o normalnej ±x jest równoległa do kierunku patrzenia, więc ma 0 px (`46` §2).

Konsekwencje dla obrotu mebla o kąt `yaw` wokół pionu:

| Yaw | Co widać | Sylwetka |
|---|---|---|
| 0° (front) | front (szer. × wys.) + wierzch (szer. × głęb.) nad nim | `w` × (`h` + `d`) |
| 180° (tył) | **tył** (szer. × wys.) + ten sam wierzch | te same wymiary co front, inny rysunek |
| 90°/270° (bok) | **dawny bok jako front** (głęb. × wys.) + wierzch obrócony (głęb. szer. × szer. wysokości na ekranie) | `d` × (`h` + `w`): dłuższy i wyższy kształt |
| 45° i inne | dwie ściany pionowe naraz (skośne równoległoboki) + wierzch jako obrócony prostokąt | patrz §3 |

Z tego trzy praktyczne wnioski:

1. **Bok mebla = jego profil.** Kanapa „bokiem” pokazuje jako front swój przekrój boczny (podłokietnik, oparcie, siedzisko), a jej wierzch (długi, 2 m = 80 px) idzie pionowo w górę ekranu. To jest czytelne, jeśli profil jest rozpoznawalny. Sylwetka rośnie w pionie, więc zajmuje więcej miejsca na ekranie niż front.
2. **Tył mebla pokazuje więcej wnętrza niż front.** Kanapa od tyłu: oparcie jest bliżej kamery i niżej na ekranie, a siedzisko leży dalej, więc w rzucie 1:1 widać je *nad* grzbietem oparcia (dokładne liczby zależą od wymiarów; przykład: oparcie 0,85 m wysokości, siedzisko 0,45 m i 0,5 m głębiej, sięga ekranowo 0,95 m ponad linią podstawy, czyli wystaje ok. 0,1 m ponad grzbiet). Tył to więc zazwyczaj gładka ściana oparcia + widoczne poduchy siedziska za nią. Nasz `sofa_back.png` (96×80) już tak działa: gładki tył z narzutą na wierzchu.
3. **Elementy „frontowe” przy ścianie bocznej znikają.** Drzwiczki lodówki zwróconej w prawo mają normalną +x: 0 px. Widać tylko boczną ścianę lodówki (płaska płyta) i wierzch. To nie jest błąd generatora, tylko własność rzutu. Wynik: lodówka przy ścianie bocznej będzie „pustym pudłem”.

### Jak to rozwiązują inni
- **Slynyrd, Pixelblog 3**: w widoku 3/4 „uniformity takes priority over realism”, „don't mix viewpoints” **[zweryfikowane: [Slynyrd, Pixelblog 3](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)]**. To uzasadnia, że bok rysowany „z perspektywą” obok frontu 1:1 jest błędem, a nie wyborem stylu.
- **Slynyrd, Pixelblog 35 (wnętrza z góry w 3/4)**: pokazuje zestaw mebli na siatce 16×16 pogrupowany po pokojach (jadalnia, salon/sypialnia) i prostokątne pokoje z jednego zestawu ścian; **nie omawia** orientacji mebli, tyłów ani ukosów **[zweryfikowane: [Pixelblog 35](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors)]**. Żaden z pierwotnych tutoriali, które otworzyłem, nie odpowiada więc wprost na „jak rysować tył kanapy”.
- **Zestawy mebli na itch.io** (źródła wtórne, ale pokazują praktykę rynkową): zestaw łóżek „3 directions (front, side, back)” w stylu top-down 3/4 [wtórne: [bidi-dev](https://bidi-dev.itch.io/pixel-art-bedroom-furniture-tileset-2d-bedroom-assets-for-rpgs-indie-games)]; krzesła z wersją przód/tył/bok [wtórne: [0-mem0ry, Makeshift Furniture](https://0-mem0ry.itch.io/makeshift-furniture-set-free)]; łóżka w dwóch perspektywach, a „side” wystarczy odbić lustrzanie [wtórne: [Classic Kingdom Interiors](https://heartemide.itch.io/classic-kingdom-interiors-pixel-asset-pack)]. Czyli rynek: **3 widoki + lustro**.
- **Stardew Valley:** w modach meble z obrotem mają cztery sprite'y w jednym arkuszu **[wtórne: [forum Stardew, mod krzeseł](https://forums.stardewvalley.net/threads/how-to-specify-paths-to-textures-for-items-in-1-6.28391/latest)]**; to, że gra bazowa robi tak samo i które meble obraca, **nie zweryfikowałem** (wiki modowa zwróciła 403, [Stardew wiki: Modding Furniture](https://stardewvalleywiki.com/Modding:Furniture)). Zakładam z ostrożności 1/2/4 orientacje zależnie od mebla **[niezweryfikowane]**.
- **Pokémon (Gen 3) i podobne:** wnętrza złożone z kafli frontalnych i mebli rysowanych en face; nie znalazłem analizy pierwotnej **[niezweryfikowane, wiedza ogólna]**.
- **Eastward:** gra 3D z kamerą 2D, „the fixed perspective of the camera becomes both a big asset and a challenge”, z doświadczenia zespołu wynika konieczność takiej aranżacji świata, by gracz „is never unintentionally obscured behind the environment” **[zweryfikowane: [Game Developer, Eastward](https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures)]**. Nie omawia obrotów mebli. To precedens dla naszego rigu 3D→sprite (jak `11b`).
- **Habbo** (izometria): tylko kontrast. W izometrii każdy obrót o 90° zmienia widoczne dwie ściany naraz, więc obrót jest tani wizualnie, ale kosztowny w assetach. Liczby orientacji Habbo **nie sprawdzałem** **[niezweryfikowane]**.

### Ile orientacji na rekwizyt [wniosek]
| Klasa | Orientacje | Uzasadnienie |
|---|---|---|
| Lodówka, aneks, szafa na akta, regał, tablica, kaloryfer, okno, lada | **1** (front; tylko ściana tylna) | front jest ich tożsamością; bok jest niewidoczny, tył nie występuje |
| Stół, biurko, ława, stolik, łóżko, skrzynia | **2** (0° i 90°; 180° = 0° gdy symetryczny; 270° = lustro 90°) | zmienia się footprint, tożsamość czytelna z wierzchu |
| Kanapa, fotel, krzesło, taboret | **3**: przód, tył, bok (lustro boku) | najczęściej obracane; tył i bok wyglądają różnie |
| Rośliny, kosze, kubki | **1** (obrotowo symetryczne) | |

Zaoszczędzone orientacje nie są darmowe: **lustro sprite'a wymaga odwrócenia normal mapy** (kanał X/R × −1), inaczej światło 2D (`normals.gd`, ADR 0002) padnie od złej strony; i nie lustrujemy obiektów z napisami lub asymetrycznym detalem (zegar, telefon) **[wniosek]**.

### Jak je wytworzyć (rig z `51`) [wniosek]
- W `spec.json` dodać `yaw` (0/90/180/270) i obracać **obiekt** wokół osi Z pod stałą kamerą. Nigdy nie obracać kamery: to zmieniłoby stałą projekcji z `51` §3.
- Pliki: `sofa.png` (0°), `sofa_back.png` (180°), `sofa_side.png` (90°), te same konwencje (albedo + normal + maska). Normal mapa dla 90°/270° jest **renderowana osobno**, nie obracana jako obraz.
- Obiekt, którego bok ma być czytelny, projektować z profilem rozpoznawalnym z wierzchu (kanapa: podłokiennik niższy niż oparcie widoczny jako schodek).
- Jeśli front **musi** być widoczny po obrocie (lodówka przy ścianie bocznej): opcja „cheat side” (wąski pasek 6-8 px drzwi dorysowany ręcznie) łamie zasadę „bok = 0 px” z `46`/`51`, więc wymaga decyzji projektowej (pytanie otwarte 2). Domyślnie: nie stawiać takich obiektów przy bocznych ścianach.

### Narzędzia AI: czy obrócą mebel?
- **Pixellab rotate**: „primarily trained to take an image of a character and generate 8 rotational views”; zmienia też widok (high top-down / low top-down / side-scroller); rozmiary płótna tylko 16/32/64/128; strona wspomina „object”, ale nie opisuje jakości dla niepostaci **[zweryfikowane: [Pixellab docs, Rotate](https://pixellab.ai/docs/tools/rotate)]**. Nie ma gwarancji, że zachowa nasz rzut (`51` §4: `view` to podpowiedź). Wniosek: nie używać do mebli.
- **Pixellab `create_object_pro_flash` z `n_directions`** (z `57`) i **Retro Diffusion** (`character_turnaround` w Scenario, opis niedostępny; brak dokumentowanego rotate w [RD API](https://github.com/Retro-Diffusion/api-examples)): obracają „w ich” kamerze, więc przy ukośnym lub niestandardowym rzucie dadzą bok o zgadywanej geometrii **[wniosek]**. Eksperyment: wygenerować kostkę 1×1×1 m w 4 kierunkach i zmierzyć proporcje wierzchu do frontu (już pytanie 5 w `51`).
- Zatem: **bok i tył = Blender** (deterministyczne), AI tylko na etapie A1 z `51` (nakładka stylu na render).

## 2. Układ obiektów w pokoju w widoku 3/4

### Ściany: gdzie co stoi
Pokój ma w kadrze: ścianę tylną (z licem, `43` wzorzec A), dwie boczne (widoczne jako wierzch, 8-10 px) i przednią (nierysowana albo tylko wierzch). Reguły **[wniosek z rzutu §1 + `22b`/`43`]**:

| Ściana | Co stawiać | Czego nie stawiać |
|---|---|---|
| **Tylna** | wszystko „frontowe”: aneks, lodówka, szafy, regały, tablice, okna z grzejnikiem, lada, kanapa tyłem do ściany; oparcia mebli stykają się z licem | nic wymagającego widoku „od tyłu” |
| **Boczne** | meble czytelne z wierzchu i profilu: łóżko wzdłuż, kanapa bokiem, biurko bokiem (jak plan `22b` wersja mała: kanapa przy lewej ścianie wymaga sprite'a z boku), skrzynie, roślina | lodówka, szafa, aneks (front niewidoczny) |
| **Przednia** (nierysowana) | niskie meble **tyłem** do kamery (np. kanapa `sofa_back` 0,85 m), kosze, rośliny; drzwi to przerwa w wierzchu (`22b`, `43`) | wysokie meble (zasłonią pokój i gracza; patrz niżej) |

Pomieszczenia „bez ścian bocznych” (kadr na ciągłą mapę posterunku) rozwiązuje `43`/`43b`: ściany działowe mają wierzch, więc meble przy nich zachowują się jak przy bocznych.

### Zasłanianie gracza i sortowanie
- Eastward (cytat wyżej) formułuje zasadę: nie pozwolić, by gracz zniknął za otoczeniem **[zweryfikowane: Game Developer]**. W 3/4 z wysokimi meblami oznacza to: wysokie sprite'y (szafa 2 m = 80 px + wierzch) tylko przy ścianie tylnej (stopa gracza nie wejdzie *za* nie), reszta nie wyższa niż ok. 1,0-1,2 m (40-48 px) **[wniosek; liczba do kalibracji względem postaci 75 px]**.
- **Y-sort w Godot 4:** `y_sort_enabled`: „If true, this and child CanvasItem nodes with a higher Y position are rendered in front of nodes with a lower Y position”; sortowanie działa tylko między węzłami z tym samym `z_index` **[zweryfikowane: [Godot CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html)]**. Dla kafli: „Y Sort Origin” to „vertical offset to use for tile sorting based on its Y coordinate” i działa tylko przy włączonym Y Sort w TileMapLayer **[zweryfikowane: [Godot, using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)]**. Strona „2d_sorting” zwróciła 404, więc samego opisu z tutoriala nie cytuję.
- **Repo już tak robi:** `Prop` ma pivot na najniższym rzędzie nieprzezroczystych pikseli (`_feet_offset`, `base_y` dla wyjątków), `RoomShell` ma `y_sort_enabled = true`, wierzch ściany przedniej sortowany z aktorami; rekwizyty ścienne mają stałe `ON_WALL_Z = -15` (`game/world/lighting/prop.gd`, `room_shell.gd`) **[zweryfikowane: repo]**.
- **Znany problem sortowania po jednym punkcie [wniosek, niezweryfikowane w źródłach]:** długie obiekty (lada 192 px, kanapa 96 px) mają jedno Y, a gracz może stać obok jej końca; wtedy poprawna kolejność zależy od tego, który punkt jest „podstawą”. Dla prostokątnych, osiowych brył wystarcza krawędź przednia (Y stóp = przednia krawędź footprintu). Dla obiektów ukośnych jedno Y jest błędne dla co najmniej jednej strony (§3). Obiekty L-kształtne dzielić na prostokąty.
- Wikipedia o rzutach oblique: obiekty top-down oblique mieszczą się w kwadratowych kaflach bez nakładania, co „remove the need for extra Z-order calculations” **[zweryfikowane: [Wikipedia, Isometric video game graphics](https://en.wikipedia.org/wiki/Isometric_video_game_graphics)]**. To argument za osiowością: nasz rzut jest obliquem i traci tę zaletę dopiero przy obrotach pod kątem.
- Opcje pomocnicze, gdy gracz **musi** móc stać za wysokim meblem: przezroczystość/sylwetka gracza przez mebel (shader), albo wygaszanie lica **[wniosek; spójne z pytaniem „wygaszanie ściany” w `43` §6]**.

### Kolizja a sprite
- Footprint na ziemi to prostokąt `szer. × głęb.`, czyli w ekranie **dolne `głęb. × 40` px sprite'a** (nad linią podstawy; front wznosi się nad nim, wierzch jeszcze wyżej) **[wniosek z §1]**. Stopy gracza (`foot_size` w `WalkArea`) kolidują tylko z tym prostokątem; głowa gracza może wchodzić w górną część sprite'a (gracz „stoi przed” półką, jeśli jest niżej, i „za” nią, jeśli jest wyżej).
- Repo: `Prop.blocker` to `Vector2` (szer., głęb.) liczone od pivotu w dół; `WalkArea` ma `Array[Rect2]` **[zweryfikowane: repo]**. Wszystko osiowe. Obiekt ukośny wymaga albo kilku prostokątów (schodki), albo zmiany `WalkArea` na wielokąty: koszt i testy.
- Godot (jeśli kolizje przejdą na TileMap): wielokąty kolizji per kafel definiuje się w edytorze TileSet; „F” tworzy prostokąt **[zweryfikowane: Godot, using TileSets]**.

### Odstępy, ścieżki, grupy, gęstość [wniosek, brak źródeł pierwotnych]
- **Przejścia:** minimum ok. 1,0 m (40 px) między meblami na głównej ścieżce, 1,2 m komfortowo; ścieżka nie powinna prowadzić „za” wysokimi meblami. Sprawdzić z `foot_size` i szerokością postaci (nie otwierałem). Dla pokoju socjalnego `22b` wskazuje przejście 4,8-6,9 × 1,8-4,4 m wolne.
- **Grupy funkcjonalne** zamiast równomiernego rozsypania: strefa jadalna (stół + 4 krzesła, w świetle okna), strefa wypoczynku (kanapa + stolik + fotel, na dywanie), strefa pracy (biurko + krzesło + szafka przy ścianie). `22b` ma to już w układzie pokoju socjalnego (stół przy oknie, kanapa po drugiej stronie).
- **Dywan zakotwicza grupę:** rysowany jako płaska plama pod meblami (kategoria podłogi, bez y-sortu z aktorami); meble stoją częściowo na nim (np. przednie nogi kanapy na dywanie, tylne poza). Slynyrd o samej konstrukcji dywanu: bez reguły, „I freely threw down shapes and colors until a meaningful pattern emerged” **[zweryfikowane: Pixelblog 35]**; wskazówka układu dywanu to moje.
- **Gęstość:** w jednym kadrze 960×540 (`ADR 0002`) czytelność wygrywa nad realizmem: 1 mebel „główny” na ok. 6-8 m² i drobiazgi tylko na blatach i przy ścianie tylnej, gdzie są widoczne; podłogę przed ścianą przednią zostawiać pustą dla czytelności ścieżki. Liczby orientacyjne, bez źródła.

## 3. Obroty ukośne: geometria, piksele, siatka

### Co się dzieje z obiektem o `yaw` = 45° w rzucie 1:1 [wniosek]
- **Wierzch** (prostokąt `w × d`) w płaszczyźnie z = const ma prawdziwy kształt w rzucie 1:1, więc po obrocie o 45° to **kwadrat obrócony o 45°** (romb z kątami prostymi), a nie „płaski” romb 2:1 z izometrii.
- **Krawędzie podstawy i wierzchu** biegną na ekranie pod 45° (przyrost x = przyrost y). Są to linie **1:1**, czyli akurat najczystsze w pixel arcie (jedno-pikselowe schodki bez nieregularności).
- **Ściany pionowe**: obie przednie ściany (lewa i prawa) są widoczne jako **skośne równoległoboki** (poziome krawędzie na 45°, pionowe krawędzie prostopadłe do ekranu). Sylwetka jest znacznie wyższa niż u frontowego: wysokość ≈ `h` + (`w` + `d`)/√2.
- **Kąty inne niż 0/45/90** dają nachylenia o dowolnym tangensie, więc nieregularne schodki pikseli (dla porównania: w izometrii pixel-artowej wybiera się nachylenie 2:1 właśnie dlatego, że linie 30° nie rysują się czysto) **[zweryfikowane: [Wikipedia, Isometric video game graphics](https://en.wikipedia.org/wiki/Isometric_video_game_graphics), [Slynyrd, Pixelblog 4](https://slynyrd.com/blog/2018/4/12/pixelblog-4-graphical-projection-part-2)]**. Slynyrd opisuje izometrię jako rzut, który „also rotates the building 45 degrees” względem 3/4 top-down: obrót 45° zmienia więc *rodzaj* rzutu, nie tylko pozycję **[zweryfikowane: Pixelblog 4]**.
- Rzut oblique zachowuje prawdziwy kształt ściany równoległej do ekranu („a true shape image of the chosen plane”) **[zweryfikowane: [Wikipedia, Oblique projection](https://en.wikipedia.org/wiki/Oblique_projection)]**. Nasz front i wierzch mają tę własność, ale po obrocie tracą ją: front ukośny jest ścięty (równoległobok). Dlatego ukośne meble w naszym rzucie wyglądają jak „wprasowane”, a nie jak w grach izometrycznych, gdzie wszystkie powierzchnie są pod kątem.

### Problem spójności
Ukośne meble na tle frontalnej lady i kanapy zdradzają dwa różne rzuty: dostajemy mieszankę „oblique 1:1” i „iso-podobne”. Slynyrd: „don't mix viewpoints”, „uniformity takes priority over realism” **[zweryfikowane: Pixelblog 3]**.

### Pozostałe koszty [wniosek]
- **Siatka kafli:** kafel 32 px (0,8 m) to tylko siatka podłóg i ścian (ADR 0002), więc meble stoją poza nią; obrót o 45° nie zmienia tego, ale ułatwia wylądowanie w narożniku bez kafla.
- **Kolizja:** diament zamiast `Rect2` (§2); koszt: wielokąty w `WalkArea` (dziś `Array[Rect2]`).
- **Y-sort:** jedna wartość Y dla bryły o przekątnych; gracz stojący przy lewym lub prawym rogu rombu może być sortowany błędnie względem fotela (róg jest wyżej niż dolny wierzchołek rombu). Naprawa: podział na dwie części (lewy/prawy) albo sortowanie po wierzchołku dolnym z uznaniem błędu przy bokach.
- **Pozycja w oświetleniu:** normal mapa dla ukośnych ścian ma dwie dominujące normalne zamiast jednej (front→S); `normals.gd` jest heurystyką dla frontu i wierzchu (`51` §2), więc dla ukosu trzeba normal mapy z renderu (A0 w `51`).
- **Obracane przez gracza meble** (jeśli kiedyś dojdzie edycja układu): Chef RPG ma tryb budowania i sortowanie mebli względem ścian (patch #22, `43b`); inne gry z devlogów (nieweryfikowane, [ModDB devlog](https://www.moddb.com/news/june-devlog) obrót co 45° przy przytrzymaniu CTRL i tryb swobodny) wprowadzają obrót ukośny dopiero z buildingiem. Nie dotyczy gry z narzuconym układem.

### Jak to robią gry komercyjne
Nie znalazłem wiarygodnego źródła pierwotnego o praktyce w Stardew, Pokémon czy Eastward dla mebli ukośnych **[niezweryfikowane]**. Zebrane poszlaki: rynkowe zestawy mebli top-down 3/4 dają przód/tył/bok (§1), a Wikipedia wskazuje, że oblique jest wygodne właśnie dlatego, że obiekty mieszczą się w kaflach bez nakładania **[zweryfikowane]**. Moja ocena: w grach w rzucie oblique meble są prawie zawsze osiowe, a ukosy zdarzają się w pojedynczych dekoracjach (rozrzucone papiery, upuszczone krzesło, narzuta) **[wniosek, niezweryfikowane]**.

## 4. Werdykt o fotelu (`armchair.png`)

**Stan [zweryfikowane: repo i obraz]:** `game/world/station/sprites/armchair.png` (56×72, razem z `armchair_n.png`) jest używany w `break_room.tscn` jako `Props/Armchair` w pozycji (148, 178), `blocker = Vector2(44, 30)` i jest rekwizytem „Armchair” z akcją przeszukania (interactable `object.newspapers`). Zmodyfikowany 2026-11-03 20:46, razem z `sofa_back.png`. Obok niego: `sofa.png` (96×80, front), `chair.png` (32×48), `lada.png`.

**Co widać na obrazie [wniosek z oglądania powiększenia 5×, nie z pomiaru pikseli]:**
- Fotel jest obrócony o ok. 30-45° wokół pionu: widoczne są jednocześnie dwie ściany pionowe (lewy podłokietnik i front) oraz wierzch w formie rombu. Gazeta/koc leży po skosie na siedzisku.
- Krawędzie podstawy i siedziska biegną łagodniej niż 1:1 (z oka ok. 1:2 lub 1:3), a nie pod 45°. To wygląda na rzut dimetryczny/izometryczny, nie nasz 1:1.
- Ten sam rozjazd, słabiej, ma `chair.png`: krzesło widziane trzy czwarte.
- Kontrola wymiarów: szerokość 56 px zgadza się z fotelem ok. 0,9 × 0,9 m obróconym o 45° (`(w + d)/√2 · 40` ≈ 51 px plus nogi), ale wysokość 72 px jest mniejsza niż wynik 1:1 dla takiego obrotu (ok. 38 + 51 ≈ 89 px). Wierzch jest więc spłaszczony względem naszego rzutu (rzut „niższy” niż 1:1) **[wniosek]**.

**Ocena względem projekcji:**
- **Niezgodny z ADR 0002** (front i wierzch w 1:1, bok 0 px): pokazuje bok, kąt nachylenia krawędzi jest inny niż w `sofa.png`/`lada.png`, więc to dokładnie ten sam typ niespójności, który `51` opisuje jako przyczynę nr 1.
- **Ładny jako obiekt**, ale w grze zdradza inną kamerę niż kanapa obok (`1200_dzien.png` pokazuje kanapę frontalną z narzutą).
- **Kolizja `44 × 30`** to prostokąt osiowy, więc przy ukosie pozostawia niechroniony ukośny róg i jednocześnie blokuje pusty narożnik bounding-boxa. Przy pivocie na dolnym wierzchołku romb ma Y-sort błędny dla jednego boku.
- Interaktywność (przeszukanie) nie zależy od obrotu.

**Werdykt:** nie zostawiać jako standardu projektu. Dla fotela rekomenduję:
1. Wersja frontalna (`armchair.png`, 0°) w rigu `51` jako domyślna, bok (`armchair_side.png`) i tył wykonać wg §1, jeśli pokój tego wymaga.
2. Obecny ukośny sprite zachować jako **ewentualny wyjątek** tylko jeśli po porównaniu na arkuszu ×4 obok kanapy nie rzuca się w oczy (decyzja człowieka, wzrokowa), z blockerem wielokątnym lub dwoma prostokątami.
3. Jeżeli ukos jest pożądany artystycznie (fotel „przy kominku”), zrobić go w rigu jako 45° w tej samej kamerze (krawędzie 1:1), a nie w „izometrii z AI”.

## 5. Rekomendacja dla projektu (obroty i ukosy)

1. **Osiowość jako reguła.** Wszystkie meble w czterech obrotach, krawędzie zgodne z `Rect2`. Zalety: spójny rzut (jedna kamera), kolizje `Rect2` bez zmian (`WalkArea`), prosty y-sort (jeden punkt na przedniej krawędzi), czyste linie 1 px, czytelne ścieżki, niski koszt assetów (3 widoki + lustro). Wada: układy bywają sztywne (łagodzi to dywan, wolne meble i drobiazgi na blatach).
2. **Ukos tylko jako wyjątek**, spełniający warunki: (a) render z rigu 45° pod tą samą kamerą, (b) blocker złożony z `Rect2` lub wielokąt, (c) y-sort przez podział na dwie części, jeśli obiekt jest szerszy niż ok. 1 m, (d) zatwierdzony na arkuszu ×4 obok `pixel_ref.png`. Kąty inne niż 45° (np. 30°) wykluczone (nierówne schodki).
3. **Aby uniknąć sztywności bez obrotów:** różna odległość od ściany (np. 0,1-0,3 m), meble „wysunięte” z grupy, dywan nie wyrównany do ściany, drobiazgi dopuszczają dowolny kąt tylko jeśli są małe (papier, kubek) i traktowane jako dekoracja bez kolizji.
4. **Stałe w `PROJECTION.md` (z `51` §3):** dodać wiersze: dozwolone `yaw` {0, 90, 180, 270}, minimalne przejście 1,0 m, maks. wysokość mebla poza ścianą tylną 1,2 m, `blocker` = footprint w px liczony od dolnej krawędzi sprite'a, zasada flip = odwrócenie kanału X normal mapy.
5. **Test automatyczny (rozszerzenie `51` §7a):** dla każdego sprite'a z listy „frontowych” brak boku (kolumny skrajne), a dla tyłów/boków zgodność wymiarów sylwetki z tabelą §1 (`w × (h + d)`, `d × (h + w)`).

## 6. Pytania otwarte

1. Czy zostawiamy ukośny `armchair.png` jako wyjątek, czy zastępujemy fotelem frontowym+bokiem z rigu? (Decyzja przez porównanie na arkuszu ×4 obok `sofa.png`.) Do czasu rigu: czy `chair.png` (też lekko ukośny) też należy do poprawki?
2. Czy dopuszczamy „cheat side” (pasek 6-8 px ściany bocznej) dla frontów przy ścianach bocznych (lodówka, szafa)? Łamie zasadę „bok = 0 px”, ale odblokowuje układy; wymaga ADR-u albo wpisu w `PROJECTION.md`.
3. Maksymalna wysokość mebli poza ścianą tylną i sposób zasłaniania gracza (cień/sylwetka/wygaszanie) do kalibracji względem postaci 75 px i `foot_size`.
4. Czy `WalkArea` ma kiedyś obsługiwać wielokąty (na obiekty ukośne i okrągłe), czy zostajemy przy `Rect2`? Decyzja wpływa na dopuszczalność ukosów.
5. Pomiar kamery narzędzi AI dla 4 kierunków (kostka 1×1×1 m) w Pixellab `create_object_pro_flash` (`n_directions`) i Retro Diffusion, czy dają nasz rzut (rozszerzenie pytania 5 z `51`).
6. Stardew, Pokémon i Chef RPG: brak pierwotnych źródeł o obrotach i ukosach mebli. Jeśli to ma być argument, trzeba obejrzeć pliki assetów (np. zrzuty arkuszy mebli z Stardew) i devlogi.
7. Wiki modowa Stardew (403) i część stron Slynyrda (404) nie dały się otworzyć w tym researchu; wnioski opierają się na tym, co udało się pobrać.

## Źródła
- [Slynyrd, Pixelblog 3: Graphical Projections](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)
- [Slynyrd, Pixelblog 4: Graphical Projection Part 2](https://slynyrd.com/blog/2018/4/12/pixelblog-4-graphical-projection-part-2)
- [Slynyrd, Pixelblog 35: Top Down Interiors](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors)
- [Game Developer: Eastward's creators share insights](https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures)
- [Godot: CanvasItem (y_sort_enabled, z_index)](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html)
- [Godot: Using TileSets (Y Sort Origin, kolizje, okluzja)](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)
- [Wikipedia: Isometric video game graphics](https://en.wikipedia.org/wiki/Isometric_video_game_graphics) [wtórne]
- [Wikipedia: Oblique projection](https://en.wikipedia.org/wiki/Oblique_projection) [wtórne]
- [Wikibooks: Isometric Pixel Art, Making a Box](https://en.wikibooks.org/wiki/Isometric_Pixel_Art/Making_a_Box) [wtórne]
- [Pixellab docs: Rotate](https://pixellab.ai/docs/tools/rotate)
- [Retro Diffusion api-examples](https://github.com/Retro-Diffusion/api-examples)
- Zestawy mebli [wtórne]: [bidi-dev](https://bidi-dev.itch.io/pixel-art-bedroom-furniture-tileset-2d-bedroom-assets-for-rpgs-indie-games), [0-mem0ry](https://0-mem0ry.itch.io/makeshift-furniture-set-free), [Classic Kingdom Interiors](https://heartemide.itch.io/classic-kingdom-interiors-pixel-asset-pack)
- [Forum Stardew: mod krzeseł z czterema sprite'ami](https://forums.stardewvalley.net/threads/how-to-specify-paths-to-textures-for-items-in-1-6.28391/latest) [wtórne]
- [ModDB devlog: obrót 45° i tryb swobodny](https://www.moddb.com/news/june-devlog) [wtórne, gra niezidentyfikowana]
- Repo: `docs/adr/0002-widok-3-4-i-drabinka-swiatla.md`, `docs/research/22b`, `43`, `43b`, `46`, `51`, `57`, `game/world/station/sprites/armchair.png`, `sofa.png`, `sofa_back.png`, `chair.png`, `game/world/station/rooms/break_room.tscn`, `game/world/lighting/prop.gd`, `game/world/lighting/room_shell.gd`, `game/world/actors/walk_area.gd`, `art/reference/game/1200_dzien.png`.
