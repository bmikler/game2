---
title: Specyfikacja Silnika światła
labels: [ready-for-agent]
status: open
source: docs/wayfinder-silnik/map.md (ticket „Specyfikacja silnika”)
---

# Specyfikacja Silnika światła

Źródło reguł: wyłącznie rozstrzygnięcia mapy silnika (`docs/wayfinder-silnik/`, tickety 07–16). Słownik: `GLOSSARY.md`. Załącznik dla krytyków (nie wymagania): [Ściąga wyglądu](sciaga-wygladu.md).

## Problem Statement

Światło i cienie w Poligonach powstawały jako prototyp do oceny wyglądu i były przebudowywane kilka razy. Dom (`SunMap`) i ulica (`StreetMap`) to dwie równoległe kopie z różnymi zasadami (przeliczanie bufora, półcień słońca tylko na ulicy, zasłanianie nieba tylko na ulicy, okno postaci liczone z inną godziną niż reszta bufora). Poprawka w jednej kopii psuła albo omijała drugą, a dane scen siedziały w stałych w kodzie (`dom_bryly.gd`, `ulica_bryly.gd`, maks. 4 pokoje, przejścia zgadywane z cienkich pudełek, losowe świecenie okien). Każda nowa Lokacja wymagała zmian w kodzie silnika. Strojenie odbywało się suwakami i łatkami pod konkretne miejsca.

Z perspektywy człowieka: nie da się zbudować nowej Lokacji ani stroić wyglądu bez ryzyka, że coś innego się zepsuje, a gra nie trzyma 60 fps we wnętrzach.

## Solution

Jeden Silnik światła jako samodzielny addon w `style-lab/addons/swiatlo/` (bez zależności od reszty `style-lab`; do gry przenoszony przez skopiowanie katalogu). Silnik liczy światło i cienie ze wszystkich Źródeł (słońce, niebo, lampy, latarnie, świecące okna, reflektory, papieros) w każdej Lokacji, wnętrzu i plenerze, tym samym kodem i tą samą stylizacją pixel art. Wnętrze i plener różnią się wyłącznie danymi sceny (wnętrze to scena ze stropem i Otworami) i wybranym Zestawem strojenia.

Lokację buduje się w edytorze Godota z węzłów kontraktu sceny (w metrach), a podgląd światła działa od razu w edytorze. Jedynym wejściem czasu jest godzina; z niej powstaje jeden Stan doby dla całego Bufora światła. Wszystko, co jest nastrojem (droga słońca, kolory doby, półcień, siła nieba, Smugi, kurz), to dane artystyczne w `.tres`, strojone wyłącznie Wariantami strojenia od krytyków przełączanymi na żywo w F1. Logika cieni jest sztywna: cień zawsze od Źródła, spójny kierunek, poprawne nakładanie przez sumę w HDR.

Nowe Poligony (Ulica, Dom) są zbudowane wyłącznie z węzłów kontraktu i zawierają trudne sceny testowe. Stary silnik zostaje do końca jako porównanie, potem jest usuwany. Test końcowy: subagent buduje na ślepo, z samej dokumentacji kontraktu, dwie zupełnie nowe Lokacje; cienie mają działać bez żadnej zmiany w kodzie silnika.

## User Stories

### Budowanie Lokacji (autor sceny w edytorze)

1. Jako autor Lokacji chcę układać scenę w edytorze z węzłów kontraktu (Otoczenie Lokacji, Ściana, Otwór, Przesłona z Brył, Źródło), aby nowa Lokacja nie wymagała kodu.
2. Jako autor Lokacji chcę podawać położenia i wymiary w metrach (x, d, z), a pozycję na ekranie dostawać z rzutu, aby geometria światła i obraz zawsze się zgadzały.
3. Jako autor Lokacji chcę przesuwać węzeł myszą po podłodze (x, d) i ustawiać wysokość w inspektorze, aby układanie było szybkie.
4. Jako autor Lokacji chcę widzieć Bufor światła i cienie na żywo w edytorze po przesunięciu Przesłony albo Źródła, aby od razu oceniać układ.
5. Jako autor Lokacji chcę ustawić w edytorze godzinę podglądu, aby sprawdzić scenę w dzień i w nocy bez uruchamiania gry.
6. Jako autor Lokacji chcę jednym Otoczeniem Lokacji wybrać Zestaw strojenia (wnętrza albo plener), profil nieba (miasto albo wieś), gęstość powietrza i jasność odniesienia ekspozycji, aby cała scena miała jeden charakter.
7. Jako autor wnętrza chcę postawić Ściany (odcinek na planie, grubość, wysokość) i strop jako zwykłą Przesłonę, aby niebo wpadało tylko przez Otwory.
8. Jako autor wnętrza chcę dodać do Ściany Otwór (położenie wzdłuż ściany, szerokość, dół, góra), który jest oknem, drzwiami albo przejściem, aby nie istniały osobne rodzaje okien.
9. Jako autor wnętrza chcę dać Otworowi wypełnienie (listwy pionowe i poziome z rozstawem i grubością, część zasłoniętą od góry, przepuszczalność), aby dostać szprosy, żaluzje, opuszczoną roletę, firankę i matową szybę.
10. Jako autor wnętrza chcę wstawić okno w dowolnej ścianie, także bocznej i przedniej niewidocznej, aby Smuga i Plama okna powstały tam, gdzie wyliczy je silnik.
11. Jako autor wnętrza chcę dodać okno dachowe jako Otwór w stropie, aby dostać światło z góry tą samą regułą.
12. Jako autor Lokacji chcę składać Przesłonę z jednej lub kilku Brył (pudełko, pudełko z dachem ze spadem wzdłuż x albo d, walec, uniesione pudełko z pustym dołem), aby kamienice, latarnie, meble i samochód rzucały cień.
13. Jako autor Lokacji chcę oznaczyć Przesłonę jako ruchomą (postać, NPC, samochód), aby jej cień liczył się co klatkę.
14. Jako autor Lokacji chcę dać Przesłonie wychylenie od wiatru (w metrach), aby korona iglaka mogła się kołysać ze wspólnym wiatrem Lokacji.
15. Jako autor Lokacji chcę postawić Źródło powierzchniowe (prostokąt albo kula w metrach) z profilem `.tres`, aby lampa, latarnia, świecące okno, neon i reflektor były tylko danymi.
16. Jako autor Lokacji chcę przyczepić Źródło do Przesłony (latarnia do słupa, reflektor do samochodu, papieros do postaci), aby poruszało się razem z nią i nie było zasłaniane przez nią samą.
17. Jako autor Lokacji chcę sterować mnożnikiem natężenia Źródła z animacji (żarzenie papierosa, migotanie neonu), aby efekty nie wymagały kodu.
18. Jako autor Lokacji chcę postawić Źródło poza kadrem (latarnia za oknem wnętrza), aby wnętrze nie musiało znać Lokacji na zewnątrz.
19. Jako autor Lokacji chcę podłogi na różnych wysokościach jako wierzch Bryły (podest, chodnik), z postacią stojącą na wysokości stóp, aby ozdoby miasta działały bez wyjątków.
20. Jako autor Lokacji chcę dostać ostrzeżenie w edytorze, gdy Otwór wystaje poza Ścianę, Źródło siedzi w Bryle albo brakuje Otoczenia Lokacji, aby błędy sceny były widoczne przed uruchomieniem.
21. Jako autor Lokacji chcę, żeby zapisany `.tscn` zawierał tylko węzły kontraktu, aby pomocnicze węzły silnika nie zaśmiecały sceny.
22. Jako autor Lokacji chcę, żeby południe zawsze było u góry ekranu, a słońce szło ze wschodu (lewo) na zachód (prawo), aby nie ustawiać orientacji w żadnej Lokacji.

