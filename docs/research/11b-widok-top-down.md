> Kopia z game1 (`repo/game1/docs/research/11b-widok-top-down.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Widok top-down / 3/4 (opcja B): pogłębienie

Ticket: `docs/wayfinder/tickets/11-widok-i-poruszanie.md`. Data researchu: 2026-10-27. Uzupełnia `06-widok-i-swiat.md` (wzorce i struktura świata) i `02-pixel-art-oswietlenie.md` (techniki światła w Godocie). Tamtych ustaleń tu nie powtarzam.

**Aktualizacja w trakcie researchu:** użytkownik wybrał widok 3/4 top-down w stylu Stardew Valley: cała postać widoczna, swobodny ruch WASD w 8 kierunkach, sprite'y w 4 kierunkach, dynamiczne światło. Sekcje 1–6 zostają jako uzasadnienie i mapa ryzyk. Sekcja 7 odpowiada na pytanie „jak i za ile" w kwestii rozmiarów kafli i postaci.

Założenia z decyzji: Godot 4.7, typowany GDScript, światła 2D + normal mapy w viewporcie 640×360 ze skalowaniem całkowitym, cząsteczki śniegu, fałszywa mgła, post-process.

## Zastrzeżenie o jakości źródeł

- **[źródło]**: potwierdzone w pobranym tekście źródła pierwotnego (dokumentacja Godota, wpis twórcy, dokumentacja narzędzia).
- **[źródło wtórne]**: streszczenie lub artykuł prasowy, nie wypowiedź twórcy wprost.
- **[wniosek]**: moja interpretacja, szacunek lub wiedza ogólna niepotwierdzona w tym researchu.

Nie udało się pobrać: TechRaptor o Children of Morta (403), strona Kickstartera Sea of Stars (403), IndieDB Eastward (403), blog techniczny Radical Fish. Najmocniejszym znalezionym źródłem jest artykuł głównego programisty Graveyard Keeper. To gra top-down 3/4 w pixel arcie z dynamicznym światłem, normal mapami i porą dnia, czyli technicznie najbliższy precedens.

## 1. Precedensy

| Gra | Widok | Światło i głębia | Zespół / czas | Pewność |
|---|---|---|---|---|
| **Graveyard Keeper** (Lazy Bear, Unity) | top-down 3/4 | Normal mapy na **każdym** sprite'cie, malowane ręcznie: światło z 4 stron pędzlem, skrypt składa normal mapę (wskazują Sprite Lamp). Zwykłe światła Unity dla pochodni i pieców. Ambient z gradientu wg pory dnia plus 10 LUT-ów (pora dnia/strefa). Własny shader rozstrzyga, czy światło jest „przed" czy „za" sprite'em (patrz §2). **Cienie to sprite'y obracane wokół punktu**, nie okludery: do 4 na obiekt (słońce + 3 najbliższe światła), ok. 10 uniwersalnych sprite'ów cienia. Mgła z wielu poziomych warstw chmur: wyższe części obiektów przykrywa mniej warstw. | b.d. | [źródło] [Cherkasov, „How the graphics effects are made"](https://slava.lazybeargames.com/graveyard-keeper-how-the-graphics-effects-are-made), kopia: [gamedeveloper.com](https://gamedeveloper.com/programming/graveyard-keeper-how-the-graphics-effects-are-made) |
| **Graveyard Keeper 2** | j.w. | Prawie każdy obiekt zamodelowany w 3D (Blender), pixel art rzutowany na model ze stałego kąta, żeby mieć poprawne światło i cienie. Powód: „GK1 used a lot of shadow trickery and had a lot of limitations", cienie płotów „approximate and buggy". Koszt: modelowanie „kind of a nightmare". | b.d. | [źródło, wywiad] [80.lv](https://80.lv/articles/almost-every-object-in-this-stardew-valley-style-cemetery-sim-is-actually-3d) |
| **Eastward** (Pixpil) | top-down 3/4 | Dev na IndieDB: „customized deferred shading pipeline" (nie udało się otworzyć strony, cytat za wynikiem wyszukiwania). Własny silnik na MOAI, import warstw z Aseprite. | Start w 2015 z 3 osobami (programista, pixel artist, designer), ok. 10 osób w 2019, premiera 2021 (ok. 6 lat). | [źródło wtórne] [filmstories](https://filmstories.co.uk/?p=82862), [Nintendo: wywiad z Tommo Zhou](https://www.nintendo.com/us/whatsnew/how-the-developers-began-making-then-remaking-eastward) |
| **Sea of Stars** (Sabotage, Unity) | top-down 3/4 | Wg materiałów z Kickstartera: dynamiczne światło sprite'ów z normal mappingiem, zapis głębi pikseli, odbiór cieni, wolumetria, własny render pipeline. Oficjalnie: dynamiczne światło powiązane z cyklem dnia i nocy. | Studio z The Messenger, kilkuletnia produkcja | [źródło wtórne] (strona KS: 403), [Sabotage press](https://sabotagestudio.com/press-release/sea-of-stars-the-highly-anticipated-turn-based-rpg-from-sabotage-studio-primed-for-playstation-consoles-in-2023/) |
| **Children of Morta** (Dead Mage) | top-down 3/4 | Wg TechRaptor: animacje pixel art skalowane ok. 4× do Full HD, a światło dynamiczne w **wysokiej** rozdzielczości, celowo niepikselowe. Normal mapy niepotwierdzone. | b.d. | [źródło wtórne] [TechRaptor](https://techraptor.net/content/how-dead-mage-created-the-art-for-children-of-morta) (403, treść za wyszukiwaniem), [Engadget](https://www.engadget.com/2018/03/22/children-of-morta-hands-on-indie-xbox-gdc/) |
| **CrossCode** (Radical Fish) | top-down 3/4 z poziomami wysokości | Dev (Felix Klein): mocno zmodyfikowany impact.js, „top down view with a simplified 3D collision". | b.d.; ponad 3 lata Early Access | [źródło] [html5gamedevs, 2013](https://www.html5gamedevs.com/topic/847-techdemo-crosscode-throwing-energy-balls-at-everything) |
| **Hyper Light Drifter** (Heart Machine, GameMaker) | top-down 3/4 | Brak źródeł o technice światła. | Kickstarter 2013 (cel 27 tys. USD, zebrane ok. 650 tys.), premiera 03.2016; mały zespół z kolektywu Glitch City, bez wydawcy | [źródło] [MCV](https://www.mcvuk.com/development-news/when-we-made-hyper-light-drifter/), [Wikipedia](https://en.wikipedia.org/wiki/Hyper_Light_Drifter) |

Wnioski z precedensów **[wniosek]**:
- Każdy precedens top-down z „ładnym" dynamicznym światłem ma **własny pipeline renderowania** (Eastward: deferred, Sea of Stars: custom pipeline, GK: własne shadery i sprite'owe cienie) albo przechodzi na geometrię 3D (GK2). Nie znalazłem precedensu z takim efektem na samych gotowych światłach 2D silnika.
- Zespoły są wieloosobowe i pracują po kilka lat na pełen etat. Nie znalazłem precedensu solo z 5–10 h/tydz. W widoku bocznym jest podobnie (zob. 06), więc to nie jest argument tylko przeciw top-down.
- Gatunkowo top-down narracyjny/detektywistyczny to dobrze znany format (RPG-makerowe gry narracyjne, Eastward), ale znalezione precedensy z mocnym światłem to głównie action-RPG i RPG.

## 2. Światła 2D + normal mapy w top-down w Godocie 4

### Co mówi dokumentacja [źródło]
- `PointLight2D.height`: „The height of the light. Used with 2D normal mapping. The units are in pixels, e.g. if the height is 100, then it will illuminate an object 100 pixels away at a 45° angle to the plane." ([PointLight2D](https://docs.godotengine.org/en/stable/classes/class_pointlight2d.html))
- `DirectionalLight2D.height`: 0.0 oznacza światło równoległe do powierzchni, 1.0 prostopadłe. Height wpływa tylko na powierzchnie z normal mapą, **nie na cienie**. Cienie kierunkowe są zawsze nieskończenie długie, a cienie od PointLight2D rzucane są od środka światła. ([2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html))
- Maski: `Occluder Light Mask` + `Shadow > Item Cull Mask` wybierają, które okludery rzucają cień dla danego światła. `Range > Item Cull Mask` wybiera, które węzły dostają światło (ta sama strona).
- Okludery mogą być częścią `TileMapLayer` (warstwa okluzji per kafel, w sekcji Rendering) ([Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)).
- Dokumentacja **nie ma** wskazówek dla gier top-down ani o interakcji świateł z Y-sortem.
- Tutorial Catlike Coding „True Top-Down 2D" (Godot 4.3): ściany z okluzją są „always in their own shadow, which is fine". Używa dwóch świateł z różnymi maskami, żeby zasymulować światło „wyżej" niż obiekty. Ostrzega, że światła z cieniami są drogie, i zaleca zaokrąglanie pozycji obiektów, bo inaczej pojawiają się fantomowe cienie. Ważne: to **prawdziwy** top-down (rzut pionowy), nie 3/4. ([Catlike Coding](https://catlikecoding.com/godot/true-top-down-2d/4-light-and-shadow/))

### Problem geometryczny 3/4 [wniosek, z zasady działania opisanej w docs]
Światła 2D w Godocie liczą wszystko na jednej płaszczyźnie XY plus wirtualne Z (height). Widok 3/4 udaje dwie różne płaszczyzny: podłogę (pozioma) i ściany oraz postacie (pionowe, zwrócone do kamery). Z tego wynikają konkretne artefakty:

1. **Cienie okluderów idą „przez" ściany i dachy.** Okluder to wielokąt na płaszczyźnie, a cień ciągnie się od środka światła w nieskończoność ekranu. Latarnia na południe od domu rzuca cień podstawy domu na północ, czyli na ekranie w górę, prosto na narysowaną elewację i dach tego domu. W rzucie 3/4 elewacja leży właśnie tam. Tutorial Catlike to akceptuje, bo w true top-down ścian nie widać.
2. **Światło „za" sprite'em.** Lampa stojąca za drzewem (wyżej na ekranie) oświetla przednią, widoczną ścianę drzewa, bo normal mapa nie wie, że ta strona jest odwrócona od światła. Graveyard Keeper miał dokładnie ten problem i rozwiązał go własnym shaderem: sprawdza znak odległości na osi głębokości i gasi światło, gdy jest „za" sprite'em **[źródło]**.
3. **Pozycja światła a wysokość źródła.** Lampa na słupie jest na ekranie narysowana wyżej niż punkt na ziemi pod nią. Środek światła trzeba więc wybrać: albo przy żarówce (wtedy podłoga jest oświetlona przesuniętą plamą), albo przy podstawie (wtedy halo wokół żarówki „wisi" za nisko). W praktyce stosuje się dwa światła: jedno na podłogę, drugie addytywne na halo.
4. **Normal mapy: podłoga a ściany.** Dla podłogi normalna wskazuje „do kamery" (płasko). Dla frontowej ściany w 3/4 normalna powinna wskazywać na południe ekranu. Laigter generuje normalne z jasności i kształtu sprite'a, więc nie wie, że kafel to pionowa ściana. Ściany i podłogi trzeba więc rozdzielić na osobne kafle lub warstwy i ściany poprawiać ręcznie albo presetem. Uwaga z forum Godota: materiał per-kafel w TileSecie potrafił „gubić" kanał niebieski normal mapy ([forum](https://godotforums.org/d/37002-canvastexture-normalmap-blue-channel-what-does-it-do), [źródło wtórne]).

### Obejścia (od najtańszego) [wniosek, jeśli nie zaznaczono inaczej]
- **Większość świateł bez cieni.** Okludery zostają tylko tam, gdzie cień jest fabularnie ważny (latarka we wnętrzu, okno). Maskami (`Item Cull Mask`) wyłączyć odbiór cienia przez dachy i elewacje. Rozwiązanie z dokumentacji, zastosowanie moje.
- **Okludery tylko w pomieszczeniach widzianych „od góry"** (wnętrza bez frontowych ścian lub z przyciętymi ścianami), gdzie geometria jest bliższa true top-down.
- **Cienie postaci i obiektów jako sprite'y** (owal pod stopami albo obracany sprite cienia jak w GK) zamiast `LightOccluder2D`. [źródło: GK robi tak w produkcji]
- **Własny shader „przód/tył"** w stylu GK: porównanie Y światła z Y podstawy sprite'a. Mały shader, ale wymaga nauki shaderów Godota.
- **HD-2D** (sprite'y w 3D, technika 2 z dokumentu 02): rozwiązuje problemy 1–3 „za darmo", bo geometria jest prawdziwa. To droga GK2, ale z kosztem modelowania („nightmare"). Dla tego projektu to raczej poza zasięgiem.

### Y-sort [źródło]
- `CanvasItem.y_sort_enabled`: „If true, this and child CanvasItem nodes with a higher Y position are rendered in front of nodes with a lower Y position." ([CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html))
- TileSet: `Y Sort Origin` per kafel („vertical offset to use for tile sorting based on its Y coordinate"), działa po włączeniu Y Sort Enabled na `TileMapLayer`. Do tego `Z Index` per kafel ([Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)).
- [wniosek] Sam Y-sort jest prosty: origin sprite'a ustawia się u stóp. Typowe pułapki to duże obiekty (dom, ciężarówka, długi płot), które trzeba pociąć na części, bo jeden punkt sortowania nie wystarcza, oraz postać przechodząca „za" drzewem, co wymaga przezroczystości lub sylwetki.

### Iluzja wysokości [wniosek + źródło GK]
- Mgła warstwowa jak w GK (wyższe partie mniej zamglone) to tani i sprawdzony trik **[źródło]**.
- Poziomy wysokości (skarpy, pomosty) jak w CrossCode wymagają uproszczonej kolizji 3D, co twórcy opisują jako mocną modyfikację silnika **[źródło]**. Dla gry śledczej można tego uniknąć: teren płaski, a różnice wysokości są tylko wizualne (schody jako przejście lub obszar kolizji).

## 3. Koszt assetów vs widok boczny

| Element | Widok boczny 2.5D | Top-down 3/4 | Uwagi |
|---|---|---|---|
| Kierunki postaci | 1 rysowany (lustro) + ewentualnie przód/tył do rozmów | 4 (S, N, W/E z lustrem, czyli 3 rysowane) albo 8 (5 rysowanych + lustra) | [wniosek] 4 kierunki to ok. 3× pracy animacji chodu i bezczynności względem side; 8 kierunków ok. 5×. Dla gry bez walki 4 kierunki w zupełności wystarczą. |
| Tło / lokacja | warstwy paralaksy malowane jako obraz | tileset (podłoga, ściany, przejścia) + obiekty | [wniosek] Top-down wymaga więcej **unikalnych obiektów** (meble, płoty, latarnie, auta widziane z góry), ale tileset pozwala szybko składać i zmieniać układ. |
| Autotiling | zwykle niepotrzebny | `TileMapLayer` + terrain sets (Match Corners and Sides / Corners / Sides) [źródło: docs] | Terreny potrzebują kafli przejść (np. 47 lub 16 wariantów na parę terenów) [wniosek, liczby typowe dla trybów 3×3 i 2×2]. Śnieg–droga, śnieg–lód, śnieg–ziemia: kilka zestawów. |
| Kolizje, nawigacja, okluzja | ręczne wielokąty na tle | per kafel: warstwy fizyki, nawigacji i okluzji w TileSecie [źródło: docs] | W top-down to praca „raz na kafel", potem działa wszędzie. |
| Normal mapy | na warstwę lub sprite; światło z boku działa naturalnie | na każdy kafel i obiekt, z rozróżnieniem podłoga/ściana | [wniosek] Laigter działa na pojedyncze obrazy, czyli też na atlas tilesetu, ale ściany 3/4 wymagają poprawek (§2). GK malował normale ręcznie z 4 kierunków światła i opisuje to jako „fairly simple" [źródło]. |
| Wnętrza | przekrój „domku dla lalek", tani | osobne mapy z kafli; ściany frontowe przycięte lub przezroczyste | [wniosek] Wnętrza w top-down są tanie przy tilesecie, droższe przy unikalnych meblach. |
| AI (Pixellab) | side-scroll maps, animacje | `create_character` z `n_directions` 4 lub 8 (domyślnie 8, kierunki S/W/E/N + przekątne), Pro: rotacja z jednego obrazu na 8 kierunków, `create_topdown_tileset` z łańcuchowaniem przejść terenów [źródło: [MCP docs](https://api.pixellab.ai/mcp/docs), [8 rotations pro](https://www.pixellab.ai/docs/tools/create-8-rotations-pro), [API](https://www.pixellab.ai/pixellab-api)] | [wniosek] Top-down jest dla Pixellab „natywnym" przypadkiem (rotacje + tilesety), co częściowo niweluje różnicę kosztu kierunków. Jakość spójności nadal do sprawdzenia na trialu (zob. 08). |

Gotowe paczki: istnieją komercyjne top-down tilesety z normal mapami (np. [MinZinn, 32×32](https://minzinn.itch.io/dynamic-tileset-landscape)), ale zimowy nordycki styl trzeba by i tak rysować samemu **[wniosek]**.

## 4. Koszt kodu

| Element | Top-down | Trudność (początkujący) | Źródło |
|---|---|---|---|
| Ruch WASD/pad | `CharacterBody2D` + `Input.get_vector` + `move_and_slide()`. Przy 8 kierunkach ruchu i 4 kierunkach sprite'a animację wybiera się wg dominującej osi wektora; przy przekątnej warto zachować poprzedni kierunek, żeby postać nie migała | niska | [wniosek, standardowy wzorzec Godota] |
| Point&click | `NavigationRegion2D` (lub warstwa nawigacji w TileSecie) + `NavigationAgent2D`: ustawić `target_position` przy kliknięciu, w `_physics_process` iść do `get_next_path_position()`, sprawdzać `is_navigation_finished()`. Agent **nie** porusza rodzicem sam. Pułapki: pusta ścieżka przed pierwszą synchronizacją mapy, drgania przy ustawianiu celu co klatkę, cofanie się przy dużej prędkości. | niska-średnia | [źródło] [NavigationAgents](https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html) |
| Kolizje | kafle + `CollisionShape2D` u stóp postaci (mały prostokąt/kapsuła, nie cały sprite) | niska | [wniosek] |
| Y-sort | jeden przełącznik + originy | niska; średnia dla dużych obiektów | [źródło + wniosek, §2] |
| Kamera | `Camera2D` z limitami mapy, wygładzanie; w low-res viewporcie wygładzanie kamery może „pływać" o subpiksele | niska-średnia | [wniosek; zastrzeżenie o ruchu subpikselowym w trybie viewport w dok. 02] |
| Interakcja z obiektami | `Area2D` wokół obiektu + najbliższy obiekt w zasięgu, albo kliknięcie | niska | [wniosek] |

Porównanie z widokiem bocznym **[wniosek]**: w side-view ruch to jedna oś i prawie nie ma sortowania ani nawigacji. Top-down dokłada Y-sort, 4 kierunki animacji, nawigację lub kolizje 2D i kamerę w dwóch osiach. Każde z tych zadań jest dobrze udokumentowane i mieści się w „kilka wieczorów" dla kogoś znającego Javę/Pythona. Najdroższy element kodowy to nie ruch, tylko **światło w 3/4** (§2), jeśli ma wyglądać jak w referencjach.

## 5. Konkretne lokacje w top-down [wniosek]

- **Zaśnieżony las**: dobrze. Drzewa jako obiekty z Y-sortem, ścieżki terrainem śnieg/udeptany śnieg, latarka jako `PointLight2D` z teksturą stożka obracaną wg kierunku postaci (w top-down naturalne, w side-view stożek świeci tylko w lewo lub prawo). Ślady stóp jako sprite'y zostawiane na śniegu to tania mechanika śledcza, w side-view praktycznie niemożliwa. Ryzyko: cienie pni od okluderów wchodzą na korony (§2.1), więc lepiej użyć sprite'owych cieni.
- **Zamarznięte jezioro**: bardzo dobrze. Duża płaska tafla, specular/połysk lodu przez normal i specular mapę (`CanvasTexture` ma Specular i Shininess, wysoki Shininess daje „mokry" połysk [źródło: docs 2D lights]), przerębel i ślady na lodzie czytelne z góry. Pustka jako nastrój.
- **Rynek miasteczka**: lepiej niż w side-view. Plac, ludzie i rutyny NPC widoczne naraz, co ułatwia obserwację rutyn. Ryzyko: fasady budynków to dokładnie miejsce artefaktów cieni 3/4 i dużych obiektów do Y-sortu.
- **Wnętrza wielopokojowe** (posterunek, dom): dobrze. Mapa kafli z pokojami, ściany frontowe przyciemnione lub ucięte, okludery mają tu najwięcej sensu (patrz §2, obejścia). Każde wnętrze to osobna scena, zgodnie z „zestawem lokacji" z dokumentu 06.
- **Samochód (wsiadanie/wysiadanie)**: auto jako obiekt z 4 (lub 2 + lustro) widokami. Wsiadanie przez interakcję (fade / krótka animacja drzwi), potem przejście do mapy podróży z dokumentu 06. Sterowanie autem w top-down jest technicznie łatwe, ale to osobny system, więc lepiej go nie robić. Reflektory jako dwa `PointLight2D` ze stożkiem dają efekt nieosiągalny w side-view.

## 6. Porównanie i rekomendacja

| Kryterium | Side-view 2.5D | Top-down 3/4 |
|---|---|---|
| Zgodność z referencjami światła (Replaced, Octopath) | wysoka (Replaced jest boczny) | średnia: Octopath to HD-2D 3/4, ale w 3D; w czystym 2D światło 3/4 wymaga trików |
| Natywne światła 2D + normal mapy w Godocie | działają „zgodnie z fizyką" (ściana = płaszczyzna ekranu) | działają, ale z artefaktami cieni przez ściany/dachy i światłem „zza" sprite'a; potrzebne maski, sprite'owe cienie lub własny shader |
| Koszt animacji postaci | 1 kierunek | 3 rysowane (4 kierunki); Pixellab to łagodzi |
| Koszt otoczenia | warstwy tła, unikalne | tileset + obiekty, łatwa iteracja układu |
| Kod ruchu i świata | najprostszy | prosty-średni (Y-sort, nawigacja, kamera 2D) |
| Rynek, rutyny NPC, obserwacja | słabiej (jedna linia) | **lepiej** (przestrzeń, widać kto gdzie idzie) |
| Las, jezioro, ślady, latarka, reflektory | ograniczone | **lepiej** (stożki światła, ślady, tafla lodu) |
| Wnętrza wielopokojowe | przekrój, tanio | mapa kafli, tanio-średnio |
| Gotowe wzorce dla początkujących (tutoriale Godota) | dużo (platformówki) | bardzo dużo (top-down RPG) |
| Precedensy z mocnym światłem | Replaced, Backbone (zespoły) | GK, Eastward, Sea of Stars (zespoły + własne pipeline'y) |

### Rekomendacja [wniosek]
Top-down 3/4 jest **wykonalny i mechanicznie lepiej pasuje** do gry śledczej z rutynami NPC, lasem, jeziorem i latarką. Zyskuje się przestrzeń, ślady i stożki światła. Pod warunkiem, że cel oświetleniowy zostanie świadomie przeformułowany: **nie „Replaced z góry"**, tylko „Graveyard Keeper/Eastward w nocy". Konkretnie:
- światła bez cieni jako domyślne, okludery tylko we wnętrzach i w wybranych scenach,
- cienie postaci i obiektów jako sprite'y,
- normal mapy tylko tam, gdzie widać efekt (postacie, ściany wnętrz, lód), a nie na każdym kaflu,
- 4 kierunki postaci.

Ryzyka:
1. **Światło 3/4 to największa niewiadoma.** Wszystkie znalezione precedensy budowały własny pipeline albo przeszły na 3D. Przed decyzją jedno-dwuwieczorowy prototyp: ulica z latarnią, dom z fasadą, postać, drzewo. Sprawdzić cienie przez fasadę i światło „zza" drzewa.
2. **Mnożnik animacji** ×3 przy każdym NPC. Przy kilkunastu NPC z rutynami to realny koszt; sprawdzić Pixellab na jednej postaci w 4 kierunkach.
3. **Pokusa poziomów wysokości i jazdy autem**: oba to drogie systemy, lepiej je świadomie odrzucić.
4. Normal mapy dla ścian 3/4 nie wyjdą automatycznie z Laigtera; zaplanować ręczne poprawki.

Jeśli prototyp z ryzyka 1 wypadnie źle, side-view z dokumentu 06 pozostaje bezpieczniejszą opcją dla referencji Replaced.

## 7. Rozmiar kafla i postaci przy bazie 640×360

### Co wiadomo o porównywalnych grach
| Gra | Kafel | Postać (sprite w świecie) | Efektywna baza | Pewność |
|---|---|---|---|---|
| Stardew Valley | 16×16 | NPC 16×32, portrety 64×64 | Kafel 16 px rysowany jako `Game1.tileSize` = 64 px ekranu (4×), więc przy 1920×1080 i zoomie 100% to ok. **480×270**. Zoom gracza 75–200%. | Rozmiary: [źródło wtórne, forum modderów](https://forums.stardewvalley.net/threads/sprite-size-first-time-modding-sv.7128/latest), [wiki modding](https://stardewmodding.wiki.gg/wiki/Tutorial:_Replacing_an_Image). `tileSize` w formułach: [wiki, Game Fundamentals](https://stardewvalleywiki.com/Modding:Modder_Guide/Game_Fundamentals). Wartość 64 i ok. 480×270: [wniosek], niezweryfikowane w kodzie. |
| CrossCode | b.d. (powszechnie 16, niepotwierdzone) | b.d. | Tryb „Original" daje płótno **568×320** | [źródło wtórne, Steam, gracz](https://steamcommunity.com/app/368340/discussions/1/1729837292642203950) |
| Eastward, Sea of Stars, Children of Morta | b.d. | b.d. | b.d. | Nie znalazłem źródeł; dane trzeba by zmierzyć na zrzutach lub wyciągniętych sprite'ach. |

Zasada praktyka pixel artu (Raymond Schlitter, SLYNYRD): rozmiar sprite'a najlepiej mierzyć w kaflach. „1 tile wide by 2 tiles tall" to jeden z najczęstszych rozmiarów. Głowa powinna zajmować 1/3–1/2 małego sprite'a, bo realistyczne proporcje zamieniają go w „stick figure". 4 kierunki wystarczą do ruchu w 8 kierunkach, a brak przekątnych „only becomes jarring if the sprite is large and detailed" **[źródło]** ([Pixelblog 22](https://www.slynyrd.com/blog/2019/10/21/pixelblog-22-top-down-character-sprites)).

### Ograniczenia Pixellab [źródło: [MCP docs](https://api.pixellab.ai/mcp/docs)]
- `create_character`: `size` domyślnie 48, maks. 128 (standard/pro) lub 256 (v3). Postać zajmuje ok. 60% wysokości płótna, więc postać 40 px wymaga `size` ok. 64–68. Widoki: „low top-down" (domyślny), „high top-down", „side", „oblique" (beta, tylko 4 kierunki, maks. 128).
- `create_topdown_tileset`: kafle **16 lub 32** (standard), 64 tylko w trybie pro. **24 px nie jest obsługiwane.**
- Animacje (v3): 4–16 klatek, szer. × wys. × klatki ≤ 8 × 256 × 256.

### Wpływ rozmiaru [wniosek; obliczenia własne]
Udział postaci w wysokości ekranu decyduje o czytelności twarzy i mowy ciała. W Stardew postać 32 px na bazie ok. 270 px to ok. 12%.

| Wariant (baza 640×360) | Widać kafli | Postać / wys. ekranu | Twarz, mowa ciała | Normal mapy | Koszt rysowania / AI |
|---|---|---|---|---|---|
| A: kafel 16, postać 16×32 | 40×22,5 | 8,9% (mniejsza niż w Stardew) | twarz ok. 6–8 px: oczy jako 1–2 px, emocje tylko w portretach | słabe, mało pikseli na „bryłę" | najtańszy; tileset 16 natywny w Pixellab |
| **B: kafel 16, postać ok. 20–24×40** | 40×22,5 | ok. 11% (jak Stardew) | twarz ok. 10–12 px: brwi i kierunek wzroku czytelne; płaszcz, czapka i postawa widoczne | akceptowalne na postaciach | ok. 1,5–2× pikseli postaci względem A; tileset nadal 16 |
| C: kafel 16, postać 32×48 | 40×22,5 | 13% | dobra mowa ciała; postać ma 3 kafle, więc drzwi i meble 16 px wyglądają na „za małe" | dobre | ok. 3× pikseli postaci względem A; rozjazd skali świata |
| D: kafel 32, postać 32×64 | 20×11,25 | 17,8% | najlepsza | najlepsze, także na kaflach | kafle i obiekty mają 4× więcej pikseli; ciasny kadr na rynku i w lesie; Pixellab obsługuje 32 |

Uwagi:
- 640×360 / 16 = 40×22,5 kafla to **szerszy kadr niż w Stardew** (ok. 30×17). Przy kaflu 16 i postaci 16×32 postacie wyjdą drobniejsze niż w Stardew. Wariant B lub C przywraca proporcję.
- Wysokość 360 nie dzieli się przez 16 (22,5 kafla). To nie przeszkadza, bo kamera się przewija, ale stałe ekrany, na przykład wnętrza, nie zmieszczą się w pełnej siatce **[wniosek]**.
- Normal mapy z Laigtera na sprite'ach 16 px dają głównie „wypukłość" krawędzi, a od ok. 32–40 px widać już modelowanie płaszcza i twarzy **[wniosek, do sprawdzenia w prototypie]**.
- Postacie nie muszą trzymać siatki kafla. Siatka dotyczy terenu; budynki i obiekty mogą być dowolnymi sprite'ami.

### Rekomendacja (wariant B) [wniosek]
**Kafel 16×16, postać ok. 24×40 (rysowana na płótnie 32×48 z zapasem na animację), portrety dialogowe osobno (np. 64×64 lub większe).**
- Proporcja postaci do ekranu jak w Stardew (ok. 11%) mimo szerszej bazy 640×360. Szeroki kadr pomaga na rynku i przy obserwacji rutyn NPC.
- Tileset 16 px: najtańszy w rysowaniu, natywny dla `create_topdown_tileset` i zgodny z większością gotowych paczek i tutoriali.
- Postać ok. 40 px daje twarz z brwiami i wzrokiem oraz czytelną sylwetkę (płaszcz, czapka, postawa), co liczy się w noir. Normal mapy postaci mają już na czym pracować. `create_character` z `size` ok. 64.
- Ryzyko: postać 2,5 kafla wymaga skalowania drzwi i mebli do niej (drzwi ok. 2,5–3 kafla), a nie do „czystej" siatki 16. Sprawdzić w prototypie z ryzyka 1 razem ze światłem.
- Alternatywa, jeśli prototyp pokaże zbyt drobny świat: wariant D (32/64) kosztem ok. 4× pracy przy kaflach i ciaśniejszego kadru.

## Aktualizacja 2: więcej detalu i twarde wymaganie cieni

Doprecyzowanie od użytkownika: Stardew to wzór **tylko** dla ruchu i kamery. Grafika ma być wyraźnie bardziej szczegółowa i realistyczna niż w Stardew i Graveyard Keeper, bliżej poziomu detalu Replaced. Twarde wymaganie dla światła to dwa scenariusze:
- **S1**: postać przechodzi przed autem z włączonymi reflektorami i rzuca cień.
- **S2**: całkiem ciemny pokój, jedynym źródłem jest latarka postaci. Stożek podąża za kierunkiem patrzenia, a ściany i meble rzucają cienie.

To zmienia wnioski z sekcji 6 i 7. Sekcje 8–11 zastępują ich rekomendacje.

### Bloomtown: A Different Story (Lazy Bear Games + Different Sense Games, 2024)
- Wydanie: 24.09.2024 (PC, konsole), wydawca Twin Sails. **[źródło wtórne]** [RPGSite](https://www.rpgsite.net/news/16197-bloomtown-a-different-story-begins-its-summer-vacation-full-taming-mo-on-september-24)
- Dev diary wydawcy z dyrektorem artystycznym (Vitaly): zespół mocno opiera się na postprocessingu, „we often use many different gradients and soft brushes in post-processing to subtly expand the palette". Paleta i postprocess były „crucial" dla nastroju. Lokacje powstają tak: blocking, potem szkic koncepcyjny z paletą i nastrojem, potem unikalne assety. **Silnika, rozmiarów sprite'ów, rozdzielczości ani techniki światła dziennik nie podaje.** **[źródło]** [Twin Sails dev diary](https://twin-sails.com/?p=1899)
- Recenzja Nintendo Everything chwali ciepłe, „niemal fotograficzne" światło **[źródło wtórne]**.
- **[wniosek]** Lazy Bear to studio Graveyard Keeper. W GK2 przeszli na geometrię 3D pod pixel artem, żeby mieć poprawne cienie (sekcja 1). Bloomtown powstawał w podobnym czasie, ale bez źródła nie wiem, czy używa tej samej techniki. Pewny wniosek z Bloomtown dotyczy procesu: paleta i postprocess robią dużą część „ładności", więc warto to przetestować w prototypie.

## 8. Jak Replaced osiąga detal i światło

- **Silnik: Unity.** Rozwój od 2018. Debiut studia Sad Cat; trzech założycieli wcześniej robiło tylko gry mobilne. Premiera 14.04.2026. Zespół zaczął od „indie pixel art style", znudził się nim i przeszedł na 2.5D. Inspiracje: Hercules, Tails Noir, The Last Night. **[źródło wtórne]** [Wikipedia](https://en.wikipedia.org/wiki/Replaced_(video_game)) (cytuje GamingBolt i The Escapist)
- **Technika: postacie to sprite'y 2D, tła głównie modele 3D.** „Characters are 2D sprites and backgrounds are composed primarily of 3D models", co daje fakturę podobną do HD-2D. Światło często zamienia bohatera w sylwetkę albo daje mu miękką poświatę. **[źródło wtórne, recenzja]** [Game Rant](https://gamerant.com/replaced-review/)
- Animacje: ponad 500 ręcznie malowanych animacji platformowych bohatera, a produkcja assetów spowalniała harmonogram **[źródło wtórne]** ([NME](https://www.nme.com/news/cyberpunk-thriller-replaced-delayed-to-avoid-overpromising-and-under-delivering-3493938), [Shacknews](https://www.shacknews.com/article/145729/replaced-gamescom-preview-2025)). Pixel art był rysowany ręcznie, klatka po klatce **[źródło wtórne]** ([GCORES](https://www.gcores.com/articles/213576)).
- Rozmiar sprite'ów i rozdzielczość bazowa: **nie znalazłem w żadnym źródle**. Trzeba by je zmierzyć na zrzutach w natywnej rozdzielczości.
- **Wniosek dla nas:** „poziom Replaced" to nie tylko lepiej narysowany pixel art. To **pixel art w scenie 3D z prawdziwym światłem 3D**, renderowany najpewniej w pełnej rozdzielczości ekranu (miękkie światło, bloom, mgła). Ta sama rodzina co Octopath (HD-2D), Graveyard Keeper 2, Children of Morta (wysokorozdzielcze światło nad pixel artem) i Sea of Stars (własny pipeline). W widoku 3/4 przekłada się to na technikę (b) z sekcji 9. Do tego Replaced miał zespół i lata pracy. Jego **poziom animacji** (setki animacji jednej postaci) jest poza zasięgiem i nie powinien być celem; cel to **poziom światła i otoczenia**. **[wniosek]**

## 9. Która technika w Godocie 4.7 spełni S1 i S2 w widoku 3/4

### (a) Światła 2D + LightOccluder2D + normal mapy
- **S2 (latarka):** wykonalne. `PointLight2D` z teksturą stożka obracany z postacią; ściany i meble mają okludery (per kafel w TileSecie). Cienie od PointLight2D liczone są od środka światła **[źródło: docs 2D lights]**.
- **S1 (reflektory):** wykonalne. Postać dostaje `LightOccluder2D` (np. owal lub sylwetka przy stopach), reflektory to dwa `PointLight2D` ze stożkiem. Tryb cull okludera (counter-clockwise) sprawia, że cień idzie tylko na zewnątrz i postać nie zaciemnia sama siebie **[źródło: [Catlike Coding](https://catlikecoding.com/godot/true-top-down-2d/4-light-and-shadow/)]**.
- **Ograniczenia [wniosek z modelu cieni w docs]:**
  - Cień to płaski klin na płaszczyźnie ekranu, a nie rzut bryły. Cień postaci w reflektorach to „klin od stóp w głąb ekranu"; nie wspina się po ścianie i nie ma kształtu sylwetki, chyba że okluder ma kształt sylwetki, ale wtedy leży źle w perspektywie.
  - Ściany 3/4 łapią cień własnej podstawy (sekcja 2). Obejście: okluder na górnej krawędzi ściany albo wyłączenie odbioru cieni przez lico ściany maskami.
  - Wysokość źródła (latarka w dłoni, reflektor na 0,7 m) nie istnieje dla cieni; `height` działa tylko na normal mapy.
- **Ocena:** spełnia S1 i S2 **funkcjonalnie**, ale efekt jest „graficzny", nie realistyczny. To poziom dobrego pixel-artowego 2D, nie Replaced. Trudność: niska-średnia. Assety: sprite'y + normal mapy + wielokąty okluderów.

### (b) HD-2D: Sprite3D w scenie 3D z prawdziwym światłem
Co daje Godot **[źródło]**:
- `SpotLight3D` to światło w stożku, przeznaczone wprost na „flashlights, car lights, and reflectors". Kąt ustawia się przez Angle, projektor (tekstura) mnoży kolor światła. **Powyżej 89° cienie spota przestają działać.** Bias / Normal Bias: za nisko daje „shadow acne", za wysoko „peter-panning"; preferować Normal Bias. Atlas cieni pozycyjnych domyślnie mieści 4+4+16+64 = **88 cieniujących świateł** w kadrze. ([3D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html))
- Renderery: Forward+ ma limit 512 elementów klastrowych w kadrze. Mobile ma 8 Omni + 8 Spot na mesh i 256/256 w widoku. Compatibility ma 8+8 na mesh, a cienie liczy w sRGB, więc wyglądają inaczej (ta sama strona). Wolumetryczna mgła działa tylko w Forward+ (dok. 02).
- `Sprite3D` (SpriteBase3D): `shaded` decyduje, czy działają na niego Light3D. `alpha_cut`: Disabled (blending), Discard, Opaque Prepass, Alpha Hash. `pixel_size` ustala rozmiar piksela w świecie. Gdy włączony jest billboard, sprite przy renderowaniu cieni też zwraca się do kamery. ([SpriteBase3D](https://docs.godotengine.org/en/stable/classes/class_spritebase3d.html))
- **Materiały z alpha blendingiem nie rzucają cieni**; Alpha Scissor, Alpha Hash i Depth Pre-Pass rzucają ([StandardMaterial3D](https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html)). Dla pixel artu naturalny wybór to Scissor/Discard.
- `cast_shadow = SHADOWS_ONLY`: obiekt jest niewidoczny i rzuca tylko cień ([GeometryInstance3D](https://docs.godotengine.org/en/stable/classes/class_geometryinstance3d.html)). To narzędzie na problem „płaskiej karty", opisany niżej.
- SubViewport z cieniami 3D wymaga `positional_shadow_atlas_size` > 0 **[źródło: docs Viewports, za wynikiem wyszukiwania]**.

Jak to spełnia scenariusze **[wniosek]**:
- **S1:** reflektory to dwa `SpotLight3D` na wysokości ok. 0,7 m. Postać (karta Sprite3D z alpha scissor) rzuca prawdziwy cień sylwetki na drogę i na stojące za nią obiekty, a cień rośnie z odległością. Pułapka: karta jest płaska. Gdy światło pada z boku (auto jedzie w poprzek kadru), cień zwęża się do kreski. Obejście: osobny niewidoczny „cieniorzut" (`SHADOWS_ONLY`), czyli prosta kapsuła lub dwie skrzyżowane karty, a widoczny sprite ma `cast_shadow = OFF`.
- **S2:** latarka to `SpotLight3D` jako dziecko postaci, obracane wg kierunku (4/8 kierunków); kąt < 89°. Ściany to boxy, meble to boxy albo karty. Cienie mebli padają na ściany i podłogę poprawnie, bo geometria jest prawdziwa. Problemy z sekcji 2 (cień przez lico ściany, światło „zza" sprite'a) **znikają**.
- Ściany frontowe zasłaniające postać: kamera 3/4 nad pokojem. Południowe ściany obniżone albo z `cast_shadow` bez renderu (`SHADOWS_ONLY`), żeby rzucały cień, ale nie zasłaniały widoku. To trik, którego 2D nie umożliwia.

Znane pułapki:
- **Pikselizacja w SubViewport + Sprite3D:** zgłoszenia na forum Godota (4.3/4.4): sprite'y w niskorozdzielczym SubViewport zniekształcają się i nie są pixel-perfect; zaradzono częściowo shaderem snapującym w przestrzeni ekranu. Rozdzielenie świata i sprite'ów na osobne viewporty psuje głębię. **[źródło wtórne, forum]** ([wątek 1](https://forum.godotengine.org/t/pixellated-3d-with-sprite3ds/115853), [wątek 2](https://forum.godotengine.org/t/exclude-sprite3d-from-viewport-pixelation-but-maintain-depth/97609))
- **Rozwiązanie [wniosek]:** nie pikselizować całej sceny. Renderować w natywnej rozdzielczości (jak Octopath czy Children of Morta), kamerą **ortograficzną** pod stałym kątem, z teksturami Nearest i `pixel_size` dobranym tak, żeby 1 piksel artu = całkowita liczba pikseli ekranu (3× przy 1080p dla siatki 640×360). Wtedy światło i cienie są gładkie, a sprite'y ostre; tak wygląda HD-2D. Snapowanie pozycji kamery i obiektów do siatki „pikseli artu" usuwa pływanie.
- Sprite'y pod kątem: przy kamerze 3/4 i braku billboardu karty postaci trzeba pochylić do kamery (stały obrót) albo użyć billboardu Y. Wtedy sprite zachowuje proporcje narysowane w Aseprite. **[wniosek]**
- Normal mapy na Sprite3D: przez własny `StandardMaterial3D` (`normal_texture`) jako material override, a nie przez CanvasTexture. Do zweryfikowania w prototypie. **[wniosek]**
- Ocena: trudność **średnia-wysoka** dla początkującego (kamera 3D, materiały, bias cieni, Forward+). Za to otoczenie nie musi być modelowane jak w GK2: wystarczą **boxy i płaszczyzny z teksturami pixel art** (`GridMap` / MeshLibrary albo CSG/proste meshe), a rekwizyty to karty Sprite3D. „Nightmare" z GK2 dotyczył dokładnego rzutowania gotowego pixel artu na model. Odwrotna droga, czyli najpierw bryła, potem tekstura, jest tańsza. **[wniosek]**

### (c) Hybrydy [wniosek]
- **(c1) Świat 2D, cienie z 3D:** niewidoczna scena 3D (proste bryły) renderuje tylko mapę światła i cieni do SubViewport, którą shader 2D mnoży z obrazem. Daje prawdziwe cienie bez zmiany pipeline'u assetów, ale wymaga utrzymywania dwóch światów zsynchronizowanych i pisania shaderów. Za trudne na start.
- **(c2) 2D + SDF:** cienie skończonej długości przez własny shader czytający 2D SDF (dokumentacja wskazuje ten kierunek dla cieni kierunkowych). Nadal płaska geometria, a do tego shadery. Nie rozwiązuje problemu lica ścian.
- **(c3) Tło jako render 3D, postacie 2D** (w stylu Disco Elysium, dok. 06): światło tła wypalone, więc S1 i S2 z ruchomym światłem odpadają.

### Podsumowanie techniki
| | S1 reflektory | S2 latarka w ciemnym pokoju | Wygląd vs Replaced | Trudność | Assety |
|---|---|---|---|---|---|
| (a) 2D | tak, płaski klin | tak, artefakty na licach ścian | niżej | niska-średnia | sprite'y, normal mapy, okludery |
| (b) HD-2D | tak, prawdziwa sylwetka (z proxy cienia) | tak, poprawnie | najbliżej | średnia-wysoka | sprite'y + bryły z teksturami pixel art |
| (c1) hybryda | tak | tak | blisko | wysoka | jak (a) + bryły |

## 10. Rozdzielczość i rozmiary przy wyższym detalu

- **Baza 640×360 zostaje jako „siatka pikseli artu"** **[wniosek]**: daje skalę całkowitą 3× (1080p), 4× (1440p) i 6× (4K). Wyższa baza, np. 960×540, ma skalę całkowitą tylko przy 1080p (2×) i 4K (4×); 1440p wymagałby ramek. W wariancie (b) baza nie jest rozdzielczością renderu (render jest natywny), tylko określa **wielkość piksela artu na ekranie**, więc detal rośnie przez większe sprite'y, a nie przez wyższą bazę.
- **Kafel 32 px = 1 m** i **postać ok. 56–64 px wysokości** (płótno 64×64 lub 48×64). Przy 360 px wysokości to ok. 16–18% ekranu, wyraźnie więcej niż Stardew (ok. 12%). Twarz ma ok. 12–16 px, co wystarcza na mimikę, zarost, kołnierz płaszcza i czytelną postawę, a normal mapy mają na czym pracować.
- **Zgodność z Pixellab [źródło: MCP docs]:** `create_topdown_tileset` obsługuje 32 px (standard); `create_character` z `size` ok. 96–104 (postać ok. 60% płótna, czyli ok. 58–62 px), w limicie 128; animacje v3 mieszczą się w 8×256×256. Tekstury ścian i podłóg dla boxów w (b) można generować jako kafle 32 px.
- Koszt: postać 60 px ma ok. 4× więcej pikseli niż 16×32, tak samo kafle 32 px w stosunku do 16 px. Przy pipeline'ie „AI + ręczna poprawka" koszt poprawek rośnie z powierzchnią. Z tego powodu nie warto iść wyżej, np. w postacie 96 px. **[wniosek]**
- Kadr: 640×360 przy kaflu 32 to ok. 20×11 m widoku. Ciasno na rynku, dobrze we wnętrzach i na scenach noir. W (b) ortograficzna kamera 3/4 pod kątem ok. 30–45° pokazuje trochę więcej głębi niż płaski rzut. Szersze plenery (jezioro, rynek) można zrobić kamerą oddaloną 2× (siatka 1280×720 przy 1440p/4K); przy 1080p wyjdzie skala niecałkowita, więc to tylko opcja. **[wniosek]**

## 11. Zaktualizowana rekomendacja [wniosek]

**Główna technika prototypu: (b) HD-2D w Godocie 4.7, renderer Forward+.**
- Kamera ortograficzna 3/4, render natywny (bez pikselizującego SubViewportu), pixel art 1:3 przy 1080p, snapowanie kamery do siatki artu.
- Postacie: `Sprite3D` z alpha scissor, 4 kierunki, płótno ok. 64 px, osobny cieniorzut `SHADOWS_ONLY`.
- Otoczenie: boxy i płaszczyzny z teksturami 32 px (`GridMap`), rekwizyty jako karty.
- Światła: `SpotLight3D` (latarka, reflektory) i `OmniLight3D` (lampy); do tego `WorldEnvironment` (glow, mgła, tonemapping) i paleta/LUT w postprocessie (lekcja z Bloomtown).
- Zakres prototypu: dokładnie S1 i S2 na dwóch scenach, plus jedna ulica nocą. Kryteria: czy sprite'y są ostre, czy cienie nie migoczą, ile czasu zajęła jedna ściana z teksturą.

**Fallback: (a) 2D** z sekcji 2 (światła 2D, okludery, normal mapy, viewport 640×360). Spełnia S1 i S2 funkcjonalnie, ale z płaskimi cieniami i niżej niż poziom Replaced. Na fallback przejść, jeśli po ok. 3–4 tygodniach (20–30 h) prototyp (b) nie daje ostrych sprite'ów i stabilnych cieni.

Ryzyka:
- 3D to nowy warsztat dla początkującego: bias cieni, materiały, kamera.
- Forward+ wymaga GPU z Vulkan/D3D12; cel PC, więc akceptowalne (dok. 02).
- Proxy cieni i normal mapy na Sprite3D są niesprawdzone w źródłach, do weryfikacji w prototypie.
- Ten wybór zmienia założenie „światła 2D w viewporcie 640×360" z dokumentu 02 i ADR o silniku/renderingu, więc wymaga decyzji człowieka.

## 12. Ranking „nastrój na jednostkę wysiłku" (światło tylko dla klimatu)

Doprecyzowanie od użytkownika: światło służy wyłącznie nastrojowi i nie jest mechaniką; nie ma zagadek typu „oświetl X latarką". S1 i S2 można złagodzić, jeśli są bardzo trudne. To zmienia priorytety sekcji 11.

### Co jest tanie, a co drogie (w Godocie, dla początkującego) [wniosek, z oparciem w docs tam, gdzie zaznaczono]
| Element | Koszt | Wkład w nastrój | Uwagi |
|---|---|---|---|
| Ciemny ambient (`CanvasModulate` / ambient w `WorldEnvironment`) + paleta/LUT/color grading | **bardzo tani** | **bardzo duży** | GK: 10 LUT-ów, „easy to create" **[źródło]**; Bloomtown: postprocess „crucial" **[źródło]** |
| Światła punktowe bez cieni (latarnie, okna, bar), ciepłe na zimnym tle | **tani** | **duży** | Wystarczą sprite'y lub tekstury światła; bez okluderów nie ma artefaktów 3/4 |
| Stożek latarki/reflektorów **bez cieni** (tekstura stożka obracana z postacią) | **tani** | duży | Spełnia „ciemny pokój + latarka" wizualnie, tylko bez cieni mebli |
| Halo/bloom na źródłach, winieta, ziarno, mgła sprite'ami, śnieg cząsteczkami | tani | duży | Dok. 02 |
| Blob shadow (owal pod stopami) | **bardzo tani** | średni (zakotwicza postać w świecie) | Standard w grach top-down **[wniosek]** |
| Cień-sprite obracany od najbliższego światła (jak GK) | średni | średni | Wymaga skryptu i dopasowania per obiekt; GK: płoty „approximate and buggy" **[źródło]** |
| Normal mapy na postaciach | tani-średni (Laigter + poprawki) | średni | Postać „łapie" światło latarni z kierunku |
| Normal mapy na wszystkich kaflach i ścianach 3/4 | średni-drogi | mały-średni | Ściany wymagają ręcznych poprawek (sekcja 2) |
| Cienie od okluderów 2D (meble/ściany w latarce) | średni | średni | Artefakty na licach ścian i dachach (sekcja 2) |
| Dynamiczny cień postaci w reflektorach (2D, okluder) | średni | mały-średni | Płaski klin, kilka sekund ekranu w całej grze |
| Prawdziwe cienie 3D (HD-2D) | **drogi** (nowy warsztat 3D, bias, materiały, bryły) | duży, ale głównie w scenach z ruchomym światłem | Sekcja 9b |

### Ranking technik (nastrój / wysiłek) [wniosek]
1. **„2D bez cieni dynamicznych" (wersja złagodzona, rekomendowana na start):** światła 2D bez okluderów + ciemny ambient + LUT/color grading + bloom, winieta, ziarno + mgła sprite'ami + śnieg + blob shadows + normal mapy tylko na postaciach. Latarka i reflektory jako stożki **bez cieni**. Największy stosunek nastroju do wysiłku: wszystko jest udokumentowane w Godocie, a w widoku 3/4 nie ma żadnych artefaktów, bo nie ma okluderów.
2. **To samo + okludery tylko we wnętrzach** (meble i ściany w świetle latarki, cull mode na zewnątrz) **+ cień postaci jako blob lub obracany sprite.** Mały dodatkowy koszt, a daje „latarkę z cieniami mebli" tam, gdzie pomieszczenie jest oglądane prawie z góry. Artefakty na licach ścian tylko we wnętrzach, gdzie da się je ukryć maskami.
3. **HD-2D (b):** najpiękniejsze i najbliższe Replaced, ale najdroższe. Ma sens dopiero, gdy prototyp wersji 1–2 pokaże, że nastrój jest niewystarczający, albo gdy użytkownik chce się świadomie uczyć 3D.
4. **Hybryda (c1):** najgorszy stosunek; odradzam.

### Dobrze wyglądająca wersja złagodzona S1 i S2 [wniosek]
- **S1 (reflektory):** dwa stożki światła (tekstura + Add/Mix), mocny bloom na lampach, smugi w padającym śniegu (cząsteczki jaśniejsze w stożku, bo światło 2D oświetla cząsteczki). Postać przechodząca przez stożek **rozjaśnia się** dzięki normal mapie postaci zamiast rzucać cień. Opcjonalnie wydłużony ciemny sprite-cień za postacią, pokazywany tylko w tej scenie (skrypt: kierunek od reflektora).
- **S2 (latarka):** pokój prawie czarny (ambient bliski czerni), stożek latarki obracany z kierunkiem postaci, słaby ciepły blask wokół postaci (mały PointLight), meble z normal mapą lub bez. Wariant 2: okludery tylko na kilku dużych meblach (szafa, stół), bez okluderów ścian.
- Oba warianty mieszczą się w technice (a) i nie wymagają 3D.

### Zmiana rekomendacji z sekcji 11 [wniosek]
Skoro światło jest tylko klimatem: **prototyp zacząć od wersji 1 (2D bez cieni dynamicznych) w viewporcie 640×360**, z rozmiarami z sekcji 10 (kafel 32, postać ok. 56–64 px). Mierzyć nastrój na S1, S2 i ulicy nocą. Potem dodać krok 2 (okludery we wnętrzach). HD-2D (b) staje się **opcją upgrade'u**, a nie punktem startu. Kryterium przejścia: jeśli po prototypie wersji 1–2 scena nie daje nastroju „Replaced/Disco Elysium", a użytkownik ma ochotę na 3D, robi się osobny prototyp (b) na jednej scenie. Uwaga: przy (a) w viewporcie 640×360 światło jest pikselowe (dok. 02), a nie gładkie jak w HD-2D/Replaced. To kwestia stylu, do oceny okiem w prototypie.

## Luki
- Rozmiary sprite'ów i rozdzielczość Replaced, silnik i technika Bloomtown: brak źródeł.
- Brak źródeł pierwotnych o pochylaniu kart Sprite3D do kamery 3/4 i o normal mapach na Sprite3D w Godocie 4.
- Brak pierwotnych źródeł o oświetleniu Eastward, Sea of Stars, Children of Morta i Hyper Light Drifter (strony 403 lub brak materiałów). Możliwe tropy: GDC Vault, devlogi Sabotage na Kickstarterze.
- Brak zgłoszeń w GitHubie Godota opisujących konkretnie cienie 3/4; artefakty z §2 to wniosek z opisanego w dokumentacji modelu cieni, do potwierdzenia prototypem.
- Stardew Valley i Unrest pominięte: nie znalazłem źródeł o ich oświetleniu.
