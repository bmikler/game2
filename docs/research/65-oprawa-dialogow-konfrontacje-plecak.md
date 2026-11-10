# Oprawa dialogów, scen konfrontacji, plecaka i dziennika (ticket 06)

Data researchu i dostępu do źródeł: **2026-11-08**. Uzupełnia `27b-czcionki-pikselowe.md` (czcionki) i `27c-portrety-w-kolumnie.md` (portret w kolumnie w stylu Disco Elysium) oraz ustalenia game1 (`docs/game1/tickets/27-generowanie-ui.md`: kolumna po prawej, portret 166 px, Ark Pixel 12, jeden portret mówcy). Tego nie powtarzam.

**Jakość źródeł: niska.** Twórcy rzadko opisują oprawę dialogów i prawie nigdy nie podają kosztu. Pobrałem to, co dało się przeczytać; GamesRadar, PC Gamer, GameSpot i GDC Vault zwracały 403 albo ucinały treść. Znaczniki: **[zweryfikowane]** (pobrane i przeczytane źródło pierwotne: blog, wywiad, artykuł twórcy), **[wtórne]** (streszczenie wyszukiwarki, recenzja, nie czytałem całości), **[niezweryfikowane]** (z pamięci, do sprawdzenia na zrzutach lub wideo), **[wniosek]** (moje). Obrazów nie pobierałem (`65-assets/` pusty): zrzuty z baz UI i sklepów są dla narzędzi niedostępne, trzeba je obejrzeć ręcznie.

## Streszczenie

- Trzy rodziny oprawy rozmowy: **kolumna tekstu + mały portret mówcy** (Disco Elysium, Norco), **duże portrety** (Wadjet Eye: Unavowed, Shardlight), **tekst przy postaciach w świecie** (Thimbleweed Park, Pentiment, Kentucky Route Zero). Dla game2 (noir, pixel art 3/4) najtańsza jest kolumna z portretem **plus** scena w tle, w której postacie grają krótkie animacje (łączy to punkty a i b ticketu).
- **Dialogowych scen konfrontacji nie znalazłem w grach z listy.** Najbliższe zweryfikowane źródło to Replaced (ręczna animacja klatka po klatce, ręcznie ustawiane kamery, animacje i dialogi tła przy walce), ale to platformówka akcji. Disco Elysium i Norco prowadzą takie sceny tekstem [niezweryfikowane]. Model dla game2 to **[wniosek]**: węzeł dialogu z „bitem” animacji, stała kamera sceny, trzy tanie narzędzia kamery.
- **Plecak i dziennik:** osobna warstwa 2D, spójna z grą paletą, konturem, czcionką bitmapową i ramkami; koszt kontroluje się liczbą wzorców (9-slice, siatka ikon, jedna czcionka), nie liczbą ekranów.
- **Koszt** (§5): portrety w kolumnie są tanie; największa pozycja to animacje bitów konfrontacji, bo mnożą się przez kierunki i warianty stroju.

## 1. (a) Rozmowa: kolumna, duże portrety, postacie w świecie

