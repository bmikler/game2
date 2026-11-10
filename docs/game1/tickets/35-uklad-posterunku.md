> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/35-uklad-posterunku.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

---
id: 35
title: Układ posterunku i meble wycinka
labels: [wayfinder:prototype]
status: closed
assignee: bmikler
blocked_by: [47]
---

## Question

Jak wygląda plan posterunku z wycinka „Dzień na posterunku” i jakie meble do niego generujemy? Pięć pomieszczeń z Zakresu wycinka scenariusza (gabinet Badacza z telefonem, recepcja z biurkiem i komputerem Krogga, archiwum z regałami, pokój socjalny z kanapą i ekspresem, dwie cele) plus korytarz i zamknięte drzwi wyjściowe: rozmieszczenie, wymiary w metrach (1 m = 40 px, wnętrza tak duże, by w większości wypełniały kadr 24×13,5 m, małe pokoje w ciemności; Rozdzielczość bazowa), kierunki ścian i okien (widok 3/4, ściana tylna z oknami, przednia usunięta), przejścia między Pomieszczeniami (budynek = jedna scena z Pomieszczeniami; Architektura kodu szkieletu) i trasy Rutyny Krogga. Wzór pokoju socjalnego: docs/research/22b-uklad-pokoju-socjalnego.md. Potem lista mebli i rekwizytów do wygenerowania tym samym łańcuchem co postacie (koncept ComfyUI → pikselizacja, normal mapy własnym skryptem; Pipeline assetów pixel art z normal mapami), z wymiarami. Sprawdzić w prototypie z zestawem oświetlenia (klocki pomieszczeń), Badaczem i Kroggiem. Wynik odblokowuje panoramę za oknami fasady (długość fasady).

## Postęp (2026-10-29)

