# Ściąga wyglądu

Spis klimatu i ustaleń starych Poligonów (sprzed nowego Silnika światła), z którego krytycy mogą czerpać podpowiedzi przy strojeniu. **To nie są wymagania:** reguły silnika pochodzą wyłącznie z mapy silnika (`docs/wayfinder-silnik/map.md`), a część starych ustaleń łatała problemy starego silnika (SunMap, StreetMap). Wartości w sekcji 4 to tylko punkt startowy dla Wariantów strojenia, dowolnie zmieniany; nic tu nie jest „zatwierdzone”. Źródła: `style-lab/README.md`, tickety mapy grafiki (`docs/wayfinder/tickets/`, skrót „t14” itd.), `docs/swiatlo-kolory-game1.md`, research 84.

## 1. Klimat

Co człowiek akceptował lub chwalił na żywo (nastrój, nie parametry):

- **Zima, chłodna baza, ciepło tylko przy źródłach.** Kolory z game1 „bardzo odpowiadają” człowiekowi; punkt wyjścia dla game2. Referencje: Disco Elysium (paleta zimy), Kentucky Route Zero (małe ciepłe źródło w wielkiej ciemności), NORCO (kolor), REPLACED (smugi i ciepłe punkty z bloomem). (t14, t38, `swiatlo-kolory-game1.md`)
- **Noc nigdy nie jest czarna, ale ciemna:** chłodny granat, śnieg i poświata miasta, lampy jako ciepłe wyspy. (`room_lighting_profile.gd`, t31)
- **Smugi z okien górnych to ulubiony element** człowieka: zwężają się od szyby do Plamy okna, podzielone na skrzydła ramy (rama robi klimat okna). Mają być poprawiane pod kątem klimatu i koloru, zwłaszcza w złotej godzinie. (t27, t31, t38)
- **Złota godzina:** wschód i zachód mają trwać dłużej i mieć więcej koloru, ma być ją czuć. (t38, życzenie 2026-11-11)
- **Plama okna ostra, z ramą i skrzydłami** (jak game1-proto); nocą „rzut okna” w kolorze tego, co na zewnątrz. (t27, t31)
- **Okna większe w każdej ścianie:** „mniej realistyczne, lepszy klimat”. (t31, ocena 1)
- **Kurz w smudze:** drobinki świecą tylko w promieniu słońca; ocena „OK” po zmniejszeniu ilości. (t31, oceny 6-8)
- **Drzwi na ulicę:** miękka, krótka, płynnie gasnąca poświata o chłodnym świetle z zewnątrz. (t31, oceny 7-8; README)
- **Płynne przejścia między pokojami:** podłoga w przejściu zlewa się z podłogą sąsiada, światło płynie z pokoju do pokoju. (t31, ocena 12)
- **Lampa w mroku:** nocą pokój ciemny, lampa daje wyraźną ciepłą plamę z miękkimi cieniami mebli; dzień wyraźnie jaśniejszy od nocy. (t31, krytyk B/C)
- **Dom bez ramek, wiszący w czerni;** dół i boki płynnie przechodzą w czerń. (README, t29)
- **„Naprawdę fajnie to teraz wygląda”** po tym, jak światło okien i drzwi szło z geometrii, a nie ze strojenia pojedynczych okien. (t31, oceny 10, 12)
- **Ulica nocą:** lampy „spoko”: ciepłe latarnie, zapalone okna z poświatą na śniegu, ciepła krawędź śniegu na dachach i parapetach. (t14, t27)
- **Pixel art cieni:** kilka poziomów, dither tym samym wzorem co gra, bez rozmytych gradientów i losowego ziarna. Gładki wygląd odpadł jako docelowy. (t37, research 84)
- **Cień nieba przy postaci i meblach:** miękki, krótki, kontaktowy; postać i meble cieniowane tak samo. (t33, t35, t36)

Czego człowiek NIE chciał (sygnały ostrzegawcze): siatkowaty cień (pas ditheru na łagodnym gradiencie) na ulicy w dzień (t14, „średnio”); jasne chłodne plamy nocą, które czytają się jak lampy (t27); dwa cienie „z krawędzi okna” przy postaci (t36); jasna ramka wokół cienia postaci (t14); ziarno 2x2 obok ditheru 1 px (t14); „pływające” prostokąty cienia od nieba na ścianie (t14); dzień, który „razi” (t31).

## 2. Ustalenia starych Poligonów

