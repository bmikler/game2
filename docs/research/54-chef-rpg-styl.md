# Chef RPG jako wzorzec stylu: rzut, meble, okna, paleta, narzędzia

Stan: 2026-11-03. Uzupełnienie do `43b-chef-rpg-wnetrza.md` (ściany, wnęki, głębokość pokoi, czego tu nie powtarzam). Dotyczy `docs/grafika.md` i `51`, `51b`, `53`.

Oznaczenia: **[zrzut]** widziałem na obrazie, **[pomiar]** policzyłem skryptem na pliku PNG, **[źródło]** tekst twórców (Steam, BackerKit/Kickstarter), **[wtórne]** prasa, **[niezweryfikowane]**, **[wniosek]** moja interpretacja.

## TL;DR

1. **Rzut to nie 45° 1:1, tylko "oblique": podłoga bez skrótu, fronty w pełnej wysokości.** Kafel podłogi to kwadrat 24×24 px natywnych także na ekranie (pionowy rozstaw linii 24 px, poziomy 24 px) [pomiar]. Wierzch obiektu to więc jego rzut z góry w skali 1:1, a front dokłada się dołem. Proporcja wierzch:front nie jest stała, wynika z rzeczywistych wymiarów obiektu [wniosek]. To inny model niż "kamera 45°" z `grafika.md`.
2. **Skala:** natywnie 640×360, skalowane całkowicie ×3 (zrzuty sklepu 1920×1080) albo ×4 (obrazy z ogłoszeń 2560×1440) [pomiar: najkrótsze serie identycznych pikseli to 3 lub 4 px]. Kafel 24 px, postać ok. 48 px (2 kafle), drzwi zewnętrzne ok. 52 px [pomiar/zrzut]. Ekran to ok. 7,5 wysokości postaci, prototyp game1 miał 540/75 = 7,2, więc skala jest porównywalna.
3. **Proporcje są chibi, ściany bardzo wysokie.** Lico ściany tylnej we wnętrzu ma ok. 117 px natywnych, czyli ok. 2,4 wysokości postaci (zrzut `2_5b25…`) [pomiar]. Dla nas to za "kukiełkowe".
4. **Okna wnętrz są wyłącznie w licu ściany tylnej.** Na ścianach bocznych i dolnej nie widziałem ani jednego okna, tam jest ciemny pas i czerń [zrzut]. To potwierdza regułę z `grafika.md` i `53`. Fasady zewnętrzne mają okna tylko na ścianie zwróconej do kamery, a dachy widać z góry.
5. **Meble stoją osiowo.** Nie znalazłem żadnego mebla obróconego o 30-45°. Ukośne są tylko schody, fazy ścian i zakrzywione blaty (zaokrąglone rogi), nie meble [zrzut].
6. **Wygląd bierze się z:** (a) kontur selektywny, ciemny i kolorowy na postaciach i rekwizytach, bez czarnego obrysu na terenie i drzewach, (b) zmiany barwy w cieniu (zimny fiolet i morski w śniegu, ciepły oranż w oknach), (c) dużo drobnej, ręcznie układanej faktury (deski, cegły, igły), (d) światło i winieta jako osobna warstwa na ograniczonej palecie [wniosek].
7. **Narzędzia:** źródła nie podają programu ani silnika. Wiadomo, że to mały zespół z architektem na czele, który pokazuje timelapse'y pixel artu, i że artyści dochodzili stopniowo (patrz §6) [źródło/wtórne].

## 1. Rzut i skala

### 1.1 Skala pikseli [pomiar]

Skrypt liczył serie identycznych pikseli w poziomie na PNG bez kompresji stratnej:
- `4_e767…` (1920×1080): serie 3, 6, 9, 12 px, czyli natywnie 640×360 skalowane ×3. Unikalnych kolorów w całym kadrze: **304**.
- `8_fcb8…` i `2_a05f…` (2560×1440 i 2055 px szerokości): serie 4, 8, 12 px, czyli ×4, też natywnie 640×360.
- Zrzuty sklepu są JPEG-ami, więc dokładnego liczenia na nich nie robiłem, ale rozmiar 1920×1080 i wygląd pikseli zgadzają się z ×3 [wniosek].

Kadry z oświetleniem nocnym (`2_c4fe…`, 298 tys. kolorów) i z winietą (`8_daf7…`, 364 tys.) mają wielokrotnie więcej kolorów niż kadr bez efektów. Z tego wynika, że światło i winieta to nakładka na ograniczoną paletę, a nie wymalowane piksele [wniosek]. Tezę potwierdza komunikat twórców, że meble sterują światłem pokoju ("overhead lights", v0.62, cytowane w 43b) [źródło].

