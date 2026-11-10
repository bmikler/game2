# 77. Schody, progi i krawędzie w rzucie 3/4: jak pokazać zmianę poziomu

Ticket: `docs/wayfinder/tickets/24-schody-zmiana-poziomu-research.md`. Data: 2026-11-09. Nic nie zostało wygenerowane ani pobrane (zero mediów w repo, brak `77-assets/`).

Oznaczenia źródeł: **[pierwotne]** dokumentacja silnika, kod, wpis dewelopera; **[wtórne]** fora, blogi, opisy cudzej analizy kodu; **[pamięć]** moja wiedza o grze, **niezweryfikowana w tej sesji**; **[brak]** szukałem i nie znalazłem źródła; **[wniosek]** moja inferencja.

## Uczciwe zastrzeżenie o źródłach

Wyszukiwarka nie znalazła ani jednego devlogu/talku/wpisu o schodach dla Eastward, Moonlighter, Sea of Stars, Chained Echoes, Hyper Light Drifter, Children of Morta, Fields of Mistria, Graveyard Keeper, Beat Cop, Stardew Valley ani Octopath. **[brak]** Dla większości z tych gier wiem tylko to, co pamiętam z grania, więc traktuję te wiersze jako hipotezy do obejrzenia w grze. Twarde, sprawdzone fakty pochodzą z: dokumentacji Solarus (silnik klonów Zeldy), dokumentacji Godota, wpisu RPG Maker, wpisu Game Developer o schodach, wątku GDevelop, wpisu Radical Fish o CrossCode i analizy dekompilacji Pokémon gen 3 (blog, wtórne). Pewność: średnia do niskiej. Człowiek powinien sam obejrzeć 3-4 gry z listy (§5) zanim zatwierdzi wariant.

## Odpowiedź w skrócie

1. Schody czyta się jako schody, gdy zmiana wysokości jest **oddzielona od ruchu po ziemi**: pozycja logiczna (kolizja, sortowanie, wejście) zostaje na płaszczyźnie podłoża, a sprite dostaje osobne **przesunięcie pionowe** zależne od wysokości stopnia. Ten wzorzec opisują niezależnie wątek GDevelop („ukryty collider + offset wizualny”, [wtórne]), Pokémon (pole `y2` obok `y`, [wtórne]) i nasza własna matematyka rzutu **[wniosek]**.
2. Dziś na Poligonie Ulica schody są namalowane na licu ściany (6 pasów po 8 px), a gracz po prostu idzie w górę ekranu o 48 px. To jest ruch po płaskim terenie z przemalowanym tłem, stąd odrzucenie. Samo „przesunięcie sprite'a” bez zmiany geometrii tego nie naprawi: trzeba też pokazać **bieg schodów** (stopnie z głębokością, policzki boczne) albo przynajmniej **schodkowy** ruch i ograniczone tempo.
3. Najtańsze skuteczne środki (zero dodatkowych klatek animacji): przesunięcie sprite'a schodkami co stopień (z krótkim wygładzeniem), wolniejszy chód, dźwięk kroku na stopniu, cień sprite'a przyklejony do stopnia, zasłanianie nóg/boku przez policzek schodów i murek. Dedykowana poza wchodzenia po schodach jest **zbędna**, jeśli stopnie są niskie (8 px).
4. Rekomenduję do prototypu: **A** schody czołowe z prawdziwym biegiem i schodkowym offsetem, **B** schody boczne (równoległe do muru), ukośny ruch z remapowaniem wejścia, **C** próg drzwi: jeden stopień z mikro-hopem. Do tego opcjonalny zeskok z tarasu z łukiem jak ledge w Pokémon. Liczby w §6.

## 1. Geometria naszego rzutu (dlaczego „po płaskim” wygląda źle)

Źródło: `style-lab/poligony/ulica_bryly.gd`, `_terrace()`: `TERRACE_M = 1.2` m, `STAIRS_X = (17.0, 19.5)` (2,5 m = 100 px szerokości), schody to 6 poziomych pasów na licu ściany, `lift = config.px(1.2)` = 48 px przy 40 px/m **[wniosek: zakładam, że `px()` nie skaluje wysokości przez 0,60]**. Głębokość ma współczynnik 0,60: 1 m w głąb = 24 px na ekranie, 1 m w górę = 40 px.