| Gra | Wzorzec | Co wiadomo | Status |
|---|---|---|---|
| Disco Elysium | Kolumna tekstu, tekst „wspina się” w górę jak kolumna na Twitterze; sens: ludzie nie czytają dokładnie, łapią główną myśl | 80.lv (Kurvitz): UI rozmowy wzorowane na Twitterze, tekst „tumbles up and is managed as a column text”. O portretach artykuł milczy; ich położenie w `27c` | **[zweryfikowane]** (kolumna); portrety wg 27c |
| Norco | Panele tekstu z lewej lub prawej strony ekranu, wyraźnie wzorowane na Disco | Streszczenie recenzji (Buried Treasure). Wywiad Game Developer (Road to IGF 2023) o prezentacji nic nie mówi: tylko Yarn Spinner, Aseprite, port Phaser→Unity, malarz Jesse Jacobi uczący się pixel artu | **[wtórne]** (wzorzec); **[zweryfikowane]** (narzędzia) |
| Unavowed / Shardlight (Wadjet Eye) | Duże portrety („talking heads”) w rozmowie, rysowane osobno od teł i sprite'ów | Recenzje: portrety ma inny artysta niż tła (tła: Ben Chandler), mała różnorodność min. Game Developer o Shardlight: AGS nie obsługiwał alfa w portretach („pixelly halo”), więc zespół zbudował osobny GUI portretów | **[wtórne]** (recenzje), **[zweryfikowane]** (Shardlight) |
| Thimbleweed Park | Tekst nad głową mówiącego; kolor tekstu i konturu przypisany do aktora (`talkColors(...)`); prędkość tekstu regulowana, czas wyświetlania z liczby słów | Blog Rona Gilberta „UI in Action”. Przy okazji: czcionki TrueType „chcą być gładkie”, co gryzie się z pikselowym wyglądem, więc planuje czcionkę bitmapową | **[zweryfikowane]** |
| Pentiment | Dymki w świecie, osobna czcionka na grupę postaci, tekst pojawia się pociągnięcie po pociągnięciu (maski kresek na glif); literówki w dymkach są elementem fabuły | Streszczenia wywiadów (PC Gamer i inne); art director: zespół za mały na projektanta UI | **[wtórne]** |
| Kentucky Route Zero | Tekst jako część inscenizacji (ujęcia z teatru, „wolne kino”), postacie bardzo uproszczone | Opis GDC 2014 „Scenography of Kentucky Route Zero” (Kemenczy); samego nagrania nie widziałem | **[wtórne]**, szczegóły **[niezweryfikowane]** |
| Citizen Sleeper | Rozmowy jako węzły z kartami i sprawdzianami; autor sam robi 3D i UI; postacie rysuje Guillaume Singelin; Dialogue System for Unity | Game Developer i wywiady | **[zweryfikowane]** (zakres pracy), wygląd UI **[niezweryfikowane]** |
| Signalis | UI diegetyczne i inwentarz w stylu Resident Evil, w niskiej rozdzielczości | Tylko analizy | **[wtórne]** |

