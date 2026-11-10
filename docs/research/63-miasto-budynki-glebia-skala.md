# Miasto i budynki w 3/4: głębia ulicy, skala fasady, wnętrze większe niż zewnątrz, zgodność okien

Stan: 2026-11-08. Ticket `docs/wayfinder/tickets/04-miasto-i-budynki-3-4.md`. Uzupełnia `43`, `43b`, `53`, `54` (nie powtarzam: wzorzec A ścian wnętrz, okna wnętrz tylko w licu ściany tylnej, fasady z oknami tylko od strony kamery, rzut oblique Chef RPG 24 px kafel).

Oznaczenia: **[zweryfikowane]** oficjalny zrzut ze sklepu Steam albo tekst twórcy, który sam oglądałem/czytałem; **[wtórne]** tekst osoby trzeciej; **[niezweryfikowane]**; **[wniosek]** moja interpretacja; **[pomiar]** liczone na obrazie. Wszystkie pomiary na zrzutach są **szacunkiem z oka na jpg 1920x1080 (±15%)**, bo w środowisku nie ma bibliotek do analizy obrazu. Jednostką jest **wysokość postaci (WP)**, bo gry mają różne skale pikseli.

## Źródła

Zrzuty pobrane przez `store.steampowered.com/api/appdetails` (pliki w `63-assets/<gra>-NN.jpg`, dane niezaufane, tylko do oglądania, nie do redystrybucji): Chef RPG (1796790), Stardew Valley (413150), Eastward (977880), Fields of Mistria (2142790), Sun Haven (1432860), Graveyard Keeper (599140), Project Zomboid (108600). Pobrano wszystkie zrzuty (108 plików), obejrzałem ok. 20; w `63-assets/` zostawiłem tylko użyte. Użyte numery: `chef-01/02/04/07`, `stardew-01/10`, `eastward-01/05`, `mistria-02/10`, `sunhaven-03`, `keeper-07`, `zomboid-02`.
Tekst twórcy: wywiad z Tommo Zhou (Pixpil, Eastward), Game Developer, `gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures` [zweryfikowane].
Wtórne: blog Blake'a Crosleya, `blakecrosley.com/blog/pixel-art-structures-on-iphone` (osoba prywatna, liczby z gier Pokémon i Stardew bez własnego dowodu u mnie) [wtórne]. Nie znalazłem żadnego dev-logu twórców tych gier, który wprost opisuje „wnętrze większe niż zewnątrz” ani zgodność okien [niezweryfikowane; wyszukiwanie nic nie dało].

## TL;DR (reguły do przyjęcia)

1. **Głębię ulicy robi się pionem, nie rzędem.** Eastward: „elevation is your friend to make an area feel dense”, „having a lot of verticality ... prevent[s] elements in the foreground from occluding elements further in the background”, „staircases ... let the player move behind buildings without being totally obscured” [zweryfikowane, Zhou]. Na zrzutach to samo robią tarasy z murkami i schodami (Eastward 01, Mistria 02, Keeper 07).
2. **Budynki w kadrze: 1 duży albo 3-5 małych/średnich**, nigdy sznur identycznych. Różnią się szerokością (5-14 WP), głębokością posadowienia (przesunięcie w pionie ok. 0,5-1,5 WP) i typem dachu (Sun Haven 03, Zomboid 02, Stardew 01) [zrzut, pomiar].
3. **Fasada: ściana jednej kondygnacji ok. 1,3-1,9 WP, drzwi ok. 1,5 WP (1,1-1,75), dach 2-2,5 WP, ścina się w górę ekranu.** Dach zajmuje więcej pionu niż ściana [pomiar, tabela §2].
4. **Wnętrze jest większe niż zewnętrze, ok. 2x w szerokości** (Le Sequoia: fasada ok. 9-10 kafli, sala ok. 18 kafli) i nikt tego nie kwestionuje, bo przejście jest cięciem sceny [pomiar, §3].
5. **Zgodność okien: sprawdzalne dla gracza jest tylko to, co widać obu stronami kamery**, czyli frontowa (południowa) fasada z ulicy. Okna ściany tylnej wnętrza patrzą na północ, której z ulicy nie widać, więc nic im nie przeczy [wniosek, §4]. Zgodne mają być: styl (kształt, szprosy, kolor ramy, mech/śnieg), liczba okien na ścianie frontowej, kolejność od lewej, położenie drzwi w osi X. Liczba okien na ścianie tylnej wnętrza nie musi pasować do niczego z zewnątrz.
6. **Widok za oknem wnętrza (ściana tylna) pokazuje to, co leży na północ od budynku (podwórko, las, tył sąsiada), nie ulicę.** Ulicę widzą tylko okna w ścianie dolnej, których nie rysujemy (patrz `53`: tam jest światło, nie szkło) [wniosek].

