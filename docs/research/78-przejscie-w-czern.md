# Przejście w czerń: jak gry kończą przekrój pokoju na dole i po bokach

Ticket: `docs/wayfinder/tickets/26-przejscie-w-czern-research.md`. Data researchu: **2026-11-09**. Tylko techniki, nic z fabuły gry nie jest publikowane.

Oznaczenia:
- **[zweryfikowane]**: widziałem na oficjalnym zrzucie ekranu (Steam `store.steampowered.com/api/appdetails`, 1920×1080) albo przeczytałem w tekście twórcy. Opis zrzutu to moja interpretacja obrazu, ale obraz jest pierwotny.
- **[wtórne]**: z wywiadu lub artykułu, nie z pierwszej ręki, albo streszczenie wyszukiwarki.
- **[z pamięci]**: pamiętam z gier, tu nie sprawdzone.
- **[wniosek]**: moja interpretacja albo propozycja.

## TL;DR

- **Nasz problem to nie „za mało gradientu”, tylko rodzaj krawędzi.** Gry, które to robią ładnie, nie używają gładkiego pasa alfa. Kończą pokój **twardą, nieregularną linią przekroju** (strop, płyta, wystające belki, gruz), a dalej jest płaska czerń. Miękkość bierze się z **oświetlenia** (żarówka gaśnie z odległością), nie z pasa czerni. [zweryfikowane na zrzutach TWoM, Sheltered, KRZ]
- **This War of Mine** [zweryfikowane na 4 zrzutach Steam]: każda kondygnacja kończy się grubą czarną płytą stropu z wyszczerbioną, „wyrwaną” krawędzią. Boki budynku to czarne słupy ścian nośnych albo urwane ściany z poszarpanym brzegiem. Najniższa kondygnacja przechodzi w ciemność, bo światło tam nie dochodzi, a **tło pod budynkiem to płaska czerń** z ręcznie niepoprawną, poszarpaną linią gruntu. Całość leży pod filtrem „węgiel/ołówek” (kreskowanie szumem na wierzchu obrazu). Gra jest 3D z kamerą równoległą do ekranu, nie rysunkiem 2D [wtórne: 80.lv]. Nie znalazłem żadnego talku z technikami krawędzi, więc „jak to jest zrobione” jest wnioskiem z obrazu.
- **Wspólny wzór w całej grupie:** (1) linia cięcia ma grubość i kolor (płyta, ściana w przekroju), (2) krawędź jest nieregularna, (3) poza cięciem jest czerń bez gradientu, (4) gaśnięcie robi światło.
- **Rekomendacja:** prototypować **wariant A** („płyta w przekroju” na dole i słup ściany z boku, 6–8 px grubości, rwany brzeg, potem czerń) z **dodatkiem z B** („gaśnięcie od światła”: podłoga ciemnieje na ostatnich ~32 px dzięki wygaszeniu światła ambient, z ditheringiem Bayer 4×4 zamiast 14 pasów). Wariant C (poszarpana mgła/szum) jako trzeci do porównania. Wszystkie trzy mieszczą się w 1 shaderze + ~30 linii w `_fade_*`. Sądzę też, że jedna z przyczyn „fatalnego” wyglądu to **alfa czerni w liniowej przestrzeni HDR** (patrz §5).

## 1. Katalog technik

### 1.1 Przekrój z płyt i ścian (twarda linia cięcia)

**Co to jest:** granica pokoju to widoczna grubość konstrukcji: płyta stropu, przekrój ściany, belki. Ciemna, gruba, bez tekstury albo ze słabą. Czerń zaczyna się za nią.