- Zależność: `ekran_y = ziemia_y − wysokość`. Gdy gracz idzie „do tyłu” po rampie, ekran widzi sumę ruchu w głąb i ruchu w górę. Ścieżka 1,8 m w głąb (6 stopni × 0,30 m) to 43 px głębi plus 48 px wysokości = 91 px na ekranie, czyli ok. 2,1× szybciej niż po płaskim przy tej samej prędkości na ziemi **[wniosek]**. Bez kompensacji gracz „wystrzeliwuje” w górę ekranu. Stąd wolniejszy chód na schodach (też w ALttP i FireRed, §2).
- Obecne lico: 48 px wysokości lica = 80 px głębi ziemi (48/0,6). Gracz idący po „schodach malowanych na ścianie” przebywa 48 px po ekranie w tempie 24 px/m, tj. jak 2 m płaskiego terenu, bez żadnego sygnału wysokości poza tłem.

## 2. Katalog technik

Koszt: **K** = kod (godziny, bez nowych assetów), **A** = dodatkowe klatki animacji na postać (u nas drogie: chód z Pixellab, 8 kierunków lub tak).

| # | Technika | Gry / źródło | Jak wygląda | Koszt | Ryzyka |
|---|---|---|---|---|---|
| 1 | **Rozdzielenie pozycji logicznej od wizualnej** (offset sprite'a o wysokość) | wątek GDevelop („PlayerCollider” + „PlayerOffset”, wysokość liczona z pozycji na rampie) **[wtórne]**; Pokémon gen 3: `y2` osobno od `y` przy hopie **[wtórne, analiza dekompilacji]** | Cień/kolizja po ziemi, ciało unosi się o stopień. Fundament pod resztę. | K małe | Sortowanie (patrz 11), kamera, interakcje z kolizjami zależnymi od wysokości |
| 2 | **Schodkowy offset** (kwantyzacja do wysokości stopnia, 2-3 klatki wygładzenia) | Pokémon: ledge to tablica offsetów co 2 klatki (−4, −6, ..., −12) **[wtórne]**, schody samego terenu bez offsetu **[wtórne]**; schodkowa wysokość to moja propozycja **[wniosek]** | Sprite „wskakuje” o 8 px przy każdym stopniu zamiast płynnie sunąć w górę. To najsilniejszy tani sygnał „stopnie”. | K małe | Przy zbyt dużym kroku wygląda na teleport; wygładzić 60-100 ms |
| 3 | **Zmiana prędkości** | FireRed: schody skalne spowalniają chód z 16 na 23 klatki/kratkę (+44%), bieg z 8 na 11 **[wtórne]**; ALttP: schody/drabiny mają osobną, wolniejszą prędkość w tabeli ruchu **[wtórne: speedrun]**; Construct (post na forum) mówi o spowolnieniu gracza i kamery na schodach **[wtórne, słabe: strona zwróciła 403, treść z wyszukiwarki]** | Gracz „pracuje” na schodach. | K minimalne | Na sąsiednim ruchu po płaskim kontrast musi być czytelny, ale nie męczący (nie poniżej ~0,6×) |
| 4 | **Osobna animacja/poza wejścia po schodach** | Poradnik Game Developer (wersja boczna): schody mają dedykowane animacje, wszystkie stopnie jednakowej wielkości, żeby jedna animacja pasowała do każdej długości **[pierwotne, side-scroller]**; Solarus: „specjalny ruch i odpowiednie animacje sprite'a” dla schodów **[pierwotne]** | Pełna animacja wspinania. W 3/4 z bocznym chodem ma sens przy wysokich schodach. | **A duże** (każdy kierunek, 4-8 klatek) | Przy naszym Pixellab chain C to największy koszt. **Nie rekomendowane** przy stopniach 8 px; wystarczy chód z offsetem |
| 5 | **Schody ukośne / boczne** | RPG Maker: ruch wymuszony „Upper Right ×2, Right ×1”, a Lewo/Prawo przemapowane na ruch ukośny na kafelku regionu **[pierwotne: wpis RPG Maker]**; Pokémon Emerald: narożniki schodów ukośnych rysowane, ale nie czytane przez kod **[wtórne]** | Gracz idzie w bok i jednocześnie w górę ekranu o stałą stromiznę. Chód boczny pasuje bez nowych klatek. | K średnie (remap wejścia) | Kierunek patrzenia: zostaje boczny; „pion” wejścia na schodach musi być przemapowany, inaczej gracz „wychodzi” ze schodów |
| 6 | **Strefa wejścia i zamiar gracza** | Game Developer: „entry range” + „bypass check”, wejście na intencję (trzymanie kierunku), a nie samo dotknięcie; teleport do punktu wejścia był widoczny, więc zastąpiony dojściem **[pierwotne, side-scroller]** | Gracz nie „wpada” na schody przypadkiem. | K średnie | Przy wąskim przejściu 2,5 m szerokie strefy są zbędne; wystarczy płaszczyzna schodów |
| 7 | **Zasłanianie przez policzki, balustradę, murek** | Pokémon: metatile „Covered” rysowane pod chodzącym, „Normal” (mosty) nad nim, priorytet sprite'a z tablicy po elevation **[wtórne]**; Godot: sortowanie względem `z_index` i `y_sort` **[pierwotne]** | Boczny policzek schodów (kamienny blok o wysokości 0,4-0,6 m) zasłania dolną część sprite'a na ostatnich stopniach i daje wyraźną krawędź. | K małe, A zero, ale potrzebne tło/spritey z rysunkiem policzka | Zasłonięcie złej części postaci; wymaga prawidłowego klucza sortowania (11) |
| 8 | **Cień** | Pokémon: przy hopie cień zostaje na ziemi, sprite się unosi (Emerald: cień 16×8 w `y` + offset) **[wtórne]**; wątek Godot: cień piętra wyżej zasłania niższe, trzeba małych cieni **[wtórne]** | Cień na ziemi = sygnał wysokości przy zeskoku. Na samych schodach cień ma leżeć **na stopniu**. | K małe | Cień „rozlewający się” przez kilka poziomów |
| 9 | **Łuk zeskoku/ledge** | Pokémon gen 3: 2 kratki w 32 klatkach (0,536 s), szczyt 12 px, tablica 16 offsetów, dźwięk startu, kurz przy lądowaniu (3 klatki 16×8) **[wtórne]**; CrossCode: zeskok z krawędzi przez wolniejsze podejście do stoku, auto-jump tuż przed krawędzią, wysokość skoku „dość niska” **[pierwotne: wpis Radical Fish]** | Postać wykonuje krótki łuk i ląduje; wystarcza jedna istniejąca klatka (np. pierwsza klatka chodu). | K małe, A zero | Przy 48 px zeskoku łuk musi być długi (patrz §6D), bo upadek 1,2 m > 12 px Pokémona |
| 10 | **Próg / pojedynczy stopień** | Gen 3: schody to pole z elevation 0 stykające dwa poziomy, w Emeraldzie „zwykły krok” bez offsetu **[wtórne]**; Pokémon-style drzwi to zwykle warp **[pamięć]** | Mikro-hop 3-6 px, cień zostaje, krótki dźwięk. | K minimalne | Zbyt duży hop robi „skakanie po ulicy”; pamiętać o kolizji progu |
| 11 | **Systemy poziomów (layers/heights)** | CrossCode: trójwymiarowa mapa z wysokościami, osobna mapa wysokości na obszar **[wtórne: MobyGames / devlog moddb, przez wyszukiwarkę]**; wpis Radical Fish potwierdza wysokości, nie opisuje schodów **[pierwotne]**; Solarus: schody wewnętrzne zmieniają warstwę bohatera, muszą leżeć na niższej z dwóch warstw **[pierwotne]**; Godot: `z_index` wyższy rysuje się przed niższym, sortowanie `y_sort` działa tylko w obrębie jednego `z_index` **[pierwotne: dokumentacja CanvasItem]**; wątki forum: z_index per piętro psuje sortowanie i cienie, naprawa: ten sam z_index i `y_sort_origin` **[wtórne]** | Poprawne zasłanianie na różnych wysokościach. | K średnie | **Najgroźniejsze**: zmiana `z_index` gracza w połowie schodów przy cofnięciu się psuje sortowanie **[wtórne]** |
| 12 | **Dźwięk** | Solarus: dźwięk wspinaczki jako element schodów **[pierwotne]**; Pokémon: SFX ledge przy starcie hopu, kroki mostu zależne od elevation **[wtórne]** | Stuknięcie kroku na stopniu, inny materiał niż na płask. | K minimalne, asset audio | Powtarzalność; wariacja wysokości tonu |
| 13 | **Kamera** | Construct: spowolnienie kamery na schodach **[wtórne, słabe]**; Pokémon: kamera śledzi sprite **[wniosek]** | Kamera wygładza 48 px wzniesienia, nie szarpie. | K minimalne | Kamera śledząca `y` ziemi nie pokaże wzniesienia, śledząca sprite może „bujać” przy schodkach; wygładzić 0,15-0,25 s |
| 14 | **Przejście ekranem (warp)** | Solarus: „schody teleportujące” uruchamiają teleporter po końcu animacji schodów **[pierwotne]**; schody w Stardew (kopalnia), drzwi w Pokémon **[pamięć]** | Nie ma ciągłej wspinaczki, tylko fade. | K małe | Nie rozwiązuje naszego tarasu, bo ma być widoczny w ulicy |

Gry z listy ticketu bez źródła: Eastward (uchodzi za grę 2D w 3D-owym silniku, wysokości w poziomach i schody między piętrami miasta, szczegółów brak **[brak, pośrednie: Game Developer / Red Bull]**), Moonlighter, Sea of Stars, Chained Echoes, Hyper Light Drifter, Children of Morta, Fields of Mistria, Graveyard Keeper, Beat Cop, Octopath Traveler, Stardew Valley: **[brak]**, **do obejrzenia w grze** (§5).

## 3. Co z tego dotyczy nas (koszt animacji)

- Nasze postacie mają tylko chód z Pixellab. Zero nowych klatek jest warunkiem wstępnym: techniki 1, 2, 3, 5, 7, 8, 9, 10, 12, 13 nie wymagają żadnej dodatkowej animacji.
- Technika 4 (poza wspinaczki) wymaga A. Odrzucić na tym etapie. Jeśli wizualnie nie wystarczy, rozważyć wyłącznie **jedną** dodatkową klatkę „stopa na wyższym stopniu” (A małe) lub dopasowanie fazy chodu do stopnia.
- Technika 11 (poziomy) w Godocie 4 wystarcza w prostej wersji: jeden `z_index` dla całego świata plus `y_sort`, korzeń gracza na pozycji ziemi, sprite jako dziecko z offsetem. Dokumentacja CanvasItem: „Nodes sort relative to each other only if they are on the same z_index” **[pierwotne]**, więc nie zmieniać `z_index` gracza na schodach.

## 4. Pułapki wspólne

- Pozycja logiczna na ziemi (sortowanie i kolizja) i offset wizualny: kamera powinna śledzić sprite (z wygładzaniem), a nie ziemię, inaczej wzniesienie 48 px „znika” z kadru.
- Kolizja z murem tarasu (`_wall`) opiera się na pozycji ekranowej; po rozdzieleniu pozycji trzeba te prostokąty przeliczyć na płaszczyznę ziemi, albo zostawić schody jako strefę, w której kolizja jest przesunięta o lift.
- Cień nie może przechodzić przez lico muru.

## 5. Do obejrzenia przez człowieka (nie sprawdzone w tej sesji)

Eastward (schody w mieście Potcrock i w Earthborn), Stardew Valley (schody w domu), CrossCode (rampy i wysokości), Pokémon Emerald/Black-White (schody skalne, ledge), Graveyard Keeper (schody i podesty), Sea of Stars. Pytania do oglądania: czy sprite zmienia wysokość schodkowo czy płynnie, czy zmienia się tempo, czy jest osobna poza, co zasłania nogi.

## 6. Rekomendowane warianty do prototypu na Poligonie Ulica

Założenia liczbowe: stopień 8 px (6 stopni = 48 px = 1,2 m), bieg stopnia 0,30 m = 7,2 px głębi (6 stopni = 43 px, 1,8 m), szerokość schodów 100 px. Wszystko tuningowane z `Resource`/`@export`, bez magicznych liczb w logice.

### A. Schody czołowe z prawdziwym biegiem i schodkowym offsetem (główny kandydat)

- Geometria: do lica muru dołożyć bryłę schodów wystającą 1,8 m w głąb (43 px na ekranie), z 6 widocznymi stopniami (każdy: pionowa podstopnica 8 px jasna + tread 7,2 px ciemniejszy), po bokach dwa policzki (kamień, szerokość 12 px, wysokość 24 px przy dole, 48 px przy górze w ekranie).
- Ruch: korzeń gracza porusza się po ziemi w strefie biegu schodów (kolizja po ziemi); `Sprite.position.y = −h`, gdzie `h = round(postęp_w_głąb / 0,30 m) × 8 px` (kwantyzacja co stopień), czas wygładzenia przejścia 0,08 s (ease out). Wygładzenie opcjonalnie 0,12 s przy schodzeniu.
- Prędkość: na schodach mnożnik 0,6 prędkości ziemnej (z kompensacji z §1: bez niej 2,1× szybciej na ekranie, z 0,6 → ok. 1,3×, jeszcze wyczuwalnie „w górę”; można zejść do 0,5). Schodzenie: 0,7.
- Cień: owal 16×8 px stałej wielkości na wysokości stopnia (podąża za `h`), nie na ziemi.
- Zasłanianie: policzki rysowane z `y_sort` względem korzenia; dolne 12 px postaci zasłania policzek przy skrajnej krawędzi (gdy gracz idzie przy krawędzi schodów).
- Dźwięk: krok „kamień” co stopień (6 razy, pitch ±5%), głośność −3 dB względem płaskiego.
- Kamera: śledzi sprite, wygładzanie 0,2 s.
- Sprawdzić: czy 2,5 m szerokości wygląda jak schody, czy jak rampa; czy 8 px skoku jest czytelne przy 72 px postaci (11%).

### B. Schody boczne (równoległe do muru), ukośny ruch

- Geometria: schody wzdłuż osi x z boku tarasu, 6 stopni po 0,40 m = 2,4 m = 96 px poziomo, wznoszenie 48 px (nachylenie 1:2, ok. 27° na ekranie). Policzek z boku (od strony kamery) kamienny, z zewnętrznej strony balustrada 24 px, zasłaniająca dolną połowę postaci przy krawędzi.
- Ruch: tak jak RPG Maker: w strefie schodów Lewo/Prawo przemapować na ruch wzdłuż schodów z jednoczesnym ruchem w górę/dół ekranu (`dy = −dx × 0,5`); Góra/Dół = jak Prawo/Lewo (kierunek ostatniego naciśnięcia), żeby gracz nie „wypadał” bokiem. Facing: boczny (chód z Pixellab bez zmian).
- Offset: jak w A, `h` kwantyzowane co 0,40 m w osi x, wygładzenie 0,08 s.
- Prędkość: 0,75× (ruch boczny jest dłuższy po ekranie, więc mniejsze spowolnienie).
- Sprawdzić: czy ukośny ruch bez zmiany animacji wygląda naturalnie (nesdev i ALttP robią tak samo: animacja trzyma ostatni kierunek kardynalny **[wtórne]**).

### C. Próg drzwi: jeden stopień

- Geometria: stopień 0,15 m = 6 px wysokości, 0,30 m = 7 px głębi, jasna krawędź 1 px na górze, 2 px ciemnego cienia pod nią, ten sam kamień co fundament.
- Ruch: mikro-hop: gdy korzeń przechodzi krawędź stopnia, offset sprite'a −6 px w 0,06 s, przy 0,5 szerokości wchodzenia dodatkowy łuk +3 px w 0,10 s i powrót, razem 0,12 s; prędkość bez zmian. Schodzenie: odwrotnie, bez łuku, offset 6 → 0 w 0,06 s.
- Cień: zostaje na ziemi w trakcie hopu, potem przeskakuje na stopień.
- Dźwięk: jedno stuknięcie, −6 dB.
- Drzwi: `Door` aktywuje się na wysokości stopnia (nie 6 px niżej), tj. sprawdzić strefę wejścia po offsecie.
- Ryzyko: zbyt duży hop na zwykłej ulicy; trzymać ≤ 9 px szczytu.

### D. Zeskok z tarasu (opcjonalny, bezpłatnie dzięki technice 9)

- Tylko na krawędzi lica poza schodami (dziś ściana blokuje): trzymanie w dół 0,15 s przy murze uruchamia zeskok: offset sprite'a od −48 do 0 px po łuku `−48 + 48·t²` z szczytem startowym +10 px, czas 0,35 s, cień zostaje na ziemi, lądowanie: kurz 3 klatki 16×8 px po 0,06 s i dźwięk, 0,1 s zablokowanego wejścia. Wchodzenie na taras z poziomu ulicy poza schodami zostaje zablokowane.
- Ryzyko: człowiek tego nie zamawiał; wypróbować, tylko jeśli A/B będzie pozytywnie przyjęte.

### Kolejność prób

1. A + C razem (jeden pakiet kodu: offset schodkowy + cień + dźwięk + kamera).
2. B osobno jako wariant porównawczy; oceniać człowiek w grze na żywo (nasza zasada: wariant musi być klikalny w Poligonie, nie zrzut).
3. Dopiero potem rozważać poszerzenie o poza wspinaczki (A klatki), jeśli schodkowy offset nie wystarcza.

## 7. Źródła

- **[pierwotne]** Radical Fish Games, „CrossQuestion: Why do we use auto jump in CrossCode?”, https://www.radicalfishgames.com/?p=1168 (wysokości, auto-jump, zeskok przez wolniejsze podejście; brak informacji o schodach i o sprite'cie na wysokościach).
- **[pierwotne]** Solarus, dokumentacja encji schodów, https://docs.solarus-games.org/lua-api/map-entities/stairs/ (schody wewnętrzne zmieniają warstwę, animacje, dźwięk).
- **[pierwotne]** Godot, `CanvasItem` (`y_sort_enabled`, `z_index`, `z_as_relative`), https://docs.godotengine.org/en/stable/classes/class_canvasitem.html.
- **[pierwotne, side-scroller]** Game Developer, „Moving on stairs in a 2D side-scroller”, https://gamedeveloper.com/design/moving-on-stairs-in-a-2d-side-scroller.
- **[pierwotne]** RPG Maker, „Special Movements: Walking on Diagonal Stairs”, https://rpgmakerweb.com/blog/special-movements-walking-on-diagonal-stairs (ukośne schody przez zdarzenia i regiony).
- **[wtórne]** Blake Crosley, „Pixel-Art Ledges, Stairs and Bridges in a Tile World”, https://blakecrosley.com/blog/pixel-art-elevation-ledges-bridges (analiza dekompilacji Pokémon gen 1-3: łuk ledge, prędkość na schodach, cienie, kolejność rysowania; przeczytałem pierwsze 100 000 z 211 456 znaków).
- **[wtórne]** wątek GDevelop o rampach w top-down, https://forum.gdevelop.io/t/how-to-make-ramps-slopes-stairs-in-topdown-movement/75198 (ukryty collider + offset wizualny).
- **[wtórne]** wątki forum Godota o piętrach i y-sort, https://forum.godotengine.org/t/working-with-2d-top-down-games-with-different-floor-heights/76001 i https://forum.godotengine.org/t/stairs-in-2d-isometric-game/112389 (z_index per piętro, problemy z cieniami i cofnięciem na schodach; drugi tylko z wyników wyszukiwania).
- **[wtórne, słabe]** Construct, „How do I implement stairs and raised floors?”, https://www.construct.net/en/forum/construct-3/how-do-i-8/implement-stairs-raised-floors-179164 (403, treść tylko ze streszczenia wyszukiwarki), zeldaspeedruns / tasvideos (prędkości ALttP, tylko streszczenia z wyszukiwarki), nesdev t6703 (animacja trzyma ostatni kierunek kardynalny).
- **[brak]** Dla Eastward, Moonlighter, Sea of Stars, Chained Echoes, Hyper Light Drifter, Children of Morta, Fields of Mistria, Graveyard Keeper, Beat Cop, Octopath Traveler, Stardew Valley nie znalazłem żadnych wpisów o schodach.