### 1.2 Kafel i postać [pomiar/zrzut]

- Kafel podłogi: **24 px** w poziomie i **24 px** w pionie (w pokoju z tatami `2_a05f…`: linie kafli co 24 px w obu osiach, próbka kolumny: linie przy y = 143 i 167). Podłoga jest więc rysowana jak plan z góry, bez skrótu.
- Postać: **ok. 48 px** (głowa z włosami ok. 20 px, czyli ok. 40%). Postać stoi na ok. 2 kaflach.
- Drzwi budynku (`ss1`, Le Sequoia): ok. 52 px, ledwo wyższe od postaci. Okna fasady ok. 28-32 px.
- Lico ściany tylnej we wnętrzu: ok. 117 px natywnych z listwą wierzchu, z czego okno ma 30-40 px [pomiar z `2_5b25…`].
- "px na metr" źródła nie podają. Jeśli postać to ok. 1,7 m, to 1 m ≈ 28 px, kafel ≈ 0,85 m [wniosek, bez potwierdzenia].

### 1.3 Proporcja wierzch:front

Nie ma stałej proporcji, więc nie da się podać jednej liczby [wniosek]. Przykłady z pomiaru na dużych, prostych bryłach:
- Długi stół z obrusem w scenie urodzin (`6_20ff…`): wierzch ok. 48 px głębokości, front z obrusem ok. 17 px wysokości. Stół wygląda na ok. 2 kafle głębokości, więc 1:1 w planie [zrzut/pomiar przybliżony].
- Stół z tablicą w domu gracza (`6_c78f…`): wierzch ok. 67 px, front z półką i nogami poniżej kadru [zrzut].
- Lada kuchenna na zrzucie `ss4` ma wierzch ok. 23 px szerokości i front ok. 15 px.

Interpretacja: wierzch to prawdziwy plan obiektu w skali podłogi, a front to elewacja w skali 1:1 dołączona dołem. Przy takim modelu "sześcian 1×1×1 m" dałby wierzch 24 px i front ok. 24-28 px, czyli wyglądałby jak kamera ok. 45°, ale płaszczyzny nie są obracane i dlatego nie ma romboidalnych ścian ani schodkowych krawędzi [wniosek]. Nie potrafię z samych zrzutów odróżnić tego od kamery ok. 55-60° ze skalowanym frontem. Pewny jest tylko pomiar kafla.

### 1.4 Czy widać boki obiektów?

- **Nie widać boków** pudełkowatych mebli: lada, szafy, lodówki i regały są rysowane z wierzchem i frontem, bez ściany bocznej [zrzut `ss2`, `ss4`, `6_c78f…`].
- Wyjątek stanowią rzeczy "okrągłe" i organiczne (zbiorniki, kotły, drzewa, balie), które z natury nie mają boków.
- Boki widać u **postaci** i **krzeseł**: siedzący goście są rysowani z boku, a oparcia krzeseł to wąskie pasy z boku [zrzut `ss4`, `ss2`].

## 2. Meble: orientacja, miejsce, okluzja, gęstość

### 2.1 Orientacja [zrzut]

- **Tylna ściana:** lodówka, szafa, regał, piec, kominek, kuchenka i okno są widziane wyłącznie od frontu [`ss4`, `6_c78f…`, `ss2`].
- **Stoły:** widziane z góry z frontem (nogi i półka) na dole. Stół "w rzędzie" ma tę samą orientację, z lekką zmianą koloru obrusa (`ss2`, boksy).
- **Krzesła:** trzy widoki. Po bokach stołu to profil (siedzenie widać z boku, oparcie jako pas pionowy), od strony kamery to widok na plecy gościa i na tył oparcia, od strony tylnej ściany to front oparcia [`ss4`, `6_20ff…`]. Zgadza się to z "trzema orientacjami" z `51b`.
- **Kanapy i boksy:** w `ss2` boksy mają siedziska z boku jako zakrzywione pasy, ze stołem w środku. Kanapy nie występują w żadnym oglądanym kadrze.
- **Diagonale:** żadnych mebli pod kątem. Diagonale występują w schodach rysowanych na licu ściany, w fazach rogu ściany (43b) i w wygiętych blatach [zrzut `6_c78f…`].