### Assety (Przepis mebli, postać)

23. Jako autor Przepisu mebli chcę wiedzieć, co asset daje silnikowi (sprite, uproszczone Bryły, punkt zaczepienia w środku przedniej dolnej krawędzi, opcjonalna mapa normalnych, opcjonalne przyczepione Źródła), aby Przepis produkował gotowe sceny `.tscn`.
24. Jako autor assetu chcę, żeby sprite nie rzucał cienia, a cień liczył się z Brył, aby cienie były spójne i tanie.
25. Jako autor assetu chcę, żeby piksel sprite'a brał pozycję z widocznej ściany Bryły i normalną z mapy normalnych (a bez niej ze ściany Bryły), aby mebel bez mapy normalnych też był poprawnie oświetlony tym samym kodem.
26. Jako autor assetu chcę Bryły uproszczone, nie 1:1 z obrazem, aby generować je z tej samej sceny Blendera co prowadnice Przepisu.

### Światło i cienie (człowiek oceniający wygląd)

27. Jako człowiek chcę, żeby cień każdego obiektu zawsze padał od Źródła, w spójnym kierunku, aby scena była czytelna.
28. Jako człowiek chcę, żeby cienie od kilku Źródeł nakładały się przez sumę światła, bez koloru cienia i kolejności źródeł, aby cień miał barwę tego, co do niego jeszcze dociera.
29. Jako człowiek chcę, żeby niebo było zawsze kopułą zasłanianą przez wszystkie Przesłony (także meble i postać), aby niebo pod gołym niebem i przez okna działało tą samą regułą.
30. Jako człowiek chcę, żeby niebo we wnętrzu nie miało prążków ani duchów okien, aby światło nieba z okien wyglądało gładko.
31. Jako człowiek chcę, żeby szerokość półcienia wynikała z geometrii (rozmiar Źródła × odległość przesłona–odbiornik / odległość źródło–przesłona), aby wysoki komin miał szeroki półcień, a noga stołu ostry cień.
32. Jako człowiek chcę, żeby długość cieni wynikała wyłącznie z wysokości słońca, aby Plamy okna i cienie zawsze się zgadzały.
33. Jako człowiek chcę, żeby postać rzucała cień od wszystkich Źródeł i miała cień kontaktowy, bez stałego reflektora, aby była częścią sceny.
34. Jako człowiek chcę, żeby postać była oświetlana ze wszystkich Źródeł co klatkę na swoich powierzchniach (modelowanie, kontrświatło, wypełnienie), aby wyglądała jak bryła w świetle lampy i okna.
35. Jako człowiek chcę, żeby meble i postać zasłaniały niebo i światło, aby pod stołem było ciemniej.
36. Jako człowiek chcę, żeby niewidoczna przednia ściana rzucała cień i wpuszczała światło swoimi Otworami, aby wnętrze nie wyglądało na scenę bez czwartej ściany.
37. Jako człowiek chcę, żeby chowanie ściany działowej przy wejściu postaci dotyczyło tylko rysowania, aby światło się nie zmieniało.
38. Jako człowiek chcę widzieć Plamę okna na podłodze i ścianach z każdego okna, przez które wpada bezpośrednie słońce, aby wnętrze żyło w ciągu dnia.
39. Jako człowiek chcę widzieć Smugę światła w powietrzu z okien i drobinki kurzu w Smudze, aby wnętrza miały klimat.
40. Jako człowiek chcę widzieć promienie słońca między budynkami i stożki latarni we mgle w plenerze, aby rozproszenie działało wszędzie tą samą regułą.
41. Jako człowiek chcę żaluzje rzucające paski w pikselach, aby szczegół wnętrza czytał się w pixel arcie.
42. Jako człowiek chcę papieros przy twarzy postaci, który żarzy się i oświetla twarz, aby małe Źródła też działały.
43. Jako człowiek chcę widzieć nocą przez okno niebo miasta z łuną albo ciemne, chłodne niebo wsi z księżycem, w zależności od profilu nieba, aby noc miała charakter miejsca.
44. Jako człowiek chcę, żeby lampy i świecące okna włączały się o godzinach z ich profili, aby wieczór zapalał się stopniowo.
45. Jako człowiek chcę słońce skierowane w kamerę nad dachami i pod słońce czytelne cienie, aby trudna scena z pleneru wyglądała dobrze.
46. Jako człowiek chcę, żeby przewijanie doby było płynne: cienie słońca doganiają godzinę z opóźnieniem ok. ¼ s, bez skoku pasów, aby zmiana godziny nie migała.
47. Jako człowiek chcę stały dobowy schemat zachmurzenia (codziennie taki sam), który osłabia słońce, rozjaśnia i wybiela niebo i poszerza tarczę, aby pogoda wpływała na światło przez dane.
48. Jako człowiek chcę automatyczną ekspozycję z jasności odniesienia Lokacji i Stanu doby, aby noc i dzień były czytelne bez ręcznej ekspozycji na Lokację.
49. Jako człowiek chcę, żeby iglaki na wietrze kołysały się, i chcę porównać na żywo wariant A (cień stały) i B (cień kołysze się z koroną), aby wybrać, co zostaje.