## 1. Głębia ulicy bez „budynków jeden za drugim”

Zrzuty i co z nich wynika [zrzut, wniosek]:

| Gra / zrzut | Co robi z głębią |
|---|---|
| **Eastward 01** (miasto) | Trzy tarasy ułożone w pionie: górny rząd sklepów, środkowy chodnik z murkiem, dolny plac. Schody w środku kadru łączą poziomy i są „przejściem za budynek”. Fasady różnej szerokości i różnych głębokości w tym samym rzędzie, w tle ciemny mur (kratki, graffiti) zamiast kolejnego rzędu domów. Słupy elektryczne i siatki to pionowe akcenty, które maskują styk poziomów [zweryfikowane]. |
| **Eastward 05** (obóz nocą) | Przyczepy ustawione pod różnymi kątami do osi, rozmieszczone wokół jednej latarni jako centrum. Skarpa i dół w dolnej połowie zamiast drugiego rzędu [zweryfikowane]. |
| **Fields of Mistria 02** | Rząd domów na wyższym poziomie, pod nim kamienny murek z jednym biegiem schodów, rzeka jako separator, niżej kolejny poziom. Pas przedogródkowy z gankiem i skrzynkami między domem a murkiem [zweryfikowane]. |
| **Sun Haven 03** (zima) | Brukowana ulica pionowo przez kadr z bocznym odejściem (T). Po prawej dwa duże domy z 2 kondygnacjami i wykuszami, po lewej małe szopy i kiosk, każdy o innej szerokości i dachu. Drzewa przed fasadami częściowo je zasłaniają, latarnie co kilka WP, płaty śniegu na bruku. Budynki nie stoją w jednej linii, bo ścieżka wygina się wokół zadrzewień [zweryfikowane]. |
| **Chef RPG 01** | Jeden budynek centralnie, ścieżka z kamienia rozszerza się wachlarzem w dół kadru, drzewa po bokach nachodzą na skraje fasady, dach śnieżny większy niż ściana [zweryfikowane]. |
| **Stardew 01** | Zabudowa w trzech rzędach: stodoła i kurnik lewą kolumną, dom po prawej o inne ok. 0,6 WP wyżej w kadrze. Płot jako granica podwórka, drzwi frontowe i ganek [zweryfikowane]. |
| **Graveyard Keeper 07** | Dach domu pokazany od frontu spoza krawędzi klifu, płot z kołków wokół wybiegu, brukowana droga po lewej [zweryfikowane]. |
| **Project Zomboid 02** (izometria) | Skrzyżowanie z chodnikiem, budynki cofnięte od jezdni o pas chodnika, róg przecięty narożną działką z płotem. Różne materiały i dachy w tym samym kwartale [zweryfikowane]. |

