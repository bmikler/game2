> Kopia z game1 (`repo/game1/docs/research/43-sciany-wnetrz-3-4.md`, stan 2026-11-03). Ścieżki i numery notatek odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Wnioski dla game2 są w `docs/grafika.md`.

# Ściany i podział wnętrz w widoku 3/4

Ticket: `docs/wayfinder/tickets/43-sciany-wnetrz-3-4.md`. Data researchu i dostępu do źródeł: **2026-10-29**. Wejście: prototyp `game1-proto/prototype/lighting` (`kit/room_shell.gd`, `rooms/*.tscn`, `station_kit.tscn`) i uwaga człowieka: sala główna leży tuż pod gabinetem i pokojem socjalnym, ściana między nimi to cienka linia, a każdy górny pokój ma wysoką ścianę tylną z oknami. To wygląda dziwnie. Dwa dopytania człowieka w trakcie: (1) czy inne gry pokazują tylko ścianę tylną i jak rysują plan nieregularny (L, schodki, pokoje jeden nad drugim); (2) ocena pomysłu: każdy pokój ma pełne ściany, pokazany jest tylko bieżący, reszta przyciemniona, a ściana zasłaniająca bieżący pokój znika.

**Źródła.** Twórcy tych gier prawie nie opisują ścian wnętrz w devlogach. Najmocniejszym źródłem są więc **oficjalne zrzuty ekranu ze stron gier na Steamie** (pobrane przez API `store.steampowered.com/api/appdetails`, oglądane w 1920×1080). Do tego tutorial ścian z paczki LimeZu Modern Interiors (obraz od autora), devlog proceduralnych wnętrz gry Subveillance, pomoc RPG Maker MZ i blog Project Zomboid. Wiki Stardew Valley, Pixpil (Eastward) na X i część bloga Zomboid zwróciły 403.

Oznaczenia:
- **[zrzut]**: widziałem na oficjalnym zrzucie ekranu (link). Opis jest moją interpretacją obrazu, ale sam obraz jest pierwotny.
- **[źródło]**: potwierdzone w tekście lub obrazie od twórcy.
- **[wiedza ogólna]**: pamiętam z gier, w tym researchu nie sprawdzone.
- **[wniosek]**: moja interpretacja albo propozycja.

## Streszczenie i rekomendacja