### 2.2 Co stoi przy bocznych i dolnej ścianie

Boczne i dolne ściany prawie nie istnieją wizualnie (ciemny pas i czerń), więc przy nich nie widać wielkich elementów. W `ss4` przy lewej ścianie stoi rząd niskich urządzeń (blendery, kuchenka), ustawionych tak jak przy tylnej ścianie, czyli frontem w dół ekranu. W scenie urodzin (`6_20ff…`) przy dolnej krawędzi leży długi stół widziany od góry, a po bokach pokoju donice i biurka. Brak wysokich szaf przy dolnej krawędzi [zrzut]. To zgadza się z regułą "przy dolnej ścianie tylko niskie".

### 2.3 Okluzja postaci

Wysokie obiekty zasłaniają postać w terenie: korony drzew, latarnie, ściany budynków (`ss1`, `ss9`). We wnętrzach nie widziałem postaci zasłoniętej przez mebel, bo mebel wysoki stoi tylko przy tylnej ścianie, a hedges/żywopłot w restauracji jest niski (`ss2`). Mechanizmu przezroczystości nie widziałem [niezweryfikowane]. Twórcy mają w patchach poprawki "tall walls & black ceilings" i "furniture rendering behind walls" (cytaty w 43b) [źródło].

### 2.4 Gęstość i grupowanie

- Meble tworzą **małe zestawy**: biurko + krzesło + monitor + papiery, stół + 4 krzesła + dania, blat + garnki + butelki [zrzut `6_20ff…`, `ss4`, `6_c78f…`].
- Między zestawami zostają szerokie ścieżki podłogi o jednolitej fakturze (deski), po których chodzą postacie. Gęstość jest wysoka na wierzchach blatów (rekwizyty), a niska na podłodze [wniosek].
- Dywany i podłoga o innym materiale wyznaczają strefy (urodziny: pas dywanu pod stołami, 43b).

## 3. Okna i drzwi

### 3.1 Wnętrza [zrzut]

- **Okna są tylko w licu ściany tylnej** (`ss4`: cztery okna łukowe z zielonym szkłem, `2_5b25…`: okna z przesuwanymi shoji, `6_8ebb…`: duże okno-iluminator z widokiem na las). Okno ma ramę, parapet, szkło z odblaskiem i często **namalowany widok na zewnątrz** (drzewa, trawa) lub otwarte skrzydła.
- **Ściany boczne i dolna:** ciemny pas wierzchu i czerń. Nie widziałem okna ani drzwi na żadnej z nich. Wyjście dolne nie występuje w oglądanych kadrach [zrzut].
- **Drzwi we wnętrzach:** małe drzwi w licu tylnej ściany do kolejnego pomieszczenia (43b). Drzwi zewnętrznych budynku we wnętrzu nie widziałem, więc nie wiem, jak gra pokazuje wyjście [niezweryfikowane].

### 3.2 Fasady zewnętrzne

- Okna i drzwi tylko na ścianie zwróconej do kamery (południowej), dach widziany z góry, nad drzwiami szyld i daszek [`ss1`, `ss7`, `ss8`, `6_8ebb…`].
- Okno ma ościeżnicę, parapet w innym kolorze, kratkę szprosów i widoczne odbicie ukośnych smug na szkle [zrzut].
- **Noc/zmierzch:** okna świecą ciepłym żółtym z kilkoma ciemnymi szybami (nieoświetlonymi) w siatce, np. pawilon w śniegu `ss8` (3 rzędy po 5 szyb, lewa kolumna ciemna) i drzwi ze świecącymi szybkami w mieście (`4_e767…`) [zrzut]. Wyraźnej poświaty na śniegu pod oknem tam nie zobaczyłem, tylko kontrast ciepłego żółci z lawendowo-szarym śniegiem. Poświata na ziemi jest za to widoczna pod latarniami i lampionami w nocy (`2_c4fe…`) [zrzut].

## 4. Co składa się na wygląd

Obserwacje na zrzutach i powiększeniach (`crop_*` w scratchpadzie, patrz źródła).

