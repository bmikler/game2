# Bok z głębią (alternatywa dla 3/4) i Kotwice nastroju

Stan: 2026-11-08. Ciąg dalszy `60-kotwice-stylu-kandydaci.md` i `67-dorosly-pixel-art-bok-vs-34.md`. Nic tu nie jest decyzją. Gra: dorosły pixel art, małe miasteczko, zima, noc, noir, mocne światło; swobodna eksploracja miasta, wnętrza jako osobne mapy.

Plansza (lokalnie, nie publikować): `docs/research/68-assets/plansza.html` (sekcje „Bok z głębią” i „Nastrój”). Zrzuty: `68-assets/<gra>-<n>.jpg`, oficjalne, Steam `appdetails` (`path_full`), 4 na grę (dla gier z ≤4 zrzutami wszystkie, inaczej pierwszy, 1/3, 2/3 i ostatni). Tylko do prywatnej oceny.

Oznaczenia: **[zweryfikowane]** dane sklepu Steam lub źródło webowe podane przy zdaniu; **[zrzut]** to, co widać na obejrzanym kadrze (oglądałem 1 kadr na grę, nie wszystkie); **[wtórne]** z pamięci/wiedzy ogólnej, nie sprawdzone tu; **[wniosek]** moja interpretacja. Wyniki wyszukiwania nie potwierdziły liczby kierunków sprite'ów w żadnej grze z części A (zob. niżej).

## TL;DR