| Ustalenie | Skąd | Łatka starego silnika? |
|---|---|---|
| Południe na górze ekranu (północ, wschód, zachód odpadły) | t27, t31 | Niejasne: decyzja kompozycyjna (okna tylne dają smugę), ale wynika też z ograniczeń ręcznych okien |
| Światło okien i drzwi z geometrii, bez strojenia pojedynczych okien | README, t31 | Nie: zgodne z mapą silnika (jeden model) |
| Plama okna tylko z okien „górnych” w dzień; z bocznych nigdy | t27, t31 | Tak: łatka na złe wstęgi i plamy z okien bocznych |
| Smuga okien bocznych jako wstęga od linii ściany, jasność x0,2 | t31 oceny 7-9 | Tak: ręczne wstęgi `sun_ribbon`, „łamały się” |
| Okna dolne, boczne i drzwi: jedna reguła poświaty nieba (x2, w głąb 0,7) | t31 oceny 10-11 | Niejasne: „jedna reguła dla wszystkich ścian” pasuje do modelu, stałe to strojenie |
| Niebo jaśniejsze od strony słońca (x(1+0,4·cos)) | t31 ocena 11 | Niejasne: kierunkowość może wynikać z modelu kopuły |
| Niebo z okien innych pokoi tylko w pokoju swojego okna | t31 ocena 8 | Tak: łatka na jednakowe jasne światło w przejściach (później `sky_other_k`) |
| Noc: ulica oświetlona równo, plama z okien górnych w kolorze zewnętrza | t31 ocena 8 | Tak: `STREET_C`, `NIGHT_SIDE_DEG` to ręczny kierunek nocy zamiast latarni jako Źródeł |
| Kurz świeci tylko w promieniu słońca, 3x więcej drobinek, jasność x2 | t31 ocena 7 | Nie: ocena wyglądu (stylizacja kurzu) |
| Glow renderera wyłączony we wnętrzu (obwódka ramy to bloom, nie światło) | t31 ocena 11 | Tak: łatka; na ulicy glow był włączony i niespójny z domem |
| Jasność dnia: słońce i niebo x0,25, widok za oknem x0,55 | t31, README | Niejasne: kalibracja do średniej kadru game1, nie ocena nastroju |
| Pogoda: pochmurno ok. 11:00-13:30 (z game1) | README, `norway_feb.tres` | Tak: hack z game1, patrz sekcja 5 |
| Cień postaci A4: lampa dalej x1,4, długość x1,6, słońce jako punkt 10 m | t33 | Tak: odrzucone w t35 (fizyka z tarczą i żarówką zamiast reguł A4) |
| Walec o promieniu 0,26-0,27 m jako Bryła postaci | t33, `sun_map.gd:31` | Nie: zgodne z pojęciem Bryły |
| Postać i meble: jeden model cienia i ten sam wygląd | t33, t35 | Nie: wymaganie człowieka, spełnia je jeden model |
| Wygląd A (poziomy EV + dither Bayera 4x4), rozdzielczość x2 jako domyślne | t37 | Niejasne: pas w części kroku EV dał siatkę na ulicy; research 84 zamienia go na A′ (szew w px) |
| Wyglądy B i C (próg per źródło, cień kontaktowy nieba) | t37 | Tak: łamały kwantyzację sumy, nie sceny |
| Półcień słońca najwyżej 6 cm (`sun_pen_max`), tylko na ulicy | t14 | Tak: łatka na rozlany półcień budynków 6-10 m od ziemi |
| Bufor ulicy przeliczany co 5 min gry w 16 pasach | t14 | Tak: obejście wydajności starego bufora |
| `sky_objects = 0` na ulicy (niebo zasłaniają tylko budynki) | t14, research 84 | Tak: łatka na ciemną plamkę pod postacią |
| Błysk w co trzecim oknie w dzień, lampy w co drugim oknie, losowe świecenie okien | t27, README | Tak: dekoracje na fasadach bez cieni z bufora |
| Poświata zapalonych okien na śniegu (okno świeci na zewnątrz, zasięg 6 m) | t14, `street_fn.gdshaderinc:33` | Nie: okno jako Źródło powierzchniowe to model |
| Ciepła krawędź śniegu na dachach i parapetach przy fasadach w cieniu | t27 | Tak: ręczna kompensacja; do oceny, czy w ogóle potrzebna |
| Ekspozycja stała na przestrzeń, bez adaptacji oka (ADR 0007 game1) | t14, t27 | Nie: zgodne z `Y_ref` i ekspozycją automatyczną z mapy |
| Obraz widoku za oknem: średnia ok. 0,48, maks. ok. 0,8 | t31 szósta sesja | Nie: wskazówka dla Przepisu widoku |
| Ziarno filmowe 0,015 i grade „nordycki” w poście | `display.gdshader:12-13`, research 84 | Niejasne: grade to nastrój, ziarno miesza się z ditherem (człowiek nie chce losowego ziarna) |

