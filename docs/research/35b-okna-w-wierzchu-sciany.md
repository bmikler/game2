> Kopia z game1 (`repo/game1/docs/research/35b-okna-w-wierzchu-sciany.md`, stan 2026-11-03). Ścieżki i numery notatek odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Wnioski dla game2 są w `docs/grafika.md`.

# Okna w wierzchu ściany (ściany boczne i przednie) w widoku 3/4

Ticket: 35 (układ posterunku), dopytanie: okno w ścianie bocznej albo przedniej, które widać tylko jako wierzch ściany, czyli pas 6–10 px przy 40 px/m. Data researchu: **2026-10-29**. Wejście: `game1-proto/prototype/lighting/kit/room_shell.gd` (`_window_strip`, `_side_cap`, `_build_caps`), `kit/window_light.gd` (widok za oknem tylnym), `station_layout.gd` (`_side_window`, `_front_window`), zrzuty `shots/cmp/wierzch_6_8_10.png` i `okna_bok1.png`. Wcześniejsze dokumenty: 43 (§5: gry nie rysują okien w ścianach bocznych), 47 (światło okien z różnych ścian), `art/concept/_style/STYLE.md` (paleta). Uwaga człowieka: obecny pas (parapet, malowana rama, ciemnoniebieskie szkło z ukośnymi błyskami, słupek) „wygląda beznadziejnie, za ciemno, w ogóle nie czyta się jako szkło”.

**Źródła.** Twórcy prawie nie piszą o tym w devlogach, więc podstawą są **oficjalne zrzuty ekranu ze Steama** (pobrane przez `store.steampowered.com/api/appdetails`, oglądane w 1920×1080 i w powiększeniu), obraz podglądu moda RimWorld z GitHuba i tutoriale GIF Pedra Medeirosa (saint11). Wiki Prison Architect (fandom) zwróciła 402. Nie znalazłem żadnego tutorialu poświęconego oknom w wierzchu ściany w widoku 3/4.

Oznaczenia: **[zrzut]** = widziałem na oficjalnym zrzucie (link), opis jest moją interpretacją obrazu; **[źródło]** = tekst albo obraz od twórcy; **[z pamięci]** = wiedza ogólna, dziś niesprawdzona; **[wniosek]** = moje rozumowanie albo propozycja.

## Streszczenie i rekomendacja

- **Gry w widoku 3/4 prawie zawsze omijają ten problem.** Okna są tylko w ścianie tylnej (Stardew, Graveyard Keeper, To the Moon, Children of Morta, Chef RPG, Sea of Stars). Moonlighter rysuje okna boczne tylko dlatego, że jego ściany boczne mają pochylone lico (43 §5) [zrzut].
- **Okna w samym przekroju ściany rysują gry z rzutem z góry** (Door Kickers 2, Hotline Miami, Prison Architect, mod RimWorld „Open The Windows”). Wszystkie robią to samo: **wycinają rdzeń ściany, a szkło rysują jako cienką (1–3 px) JASNĄ linię w kolorze nieba** (blady błękit albo cyjan), z jasnymi słupkami ościeża na końcach. Szkło jest jaśniejsze od ściany, nigdy ciemniejsze [zrzut].
- **Szkło w małej skali czyta się dzięki jasności, nie rysunkowi:** okno to dziura w ciemnej ścianie, przez którą widać jasne „na zewnątrz”, plus światło wpadające na podłogę. Ciemne szkło z ukośnymi błyskami to konwencja dla dużej szyby widzianej **od frontu**. W przekroju z góry daje „niebieską listwę” albo „ławkę”.
- **Dlaczego nasz pas nie działa [wniosek, sprawdzone w kodzie]:** (1) szkło ma kolory nocne `547188 → 415d7a`, a okna tylne pokazują za szybą jasny śnieg; (2) pas jest rysowany materiałem `Lit`, więc szkło ciemnieje razem ze ścianą przy świetle wnętrza, a widok za oknem tylnym jest `unshaded` i jasny od luksów zewnętrznych (`view_k`); (3) jasna rama wokół ciemnego wypełnienia czyta się jak listwa albo kaloryfer; (4) ukośne błyski co 23 px wyglądają jak wzór na materiale.
- **Rekomendacja:** pas okna = **jasny parapet od strony pokoju + 3–4 rzędy szkła w kolorach nieba i śniegu (`798e9f → 9fb8d0 → c0cacc`, jaśniejsze na zewnątrz) + jasna rama zewnętrzna + ciemna krawędź zewnętrzna**. Szkło jest osobnym sprite'em **`unshaded`**, ściemnianym tak samo jak widok okna tylnego (`view_k`, warianty dzień, złota godzina, noc). Błysk to 1–2 piksele `eef2f4` przy ościeżu, a nie wzór. Słupki ościeża wystają 1 px poza wierzch na podłogę. Do tego jasna poświata nieba na podłodze tuż przy oknie (już jest w `SideWindowLight`). Przepis piksel po pikselu dla 8 i 10 px jest w §4.
- **Widok na zewnątrz:** wariant tani to płatki śniegu i szron w samym pasie szkła. Wariant odważny to mały **„fartuch” śniegu za ścianą** w czarnej pustce, widoczny tylko przy oknie (§5). Oba warianty warto pokazać na arkuszu porównawczym.

## 1. Co robią gry