1. **Bok z głębią to trzy różne rzeczy** o różnej swobodzie: czysty side-scroll (oś X, ekrany), ostry rzut z perspektywą (point-and-click, ścieżka chodzenia w głąb, ekrany) i pas głębi (beat 'em up, oś X + wąski pas Y). **Żaden nie daje „skrętu w przecznicę” na ciągłej mapie**: wszystkie trzy opierają się na ekranach/scenach, miasto to graf scen [wtórne, zrzuty to potwierdzają co do kadrów].
2. **Najlepszy kompromis eksploracji w boku z głębią: ostry rzut z perspektywą** (Broken Sword, Thimbleweed Park): postać wchodzi w głąb, skala zmienia się z odległością, ale „skręt” to przejście do kolejnej sceny przez wyjście narysowane w tle [wniosek]. Swoboda ≈ 3/5; mapa miasta ciągła **nie jest**.
3. **Pas głębi** daje ruch dowolny w pasie, ale pas jest płytki (zob. `rivercitygirls-1`: wnętrze ma głębię ok. 2/3 kadru, ulica zwykle mniej) i wymaga w grze eksploracyjnej tylko 2 kierunków + lustro [wniosek]. Dla noir/śledztwa to najtańsza postać, najdroższe w sensie ograniczeń świata.
4. **Kierunki sprite'ów** (Broken Sword „8”): **niepotwierdzone**. Szukałem źródeł (wyszukiwarka, blog Thimbleweed Park); nic nie podaje liczby kierunków. Z potwierdzonych faktów: Reforged ma „30 000 ręcznie rysowanych sprite'ów” i ręcznie malowane tła [wtórne: recenzje z wyników wyszukiwania]; Ron Gilbert opisuje, że w Maniac Mansion chód był w 3 kierunkach (lewo/prawo lustrem) [zweryfikowane: blog Thimbleweed Park, ale dotyczy MM, nie TP].
5. **Nastrój, najlepsi nowi kandydaci do uzupełnienia NORCO** (z pikselami): **Unavowed** (noc, deszcz, ciepłe okna i drzwi na brudnym tle, portrety), **Lamplight City** (portrety malarskie + tła), **Gemini Rue** (zimny noir, fiolet), **Kathy Rain** (małe miasteczko, ciepłe wnętrza). Z nie-pixel: **Kentucky Route Zero** (ciepłe światło w ogromnej ciemności, najlepszy wzorzec „ciepłe okna w zimnej ciemności”) i **Disco Elysium** (zima/śnieg, brudna paleta, zgaszona).
6. **Żadna gra nie łączy zimy, małego miasteczka, nocy i pixel artu.** Zimę dają Disco (malarsko) i Papers, Please (zimny szary); noc + ciepłe okna: Unavowed, KRZ, Cloudpunk (neon, nie pasuje) [zrzut].

## Metoda i ograniczenia

- Zrzuty ze Steam API; kadry do analizy to 1 z 4 na grę. Niektóre zrzuty są małe (Lamplight 1280×800, Gemini Rue 1280×960, Kathy Rain 960×720, Unavowed 1280×720) [zweryfikowane: wymiar plików].
- Liczby kierunków, skala, mapa świata: z wiedzy ogólnej, **nie sprawdzane grą** [wtórne]. W części A to główny rodzaj dowodu; w kilku miejscach jest otwarte pytanie „sprawdzić na gameplayu”.
- Paleta/światło/faktura w części B: wnioski z jednego kadru, mogą nie reprezentować całej gry.

## A. Bok Z GŁĘBIĄ jako alternatywa dla 3/4

### 1) Czysty side-scroll / ekrany z boku (Kathy Rain, Gemini Rue)

- **Mapa miasta:** graf scen (ekranów); w Kathy Rain miasteczko Carden Falls to zestaw ekranów połączonych wyjściami i mapą [wtórne]. Gemini Rue: lokacje-ekrany, tło pre-malowane, 320×240 ×4 [pomiar z `67`, 1,00].
- **Skręt w przecznicę:** nie jako ruch; tylko jako wyjście do innego ekranu, często przez menu mapy [wtórne].
- **Głębia:** brak lub symboliczna (postać na jednej linii podłogi, ewentualnie lekki zakres w głąb w dolnej połowie, jak w `kathyrain-1`, gdzie postać chodzi po pokoju w obrębie podłogi) [zrzut].
- **Kierunki postaci:** 2 (lewo/prawo z lustrem) + ewentualnie przód/tył przy drzwiach; w Kathy Rain postać ma ok. 33 px (`67`) [wtórne/pomiar z `67`].
- **Wnętrza:** osobne sceny-pokoje, ten sam rzut co miasto (`kathyrain-1`: szpitalny pokój, ciepłe światło sufitowe, okno) [zrzut].
- **Przykład:** `kathyrain-*.jpg`, `geminirue-*.jpg`.

### 2) „Ostry rzut z perspektywą” (Broken Sword 1/2 i Reforged, Beneath a Steel Sky, Thimbleweed Park, Broken Sword 5)

- **Mapa miasta:** graf scen; Broken Sword: Paryż jako seria ekranów dostępnych z mapy lub przez wyjścia [wtórne]. Beneath a Steel Sky: pojedyncze ekrany miasta Union City [wtórne].
- **Skręt w przecznicę:** w obrębie sceny — tak (postać idzie w głąb po narysowanym chodniku, jeśli tło ma tam obszar chodzenia), ale „ulica boczna” to osobna scena wymagająca narysowanego wyjścia [wniosek]. `thimbleweed-1` i `bsreforged1-1` pokazują pokoje, w których postać chodzi w głąb pomieszczenia na podłodze o dużej powierzchni [zrzut].
- **Skalowanie postaci:** Broken Sword i Beneath a Steel Sky skalują postać z odległością (typowe dla gatunku) [wtórne]. Thimbleweed Park: forum pixeljoint twierdzi, że postać przeskalowuje się płynnie; **sprawdzenie nie udało się** (blog Gilberta opisuje tylko „fałszywą perspektywę” prędkości: ruch w poziomie ≈ 2× dłuższy niż w pionie, bez potwierdzenia skalowania sprite'a) [zweryfikowane: blog Thimbleweed Park; skalowanie: wtórne, forum].
- **Kierunki postaci:** Broken Sword „8” — **nie potwierdzone**; typowo 4-8 kierunków (przód/tył/boki, 3/4) plus animacje specjalne [wtórne]. Thimbleweed Park: nie znalazłem liczby kierunków; dziedziczy po SCUMM (3 kierunki + lustro) tylko jako hipoteza [niezweryfikowane]. Reforged: ręcznie rysowane sprite'y w wysokiej rozdzielczości, „30 000 sprite'ów” [wtórne].
- **Wnętrza:** osobne sceny (np. mieszkanie Andrégo w `bsreforged1-1`, pokój w Thimbleweed) o malowanych tłach z wbudowanym światłem i cieniami [zrzut].
- **Uwaga produkcyjna:** tła malowane (BS) są drogie, ale światło jest w nich „za darmo” (wbudowane w malarski obraz); w pixel arcie (Thimbleweed) tło jest rysowane z pewną skalą pikseli ok. 1080p, a sprite'y mieszają skale pikseli [zrzut/wtórne].
- **Przykłady:** `bsreforged1-*.jpg`, `bs2-*.jpg`, `bs5-*.jpg`, `bass-*.jpg` (VGA 320×200, 743 px na zrzucie), `thimbleweed-*.jpg`.

### 3) „Pas głębi” jak beat 'em up (Streets of Rage 4, River City Girls, Scott Pilgrim)

- **Mapa miasta:** SoR4: linearne poziomy (ekranowe przewijanie w prawo) [wtórne]. River City Girls: powiązane obszary miasta z kilkoma wejściami do lokali i sklepów, w manierze metroidvanii [wtórne]. Scott Pilgrim: poziomy liniowe z mapą świata [wtórne].
- **Skręt w przecznicę:** nie; pas daje ruch góra/dół, ale ulica boczna to nowy odcinek, najczęściej osobne wejście/poziom [wtórne].
- **Głębia:** pas o szerokości ok. 1/4-2/3 kadru; w `rivercitygirls-1` (wnętrze stołówki) pas obejmuje większość podłogi, ale przeszkody to meble, które stają „wzdłuż”, nie w głąb [zrzut].
- **Kierunki postaci:** 2 (lewo/prawo, lustro); ruch w pionie bez obracania sprite'a [wtórne]. Ten wzorzec jest najtańszy z trzech [wniosek].
- **Wnętrza:** osobne pokoje o tym samym pasie (`rivercitygirls-1`) [zrzut].
- **Styl:** SoR4 to **nie pixel art** (rysunek HD, komiksowe konturowanie, nasycony neon, `sor4-1`); River City Girls i Scott Pilgrim to pixel art, ale **kreskówkowy/arcade, jasny, o dużych głowach** (mało „dorosły”, zob. `rivercitygirls-1`) [zrzut].
- **Przykłady:** `sor4-*.jpg`, `rivercitygirls-*.jpg`, `scottpilgrim-*.jpg`.

### Tabela: swoboda i koszt

Skale względne [wniosek], nie dane twórców.

| Model | Swoboda eksploracji (1-5) | Koszt postaci | Koszt teł/budynków | Ryzyko |
|---|---|---|---|---|
| Czysty side-scroll (Kathy Rain, Gemini Rue) | **2** (ekrany, jeden pas podłogi, wyjścia) | **niski**: 2 kierunki + lustro, ok. 30-45 px | **średni**: każda scena malowana, ale dowolny kąt i światło | miasto jako graf ekranów, a nie ciągła mapa; sprzeczne z wymaganiem swobodnej eksploracji |
| Ostry rzut z perspektywą (Broken Sword, TP) | **3** (chodzenie w głąb sceny, wyjścia w bok i w głąb) | **średni-wysoki**: 4-8 kierunków (BS „8” niepotwierdzone) + skalowanie, albo wiele wersji skali | **wysoki**: ręcznie malowana scena na każdą lokację, perspektywa i oświetlenie ręcznie; tła Reforged wymagały odtworzenia | skalowanie sprite'ów w pixel arcie (zniekształcenia/mieszanie skali pikseli), koszt tła rośnie liniowo z liczbą scen, nadal brak ciągłej mapy |
| Pas głębi (beat 'em up) | **2-3** (swobodny ruch w pasie, brak skrętu; zależy od kompozycji poziomu) | **najniższy**: 2 kierunki + lustro, brak obrotów | **niski-średni**: kafle/fasady składane w pas, w tym jeden poziom ulicy; wnętrza jako sale | świat „korytarzowy”, mały pas głębi, kreskówkowy odbiór gatunku; dorosły ton zależy od stylu rysunku |

### Porównanie z 3/4 (z `67`)

[wniosek]: żaden z trzech modeli nie spełnia razem „ciągła mapa + skręt w przecznicę + dorosły pixel art”. Najbliżej jest ostry rzut (świat jako graf scen, ale dużo głębi w scenie) i pas głębi (najtańszy, ale najbardziej korytarzowy). 3/4 daje ciągłą mapę kosztem 4-8 kierunków i dachów/fasad (zob. `67`, sekcja kosztów). Otwarte do sprawdzenia grą: (a) liczba kierunków Broken Sword i Thimbleweed, (b) czy River City Girls pozwala na ulicę „w głąb” poza pasem, (c) skalowanie sprite'ów w Thimbleweed.

## B. Kotwice nastroju (vibe, kolor, światło, powaga)

Człowiek: NORCO jest „w miarę ok, ale nie dokładnie to”. Poniżej: kandydaci, czy to pixel art, paleta, światło nocą, faktura, nastrój, co brać/czego nie.

| Gra | Pixel art? | Paleta i nasycenie | Światło nocą | Faktura | Nastrój (1 zdanie) | Brać | Nie brać |
|---|---|---|---|---|---|---|---|
| **NORCO** (2022) | **tak** (duże piksele, malarsko) [zrzut `norco-1`] | zgaszona, ciepły zachód + szarofiolet mgły, średnie nasycenie | światło punktowe w mgle (sodowe światła miasta w oparach) | miękkie, rozmyte plamy z blokami pikseli | Gnijące Południe w mglistym zmierzchu, melancholijne. | kolor i mgła, dialogi z portretem (z 60) | bardzo duże piksele, bok jako rzut |
| **Disco Elysium** (2019) | **nie** (malarski render) [zrzut `disco-1`] | brudna, zgaszona: szary, ochra, zieleń butelkowa, akcenty fioletu/czerwieni | pochmurne światło dzienne; nocne kadry ciemne [niski dowód] | pociągnięcia pędzla, zacieki, błoto/śnieg | Zimowy, zdewastowany miejski wiatr, tragikomiczny. | **śnieg i brud na ziemi, paleta zgaszona**, portrety jako osobna warstwa UI | malarskiej techniki i trybu tekstowego |
| **Kentucky Route Zero** (2013-20) | **nie** (płaskie wielokąty, low-poly) [zrzut `krz-1`] | ciemny brąz, bursztyn, pomarańcz; niskie nasycenie, wysoki kontrast | **ciepłe źródła (pochodnie, scena) w ogromnej ciemności**, światło tylko tam, gdzie jest akcja | gładkie, bez tekstury, z mgłą | Magiczny realizm, cisza, samotność w nocy. | **zasada: ciemność jako tło, światło jako bohater**, minimalizm detalu | stylu wektorowego, niezwykle zredukowanych postaci |
| **Lamplight City** (2018) | **tak** (tła; portrety malarskie, nie pixel) [zrzut `lamplight-1`: portrety na czerni] | ciemna, brąz/bursztyn, niskie nasycenie | latarnie gazowe i okna w ciemnych ulicach (wg `67`) | malarskie portrety, pikselowe tła | Wiktoriańskie detektywistyczne Brooklynie w mroku. | portrety dorosłych twarzy, ciepłe światło na ciemnych fasadach | steampunk, portretów na czarnym ekranie jako stylu świata |
| **Kathy Rain** (2016) | **tak** (320×240 ×3) [zrzut `kathyrain-1`] | ciepły żółto-bursztynowy, średnie nasycenie, 90s | ciepłe lampy sufitowe i okno z jasnym światłem w pokoju | miękki cieniowany pixel art z gradientami | Małe miasteczko, retrospekcja, spokojne ciepło z nutą niepokoju. | **ciepłe wnętrza małego miasteczka, dorosłe twarze** | okrągłych portretów, 4:3 |
| **The Last Door** (2014) | **tak** (grube piksele, 2 skale) [zrzut `lastdoor-1`] | prawie czerń, tylko bursztyn lampy i drobne akcenty | **jedna lampa w czerni**, reszta znika | bardzo duże piksele, ciemny rozmyty kadr | Wiktoriański horror z lampą w absolutnej ciemności. | **ekstremalnie skromne światło, tylko lampa i zarys** | zbyt grubych pikseli, brak detalu |
| **Night in the Woods** (2017) | **nie** (wektor, płaskie plamy) [zrzut `nitw-1`] | jesienna: czerwień, pomarańcz, turkus; **wysokie nasycenie** | neon „Miller's”, żarówka w tunelu | gładkie, bez tekstury | Małe miasteczko schyłkowe, jesień, zwierzęcy bohaterowie. | **struktura małego miasteczka (pętla kamienic, sklepów)** | zwierząt, wektorowej jasności, nasycenia |
| **Signalis** (2022) | pixelowy wygląd z **modeli 3D i filtra** (w `60` odrzucony jako 3D) [zrzut `signalis-1`] | oliwkowo-czarny, czerwień akcentu, zielone CRT | **cienie i punktowe światło wskaźników na ciemnej podłodze** | dithering, ziarno, niska rozdzielczość | Klaustrofobiczne, zimne sci-fi horror. | **rygor oświetlenia, cienie, dorosły ton** | sci-fi, zieleni CRT, niskiej rozdzielczości 3D |
| **Pentiment** (2022) | **nie** (malowane 2D, drzeworyt) [zrzut `pentiment-1`] | ciepły żółty/brąz, świece | **świece jako jedyne ciepło na szarym kamieniu** | papier, tusz, ręczne | Bawarska wioska w XVI wieku, zimowa, cicha. | **śnieg i zima w małej wspólnocie (wg opisu), ciepłe świece** | stylu iluminacji, średniowiecza |
| **Mouthwashing** (2024) | **nie** (3D low-poly PS1, dithering) [zrzut `mouthwashing-1`] | zielone monochromatyczne, ciemne, groza | zielone CRT w ciemnym pokoju | ziarno, rozmycie, dithering | Klaustrofobiczny horror statku kosmicznego. | rygor monochromatycznego klimatu (tylko jako wzór ciemni) | 3D, horror psychologiczny, zieleń |
| **Unavowed** (2018) | **tak** (pixel art z portretami) [zrzut `unavowed-1`] | **ciemny brąz + pomarańczowe okna i drzwi**, średnie nasycenie | **deszcz i ciepłe światło okien i lampy w ciemnej uliczce** | miękkie, zniszczone ściany (graffiti, mokry beton) | Nowojorska noc, magiczny noir, mokra uliczka. | **ciepłe okno w zimnej ciemności, deszcz, brudne ściany** | postaci „bohaterskich” nad miastem, duże sprite'y, fantastyka |
| **Vigil: The Longest Night** (2020) | **nie** (malowana grafika, bez pixel artu) [zrzut `vigil-1`] | czarno-biała, niebieskawy cień | **jasne smugi światła** w ciemności | malarska, ziarnista | Mroczne fantasy, groza. | smugi światła i ciemność | metroidvania, fantasy |
| **Lorelai** (2019) | **nie** (3D renderowane, 2.5D) [zrzut `lorelai-1`] | pastelowa żółć + różowe niebo, wysoka jasność | słoneczna, nie nocna | płaskie 3D | Brytyjskie osiedle w ciepłym świetle, groza. | nic (brak nocy), może struktura ulicy | wszystkiego z kadru |
| **Cloudpunk** (2020) | **nie** (voxel 3D) [zrzut `cloudpunk-1`] | granat + neonowy cyan/pomarańcz, **wysokie nasycenie** | **setki ciepłych okien w zimnym granacie, deszcz, smugi** | voxelowa | Deszczowa noc w cyberpunkowym mieście. | **gęstość ciepłych okien w zimnej ciemności** (zasada, w skali miasteczka mniej) | cyberpunku i nasycenia neonów |
| **Fran Bow** (2015) | **nie** (ręcznie rysowane 2D) [zrzut `franbow-1`: łamigłówka; mało danych] | ciemny brąz i złoto | ciemne wnętrza | rzeźbione, ornamentalne | Horror dziecięcy, groteskowy. | nic o nastroju noir | nastrój infantylnej grozy |
| **The Darkside Detective** (2017) | **tak** (grubsze piksele, komiks) [zrzut `darkside-1`] | ciemny fiolet/bordo + żółty płomień, **średnio-wysokie nasycenie, kreskówkowe** | świece i magiczny blask | płaskie kolory, ciemna winieta | Małe miasto Twin Lakes, komediowe paranormalne. | pomysł małego miasta z wnętrzami i światłem świec | humoru, kreskówkowej kreski |
| **The Case of the Golden Idol** (2022) | **tak** (pixel art, 1-sceniczne kadry) [zrzut `goldenidol-1`] | ziemisty oliwkowo-szary, niska nasyceń, tylko akcenty | światło wewnętrzne z lamp | płaskie, grube kontury | Pokój zbrodni jak obraz, śledcza gra. | **paleta zgaszona, kompozycja sceny, powaga dorosła** | płaskie, groteskowe postacie, brak eksploracji |
| **Papers, Please** (2013) | **tak** (niska rozdzielczość, 1 odcień) [zrzut `papersplease-1`] | **szaro-niebieski, prawie monochrom** | brak (UI) | ostre piksele | Zimny totalitarny punkt graniczny. | **paleta zimna i zgaszona jako wzorzec zimy** | UI-owa kompozycja |
| **Gemini Rue** (2011) | **tak** (320×240 ×4) [zrzut `geminirue-1`] | **fiolet/granat + zieleń, niska jasność**, deszcz | **mokra uliczka w chłodnym fiolecie, jedna jasna poświata** | pikselowa, surowa | Sci-fi noir w deszczu. | **zimna paleta, poświata deszczu** | sci-fi, 4:3 |

Uwagi o dopasowaniu [wniosek]:

- **Najbliżej wymagań noc + ciepłe okna + pixel art:** Unavowed (`unavowed-1`: pomarańczowe okna i drzwi na brązowo-czarnej ścianie, deszcz) oraz Kathy Rain (wnętrza). Gemini Rue to druga skrajność: zimny fiolet.
- **Zasada światła do skopiowania:** KRZ i The Last Door (ciepłe źródło w prawie całkowitej ciemności), Cloudpunk (ciepłe okna w granacie, ale neon i nasycenie odpadają).
- **Zima:** nie ma wśród kandydatów pixel artowej zimy w nocy. Pentiment (opis w kadrze: „w środku zimy”, ale to wspomniana legenda o świętej, nie widok), Disco (śnieg na ziemi), Papers, Please (zimna paleta) to ślady do zbierania; reszta w `66`.
- **Pułapki:** Mouthwashing/Signalis/Lorelai to 3D lub filtry; nie nadają się jako wzór sprite'ów, tylko jako ciemność i rygor.

## Co z tego wynika (nie decyzja)

| Rola | Propozycja do rozważenia |
|---|---|
| Rzut (jeśli bok) | ostry rzut z perspektywą (Thimbleweed Park jako wzór pixel artu) albo pas głębi; oba rezygnują z ciągłej mapy |
| Światło | KRZ, The Last Door, Unavowed |
| Kolor/paleta miasteczka | Kathy Rain, Gemini Rue (zimny kontrast), Disco (zima) |
| Powaga i zgaszenie | The Case of the Golden Idol, Papers, Please |

## Otwarte pytania

1. Ile kierunków mają Broken Sword (1/2/Reforged) i Thimbleweed Park? Sprawdzić grą, filmem lub kodem ScummVM.
2. Czy `rivercitygirls` pozwala na ruch „w głąb” poza pasem (ulica boczna)? Sprawdzić grą.
3. Czy w Thimbleweed Park sprite postaci jest skalowany w rzucie z perspektywą, i jakim kosztem dla czytelności pikseli?
4. Pentiment: potwierdzić, czy wieś ma zimowe sceny (kadr tylko cytuje legendę o zimie).