## 3. Wnioski z research 84 (stylizacja)

- Żadna sprawdzona gra pixel art nie stylizuje miękkiego zasłaniania nieba w plenerze poziomami lub ditherem; gry mają jeden pipeline z różnymi danymi (LUT, kolory pory dnia).
- Przyczyna siatki na ulicy: pas ditheru w jednostkach światła (część kroku EV) ma od <1 px do ok. 85 px szerokości. Kierunek A′: szew o stałej szerokości w pikselach (`seam_px` 3; wariant: szachownica, `seam_px` 4) i kotwica `Y_ref`, żeby granice cienia nieba nie wędrowały w ciągu dnia.
- Kwantyzować sumę światła, nie każde źródło. Niebieski szum odpada (Bayer spójny z grą).
- Przy ocenie wyłączyć ziarno i glow, żeby nie mylić ich z wzorem.

## 4. Punkty startowe wartości

Wszystko poniżej to start dla Wariantów, nie reguły. Ścieżki względem `style-lab/lighting/`.

### 4.1 Krzywe doby

Z `time_of_day_profile.gd` (wartości domyślne) nadpisanych przez `data/norway_feb.tres` (luty, Norwegia); to profil w obu Poligonach.

| Wartość | Punkt startowy | Źródło i uwaga |
|---|---|---|
| Wschód / zachód słońca | 6,9 h / 18,1 h | `data/norway_feb.tres:19-20` (domyślnie 7,7 / 17,3, `time_of_day_profile.gd:7-8`) |
| Opóźnienie słońca po wschodzie / wcześniejszy zanik przed zachodem | 0,5 h / 0,5 h | `norway_feb.tres:21-22`; słońce wychodzi zza dachów późno i chowa się wcześnie |
| Czas „wyjścia zza wzgórz” | 0,5 h | `time_of_day_profile.gd:17` |
| Droga słońca: azymut | 180 stopni w południe, +-43 stopnie przy wschodzie i zachodzie (rano ze wschodu) | `time_of_day_profile.gd:9` |
| Droga słońca: wysokość | sin(wys.) w południe 0,26 (ok. 15 stopni), sinusoida od godziny | `time_of_day_profile.gd:10`; „nastrój ponad realizm” |
| Długość smugi na metr wysokości | 1,3 (słońce wysoko) do 2,0 (przy horyzoncie) | `time_of_day_profile.gd:11-12` |
| Kolor słońca: południe / rano / wieczór | (1,0 0,9 0,76) / (1,0 0,55 0,38) / (1,0 0,45 0,18) | `time_of_day_profile.gd:22-24`; wieczór cieplejszy, baza pod złotą godzinę |
| Ocieplanie słońca: od / pełne przy (0 wysoko, 1 horyzont) | 0,2 / 0,85 | `time_of_day_profile.gd:25-26`; pokrętło „jak długa złota godzina” |
| Złoty obraz za oknem: od / pełny przy | 0,25 / 0,7 | `time_of_day_profile.gd:27-28` |
| Natężenie słońca (czyste niebo), kolano | 3000 lx, 1,0 | `time_of_day_profile.gd:18,21` |
| Niebo pochmurne | 300 lx zmierzchu + 21000 · sin(wys.) | `time_of_day_profile.gd:33-34` |
| Noc: zewnątrz / minimum poświaty okien | 1 lx / 150 lx („nastrój”) | `time_of_day_profile.gd:35-36` |
| Świt: początek / pełnia; zmierzch: początek / koniec | 0,7 h przed i 0,5 h po wschodzie; 0,5 h przed i 0,7 h po zachodzie | `time_of_day_profile.gd:29-32` |
| Kolor nieba, punkty kontrolne | 00:00 #475cbd; 05:42 #4d5ebf; 06:54 #d999b3; 07:48 #d9cce0; 10:30 #cce0ff; 12:30 #cce0ff; 14:30 #d9d9f2; 17:06 #e69e9e; 18:06 #8073cc; 19:06 #4a5cbd; 24:00 #475cbd | `norway_feb.tres:10-11`; tabela w `swiatlo-kolory-game1.md`; różowo-liliowy świt i zmierzch |
| Kolor ambientu (używany tylko odcień) | 00:00 #3d426b; 06:54 #6b5766; 07:48 #a89494; 10:30 #f2f5fa; 12:30 #ffffff; 14:30 #e6dedb; 17:06 #f29e6b; 18:06 #61577a; 19:06 #424570 | `norway_feb.tres:14-15`; baza chłodna, ciepło tylko o 17:06 |
| Zachmurzenie (1 czysto, 0 pochmurno) | czysto do ok. 9:30, pochmurno 11:00-13:30, czysto od ok. 15:00 | `norway_feb.tres:6`; hack z game1 (sekcja 5); nowa krzywa: brak – do ustalenia przez krytyka. Inny trop: krzywa z research 22c game1 (słońce tylko 8:30-9:45 i 14:45-16:45), t31 ocena 5 |
| Tarcza słońca | 2,4 stopnia (promień) | `sun_map.gd:62`; miękkość cieni 0,8 stopnia wybrana w t31 ocena 4: dwie liczby z różnych etapów, do ujednolicenia przez krytyka |
| Ekspozycja: biel odniesienia | 250 lx = albedo przy ekspozycji 1; wnętrza `exposure_alpha` 0,3 | `exposure.gd:7`, `room_lighting_profile.gd:7` |
| Ekspozycja wnętrza dzień / noc (mnożnik) | x0,7 / x0,7 (krytyk C „Pośredni”) | opis w t31 (druga runda krytyka); suwaki `room_lighting.gd:21,23`, domyślnie 1,0 |
| Ekspozycja pleneru dzień / noc | brak – do ustalenia przez krytyka | t14: „dzień jasny (słońce na śniegu x0,5), do strojenia w t38” |