| Gra | Rzut | Gdzie okna | Jak wygląda szkło | Rama, parapet | Światło | Pewność |
|---|---|---|---|---|---|---|
| **Door Kickers 2** | z góry, ściana jako pas ok. 12 px z kreskowanym rdzeniem | w każdej ścianie zewnętrznej | **jedna linia 2–3 px jasnego błękitu nieba** na zewnętrznej krawędzi pasa; rdzeń ściany wycięty, przez otwór widać podłogę pokoju | kremowe słupki na końcach, **szersze od ściany** (wystają po obu stronach); od środka zasłona (biały zygzak) | ciepły trapez światła na podłodze od okna | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1239080/ss_ee5c78b8ff009eee72dff4b6b20207caba6ff3aa.1920x1080.jpg) |
| **Hotline Miami** | z góry, ściany jako pas ok. 8 px z kremowym obrysem | ściany wewnętrzne i zewnętrzne (szklane ściany) | **pasek nasyconego jasnego cyjanu z białą linią** w środku pasa ściany; stłuczone szkło to cyjanowe odłamki na podłodze | kremowy obrys jak reszta ściany, poprzeczne słupki co ok. 1 kafel | brak | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/219150/ss_bdf28f59652e53e725d96d94cdc8db97fc277cf2.1920x1080.jpg) |
| **Prison Architect** | z góry | okna 1×1 i 1×2 w ścianach (wiki: także wariant „glass”) [źródło: wyniki wyszukiwania z [wiki](https://prison-architect.fandom.com/wiki/Window), strona zwraca 402] | jasnoniebieska tafla w linii ściany | cienka rama | brak | [z pamięci], na pobranych zrzutach okien nie znalazłem |
| **RimWorld + mod Open The Windows** | z góry | w ścianach | szkła prawie nie widać, okno to **segment ściany z ramą/okiennicami**; czyta się przez podział ściany i światło w pokoju | rama w kolorze materiału ściany | mod liczy światło dzienne przez okno, „10% loss when crossing the glass framings” | [źródło: README](https://github.com/jptrrs/OpenTheWindows), [obraz](https://github.com/jptrrs/OpenTheWindows/raw/master/About/Preview.png). Vanilla bez okien [z pamięci] |
| **Darkwood** | z góry, ciemne cienkie ściany | ściany domów | okno prawie niewidoczne: krótki jaśniejszy, poszarpany odcinek ściany | — | **okno czyta się wyłącznie przez klin światła** na podłodze | [zrzut 1](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/274520/5b6bdd5ebe2f4f0d816aa2e46c26325e88066fab/ss_5b6bdd5ebe2f4f0d816aa2e46c26325e88066fab.1920x1080.jpg), [zrzut 2](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/274520/af1e995c592fb08e2c3ceb785359f1f0f5ff01ef/ss_af1e995c592fb08e2c3ceb785359f1f0f5ff01ef.1920x1080.jpg) |
| **Moonlighter** | 3/4 jako „misa” (wszystkie ściany pochylone) | ściany boczne | **okrągłe okna prawie białe / brzoskwiniowe, ze świecącą aureolą**: najjaśniejszy element kadru, szkło jako źródło światła | rama z krzyżem (słupek i ślemię) | ciepła plama na podłodze obok | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606150/ss_6264f9e73fe2db8a427c5bc3d250123eaef79456.1920x1080.jpg) |
| **Chef RPG** | 3/4 | tylko ściana tylna (łukowe okna z zielonymi ramami) | widok na zewnątrz, jasny | — | — | [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_82871847df216baa534b10b5777cb4606a731d57.1920x1080.jpg) |
| **Stardew, Graveyard Keeper, To the Moon, Children of Morta, Sea of Stars** | 3/4 | tylko ściana tylna; boki i przód to sam wierzch | — | — | Stardew: pionowe smugi pod oknami tylnymi | [zrzut], szczegóły w 43 §1 |
| **Pokémon (Gen 3–5), Earthbound/Mother 3, Undertale/Deltarune** | 3/4 albo ukośny | tylko ściana tylna; w Earthbound ściany boczne mają ukośne lico, które może mieć okna | — | — | — | [z pamięci] |
| **Octopath (HD-2D), Eastward** | 3/4 / 3D | ściana przednia usunięta, okna głównie z tyłu | — | — | poświata i ambient zamiast smug | [z pamięci], na pobranych zrzutach Eastward brak wnętrz z oknami bocznymi |
| **Project Zomboid** | izometria | okna na licach ścian (izometria pokazuje dwie ściany) | jasna tafla; nocą okna z zapalonym światłem świecą na żółto | — | — | [zrzut](https://store.steampowered.com/app/108600/), dla kontrastu; inny rzut |
| **CrossCode, Hyper Light Drifter, Teleglitch, Unrailed** | — | na zrzutach brak okien w ścianach bocznych | — | — | — | [zrzut], nie dotyczy |

**Wspólny mianownik:**
1. W 3/4 okna boczne i przednie się **pomija**. Światło z tych stron pokazuje się na podłodze (43 §5, 47 §5).
2. Gry z rzutu z góry, które **muszą** pokazać okno w przekroju ściany, rysują szkło jako **cienką jasną linię w kolorze nieba**, a ściana wokół jest ciemniejsza (DK2, Hotline Miami). Szkło ma najjaśniejszą wartość w obrębie ściany.
3. Okno identyfikują **słupki ościeża** wystające poza grubość ściany (DK2) albo poprzeczne słupki co kafel (Hotline Miami), a od środka **zasłona** (DK2).
4. Jeśli okno jest za małe, żeby czytać się samo, mówi o nim **światło**: klin na podłodze (Darkwood, DK2) albo aureola (Moonlighter).

## 2. Co sprawia, że szkło w małej skali wygląda jak szkło

- **Wartość, nie kolor.** We wszystkich przykładach szkło jest jaśniejsze od otoczenia. Szkło pokazuje to, co jest za nim (jasne niebo, śnieg) albo odbija niebo. Ciemne szkło działa tylko wtedy, gdy za nim jest ciemne wnętrze, a my widzimy szybę od frontu z zewnątrz (forum PixelJoint: „From the outside, the interiors of buildings usually look quite dark” [źródło: [PixelJoint WIP](https://pixeljoint.com/Forum/forum_posts.asp?TID=25956)]). Nasze okno widzimy od środka, czyli patrzymy na zewnątrz, więc szkło ma być jasne.
- **Przezroczystość pokazuje się przez to, co za szkłem, a nie przez kolor szkła.** Na PixelJoint: przezroczyste szkło w sprite'ach się omija, a zamiast niego rysuje się odbicie zewnętrzne i załamanie [źródło: [PixelJoint](https://pixeljoint.com/forum/printer_friendly_posts.asp?TID=20953)]. Najpierw szkło bez błysków, potem odbicia prawdopodobnego otoczenia; duże błyski są nieliczne i duże [źródło: [PixelJoint WIP](https://pixeljoint.com/Forum/forum_posts.asp?TID=25956)].
- **Błysk to akcent, nie wzór.** Saint11, „Shine”: jeden krótki ukośny błysk przesuwający się raz po pasku albo jedno jasne „okienko” w środku; „you can use only the simple one” [źródło: [Shine.gif](https://saint11.art/img/pixel-tutorials/Shine.gif), lista na [saint11.art](https://saint11.art/blog/pixel-art-tutorials/)]. Saint11, „Ice”: kolejność to bryła, odbicie cienia, obszar światła, **podświetlenie od tyłu** (backlight) na krawędzi dalszej od widza [źródło: [Ice.gif](https://saint11.art/img/pixel-tutorials/Ice.gif)]. U nas krawędzią podświetloną jest zewnętrzna krawędź szkła, od strony nieba.
- **Gradient jasności w poprzek pasa:** ciemniej od strony pokoju, jaśniej od strony zewnętrznej. Oko odczytuje to jako „światło przychodzi z zewnątrz przez szkło” [wniosek, zgodne z „backlight” saint11].
- **Kontekst robi połowę roboty:** ościeże przerywające wierzch, parapet, zasłona albo żaluzja od środka, poświata na podłodze. Przy 8 px nie da się narysować szkła, które czyta się bez kontekstu [wniosek z DK2, Darkwood, Moonlighter].
- **Szkło nie może ciemnieć od świateł wnętrza.** To, co widać przez szybę, jest oświetlone niebem, a nie świetlówką w pokoju. W silniku szkło powinno być `unshaded` i ściemniane luksami zewnętrznymi, tak jak widok okna tylnego [wniosek, zgodne z ADR 0007: jasność z luksów].

## 3. Diagnoza obecnego pasa [zweryfikowane w kodzie]

`RoomShell._window_strip()` dla `cap` = 8: rzędy 0–1 parapet `c0cacc`/`eef2f4`, rząd 2 rama `e6dccb`, rzędy 3–6 szkło `547188 → 415d7a` z ukośnymi błyskami `9fb8d0` co 23 px, rząd 7 rama `a8978e`, słupek 2 px w połowie okien dłuższych niż 1 m. Całość przechodzi przez `_lit(..., Lit.material())`, czyli szkło jest mnożone przez światło wnętrza i dostaje normal mapę `NORMAL_UP`.

| Problem | Skutek na zrzucie `wierzch_6_8_10.png` |
|---|---|
| 4 rzędy ciemnego granatu w środku | szkło ma prawie tę samą wartość co ciemny wierzch, okno czyta się jak wnęka albo listwa |
| `Lit` | w ciemniejszym pokoju szkło ciemnieje dalej; okna tylne w tym samym pokoju pokazują jasny śnieg, więc dwa okna jednej ściany mówią co innego |
| jasna rama dookoła ciemnego wypełnienia | „ramka z wypełnieniem”, czyli ławka, kaloryfer albo tablica |
| ukośne błyski co 23 px | ukośny błysk to konwencja szyby widzianej od frontu; w przekroju z góry daje prążki |
| parapet `c0cacc` i rama `e6dccb` obok siebie | trzy jasne paski bez hierarchii, nic nie jest najjaśniejsze |

## 4. Przepis dla posterunku

Zasada: **jasne szkło (niebo/śnieg) między ciepłym parapetem a ciemną krawędzią zewnętrzną**. Szkło jest najjaśniejszym pasem na wierzchu, z gradientem ku zewnątrz. Rama i parapet zostają `Lit` (biorą światło pokoju i normal mapę). Szkło jest osobną warstwą `unshaded`.

Rząd 0 to strona pokoju (tak jak teraz: przy ścianie bocznej `rotate_90`, przy przedniej pokój jest u góry). Kolory z `palette.hex`. Kolumna „noc” to docelowa barwa po modulacji, a nie osobny asset (§4.3).

### 4.1 Pas 8 px

```
rząd  część                       dzień     złota g.  noc       warstwa
 0    nos parapetu (krawędź)      e6dccb    e6dccb    e6dccb    Lit, NORMAL_SOUTH
 1    blat parapetu               c1b6a3    c1b6a3    c1b6a3    Lit, NORMAL_UP
 2    cień ramy wewn. / listwa    756357    756357    756357    Lit
 3    szkło, strona pokoju        798e9f    a0836f    262e47    unshaded × view_k
 4    szkło                       9fb8d0    d6c09a    415d7a    unshaded × view_k
 5    szkło, strona nieba         c0cacc    f6e7b8    547188    unshaded × view_k
 6    rama zewnętrzna             e6dccb    e6dccb    e6dccb    Lit
 7    krawędź zewn. ściany        1e1a17    1e1a17    1e1a17    jak wierzch
```

```
x:  0 1 2 3 4 5 6 7 8 9 ...                    ... L-2 L-1
 0  P P e e e e e e e e e e e e e e e e e e e e e e P P      P = słupek ościeża (e6dccb / a8978e co drugi px)
 1  P P c c c c c c c c c c c c c c c c c c c c c c P P      e = e6dccb, c = c1b6a3
 2  P P d d d d d d d d d d d d d d d d d d d d d d P P      d = 756357
 3  P P 1 1 1 1 1 1 1 1 1 1 M M 1 1 1 1 1 1 1 1 1 1 P P      1 = 798e9f, M = słupek środkowy (e6dccb/a8978e)
 4  P P 2 2 2 2 2 2 2 2 2 2 M M 2 2 2 2 2 2 2 2 2 2 P P      2 = 9fb8d0
 5  P P * * 3 3 3 3 3 3 3 3 M M * 3 3 3 3 3 3 3 3 3 P P      3 = c0cacc, * = błysk eef2f4
 6  e e e e e e e e e e e e e e e e e e e e e e e e e e
 7  k k k k k k k k k k k k k k k k k k k k k k k k k k      k = 1e1a17
```

- **Słupki ościeża** (2 px, rzędy 0–6) w kolorze ramy. Wystają **1 px poza wierzch do pokoju** (na podłogę), tak jak słupki drzwi bocznych w `_side_cap` (`cap + 4`). To sygnał „otwór w ścianie”, wzięty z DK2.
- **Słupek środkowy** tylko w rzędach szkła (3–5), żeby parapet był ciągły. Tylko przy oknach dłuższych niż 1 m, jak teraz.
- **Błysk:** 2 piksele `eef2f4` w rzędzie 5 (strona nieba), tuż za ościeżem albo słupkiem, **jeden na szybę**. Bez ukośnych pasm.
- **Szron (opcja, zima):** 1 piksel `eef2f4` w rogu szyby w rzędzie 3 przy ościeżu. Mówi „szkło” i „mróz” naraz.

### 4.2 Pas 10 px

```
rząd  część                       dzień     złota g.  noc
 0    nos parapetu                e6dccb    e6dccb    e6dccb    Lit
 1    blat parapetu               c1b6a3    c1b6a3    c1b6a3    Lit
 2    blat parapetu (dalej)       c1b6a3    c1b6a3    c1b6a3    Lit
 3    cień ramy wewn.             756357    756357    756357    Lit
 4    szkło, strona pokoju        798e9f    a0836f    262e47    unshaded
 5    szkło                       9fb8d0    d6c09a    415d7a    unshaded
 6    szkło                       9fb8d0    d6c09a    415d7a    unshaded
 7    szkło, strona nieba         c0cacc    f6e7b8    547188    unshaded
 8    rama zewnętrzna             e6dccb    e6dccb    e6dccb    Lit
 9    krawędź zewn.               1e1a17    1e1a17    1e1a17
```

- Przy 10 px można dodać **podwójną szybę** (norweskie okna są dwu- albo trzyszybowe): rząd 5 albo 6 jako **ramka międzyszybowa** `a8978e` tylko przy słupkach i ościeżach (2 px), a w środku szyby zostawić szkło. Daje to dwie jasne linie szkła i czyta się bardzo „okiennie”. Do sprawdzenia na arkuszu [wniosek].
- Błysk: 2 piksele `eef2f4` w rzędzie 7 plus 1 piksel w rzędzie 6 obok (mały „schodek”), jeden na szybę.

### 4.3 Pora dnia i noc

- Szkło ma tę samą logikę co `WindowLight._build_view()`: trzy warstwy pasa szkła (dzień, złota godzina, noc) albo jedna jasna warstwa modulowana kolorem. Jasność daje `view_k` (luksy nieba × ekspozycja pokoju), a mieszanie `sun.gold` i `sun.night`, tak jak `_outside_*`. Okno boczne i tylne w tym samym pokoju są wtedy zawsze spójne [wniosek, mechanizm zweryfikowany w `window_light.gd`].
- **Noc:** szkło `262e47 → 415d7a → 547188` (śnieg pod księżycem), nadal **jaśniejsze od ciemnego wierzchu**. Jeśli za ścianą stoi latarnia sodowa (jak przy oknie tylnym), dać 1 piksel `e8c27a` jako błysk zamiast `eef2f4`.
- **Odbicie wnętrza nocą (opcja):** gdy w pokoju świeci lampa, rząd szkła od strony pokoju może dostać słabe ciepłe odbicie, np. `Lit` z małym `modulate.a` na samym rzędzie 3/4. To szczegół na później.
- **Żaluzje (opcja, posterunek 2010):** od strony pokoju linia przerywana `c0cacc` 1 px (lamele z góry) na rzędzie parapetu. Opuszczone nocą, zwinięte w dzień. Pełni rolę zasłony z DK2 i jest stanem, który pokazuje porę dnia [wniosek].

### 4.4 Światło przy oknie

- `SideWindowLight` ma już poduszkę nieba (47 §5, wzorzec A). Ważne, żeby **najjaśniejszy pas podłogi leżał tuż przy oknie** (2–6 px od wierzchu) i miał kolor nieba. Wtedy jasne szkło i jasna podłoga tworzą jedną plamę i okno czyta się jak u Moonlightera.
- Nos parapetu (rząd 0) z normalną `NORMAL_SOUTH` złapie tę poduszkę i dostanie jasny brzeg „od okna”.

## 5. Jak pokazać zewnętrze przez okno

| Wariant | Co | Gry | Koszt | Ryzyko |
|---|---|---|---|---|
| **A. Szkło = niebo** (bazowy) | gradient nieba i śniegu w pasie, `unshaded × view_k` | DK2, Hotline Miami (jasna linia), Moonlighter (jasne szkło) | mały: zmiana `_window_strip` + osobny sprite szkła | brak |
| **B. Śnieg w szybie** | 1–2 białe piksele przesuwające się wzdłuż pasa (te same parametry co `_snow` okna tylnego, ale emiter 1 px wysoki, w masce szkła) | nasze okno tylne | mały | migotanie przy zbyt wielu płatkach; 1 płatek na 1 m szkła wystarczy |
| **C. Szron i błysk przesuwany** | szron w rogach (statyczny) i rzadki błysk saint11 przesuwający się po szybie (np. co 20–40 s albo gdy postać przechodzi obok) | saint11 „Shine” | mały | wygląda jak UI, jeśli za często |
| **D. „Fartuch” na zewnątrz** | za ścianą, w czarnej pustce, mała łata śniegu 8–16 px głębokości z zaspą, szerokości okna + 4 px, wygasająca do czerni; nocą oświetlona niebieskim światłem z okna | brak bezpośredniego przykładu w 3/4; najbliżej DK2/Prison Architect, gdzie teren za ścianą jest widoczny | średni: nowy sprite, maska światła na zewnątrz | łamie zasadę „poza bryłą czerń” (43); może wyglądać jak błąd |
| **E. Klin światła na podłodze bez rysowania szkła** | samo światło, pas wierzchu tylko lekko rozjaśniony | Darkwood, Stardew (pod oknami tylnymi) | zrobione (47) | okno nie ma źródła, „lampa w ścianie” (47 §3) |
| **F. Okno na zewnętrznym licu / wykusz** | okno obrócone przodem do kamery albo wystające z bryły | Moonlighter (misa), Earthbound (ukośne lico) [z pamięci] | duży, inny rzut ściany | sprzeczne z rzutem posterunku |

**Polecam A + C (szron, bez animowanego błysku na start) + B tylko przy opadzie śniegu.** D jako jeden wiersz na arkuszu: jeśli zadziała, daje najmocniejsze „to jest okno na mróz”.

## 6. Arkusz porównawczy (do zrobienia w prototypie)

Pomieszczenia: sala (okno boczne we wschodniej ścianie), cela (okno przednie). Pory: 9:00, 12:30 pochmurno, 15:30, niebieska godzina, noc. Kolumny: `cap` 8 i 10.

1. Teraz.
2. Przepis §4 bez szronu, szkło `Lit` (żeby zobaczyć, ile daje samo `unshaded`).
3. Przepis §4, szkło `unshaded × view_k`.
4. Jak 3 + szron + podwójna szyba (tylko 10 px).
5. Jak 3 + fartuch śniegu (wariant D).

Na co patrzeć: czy okno boczne czyta się jako okno **bez podpisu** z odległości całego kadru (960×540 ×2); czy jest spójne z oknem tylnym w tym samym pokoju (ta sama jasność „na zewnątrz”); czy nocą nadal widać szkło, a okno nie zamienia się w czarną dziurę.

## 7. Czego nie zweryfikowano

- Wygląd okien w Prison Architect: wiki zwraca 402, a na pobranych zrzutach nie znalazłem okna w zbliżeniu. Opis jest z pamięci.
- Eastward, Octopath, Pokémon, Earthbound/Mother 3, Undertale/Deltarune, Sea of Stars, Unpacking, LimeZu Modern Interiors, Kenney: nie znalazłem źródła pierwotnego, które pokazuje okno w ścianie bocznej albo przedniej. Strona LimeZu nie wspomina okien. Nie wykluczam, że takie kafle są w paczce.
- Żaden z obejrzanych tutoriali (saint11, PixelJoint, lospec przez wyszukiwarkę) nie mówi wprost o oknie w wierzchu ściany. Wnioski w §2 łączą ogólne zasady szkła z obserwacjami ze zrzutów.
- Przepis z §4 nie był uruchomiony. Kolory po modulacji `view_k` nie będą już dokładnie paletą (tak samo jak widok okna tylnego).

## 8. Przegląd wizualny (zrzuty)

Dopytanie po zrzucie `shots/cmp/okna_wierzch.png`: okno „wygląda trochę dziwnie”. Tym razem oglądałem pobrane obrazy i próbkowałem piksele wzdłuż linii w poprzek ściany. Założenia: wierzch ściany domyślnie 10 px, okna na wszystkich ścianach 1,35 m (54 px), szkło nocą bez kropek lamp. Wycinki: `35b-okna-przyklady.png` (numery niżej).

**Wniosek:** gry, które naprawdę rysują okno w przekroju ściany, dają szkłu tylko 15–33% grubości ściany, jako płaski pas z **ciemnym konturem**. Nasze szkło zajmuje 40% i nie ma konturu od strony ramy, więc czyta się jak jasna listwa w kremowej ramce. Przepis: **2 rzędy szkła w ciemnym konturze i ciemniejszy parapet** (§8.4). Sprawdziłem go tylko na makiecie poza grą.

Wymiary podaję w pikselach zrzutu 1920×1080. To nie są piksele gry, dlatego liczą się proporcje. Kolory są odczytane z JPEG-ów, więc są przybliżone.

### 8.1 Przykłady przydatne (okno w wierzchu ściany)

| Nr | Gra, źródło | Co widać |
|---|---|---|
| 1, 2 | **Door Kickers 2**, [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1239080/ss_ee5c78b8ff009eee72dff4b6b20207caba6ff3aa.1920x1080.jpg) | Ściana ma 20 px: krawędzie `b9a990`, kreskowany rdzeń `5d5956`. W oknie cała ściana jest wycięta. Zostaje **linia szkła 3 px `7ebdff`** (15% grubości), od zewnątrz ciemna kreska `1e303c` (1 px), od środka `738088` (1 px). Linia leży ok. 8 px od zewnętrznej krawędzi. Za nią jest parapet w tonie drewna `72634c → 795944`, ciemniejszy od ramy. Słupki `e6d2c0` mają ok. 10 × 24 px, wystają ok. 2 px poza ścianę **z obu stron**. W szybie nie ma słupka środkowego ani błysku. Od środka bywa zasłona (zygzak w kolorze słupka). |
| 4 | **Door Kickers 2**, [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1239080/ss_517cf841d1ccded40ddb69e908b4f4b87f4e5bc0.1920x1080.jpg) | Ten sam zestaw: wycięcie, niebieski pas, kremowe słupki, zasłona. Tutaj widać też lica ścian, a pas jest wyraźnie szerszy niż na zrzucie 1. Przy żadnym oknie nie ma plamy światła na podłodze. |
| 3 | **Door Kickers 1**, [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/248610/ss_0d8b17c66629848abdbb42fa0de81801ae52d2a6.1920x1080.jpg) | Prawie czarna ściana ok. 11 px z kreskowaniem. Okno to ciemnoszary otwór `2e2f34` z linią szkła 3 px `bdd9ef / 86d0f7 / c5d8e7`, ok. 27% grubości. Bez słupków wystających poza ścianę. Różnica jasności jest bardzo mocna. |
| 5 | **Hotline Miami 2**, [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/274170/ss_6cfa2463e35970d7f58835ed2c699a7df836bf5b.1920x1080.jpg) | **Najbliższy pixel artowi.** Od zewnątrz: rama `d8ccd0` 9 px, czarny kontur 3 px, szkło 9 px (`5dd2ca` od nieba → `09afab` od pokoju), czarny kontur 3 px, parapet `5a5c2d` 9 px, kontur. Razem ok. 33 px przy ścianie ok. 26 px: parapet wchodzi ok. 7 px do pokoju. Szkło to 27% szerokości okna z parapetem, czyli ok. 1/3 grubości ściany. Rama i szkło są ciągłe, tylko parapet dzielą czarne kreski na 3 odcinki. Bez punktowych błysków. |
| 6 | **Hotline Miami**, [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/219150/ss_263387d83df0626c58a484baa8f78f9394074b76.1920x1080.jpg) | Ten sam układ bez ramy: ciemny pas zewnętrzny, kontur, szkło 10 px (`7ab69c` od zewnątrz → `08aa83` od pokoju), kontur, oliwkowy parapet 18 px `655a1c`. Parapet jest ciemny i dwa razy szerszy od szkła, a mimo to okno czyta się dobrze. |
| 7, 8 | **Police Stories**, [zrzut 1](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/539470/ss_86787022ebd629cc911cc7a0b5d8cc62d538f52f.1920x1080.jpg), [zrzut 2](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/539470/ss_0209d4658572ffecdee7630610fed2ffbbbd263b.1920x1080.jpg) | **Ta sama grubość co nasz wariant 12 px.** Jeden piksel gry to 5 px zrzutu, ściana ma 12 pikseli gry: `493f58, 332f4a`, ciemny rdzeń `21152d`, `372c4c, 4c3d5c`. Okno, rzędy symetrycznie: `62537e, 6c5c81, 77648e, 7e719e`, **ciemny `5f5686`, jasne `847fb9` × 2, ciemny `5d5687`**, `7f6f9c, 77658d, 6c5f80, 615175`. Szkło to 2 z 12 rzędów. Końce są równo ze ścianą, bez wystających słupków. Bez błysków. Całość ma fioletowy filtr. **Zastrzeżenie:** to, że to okno, jest moją interpretacją. Takie pasy są tylko na ścianach zewnętrznych, ale gra nie ma podpisu, który by to potwierdzał. |

### 8.2 Przykłady dla kontrastu (okna na licach ścian)

| Nr | Gra, źródło | Co widać |
|---|---|---|
| 10 | **Moonlighter**, [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606150/ss_1ea2e271edeed3d9a78687316f1464050776984d.1920x1080.jpg) | Okno boczne jest rysowane od frontu na pochylonej ścianie: prawie białe szyby, ciemnoróżowy krzyż, jasna aureola na ścianie. To nie jest przekrój, więc tego nie przeniesiemy. |
| 11 | **The Escapists 2**, [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/641990/ss_75c9e0c479c4fb6cc2a40686685ed26d0488f332.1920x1080.jpg) | Rzut najbliższy naszemu: 3/4 z kremowym wierzchem ścian. Okna są tylko na licu tylnym i zewnętrznym licu przednim: beżowa rama, szaroniebieskie szyby, krzyż. **W samym wierzchu ściany okien nie ma.** |
| 9 | **RimWorld + Open The Windows**, [obraz moda](https://github.com/jptrrs/OpenTheWindows/raw/master/About/Preview.png) | Okno to segment ściany z drewna albo szary. Szkła w kolorze nieba nie widać. |
| brak | **LimeZu Modern Interiors**, [GIF](https://img.itch.zone/aW1hZ2UvNjcxNzUxLzQ0NDcxMjMuZ2lm/original/9V3RMY.gif) | Okna tylko na ścianie tylnej, wierzchy boczne i przednie to gładki szaroniebieski pas. Obejrzałem jeden GIF, nie całą paczkę. Godot nie wczytuje GIF-ów, więc nie ma go na arkuszu. |
| brak | **ZERO Sievert**, [zrzut](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1782120/ss_1a8d33591a260af5e18b900319e978c9f9d46380.1920x1080.jpg) | Szklana witryna tylko na licu tylnym, jasne szyby. Wierzchy ścian bez okien. |

### 8.3 Gry bez przydatnego przykładu

- **Prison Architect:** 16 oficjalnych zrzutów w miniaturach, 2 w pełnej rozdzielczości ([1](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/233450/ss_71a9f3d9bbc42df3ed320f6072353be9dd3b65fd.1920x1080.jpg), [2](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/233450/ss_9409f165fe4f7b747e16e84f1c557a37c0bccfc1.1920x1080.jpg)). Nie rozpoznałem żadnego okna.
- **Darkwood:** miniatury i [jeden zrzut w pełnej rozdzielczości](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/274520/af1e995c592fb08e2c3ceb785359f1f0f5ff01ef/ss_af1e995c592fb08e2c3ceb785359f1f0f5ff01ef.1920x1080.jpg). Nie rozpoznałem okna.
- **Tylko miniatury, bez okna w wierzchu ściany:** Teleglitch, Unrailed, Stardew Valley, Eastward (po 6 zrzutów), Streets of Rogue (12), APE OUT (11). W tej skali mógłbym przeoczyć drobne okno. Project Zomboid (6 miniatur) to izometria z licami ścian, inny rzut.
- **Nie obejrzane:** RimWorld bez modów (pobrany, nieotwarty), Modern Exteriors, Cainos, Pixel Frog, OpenGameArt. **Kenney:** pobranie próbek zwróciło 199 bajtów zamiast obrazu.
- **Pora dnia:** nie znalazłem pary zrzutów tej samej sceny w dzień i w nocy, więc o różnicach dzień/noc w tych grach nic nie twierdzę. Noc w przepisie jest naszą decyzją.

**Sprostowania do §1, §2 i streszczenia:**

- **DK2, „ciepły trapez światła z okna”: prawdopodobnie błąd.** Kolorowe kliny mają takie same dithrowane krawędzie jak reszta odsłoniętego obszaru, a na zrzucie DK1 podobny klin zaczyna się wyraźnie przy operatorze. To najpewniej pole widzenia, nie światło. Sam parapet na zrzucie 1 ma ciepłą poświatę, ale jej pochodzenia nie ustaliłem.
- **Darkwood, „okno czyta się przez klin światła”: nie potwierdzam.** Patrz §8.3.
- **„Szkło ma najjaśniejszą wartość w obrębie ściany”: nieprawda w DK2 i HM2.** Rama (`e6d2c0`, `d8ccd0`) jest tam tak jasna jak szkło albo jaśniejsza. Szkło wyróżniają kolor i kontur. U nas najjaśniejsze szkło zostaje, ale jako nasza decyzja, nie reguła z gier.
- **Hotline Miami, „pasek w środku pasa ściany”:** szkło leży bliżej zewnętrznej strony, a od pokoju ma szeroki ciemny parapet.
- **Światło na podłodze nie jest potrzebne do odczytu.** W DK2, HM i Police Stories okno czyta się bez plamy przy oknie. Nie wycofuję naszego światła, bo służy nastrojowi, ale pas musi działać też bez niego.

Przepisy §4.1 i §4.2 zastępuje §8.4 (wierzch 8 px wypada z domyślnych).

### 8.4 Co zmienić w naszym oknie

Porównanie obecnej wersji (cap 10, `_window_parts`) z tym, co zmierzyłem:

| Obecnie | Co widać w grach | Skutek u nas [wniosek] | Zmiana |
|---|---|---|---|
| szkło 4 z 10 rzędów (40%) | 15–33% (DK2 15%, PS 17%, DK1 27%, HM2 ok. 33%) | z góry szkło nie ma powierzchni, więc szeroki pas czyta się jak panel; złota godzina daje dwie żółte świetlówki | **2 rzędy (20%)** |
| brak ciemnej linii między szkłem a ramą zewnętrzną, od pokoju tylko `756357` | ciemny kontur z obu stron (HM, PS), przynajmniej kreska od zewnątrz (DK2) | szkło zlewa się z ramą, całość to „listwa w ramce” | **kontur `2e2a25` wokół szyb** |
| parapet `e6dccb` + `c1b6a3` × 2, najjaśniejszy w pasie | parapet ciemniejszy od ramy (DK2 brąz, HM oliwka) | trzy jasne rzędy od pokoju przyciągają wzrok bardziej niż szkło: półka albo tacka | **nos `c1b6a3`, blat `a0836f`** |
| rama zewnętrzna `e6dccb` | HM2 kremowa, ale za czarnym konturem; PS stonowana | rama zamyka jasny prostokąt | **`a8978e`** |
| słupki 2 px w paski `e6dccb/a8978e`, wystają 1 px tylko do pokoju | DK2: pełny kolor, szerokie, wystają z obu stron; PS i DK1: równo ze ścianą | małe „uszka”, czyta się jak zszywka | **równo ze ścianą, jeden kolor `a8978e`** |
| 3-tonowy gradient, punktowy błysk, szron | płaski pas albo dwa tony, nigdzie punktowych błysków | przy 54 px piksele czytają się jak szum | **dwa płaskie rzędy, jaśniejszy od nieba; bez błysku i szronu** |
| kremowy słupek środkowy 2 px | w szybie brak (DK2, PS, HM2) | dzieli świetlówkę na dwie | **`2e2a25` albo cała szyba, do oceny na arkuszu** |

### 8.5 Przepis, 10 px

Rząd 0 to strona pokoju. Obraz ma dokładnie `cap` rzędów, bez dodatkowego rzędu na uszka.

```
rząd  część                 frame (Lit)      szkło: dzień   złota g.   noc
 0    nos parapetu          c1b6a3
 1    blat parapetu         a0836f
 2    blat parapetu         a0836f
 3    rama wewn.            756357
 4    kontur                2e2a25
 5    szkło, strona pokoju                   9fb8d0         c9a96a     262e47
 6    szkło, strona nieba                    c0cacc         e8c27a     415d7a
 7    kontur                2e2a25
 8    rama zewn.            a8978e
 9    krawędź zewn.         1e1a17
```

### 8.6 Przepis, 12 px

```
rząd  część                 frame (Lit)      szkło: dzień   złota g.   noc
 0    nos parapetu          c1b6a3
 1-3  blat parapetu         a0836f
 4    rama wewn.            756357
 5    kontur                2e2a25
 6    szkło, strona pokoju                   9fb8d0         c9a96a     262e47
 7    szkło, strona nieba                    c0cacc         e8c27a     415d7a
 8    kontur                2e2a25
 9-10 rama zewn.            a8978e
 11   krawędź zewn.         1e1a17
```

Dodatkowy zapas idzie w parapet i ramę, a szkło zostaje na 2 rzędach (17%, jak w Police Stories).

### 8.7 Podział na długości (54 px, oba warianty)

```
x:  0-1    2      3-25      26-27     28-50     51     52-53
    słupek kontur szyba 23  słupek śr. szyba 23  kontur słupek
```

- **Słupki ościeża:** `a8978e`, wszystkie rzędy oprócz ostatniego (krawędź `1e1a17` biegnie przez całą długość).
- **Słupek środkowy:** `2e2a25`, tylko w rzędach szkła. Parapet i rama są ciągłe. Wariant bez słupka: jedna szyba `x = 3..50`.
- **Warstwy bez zmian:** szkło `unshaded` w trzech warstwach, reszta `Lit`.
- **Noc:** bez kropek i błysków, tylko dwa rzędy `262e47 / 415d7a`.

### 8.8 Wariant do porównania: „wycięcie” jak w DK2

Rzędy dla 10 px: `c1b6a3`, `a0836f` × 4, `756357`, `2e2a25`, szkło × 2, `1e1a17`. Szkło leży przy zewnętrznej krawędzi, bez ramy zewnętrznej, co daje najmocniejsze wrażenie otworu. Słupki mogą być jaśniejsze (`e6dccb`) i wystawać 1 px, bo tak działa to w DK2. Na makiecie wypadł dobrze, ale cały jasny parapet zajmuje połowę ściany.

### 8.9 Co jeszcze nie jest sprawdzone

- Przepis oglądałem tylko na makiecie poza grą (płaskie kolory, ściemnianie prostym mnożnikiem), nie w oświetleniu prototypu. Trzeba go ocenić w arkuszu z §6: obecna wersja, §8.5, §8.8, a dla 12 px §8.6, o tych samych porach dnia.
- Zmiana dotyka `_window_parts` i `_top_window`: `h` z `cap + 1` na `cap`, nowe rzędy i normalne, a także pozycja `at`, jeśli liczy się ją z dodatkowym rzędem. Kodu nie zmieniałem.

**Arkusz `35b-okna-przyklady.png`:** 1–2 DK2 (×3, ×4), 3 DK1 (×3), 4 DK2 (×2), 5 HM2 (×3), 6 HM1 (×3), 7–8 Police Stories (×3), 9 RimWorld + mod (×2), 10 Moonlighter (×2), 11 The Escapists 2 (×4). Źródła są w tabelach §8.1 i §8.2.