### Stylizacja pixel art

50. Jako człowiek chcę stylizację A′ (poziomy EV, szew ditheru o stałej szerokości w px, kotwica `Y_ref`) na oświetleniu powierzchni, aby światło wyglądało jak pixel art.
51. Jako człowiek chcę dwa tryby stylizacji w Zestawie strojenia, A′ na luminancji sumy z ciągłą barwą oraz A′ osobno na kanale naturalnym i sztucznym, przełączane na żywo w F1, aby wybrać jeden przy strojeniu.
52. Jako człowiek chcę, żeby Smugi nie dostawały pasów poziomów A′, tylko własną stylizację (gładko albo dither, drobinki), aby wyglądały jak powietrze.
53. Jako człowiek chcę, żeby 1 px Bufora światła = 1 px gry, aby światło nigdy nie było drobniejsze niż piksel sprite'a.

### Strojenie (krytycy i człowiek)

54. Jako krytyk chcę zmieniać wygląd wyłącznie przez dane (`.tres`), nigdy przez shadery, aby strojenie nie psuło logiki.
55. Jako krytyk chcę jednego pliku Krzywych doby dla całej gry (droga słońca: wysokość i azymut od godziny, kolory i natężenia słońca, nieba i ambientu, tarcza, zachmurzenie, ekspozycja), aby słońce za oknem zgadzało się z ulicą.
56. Jako krytyk chcę dwóch Zestawów strojenia (wnętrza, plener) ze stałymi (A′: tryb, szew, poziomy; półcień: mnożnik i maksimum w px; Odbiorniki: modelowanie, kontrświatło, wypełnienie; siła Smug i Plam okna; stylizacja Smug i kurzu: gładko/dither, gęstość i ruch drobinek, szew), aby wnętrza mogły mieć mocniejsze Smugi bez osobnej logiki.
57. Jako krytyk chcę profili Źródeł (kolor, natężenie, zanik jako krzywa, godziny świecenia, kanał naturalny/sztuczny) i profili nieba (miasto, wieś), aby stroić rodzaje światła bez dotykania Lokacji.
58. Jako krytyk chcę oddać Wariant strojenia jako katalog z kopiami dowolnych plików strojenia (brakujący plik = bazowy) i opisem w jednym zdaniu, aby człowiek mógł go przełączyć na żywo.
59. Jako człowiek chcę przełączać w F1 Warianty kilku krytyków (np. „bazowy / Malarz A–C / Kontrast A–C”), a gra ma wczytywać nowe Warianty bez restartu, aby porównywać na żywo.
60. Jako człowiek nie chcę suwaków wartości ani zapisu zestawów w F1, aby strojenie szło tylko przez Warianty.
61. Jako Claude chcę przenieść wybrany Wariant do plików domyślnych i zacommitować w tickecie, aby poprzednia wersja została w gicie.
62. Jako krytyk chcę zmieniać pojedynczą wartość z wiersza poleceń po nazwie (`--set=styl.szew_px=2`) i wybierać Wariant (`--wariant=nazwa`), aby robić zrzuty porównawcze wsadowo.
63. Jako człowiek chcę od pierwszego ticketu sensownego wyglądu: domyślne `.tres` mają punkty startowe przeniesione ze starego silnika (Ściąga wyglądu), aby nie oceniać czarnego ekranu.

### F1, zrzuty, widok debug

64. Jako człowiek chcę w F1 tylko minimum: godzina, tempo czasu, Wariant, przycisk „Zrzut”, „Widok debug” i przełączniki bieżącego ticketu, aby panel był prosty.
65. Jako człowiek chcę widok debug silnika (brak / Bryły / Odbiorniki / kafle i warstwy / kanały / odczyt Stanu doby) działający w każdej Lokacji, aby zobaczyć, co silnik widzi.
66. Jako człowiek chcę, żeby przycisk „Zrzut” i F12 zapisywały PNG z opisem stanu (scena, godzina, Wariant, pozycja postaci, przełączniki) i kopiowały ścieżkę do schowka, aby wkleić ją agentowi.
67. Jako agent chcę odtworzyć tę samą klatkę z `--z-zrzutu=plik`, aby zobaczyć dokładnie to, co człowiek.
68. Jako człowiek chcę przełączać w F1 Poligonu trudne sceny (odcinki, pomieszczenia, profil nieba), aby szybko dojść do sceny z ticketu.
69. Jako człowiek chcę, żeby przełączniki bieżącego ticketu znikały po moim „ok”, aby F1 nie puchło.