### 4.2 Zestaw strojenia: wnętrza

| Wartość | Punkt startowy | Źródło i uwaga |
|---|---|---|
| A′: poziom (krok) | 0,5 EV | `sun_map.gd:71`, `light_common.gdshaderinc:28`; research 84: `level_stops` 0,5 |
| A′: szew ditheru | 3 px (Bayer 4x4); wariant 4 px (szachownica); 0 = posteryzacja do porównania | research 84 §7; stary pas 0,3 kroku (`sun_map.gd:72`) nie jest w px, nie przenosić |
| A′: `Y_ref` | luma otwartego nieba na płaskim terenie przy ekspozycji przestrzeni + ambient | research 84 §6.1; w starym silniku brak – do ustalenia przez krytyka (jest tylko wzór) |
| A′: rozdzielczość widoku | x2 (domyślnie, wybór człowieka) | t37 Resolution |
| Półcień: tarcza słońca / żarówka | 2,4 stopnia / 0,1 m | `sun_map.gd:62-63` |
| Modelowanie / kontrświatło / wypełnienie (Odbiorniki) | brak – do ustalenia przez krytyka | stary silnik: tylko `sky_dir_k` 0,4 (niebo jaśniejsze od strony słońca, `sun_map.gd:51`) |
| Ambient pokoju dzień / noc (mnożnik) | x0,7 / x0,4 (krytyk C) | t31; rozlewanie lamp `art_fill_k` x1,5 (C); `room_lighting.gd:25-26,29` |
| Udział słońca w ambiencie / lamp; nasycenie; maks. | 0,1 / 0,1; 0,75; 1,1 | `room_lighting_profile.gd:16-20` |
| Poświata nieba przez okna dolne, boczne, drzwi | x2 w głąb 0,7; drzwi x0,5 | `sun_map.gd:49-53`; t31 ocena 10 |
| Skala słońca i nieba | x0,25 | `sun_map.gd:48`; kalibracja do kadru game1 |
| Siła Smug: gęstość powietrza, zanik | 0,08 (x `air_k` 1,0), 6 m | `sun_map.gd:41-42` (`AIR_FADE_M`, `AIR_DENSITY`) |
| Siła Plam okna | brak osobnej wartości (dziś część `sun_scale`; t31 ocena 1: jasność plamy x0,5) | do ustalenia przez krytyka |
| Smugi okien bocznych: jasność / szerokość / poszerzanie | x0,2 / x2 / 0,25 na metr | `sun_map.gd:54-56`, `RIBBON_WIDEN` `sun_map.gd:35` |
| Kurz: ilość, jasność, kolor | 25 drobinek x3 (`DUST_AMOUNT_K`), gain x2, kolor (1,0 0,92 0,8 alfa 0,22) | `room_lighting_profile.gd:24,28`, `sun_map.gd:43-44` |
| Noc: zimne światło z okien | x2 (krytyk C); 10 lx (`NIGHT_COOL_LUX`) | `sun_map.gd:38`; t31 |
| Lampy z mapy: jasność | x2 (krytyk C) | t31; domyślnie 1,0 (`sun_map.gd:58`) |
| Światło na postaci | x1 (t38: ustalić na 1 lub usunąć); w C: niebo x0,5, lampy x0,9, mapa x1,5 | `sun_map.gd:60`, t31, t38 |
| Podłoga nocą | `floor_lux` 3 lx | `room_lighting_profile.gd:6` |