Wnioski [wniosek]:
- **Cztery techniki unikania „budynku za budynkiem”:** (a) poziomy terenu z murkiem i schodami (Eastward, Mistria, Keeper), (b) ścieżka zakręcająca wokół obiektów i skrzyżowanie T (Sun Haven, Zomboid), (c) element wypełniający między budynkami: drzewa, płot, latarnia, skrzynka (wszędzie), (d) różna szerokość i dach (wszędzie).
- **Zasłanianie postaci:** w obu przypadkach, gdzie twórcy opisują zasady (Eastward), cel to „gracz nigdy nie jest niezamierzenie zasłonięty”, więc układ jest zaplanowany tak, żeby ścieżki nie szły ZA wysokimi dachami, a obejścia są po schodach i bokiem [zweryfikowane, Zhou]. Do Poligonu Ulica: pierwszy plan (ulica) niżej niż najwyższy dach, nic poza drzewami i słupami nie wchodzi na ulicę z góry.
- **Zima:** w Sun Haven 03 i Chef RPG 01 śnieg leży na dachach grubymi czapami, na ulicy plamami (ścieżka odśnieżona, bruk widoczny), przy fasadach zaspy. Zasada: **dach jaśniejszy od terenu o 1-2 stopnie, ulica ciemniejsza od zasp**, żeby ścieżka czytała się jako ścieżka [wniosek].

## 2. Wysokość fasad i dachów względem postaci

Pomiar z oka, ±15%, w WP (wysokość postaci). Kolumny: ściana jednej kondygnacji od progu do okapu, drzwi, dach (rzut, od okapu do kalenicy), szerokość całego budynku. [pomiar, zrzut]

| Zrzut | Ściana | Drzwi | Dach | Szerokość | Wysokość kadru w WP |
|---|---|---|---|---|---|
| Chef RPG 01 (Le Sequoia) | 1,35 | 1,75 | ok. 1,5 widocznego, reszta pod czapą śniegu | 4,9 | 7,7 |
| Chef RPG 07 (to samo lato) | 1,2 | 1,6 | 2,5 | 4,5 | 7,7 |
| Stardew 01 (dom) | 1,9 | 1,1 | 2,2 | 4,8 | 9,8 |
| Mistria 02 (dom) | 1,5 | 1,45 | >2 (nie mieści się w kadrze) | >9 | 9,8 |
| Sun Haven 03 (duży dom) | 1,3 parter, 1,2 piętro | 1,55 | >3 | ok. 5 | ok. 11 |
| Eastward 01 | ok. 1,9 parter | ok. 1,9 | brak (widać tylko fasady) | 2,5-4 | ok. 11 |

Wnioski [wniosek]:
- **Przedział, który trzymają gry „przytulne”:** ściana 1,3-1,9 WP, drzwi 1,1-1,75 WP, dach 2-2,5 WP. Dom jest więc nisko, dach go „przykrywa”. To odpowiada Chef RPG: postać chibi, ściana ok. 2-2,5 WP w 54 §TL;DR dotyczyło wnętrza, a fasada jest niższa.
- **Fasada wyższa niż drzwi o 0,3-0,9 WP**; różnica jest oknem, szyldem albo daszkiem. Przy dwóch kondygnacjach (Sun Haven) kondygnacja ok. 1,2-1,3 WP, czyli bardzo ściśnięta, bo i tak dach przesłania górę.
- **Dla postaci realistyczniejszych niż chibi (nasz cel: „mniej infantylnie”)** liczby WP z Chef RPG i Stardew zaniżają wysokość budynku. Rzeczywisty dom ma ściany ok. 2,5 m = 1,5 WP przy postaci 1,7 m, drzwi 2,0 m = 1,2 WP. Stardew (drzwi 1,1 WP, ściana 1,9 WP) jest najbliżej realizmu, Chef RPG (drzwi 1,75 WP) jest „kukiełkowy” [wniosek, zgodne z 54].
- **Ile budynków w kadrze (przy kadrze 8-11 WP wysokości):** 1 duży (Chef RPG 01, Mistria 02 ponad pół szerokości), 3 (Stardew 01), 4-5 częściowych (Sun Haven 03, Eastward 01, Zomboid 02). **Dla Poligonu Ulica:** kadr ok. 9 WP wysokości i ok. 16 WP szerokości zmieści 2 średnie budynki w całości + 1 częściowy na brzegu. Trzy budynki o różnej skali, jak chce ticket, wchodzą w jednej kolumnie ulicy, jeśli jeden jest mały (szopa/kiosk 3 WP), jeden średni (5 WP), jeden duży (9-10 WP) [wniosek].

