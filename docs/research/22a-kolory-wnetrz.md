> Kopia z game1 (`repo/game1/docs/research/22a-kolory-wnetrz.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Kolory wnętrz: podłoga, światło pory dnia i struktura palety (pokój socjalny)

Ticket: `docs/wayfinder/tickets/22-pipeline-assetow.md` (pokój socjalny w docelowej grafice, `room.tscn`). Data researchu i dostępu do wszystkich źródeł: **2026-10-28**. Wejście: `art/concept/_style/STYLE.md`, `palette.hex`, concepty `socjal-9002e-9202.png` i `sala-c-8302.png`, stałe świateł z `prototype/lighting/room.gd` (gałąź `prototype/oswietlenie`).

Źródła pierwotne o kolorze w grach okazały się skąpe: wywiady o Disco Elysium, Kentucky Route Zero i Norco mówią o inspiracjach, nie o kolorze podłóg. Dlatego część rekomendacji to **własne pomiary** (jasność i nasycenie w OKLab, kontrast WCAG, symulacja mnożenia przez kolor ambientu tak, jak robi to `CanvasModulate`) oparte na zasadach z kilku źródeł, które dało się sprawdzić (Gurney, Slynyrd, dokumentacja Godot). Gdzie wniosek jest mój, piszę to wprost.

## Streszczenie i rekomendacja

- **Obecna podłoga `7a8181` jest czytelna, ale ma zły odcień.** Jasność jest dobra: OKLab L 0,60, czyli dokładnie między parką (L 0,31) a swetrem (L 0,90), kontrast z parką 3,4:1. Problemem jest temperatura: podłoga to chłodna, szaro-turkusowa plama (odcień ~197°) obok ciepłej brzozy (~81°), a parka też jest chłodna (~270°). W nocy pod świetlówką podłoga i parka lądują w tej samej niebieskiej rodzinie (`6a7f8d` i `212d4d`), więc postać odróżnia się tylko jasnością. Pokój dzieli się też na dwie temperatury: ciepłą górę i zimny dół.
- **Rekomendacja: ciepło-neutralna szarość „greige” o średniej jasności i bardzo niskim nasyceniu.** Podłoga ma być najspokojniejszą dużą płaszczyzną w kadrze. Jasność trzymamy w L 0,55–0,65, a nasycenie w OKLab C ≤ 0,03, czyli niższe niż ściana (0,06). Kandydaci, w kolejności:
  1. **`8a8276` greige (spoza palety, dodać jako nowy neutral).** L 0,61, C 0,02, odcień ~78°, ta sama rodzina co brzoza, ale wyraźnie ciemniejsza (ΔL −0,21 względem `d6c09a`). Kontrast z parką 3,5:1, ze swetrem 2,8:1. Zgodne z epoką szaro-beżowe linoleum lub winyl; wnętrze wygląda jak spójna całość, a postać w granacie jest jedyną chłodną plamą na środku kadru. **Wybór domyślny.**
  2. **`a8978e` (z palety).** L 0,69, najlepszy kontrast z parką (4,8:1), ale słabszy ze swetrem (2,1:1) i blisko ściany (ΔL −0,13). Trzeba wtedy wyraźnie odciąć podłogę ciemną listwą `585b5b`. Ryzyko: jasny beż plus brzoza robi się „przytulny”.
  3. **`6b7466` szaro-zielony (spoza palety).** L 0,55, odcień ~134°. Typowo „gminny”, instytucjonalny kolor, jest w sąsiedztwie sosen z palety (`4b5e50`). Daje trzeci, chłodnawy, ale nie niebieski odcień. Mniej „przytulny” niż beż, ale ciemniejszy, więc kontrast z parką spada (2,8:1).
  4. **`7a8181` zostawić jako punkt odniesienia** albo ocieplić: przesunąć odcień w stronę `7d7a6c` (L 0,58, ~97°).
- **Plamki:** 2 kolory z palety o jeden stopień ciemniej i jaśniej od bazy (dla `8a8276`: `756357` i `a8978e`), gęstość ok. 3–6% pikseli, pojedyncze piksele bez skupisk, bez wzoru, który powtarza się co kafel 32 px. Kontrast plamek mniejszy niż kontrast konturu postaci, inaczej podłoga „szumi” pod sprite'em.
- **Światło (największy problem, ważniejszy od podłogi):** obecne klucze ambientu w `room.gd` gubią czytelność. Noc `(0,05; 0,055; 0,09)` sprowadza wszystko poza zasięgiem lamp do czerni (parka L 0,09, podłoga L 0,13). Zachód `(0,42; 0,28; 0,24)` mnoży granat parki do prawie czarnego brązu `100d11`, a całą resztę do błota. Rekomendacja: **ambient zawsze chłodniejszy i mniej nasycony niż światło kluczowe; ciepło niosą światła (słońce, lampka), nie `CanvasModulate`.** Szczegóły i wartości startowe w §3.
- **Struktura palety pokoju:** ok. 60–70% ciepłe neutrale (ściana, meble, podłoga), 20–30% chłodne (okna, noc, świetlówka, mundury), poniżej 5% akcentów (ciepła lampka, czerwień). Na „przytulność” assetów AI najlepiej działa: niskie nasycenie, mniej dekoracji tekstylnych, prostokątne, użytkowe sprzęty i chłodne światło (§4).

## 1. Kolor podłogi w pixel arcie 3/4 i top-down

### Zasady (źródła)
- **Czytelność daje jasność, nie odcień.** Test: przestawić kadr na skalę szarości i sprawdzić, czy sylwetki się odróżniają. [Wayline, Color and limited palettes](https://www.wayline.io/learn/pixel-art/2) (tutorial, źródło średniej wiarygodności, ale zgodne z innymi).
- **Tło ciszej niż postacie.** Mocno nasycone i zróżnicowane kafle podłogi ściągają wzrok z postaci; rada z krytyki zrzutów RPG Maker: mniej nasycenia i mniejsza rozpiętość kolorów w kaflach podłogi. [rpgmaker.net, Screenshot topic](https://rpgmaker.net/forums/topics/8095/?p=240) (forum, niska wiarygodność, ale powszechna praktyka).
- **Rampy z przesunięciem odcienia, bez skrajnego nasycenia przy dużej jasności.** Jaśniejsze kolory w rampie przesuwają się w stronę ciepłych, przy dużej jasności nasycenie spada, a ciemne kolory przy wysokim nasyceniu robią się „ciężkie”. Autor unika łączenia wysokiej jasności z wysokim nasyceniem. [Slynyrd, Pixelblog 1: Color Palettes](https://www.slynyrd.com/blog/2018/1/10/pixelblog-1-color-palettes)
- **Dalsze obiekty mają mniejszy kontrast.** Zmniejszenie kontrastu elementów tła pomaga odróżnić od nich postacie. [Flowlab community](https://community.flowlab.io/t/what-advice-do-you-have-for-becoming-better-at-pixel-art/34861) (forum).

### Pomiary dla naszej palety (własne)
OKLab L (jasność 0–1), C (nasycenie), h (odcień w stopniach). CR: kontrast WCAG z parką `262e47` i swetrem `e6dccb`.

| Kolor | L | C | h | CR parka | CR sweter | ΔL do ściany `d6c09a` | Uwagi |
|---|---|---|---|---|---|---|---|
| parka `262e47` | 0,31 | 0,05 | 270 | — | — | — | ciemna, chłodna masa postaci |
| sweter `e6dccb` | 0,90 | 0,03 | 81 | — | — | — | jasna plama, ta sama rodzina co ściana |
| ściana `d6c09a` / `c1b6a3` | 0,82 / 0,78 | 0,06 / 0,03 | 81 | | | | |
| **`7a8181` (obecna)** | 0,60 | 0,01 | 197 | 3,38 | 2,93 | −0,22 | dobra jasność, chłodny odcień |
| **`8a8276`** | 0,61 | 0,02 | 78 | 3,54 | 2,79 | −0,21 | rekomendacja |
| **`a8978e`** | 0,69 | 0,02 | 50 | 4,78 | 2,07 | −0,13 | jasna, blisko ściany |
| **`6b7466`** | 0,55 | 0,02 | 134 | 2,76 | 3,58 | −0,27 | szaro-zielona |
| `7d7a6c` | 0,58 | 0,02 | 97 | 3,11 | 3,17 | −0,24 | ocieplona obecna |
| `9a8f80` | 0,66 | 0,03 | 76 | 4,23 | 2,34 | −0,16 | między 1 a 2 |
| `756357` | 0,51 | 0,03 | 56 | 2,35 | 4,20 | −0,30 | za ciemna: „brudna” |
| `585b5b`, `42525d`, `4b5e50` | 0,43–0,47 | | | 1,7–2,0 | | | za ciemne: parka ginie |
| `c1b6a3` | 0,78 | 0,03 | 81 | 6,70 | 1,47 | −0,04 | zlewa się ze ścianą i swetrem |

Wnioski:
- **Postać ma dwie masy, ciemną (parka, jeansy L ~0,3) i jasną (sweter, twarz L ~0,7–0,9).** Podłoga musi siedzieć **pośrodku**, ok. L 0,55–0,65, żeby obie masy się od niej odcinały. Ciemniejsza podłoga zjada parkę, jaśniejsza sweter.
- **Podłoga musi być wyraźnie ciemniejsza od ściany** (ΔL ≥ ~0,15), inaczej w widoku 3/4 nie widać, gdzie kończy się ściana. Jasna listwa przypodłogowa tego nie załatwi; ciemna `585b5b` (jak teraz) pomaga.
- **Typowe błędy:** nasycona albo wzorzysta podłoga (szachownica, wyraźne kafle) konkuruje z postacią; podłoga w tej samej jasności co ubranie postaci; plamki o wysokim kontraście, które przy 1 px wyglądają jak szum; zbyt jasna, prawie biała podłoga (pod światłem zachodu i lampy wypala się w płaską plamę).
- **Czy niebiesko-szara podłoga obok brzozy i granatowej parki to problem?** Dla czytelności nie (ΔL 0,29 to dużo). Problem jest kompozycyjny: (a) największa płaszczyzna w kadrze jest jedynym chłodnym obszarem wnętrza, więc oko czyta pokój jako „zimny dół, ciepła góra”; (b) granat parki wtapia się odcieniem w podłogę, zamiast być **jedyną** chłodną plamą na ciepłym tle; (c) nocą pod świetlówką (`0,82; 0,93; 1,0`) wszystko staje się niebieskie, a podłoga zlewa się z cieniem i oknami. Ciepło-neutralna podłoga zostawia chłód oknom, nocy i postaci.

## 2. Podłogi i ściany w skandynawskich budynkach publicznych 1980–2010

Co udało się potwierdzić:
- **Linoleum dominowało w Norwegii ok. 100 lat od lat 60. XIX wieku**, potem wyparły je winyl i wykładziny. Jedyna norweska fabryka (Victoria Linoleumsfabrikk, Sandvika) zamknęła się w 1968 r. [lokalhistoriewiki.no](https://lokalhistoriewiki.no/wiki/Victoria_Linoleumsfabrikk)
- **Winyl (PVC) w rolach był regulowany w norweskich przepisach budowlanych od 1967 r.**, a w 1982 r. zastąpiła je norma NS 3860 (spawalne wykładziny PVC). [Rundskriv H-22/82, regjeringen.no](https://cms12.regjeringen.no/contentassets/20503ddfe0664fac9e2185c1a6c80716/rundskriv_h_22_82_jnr_278_82bb_sept_1982.pdf)
- **Homogeniczny winyl powstał w Ronneby w Szwecji (dziś Tarkett)** ok. 50 lat temu i jest używany „w szkołach, miejscach pracy, szpitalach”. Seria Granit ma drobny, bezkierunkowy, nakrapiany wzór przechodzący przez całą grubość. [Tarkett UK: iQ Granit & iQ Eminent, making history](https://professionals.tarkett.co.uk/en_GB/node/iq-granit-iq-eminent-making-history-15614), [Jacobsen (dystrybutor), iQ Granit](https://jacobsen.co.nz/commercial/vinyl/smooth/iq-granit/). Daty na stronach Tarketta są niespójne (1947 vs. 1950); to materiał marketingowy.
- **Linoleum dalej kładzie się w suchych pomieszczeniach szkół, szpitali i biur**, a winyl ma mniejszą porowatość i lepiej znosi wilgoć. [Bygg og Bevar, Linoleum gulvbelegg (PDF)](https://byggogbevar.no/media/12831/gulvbelegg-linoleum-egenskaper.pdf), [IFI](https://www.ifi.no/kan-vi-pusse-opp-et-slitt-belegg)
- **W szwedzkiej architekturze lat 70.** kolor przeszedł od mocnych barw podstawowych i szarego betonu do jaśniejszej, zniuansowanej palety (róż, żółć) pod koniec dekady (dotyczy głównie elewacji i ścian). Mari Ferring, *Den levande väggen: Färg och arkitektur i svenskt 1970-tal*, KTH ([avhandlingar.se](https://www.avhandlingar.se/om/1970-tal/)).

Czego nie udało się potwierdzić źródłem (moja wiedza ogólna, do sprawdzenia na zdjęciach):
- Typowe dla instytucji z lat 80.–2000 w Norwegii są **nakrapiane wykładziny winylowe lub linoleum w kolorach szarym, szaro-beżowym, piaskowym i szaro-zielonym**, łączone listwą w ciemniejszym kolorze lub cokołem z wywiniętej wykładziny. Lastryko i lastrykopodobny winyl pojawiają się raczej w holach i na klatkach schodowych. Ściany: malowane na złamaną biel lub jasne, olejowane panele sosnowe albo brzozowe (świerk, sosna częściej niż brzoza). Wszystkie trzy kandydatki z §1 (greige, piaskowy beż, szaro-zielony) mieszczą się w tym repertuarze. Niebiesko-szara też, ale rzadziej spotyka się ją razem z jasnym drewnem.
- Dokumenty ochrony Riksantikvaren dla posterunków (np. [Nyrud politistasjon](https://riksantikvaren.no/content/uploads/2019/10/25nyrudpolitistasjon.pdf), [Politihøgskolen](https://riksantikvaren.no/content/uploads/2019/10/6politih25c325b8gskolen252coslo.pdf)) mogą opisywać materiały wnętrz, ale są skanami bez warstwy tekstowej i nie dało się ich odczytać (brak `pdftoppm`). **Warto, żeby człowiek je przejrzał**, bo to najlepsze pierwotne źródło o norweskim posterunku.

## 3. Pora dnia: `CanvasModulate` plus kolorowe światła

Jak to działa w Godot: `CanvasModulate` ustawia bazowy kolor ambientu i przyciemnia całą scenę, a światła 2D (`PointLight2D`, tryb Add) go dodają. Po włączeniu normal map światła wydają się słabsze; dokumentacja zaleca podnieść `height` i trochę `energy`. [Godot docs, 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html). Ambient to **mnożenie**: kolor piksela × kolor ambientu. Mocno zabarwiony ambient zjada kolory dopełniające (niebieski × pomarańczowy = brąz lub czerń).

Zasady z malarstwa (Gurney):
- O złotej godzinie, przy słońcu za plecami, oświetlone płaszczyzny są złote, a cienie **względnie niebieskawe**. [Gurney Journey, The Golden Hour](http://gurneyjourney.blogspot.com/2008/01/golden-hour.html)
- Zachód: kolory jaśnieją i nasycają się w stronę słońca, odcień przechodzi pasmami od bladej żółci do czerwono-pomarańczowego, a **ciemne elementy pierwszego planu nie są czarne: zachowują swój kolor**. [Gurney Journey, Three Tips for Painting a Sunset](http://gurneyjourney.blogspot.com/2016/12/three-tips-for-painting-sunset.html)
- Ciepło i chłód to „pierwszy krok od studium walorowego do koloru”. Jeśli walory są dobre, scena jest spójna. [Gurney Journey, How to Apply the Warm-and-Cool Approach](http://gurneyjourney.blogspot.com/2018/06/how-to-apply-warm-and-cool-approach.html). Gurney ostrzega też przed sztywną regułą „ciepłe światło, zimne cienie”: odbite ciepłe światło potrafi ocieplić cień. [Relative color temperature on skin tones](http://gurneyjourney.blogspot.com/2017/07/relative-color-temperature-on-skin-tones.html)
- Pixel art: jaśniejsze tony przesuwamy ku żółci, ciemniejsze ku błękitowi, a przy dużej jasności zmniejszamy nasycenie. [Slynyrd](https://www.slynyrd.com/blog/2018/1/10/pixelblog-1-color-palettes); podobna reguła w artykule o paletach na [OpenGameArt](https://opengameart.org/node/5493).

Symulacja na stałych z `room.gd` (własna, mnożenie albedo × ambient, bez świateł):

| Ambient | Parka | Sweter | Podłoga `8a8276` | Ściana | Wniosek |
|---|---|---|---|---|---|
| zachód obecny `(0,42; 0,28; 0,24)` | `100d11` L 0,16 | `613e31` | `3a241c` | `5a3625` | wszystko brązowe, parka czarna: „błoto” |
| zachód alternatywa `(0,40; 0,38; 0,46)` | `0f1121` L 0,19 | `5c545d` | `373136` | `564947` | chłodny cień, granat zostaje granatem; ciepło dokłada smuga słońca |
| noc obecna `(0,05; 0,055; 0,09)` | `020306` L 0,09 | `0c0c12` | `07070b` | `0b0b0e` | poza lampami czerń, ΔL podłoga–parka 0,04 |
| noc alternatywa `(0,14; 0,16; 0,24)` | `050711` L 0,13 | `202331` | `13151c` L 0,20 | `1e1f25` | ciemno, ale sylwetka i kształt pokoju czytelne |

Praktyczne reguły:
1. **Ambient ma niskie nasycenie i jest chłodniejszy niż światło kluczowe.** Kolor pory dnia niesie światło kierunkowe (smuga z okna, lampka), a nie mnożnik całej sceny. Dla zachodu i wschodu ambient lekko fioletowo-szary, słońce `(1,0; 0,6; 0,35)` jak teraz, z wyższą `energy` w smudze.
2. **Noc nie jest czarna.** Ambient nocny ok. L 0,13–0,20 dla średnich tonów (np. `(0,14; 0,16; 0,24)`, do strojenia). Czerń zostaje tylko w pustce poza pokojem. Trzy poziomy jasności: plamy światła, ciemny półmrok pokoju, czarne tło.
3. **Każda pora ma jedno dominujące źródło i jedną temperaturę;** drugie źródło jest kontrapunktem (noc: zimna świetlówka plus jedna ciepła lampka; zachód: ciepła smuga plus chłodny ambient). Dwa równorzędne, mocno kolorowe światła dają szarość tam, gdzie się mieszają.
4. **Test w skali szarości dla każdej pory dnia** (zrzuty z `room.tscn`): postać musi odróżniać się od podłogi bez koloru. Ewentualnie słaba poświata wokół gracza (mała `PointLight2D` o niskiej `energy`, jak „światło oczu”) albo kontur oświetlany (prototyp: `outline_lit.gdshader`).
5. **Nasycenie świateł umiarkowane.** Pomarańcz o pełnym nasyceniu × beżowa ściana daje pomarańczową ścianę, która zaczyna wyglądać „przytulnie” i świątecznie (STYLE.md tego zabrania). Lepiej `(1,0; 0,75; 0,5)` z większą `energy` niż `(1,0; 0,5; 0,28)`.
6. **Okna jako najjaśniejszy element tylko w dzień;** nocą najjaśniejsza jest świetlówka i jej plama na podłodze. Wtedy podłoga o średniej jasności ładnie „łapie” stożek światła. Tego nie da podłoga ciemna.

## 4. Struktura palety wnętrza w tym nastroju

Wnioski własne (na podstawie STYLE.md, conceptów i zasad z §1 i §3; brak pierwotnego źródła opisującego proporcje w Disco Elysium czy Kentucky Route Zero: wywiady mówią tylko o „zrównoważeniu zwyczajnego z obcym i dziwnym”, [MCV/Develop, The Art of Disco Elysium, 2021](https://www.mcvuk.com/business-news/we-knew-immediately-that-we-needed-to-make-a-game-with-a-striking-and-unique-look-to-accompany-the-writing-a-look-that-would-balance-the-mundane-with-the-unfamiliar-and-strange-the-art)):

- **Proporcje (albedo, przed światłem):** ok. 60–70% ciepłe, ale zgaszone neutrale (brzoza `d6c09a`/`c1b6a3`, meble, podłoga greige), 20–30% chłodne (okna, sprzęt, mundury, cienie, `415d7a`–`9fb8d0`), do 5% akcentów (lampka `e8c27a`, czerwień `7a2e2a` na gaśnicy, kubku albo dachu za oknem). Światło odwraca te proporcje nocą: wtedy dominuje chłód, a ciepło zostaje akcentem.
- **Jeden akcent na pomieszczenie**, nie trzy. W conceptcie socjalu narzuta w czerwono-niebieskie norweskie wzory jest najmocniejszym kolorem kadru. To dobry „ludzki” detal, ale w pixel arcie trzeba zgasić jej nasycenie o stopień, żeby nie była ważniejsza od postaci.
- **Jak uniknąć „przytulności” assetów AI (Pixellab ma tendencję do jasnych, nasyconych, zaokrąglonych mebli: zob. postęp ticketu 22):**
  - Kwantyzacja do palety bez ditheringu (już w STYLE.md). Rozważyć **obcięcie najjaśniejszego i najbardziej nasyconego tonu rampy w meblach**: meble nie powinny być jaśniejsze od ściany.
  - W promptach: „institutional”, „municipal office”, „worn laminate”, „plain”, „utilitarian”, „rectangular”. Unikać słów „cozy”, „cute”, „warm”, „rustic”, „hygge” (w Pixellab: jako negatyw, jeśli przyjmuje).
  - Mniej tekstyliów, roślin i dekoracji; więcej przedmiotów pracy (segregatory, czajnik elektryczny, CRT, tablica korkowa z ogłoszeniami związków zawodowych). Bałagan w szczegółach, nie w kolorze.
  - Kontur z ciemnego koloru z palety (już w STYLE.md) i **lekko twardsze krawędzie** przy prostokątnych meblach; zaokrąglenia czytają się jak zabawka.
  - Chłodna świetlówka jako światło domyślne wnętrza nawet za dnia (słabsza): to ona „urzędowo” odbiera ciepło brzozie.
- **Podłoga w tej strukturze** jest „ciszą”: ciepło-neutralna, średnia jasność, najniższe nasycenie w kadrze. Ściany są ciepłe i jasne, postać to ciemny chłód z jasnym akcentem, okno to chłód z kolorem.

## 5. Proponowane kroki (nie wykonane, decyzja człowieka)
1. Podmienić `FLOOR` w `room.gd` na `8a8276` (i warianty `a8978e`, `6b7466`), zrobić zrzuty dla 4 presetów pory dnia, plus wersje w skali szarości.
2. Zmienić klucze `AMBIENT` dla zachodu, wschodu i nocy według §3 i porównać z obecnymi.
3. Jeśli greige zostanie, dodać `8a8276` do `palette.hex` (np. w miejsce `7a8181` albo jako 33. kolor) i dopisać do STYLE.md.

## 6. Niezweryfikowane
- Typowe kolory i wzory podłóg w norweskich posterunkach i pokojach socjalnych z lat 80.–2000: brak pierwotnego źródła (zdjęć, katalogów Tarkett/Forbo z epoki). §2 w tej części to wiedza ogólna. Dokumenty Riksantikvaren (skany PDF) nieprzeczytane.
- Proporcje ciepło/zimno i akcentów w Disco Elysium, Kentucky Route Zero, Pentiment, Norco, Eastward i Octopath: nie znalazłem wywiadu ani posłowia z konkretami o kolorze (GDC 2014 Kemenczy „Scenography of KRZ” i *The Art of NORCO* niesprawdzone). Rekomendacje z §4 są moje.
- Wartości ambientu w §3 to symulacja mnożenia bez świateł i normal map; w grze trzeba je dostroić na zrzutach.
- Pomiary OKLab i WCAG liczone skryptem Node na kolorach z palety, nie na wyrenderowanych zrzutach. Kontrast WCAG dotyczy tekstu i jest tu tylko przybliżeniem czytelności sylwetki.
- Źródła pixel-artowe poza Slynyrd (Wayline, fora RPG Maker i Flowlab, OpenGameArt) to tutoriale i fora: zgodne ze sobą, ale nie autorytatywne.