### 4.3 Zestaw strojenia: plener

| Wartość | Punkt startowy | Źródło i uwaga |
|---|---|---|
| A′: szew, poziomy | te same co wnętrza (jeden algorytm, research 84 §5) | jedno `level_stops` dla obu scen |
| Słońce na otwartym terenie | x0,5 lux słońca na ekspozycji ulicy | `street_map.gd:29` |
| Udział nieba w buforze | 0,75 (reszta płaska jako odbicie) | `street_map.gd:30` |
| Noc w plenerze: jasność, udział słońca w ambiencie | 20 lx (śnieg, poświata miasta); 0,3 | `room_lighting_profile.gd:12`, `data/outdoor.tres:13` |
| Zapalone okna na ulicę: natężenie, zasięg | 1100 lx na formę (x1,0); zanik od 3 do 6 m | `street_map.gd:31-32`, `street_fn.gdshaderinc:33` |
| Latarnie: mnożnik | x1,0 | `street_map.gd:33` |
| Kurz w plenerze | wyłączony | `data/outdoor.tres:14` |
| Glow renderera | 0,7 przy progu HDR 1,0 (ulica); wnętrze wyłączony | `data/view_environment.tres:6-9`; patrz sekcja 5 |
| Półcień słońca | maks. 6 cm przy przesłonie | `street_fn.gdshaderinc:236`; łatka (sekcja 5) |
| Modelowanie / kontrświatło / wypełnienie | brak – do ustalenia przez krytyka | |
| Ambient i ekspozycja ulicy | brak – do ustalenia przez krytyka | w starym silniku ekspozycja z `exposure_alpha` 0,3 |

### 4.4 Profile Źródeł

Z `data/*.tres` (`fixture_def.gd`); natężenie to nominalne lx na podłodze pod źródłem; kolory z game1 (`swiatlo-kolory-game1.md`).

| Źródło | Kolor | Natężenie | Zanik, kształt | Godziny świecenia |
|---|---|---|---|---|
| Lampa stołowa (`desk_lamp.tres:8`) | (1,0 0,7 0,42) #ffb36b | 400 lx | tekstura 0,6, stożek | harmonogram wieczorny |
| Lampa stojąca (`floor_lamp.tres:8`) | (1,0 0,6 0,3) #ff994d | 150 lx | żarówka 1,65 m nad podłogą, 0,15 m za oprawą | j.w. |
| Kinkiet (`wall_sconce.tres:8`) | (1,0 0,64 0,34) #ffa357 | 100 lx | tekstura 1,0 | j.w. |
| Żarówka w celi (`cell_bulb.tres:8`) | (1,0 0,85 0,6) #ffd999 | 60 lx | | j.w. |
| Świetlówka (`hall_tube.tres`) | domyślny #faf2d6 | 120 lx | tuba, tekstura 1,8 | j.w. |
| Monitor (`monitor.tres:8`) | (0,22 0,42 1,0) #386bff | 100 lx | | j.w. |
| Latarnia (`street_lamp.tres:8`) | (1,0 0,64 0,34) #ffa357 | 60 lx | żarówka 4,0 m nad ziemią, tekstura 1,4, zasięg do 14 m (`street_map.gd:21`) | wg `outdoor.tres:6`: gaśnie ok. 8,0 h, zapala ok. 17,8 h |
| Lampy pokojowe, harmonogram `evening_lamps` | | | | świecą do ok. 8,7 h, gasną ok. 9,2 h; zapalają się od ok. 16,3 h, pełne ok. 16,8 h (`evening_lamps.tres:6`) |
| Światło z zewnątrz w drzwiach (`entrance_spill.tres:8`) | (0,7 0,8 1,0) #b3ccff | 90 lx | tekstura 2,4; w trybie mapy zastąpione szybą drzwi x0,5 | zawsze (poza harmonogramem) |
| Świecące okno nocą, poświata (`window_light.tres:7-10`) | (0,696 0,712 0,876) #b1b6df | 25 lx; widok x1,35 nocą, maks. 1,6 | niebo przez szybę, jaśniej od strony słońca | wieczorem i nocą, w kolorze zewnętrza (`sky_glow_color`, `window_light_profile.gd:95`) |
| Okno zapalone widziane z ulicy | ciepłe (wariant „ciepłe / ciemne”) | 1100 lx na formę (`street_map.gd:32`) | zasięg 6 m | brak harmonogramu w danych: dekoracja w `ulica_bryly.gd` (sekcja 5); do ustalenia przez krytyka |