### Wydajność

70. Jako gracz chcę ponad 60 fps na słabszym sprzęcie niż RTX 4060 Laptop, aby gra była płynna.
71. Jako człowiek chcę, żeby najbardziej zatłoczony kadr miasta (8 postaci, 1 samochód z reflektorami, 4 iglaki na wietrze) mieścił się w ≤ 4 ms GPU i ≤ 1 ms CPU silnika na klatkę na RTX 4060 Laptop, aby mieć zapas na ok. 3× słabszą kartę.
72. Jako człowiek chcę wczytania Lokacji wielkości Poligonu Ulica w ≤ 2 s (niebo i nieruchome Źródła), aby przejścia między Lokacjami nie męczyły.
73. Jako człowiek nie chcę wypiekania światła w edytorze, aby nie przeoczyć nieaktualnego wypieku.

### Wykonanie i testy (agent `/implement`, człowiek)

74. Jako agent `/implement` chcę jednej komendy `node tools/test.mjs`, która uruchamia testy GUT i bramki buforów, aby pętla TDD była prosta.
75. Jako agent chcę testów jednostkowych logiki w GDScript (headless), aby szybko sprawdzać Stan doby, rzut, Odbiorniki, Otwory, walidację, strojenie i przydział do kafli.
76. Jako agent chcę bramek buforów na małych syntetycznych Lokacjach z węzłów kontraktu, aby sprawdzać zasady światła, nie wygląd.
77. Jako człowiek chcę sprawdzać ręcznie każdy zaimplementowany ticket według jego sekcji „Jak sprawdzić”, aby błędy wyglądu wychodziły od razu.
78. Jako człowiek chcę, żeby każdy ticket zmieniał coś widocznego w Poligonie albo w edytorze, aby było co sprawdzać.
79. Jako człowiek chcę porównać na żywo nowy silnik ze starymi Poligonami o tej samej godzinie, aby wiedzieć, czy klimat nie uciekł.
80. Jako człowiek chcę, żeby na końcu stary silnik i stare Poligony zostały usunięte, aby w projekcie była jedna droga.
81. Jako człowiek chcę testu końcowego: subagent z samą dokumentacją kontraktu buduje nową piwnicę lub strych i nową wieś, a ja przesuwam w edytorze jedną Przesłonę i jedną lampę i oceniam w grze o kilku godzinach, aby udowodnić, że silnik nie zna scen.

## Implementation Decisions

### Granice i ogólne zasady

- Addon `style-lab/addons/swiatlo/`, samodzielny: nie odwołuje się do `config/`, `world/`, `debug/`, `poligony/`, `lighting/` ani do nazw scen. Sprawdza to test „bez kodu pod scenę”.
- Jeden kod dla wnętrz i pleneru; bez gałęzi, ifów i flag zależnych od rodzaju Lokacji, rodzaju Źródła, pokoju czy budynku. Rodzaje istnieją tylko w danych.
- Bez C++ (GDExtension). Shadery `canvas_item` w SubViewportach, dane geometrii w teksturach danych. Compute shader (RenderingDevice z GDScriptu) tylko wtedy, gdy bramka wydajności nie zmieści budżetu.
- Każda wartość wizualna w `.tres`. Strojenie nie wymaga zmian w shaderach ani w kodzie. Typowany GDScript (ostrzeżenia `untyped_declaration` itd. jako błędy, jak w projekcie).
- Rzut: głębia 0,60, 40 px/m. Parametry rzutu to zasób addonu (nie `style-lab/config`). Południe zawsze u góry ekranu; Lokacja nie ma pola orientacji.
- Gdy poprawki się piętrzą: stop, powrót do modelu, nie łatka pod miejsce.

### Moduł: Kontrakt sceny (węzły `@tool`)

- Węzły w widoku 2D gry, pola w metrach (x, d, z), pozycja ekranowa liczona z rzutu; każdy węzeł dodaje się do grupy kontraktu w `_enter_tree` i emituje sygnał zmiany.
- **Otoczenie Lokacji** (jedno na Lokację): Zestaw strojenia (wnętrza/plener), profil nieba, gęstość powietrza (kurz, mgła albo nic), jasność odniesienia ekspozycji. Bez własnych pokręteł wyglądu.
- **Ściana**: odcinek na planie, grubość, wysokość. Dzieci: **Otwory** (położenie wzdłuż Ściany, szerokość, dół, góra; kierunek wynika ze Ściany) z opcjonalnym wypełnieniem: listwy pionowe i poziome (rozstaw, grubość), zasłonięcie od góry do wysokości, przepuszczalność. Otwory stałe (bez otwierania w grze).
- **Przesłona**: jedna lub kilka **Brył** (pudełko; pudełko z dachem ze spadem wzdłuż x albo d; walec; uniesione pudełko). Pola: ruchoma (tak/nie), wychylenie od wiatru (m, opcjonalne). Strop i dach to zwykłe Przesłony. Okno dachowe to Otwór w Przesłonie-stropie: jeśli Przesłona nie może mieć Otworów, strop składa się ze Ścian leżących; o kształcie decyduje implementacja, ale jedna reguła Otworu dla wszystkich.
- **Źródło powierzchniowe**: prostokąt albo kula w metrach, profil Źródła, mnożnik natężenia (właściwość animowalna), opcjonalnie ruchome i przyczepione do Przesłony. Reguła ogólna: Źródła nie zasłania Przesłona, do której jest przyczepione.
- Słońce (kierunkowe, z tarczą o rozmiarze kątowym) i niebo (kopuła) nie są węzłami: powstają ze Stanu doby i profilu nieba.
- **Asset** = scena `.tscn`: sprite, Bryły, punkt zaczepienia (środek przedniej dolnej krawędzi), opcjonalna mapa normalnych, opcjonalne przyczepione Źródła. Sprite nie rzuca cienia; piksel sprite'a leży na widocznej ścianie Bryły.
- **Walidacja**: ostrzeżenia konfiguracji węzła w edytorze (Otwór poza Ścianą, Źródło w Bryle, brak lub kilka Otoczeń Lokacji, Bryła o zerowym wymiarze itd.). Kontrakt nie ma stałych limitów liczby węzłów.
- Część addonu: **Dokumentacja kontraktu sceny** (jeden plik), wystarczająca, żeby zbudować Lokację bez czytania kodu silnika (test końcowy).