## 3. „Większy w środku”: proporcje

- **Le Sequoia, Chef RPG, jedyny przypadek, w którym mam oba widoki z tego samego budynku** (zrzut `chef-01` fasada, `chef-04` wnętrze, oba z oficjalnego sklepu) [zweryfikowane]. Fasada ma ok. 680 px na ekranie ×3, czyli ok. 227 px natywnych, czyli ok. **9,4 kafla** (kafel 24 px, 54). Sala wnętrza w `chef-04` ma ok. 1300 px ekranu, czyli ok. 433 px natywnych = **18 kafli** [pomiar]. Wnętrze jest więc **ok. 1,9x szersze** niż zewnętrze. Głębokość wnętrza (od ściany tylnej do dolnej krawędzi kadru) to ok. 850+ px ekranu, czyli ponad 280 px natywnych = **ponad 11 kafli**, nie ma ściany dolnej w kadrze, więc głębokości całkowitej nie znam [pomiar, niepełne].
- **Okno ściany wnętrza jest większe niż okno fasady:** okno `chef-04` ok. 150 px ekranu (50 natywnych), okno fasady `chef-01` ok. 110 px (37 natywnych), czyli ok. **1,35x** [pomiar]. Nie rysują tego jak jednego obiektu, tylko jako ten sam wzór w większej skali.
- **Stardew** (wnętrze `stardew-10` to domek po rozbudowie z dwoma pokojami, więc nie porównuję go z `stardew-01`). Crosley podaje bazową farmę jako „9×5” na zewnątrz i „10×7” w środku [wtórne]; nie sprawdziłem w kodzie gry (wiki zwróciło 403 w `43`).
- **Reguła ogólna, [wtórne]:** „Interiors are bigger than their outsides, on purpose ... Nobody notices, because the fade breaks the spatial comparison” (Crosley, o Pokémon Emerald). Pasuje do Chef RPG i Stardew [wniosek].
- **Proporcja do przyjęcia [wniosek, do sprawdzenia na Poligonie Dom]:** szerokość wnętrza 1,5-2x szerokości fasady, głębokość wnętrza 2-3x tego, ile „głębokości” dachu jest widoczne (dach nie pokazuje głębokości budynku w oblique: widać tylko jego rzut z kątem). Najbezpieczniej: **nie liczyć głębokości budynku z zewnątrz w ogóle**, bo oblique tego nie daje (patrz `54` §1: podłoga w skali 1:1, dach tylko „pokrywa”).

## 4. Okna: zgodność między ulicą a wnętrzem

Co się da sprawdzić z kamery 3/4 (oblique) [wniosek]:

| Ściana | Widać z ulicy | Widać we wnętrzu | Zgodność sprawdzalna? |
|---|---|---|---|
| **Południowa (frontowa)** | fasada z oknami i drzwiami | pas wierzchu u dołu, światło wpadające od dołu (53) | tak: kolejność od lewej i położenie drzwi w osi X |
| **Północna (tylna)** | nie widać | lico z oknami | nie, brak punktu odniesienia |
| **Wschodnia/zachodnia** | cienki pas dachu, ewentualnie wąska krawędź | pas wierzchu, światło z boku (53) | nie |