- **Paleta i nasycenie:** kolorowe sceny (las, rynek, restauracja) są mocno nasycone, nawet "cukierkowe" (`ss5`, `ss3`, `ss9`). Scena zimowa (`ss1`, `ss8`) jest wyraźnie spokojniejsza: śnieg to pastelowy lawendowo-morski, cienie fioletowe i morskie, a ciepłe akcenty (okna, drewno) są nieliczne. W sumie ok. 300 kolorów w pojedynczej scenie bez nakładek [pomiar jednego kadru, `4_e767…`]. Zmiany barwy: cień idzie w fiolet i zieleń morską, światło w oranż i żółć [zrzut].
- **Kontury:** postacie mają ciemny obrys w kolorze dopasowanym do materiału (włosy prawie czarne, ubrania ciemnoszare), przerywany w światłach. Teren, śnieg i drzewa nie mają czarnego obrysu, tylko ciemniejszą zieleń wewnątrz korony i ciemnobrązową krawędź klifu. Rekwizyty (kosze, stoły) mają ciemnobrązowy obrys. [zrzut, powiększenia]
- **Światło:** niejednoznaczne. W większości obiektów jaśniejszy wierzch i górna lewa strona, ale nie jest to ścisła konwencja. Drzewa mają jaśniejsze czapy śniegu na górze gałęzi, a cień w dolnych partiach. Podłoga w pokojach dostaje winietę przy krawędziach [zrzut `ss4`, `2_5b25…`].
- **Dithering:** są pojedyncze checkery na krawędziach glow i gradientów (cienie pod latarniami, mgła przy wodzie), ale nie jest to styl całej gry. Większość cieniowania to płaskie plamy o 3-4 odcieniach [zrzut powiększeń].
- **Faktura:** bardzo drobna i ręczna: pojedyncze deski podłogi różnią się kolorem, cegły mają osobne spoiny, igły drzew są układane w warstwy. Gęstość detalu jest równomierna w całym kadrze [zrzut].
- **AA:** brak antyaliasingu w sprite'ach. Krawędzie są schodkowe, ale z przemyślanymi pikselami w "pełnych" liniach [zrzut powiększeń].
- **Postacie vs meble:** postacie są chibi (głowa ok. 40%), ale mają ten sam kontur i podobną fakturę co rekwizyty, dlatego nie odstają. Meble i postacie mają podobny rozmiar detalu [wniosek].
- **Cienie pod obiektami:** postacie mają miękki, okrągły cień pod stopami (ciemniejszy kolor podłoża). Drzewa mają ciemną plamę u podstawy. Meble z nogami mają ciemniejszą podłogę pod spodem [zrzut].
- **Pogoda i pora:** śnieg, deszcz i drobne efekty pogodowe to osobna warstwa cząsteczek (`ss1`, `ss8`: płatki, `ss3`: krople). Nocne sceny mają niebieski filtr i punktowe źródła światła (`2_c4fe…`) [zrzut].

## 5. Co przenosi się na game2

### Przenosi się

- **Okna tylko w licu tylnej ściany** z ramą, parapetem i namalowanym widokiem. Boki i dół to światło i rekwizyty (zgodne z `53`).
- **Brak bocznych ścianek mebli.** Meble to wierzch + front, boki tylko u krzeseł. Upraszcza generowanie.
- **Osiowość mebli.** Zero ukosów, ukos tylko w schodach i fazach.
- **Zimowa scena jako wzór palety:** pastelowy śnieg z zimnymi cieniami i nieliczne ciepłe okna. Dla noir wystarczy obniżyć nasycenie i jasność.
- **Okna fasady z kilkoma ciemnymi szybami** (życie w budynku) i ciepły kontrast z zimnym śniegiem.
- **Konwencja konturu:** selektywny ciemny kontur na postaciach i rekwizytach, teren bez czarnego obrysu.
- **Światło i winieta jako warstwa** na ograniczonej palecie.
- **Zestawy rekwizytów** zamiast pojedynczych mebli, wolna podłoga na ścieżki.

### Nie przenosi się

- **Chibi (głowa 40%) i bardzo wysokie ściany** (2,4 postaci). Mają dobry efekt przy bajkowym tonie, nie przy noir. Z realistycznymi proporcjami (głowa ok. 1/7) potrzebujemy wyższego px na postać, a to zmienia całą skalę.
- **Nasycenie** lasów i rynku. Tu to jest "cozy cute", nie noir.
- **Cukierkowe rekwizyty** (różowe obrusy, serca). Za jaskrawe.
- **Podłoga bez skrótu** jest dobrym pomysłem dla pixel art, ale zmienia stałą rzutu: w `grafika.md` założono 45° 1:1 jako skrócenie wierzchu o sin 45° (czyli ok. 0,7). Przy modelu oblique wierzch nie jest skracany i pasuje do kafla kwadratowego.

### Konkretne propozycje do `grafika.md` [wniosek]