### Moduł: Opis sceny (kompilacja kontraktu)

- Czysta logika w GDScript: z drzewa węzłów kontraktu powstaje Opis sceny, wejście dla Bufora światła. Testowalny bez GPU.
- Wylicza: **Odbiorniki** (każda powierzchnia Bryły widoczna w rzucie 0,60: podłoga, wierzch, przód, spadek dachu, fasada; bez flagi), **obszar Bufora** (z Brył i podłogi; Lokacja większa niż limit tekstury to osobne Lokacje), geometrię Otworów z wypełnieniem, **kafle** (rzędy 32×32 px) z listą Brył i Źródeł, które mogą na nie wpłynąć, **przydział do warstw zmienności** (nieruchome / ruchome Przesłony i Źródła, wiatr = ścieżka ruchomych), **grupy Źródeł** (ten sam profil i ten sam mnożnik animacji = jedna warstwa).
- Pakuje dane do tekstur danych dla shaderów. Silnik nie zna pokoi, budynków, rodzajów okien ani lamp.
- Przebudowa Opisu sceny przy zmianie węzła (edytor) i przy wczytaniu Lokacji (gra); ruchome Przesłony i Źródła aktualizują tylko swoje dane co klatkę.

### Moduł: Stan doby

- Czysta funkcja: (Krzywe doby, profil nieba, profile Źródeł, godzina) → Stan doby. Liczony raz na klatkę, jeden dla całego Bufora, łącznie z oknami ruchomych Przesłon.
- Zawiera: kierunek słońca (wysokość, azymut z krzywej artystycznej; wschód po lewej, zachód po prawej, południe u góry), kolor i natężenie słońca, nieba i ambientu, rozmiar tarczy, zachmurzenie, ekspozycję, kolor × natężenie każdego profilu Źródła (z godzinami świecenia).
- Zachmurzenie działa przez dane: słońce × (1−c), niebo jaśniejsze i bielsze, szersza tarcza. Bez hacka godzinowego z game1.
- Godzina jest jedynym wejściem czasu; gra (i F1) ustawia godzinę i tempo.

### Moduł: Zasoby strojenia i Warianty

- `Resource` (z `class_name`):
  - **Krzywe doby** (jeden plik na grę): każda wielkość jako krzywa lub gradient od godziny 0–24: wysokość słońca, azymut słońca, kolor słońca, natężenie słońca, kolor nieba, natężenie nieba, ambient (kolor, natężenie), tarcza słońca, zachmurzenie, ekspozycja (krzywa: jasność sceny → mnożnik).
  - **Zestaw strojenia** (`wnetrza.tres`, `plener.tres`, same stałe): A′ (tryb: na sumie / na każdym kanale; szew w px; poziomy EV; `Y_ref`), półcień (mnożnik, maksimum w px ekranu), Odbiorniki (modelowanie, kontrświatło, wypełnienie), siła Smug, siła Plam okna, stylizacja Smug (gładko / dither, szew) i kurzu (próg, gęstość i ruch drobinek).
  - **Profil Źródła**: kanał (naturalny/sztuczny), kolor (gradient doby), natężenie (krzywa doby, w tym godziny świecenia), zanik (krzywa od odległości), rozmiar dla półcienia wynika z wymiarów węzła.
  - **Profil nieba**: kolor i natężenie nieba nocą, łuna/księżyc jako dane (np. miasto, wieś); dzienne niebo z Krzywych doby.
- Domyślne pliki mają punkty startowe ze Ściągi wyglądu (stary silnik, game1); to tylko start, nie cel.
- **Wariant strojenia** = katalog z kopiami dowolnych plików strojenia (brakujący plik = bazowy) i plikiem opisu (jedno zdanie, autor-krytyk). Rejestr Wariantów przegląda katalog Wariantów przy starcie i przy otwarciu F1 / na żądanie; przełączenie podmienia zasoby na żywo bez restartu.
- Nadpisania z wiersza poleceń po nazwie wartości: `--set=<zasób>.<pole>=<wartość>` (np. `styl.szew_px=2`), `--wariant=<nazwa>`. Stare `--set=` z indeksami zostaje tylko dla opcji Poligonów.

### Moduł: Bufor światła (GPU)

