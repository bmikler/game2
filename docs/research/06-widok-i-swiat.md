> Kopia z game1 (`repo/game1/docs/research/06-widok-i-swiat.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Widok, poruszanie i struktura świata w grach śledczych 2D

Ticket: `docs/wayfinder/tickets/06-widok-i-swiat.md`. Data researchu: 2026-10-27.

## Zastrzeżenie o jakości źródeł

Wyszukiwanie dało mało twardych źródeł pierwotnych. Wiele postmortemów i wywiadów jest za paywallem, za logowaniem (Unreal Engine) albo nie zwróciło treści (PC Gamer o Kentucky Route Zero). Poniżej każde twierdzenie jest oznaczone:

- **[źródło]**: potwierdzone w pobranym tekście (wypowiedź twórców lub ich blog).
- **[wniosek]**: moja interpretacja lub szacunek, nie fakt ze źródła. Szczególnie dotyczy kosztów produkcji: żadne znalezione źródło nie podaje godzin ani budżetu na lokację.

Luki do uzupełnienia, jeśli decyzja będzie od nich zależeć: wywiad Unreal Engine z EggNut o Backbone (wymaga logowania), pełny artykuł PC Gamer o The Zero, wystąpienia GDC o Disco Elysium i Night in the Woods.

## 1. Wzorce widoku i poruszania

### Izometria z malowanym tłem (Disco Elysium)

- Główna scenarzystka Helen Hindpere o Martinaise: zabudowa wygląda „okropnie w realu, ale świetnie w izometrycznym 3D". **[źródło]** https://filmstories.co.uk/?p=83234
- Blog deweloperski ZA/UM (repost) opisuje workflow „render to paintover": kamera ma stały kąt, tła są malowane na renderze geometrii, a wszystko, co animowane, podnoszone lub zależne od pory, dodawane jest w czasie rzeczywistym, nie wmalowane w tło. **[źródło]** https://www.gamebanshee.com/k4fuh
- Wniosek dla nas: stały kąt kamery oznacza, że tło można malować raz, a dynamiczne rzeczy (NPC, przedmioty, światło) nakładać osobno. To pasuje do wymagania „dynamiczne oświetlenie" tylko wtedy, gdy światło działa na warstwie runtime, a nie jest wmalowane. **[wniosek]**
- Koszt: malowane tło o jakości Disco Elysium wymaga wykwalifikowanego artysty. Twórcy zaznaczają, że część lokacji była przeprojektowana po zmianach scenariusza (Tamsalu w filmstories), co sugeruje, że tła są kosztowne do zmiany po fakcie. **[źródło + wniosek]**

### 2.5D pixel art z warstwami (Replaced, Backbone, Thimbleweed Park)

- Replaced: reżyser Yura Zhdanovich mówi o łączeniu różnych podejść do 2.5D pixel artu, inspiracjach Octopath Traveler, Flashback, Another World, Limbo, Inside. Wywiad urywa się przed pytaniem o oświetlenie. **[źródło]** https://gamingbolt.com/replaced-interview-inspirations-for-art-style-ranged-and-melee-combat-exploration-and-more
- Backbone (EggNut): ogólnie opisywany jako side-scrolling noir z 2.5D pixel artem, zrobiony w UE4. Szczegółów technicznych (oświetlenie, wielkość zespołu) nie udało się pobrać. W wywiadzie Unwinnable twórcy opisują Vancouver jako „autentyczną, ale nie niewolniczo realistyczną" wersję miasta, a zespół jako „małe studio" z dedykowanym project managerem. **[źródło]** https://unwinnable.com/2020/05/05/become-a-raccoon-detective-in-backbone-an-interview-with-developer-eggnut/ ; opis UE4: https://www.unrealengine.com/developer-interviews/developer-eggnut-highlights-how-they-created-backbone-s-dystopian-noir-2-5d-pixel-art-style (nie otwarto w całości)
- Thimbleweed Park: wg zapowiedzi do ~11 warstw przewijanych równolegle z subtelnym światłem (recenzent, nie twórca). Ron Gilbert: kamerę „zawsze się stroi przez cały projekt" (blog twórców). **[źródło]** https://blog.thimbleweedpark.com/scrolling_rooms.html ; https://www.gamereactor.eu/thimbleweed-park-preview/
- Wniosek: widok boczny z paralaksą jest najtańszy w ruchu (tylko oś X, proste kolizje) i najlepiej pasuje do referencji Replaced i Octopath. Cena: ograniczona głębia, trudniej pokazać „plac miasteczka" niż w top-down/izometrii. **[wniosek]**

### Widok boczny, miasteczko jako seria ekranów (Night in the Woods)

- Scott Benson o celu: miasto, które „wydaje się zamieszkane". Projekt trwał ok. 3,5 roku od konceptu do premiery, narzędzia: After Effects, Unity, Photoshop, własny open-source'owy Yarn do dialogów. Zespół trzyosobowy (wg Wikipedii/wywiadów). **[źródło]** https://gamedeveloper.com/business/road-to-the-igf-infinite-fall-s-i-night-in-the-woods-i-
- Wniosek: to najbliższy znaleziony precedens „jedno miasteczko jako zbiór ekranów dla małego zespołu", ale 3,5 roku to pełen etat trzech osób. Przy 5–10 h/tydz. skala czasu jest nieporównywalna. **[wniosek]**

### Point&click z rozmowami

- Thimbleweed Park: świat zbudowany z pokoi w stylu SCUMM. Pierwsze rozdziały dają swobodę w centrum miasta, reszta świata otwiera się po zdobyciu mapy (recenzja). **[źródło]** https://www.hardcoregaming101.net/thimbleweed-park/
- Wniosek: sprawdzony model „małe mapy + stopniowe otwieranie" ma naturalne miejsce dla Dni gry i Rutyn NPC. **[wniosek]**

## 2. Struktura świata

### Jeden ciągły świat vs. zamknięty mikrokosmos

- Hindpere: zespół musiał utrzymać centralną lokację w rozsądnych rozmiarach, dlatego wybrano Martinaise. Uważa, że wielkie otwarte światy bywają „puste i powtarzalne", a Martinaise „działa jako mikrokosmos". **[źródło]** https://filmstories.co.uk/?p=83234
- Wniosek: ~10 lokacji to mały zestaw. Ryzyko to nie liczba, tylko odległości: jeśli lokacje są rozrzucone (las, jezioro, bocznica, cegielnia), ciągły świat zmusza do dużo drogi bez treści. **[wniosek]**

### Wnętrza i szablony

- Thimbleweed Park: hotel ze 110 pokojami powstał z jednego szablonu („Pseudo Rooms"). Gilbert: napisanie 110 pokoi ręcznie byłoby „żmudne i nieelastyczne", dodanie funkcji zajęło „około dnia", warianty przez zmianę stanów obiektów. **[źródło]** https://blog.thimbleweedpark.com/pseudorooms.html
- Wniosek: dla gry z ~10 kluczowymi lokacjami nie jest to potrzebne, ale wskazuje wzór: wnętrza (dom Madsenów, posterunek, bar) mogą dzielić szablon układu z wariantami stanów. **[wniosek]**

### Mapa i podróż między lokacjami (Kentucky Route Zero)

- Z dostępnego streszczenia PC Gamer: twórcy najpierw wyobrażali sobie jazdę jako realistyczny widok zza kierownicy, ale to „nie działało tak, jak chcieli", więc zrobili abstrakcyjny tryb mapy. Odrzucona wersja: mapa z puzzli układanych losowo. Nawigacja ma być „rytualna", opierać się na symbolach i punktach orientacyjnych. **[źródło, częściowe]** https://www.pcgamer.com/uk/welcome-to-the-zero-the-making-of-kentucky-route-zeros-open-road (pełnej treści nie udało się pobrać; wypowiedzi Elliotta i Kemenczy przytoczone za wynikiem wyszukiwania)
- Wniosek: jazda autem w zimie jako osobny widok to dodatkowy system. Wariant tani: mapa regionu z wyborem celu, czasem podróży zjadającym czas Dnia gry (łączy się ze Zmęczeniem i Rutynami), krótką sceną/ilustracją drogi i zdarzeniami losowymi w trakcie. Wariant drogi: prowadzone auto jako własny odcinek gry. **[wniosek]**

## 3. Tabela kompromisów (szacunki względne, wniosek)

| Wzorzec | Koszt assetów | Koszt kodu | Pasuje do światła dynamicznego | Ryzyko dla solo deva |
|---|---|---|---|---|
| Widok boczny 2.5D, ekrany-lokacje | średni (warstwy paralaksy) | niski | dobrze (referencje Replaced/Octopath) | niskie, ale ograniczona głębia |
| Izometria, tła malowane na geometrii | wysoki (malarz) | średni | trudniej, dynamika tylko na warstwie runtime | wysokie przy zmianach lokacji |
| Top-down | średni | średni (pathfinding, kolizje) | dobrze | średnie |
| Pokoje point&click | niski-średni | niski | dobrze | niskie, ale mało „świata" |
| Jedno ciągłe miasteczko | bardzo wysoki | wysoki (streaming, mapa) | zależy | wysokie |
| Zestaw lokacji + mapa podróży | średni | niski | dobrze | niskie |

## Rekomendacja

Decyzję podejmuje ticket grilling z człowiekiem. Z researchu wynika, że:

1. Dla solo deva z 5–10 h/tydz. najtańsza i najlepiej poparta precedensami (Thimbleweed Park, Night in the Woods, Disco Elysium jako „mikrokosmos") jest struktura **zestawu osobnych lokacji z mapą wyboru celu**, z czasem podróży wpływającym na zegar Dnia gry i Zmęczenie.
2. Widok boczny z warstwami najlepiej łączy się z referencjami Replaced/Octopath i z dynamicznym światłem. Izometria w stylu Disco Elysium wymaga malarza i jest droga przy zmianach.
3. Jazdę autem w zimie warto rozstrzygnąć osobno: jako ekran mapy ze zdarzeniami (tanio) czy jako prowadzony odcinek (drogo). Kentucky Route Zero jest przykładem, że twórcy sami odrzucili realistyczny widok jazdy na rzecz abstrakcji.
4. Otwarte pytania do grillingu: czy lokacje mają chodzoną drogę między sobą, ile wnętrz ma być osobnymi ekranami, czy widok musi być ten sam we wnętrzach i na zewnątrz.