- **Tak, gry pokazują wysokość tylko na ścianach zwróconych do kamery (południowych), ale robią to w *każdym* miejscu, gdzie taka ściana graniczy z podłogą, a nie tylko na górze pokoju.** Ściana działowa między pokojem górnym a dolnym jest rysowana jako **wierzch ściany (gruby pas) plus pełna ściana tylna pokoju dolnego**. Pokój górny kończy się u dołu samym wierzchem, a pokój dolny ma pod nim swoją wysoką ścianę z obrazami, drzwiami i oknami (gdy wychodzi na zewnątrz). Widać to na zrzutach Graveyard Keeper (tawerna: dwie sypialnie pod salą), To the Moon (korytarz pod sypialnią), Stardew Valley (Community Center), Children of Morta (dom Bergsonów) i w tutorialu LimeZu. **W naszym prototypie brakuje właśnie ściany tylnej sali głównej** (`main_hall.tscn` ma `wall_height_px = 0`), dlatego granica wygląda jak linia.
- **Plan nieregularny:** każde Pomieszczenie, wnęka, uskok i filar ma ścianę tylną na **własnej** wysokości ekranu, tam, gdzie zaczyna się jego podłoga. W kostnicy Graveyard Keepera widać pięć różnych poziomów ścian tylnych w jednym kadrze, w Community Center Stardew trzy. Pionowe odcinki (ściany boczne, boki uskoków) mają tylko wierzch. Reguła daje się zapisać w kodzie: „każdy odcinek ściany z podłogą *pod* sobą dostaje lico 2,6 m, każdy inny tylko wierzch”.
- **Te gry oszukują geometrię:** ściana działowa zajmuje na ekranie tyle miejsca w pionie, ile ma wysokości (u nas 104 px + wierzch), czyli w rzucie jest „gruba na 2,6 m”. Gracz tego nie zauważa. Dzięki temu nic niczego nie zasłania i nie trzeba nic wygaszać. Przy 1 m = 40 px w każdej osi trzeba dodać ok. 110 px między podłogami pokoju górnego i dolnego.
- **Ściany przednie (dolne):** w żadnej z obejrzanych gier 2D w stylu Stardew nie mają wysokości. Są tylko wierzchem, a drzwi wyjściowe to przerwa albo „języczek” podłogi wystający poza obrys (Stardew, To the Moon, Graveyard Keeper). Wyjątkiem jest Moonlighter: pokój jest rysowany jak „misa” z pochylonymi do środka wszystkimi ścianami, także dolną i bocznymi (z oknami). Wymaga to rysowania każdej ściany w perspektywie, więc dla nas jest za drogie.
- **Sąsiednie pokoje:** w grach przytulnych (Stardew, Graveyard Keeper, Children of Morta, To the Moon) **są widoczne i oświetlone po swojemu**. Oddziela je czarna pustka i gruby wierzch ściany, a nie przyciemnianie. Kamera jest ograniczona do mapy, a sąsiedzi wchodzą w kadr na brzegach. Pokoje wygaszane do czerni do czasu wejścia gracza to wzorzec z gier akcji i lochów [wiedza ogólna].
- **Pomysł z wygaszaniem ściany (dopytanie 2):** robią to gry o prawdziwej geometrii 3D albo izometrii, np. Project Zomboid („sims-style cutaway”, który zastąpił wcześniejszy „transparent blob effect” [źródło]), The Sims i Death Trash (niskie ściany w izometrii [zrzut]). Żadna z obejrzanych gier 2D w widoku 3/4 tak nie robi. **Werdykt: odradzam jako podstawę.** Wygaszanie dokłada stan zależny od pozycji gracza, a ADR 0007 odrzucił już ekspozycję sterowaną graczem, bo „pokój jaśniał po wyjściu gracza na korytarz, co wyglądało jak błąd”. Do tego dochodzą prześwitujące lico nad podłogą, sortowanie w drzwiach i kamera. Szczegóły w §6. Dopuszczam jeden wąski wariant: lekkie wygaszenie (do ok. 40–60% krycia) samego lica, tylko gdy postać stoi za nim (jak drzewa i budynki w Stardew [wiedza ogólna]).
- **Okna w ścianach bocznych i przednich:** w obejrzanych grach z wierzchem zamiast ścian bocznych okien bocznych **nie rysuje się**. Okna są tylko na ścianach tylnych, a światło z innych stron pokazuje się jako plamę na podłodze. Moonlighter (okrągłe okna w pochyłych ścianach bocznych i plamy pod nimi) to wyjątek, który wynika z rysowania „misy”. Propozycja: okno w ścianie przedniej albo bocznej to tylko smuga światła (`PointLight2D` z teksturą trapezu) wchodząca spod wierzchu, plus ewentualnie parapet i jaśniejszy fragment wierzchu [wniosek].
- **Trzy wzorce i ich koszt:** A „bryła ściany” (lico na każdej ścianie z podłogą pod spodem; mała zmiana w `RoomShell`, assety bez zmian), B „przekrój z wygaszaniem” (geometria metryczna, wygaszanie lica przy graczu; średni koszt kodu, ryzyko błędów progowych), C „jeden pokój na kadr” (Pokémon, Sea of Stars, Moonlighter; najtańszy, ale sprzeczny z ciągłą sceną). Tabela w §7.
- **Rekomendacja dla posterunku: wzorzec A.** Sala główna dostaje własną ścianę tylną 104 px (lico ściany działowej), która stoi pod wierzchami gabinetu i pokoju socjalnego. W licu są **otwory drzwiowe** 0,9 × 2,1 m prowadzące do obu pokojów, plus tablice ogłoszeń, gablota i grafik dyżurów zamiast okien. Sala przesuwa się w dół o 104 px (podłoga od y ≈ 378 zamiast 274). Cała mapa nie zmieści się w 540 px wysokości, ale kamera i tak trzyma się granic bieżącego Pomieszczenia. Cela: osobne Pomieszczenie z boku sali, oddzielone **kratą zamiast lica** (przezroczyste lico, które samo rozwiązuje problem widoczności). Drzwi wyjściowe zostają przerwą w wierzchu przedniej ściany sali, z wycieraczką i chłodną smugą światła z zewnątrz. Przyciemniania sąsiadów nie robimy. Za klimat odpowiadają ich własne światła i czarna pustka między bryłami. Plan i liczby są w §8.

## 1. Co widać w grach