- Rozdzielczość ×1 (1 px Bufora = 1 px gry), obejmuje całą Lokację. Dwa kanały światła w HDR: naturalny (słońce, niebo, ambient) i sztuczny (Źródła z kanałem sztucznym); kanał to pole w profilu Źródła.
- Model: `E = ambient + Σ kolor_i(Stan doby) × natężenie_i × widoczność_i`, liniowo, bez trybów mieszania, kolejności i koloru cienia.
- **Jedna funkcja widoczności** dla wszystkich Źródeł i wszystkich Przesłon (Bryły, Ściany z Otworami i wypełnieniem); półcień z geometrii: rozmiar Źródła × (przesłona→odbiornik) / (źródło→przesłona), × mnożnik z Zestawu, przycięty do maksimum w px.
- **Warstwy według zmienności**, co klatkę tylko składanie z mnożnikami ze Stanu doby:
  - **niebo**: widoczność kopuły (tylko geometria) liczona przy wczytaniu narastająco przez kilka klatek, tysiące próbek; kolor i siła nieba to mnożnik;
  - **nieruchome Źródła powierzchniowe**: światło przy natężeniu 1 liczone raz, jedna warstwa na grupę Źródeł; włączanie, gradienty i animacja to mnożniki;
  - **słońce**: widoczność przeliczana kaflami rozłożonymi na klatki dla bieżącej godziny; stary i nowy stan przenikają się płynnie (doganianie ok. ¼ s);
  - **ruchome Przesłony**: co klatkę, tylko w oknie wokół każdej i tylko dla Źródeł w zasięgu; ich cień mnoży gotowe warstwy; zasłonięcie nieba przez ruchomą Przesłonę wzorem analitycznym, bez próbek; cień kontaktowy postaci;
  - **ruchome Źródła**: co klatkę w swoim zasięgu, tą samą funkcją.
  Okna (ruchome) liczone tylko, gdy przecinają kadr.
- **Odbiorniki bryłowe** (postać, meble, każdy sprite na Bryle): piksel sprite'a dostaje pozycję z widocznej ściany Bryły i normalną z mapy normalnych albo ze ściany; światło ze wszystkich Źródeł; parametry modelowania, kontrświatła i wypełnienia z Zestawu. Powierzchnie ruchomej Przesłony liczone co klatkę (bez paska `ACTOR_STRIP`).
- **Wiatr**: wspólny wiatr Lokacji daje wychylenie Przesłon z polem wiatru. Wariant B (cień z koroną) przez ścieżkę ruchomych Przesłon; wariant A (cień stały, kołysze się tylko sprite) jako przełącznik ticketu. Jeśli B okaże się trudne albo drogie, zostaje A.

### Moduł: Rozproszenie w powietrzu (Smugi i kurz)

- Plama okna to zwykłe bezpośrednie słońce przez Otwór (ta sama widoczność co cienie); żadnego osobnego kodu plamy.
- Smuga = całka po słupie powietrza nad punktem (rzut 0,60) z widoczności Źródła × gęstość powietrza Lokacji. Działa dla każdego Źródła (okna, prześwity między budynkami, latarnia we mgle). W ½ rozdzielczości.
- Drobinki kurzu w pełnej rozdzielczości tam, gdzie rozproszenie przekracza próg z Zestawu; ruch drobinek z Zestawu.
- Rozproszenie dodaje się **po** kwantyzacji A′, bez progów poziomów, z własną stylizacją.

### Moduł: Stylizacja i wyświetlanie

- Ekspozycja automatyczna: mnożnik sumy przed A′, z jasności odniesienia Lokacji (`Y_ref`) i Stanu doby przez krzywą ekspozycji.
- A′ kwantyzuje tylko oświetlenie powierzchni (poziomy EV, szew ditheru o stałej szerokości w px). Dwa tryby w Zestawie, oba z tych samych dwóch kanałów: (1) A′ na luminancji sumy, barwa ciągła; (3) A′ osobno na każdym kanale, potem suma. Przełącznik trybu na żywo w F1 do czasu wyboru przy globalnym strojeniu.
- Obraz = albedo sprite'a × stylizowane światło + rozproszenie.

### Moduł: Podgląd w edytorze

- Jeden kontroler (`@tool`) na Lokację zbiera węzły z grupy, buduje Opis sceny, renderuje Bufor w SubViewport w trybie jednorazowym tylko przy fladze zmiany (zero kosztu w spoczynku). Godzina i tryb podglądu jako `@export` kontrolera. Węzły pomocnicze bez `owner`.
- Ten sam kod kontrolera działa w grze (różni się tylko źródłem godziny).

### Moduł: Panel silnika i narzędzia (część addonu)

- Panel silnika: godzina, tempo czasu, przełącznik Wariantów, „Zrzut”, „Widok debug” (brak / Bryły / Odbiorniki / kafle i warstwy / kanały / odczyt Stanu doby: godzina, wysokość i azymut słońca, kolory), przełączniki bieżącego ticketu. Panel nie zależy od `style-lab/debug`; Poligon osadza go w swoim F1 obok swoich opcji (przełącznik trudnych scen).
- Zrzut (przycisk i F12): PNG + opis stanu (scena, godzina, Wariant, pozycja postaci, przełączniki), ścieżka do schowka; `--z-zrzutu=plik` odtwarza klatkę. Benchmark: `--bench=godzina [--ruch]` wypisuje ms GPU, ms CPU silnika i czas wczytania.
- Akcje wejścia z Input Map, bez surowych kodów klawiszy.

### Nowe Poligony (sceny edytora z węzłów kontraktu)