### 4.5 Profile nieba

Starego silnika nie ma osobnych profili „miasto” i „wieś”: jest jedno niebo (`norway_feb.tres`, punkt 4.1) i jedna noc w plenerze.

- Niebo miasta (poświata, śnieg, latarnie): częściowo `outdoor_night_lux` 20 lx (`room_lighting_profile.gd:12`) i `night_sky_lux` 150 lx (`time_of_day_profile.gd:36`); reszta: brak – do ustalenia przez krytyka.
- Niebo wsi (ciemniejsze, bez poświaty miasta): brak – do ustalenia przez krytyka. Zasada z mapy grafiki (t14): „noc w mieście i poza nim”.
- Zasłanianie nieba przez budynki liczy się z geometrii; jedyna stała ze starego silnika: zasięg cienia nieba obiektów 4 m (`street_map.gd:23`).

## 5. Czego nie przenosić

Znane łatki starego silnika; nowy silnik rozwiązuje te problemy modelem:

- **Hack zachmurzenia ok. 11:00-13:30 z game1** (`norway_feb.tres:6`): dobrany, żeby w południe „nie raziło”; w nowym silniku pogoda to stały schemat dobowy z mapy.
- **`sky_objects = 0` na ulicy** (`street_map.gd:36`): łatka na ciemną plamkę pod postacią; niebo zasłaniają wszystkie Przesłony tym samym wzorem.
- **`sun_pen_max` (6 cm) tylko na ulicy** (`street_fn.gdshaderinc:236`): łatka na ziarnisty półcień dalekich budynków; półcień ma wynikać z jednej geometrii.
- **Losowe i okresowe świecenie okien** (błysk w co trzecim oknie, lampy w co drugim): dekoracja bez związku ze Stanem doby; okno świeci według godzin swojego Źródła.
- **Zakaz plamy z okien bocznych i wstęgi `sun_ribbon`:** łatka na rozjeżdżające się ręczne smugi; Plama okna i Smuga wynikają z geometrii każdego Otworu.
- **Stałe nocy (`STREET_C`, `NIGHT_SIDE_DEG`, „ulica równo”):** zastępowały brak latarni jako Źródeł w modelu.
- **Reguły postaci A4** (lampa dalej x1,4, długość x1,6, słońce jako punkt, okno cienia 320x320, `actor_k`): odrzucone w t35; postać to Przesłona jak każda inna.
- **Wyglądy B i C i pas ditheru jako część kroku EV:** przyczyna siatki na ulicy; zastępuje je A′.
- **Warstwy rysowane na wierzchu** (języczek drzwi, plamka pod stopami, `BeamCanvas`, poduszki nieba, bliźniaki lamp postaci): poza buforem, nie dostawały cienia.
- **Przeliczanie ulicy co 5 minut w 16 pasach i okno wokół postaci:** obejście wydajności; mają dać wspólną godzinę całego bufora (obserwacja człowieka: przy szybkim przewijaniu czasu okno ma inną godzinę niż reszta).
- **Glow renderera jako światło** (obwódka ramy okna) i jego niespójność dom/ulica: bloom nie jest światłem.
- **Ziarno filmowe 0,015 w poście** (`display.gdshader:13`): losowy szum nakładający się na dither.