| Gra | Ściana tylna | Ściana działowa „pod” pokojem | Ściany boczne | Ściana przednia, wyjście | Sąsiednie pokoje | Pewność |
|---|---|---|---|---|---|---|
| **Stardew Valley**, dom na farmie | wysoka, tapeta, okno | (kuchnia i salon bez ściany, tylko zmiana podłogi) | sam wierzch (pomarańczowy obrys) | sam wierzch; wyjście to wystający „języczek” podłogi | sypialnia obok widoczna przez czarną przerwę, połączona wąskim korytarzem, **który ma własną, niższą ścianę tylną** | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/413150/ss_37f15ea893ec1fa7c9e73106f512e98161bac61b.1920x1080.jpg) |
| **Stardew Valley**, Community Center | wysoka, deski, dwa okna z **pionowymi smugami światła** na podłodze | pokoje boczne mają ściany tylne niżej na ekranie; dolne przejścia to czarne otwory w grubym obrysie | sam wierzch | sam wierzch, przejścia w dół jako czarne prostokąty | sąsiednie pokoje widoczne w rogach kadru, z własnymi ścianami tylnymi | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/413150/ss_6422d297347258086b389e3d5d9c0e0c698312e4.1920x1080.jpg) |
| **Graveyard Keeper**, tawerna | wysoka, belki, dwa okna | **dwie sypialnie pod salą: cienki ciemny wierzch, pod nim pełne ściany tylne sypialni z drzwiami** | gruby ciemny wierzch, także między sypialniami | sam wierzch, przerwa na drzwi | wszystkie pokoje widoczne jednocześnie, oświetlone świecami, bez przyciemniania; wnęka baru ma ścianę tylną niżej (plan L) | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/599140/ss_75bcd3ed3fe2a3ec162177ecf01c3217e26dbe25.1920x1080.jpg) |
| **Graveyard Keeper**, kostnica | kamienna, pochodnie | — | gruba kamienna bryła z wierzchem | sam wierzch, wyjście to przerwa w ciemność | **pięć poziomów ścian tylnych** (wnęki, uskoki, filary z licem) | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/599140/ss_5c25486a1e9bdbbd0cfa45c84969d69a05e46392.1920x1080.jpg) |
| **To the Moon** (RPG Maker XP) | wysoka, trzy okna z zasłonami | **korytarz pod pokojem z prawej: czarny pas wierzchu, pod nim pełna ściana korytarza z obrazami** | sam wierzch | sam wierzch, wyjście to wnęka z prześwitem i strzałką | sąsiedni pokój widoczny przez przerwę, cała mapa w ciemnej winiecie | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/206440/ss_244339bfc260fdc2d2f4cdbe3fc3c6df0cb700ed.1920x1080.jpg) |
| **To the Moon**, dom dziecka | dwa pokoje obok siebie, każdy z oknem | ściana działowa to pionowy wierzch, a **wolnostojący fragment ściany ma lico od dołu** | sam wierzch | sam wierzch, korytarz wychodzi w dół | — | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/206440/ss_4a7896fd41897b0b65db935a28d2c418e397d7ed.1920x1080.jpg) |
| **Children of Morta**, dom | wysokie, ozdobne | pokoje piętrowo jeden nad drugim: **ozdobny pas wierzchu, pod nim ściana tylna dolnego pokoju** | wierzch / słupy | niska ściana z roślinnością, główne drzwi wycięte | wiele pokoi naraz w kadrze | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/330020/ss_ffcc7c2898adaf56c8302e17d5a2297a5abc2bfc.1920x1080.jpg) |
| **Moonlighter**, sklep i dom | „misa”: wszystkie ściany pochylone do środka | dom nad sklepem: dolna ściana domu pokazuje lico z drzwiami „SHOP”, pod pasem ściana tylna sklepu z drzwiami „HOME” | **pochylone lico z okrągłymi oknami i plamami światła pod nimi** | niska pochylona ściana z drzwiami | wszystko poza domem czarne | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606150/ss_6264f9e73fe2db8a427c5bc3d250123eaef79456.1920x1080.jpg) |
| **Sea of Stars**, gospoda | jeden duży pokój wypełniający kadr, ściana tylna z oknem | — | brzegi w winiecie | poza kadrem | nie widać | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1244090/ss_8a196c4fc247a083a9580873d2c81a336c2543a3.1920x1080.jpg) |
| **Death Trash** | izometria, ściany pokazane jako **niskie, ucięte bryły** | j.w. | j.w. | j.w. | ciemne | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/941460/ss_30b47bcdc5cba731e2d1656eb34bca573a78d82e.1920x1080.jpg) |
| **LimeZu Modern Interiors** (tutorial ścian) | lico 2–3 kafle | lico na każdym odcinku z podłogą pod spodem; wystające ściany mają wierzch i lico od dołu | wierzch | wierzch | — | [źródło: obraz autora](https://limezu.itch.io/moderninteriors/devlog/209960/tutorial-how-to-walls) |
| Pokémon (2D) | wysoka | jeden pokój na mapę | wierzch / brak | brak, wycieraczka na dole | brak, czarne tło | [wiedza ogólna] |
| Unpacking | izometryczny „domek dla lalek”, dwie ściany tylne | jeden pokój na raz | — | brak | brak | [wiedza ogólna] |
| Octopath Traveler | HD-2D, ściana przednia usunięta | pokój na kadr | — | — | ukryte | [wiedza ogólna] |
| Eastward | nie przeanalizowałem wnętrz wielopokojowych | | | | | nie sprawdzone (X/Pixpil 403) |
| Replaced | gra z boku (side-scroller 2,5D), nie dotyczy widoku 3/4 | | | | | [wiedza ogólna] |

**Wspólny mianownik obejrzanych gier 2D w widoku 3/4:**
1. Wysokość (lico) mają tylko ściany zwrócone do kamery.
2. Wszystkie ściany mają wierzch (gruby, kontrastowy pas, zwykle bardzo ciemny albo z jasnym obrysem), a poza bryłą budynku jest czerń.
3. Ściana przednia to tylko wierzch.
4. Pokój dolny „podpiera” pokój górny swoją ścianą tylną.

Autor paczki LimeZu pisze o tym w komentarzu: wyższe ściany (3–4 kafle) dają więcej miejsca na wystrój i duże obiekty, ale pokój wygląda wtedy mniej jak dom [źródło, strona tutorialu]. U nas 2,6 m to ok. 2,6 „kafla” po 40 px, czyli w tym samym zakresie.

## 2. Tylko ściana tylna? Plany nieregularne i pokoje jeden nad drugim

**Reguła (z obrazów LimeZu, Graveyard Keepera, Stardew i To the Moon):** w rzucie każdy odcinek ściany ma dwie strony. Jeśli strona **południowa** (zwrócona do kamery) graniczy z podłogą, odcinek dostaje lico pełnej wysokości, stojące na tej podłodze. Wierzch dostaje każdy odcinek, zawsze. W efekcie:
- **Ściana tylna Pomieszczenia** to po prostu lico górnego odcinka obrysu.
- **Ściana między pokojem górnym a dolnym** to wierzch (dolna krawędź pokoju górnego) plus lico tej ściany od strony pokoju dolnego, czyli ściana tylna pokoju dolnego. Pokój górny nie dostaje „ściany przedniej” z licem. Widzimy jego podłogę aż do wierzchu.
- **Uskok w planie L:** część pokoju, która „cofa się” w dół (np. wnęka baru w tawernie GK, korytarz w domu Stardew), ma ścianę tylną niżej na ekranie. Pionowy bok uskoku ma tylko wierzch. Lico górnej części kończy się na narożniku, a wierzch boku biegnie w dół wzdłuż krawędzi lica i zamyka je (tak wygląda narożnik w Stardew i GK).
- **Fragment ściany wystający z dołu w głąb pokoju** (np. przepierzenie od ściany przedniej) to sam wierzch, bo jego koniec od strony kamery dochodzi do ściany przedniej. **Fragment wystający z góry** (filar, przepierzenie od ściany tylnej) ma wierzch na całej długości i lico na końcu, tam, gdzie pod nim zaczyna się podłoga (filary w kostnicy GK, wolnostojący fragment w domu z To the Moon, wypustka w tutorialu LimeZu).
- **Devlog Subveillance** (proceduralne wnętrza w rzucie „oblique top-down”) opisuje tę samą zasadę od strony kodu: ściany „na górze i na dole pokojów są widoczne, a ściany po lewej i prawej z boku”, a żeby nie dublować wspólnych ścian, każdy pokój rysuje tylko swoją górną i lewą ścianę [źródło: [Subveillance, Procedural generation of building interiors, part 6](https://unusual-intersection.itch.io/subveillance/devlog/541223/procedural-generation-of-building-interiors-part-6)]. Drzwi powstają przez usunięcie fragmentu właśnie narysowanej ściany tam, gdzie pokój graniczy z korytarzem.
- **RPG Maker** ma na to osobny zestaw autokafli A4 (ściany), który edytor powiela w pionie i poziomie, a cień rzuca na kafel po prawej od pionowo ułożonych ścian [źródło: [pomoc RPG Maker MZ, A4 Walls](https://rpgmakerofficial.com/product/MZ_help-en/01_11_01.html)]. Stąd biorą się wnętrza To the Moon.

**Geometria [wniosek].** W prawdziwym 3D przy kamerze pod 45° i skali 1:1 w obu osiach ściana 2,6 m zasłania 2,6 m podłogi za sobą. Gry kafelkowe tego nie robią: lico zajmuje własne miejsce w pionie, jakby ściana działowa miała w rzucie 2,6 m grubości. Dlatego nic się nie zasłania i nic nie trzeba wygaszać. Dla nas oznacza to, że **współrzędne ekranu nie są już współrzędnymi rzutu**: każda ściana działowa pozioma przesuwa w dół wszystko pod sobą o `wall_height_px + cap`. `RoomShell` już ma pozycję i `wall_height_px` na Pomieszczenie, więc wystarczy to uwzględnić przy rozmieszczaniu w `station_kit.tscn`.

```
Plan L / schodkowy (widok na ekranie, x w prawo, y w dół)

  ##########################            # = wierzch (cap), czerń poza bryłą
  #|||| ŚCIANA TYLNA A ||||#            | = lico 2,6 m
  #|||||||||||||||||||||||||#########
  #  podłoga A              ||| B |||#  <- ściana tylna wnęki B niżej (uskok)
  #                         |||||||||#
  #                           podł. B#
  ####===########################==###  <- wierzch dolnej krawędzi A i B (cienki)
  #||||[ ]||| ŚCIANA TYLNA C |||[ ]||#  <- lico = ściana tylna sali C, w niej otwory drzwi
  #||||[ ]|||||||||||||||||||||[ ]|||#
  #  podłoga C                       #
  #                                  #
  ##############    #################   <- ściana przednia: sam wierzch, przerwa = wyjście
```

## 3. Drzwi

- **W ścianie działowej poziomej (pokój dolny → górny).** Drzwi są narysowane **w licu pokoju dolnego**, z progiem na jego podłodze. W wierzchu pokoju górnego nad nimi jest przerwa. Tak wyglądają sypialnie w tawernie GK [zrzut] i drzwi „HOME” w sklepie Moonlighter [zrzut]. W Community Center Stardew przejścia w dół to czarne otwory w grubym obrysie [zrzut]. Przejście przez „grubą” ścianę rozwiązuje się na dwa sposoby [wniosek; mechaniki w tych grach nie zweryfikowałem]:
  1. **Otwór na wylot:** w licu jest wycięty otwór 0,9 × 2,1 m (36 × 84 px) z ciemnym ościeżem, a w środku pas podłogi łączący obie podłogi. Gracz idzie przez pas, rysowany nad licem (`z_index` albo pochodzenie y-sortu lica przy jego górnej krawędzi). Nadproże (0,5 m = 20 px lica nad otworem) i wierzch są rysowane nad głową gracza. Przejście ma ok. 110 px, czyli ok. 1,8 s przy obecnych 60 px/s. Można je skrócić, przyspieszając chód w pasie.
  2. **Drzwi jako zdarzenie** (RPG Maker, To the Moon [wiedza ogólna]): drzwi w licu to sprite, wejście przenosi gracza do progu w pokoju górnym, z krótkim wygaszeniem albo bez. Taniej, ale gubi ciągłość sceny.
- **W ścianie bocznej (pionowej).** Przerwa w wierzchu, a podłoga przechodzi płynnie (korytarz w domu Stardew [zrzut]). Skrzydło drzwi, jeśli w ogóle jest, to wąski pionowy sprite otwarty pod ścianę. W naszym rzucie przejście ma tylko grubość wierzchu (6 px), więc nie ma problemu z sortowaniem.
- **W ścianie przedniej (wyjście z budynku).** Przerwa w wierzchu albo „języczek” podłogi wystający poza obrys (dom Stardew, To the Moon ze strzałką [zrzut]). Samo skrzydło nie jest widoczne. Wystarczy wycieraczka, próg i światło z zewnątrz [wniosek].

## 4. Sąsiednie pomieszczenia: pokazać, przyciemnić czy ukryć

- **Pokazane w całości (Stardew, GK, Children of Morta, To the Moon) [zrzut].** Między bryłami jest czerń, a każdy pokój ma swoje światło: w nocy sypialnia w Stardew jest niebieska i oświetlona kominkiem, a salon ciepły. Nikt nie przyciemnia pokoju tylko dlatego, że nie ma w nim gracza. Odczucie „jestem tutaj” daje kamera, wierzch ściany i czerń.
- **Ukryte (Pokémon, Sea of Stars, Moonlighter, Octopath) [zrzut/wiedza ogólna].** Jeden pokój wypełnia kadr albo stoi sam na czerni.
- **Ukryte do wejścia, odsłaniane przy wejściu (lochy, roguelike, stealth, np. Enter the Gungeon) [wiedza ogólna].** Pełni funkcję mechaniczną (zaskoczenie, mgła wojny). Do śledztwa w znanym posterunku nie pasuje.
- **U nas:** kamera trzyma się granic bieżącego Pomieszczenia, a każdy pokój ma swój `RoomLighting` i ekspozycję (ADR 0007). Sąsiedzi, którzy wchodzą w kadr, są już ciemniejsi albo jaśniejsi zgodnie ze swoimi luksami. To jest wzorzec Stardew i GK, tylko z lepszym światłem.

## 5. Okna w ścianach bocznych i przednich, światło z boku i z dołu

- W obejrzanych grach z wierzchem zamiast ścian bocznych **okna są tylko w ścianach tylnych** (Stardew, GK, To the Moon, Children of Morta) [zrzut]. Stardew rysuje pod oknami ściany tylnej pionowe smugi światła na podłodze (Community Center) [zrzut].
- Moonlighter rysuje okna w ścianach bocznych, ale tylko dlatego, że ściany boczne mają u niego lico („misa”). Pod oknami są ciepłe plamy na podłodze [zrzut].
- **Propozycja dla nas [wniosek]:**
  - **Okno boczne** to niewidoczne źródło z wycinkiem w wierzchu: kilka jaśniejszych pikseli albo parapet 2–3 px na wierzchu, a od ściany na podłogę pada smuga jak z `WindowLight`, tylko obrócona o 90° (trapez rozszerzający się w głąb pokoju, kierunek ze Słońca jak w 22b §4).
  - **Okno w ścianie przedniej** to smuga wchodząca od dolnej krawędzi pokoju w górę. Przy niskim Słońcu zimą byłaby długa (22b: 3–8 m), ale fasada z oknami posterunku i tak patrzy na południe, czyli do góry mapy. Okna dolne potrzebujemy tylko dla pomieszczeń po stronie północnej, a te według 22b §5 są bez okien (WC, szatnia, archiwum, areszt).
  - W prototypie jest to możliwe bez nowych assetów, bo smuga to tekstura światła, a nie sprite.

## 6. Ocena pomysłu: pełne ściany, przyciemnianie sąsiadów, wygaszanie ściany zasłaniającej

**Kto robi coś podobnego:**
- **Project Zomboid** (izometria): najpierw „single building cutaway”, potem „sims-style cutaway”, który miał „finally do away with the transparent blob effect”, czyli przezroczystą plamę wokół gracza we wnętrzach. Twórcy piszą, że cutaway mocno poprawia widoczność w budynkach, ale wciąż mogą potrzebować „transparent doors and tall furniture (such as wardrobes or fridges)”, żeby nie zasłaniały gracza [źródło: [Saving Public Zomboid, 2017](https://projectzomboid.com/blog/news/2017/07/saving-public-zomboid/), [Jan(im)uary](https://projectzomboid.com/blog/?p=7049)]. Wcześniej musieli przebudować renderer, żeby mieć w ogóle „engine support to be able to do proper cut-away walls” [źródło: [Iso Revolution](https://projectzomboid.com/blog/?p=3389)].
- **The Sims** (3D): tryby ścian podniesionych, ściętych przy kamerze i opuszczonych [wiedza ogólna].
- **Death Trash** (izometria 2D): ściany wnętrz stale niskie, ucięte [zrzut].
- **Stardew Valley**: korona drzewa i budynek na farmie robią się półprzezroczyste, gdy gracz stoi za nimi [wiedza ogólna]. To jedyny bliski odpowiednik w 2D 3/4, ale dotyczy obiektów na zewnątrz, nie ścian wnętrz.
- **Godot**: forum podaje trzy drogi (alpha na kafel przez callback TileMapLayer, osobna warstwa wygaszana w całości, maski światła). GDQuest w ogóle omija wygaszanie i stawia na y-sort ścian z kolizją tylko u podstawy [źródło: [forum Godota](https://forum.godotengine.org/t/make-a-wall-tree-a-little-bit-translucent-trasnparent-when-there-is-a-player-behind-it-in-2d-top-down-especially/111322), [GDQuest](https://www.gdquest.com/tutorial/godot/shaders/silhouette-2d)].

**Pułapki u nas [wniosek]:**
1. **Czytelność.** Przy metrycznym rzucie lico ściany działowej zasłania pas 2,6 m (104 px) podłogi pokoju górnego. Gabinet ma podłogę 144 px, więc lico zakrywa ponad 70% jego głębokości. Wygaszone lico nad podłogą daje „ducha” ściany z tablicami i drzwiami, nałożonego na meble, czyli szum w najważniejszym miejscu kadru.
2. **Stan zależny od gracza.** Pokój jest przyciemniony, gdy gracz go opuści, a lico znika, gdy gracz wejdzie. To ten sam typ zachowania, który ADR 0007 odrzucił dla ekspozycji (miganie na progu, pokój jaśniejący po wyjściu gracza). Na progu drzwi trzeba będzie histerezy i przejścia w czasie, a i tak w drzwiach przez chwilę widać dwa pokoje w różnych stanach.
3. **Ciągłość światła w drzwiach.** Przyciemnianie przez `modulate` pokoju mnoży kolor przed oświetleniem. Smuga z okna albo światło lampy przechodzące przez drzwi do pokoju przyciemnionego urywa się na granicy pokoju. Przyciemnianie przez obniżanie luksów walczy z `LightingDirector` (luksy są daną, a nie stanem gracza).
4. **Postacie.** Krogg w przyciemnionym pokoju albo za licem: osobna maska światła (`actor_mask`) musiałaby też znać stan „przyciemniony/wygaszony”. NPC idący przez drzwi zmienia stan pokoju?
5. **Koszt w Godot 2D.** Samo wygaszanie (`modulate.a` lica z `Tween`) jest tanie. Drogie jest to, co dookoła: lico półprzezroczyste dalej dostaje normal mapę i światła 2D, a przez nie widać podłogę oświetloną innym zestawem świateł. Trzeba sprawdzić, czy wygląda to dobrze w HDR i sRGB (ADR 0007), i dopisać testy progów. Kolejność rysowania lica, podłogi pokoju górnego i postaci w y-sorcie trzeba też ustalić ręcznie.
6. **Kamera.** Kamera bieżącego Pomieszczenia i tak pokazuje głównie ten pokój. Przy wzorcu A nie ma czego wygaszać, przy wzorcu B trzeba wygaszać lico i przesuwać granice kamery o 104 px.

**Werdykt:** jako zasada wnętrz pomysł **nie pasuje** do ciągłej sceny z kamerą na Pomieszczenie i światłem liczonym z luksów. Ten sam efekt („widzę cały bieżący pokój, sąsiedzi są obok i mają swój nastrój”) wzorzec A daje bez stanu: ściana nikogo nie zasłania, a sąsiedzi są ciemniejsi, bo mają mniej luksów. Wąski wariant, który ma sens: **wygaszanie do ok. 50% tylko wtedy, gdy postać stoi tuż za licem** (w drzwiach albo w pasie przejścia), na wzór drzew w Stardew. Jest tani, lokalny i nie wymaga przyciemniania pokojów. Warto go zrobić tylko, jeśli test w prototypie pokaże, że postać w otworze drzwi ginie.

## 7. Wzorce z kosztem dla solo deva

| Wzorzec | Na czym polega | Przykłady | Kod w `RoomShell` | Assety (ComfyUI/Pixellab) | Ryzyka |
|---|---|---|---|---|---|
| **A. Bryła ściany** | Lico na każdym odcinku ściany z podłogą pod nim, wierzch na wszystkich, ściana przednia to sam wierzch. Ściany działowe poziome zajmują w pionie `wall_height_px + cap`. | Stardew, Graveyard Keeper, To the Moon, Children of Morta, RPG Maker, LimeZu | **mały**: sala dostaje `wall_height_px = 104` (już jest w klasie); nowe: otwór drzwiowy w licu (jak `_cut_window`, tylko do podłogi), pas przejścia w `walkable()`, opcjonalnie lico na końcu filara/przepierzenia. Ok. 1–2 dni z przestawieniem pokojów. | bez zmian: ściany są proceduralne. Drzwi i ościeże proceduralnie jak okna; dekoracje lica (tablice, gablota, grafik) to zwykłe propsy | rzut ≠ ekran (trzeba przeliczać pozycje przy układaniu planu); budynek jest wyższy na ekranie; przejście przez drzwi w licu trwa ok. 1,8 s |
| **B. Przekrój z wygaszaniem** | Rzut metryczny, każdy pokój ma pełne ściany; lico zasłaniające bieżący pokój jest wygaszane lub ucinane do niskiej listwy; sąsiedzi przyciemniani. | Project Zomboid, The Sims, Death Trash (ucięte) | **średni**: stan „bieżące Pomieszczenie” z histerezą, `Tween` alfy, kolejność rysowania, maski światła postaci, granice kamery; testy progów. Ok. 1 tydzień plus strojenie. | lico z dwóch wersji (pełne i ucięte) albo shader alfy; bez nowych assetów | sprzeczne z duchem ADR 0007; „duchy” ścian nad meblami; światło urywa się w drzwiach |
| **C. Jeden pokój na kadr** | Pokój sam na czerni, sąsiedzi niewidoczni, przejście przez drzwi to cięcie albo przesunięcie kamery. | Pokémon, Moonlighter, Sea of Stars, Octopath | **najmniejszy** (sąsiedzi ukryci przez `visible` albo przycięcie kamery) | bez zmian | łamie decyzję „budynek = jedna ciągła scena”; nie widać Krogga w pokoju obok; mniej klimatu |

## 8. Rekomendacja dla posterunku (wzorzec A)

Stan prototypu (`station_kit.tscn`, `rooms/*.tscn`): gabinet w (200, 20), podłoga 160 × 144; pokój socjalny w (366, 20), podłoga 216 × 144; oba z licem 104 px, więc podłogi kończą się na y = 268, a wierzch dolny na 274. Sala główna w (194, 274), podłoga 400 × 260, `wall_height_px = 0`, `cap_back = false`. Brakuje lica ściany działowej.

**Zmiany (do prototypu z ticketu 35, nie robię ich tutaj):**
1. **Sala główna dostaje ścianę tylną:** `wall_height_px = 104`, a `cap_back` zostaje `false`. Wierzchem nad licem są istniejące przednie wierzchy gabinetu i socjalu (y 268–274, już oświetlane jako próg przez oba pokoje dzięki `front_neighbour_slot`). Wierzchu nie rysujemy podwójnie: to ta sama zasada co w Subveillance (każdy odcinek rysuje jeden pokój). Pozycja sali bez zmian (194, 274), lico zajmuje y 274–378, a podłoga zaczyna się na y = 378. Wysokość podłogi sali można zmniejszyć z 260 do ok. 220 px (5,5 m), żeby cała sala z licem zmieściła się w kadrze 540 px: 104 + 220 + wierzch < 540.
2. **Lico sali to korkowa ściana dyżurki:** tablica ogłoszeń, grafik dyżurów, mapa gminy, gablota z listami gończymi, zegar. Bez okien, bo za ścianą są pokoje. Lico ma maskę światła sali (`slot` sali, `Receiver.SOLID`), więc oświetlają je jarzeniówki sali, a nie okna pokojów górnych. To jest poprawne fizycznie.
3. **Drzwi do gabinetu i pokoju socjalnego:** dwa otwory w licu sali (36 × 84 px, nadproże 20 px), pod przerwami w wierzchu. Pas przejścia o szerokości otworu łączy podłogę sali z podłogą pokoju górnego (`walkable()`). Ościeże ciemne, z jaśniejszą podłogą pokoju górnego widoczną w górnej części otworu. Postać w pasie jest rysowana nad licem. Obecne `door` (przerwa w przedniej krawędzi) zostaje jako przerwa w wierzchu, a otwór w licu dochodzi jako nowa opcja (np. `@export var openings: Array[Vector2i]`).
4. **Cela:** osobne Pomieszczenie przy lewym albo prawym boku sali, połączone przerwą w pionowym wierzchu (drzwi kratowe jako wąski sprite). Jeśli cela leży *pod* salą, jej ściana tylna (lico pod salą) to **krata**: lico rysowane jako pręty co ok. 4–5 px z przezroczystością między nimi. Wtedy z sali widać wnętrze celi przez kratę, co jest czytelne i klimatyczne. Lepszy wariant z boku sali, bo krata w licu oznacza 104 px kraty.
5. **Drzwi wyjściowe:** przerwa w wierzchu przedniej ściany sali (jak teraz `door`), z wycieraczką, progiem i **chłodną smugą** z zewnątrz rano i wieczorem, a nocą z niebieskim światłem latarni. Skrzydła nie rysujemy.
6. **Sąsiedzi:** bez przyciemniania. Kamera trzyma się granic bieżącego Pomieszczenia (z licem sali wliczonym w salę). Gdy gracz jest w sali, widać nad licem dolny pas podłóg gabinetu i socjalu z ich światłem, tak jak w tawernie GK.
7. **Wierzch:** pogrubić z 6 do ok. 8–10 px (0,2–0,25 m) i przyciemnić prawie do czerni z jaśniejszą krawędzią. Na wszystkich zrzutach wierzch jest najsilniejszym elementem kadru, który odróżnia „ścianę” od „linii na podłodze” [wniosek ze zrzutów].

```
Posterunek, widok na ekranie (1 znak ≈ 20 px)
  ######################################
  #||| GABINET |||#||| POKÓJ SOCJALNY |#   lico 104 px, okna (fasada na południe)
  #||[okno]|||||||#|||||[okno 2,4 m]|||#
  #  podłoga 144  #   podłoga 144      #
  #####==######################==#######   wierzch 8–10 px, przerwy nad drzwiami
  #||||[ ]|||| TABLICE, GRAFIK ||[ ]|||#   lico sali 104 px, otwory drzwi 36 × 84 px
  #||||[ ]||||||||||||||||||||||[ ]||||#
  #   SALA GŁÓWNA (recepcja, szafy)    ##########
  #                                    =  CELA   #   przerwa w pionowym wierzchu, krata
  #                                    #         #
  ###########    #######################==########
             ^ wyjście: przerwa, wycieraczka, smuga z zewnątrz
```

## 9. Czego nie zweryfikowano

- **Mechanika przejścia przez drzwi w licu** (pas przez „grubą” ścianę czy teleport) w GK, Stardew i Moonlighter: widziałem tylko statyczne zrzuty. Opis w §3 to wniosek.
- **Eastward, Hyper Light Drifter, CrossCode, Lone Fungus:** nie obejrzałem ich wnętrz (Pixpil na X i IndieDB blokują; Lone Fungus to platformówka z boku, Replaced też jest z boku). Pokémon, Unpacking, Octopath i The Sims opisuję z pamięci.
- **Przezroczystość drzew i budynków w Stardew** znam z gry, nie ze źródła (wiki zwraca 403).
- Projekt Zomboid: cytaty z bloga są pierwotne, ale o 2D 3/4 nie mówią nic wprost. Izometria to inny rzut.
- Wpływ półprzezroczystego lica na oświetlenie 2D z normal mapami w HDR (§6, pkt 5) to wniosek z budowy zestawu oświetlenia, nie test.
- Liczby dla posterunku (§8) opieram na obecnych `.tscn` prototypu. Układ pomieszczeń (archiwum, recepcja, druga cela) ustala ticket 35.