- Nie importują niczego ze starego `lighting/`, `world/`, starych `poligony/`. Pliki graficzne (sprite'y) można użyć ponownie.
- **Poligon Ulica** (plener, miasto, jedna ulica przewijana w poziomie):
  - **Uliczka**: rząd kamienic od południa z prześwitem 2 m (promienie między budynkami, cień kamienic na ulicy), słońce w kamerę nad dachami, wysoki komin lub słup ogłoszeniowy w półcieniu;
  - **Sklep**: witryna i okna świecące nocą, trzy latarnie i lampa nad drzwiami w słońcu (nakładanie cieni wielu Źródeł, przewijanie doby);
  - **Skwer**: 8 chodzących postaci, samochód z reflektorami, 4 iglaki na wietrze (kadr wydajności, wiatr A/B).
- **Poligon Dom** (wnętrze, jedno piętro, bez schodów):
  - **salon**: duże okna w tylnej, południowej ścianie (Smugi, Plamy, kurz w stronę kamery), okno w niewidocznej przedniej ścianie (samo niebo), lampa stojąca przy słonecznym oknie, stół, regał, kanapa z cieniem;
  - **kuchnia**: za ścianą działową z drzwiami, chowaną przy wejściu postaci; okno boczne od wschodu; żaluzje w drugim oknie;
  - **pracownia**: okno dachowe, goła żarówka, postać z papierosem, noc z przełącznikiem profilu nieba miasto/wieś.
- Bez przejścia ulica → dom, bez pięter i schodów. F1 Poligonu: przełącznik trudnych scen (odcinek / pomieszczenie, godzina startowa).

### Migracja i usunięcie starego silnika

- Stare Poligony nietknięte do końca wykonania (porównanie „jak było” o tej samej godzinie).
- Osobny ticket „Usunięcie starego silnika” po „ok” człowieka dla obu nowych Poligonów, przed testem końcowym: usuwa `lighting/`, zależne klasy `world/`, `rzut_*`, `demo_*`, stare Poligony i ich `.bat`, stare bramki (`bufor_roznica.mjs`, `bufor_ulica_*`, `cien_nieba_*`); `main/` przechodzi na nowe Poligony. Ogólne narzędzia pomiaru (`png.mjs`, `jasnosc.mjs`, `kadr.mjs`, `roznica.mjs`, `obok.mjs`, `postac.mjs`) zostają.

## Testing Decisions

- **Dobry test** sprawdza zachowanie z zewnątrz (wejście: węzły kontraktu, godzina, zasoby; wyjście: Stan doby, Opis sceny, piksele Bufora), nie szczegóły implementacji (nazwy uniformów, układ tekstur danych). Wygląd ocenia tylko człowiek.
- **Szwy testów (od najwyższego):**
  1. **Lokacja → Bufor światła** (GPU): syntetyczna Lokacja z węzłów kontraktu + godzina + Zestaw → odczyt pikseli Bufora (osobno kanały i wynik po stylizacji). Jedyny szew bramek buforów.
  2. **Węzły kontraktu → Opis sceny** (headless): Odbiorniki, obszar, Otwory z wypełnieniem, kafle, warstwy, grupy Źródeł, ostrzeżenia walidacji.
  3. **Krzywe doby + godzina → Stan doby** (headless).
  4. **Zasoby i Warianty** (headless): wczytanie, nakładanie Wariantu na bazę, `--set=` po nazwie.
- **Narzędzia:** GUT 9.7.1 w `style-lab/addons/gut/` (poza katalogiem silnika; zgoda człowieka jest). Jedna komenda `node tools/test.mjs` uruchamia GUT (testy logiki headless, testy GPU w oknie poza ekranem `--resolution 64x64 --position -3000,-3000`, bo `--headless` nie renderuje) i bramki; `-gselect=` do szybkiej pętli TDD. Ścieżka Godota: `C:/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64.exe` (konsolowy `..._console.exe`).
- **Testy jednostkowe:** Stan doby z godziny (krzywe drogi słońca, kolory, zachmurzenie, godziny świecenia), rzut metry → ekran, Odbiorniki i obszar z Brył, geometria Otworów z wypełnieniem, ostrzeżenia walidacji, wczytywanie zasobów i Wariantów, `--set=`, przydział do warstw i kafli; test „bez kodu pod scenę” (katalog addonu nie odwołuje się do `style-lab` ani do nazw scen).
- **Bramki buforów (zasady, nie wygląd):** cień po przeciwnej stronie niż Źródło; dwa Źródła razem = suma osobno (w HDR); przyczepione Źródło niezasłaniane przez swoją Przesłonę; pokój bez Otworów ciemny (poza ambientem); brak skoków między kolejnymi minutami doby; niebo we wnętrzu bez prążków; półcień szerszy dalej od przesłony; Plama okna w kształcie Otworu i w kierunku od słońca. Regresja w ustalonych punktach z tolerancją (powtarzalność między uruchomieniami niesprawdzona); wzorzec odświeżany tylko po akceptacji wyglądu przez człowieka.
- **Bramka wydajności:** benchmark kadru Skweru (8 postaci, samochód, 4 iglaki na wietrze): ≤ 4 ms GPU i ≤ 1 ms CPU silnika na klatkę na RTX 4060 Laptop; wczytanie Lokacji wielkości Poligonu Ulica ≤ 2 s.
- **Prior art:** narzędzia `style-lab/tools/pomiar/*.mjs` (odczyt PNG, porównanie w punktach), `--bench=` i `--shots=` starych Poligonów. Stare bramki nie przechodzą; nowe od zera.
- **Człowiek na żywo:** każdy ticket wykonawczy kończy się sekcją „Jak sprawdzić” (komenda/scena, godzina, co przestawić w F1, co ma być widać). Po `/implement` status „do sprawdzenia”; zamknięcie po „ok” człowieka; poprawka w tym samym tickecie jako kolejny commit.
- **Test końcowy** (ostatni ticket, po usunięciu starego silnika): świeży subagent widzi tylko Dokumentację kontraktu sceny, nie kod silnika, i buduje: wnętrze (piwnica lub strych z oknem dachowym, gołą żarówką i wąskim okienkiem pod sufitem) i plener (wieś nocą i o świcie, drzewa, stodoła, jedna latarnia, świecące okno). Każda zmiana w katalogu silnika = wynik negatywny i powrót do modelu. Człowiek przesuwa w edytorze jedną Przesłonę i jedną lampę (cienie idą za nimi od razu) i ocenia w grze o kilku godzinach.
- **Kryterium „gotowe”** (ostatni ticket): testy i bramki zielone; trudne sceny ocenione na żywo; brak kodu i przełączników pod scenę; każda wartość wizualna w `.tres`, Warianty w F1; > 60 fps na sprzęcie człowieka; test końcowy pozytywny.

## Out of Scope

- Strojenie wartości i kolorów światła (ticket 38 mapy grafiki, Warianty krytyków na działającym silniku), w tym Krzywe doby i noc oraz stylizacja Smug i kurzu: spec zapewnia tylko, że da się je stroić bez kodu.
- Produkcja assetów i Przepisy (mapa grafiki); spec ustala tylko kontrakt assetu.
- Płynne przejście ulica → wnętrze bez wczytania; drzwi ulica → dom, piętra i schody w nowych Poligonach.
- Brzeg kadru w czerni (prototyp w mapie grafiki na działającym silniku).
- Odczyt poziomu światła przez logikę gry (brak API).
- Pogoda zmienna między dniami.
- Otwieranie Otworów w grze; migotanie cienia liści (przepuszczalność z teksturą).
- Wypiekanie światła w edytorze; GDExtension (C++).

## Further Notes

- **Proponowana kolejność plastrów dla `/to-tickets`** (każdy widoczny w Poligonie albo edytorze; najpierw Ulica, potem Dom):
  1. Szkielet: addon, GUT, `node tools/test.mjs`, pusty Poligon Ulica z Otoczeniem Lokacji; Stan doby z Krzywych doby z punktami startowymi; panel silnika z godziną i odczytem Stanu doby.
  2. Uliczka: Przesłony z Brył, słońce, cień na ziemi i Odbiorniki fasad; podgląd w edytorze.
  3. Niebo jako kopuła (warstwa przy wczytaniu, narastająco), ambient; widok debug kanałów.
  4. Półcień z geometrii; wysoki komin w półcieniu; słońce w kamerę.
  5. Stylizacja A′ (dwa tryby) i ekspozycja automatyczna.
  6. Sklep: Źródła powierzchniowe z profilami i godzinami świecenia, grupy Źródeł, dwa kanały, nakładanie cieni wielu Źródeł.
  7. Kafle i przenikanie słońca przy przewijaniu doby.
  8. Ruchome Przesłony: postać (cień od wszystkich Źródeł, kontaktowy, Odbiornik bryłowy, mapa normalnych).
  9. Ruchome i przyczepione Źródła (samochód z reflektorami), mnożnik z animacji.
  10. Skwer: wiatr A/B, kadr wydajności i bramka wydajności.
  11. Warianty strojenia, `--set=` po nazwie, zrzut z opisem stanu i `--z-zrzutu`.
  12. Poligon Dom, salon: Ściany z Otworami, strop, okno przedniej ściany, Plamy okna, meble.
  13. Smugi i kurz (rozproszenie w powietrzu); promienie między budynkami i latarnia we mgle na Ulicy.
  14. Kuchnia: wypełnienie Otworów (żaluzje), okno boczne, ściana działowa chowana przy wejściu.
  15. Pracownia: okno dachowe, goła żarówka, papieros, profil nieba miasto/wieś.
  16. Dokumentacja kontraktu sceny i ostrzeżenia walidacji.
  17. Usunięcie starego silnika.
  18. Test końcowy.
  `/to-tickets` może tę listę scalać i dzielić; podany porządek nie jest wymaganiem.
- **Tickety wykonawcze (2026-11-15, zaakceptowane przez człowieka):** `docs/silnik/tickets/01–27`. Zmiana wobec listy wyżej: najpierw sprawdzian kontraktu assetu (Prowadnice v2 → Sprawdzian assetu w prototypie → Poprawka kontraktu assetu), bo sprite z ComfyUI ma dziś wypalone światło, a silnik zakłada albedo × światło; w silniku Oświetlenie sprite'ów na Bryłach i Mebel z ComfyUI na Ulicy zaraz po niebie. Wynik prototypu może zmienić kontrakt assetu w tej specyfikacji.
- **Decyzje odłożone do wykonania (techniczne, rozstrzyga Claude):** dokładny kształt stropu z oknem dachowym w kontrakcie; format tekstur danych (RGBAH: odczyt niesprawdzony); liczba próbek nieba i liczba klatek narastania w budżecie 2 s; czy podłoga na różnych wysokościach zostaje (zrezygnować, jeśli droga); przeciąganie myszą w edytorze i podsceny z węzłami `@tool` (niesprawdzone w research 90).
- **Ściąga wyglądu** (`sciaga-wygladu.md`) idzie do krytyków przy strojeniu; punkty startowe z niej trafiają do domyślnych `.tres` w pierwszych ticketach.
- Research: 85 (Shadowglass), 86 (nakładanie), 87 (Kotwice), 88 (C++ czy shadery), 89 (testy), 90 (podgląd w edytorze), 84 (stylizacja A′).
- Commity tylko z `/implement`; każdy ticket na osobnej gałęzi (pamięć: git-and-hard-look-check).