| Gra | Co widać | Źródło |
|---|---|---|
| **This War of Mine** | Strop = czarny pas ok. 15–25 px (przy 1080p) na całej szerokości, z wyszczerbionym spodem i górą, jakby pękła płyta. Przy ścianach nośnych: czarny pionowy słup (cała wysokość kondygnacji, ok. 40–60 px szerokości), do którego dochodzą płyty. Zewnętrzny dach i boki: cienka czarna rama konstrukcyjna. Gruz leży na płycie i wystaje poza nią. | [zrzuty Steam](https://store.steampowered.com/app/282070) [zweryfikowane]: `ss_9a8e87…`, `ss_2aebf3…`, `ss_28b7b1…`, `ss_642439…` |
| **Sheltered** | Każdy poziom ma pas ziemi 40–50 px (1080p) pod podłogą i nad sufitem: brązowa, chropawa, z kępami korzeni. Boki: ziemia / niedokopana skała, brzeg schodkowy, nieregularny. Pod ostatnim poziomem niezagospodarowany obszar jest ciemny, ale nie czarny. | [zrzuty](https://store.steampowered.com/app/356040) [zweryfikowane]: `ss_703220…`, `ss_82754b…` |
| **Kentucky Route Zero** | Przy krawędzi sceny „stół” z cegieł: twarda krawędź, bryła ciemnoszara z wzorem cegieł, potem czarne tło. Żadnej winiety. Płaskie wielokąty o ostrych krawędziach. | [zrzut](https://store.steampowered.com/app/231200) [zweryfikowane]: `ss_86f61b…` |
| **Fallout Shelter** | Przekrój krypty z pasami ziemi i skały [z pamięci], nie znalazłem źródła twórców. | [z pamięci] |
| **Stardew, Graveyard Keeper, To the Moon** (widok 3/4) | Gruby ciemny wierzch ściany jako obrys, czerń za. Nie przekrój, ale ta sama funkcja. Szczegóły w `docs/research/43-sciany-wnetrz-3-4.md`. | [zweryfikowane w poprzedniej notatce, nie ponawiane] |

**Wniosek [wniosek]:** u nas oś „dołu” jest czymś innym niż płyta w przekroju z boku: widzimy podłogę z góry, więc odpowiednik to **czoło płyty podłogowej** (pionowa ściana frontu o grubości 0,15–0,2 m = 6–8 px) pod przednią krawędzią podłogi. To jest ten sam gest co w Sheltered (pas ziemi pod podłogą) i w KRZ (cegły pod platformą).

### 1.2 Nieregularny, „wyrwany” kształt krawędzi

- **TWoM:** brzegi płyt i ścian mają wyszczerbienia 10–40 px, ułamane narożniki, odstające pręty/deski. Linia gruntu u dołu (zrzut 28b7b1/642439) jest poszarpana, nie prosta, i przechodzi w czerń. [zweryfikowane]
- **Sheltered:** skała po bokach ma schodkowe, pikselowe wypukłości i wąskie wgłębienia. [zweryfikowane]
- **KRZ:** brzeg jest prosty, ale szeroki „stół” cegieł rwie się wielokątem. [zweryfikowane]
- **Koszt dla nas [wniosek]:** jedna lista wierzchołków na pokój, generowana z seeda: skok y ±2–3 px co 6–14 px wzdłuż krawędzi (łamana), rysowana `ShapePainter.add_polygon`. Zero tekstur.

### 1.3 Ciemnienie od światła (pokój gaśnie, bo światło nie dochodzi)

- **TWoM:** pokoje są oświetlone prawie wyłącznie żarówkami i oknami; poza ich zasięgiem ściana i podłoga tonie w ciemności, **z zachowaną sylwetką mebli** (słabo widoczną). Najniższa kondygnacja (zrzut 28b7b1, dolna 1/6 kadru) jest „niedoświetlona”: gruz i drzwi są jeszcze widoczne, ale w prawie czerni. Okna dają plamy i snopy kurzu. [zweryfikowane na obrazie]
- **KRZ:** ciemność wynika z palety i z kilku źródeł; budynek wynurza się z granatu, a nie z czerni. [zweryfikowane na obrazie]
- **Sheltered:** na zrzutach pokoje mają ciepłe żarówki przy suficie z lokalnym winietowaniem koloru ścian; oświetlone „plamy” oddzielone ciemniejszymi. [zweryfikowane]
- **Wniosek [wniosek]:** to jest to, co nasza gra już ma (maski świateł, ekspozycja na pokój). Zamiast czarnego pasa na końcu lepiej **obciąć zasięg ambient i lamp przy krawędzi**, czyli podłoga i meble ciemnieją, a nie są zasłaniane. Meble stojące przy samej krawędzi dalej widać, ale ciemno.

### 1.4 Dithering i szum w pixel arcie

- **Dithering uporządkowany (Bayer 2×2/4×4)** zamiast pasów alfa: znany standard pixel artu dla gradientów w ograniczonej palecie [z pamięci]. Pasy 28 px / 14 kroków dają ok. 2 px na krok, czyli bardzo drobne, które w skali 2× wyglądają jak „plastikowa” winieta. Dither 4×4 daje ziarno widoczne przy 1 px.
- **Szum / ziarno:** nasz `display.gdshader` ma już `grain` 0,015 po konwersji sRGB [zweryfikowane w kodzie]. TWoM ma „kreskowanie” (kreski ołówka, kierunkowe, ~60 px długie) na wierzchu całego obrazu [zweryfikowane na obrazie, mechanizm: shader węgla, wtórne: TechRaptor/Game Developer].
- **Dither a skala:** nasz kadr jest renderowany 960×540 (`lit_view.tscn`, `size = Vector2i(960, 540)`) [zweryfikowane w kodzie], więc `FRAGCOORD` w shaderze to 1 px sztuki. Dither Bayer będzie nie rozmyty, o ile okno skaluje całkowicie.
- **Gry pixel-artowe z ditheringiem w winiecie:** nie mam źródła pierwotnego; Hyper Light Drifter i Gemini Rue (kropkowane cienie) wymieniam z pamięci [z pamięci]. Nie weryfikowałem.

### 1.5 Mgła

- **TWoM:** mgła jako warstwa dymu i kurzu przed ścianami; między sąsiednimi budynkami pas mgły rozjaśnia się z odległością [zweryfikowane na obrazie, zrzut 2aebf3]. Zewnętrze (niebo, drzewa, budynki tła) dostaje atmosferyczną perspektywę.
- Dla przekroju domu „wiszącego w czerni” mgła nie zastępuje cięcia; dobrze działa **za** pokojem (ciemny pas gradientu wchodzący w czerń) i jako dymek światła wokół lamp.

### 1.6 Podłoga, ściany działowe, drzwi na krawędzi

- **Podłoga:** w TWoM podłoga kończy się samą płytą (jej przód jest czarny); nie ma gradientu na deskach. W Sheltered podłoga kończy się jasnym cienkim pasem (próg) i ziemią. [zweryfikowane]
- **Ściany między pokojami:** w TWoM słup nośny jest czarną bryłą przechodzącą przez płytę; ściana działowa to cienka ciemna kreska bez przekroju. W Sheltered ściany działowe to krawędź koloru + cień. [zweryfikowane]
- **Drzwi na krawędzi:** w TWoM drzwi zewnętrzne to biały lub jasny prostokąt przy samej krawędzi budynku, jasno oświetlony, ucięty przez płytę. Drzwi dolne/boczne „wystają” z konstrukcji lekko, są czytelne przez jasny kontrast z czernią [zweryfikowane na obrazie 2aebf3]. U nas: język podłogi z wycieraczką (istniejące `TONGUE_M = 1,3 × 0,7 m`) powinien być **jaśniejszą plamą światła wychodzącą w czerń**, a nie luką w pasie alfa.

## 2. Wybrane źródła i ich wiarygodność

| Źródło | Co daje | Status |
|---|---|---|
| Zrzuty Steam TWoM, Sheltered, KRZ (API `appdetails`) | Wszystkie obserwacje o kształcie krawędzi, grubości płyt, ciemności | pierwotne, [zweryfikowane] |
| [80.lv: This War of Mine: A Game About Civilians In War](https://80.lv/articles/this-war-of-mine-a-game-about-civilians-in-war) | „Everything is 3D”, kamera równoległa do widza = 2.5D, tylko dalekie tło jest płaskie; styl: ręcznie rysowany + sepia | wywiad zespołu, [zweryfikowane] (nie mówi nic o krawędziach) |
| [Game Developer: Road to the IGF, 11 bit studios](https://www.gamedeveloper.com/design/road-to-the-igf-11bit-studios-i-this-war-of-mine-i-) | „time-lapse pencil-like sketch”, „hand drawn cels over movie footage”, brak realizmu | wywiad z dyrektorem artystycznym, [zweryfikowane] (nic o krawędziach) |
| TechRaptor, „Art and This War of Mine” | Shadery węgla; własny silnik (Liquid Engine); niskopoligonowe modele | [wtórne]: strona zwróciła 403, treść z streszczenia wyszukiwarki |
| Designer Notes 51 (Drozdowski, Marszał) | Odcinek z dyrektorem artystycznym | strona nie opisuje treści, audio niesłuchane, [niezweryfikowane] |

**Brak:** nie znalazłem żadnego talku GDC/devlogu 11 bit studios opisującego, jak powstają krawędzie przekroju i przejścia w czerń. Wszystko o krawędziach to analiza obrazu.

## 3. Czego te gry NIE robią

- Żadna z obejrzanych gier (TWoM, Sheltered, KRZ) nie ma **gładkiego czarnego gradientu pod pokojem** w stylu naszej winiety. TWoM ma ciemność od światła, ale granica to płyta, nie wygaszenie. [zweryfikowane]
- Nie ma dowodu, że TWoM ma specjalny shader „przejścia w czerń”: zbliżony efekt wynika z (a) czarnej geometrii płyt, (b) czarnego tła, (c) świateł. [wniosek]

## 4. Dopasowanie do naszego rzutu

Dane: niskie 3/4, głębia × 0,60, 40 px/m, kadr 960×540, postać 72 px, ściana tylna z licem (WALL_M), boki i dół bez ścian; w `dom_bryly.gd`: `FADE_PX = 28`, `FADE_STEPS = 14`, alfa `pow(t, 1.6)`, rysowane `ShapePainter` bez światła (`LIGHT_MODE_UNSHADED`) na masce podłogi slotu.

W rzucie 3/4 z góry oglądamy podłogę, więc „przekrój z boku” zamienia się w:
- **Dół:** widoczne **czoło płyty podłogowej** (pionowo) pod przednią krawędzią podłogi: wysokość = grubość płyty × px/m = 0,15–0,20 m × 40 = **6–8 px**. Nie skalujemy przez 0,60, bo to wymiar pionowy.
- **Boki:** widoczny **przekrój ściany** (wierzch + czoło) jako słup o szerokości = grubość ściany 0,12–0,20 m × 40 = **5–8 px** (u nas wierzch ścian `RoomBox.WALL_TOP_M` już istnieje jako rama między pokojami). Z boku od zewnątrz: urwana ściana (wierzch nieregularnej wysokości) zamiast pełnej ramy.
- **Narożnik tylny:** lico tylnej ściany kończy się pionową krawędzią; tu wierzch ściany bocznej dochodzi do stropu. Zostawić 1–2 px jaśniejszej krawędzi na licu (światło odbite od przekroju).

## 5. Koszt w naszym Godot

| Technika | Wykonanie | Koszt | Uwagi |
|---|---|---|---|
| Czoło płyty, słup ściany | `ShapePainter.add_polygon` (kolor z palety, bez tekstury) | ~30 linii w `_fade_bottom/_fade_side`, 0 assetów | działa z istniejącą maską podłogi slotu |
| Nieregularna krawędź | łamana z seeda (`RandomNumberGenerator` z `hash(slot)`) | ~15 linii | deterministyczna, nie miga |
| Ciemnienie od światła | ambient `PointLight2D` pokoju (`_flat_light`) ma teksturę prostokąta; dodać gradient obcinający przy dolnym/bocznym brzegu (tekstura światła 960×540 z rampą 32 px lub osobna warstwa `PointLight2D` w trybie SUB) | 1 tekstura generowana w kodzie (`light_textures.gd`) | zero shadera; działa też na meble i postać przy brzegu |
| Dither Bayer 4×4 | `canvas_item` shader z `FRAGCOORD` i macierzą 4×4, nakładany unshaded na maskę slotu | ~20 linii shadera, 1 `ShaderMaterial` | przy 960×540 `FRAGCOORD` = 1 px sztuki |
| Zakłócenie krawędzi szumem | `hash`/value noise w shaderze, przesunięcie progu | +10 linii | |
| Mgła/ziarno | `display.gdshader` już ma `grain`; dodać lokalną mgłę (gradient PointLight) | niski | |

**Podejrzenie przyczyny obecnego wyglądu [wniosek, niezweryfikowane]:** pasy czerni są rysowane w widoku HDR liniowym (`display.gdshader` konwertuje potem do sRGB). Alfa `pow(t,1.6)` w przestrzeni liniowej, po konwersji sRGB, daje przejście, które wygląda jak „skok” w jasnych końcach i długi ogon w ciemnych; 14 kroków po 2 px potęguje schodkowość. **Test:** narysować tę samą rampę z krzywą w sRGB (np. alfa liniowa w sRGB = `pow(t, 2.2)` alfa w liniowym) i porównać obok siebie. Nie sprawdzałem tego w grze.

## 6. Warianty do prototypu na Poligonie Dom

Wszystkie z przełącznikiem w menu Poligonu (zgodnie z regułą „oceniać w grze, nie na zrzutach”).

### Wariant A: „Płyta w przekroju” (inspiracja: TWoM, Sheltered, KRZ)

- **Dół:** czoło płyty 7 px pod przednią krawędzią podłogi, kolor `#0d0a09` z górną 1 px krawędzią `#2a211b` (jasna krawędź przekroju). Pod nim czerń `#000`.
- Dolna krawędź płyty rwana: łamana z krokiem 8–14 px, skok y ∈ {0, 1, 2, 3} px, z 1–2 „odłamami” (trójkąt 6×4 px) na 100 px szerokości; kilka pikseli gruzu (2×2 px) na płycie przy krawędzi.
- **Boki:** słup ściany 6 px szerokości, wysokość od wierzchu lica do czoła płyty, nieregularny górny brzeg (±3 px), kolor jak wierzchy ścian między pokojami.
- **Drzwi na krawędzi:** w czole płyty przerwa 52 px (1,3 m), a w czerni pod nią plama światła: trapez 52→84 px, wys. 28 px, jasność 0,35 światła z wnętrza, wygaszana liniowo.
- Koszt: ok. 50 linii, 0 shadera. Ryzyko: wygląda „zbyt rysunkowo”, jeśli kolory cięcia odstają od palety.

### Wariant B: „Gaśnie od światła” z ditheringiem (inspiracja: TWoM niskie kondygnacje, pixel art)

- Bez czarnych pasów. Ambient pokoju dostaje **maskę zasięgu**: pełna ekspozycja do 32 px od krawędzi, potem spadek do 0 na ostatnich 32 px (dół) i 40 px (boki).
- Spadek: krzywa `t^2,0` w sRGB (czyli ~`t^4,4` w liniowym), 8 poziomów, **dither Bayer 4×4**: próg `(bayer(x%4,y%4) + 0,5)/16`, kwantyzacja `floor(t * 8 + próg) / 8`.
- Lampy zachowują własny zasięg, więc meble przy lampie przy krawędzi jeszcze widać.
- Podłoga i meble ciemnieją, nie ma czoła płyty; ostatni 1 px podłogi to czerń (zamknięcie).
- Koszt: tekstura rampy + 20 linii shadera. Ryzyko: dither może migotać przy ruchu kamery, jeśli `FRAGCOORD` nie jest przyklejony do ekranu (powinien być).

### Wariant C: „Poszarpana mgła” (inspiracja: TWoM mgła i kreskowanie, KRZ granat)

- Jak B, ale **próg krawędzi przesuwany szumem**: amplituda 8 px, długość fali 48 px (1D value noise wzdłuż krawędzi) + drobny szum 2 px; szerokość strefy 40 px (dół) i 48 px (boki).
- Kolor końcowy nie czysta czerń, tylko `#03040a` (zimny granat, gotowe do `grade` w `display.gdshader`), przechodzący w `#000` na ostatnich 6 px. [wniosek: sprawdzić, czy człowiek akceptuje granat zamiast czerni.]
- Opcjonalnie ruchome ziarno kurzu (`LightMasks.DUST`) zagęszczone w strefie przejścia.
- Koszt: shader ~35 linii. Ryzyko: efekt „winiety fotograficznej”, najbliższy temu, co człowiek ocenił jako fatalne, jeśli szum będzie za miękki.

**Kolejność oceny [wniosek]:** A → B → C. Jeśli A i B wyglądają dobrze osobno, sprawdzić A+B razem (płyta + gaśnięcie na ostatnich 16 px wnętrza).

## 7. Czego nie zweryfikowałem

- Żadnego primary source od 11 bit studios o technice krawędzi, ściemniania lub winiet w TWoM. Wniosek o „czarnych płytach + świetle” pochodzi z oglądania 4 zrzutów, nie z wypowiedzi twórców.
- **Fallout Shelter:** nic poza pamięcią; Behaviour/Bethesda nie opisali tego w znalezionych materiałach. Nie pobierałem zrzutów (gra nie jest na Steamie).
- **Unpacking, Gemini Rue, Eastward, Children of Morta, Stardew, Graveyard Keeper, To the Moon** w tym researchu: tylko wnioski z notatki `43-sciany-wnetrz-3-4.md` (sprawdzone wcześniej), plus pamięć. Zrzuty Unpacking i Eastward pobrałem w liście URL, ale nie oglądałem. Pliki Gemini Rue nie zostały pobrane, bo ID 204450 w Steam to inna gra (Call of Juarez); nie szukałem właściwego.
- **Dithering w pixel arcie:** brak źródeł pierwotnych; podstawy Bayer 4×4 z pamięci, parametry (8 poziomów, krzywe) to moja propozycja do prototypu.
- **Hipoteza o liniowej alfa:** nie testowana w grze.
- **Wartości liczbowe wariantów** (px, kolory, kroki) to punkty startowe, nie dane z gier.
- Wywiad TechRaptor (403) i Designer Notes 51 (audio) nie przeczytane/odsłuchane.