1. W sekcji "Rzut" dodać drugi wariant obok 45° 1:1: **oblique, kafel podłogi kwadratowy na ekranie, front w pełnej wysokości**. Przetestować na kostce 1×1×1 m w narzędziach, czy da się go utrzymać z generatora (prowadnica to plan z dołączonym frontem).
2. Stała skali: **natywnie niska rozdzielczość + skalowanie całkowite** (Chef RPG: 640×360, ×3/×4). Dla naszej bardziej szczegółowej postaci rozważyć np. 960×540 ×2 i 60-75 px na postać, czyli bliżej prototypu.
3. Reguła kafla: kafel to 1 m lub 0,85 m, postać 2 kafle (chibi) albo ok. 2 kafle (realistyczna). Ściana tylna to wielokrotność kafla, a drzwi mają ok. 2,2 kafla.
4. Reguła konturu: **selektywny, ciemny i kolorowy na postaciach i rekwizytach, bez konturu na terenie i śniegu**. Zastępuje "jedną paletę i jeden kontur" tam, gdzie zdecydujemy inaczej dla terenu.
5. Reguła światła: baza neutralna w sprite'ach, **nakładka światła i winiety w silniku**. Ta część zgadza się z obecnym `grafika.md`.
6. Reguła okien: zostaje. Dodać "okno tylnej ściany ma namalowany widok (u nas zaśnieżony las, ciemne okno nocą)".
7. Reguła fasad: okna tylko na ścianie południowej, dach z góry, część szyb ciemna, ciepłe światło kontra zimny śnieg. To uzupełnia otwartą decyzję 5 w `grafika.md` (brak wzorca fasad).

## 6. Narzędzia i zespół (tylko źródła)

- **Lider:** Noah Cai ("Pixel Architect"), były projektant architektoniczny, prowadzi kanał YouTube z samouczkami architektury, timelapse'ami pixel artu i devlogami [źródło: komunikat prasowy Game Developer; wtórne: cogconnected].
- **Zespół:** trzy osoby w czasie rozmowy z cogconnected (data artykułu niepodana w odpowiedzi) [wtórne]. Po Kickstarterze (grudzień 2021, ok. 124 tys. USD) dołączyli kolejni [wtórne].
- **Nikita:** projekty postaci i dania ("draws the beautiful food art") oraz dialogi [źródło: BackerKit, aktualizacja z 2021].
- **Clement:** "nasz najnowszy artysta", przerobił sprite'y i animacje postaci w maju 2022. Roślinność, drzewa i trawa narysowane od nowa, **dodano shadery animacji** "dla wyższej jakości i słodszego wyglądu" [źródło: BackerKit, 06.05.2022].
- **Plan zatrudnienia animatora** do postaci i zwierząt, bo zespół miał w tym mniej doświadczenia [źródło: BackerKit].
- **Inspiracje architektoniczne:** Archigram, neony i billboardy, japońskie automaty z napojami, Fenghuang Old Town, Studio Ghibli (Spirited Away) [źródło: BackerKit, 10.12.2021]. Świat łączy architekturę azjatycką i zachodnią z elementami cyberpunku [źródło: Game Developer].
- **Czas:** produkcja od lipca 2020, ponad cztery lata do wczesnego dostępu [źródło: Steam, ogłoszenie z 12.09.2024].
- **Nie znalazłem:** programu do rysowania (Aseprite lub inny), silnika, rozmiaru kafla w dokumentacji, tego, czy sprite'y powstały ręcznie w całości. Z timelapse'ów lidera można wnioskować, że część jest rysowana ręcznie, ale nie oglądałem ich [niezweryfikowane]. Kickstarter zwrócił 403, a wiele aktualizacji BackerKit jest tylko dla backerów.

## Źródła