Prototyp w `game1-proto`, gałąź `prototype/oswietlenie` (bez commita): `station_layout.gd` buduje posterunek z danych w metrach, `station_kit.tscn` jest pusty i używa go przez `station_kit.gd` (`run_station_kit.bat`; K plama słońca, R trasa i nazwy, T pory dnia). Szkice układów: `prototype/lighting/sketches/uklad35.html` (Artifact „Szkice posterunku”, https://claude.ai/artifact/MhXVTZcJkmd1K1BaND51ZS). Zrzuty: `shots/layout35_19/`, porównania `shots/cmp/sciany_22_19.png`, `shots/cmp/plama_tak_nie.png`.

**Ustalone z człowiekiem:**
- **Zakres zmieniony względem Zakresu wycinka scenariusza:** układ tymczasowy, do sprawdzenia mechanik, uproszczony. Trzy pomieszczenia i cela: sala główna, gabinet Badacza, pokój socjalny, jedna cela. Archiwum odpada (szafy z teczkami w zapleczu sali przejmują Południe w Rutynie Krogga). Do odnotowania w Zakresie wycinka scenariusza przy zamknięciu.
- **Ściany według Ścian i podziału wnętrz w widoku 3/4 (wzorzec A):** każda podłoga ma stałe lico ściany tylnej (także pod pomieszczeniem wyżej), ściany boczne i przednie to tylko wierzch. Bez wygaszania ścian i przyciemniania sąsiednich pomieszczeń.
- **Wysokość ścian 1,9 m (76 px)**, mniej realistycznie, ale lepiej w kadrze (porównano 2,6 / 2,2 / 1,9 m). Drzwi z futryną i nadprożem, nie do sufitu: min(2,0 m; ściana − 0,35 m), przy 1,9 m ok. 1,55 m. Okno: parapet ok. 1/3 ściany, góra 0,25 m pod sufitem.
- **Układ A (zaakceptowany 2026-10-29, zastępuje wariant 4):** jak najwięcej pomieszczeń na fasadzie, żeby miały okna. Fasada od lewej: sala 6 m (okno), gabinet 4,2 × 4 m (okno), pokój socjalny 4,4 × 4 m (okno), areszt 4,4 × 4 m (dwa małe, wysokie okienka). Wejście w dolnej ścianie sali prowadzi do poczekalni (krzesła, wieszak); lada Krogga w poprzek sali (przód 3,2 m od ściany tylnej), Krogg siedzi z oknem, mapą okręgu i szafami z teczkami za plecami, furtka na prawym końcu lady. Pod gabinetem, pokojem socjalnym i aresztem korytarz 1,8 m otwarty na salę z prawej u dołu; w jego licu troje drzwi w górę i tablica ogłoszeń. Areszt: dwie cele za jedną półprzezroczystą kratą w poprzek pokoju (2,2 m od ściany tylnej, kratowe drzwi z zamkiem), przedzielone wierzchem ściany, przed kratą korytarzyk z krzesłem. Budynek ok. 19,6 × 7,85 m (podłoga) mieści się w jednym kadrze; fasada ok. 19,6 m. WC odłożone (dziwnie odstawało pod korytarzem, wróci później w dolnej linii). Arkusz: `shots/cmp/uklad_A.png`, zrzuty `shots/layoutA3/`.
- ~~**Układ (wariant 4 ze szkiców):**~~ (zastąpiony przez układ A) sala 11 × 6,2 m na fasadzie (2 okna): wejście w dolnej ścianie z zimną smugą, poczekalnia (krzesła pod oknem, tablica ogłoszeń, wieszak), lada w poprzek sali = biurko Krogga (komputer, papiery z amuletem) z przejściem przy dolnej ścianie, za ladą zaplecze (szafy z teczkami, mapa okręgu), drzwi boczne do pokoju socjalnego (4,4 × 3,8 m, płytszy, okno na fasadzie). Pod poczekalnią gabinet Badacza 4,2 × 3,8 m: ściana tylna to ściana wewnętrzna z drzwiami z sali, okno w lewej (wschodniej) ścianie bocznej. Pod zapleczem jedna cela 2,2 × 2,4 m z kratami zamiast lica, bez okna. Każde pomieszczenie poza celą ma okno. Fasada (ściana z oknami) ma ok. 15,6 m: to długość panoramy za oknami.
- **Światło:** bez plamy okna na podłodze (dzień i noc), tylko smugi w powietrzu, dłuższe (×1,7) i płynnie gasnące; plama kładła się na bryłach (lada). Okno boczne: szybka w wierzchu ściany i smuga (`kit/side_window_light.gd`), przygasa z porą dnia; do strojenia razem z resztą.
- **Przejście przez drzwi w licu** wydzielone do Przejścia przez drzwi w ścianie (góra–dół).

**Nowe klocki zestawu (prototyp):** `RoomShell`: `wall_doors` (otwór w licu z futryną, nadprożem i przesmykiem), `front_gaps`, `side_doors_left/right` (przerwa z progiem i słupkami), `side_windows_left/right`, styl ściany `BARS`; `SideWindowLight`; `LayoutBox` (bryły-placeholdery z podpisami); `WindowLight.show_patch`; kamera podążająca za graczem w granicach budynku.

**Kolejność pracy nad wnętrzem (człowiek, 2026-10-29; wejście do Pipeline'u tworzenia wnętrz):** 1) plan pomieszczeń i okna, które dają światło; 2) kluczowe meble jako gotowe assety (biurka, komputery, kraty, prycze…) i ich ustawienie; 3) oświetlenie na końcu, na gotowych meblach; 4) ozdoby (kalendarz, tablica korkowa, plakaty) na samym końcu. Wcześniejsze strojenie światła na bryłach było za wcześnie.

**Okna (krok 1, zrobione):** poza fasadą okno w lewej (wschodniej) ścianie sali nad poczekalnią i dwa okna w dolnej (północnej) ścianie korytarza na parking, oba jako szybka w wierzchu ściany ze smugą (`RoomShell.front_windows`, `SideWindowLight.into_up`). Korytarz w dzień nie jest już ciemny. Zrzuty `shots/layoutA4/`.

**Postęp (2026-10-29, druga część sesji)**, prototyp na gałęzi `prototype/oswietlenie`, commity `a04f4c6` (układ A, meble, okna) i `a51acf9` (światło okien):
- **Cela:** jedna cela, krata 1,6 m od ściany tylnej z jednymi drzwiami po lewej, prycza przy ścianie tylnej na prawo od środka; prycza oświetlana jak postać (`Prop.lit_as_actor`, bo górą wchodzi na pas ściany, gdzie nie sięgają światła podłogi).
- **Okna tylne** 1,35 m szerokości, parapet 0,61 m, góra 0,25 m pod sufitem (`StationLayout.window_m`).
- **Dłuższe złote godziny** kosztem nocy (człowiek: klimat ponad realizm): wschód 6:54, zachód 18:06, przejścia nieba ok. 50 min szersze, złota faza dłuższa (`norway_feb.tres`, `time_of_day_profile.gd`).
- **Światło okien według wzorca A z Światła z okien w różnych ścianach w widoku 3/4:** promień = szyba + jej rzut na podłogę, ostre brzegi, koniec poszerzony 2,0× (wybrane, `shots/cmp/okna_C.png`), jasność tylko wzdłuż promienia (pasy); jedna reguła słońca dla wszystkich ścian (kierunek, bramka facing, siła wg powierzchni szyby); okna boczne i przednie: promień od szybki w wierzchu ściany (`side_k` 0,8) + poduszka nieba w `sky_color` zamiast światła z drzwi; okna północne tylko niebo. Ustawienia: `--widen=`, `--gain=` (1,0), `--falloff=`, `--side_k=`; `--hours=` robi zrzuty sali o wybranych godzinach. Szyby okien tylnych rozszerzają się tylko na zewnątrz, więc cień słupka zostaje przez cały promień. Próba ze słupkiem w oknach bocznych (dwa promienie) odrzucona: promień wyglądał na bardziej stromy; okna boczne i przednie zostają z jedną szybą. Uproszczenie: poduszka nieba okien bocznych nie oświetla postaci (brak bliźniaka dla obróconego światła).
- **Tekstury z ComfyUI** (`art/concept/props/posterunek/_tekstury.png`): krata `krata-299757619{4,5,6}` udana (propozycja Claude: 6, drzwi najbliżej naszego ustawienia), okno w wierzchu ściany `okno-gora-*` nieudane (widok z przodu zamiast z góry), wierzch ściany `sciana-gora-*` poprawny, ale z ramką na końcach.

**Postęp (2026-11-01), ticket zaparkowany przez człowieka.** Zmiany w prototypie (`game1-proto`, gałąź `prototype/oswietlenie`) w commicie `6030719`.
- **Krata:** wybrana 6 (`krata-2997576196`). Zmniejszony koncept wyglądał na niższą rozdzielczość niż postać, więc rysunek powstaje kodem na układzie konceptu (`pipeline/bars_draw.gd` → `room/props/krata.png`): ciemna stal z palety, pręty co 5 px, kontur `25262f` jak u postaci, tylko po stronie cienia; `lit_as_actor`, bo górą wchodzi na pas ściany. Krata blokuje całą szerokość (cela na razie niedostępna). Otwarte: czy nie za ciężka (ewentualnie pręty co 6 px), środkowy słupek nie jest pośrodku części stałej.
- **Prycza:** człowiek odrzucił brązowy koc (`pipeline/colorize.gd`), wrócił oryginalny kolor; przy ciemnej kracie kontrast wystarcza.
- **Wierzch ściany:** tekstura z trzech `sciana-gora-*` sklejonych w pasek (`pipeline/wall_top.gd` → `room/walltop/top<cap>.png`). Grubość to `--cap=` (6/8/10/12 px), roboczo domyślnie 10 px; **ostatecznej decyzji człowieka jeszcze nie ma** (rekomendacja Claude: 10 px). `--flat_top` to stary ciemny wierzch. Arkusz: `shots/cmp/okna_wierzch2.png`.
- **Okna w wierzchu:** długość 62 px (1,55 m), czyli zewnętrzny obrys okna tylnego: szyba 1,35 m + ościeże po 4 px (`StationLayout._window_outer_m`). Szkło to osobna warstwa `unshaded` w kolorze świata za oknem (człowiek: dzień szaroniebieski, wschód i zachód pomarańczowy, noc ciemna z lekką poświatą, bez latarni na szybie), jasność jak widok okna tylnego, ograniczona do 1. Rampa złotej godziny poza raportem 35b (`a0836f`, `c9a96a`, `e8c27a`), bo kremowa wyglądała szaro. **Sam rysunek okna człowiek uważa za dziwny:** do poprawy według `docs/research/35b-okna-w-wierzchu-sciany.md`.
- **Odstęp od ścian bocznych:** `RoomShell.SIDE_CLEARANCE` 11 px + połowa `FOOT` = 18 px, kurtka nie nachodzi na wierzch. `--probe` podaje odstęp i osiągalność miejsc (wszystkie osiągalne).
- **Świecenie podłogi:** człowiek zgłosił „dziwne świecenie”, potem odłożył temat. Nie zidentyfikowane; w dziennych zrzutach plamy wyglądają jak przed zmianami okien.
- **Blender:** człowiek odłożył instalację (2026-10-29), Pipeline mebli z brył w Blenderze nadal blokuje dalsze meble.
- **Nowe opcje zrzutów:** `--clean` (bez trasy i podpisów), `--only=<nazwy>`.

- **Research okien zakończony** (`docs/research/35b-okna-w-wierzchu-sciany.md` §8, przykłady `docs/research/35b-okna-przyklady.png`, makieta poza grą `docs/research/35b-okna-makieta.png`). Dziwny wygląd: szkło zajmuje 40% grubości ściany (w zmierzonych grach 15–33%), brak ciemnego konturu szyby, jasny parapet i kremowa rama dają „listwę w ramce”. Przepis 10 px od pokoju: `c1b6a3`, `a0836f` ×2, `756357`, `2e2a25`, szkło ×2, `2e2a25`, `a8978e`, `1e1a17`; słupki `a8978e` równo ze ścianą, bez błysków i szronu. Szkło (pokój/niebo): dzień `9fb8d0/c0cacc`, złota godzina `c9a96a/e8c27a`, noc `262e47/415d7a`. **Przepisu nie oceniono jeszcze w grze ani nie wdrożono** (`_window_parts`, `_top_window`); do porównania wariant „wycięcie” jak w Door Kickers 2 (§8.8).

**Po powrocie:** wdrożyć przepis okna i ocenić go w świetle prototypu, decyzja o grubości wierzchu, ocena kraty, potem lista poniżej.

**Zostało w tym tickecie:**
1. Kluczowe meble (człowiek 2026-10-29: wszystkie assety od nowa jednym łańcuchem, `table` i `chair` do kosza; krata jako asset do sprawdzenia; okna, kaloryfery i czarne wierzchy ścian działowych też generować w pixel arcie, bo kodem wyglądają mało szczegółowo; każdy obraz z ComfyUI do akceptacji człowieka przed pikselizacją; kolejność: lada Krogga i prycze najpierw). Koncept: bryła w rzucie gry jako 1. referencja (kształt, kamera; `art/concept/props/posterunek/_guides/`) + wybrany koncept pomieszczenia jako 2. referencja (materiał); bez referencji FLUX nie trzyma kamery ani proporcji. Zaakceptowane i w grze: lada (`lada-gc74m-3234925162`) i prycza (`prycza-g-4031217692`), łańcuch lokalny bez Pixellab (STYLE.md, „Meble i obiekty”); okna tylne 1,35 m szerokości. Dalsze generowanie czeka na research Generowanie mebli w spójnym rzucie 3/4 (FLUX trzyma kąt tylko częściowo; najlepsza dotąd szafa: FLUX 3 + arkusz Badacza jako referencja stylu, `szafa-mal-flux3-601619933`). Komputer na ladzie stoi tyłem monitora do kamery (Krogg patrzy na poczekalnię). Lista z wymiarami, generowanie (koncepty w `art/concept/locations/posterunek/`: sala-c, gabinet-b, socjal, cele-d → pikselizacja → normal mapy), podmiana brył, ustawienie od nowa (człowiek: obecne bez sensu).
2. Trasy Rutyny Krogga przez nowy układ (teraz przenosi się między punktami bez chodzenia).
3. Oświetlenie na gotowych meblach. Materiał z bryłami: `shots/cmp/sala_swiatlo.png` (stary układ), `shots/cmp/sala_swiatlo_A.png` (układ A: rury / 1 rura nad Kroggiem + lampy / same lampy, `--hall=`); rekomendacja Claude: 1 rura + lampy.
4. Ozdoby (mapa okręgu, tablica ogłoszeń, stary plakat, kalendarz).
5. Zamknięcie: rozwiązanie, aktualizacja Zakresu wycinka scenariusza i ewentualnie ADR 0002 (wysokość ścian 1,9 m), graduacja panoramy (fasada ok. 19,6 m) i WC do Not yet specified, wpis na mapie, commit prototypu. Doświadczenia z tej sesji są wejściem do Pipeline'u tworzenia wnętrz.

## Zawężenie (2026-11-01, decyzja człowieka)

Ta sekcja zastępuje listy „Po powrocie” i „Zostało w tym tickecie”. Układ pomieszczeń jest gotowy (układ A). Ticket zamyka układ mebli pierwszej wersji, potem Spec wycinka. Rysunek okna, grubość wierzchu ściany, ocena kraty, „dziwne świecenie” podłogi, oświetlenie na meblach i ozdoby przechodzą do budowy.

**Meble:** mniej mebli w pierwszej wersji, tylko to, co jest teraz na posterunku, oraz:
- **Aneks z ekspresem:** gotowy obiekt Pixellab `167bcc4e-ae2e-42a8-854f-7f6b3ac31137` (96×96, high top-down, 1 kierunek; szafki, mikrofalówka, ekspres). Do sprawdzenia w grze obok lady (skala, kolor).
- **Szafy z teczkami i wieszak:** próba w Pixellab, jeśli starczy tokenów; jeśli nie, zostają placeholdery.
- **Telefon:** na biurku Badacza albo mechanizm telefonu komórkowego. Do rozstrzygnięcia w tym tickecie.
- **Stos papierów:** odpada. Test Spostrzegawczości na amulet przenosimy na kanapę w pokoju socjalnym.

**Do zrobienia:**
1. Ustawienie mebli (propozycja jako ASCII).
2. Wybór telefonu.
3. Nowa konsekwencja forsowania testu na amulet, bo „rozsypane papiery” z Zakresu wycinka scenariusza już nie pasują.
4. Trasy Rutyny Krogga przez układ A.
5. Zamknięcie: rozwiązanie, aktualizacja Zakresu wycinka scenariusza (pomieszczenia, meble, amulet, telefon), ewentualnie ADR 0002 (ściany 1,9 m), wpis na mapie, commit prototypu.

## Postęp (2026-11-01)

Decyzje człowieka:
- **Aneks:** lewy górny róg pokoju socjalnego, bo tak pasuje kąt sprite'a (Pixellab: 58×68 px). Lodówka zostaje w prawym rogu, okno między nimi (x 1,75 m). Bryła stołu usunięta.
- **Kanapa:** nie przy dolnej ścianie, bo jest do niej zwrócona; stoi na (2,9; 2,7) m.
- **Krzesła w poczekalni:** wzdłuż lewej ściany, pod oknem, nie w poprzek sali.
- **Szafy i wieszak:** z Pixellab (10 generacji), `room/props/szafy` i `wieszak_kurtka`, wieszak po prawej stronie wejścia. Za ladą krzesło Krogga.
- **Telefon:** komórka, bez aparatu na biurku.
- **Forsowanie:** usunięte z całej gry (Model testów umiejętności). Punkt 3 listy jest nieaktualny.
- **Rzut mebli:** nowe meble generujemy w rzucie gry, wzorem jest `lada` (`STYLE.md`). Obecne obiekty z Pixellab zostają w pierwszej wersji.

Trasy Rutyny Krogga są w prototypie (`StationLayout.legs`, `--walk_test`): szafy 3,4 m, kawa 18,3 m, powrót 20,1 m, wyjście 10,7 m; żaden odcinek nie koliduje ze ścianami ani meblami.

## Resolution

Posterunek pierwszej wersji to układ A, zbudowany z danych w metrach w prototypie (`game1-proto`, gałąź `prototype/oswietlenie`: `station_layout.gd`, `station_kit.gd`, `room/props/`; `run_station_kit.bat`). Ten plik jest źródłem wymiarów dla budowy.

```
 SALA 6 m                 GABINET 4,2 m     SOCJALNY 4,4 m     ARESZT 4,4 m
+------------------------+-----------------+------------------+------------------+
|  okno   mapa   SZAFY   | okno     plakat | ANEKS  okno   LOD|okienko    okienko|
|                 K2     |                 |  K3              |  prycza          |
|     K1                 |    BIURKO       |     KANAPA+amulet|=D================|
|====== LADA ======  \   |                 |                  |  krzesło         |
|k                       +----------[dd]---+--[dd]------------+-------[dd]-------+
|k                         tablica ogłoszeń, lico z drzwiami w górę              |
|k                         korytarz 1,8 m                                        |
|           W                                                                    |
+----[wejście]-----------+--------------[okno]-----------------[okno]------------+
```

- **Wymiary:** budynek ok. 19,6 × 7,95 m, fasada ok. 19,6 m, ściany 1,9 m (76 px), okna tylne 1,35 m (parapet 0,61 m, góra 0,25 m pod sufitem). Sala 6 m szerokości, gabinet 4,2 × 4 m, pokój socjalny 4,4 × 4 m, areszt 4,4 × 4 m (krata 1,6 m od ściany tylnej, cela na razie niedostępna), korytarz 1,8 m otwarty na salę.
- **Meble (pozycje w metrach, x od lewej, y od ściany tylnej):** lada (2,4; 3,2), szafy (4,75; 0,6), krzesła w poczekalni (0,45; 4,4 / 5,3 / 6,2), wieszak z kurtką (2,9; 7,75); biurko Badacza (1,9; 2,4); aneks (0,78; 0,65), lodówka (4,0; 0,65), kanapa (2,9; 2,7); prycza (2,9; 0,6), krzesło w areszcie (0,5; 3,5).
- **Grafika:** istniejące sprite'y plus szafy, wieszak i aneks z Pixellab. Rzut tych trzech nie jest zgodny z ladą; zostają w pierwszej wersji, a nowe meble generujemy w rzucie gry (`STYLE.md`). Komputer na ladzie (monitor tyłem do kamery) to placeholder. Rysunek okna, grubość wierzchu ściany, ocena kraty, „dziwne świecenie” podłogi, oświetlenie na meblach i ozdoby przechodzą do budowy.
- **Trasy Rutyny Krogga** (`StationLayout.legs`, 60 px/s): `K1` → `K2` za ladą (3,4 m); `K2` → furtka → sala → korytarz → drzwi → `K3` (18,3 m); ta sama droga do `K1` (20,1 m); o 19:00 `K1` → furtka → wieszak → wejście (10,7 m). Rusza na początku nowej Pory dnia, po Przeskoku od razu stoi na miejscu docelowym, Badacza nie blokuje.
- **Telefon:** komórka, otwierana przyciskiem w HUD-zie i akcją z Input Map, poza rozmową. Aparatu na biurku nie ma, więc gabinet ma w wycinku tylko opisy obiektów.
- **Testy (zmiana w całej grze):** bez forsowania i bez zapowiadania konsekwencji porażki przed rzutem (Model testów umiejętności).
- **Test Psychologii:** sukces: Krogg mówi, że zgubił amulet, pewnie w socjalnym, gdzieś przy kanapie. Porażka: Krogg mówi, że wszystko w porządku, Temat bez wyznania. Popsucia w wycinku nie ma.
- **Test Spostrzegawczości na amulet:** na kanapie, jeden rzut, porażka: amulet przepada do końca wycinka. Spostrzegawczość Badacza 70, czyli góra zakresu Umiejętności głównych, Poziom trudności zwykły.

Zakres wycinka scenariusza zaktualizowany. Wysokość ścian w ADR 0002.
