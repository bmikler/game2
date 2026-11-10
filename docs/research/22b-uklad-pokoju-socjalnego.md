> Kopia z game1 (`repo/game1/docs/research/22b-uklad-pokoju-socjalnego.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Układ pokoju socjalnego posterunku: wymiary, okna, ogrzewanie, słońce

Ticket: `docs/wayfinder/tickets/22-pipeline-assetow.md` (pokój socjalny w docelowej grafice, `room.tscn`). Data researchu i dostępu do wszystkich źródeł: **2026-10-28**. Wejście: koncept `art/concept/locations/posterunek/socjal-9002e-9202.png`, uwagi człowieka do prototypu (trzy równe okna na ścianie 12 m są nierealistyczne; bez jarzeniówek w południe jest za ciemno; pokój może być mały; posterunek będzie ciągłą mapą bez ekranów ładowania; za oknem jest małe miasto ze szpitalem i barem, nie wioska z dwoma domami).

Źródła pierwotne: przepisy (Arbeidsplassforskriften na Lovdata, TEK17/TEK10 na dibk.no), statystyka SSB, równania pozycji Słońca NOAA (obliczenia własne w Node) i **prawdziwe zdjęcia** biurowców z lat 1987–1989 z ogłoszeń Finn.no (oglądane klatka po klatce). Zdjęć wnętrz lensmannskontor z lat 70–90 nie znalazłem: DigitaltMuseum blokuje pobieranie (403), jego API nie odpowiada, a Commons ma tylko eksponaty z Justismuseet. Najbliższy odpowiednik to zwykłe biurowce administracyjne z tej epoki, a posterunek w małym mieście zwykle zajmował właśnie taki budynek albo jego piętro. Gdzie wymiar odczytałem ze zdjęcia, piszę „szacunek ze zdjęcia”.

## Streszczenie i rekomendacja

- **Pokój: 7,0 × 4,4 m (280 × 176 px), ok. 31 m², ściana tylna 2,6 m (104 px).** To realny rozmiar: w biurowcu z 1987 r. w Alcie (15 gabinetów, czyli skala małego posterunku) „spiserom” ma 35 m². Przepis wymaga tylko miejsca dla wszystkich jedzących naraz (orientacyjnie 1,2 m² na osobę). Mniejsza wersja **5,4 × 4,2 m** jest opisana w §6; wypada z niej kanapa przy ścianie tylnej.
- **Okna: jedno podwójne okno, a nie rząd równych okien.** Na zdjęciach z epoki okna to osobne, „wycięte” otwory ok. 1,0–1,2 m szerokości i 1,2–1,4 m wysokości, z parapetem ok. 0,85–0,95 m. Powtarzają się co moduł fasady (gabinet ok. 2,4 m szerokości ma 1 lub 2 okna). Trzy równe okna istnieją naprawdę (sala w Alcie), ale tylko w szerokim pokoju na fasadzie. Pokój 7 m dostaje **jedno okno dwuskrzydłowe 2,4 × 1,4 m, parapet 0,85 m, nadproże 2,25 m**, z żaluzjami (persienner), bo przepis wymaga regulowanej osłony przed olśnieniem.
- **Ogrzewanie: elektryczne grzejniki panelowe (panelovner) pod oknem**, białe, ok. 1,0 × 0,40 m, ok. 0,15 m nad podłogą. Widać je na zdjęciach z obu budynków, a ogłoszenia podają „elektrisk oppvarming med panelovner”. Według SSB tylko nieco ponad 40% budynków usługowych ma centralne ogrzewanie. Kaloryfer wodny z konceptu jest możliwy, ale mniej typowy.
- **Aneks** (benkeskap 60 cm głębokości, blat 90 cm, szafki wiszące ok. 55 cm nad blatem) na **pełnym odcinku ściany, nie pod oknem**. W prawdziwych budynkach kuchnia stoi przy ścianie wewnętrznej albo w osobnej wnęce. W grze widać tylko ścianę tylną, więc stawiamy aneks na jej pełnym odcinku z prawej, obok okna.
- **Kierunek: ściana tylna (fasada z oknem) zwrócona na południe.** W końcu lutego na 63°N Słońce wschodzi na azymucie ok. 110° (7:42), zachodzi na ok. 251° (17:24) i w południe wznosi się tylko na 17–18°. Okno na południe ma niskie smugi przez cały dzień (ok. 8:30–16:30), a ich kierunek przesuwa się jak wskazówka zegara: rano padają w prawo (na aneks), w południe prosto na stół, po 15:00 w lewo (na kanapę). To daje najwięcej światła i odpowiada na uwagę „za ciemno w dzień”. **Wschód** daje słońce tylko ok. 7:45–11:15, **zachód** tylko ok. 14:00–17:15, a **północ** nigdy. Liczby są w §4.
- **Za oknem nie może stać nic wysokiego blisko.** Przy Słońcu na 10–17° budynek wysoki na 9 m zasłania je, jeśli stoi bliżej niż ok. 30–50 m. Świerki z konceptu tuż za szybą zabrałyby całe słońce. Za oknem dajemy parking posterunku albo plac (ok. 40 m), a dalej niską zabudowę miasteczka i zalesione wzgórze.
- **Połączenie z resztą posterunku:** korytarz środkowy (midtkorridor) ok. 1,8–2,0 m biegnie **równolegle do fasady, poziomo pod pokojem (w miejscu usuniętej ściany przedniej)**. Drzwi są w ścianie przedniej przy prawym narożniku. Po drugiej stronie korytarza leżą pomieszczenia bez okien w kadrze: szatnia, WC, archiwum, kopiarka. Po bokach są gabinety o szerokości ok. 2,4 m. Pokój socjalny leży po stronie personelu, z dala od okienka dla interesantów i aresztu.
- **Światło dzienne (uwaga człowieka):** w lutowe południe nawet pochmurne niebo daje kilka tysięcy luksów na zewnątrz, a śnieg odbija światło w okno. Przy oknie wnętrze ma więcej światła niż z jarzeniówek (500 lx), dalej w głąb mniej, ale nadal czytelnie. Rekomendacja dla gry: **bez lamp w południe pokój ma mieć co najmniej 70–80% jasności pokoju z lampami, pas 2 m przy oknie jaśniejszy niż z lampami, a plama słońca najjaśniejsza w kadrze.** Jarzeniówki w dzień dodają tylko 15–25%. Przy okazji: prototyp ma wschód 8:30 i zachód 16:15, a koniec lutego na 63°N to ok. 7:40 i 17:25 (połowa lutego: 8:15 i 16:55).

## 1. Wielkość i proporcje pokoju

**Przepisy (źródło pierwotne).** Arbeidsplassforskriften:
- § 3-5: „Spiserom skal være så stort at det gir tilfredsstillende plass til det største antall arbeidstakere som skal spise samtidig.” oraz „skal være hensiktsmessig innredet, og om nødvendig slik at arbeidstakerne kan tilberede måltider der.”
- § 2-10: „Spiserom skal om mulig ha dagslys og utsyn.”
- § 2-12: okna mają mieć „hensiktsmessig regulerbar blendingsanordning”, czyli regulowaną osłonę przed olśnieniem (żaluzje).
- § 2-8: wysokość pomieszczeń personelu ma odpowiadać powierzchni pomieszczenia. Nie ma tu sztywnej liczby.

[Lovdata, kap. 3](https://lovdata.no/dokument/SF/forskrift/2011-12-06-1356/KAPITTEL_3). Liczby „min. 6 m² i 1,2 m² na pracownika” podaje serwis Arbeidstilsynet na ung.no, ale nie wiąże ich z konkretnym paragrafem ([ung.no](https://www.ung.no/oss/7z9pJRa4mgfrqrWUyu4r7D)). Traktuję je jako orientacyjne. Uwaga: obecne przepisy są z 2011 r. Akcja gry dzieje się w 2010 r., kiedy obowiązywały starsze przepisy o podobnej treści (nie sprawdzałem ich tekstu).

**Realne przykłady (ogłoszenia Finn.no, zdjęcia oglądane):**
- **Alta sentrum, budynek z 1987 r.** 2. piętro: 15 gabinetów, recepcja, kuchnia, „møterom (12 kvm), større møterom/spiserom (35 kvm)”, szatnia, „pauserom/minglesone”, archiwum, 2 kopiarki. Ogrzewanie: „Elektrisk oppvarming med panelovner”; sufity „nedforede systemhimlinger med mineralullsplater”. [Finn 460642739](https://www.finn.no/realestate/businessrent/ad.html?finnkode=460642739). Sala 35 m² ([zdjęcie](https://images.finncdn.no/dynamic/1280w/2026/4/vertical-7/20/9/460/642/739_2d97d8dd-6949-40bd-a307-d4f8aaf2d99e.jpg)): podłużny pokój na fasadzie, na krótszej ścianie trzy osobne okna ok. 1,0 × 1,2 m z grzejnikami pod spodem, drzwi z przeszkleniem w ścianie bocznej przy narożniku od strony korytarza. Kuchnia to **osobna wnęka bez okna** z wysoką lodówką, zlewem, ekspresem przelewowym i zmywarką ([zdjęcie](https://images.finncdn.no/dynamic/1280w/2026/4/vertical-7/20/9/460/642/739_c0a8543e-ffcb-4235-a012-d75b10390874.jpg)).
- **Skien/Myren, budynek z 1989 r.** Wolne 2. piętro „har de fleste overflater fra byggeår”: „spiserom med kjøkken, 7 kontor…”. Ogrzewanie „panelovner og varm[e]…”. [Finn 436626193](https://www.finn.no/realestate/businesssale/ad.html?finnkode=436626193). Kantyna ([zdjęcie](https://images.finncdn.no/dynamic/1280w/2025/11/vertical-7/11/3/436/626/193_3e59a245-2b2d-4e83-adef-ee8e72ab859c.jpg)): stoły przy rzędzie okien, prosty aneks z białymi frontami **wzdłuż ściany wewnętrznej**, kącik z kanapą w głębi. Mniejszy pokój socjalny ([zdjęcie](https://images.finncdn.no/dynamic/1280w/2025/11/vertical-7/11/3/436/626/193_6b91d907-72ce-4932-a231-a3e657913e3d.jpg)): stół na 4–6 osób, kanapa wzdłuż ściany, aneks na końcu pokoju.
- **Aukra, dawny lensmannskontor (budynek z 1982 r., zniszczony wodą):** lista pomieszczeń „resepsjon, flere kontorer, toaletter, dusj, to tidligere arrestrom, gangarealer, spiserom”. Daje to skład małego posterunku; zdjęcia są po zalaniu i do układu się nie nadają. [Finn 432235798](https://www.finn.no/realestate/businesssale/ad.html?finnkode=432235798)

**Wniosek:** dla posterunku z ok. 10–15 osobami pokój socjalny 20–35 m² jest realny. Ok. 31 m² (7,0 × 4,4 m) to górna, „wygodna” wersja, a 5,4 × 4,2 m (23 m²) to wersja oszczędna. Proporcja ok. 3:2 do 5:3, dłuższy bok wzdłuż fasady, bo pokoje układa się wzdłuż korytarza (to wniosek z rzutów i zdjęć, nie z przepisu).

## 2. Okna i ogrzewanie

**Okna (zdjęcia z epoki):**
- Gabinet w Skien z oryginalnym wykończeniem z 1988–89 ([zdjęcie](https://images.finncdn.no/dynamic/1280w/2025/11/vertical-7/11/3/436/626/193_e9f66088-3ce2-48aa-a534-5a6f8dd681c4.jpg)): pokój ok. 2,4 m szerokości ma **dwa osobne okna ok. 0,8–0,9 × 1,1 m** z wąskim filarkiem ok. 0,25 m, parapet ok. 0,95 m (ponad biurkiem 0,72 m), zasłony. Pod oknem jest grzejnik w obudowie, w suficie siatka 600 × 600 i dwie wpuszczane oprawy świetlówkowe 2-rurowe (szacunek ze zdjęcia).
- Inny gabinet w Skien ([zdjęcie](https://images.finncdn.no/dynamic/1280w/2025/11/vertical-7/11/3/436/626/193_dcbb827b-2371-4aa8-a584-f751b6c4d7c2.jpg)) i gabinet w Alcie ([zdjęcie](https://images.finncdn.no/dynamic/1280w/2026/4/vertical-7/20/9/460/642/739_ccadea23-05fa-4460-91b9-1122f5f641bd.jpg)): okna ok. 1,0–1,2 × 1,2–1,4 m, parapet ok. 0,85–0,95 m, szeroki parapet wewnętrzny, **biały grzejnik panelowy ok. 0,9–1,0 × 0,4 m pod każdym oknem, ok. 0,15 m nad podłogą**, żaluzje.
- Na zdjęciach z zewnątrz oba budynki mają fasady z rzędem osobnych okien, a nie ciągłe pasy okienne (Skien: 2-kondygnacyjny budynek z drewnianą elewacją; Alta: murowany, 2–3 kondygnacje).
- Przepis o bezpieczeństwie: szkło niżej niż 0,8 m nad podłogą trzeba zabezpieczyć ([TEK17 § 12-17](https://www.dibk.no/regelverk/byggteknisk-forskrift-tek17/12/iii/12-17)). Stąd typowy parapet ≥ 0,8 m.
- Ilość światła: TEK10 dopuszczał udokumentowanie dziennego światła regułą „powierzchnia przeszklenia ≥ 10% powierzchni użytkowej”, a TEK17 zastąpił ją współczynnikiem światła dziennego ≥ 2% ([TEK17 § 13-7](https://www.dibk.no/regelverk/byggteknisk-forskrift-tek17/13/v/13-7), [SINTEF 2016 o regule 10%](https://www.dibk.no/globalassets/byggeregler/tek10-til-tek17/rapporter/krav-til-dagslys-i-tek10_sintef_januar-2016.pdf)). Dla 31 m² daje to ok. 3 m² szkła. Nasze okno 2,4 × 1,4 m ma ok. 2,5 m² szkła (ok. 8%), co jest realne dla budynku sprzed TEK10.

**Ogrzewanie:**
- Oba budynki z lat 1987–89 i budynek z 1970 r. w Lakselv („Oppvarming i bygget er varmepumpe og panelovner”, ściany z „panelplater/huntonitt plater”, [Finn 433525917](https://www.finn.no/realestate/businesssale/ad.html?finnkode=433525917)) grzeją elektrycznymi grzejnikami panelowymi.
- SSB (2008): „Drøyt 40 prosent av byggene hadde sentralvarmeanlegg”, czyli większość budynków usługowych nie ma ogrzewania wodnego. [SSB](https://www.ssb.no/energi-og-industri/artikler-og-publikasjoner/energibruk-i-bygninger-for-tjenesteytende-virksomhet-2008)
- Teza, że po kryzysie naftowym w 1973 r. ogrzewanie elektryczne „przejęło cały rynek” aż do połowy lat 90., pochodzi z uwag Norsk Varmeteknisk Forening do DiBK. Znam ją tylko ze streszczenia wyszukiwarki, bo PDF nie dał się odczytać ([PDF](https://dibk.no/globalassets/aktuelle-horinger3/160215_nye-energikrav-til-bygg/svar/norsk-varmeteknisk-forening.pdf)).
- **Miejsce: zawsze pod oknem**, gdzie grzejnik odcina zimne powietrze spływające z szyby. Na każdym zdjęciu grzejnik stoi pod oknem, a nie na pełnej ścianie. Dla gry: grzejnik panelowy (płaski, biały, z kratką u góry) pod każdym skrzydłem albo jeden długi pod całym oknem. Kaloryfer żeberkowy z konceptu też jest dopuszczalny, ale bez rur do kotła wygląda mniej „norwesko”.

## 3. Aneks, meble, tablice, oświetlenie

- **Aneks:** szafki dolne 60 cm głębokości, moduły szerokości 60 cm, blat ok. 90 cm; szafki wiszące ok. 30–35 cm głębokości, dolna krawędź ok. 50–55 cm nad blatem, wysokość ok. 70 cm. Między nimi kafelki. To wymiary z forów i ogłoszeń, nie z normy (byggebolig.no, Finn), ale zgadzają się ze zdjęciami. Wyposażenie widoczne w Alcie i Skien: zlewozmywak, ekspres przelewowy, czajnik, mikrofalówka, zmywarka pod blatem, lodówka. W małym pokoju często stoi mała lodówka pod blatem albo obok, a na niej mikrofalówka (jak w koncepcie).
- **Gdzie stoi aneks:** na zdjęciach przy ścianie wewnętrznej albo w osobnej wnęce, nigdy pod oknem. Stół stoi **przy oknie** (tam jest światło). Kanapa albo fotele są w drugim końcu pokoju, wzdłuż pełnej ściany, ze stolikiem kawowym.
- **Ściany:** tablica korkowa, kalendarze, zegar ścienny, wyłącznik światła i gaśnica przy drzwiach (gaśnica przy wejściu jest widoczna w kantynie w Skien). Tablice wiszą na pełnych odcinkach ściany, nad kanapą albo przy drzwiach.
- **Sufit:** podwieszany, płyty 600 × 600 z wełny mineralnej („systemhimling”). Oprawy świetlówkowe wpuszczane 2-rurowe (1200 × 300 albo 600 × 600) w rzędach, mniej więcej jedna na 6–8 m² (szacunek: gabinet 2,4 × 4 m w Skien ma dwie). Pokój ok. 31 m² dostaje **4 oprawy w układzie 2 × 2**. Dla porównania norma NS-EN 12464-1 zakłada ok. 500 lx w biurze (tego nie sprawdzałem w tekście normy).

## 4. Słońce: końcówka lutego na ok. 63°N

Obliczenia własne według [równań NOAA](https://gml.noaa.gov/grad/solcalc/solareqns.PDF) (Node), długość geograficzna 10,4°E, czas CET, wschód i zachód z refrakcją −0,833°. Uwaga: [kalkulator NOAA](https://gml.noaa.gov/grad/solcalc/) nie jest już utrzymywany, ale same równania są standardowe. Nie porównałem wyników z timeanddate.com (strona zwróciła 403).

| Data, szer. | Wschód (azymut) | Zachód (azymut) | Południe słoneczne | Wysokość w południe |
|---|---|---|---|---|
| 15 lutego, 63,4°N | 8:15 (118°) | 16:53 (242°) | 12:33 | 13,6° |
| 25 lutego, 63,4°N | 7:42 (110°) | 17:24 (251°) | 12:32 | 17,2° |
| 25 lutego, 62,5°N | 7:39 (109°) | 17:27 (251°) | 12:32 | 18,1° |

**Kiedy okno dostaje bezpośrednie słońce (25 lutego, 63°N; liczone, gdy kąt między Słońcem a normalną okna < 75°):**

| Ściana tylna (okno) patrzy na | Słońce przez okno | Charakter |
|---|---|---|
| **południe (180°)** | ok. 8:30–16:30 | smugi cały dzień; rano padają w prawo, w południe prosto, po południu w lewo |
| wschód (90°) | ok. 7:45–11:15 | tylko rano, potem światło rozproszone; zachód widać tylko jako różowawe niebo naprzeciw |
| zachód (270°) | ok. 14:00–17:15 | tylko po południu; zachód słońca widać w oknie (16:30–17:30) |
| SE (135°) / SW (225°) | ok. 8:00–14:00 / 11:00–17:00 | kompromisy |
| północ (0°) | nigdy | — |

**Gdzie pada plama słońca (fasada na południe, parapet 0,85 m, nadproże 2,25 m).** `y` to odległość od ściany tylnej w głąb pokoju, `x` to przesunięcie w ekranie (+ w prawo) względem okna. Patrzymy na południe, więc z lewej jest wschód, a z prawej zachód.

| Godz. | Wysokość | Azymut | Krawędź plamy od parapetu (y, x) | Krawędź od nadproża (y, x) |
|---|---|---|---|---|
| 9:00 | 7° | 127° | 4,4 m; +5,7 m | poza pokojem |
| 10:00 | 12° | 142° | 3,3 m; +2,6 m | 8,5 m; +6,7 m |
| 11:00 | 15,5° | 156° | 3,0 m; +1,3 m | 7,6 m; +3,3 m |
| 12:30 | 17,6° | 180° | 2,8 m; 0 | 7,2 m; 0 |
| 14:00 | 15,7° | 203° | 3,0 m; −1,2 m | 7,6 m; −3,1 m |
| 15:00 | 12,3° | 217° | 3,3 m; −2,5 m | 8,4 m; −6,4 m |
| 16:00 | 7,5° | 232° | 4,2 m; −5,3 m | poza pokojem |

Wnioski do gry:
- Przy tak niskim Słońcu plama na podłodze **zaczyna się dopiero ok. 3 m od okna** i biegnie do przedniej krawędzi pokoju (głębokość 4,4 m). Bliżej okna światło trafia na **meble**: blat stołu (0,75 m) jest w słońcu w całości od ok. 0,3 m od ściany, podobnie oparcia krzeseł. Rano i wieczorem (Słońce poniżej ok. 10°) światło przechodzi przez cały pokój i trafia w nierysowaną ścianę przednią. W kadrze widać wtedy jasne pasy na meblach i ewentualnie przy dolnej krawędzi kadru.
- Ściana na południe daje „zegar słoneczny”: plama przesuwa się z prawej (aneks, ok. 10:00) przez stół (12:30) na lewo (kanapa, ok. 15:00).
- **Przeszkody:** Słońce zasłania wszystko, co jest wyżej niż kąt jego wysokości. Na 10–17° obiekt o wysokości H zasłania je, jeśli stoi bliżej niż ok. 3,3–5,7 × H. Budynek na 9 m musi stać dalej niż ok. 30–50 m, a świerki na 15 m dalej niż ok. 50–85 m. Za oknem dajemy parking posterunku albo plac i ulicę, dalej niską zabudowę miasteczka (szpital, bar, sklepy, 2–3 kondygnacje), a w tle wzgórze ze świerkami. Pojedyncze świerki mogą stać z boku kadru okna.

**Ile jest światła (szacunek własny, nie ze źródła):** w lutowe południe na 63°N przy bezchmurnym niebie poziome natężenie na zewnątrz to rzędu 20–30 tys. lx, a na pionowej fasadzie od południa nawet ok. 50–60 tys. lx (niskie Słońce świeci prawie prostopadle w okno, do tego odbicie od śniegu). Przy zachmurzeniu jest to rzędu kilku tysięcy lx. Przy współczynniku światła dziennego 2–5% we wnętrzu daje to przy zachmurzeniu ok. 100–400 lx w głębi i więcej przy oknie, a przy słońcu znacznie więcej. Jarzeniówki dają ok. 500 lx. **Pokój bez lamp w południe jest więc jasny, a obecny prototyp jest za ciemny.** Zgodnie z realiami Norwegii w lutym światła w biurach i tak zwykle palą się cały dzień, więc jarzeniówki można zostawić włączone, ale w dzień mają być dodatkiem.

Rekomendacja dla `room.gd` (wartości startowe do strojenia):
- Południe, pogodnie: ambient bez lamp ok. 0,80–0,90 jasności docelowej, lekko chłodny. Plama słońca addytywnie, aż do przepalenia. Odbicie od śniegu jako słabe, chłodne światło na sufit i ścianę tylną wokół okna.
- Południe, pochmurno: ambient ok. 0,70–0,80, bez plamy. Gradient: przy oknie jaśniej niż z lampami, przy przedniej krawędzi ok. 60%.
- Jarzeniówki w dzień: +0,15–0,25. Po zmroku stają się głównym źródłem.
- Godziny: wschód ok. 7:40, zachód ok. 17:25 (25 lutego). Niebieska godzina przed 7:40 i po 17:25 trwa długo, bo Słońce wznosi się płasko.

## 5. Połączenie z korytarzem i sąsiednimi pomieszczeniami

- **Typowy układ (zdjęcia z Alty i Skien, lista pomieszczeń z Aukry):** korytarz środkowy z pomieszczeniami po obu stronach. Od strony fasady leżą gabinety (moduł ok. 2,4 m), sala, pokój socjalny. Od strony wewnętrznej, bez okien: WC, szatnia, archiwum, kopiarka, pomieszczenie gospodarcze, w Alcie także kuchnia. W małym posterunku dochodzi strefa publiczna (recepcja/okienko przy wejściu) i areszt („to tidligere arrestrom” w Aukrze). Pokój socjalny leży po stronie personelu, z dala od wejścia publicznego.
- **Drzwi:** w ścianie od korytarza albo w ścianie bocznej **tuż przy narożniku od strony korytarza** (sala w Alcie). Nigdy nie stoją na środku ściany ani w ścianie z oknem. Skrzydło ok. 0,9 m, otwiera się do pokoju i przylega do najbliższej ściany. Obok drzwi jest wyłącznik i często gaśnica.
- **Dla mapy gry (wniosek):** przy kamerze 3/4 z widoczną tylko ścianą tylną najlepiej sprawdza się **poziomy korytarz poniżej pokoju**, na miejscu usuniętej ściany przedniej. Pokoje nad korytarzem pokazują fasadę z oknami (to pokój socjalny i gabinety), a pokoje pod korytarzem pokazują ścianę od korytarza (WC, szatnia, archiwum, areszt), czyli nie potrzebują okien w kadrze. Drzwi pokoju socjalnego są w ścianie przedniej przy prawym narożniku, rysowane jako przerwa w cienkiej krawędzi ściany i futryna. Jeśli trzeba trzymać się konceptu (drzwi w prawej ścianie), to drzwi w prawej ścianie bocznej przy przednim narożniku prowadzą do korytarza biegnącego pionowo po prawej. To też jest realne, ale gorzej się łączy z resztą posterunku.
- Ponieważ kamera jest jedna dla całego posterunku, **wszystkie widoczne fasady patrzą w tę samą stronę świata**. Wybór „ściana tylna na południe” oznacza, że góra mapy posterunku to południe.

## 6. Specyfikacja układu (7,0 × 4,4 m, ściana tylna 2,6 m, 1 m = 40 px)

Ściana tylna = fasada na południe. `x` w metrach od lewego wewnętrznego narożnika, `h` to wysokość nad podłogą.

**Elewacja ściany tylnej (od lewej do prawej):**

| Element | x [m] | h [m] | Uwagi |
|---|---|---|---|
| kanapa (oparta o ścianę, frontem do kamery) | 0,15–2,15 | 0–0,80 | głębokość 0,85; narzuta |
| tablica korkowa | 0,40–1,40 | 1,15–1,85 | ogłoszenia, grafik dyżurów |
| kalendarz 1 | 1,60–1,95 | 1,35–1,85 | |
| okno dwuskrzydłowe | **2,40–4,80** | **0,85–2,25** | 2 × 1,2 m, słupek na x 3,60; żaluzje; szeroki parapet |
| grzejnik panelowy A | 2,50–3,50 | 0,15–0,55 | pod lewym skrzydłem |
| grzejnik panelowy B | 3,70–4,70 | 0,15–0,55 | pod prawym skrzydłem |
| filarek | 4,80–5,10 | — | gniazdko przy blacie |
| szafki dolne + blat | 5,10–6,30 | 0–0,90 | 2 moduły; ekspres przelewowy x 5,20–5,50, zlew x 5,70–6,20 |
| kafelki nad blatem | 5,10–6,30 | 0,90–1,45 | |
| szafki wiszące | 5,10–6,30 | 1,45–2,15 | |
| lodówka mała, na niej mikrofalówka | 6,30–6,90 | 0–0,85 / 0,85–1,15 | magnesy, kartki |
| kalendarz 2 i zegar | 6,35–6,85 | 1,40–1,90 / zegar 1,95–2,25 | nad mikrofalówką |
| (ściana przednia) drzwi | **6,00–6,90** w ścianie przedniej (y = 4,4) | 0–2,10 | do korytarza poniżej; obok wyłącznik i gaśnica na prawej ścianie bocznej |

**Podłoga (`y` od ściany tylnej):**

| Mebel | x [m] | y [m] | Uwagi |
|---|---|---|---|
| kanapa | 0,15–2,15 | 0,00–0,85 | |
| stolik kawowy | 0,65–1,65 | 1,25–1,75 | |
| stół jadalny 0,8 × 1,4, prostopadle do okna | 3,20–4,00 | 0,60–2,00 | 0,6 m od grzejników |
| krzesła | 2 po lewej (x ≈ 2,75), 2 po prawej (x ≈ 4,45) | y ≈ 0,9 i 1,6 | piąte opcjonalnie u szczytu (y ≈ 2,4) |
| strefa przed aneksem | 5,10–6,90 | 0,60–1,80 | wolna; kosz na śmieci przy x 5,0 |
| przejście drzwi → aneks/stół | 4,8–6,9 | 1,8–4,4 | wolne |
| jarzeniówki (4 oprawy, sufit nierysowany) | 1,75 i 5,25 | 1,10 i 3,30 | plamy światła na podłodze |

```
PLAN  (1 znak = 0,2 m, 1 wiersz = 0,4 m; === okno, luka u dołu = drzwi)
       x: 0    1    2    3    4    5    6    7 m
     y    +------------============-----------+
  0,0 m  | SSSSSSSSSS gggggg ggggg AAAAAALLLL|
  0,4 m  | SSSSSSSSSS     TTTT     AAAAAALLLL|
  0,8 m  |             k  TTTT  k            |
  1,2 m  |   ccccc        TTTT               |
  1,6 m  |             k  TTTT  k            |
  2,0 m  |                                   |
  2,4 m  |                  k                |
  2,8 m  |  15:00 <-      12:30    -> 10:00  |
  3,2 m  |   plama slonca (y 2,8-4,4)        |
  3,6 m  |                                   |
  4,0 m  |                                   |
  4,4 m  +------------------------------     +
         KORYTARZ (1,8-2,0 m) -> reszta posterunku
S kanapa, c stolik kawowy, T stół, k krzesło, g grzejnik pod oknem, A aneks (blat, zlew, ekspres), L lodówka + mikrofalówka

ELEWACJA ŚCIANY TYLNEJ (1 znak = 0,2 m, 1 wiersz = 0,2 m)
       x: 0    1    2    3    4    5    6    7 m
  2,6 m  |                                   |
  2,4 m  |                                   |
  2,2 m  |            OOOOOO|OOOOO WWWWWW  Z |
  2,0 m  |            OOOOOO|OOOOO WWWWWW    |
  1,8 m  |  BBBBB KK  OOOOOO|OOOOO WWWWWW KK |
  1,6 m  |  BBBBB KK  OOOOOO|OOOOO WWWWWW KK |
  1,4 m  |  BBBBB     OOOOOO|OOOOO ......    |
  1,2 m  |            OOOOOO|OOOOO ......MMMM|
  1,0 m  |            OOOOOO|OOOOO ......MMMM|
  0,8 m  | SSSSSSSSSS              AAAAAALLLL|
  0,6 m  | SSSSSSSSSS  ggggg ggggg AAAAAALLLL|
  0,4 m  | SSSSSSSSSS  ggggg ggggg AAAAAALLLL|
  0,2 m  | SSSSSSSSSS              AAAAAALLLL|
         +-----------------------------------+
S kanapa, B tablica korkowa, K kalendarz, O okno (| słupek), g grzejnik panelowy, A szafki dolne z blatem, . kafelki, W szafki wiszące, L lodówka, M mikrofalówka, Z zegar
```

**Wersja mała (5,4 × 4,2 m):** okno 1,2–3,6 (2 × 1,2 m), grzejniki pod nim; aneks z lodówką na x 3,8–5,4 (lodówka na prawym końcu); stół prostopadle do okna x 2,0–2,8; kanapa przy lewej ścianie bocznej (y 1,6–3,6), co wymaga sprite'a kanapy z boku; tablica korkowa na filarku x 0,1–1,1. Drzwi bez zmian: w ścianie przedniej przy prawym narożniku.

## 7. Czego nie zweryfikowano

- **Zdjęć prawdziwego pokoju socjalnego lensmannskontor z lat 70–90 nie znalazłem.** Wnioski opierają się na dwóch biurowcach z lat 1987–89 (Alta, Skien) z ogłoszeń Finn.no z 2025–2026 r. Część wyposażenia jest współczesna (meble, oprawy LED w niektórych pokojach); okna, grzejniki, sufity i podział pokoi oceniałem jako oryginalne. DigitaltMuseum (403, API demo przekierowuje) i Finna/Stockholmskällan nie dały wyników.
- Wymiary okien, parapetów, grzejników i opraw są **szacunkami ze zdjęć**, nie z rysunków. Byggforsk 533.102 (projektowanie okien) jest płatny i go nie czytałem.
- Liczby 6 m² i 1,2 m² na osobę są tylko z ung.no. Tekstu przepisów obowiązujących w 2010 r. (przed Arbeidsplassforskriften z 2011 r.) nie sprawdzałem.
- Teza o dominacji ogrzewania elektrycznego od 1973 do połowy lat 90. jest znana tylko ze streszczenia (PDF NVF nieczytelny). Pewne są dane SSB (ok. 40% z centralnym ogrzewaniem w 2008 r.) i opisy z ogłoszeń.
- Pozycja Słońca jest liczona równaniami NOAA, bez porównania z niezależnym kalkulatorem. Błąd to rzędu minut i dziesiątych części stopnia. Natężenia światła (lx) to rzędy wielkości z prostego modelu, nie pomiar.
- Wymiary kuchni (90 cm blat, ok. 55 cm do szafek wiszących) pochodzą z forów i ogłoszeń, nie z normy.
- Układ korytarza i stref (personel/publiczna/areszt) jest wnioskiem z list pomieszczeń i zdjęć zwykłych biurowców, a nie z planu prawdziwego posterunku. Statsbygg i politiet nie publikują rzutów małych posterunków.