- **Przykład z Chef RPG:** fasada Le Sequoia ma 2 okna łukowe i drzwi w osi, wnętrze ma 3 okna łukowe + 1 na bocznym skrzydle w ścianie tylnej (`chef-01` vs `chef-04`). Liczba się nie zgadza, ale **styl tak: łuk, szprosy (6 szyb), ceglana czerwień z zieloną listwą, mech** [zweryfikowane]. Wniosek: **gracz nie wyłapuje różnicy w liczbie, jeśli styl jest ten sam** [wniosek].
- **Osie X:** kamera patrzy na północ i na zewnątrz, i we wnętrzu, więc „lewo-prawo” ekranu = zachód-wschód w obu widokach, bez lustra. Drzwi z lewej fasady = drzwi/wyjście po lewej wnętrza [wniosek].
- **Co widać za oknem tylnym:** płaska panorama, bo tylna ściana patrzy na północ (tył budynku, podwórko, las, ewentualnie sąsiad). W Chef RPG oknom tylnej ściany dano zielone, rozmyte tło lasu z plamami nieba (`chef-04`, szyby w odcieniach zieleni), nie ulicę [zweryfikowane]. To pasuje do ich ulicy, bo fasada patrzy na plac, a las jest z tyłu [wniosek].
- **Zima, dzień i noc [wniosek]:** nocą okno fasady świeci ciepło (jak w `eastward-05`, `53`), a okno tylne wnętrza pokazuje ciemny las z odrobiną księżycowego błękitu. Światło z okien wnętrza padające na śnieg rysuje się przy fasadzie południowej, a nie przy północnej, bo tylko tej gracz nie zobaczy z ulicy [wniosek].

## 5. Reguły do przyjęcia (Poligon Ulica i Poligon Dom)

**Poligon Ulica**
1. Ulica pionowo przez kadr z jednym skrzyżowaniem T albo zakrętem. Dwa poziomy terenu (podwyższony chodnik/ogród z murkiem 0,6-0,8 WP i schodami 2-3 kafle), nie trzy rzędy domów [Eastward, Mistria].
2. Trzy budynki: kiosk/szopa (szerokość ok. 3 WP), średni dom (5 WP, drzwi do wejścia), duży budynek (9-10 WP, częściowo poza kadrem). Przesunięcie względem siebie w pionie 0,5-1,5 WP, różne dachy.
3. Fasada: ściana 1,5 WP (Stardew-Mistria), drzwi 1,3-1,5 WP, dach 2-2,5 WP z czapą śniegu. Okno fasady ok. 0,6-0,8 WP wysokości [pomiar, ekstrapolacja].
4. Między budynkami co najmniej jeden element wypełniający (drzewo, płot, zaspa, latarnia, skrzynka), nie goła przerwa.
5. Śnieg: dach jasny, zaspy pod fasadą, ulica odśnieżona i ciemniejsza. Kilka ciemnych okien w fasadzie, reszta ciepła.
6. Drzewa i słupy zasłaniają postać tylko poza główną ścieżką; sprawdzić okluzję przy każdym obejściu.

**Poligon Dom**
1. Szerokość sali 1,5-2x fasady, głębokość nie powiązana z zewnątrzem.
2. Okna ściany tylnej w stylu fasady (ten sam łuk, szprosy, kolor ramy), mogą być 1,3x większe, w liczbie dowolnej, panorama to tył budynku.
3. Wyjście w ścianie dolnej w tej samej osi X co drzwi fasady (±1 kafel). Światło od dołu zgodne z oknami fasady (liczba smug = liczba okien fasady, kolejność od lewej).
4. Widok za oknem: las/podwórko/tył sąsiedniego domu (nie ulica); w nocy ciemny z błękitem.

## 6. Czego nie wiem

- Brak dev-logów twórców o „większy w środku” i o zgodności okien: wszystkie liczby WP i proporcje to moje szacunki z jpg 1920x1080 (±15%), bez narzędzi graficznych [niezweryfikowane].
- Fields of Mistria, Sun Haven, Graveyard Keeper, Zomboid: obejrzałem po 1-3 zrzuty z ok. 8-26; wnętrza tych gier nie sprawdzałem pod kątem okien.
- Stardew: liczby 9×5/10×7 tylko z drugiej ręki (Crosley), niezweryfikowane w kodzie.
- Dane o dalszym otoczeniu miasta (rozmiar planszy, ile ulic) nie były w tym researchu.
- Moonlighter i Pokémon (wnętrza jako osobne mapy) pominięte, bo `43` opisuje wzorzec „jeden pokój na kadr”.