Zrzuty sklepu Steam (appid 1796790), numeracja z API `appdetails`, kolejność jak w odpowiedzi. Pliki lokalne w `C:\Users\bartl\AppData\Local\Temp\claude\2a738d438b1da09e\80c80e41-ce9d-4004-9bfd-fc98640b2755\scratchpad\chefrpg\`.

| Plik | Co pokazuje | URL |
|---|---|---|
| `ss1.jpg` | Le Sequoia w śniegu, dialog | https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_d0c5d57ea0d1f5e867d40790fe2589f462e8925d.1920x1080.jpg |
| `ss2.jpg` | restauracja w serwisie | https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_0e8f5c414197a2631fc57af714d9d1758120eefb.1920x1080.jpg |
| `ss3.jpg` | rynek w deszczu | https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_6849dd366059065a76e0e0feacc2ac42401ba59d.1920x1080.jpg |
| `ss4.jpg` | zaniedbane wnętrze restauracji | https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_82871847df216baa534b10b5777cb4606a731d57.1920x1080.jpg |
| `ss5.jpg` | las, polowanie | https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_b9175580e27f63693af78c04edcb8693a96290ce.1920x1080.jpg |
| `ss6.jpg` | menu (UI) | https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_356665489a6dc417ef2d815c834c4d1db599fe95.1920x1080.jpg |
| `ss7.jpg` | Le Sequoia latem | https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_a7919db771c21a757c2f32b22b5686eba0afcee0.1920x1080.jpg |
| `ss8.jpg` | łaźnia w śniegu, świecące okna | https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_0f0d961567c3eec213daefa246168a79b78bb7c1.1920x1080.jpg |
| `ss9.jpg` | jesienny las | https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_691edcdd73121d2130aa8daf14839eece95756e0.1920x1080.jpg |

Obrazy z ogłoszeń Steam (`ISteamNews/GetNewsForApp`, adres bazowy `https://clan.akamai.steamstatic.com/images/41514609/`), pliki w podkatalogu `news\`:
- `news\2_5b2503a8388d630423378fd24fc9de7cc8079d8a.png` i `news\2_a05f4741ce2a16d1fffd43e2be3d607faceb3a3c.png` (Tidehaven, 21.08.2026): wnętrza z oknami w licu, pomiar kafla.
- `news\6_8ebb1f83f585aabdfbcc7f0c59746d6558977c3c.jpg` i `news\6_c78f1b9934bc4a54513f7d6e105e78603a428d77.jpg` (Flavors, 28.02.2026): fasada z drzwiami i oknami, dom gracza.
- `news\6_20ffe136e6bea1e2076fe9a8e06dbcd6428ba27b.jpg` (Flavors): scena urodzin, stoły i krzesła.
- `news\4_e76753a7ae2619921ad67b0d5a513d1385d5c685.png` (mapa drogowa, 10.04.2026): miasto, pomiar ×3 i palety, postać z kontururem.
- `news\2_c4fec28a6a5790a9a365d164bdd5c50ebc23da78.png` (Tidehaven): noc z lampionami.
- Wycinki powiększone: `crop_char_city.png`, `crop_lit_windows.png`, `crop_trees_snow.png`, `crop_table_ss4.png`, `crop_home_table.png`, `crop_tatami_floor.png`.

Skrypty pomiarowe: `...\scratchpad\tools\scale.js`, `dump.js`, `crop.js`.

Teksty:
- Steam, API sklepu: https://store.steampowered.com/api/appdetails?appids=1796790
- Steam, ogłoszenia: https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=1796790
- BackerKit, aktualizacje projektu (strony 3-6): https://chef-rpg.backerkit.com/hosted_preorders/project_updates
- Game Developer, komunikat prasowy o Kickstarterze: https://gamedeveloper.com/press-release/chef-rpg-an-open-world-pixel-art-game-project-started-by-an-architectural-designer-is-live-on-kickstarter
- Cogconnected, wywiad: https://cogconnected.com/?p=297169
- Retroware, relacja z Kickstartera: https://articles.retroware.com/2021/12/13/chef-rpg-kickstarter-is-cooking-with-fire
- Denfaminicogamer (japoński): https://news.denfaminicogamer.jp/news/240606h
- Kickstarter: https://www.kickstarter.com/projects/chefrpg/chef-rpg (HTTP 403, nie przeczytane)

## Czego nie zrobiłem

- Nie oglądałem trailera ani wideo dev-logów, więc nie wiem, jak wygląda przejście przez wyjście z wnętrza ani jak chowa się mebel zasłaniający postać.
- Nie mam oficjalnych wymiarów kafla ani px/m, tylko pomiary na obrazach. Proporcja wierzch:front mierzona na kilku obiektach jest przybliżona (obrazy były w jpg lub skalowane), a wniosek o modelu "oblique" opiera się głównie na kwadratowym kaflu podłogi.
- Na zrzutach nie ma kanap, szaf przy dolnej ścianie ani drzwi zewnętrznych we wnętrzu, więc o tych elementach nie wypowiadam się.
- Liczby kolorów (304 itd.) pochodzą z jednego kadru i nie są paletą całej gry.