Wnioski do game2 **[wniosek]**:
- **Kolumna z portretem (decyzja game1)** pasuje do detektywa, rozmów grupowych i telefonu. Portret mówcy to jeden asset na minę, bez wiązania z animacją świata.
- **Postacie w świecie** (Thimbleweed, Pentiment) to jedyny wzorzec, który uzasadnia animację postaci przy rozmowie. Z Thimbleweed warto wziąć **kolor tekstu i konturu na postać** (drugi kanał obok imienia) i czas wyświetlania liczony ze słów.
- **Duże portrety** (Wadjet Eye) wymagają osobnego procesu, słabo skalują się liczbą min (recenzenci narzekają na małą różnorodność), a w game1 popiersia i tak ustąpiły kolumnie. Zostawić jako opcję dla scen kluczowych.
- Z Pentiment: **czcionka na grupę postaci** to tani sposób na charakter (zero sprite'ów). Przy pikselowych fontach realne (27b ma kilka fontów OFL/CC0), ale ograniczyć do 2–3.

## 2. (b) Sceny konfrontacji jako dialog z animacjami w świecie

**Zweryfikowane.** Jedyne twarde źródło: Xbox Wire o Replaced (14.04.2026). Animacje są „meticulously handcrafted frame-by-frame”; zespół wybrał to zamiast modeli 3D, które w testach wyglądały gorzej i „very noisy”. Finishery mają własny ruch kamery i zmiany oświetlenia. Łączenie walki z fabułą wymagało „unique animations, background dialogue and cinematography”, a przed bossami są negocjacje. Wtórnie: operator Jaime Delmonte projektuje każde ujęcie („not a single camera is done in an automatic way”). Liczb (klatek, kosztu, zespołu) źródło nie podaje.

**Nie znalazłem** opisu dialogowej konfrontacji „wyciągnij broń → animacja → reakcja” w żadnej grze z listy. Disco i Norco prowadzą takie sceny tekstem [niezweryfikowane]; Unavowed ma „special full screen events” (recenzje, [wtórne]). Game2 buduje więc własny wzorzec, nie kopiuje.

**Proponowany model [wniosek]** (do sprawdzenia na Poligonie, nie decyzja):
1. **Węzeł dialogu niesie opcjonalny „bit”**: identyfikator animacji aktora (np. `gracz: wyciaga_bron`, `przeciwnik: unosi_rece`), czas trwania i opcjonalny cel kamery. Tekst w kolumnie czeka na koniec bitu albo biegnie równolegle.
2. **Kamera: trzy tanie narzędzia, bezpieczne dla pikseli.** (i) Stałe ujęcie sceny (domyślnie, zero kosztu). (ii) Najazd o całkowitą skalę (×2) na parę aktorów, bez interpolacji subpikselowej. (iii) Drgnięcie 1–2 px i/lub krótkie przyciemnienie lub letterbox przy strzale. Ujęcia unikalne na scenę (jak w Replaced) są poza budżetem.
3. **Mały, współdzielony zestaw bitów** (§5) zamiast animacji unikalnych dla sceny. Szczekający pies i strzał w powietrze to osobne drobne bity (zgodne z `map.md`).
4. **Wariant najtańszy: dwie pozy** (spokojna i z bronią) z cięciem i błyskiem, bez klatek przejścia; poza z bronią trafia do arkusza w Przepisie postaci.

## 3. (c) Plecak i dziennik spójne z grafiką

| Gra | Wzorzec | Status |
|---|---|---|
| Disco Elysium: Thought Cabinet | „Inwentarz myśli”; sloty rombowe (ograniczenia projektowe); do dopracowania wyglądu zatrudniono osobnego artystę; Kurvitz: funkcja o mało nie zatopiła projektu | **[wtórne]** (AltChar o wywiadzie GameSpot; GameSpot dał 403) |
| Thimbleweed Park | Interfejs czasownikowy i inwentarz na ekranie, kursor w tej samej rozdzielczości co tła, plan czcionki bitmapowej zamiast gładkiej | **[zweryfikowane]** (blog UI in Action); 9 czasowników: VideoGamer **[wtórne]** |
| Citizen Sleeper | UI projektowane przez autora razem z resztą gry, karty i zegary z TTRPG | **[zweryfikowane]** (zakres), wygląd **[niezweryfikowane]** |
| Pentiment | Księgi i notatki w estetyce stron manuskryptu | **[wtórne]** |
| Signalis | Inwentarz w stylu Resident Evil w niskiej rozdzielczości | **[wtórne]** |

Wnioski **[wniosek]**: spójność daje (1) ta sama paleta i kontur co świat, (2) ta sama czcionka bitmapowa (Ark Pixel 12 z 27b; Gilbert z Thimbleweed potwierdza problem gładkich fontów), (3) ramki i tła jako 9-slice z jednego arkusza, (4) ikony Przedmiotów w jednej siatce i rozmiarze (game1: amulet w 32 px tracił wzór, w 48 px działał), (5) tekstura skóry lub papieru spikselizowana tym samym łańcuchem co portrety. Dziennik jako skórzany notatnik z zakładkami (decyzja game1, ticket 37) i plecak jako osobna siatka to osobne warstwy 2D, **bez udziału światła** (zgodnie z game1). Logika poza zakresem mapy; tu tylko wygląd.

## 4. Zgodność portretu ze sprite'em

- W Disco i Norco portret jest ilustracją, a postać w świecie mała i uproszczona; zgodność trzyma się na ubiorze, fryzurze i palecie **[niezweryfikowane]**. W game1 łańcuch (FLUX 3 z referencją → `unfake` → paleta) zachował twarz i ubranie, ale paleta projektu spłaszczała twarze (materiały game1, ticket 27) **[zweryfikowane]** w tych materiałach.
- Dla game2 (bardziej szczegółowe postacie) **[wniosek]**: portret wywodzić z tego samego arkusza postaci lub konceptu co sprite, nie odwrotnie; wariant stroju (kurtka, bez kurtki) dostaje własny portret tylko wtedy, gdy zmienia się sylwetka powyżej ramion; portret z bronią to osobna mina, nie osobny strój.

## 5. Koszt produkcji [wniosek]

Szacunki do sprawdzenia na Poligonie, nie z literatury (żadne źródło nie podaje liczb). Założenia: sprite w widoku 3/4, 4 kierunki (lub 2 + lustro), portret kolumny 166 px.

| Pozycja | Zakres | Uwagi |
|---|---|---|
| Portret w kolumnie | 1 postać × 3–5 min (neutralna, zła, zdziwiona, uśmiech, z bronią) | w game1 jedna generacja ok. 40 s; koszt to selekcja i `unfake`, nie rysowanie |
| Bity konfrontacji, główne postacie | wyciągnij broń 6–8 kl., trzymanie celu 2 kl. (pętla), strzał 3–4 kl. + błysk, reakcja 4 kl., ręce w górę 4 kl. | ok. 20–25 klatek × 1–2 kierunki (bit gra do kamery) × 2 warianty stroju |
| Bity ogólne dla NPC | 3 uniwersalne: zaskoczenie, ręce w górę, cofnięcie | jeden zestaw dla wielu postaci (inne palety i stroje) |
| Zwierzę (pies szczekający) | 4–6 kl. pętla szczeku + idle | jedna postać, dwa kierunki |
| Strzał w powietrze | błysk, kłąb śniegu lub dymu, drgnięcie kamery | efekt kodem, prawie bez klatek postaci |
| UI plecak i dziennik | 1 ramka 9-slice, 1 arkusz ikon, tło księgi, zakładki | koszt jednorazowy, nie rośnie z fabułą |

Zasada: zestaw bitów zamrozić w Przepisie postaci. Każdy nowy bit to klatki × kierunki × warianty.

## Do decyzji człowieka

1. Czy konfrontacje grają animacje bitów w świecie obok kolumny (§2), czy zostaje sam tekst jak w Disco (najtaniej)? Od tego zależy rozmiar zestawu animacji w Przepisie postaci.
2. Czy portret z bronią to osobna mina w tej samej ramce (tanio), czy większy, dynamiczny portret w scenach konfrontacji (drożej, wzór Wadjet Eye).
3. Czy brać z Thimbleweed kolor tekstu na postać jako drugi kanał obok imienia i portretu.

## Źródła

- Xbox Wire, Replaced combat: https://news.xbox.com/en-us/2026/04/14/replaced-combat/ [zweryfikowane]
- 80.lv, Disco Elysium UI: https://80.lv/articles/disco-elysium-working-on-ui-design [zweryfikowane]
- Thimbleweed Park blog, UI in Action: https://blog.thimbleweedpark.com/ui_in_action.html [zweryfikowane]
- Game Developer, Shardlight: https://www.gamedeveloper.com/design/the-making-of-wadjet-eye-s-dystopian-adventure-i-shardlight-i- [zweryfikowane]
- Game Developer, NORCO: https://www.gamedeveloper.com/road-to-igf-2023/-i-norco-i-and-capturing-the-spirit-of-louisiana-through-sci-fi-storytelling [zweryfikowane, tylko narzędzia]
- Game Developer, Citizen Sleeper: https://www.gamedeveloper.com/business/how-citizen-sleeper-was-inspired-by-tabletop-rpgs-and-gig-work [zweryfikowane]
- Game Developer, Unavowed (wywiad z Gilbertem): https://www.gamedeveloper.com/game-platforms/road-to-the-igf-wadjet-eye-games-i-unavowed-i- [nie zawiera oprawy dialogów]
- Wtórne (wyniki wyszukiwarki): PC Gamer o czcionkach Pentiment, AltChar/GameSpot o Thought Cabinet, Buried Treasure o Norco, opis GDC 2014 Kemenczy (KRZ), recenzje Unavowed, VideoGamer o Thimbleweed.
- **Do ręcznego sprawdzenia przed decyzją:** zrzuty Norco, Unavowed, Pentiment, KRZ i konfrontacji w Disco; nagranie GDC 2014 Kemenczy (GDC Vault).
