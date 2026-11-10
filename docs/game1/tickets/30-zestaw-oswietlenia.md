---
id: 30
title: Zestaw oświetlenia pomieszczeń i plenerów
labels: [wayfinder:prototype]
status: closed
assignee: bmikler
blocked_by: [19, 22]
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/30-zestaw-oswietlenia.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Jak zamienić oświetlenie pokoju socjalnego z prototypu (`game1-proto/prototype/lighting/room.gd`, zasada „klimat ponad realizmem”) w zestaw klocków wielokrotnego użytku? Nowe pomieszczenie posterunku albo plener ma wymagać rozstawienia okien i lamp i co najwyżej drobnego strojenia profilu, a nie osobnej sesji. Przy okazji: ile to kosztuje na posterunku z ~10–15 pomieszczeniami i korytarzem?

Wejście:
- research `docs/research/22a-kolory-wnetrz.md`, `22b-uklad-pokoju-socjalnego.md`, `22c-gra-swiatla.md`, `22d-balans-swiatla-i-skalowanie.md` (reguła ekspozycji, koszt, plan zestawu w §5);
- prototyp `room.tscn` (`run_room.bat`): plama słońca w kształcie okna, smugi, kurz, światło nieba, odbicie, AO, cień pod postacią, rim, jarzeniówki, światło z korytarza, latarnia; zaakceptowany przez człowieka jako kierunek.

Do zrobienia na próbce (w prototypie):
1. **Reguła ekspozycji z 22d** zamiast obecnego gaszenia poświaty okna porą dnia: wartości w luksach, adaptacja z pokoju gracza, wolniejsze przejście przy ściemnianiu; sprawdzić `Environment.tonemap_exposure` w `BG_CANVAS`.
2. **Wydajność:** przeliczanie tylko przy zmianie godziny, bez alokacji co klatkę; nakładka z czasem CPU/GPU i tryb `--bench`.
3. **Wydzielenie zestawu:** profil pory dnia (Resource z krzywymi), `WindowLight` (prostokąt okna, azymut ściany), `LightFixture` + `FixtureDef`, profil pomieszczenia, dyrektor światła (ekspozycja, włączanie pomieszczeń), przydział masek świateł.
4. **Dowód skalowania:** drugie pomieszczenie (np. korytarz + gabinet) złożone z klocków, przejście między nimi bez szwów; pomiar kosztu.
5. **Plener** tylko szkicem decyzji (słońce/księżyc, latarnie, cienie budynków, śnieg), budowa poza tym ticketem.

Kryteria: nowe pomieszczenie składa się z klocków bez nowego kodu; człowiek akceptuje wygląd pokoju po zmianie reguły; koszt zmierzony, nie szacowany. Nie łamać kierunku zaakceptowanego w Pipeline assetów (ticket 22).

Znane drobiazgi do poprawki: `post.gdshader` ma na sztywno 640×360 w rozmyciu; nocny kolor nieba w `SKY_COL` za jasny.

## Resolution

Zestaw oświetlenia działa i jest skalibrowany w `game1-proto/prototype/lighting/kit/` (`run_station_kit.bat`):
- **Klocki:** pomieszczenie składa się z klocków bez nowego kodu (`RoomShell`, `Prop`, `WindowLight`, `LightFixture` + `FixtureDef`, `RoomLighting` + profil, `LightingDirector`, `TimeOfDayProfile`).
- **Ekspozycja:** jedna reguła ekspozycji na przestrzeń, bez adaptacji oka (energia = lux × X / 250, X = (250 / L)^0,3).
- **Materiał i maski:** jeden materiał `Lit`, maski 12 bitów, postać należy do jednego pomieszczenia naraz.
- **Gamma:** naprawiona; sprite'y z Pixellab przy X = 1 wychodzą na ekran 1:1.
- **Wygląd:** w dzień bez świetlówek, wieczorem ciepłe lampy według harmonogramu, słońce 8:15–16:45, ciemne tło nocy.
- **Koszt:** cały posterunek (15 pomieszczeń) ok. 0,6 ms na klatkę.

Kalibrację (widok za oknem, ekran, rim, post-process P2) wybrał człowiek z arkuszy w `shots/cmp/`. Plener jest tylko szkicem decyzji (krok 5): osobna scena z `DirectionalLight2D` i ambientem nieba, bez adaptacji na progu, rzutowane cienie budynków, noc z latarniami (księżyc tylko na tle nieba, bez światła na scenę), okna fasad z własnym harmonogramem, jeden profil pory dnia i stała Pogoda z Nadpisaniem pogody w `GameState`, bez poświaty gracza. Sprite'y lamp powstaną przy budowie posterunku. Szczegóły w sekcjach postępu poniżej.

## Postęp (2026-10-28)

Kroki 1–2 zrobione w `room.gd`, gałąź `prototype/oswietlenie` w `game1-proto` (commity `e0b9055`, `02ed5c8`, bez pusha). Następna sesja zaczyna od kroku 3.

**Krok 1, reguła ekspozycji (zaakceptowana przez człowieka):**
- Każde źródło ma luksy, a energia światła to luksy × ekspozycja jego przestrzeni × `K` typu. Ekspozycja `X = clamp((250 / L)^0,7; 0,25; 8)`, gdzie `L` to suma luksów przestrzeni + `FLOOR_LUX`. Stałe i `K` są w nagłówku `room.gd`, `K_FLUO = 0,004` (o 30% słabiej niż kalibracja z 22d, na prośbę człowieka).
- **Adaptacja oka odpadła.** Wersja, w której ekspozycja szła za graczem (z wygładzaniem asymetrycznym), dawała miganie na progu drzwi, a pokój jaśniał po wyjściu gracza na korytarz. Teraz każda przestrzeń (pokój, korytarz) ma stałą ekspozycję ze swojego światła, niezależną od gracza. Wyróżnienie pomieszczenia gracza trafiło na mapę jako możliwy dodatek.
- Poświata okna gaśnie sama przy zapalonych jarzeniówkach (z ~0,6 do 0,08). Ręczne gaszenie porą dnia usunięte.
- Fizyczne niebo w nocy (~1 lx) gasiło okno całkiem, więc poduszka nieba ma nastrojowe minimum `NIGHT_SKY_LUX = 1000`. W zestawie ma to być krzywa w profilu pory dnia.
- Ambient (`CanvasModulate`) liczony z pokoju, ton nieba odsycony (`TINT_SAT`), słońce wchodzi do ambientu w 30%. Jeden `CanvasModulate` na scenę nie wystarczy dla wielu pomieszczeń: zestaw potrzebuje ambientu na pomieszczenie.
- Obrazy za oknem skalowane `(X / X_obrazu)^0,35` z minimum 0,6. Nocny `SKY_COL` przyciemniony. Rozmycie w `post.gdshader` zależy od rozdzielczości.
- **`Environment.tonemap_exposure` działa na 2D przy `BG_CANVAS`** (0,5 → ~0,6 średniej jasności). Obraz HDR 2D jest liniowy, więc zmiany ambientu działają mocniej, niż sugerują liczby.
- Zrzuty: `shots/kit_before/`, `shots/kit_after/` (`-- --shots=<katalog>`, 11 ujęć z wypisanymi wartościami).

**Krok 2, wydajność:**
- Przeliczanie świateł tylko przy zmianie minuty gry albo trybu jarzeniówek. Co klatkę liczy się tylko rim. HUD pokazuje GPU i CPU renderu, czas skryptu, przeliczenia/s i FPS.
- `-- --bench` → `shots/bench.csv`. Wyniki na RTX 4060 Laptop, jeden pokój o 8:15: GPU 0,42 ms (p95 0,43), CPU renderu 0,15–0,17 ms, skrypt 0,014 ms (przy przeliczaniu co klatkę 0,08 ms). Glow to ~0,25 ms z 0,42 ms GPU. Normal mapy są w szumie pomiaru.
- Pomiar dla 1, 4 i 15 pokoi przeniesiony do kroku 4 (wymaga pokoi z klocków).

**Do kroku 3:** zestaw musi mieć ekspozycję i ambient na pomieszczenie (bez adaptacji), nocne minimum nieba w profilu pory dnia, przeliczanie przy zmianie czasu. Do decyzji: `tonemap_exposure` jako globalny mnożnik czy mnożenie w skrypcie. Przy ekspozycji na pomieszczenie globalny mnożnik pasuje tylko wtedy, gdy na ekranie jest jedno pomieszczenie.

**Krok 3, wydzielenie zestawu (2026-10-28, zaakceptowany, `game1-proto` commit `35d96f1`):**
- Zestaw w `game1-proto/prototype/lighting/kit/`, dane w `kit/data/*.tres`: `TimeOfDayProfile` (krzywa zachmurzenia, gradienty nieba i ambientu, nocne minimum nieba `night_sky_lux`) → `SunSample`, `FixtureDef` + `LightFixture`, `WindowLight` (widok za oknem ze śniegiem, plama, smugi, kurz, odbicie, ościeża, poduszka nieba, sód, test rim), `RoomLightingProfile` + `RoomLighting` (ekspozycja i ambient pomieszczenia), `LightingDirector` (zegar w dół, włączanie pomieszczeń według widoku, maska i rim aktora), `LightMasks`, `Exposure`, `LightTextures`. `room.gd` rysuje już tylko geometrię, a światło składa z klocków.
- **Decyzje:** ekspozycja jest mnożona w skrypcie na pomieszczenie, `tonemap_exposure` zostaje 1. `CanvasModulate` jest czarny, a ambient to płaskie światło na pomieszczenie (osobno dla podłóg i postaci, osobno dla brył). Poziom światła pomieszczenia to Σ(lux × poziom × footprint opraw) i Σ strumień okien (na m² szyby), podzielone przez powierzchnię podłogi. Dodanie oprawy rozjaśnia więc pokój bez strojenia, a kalibracja daje dokładnie liczby z kroku 1.
- **Maski:** bit na parę (slot koloru 0–3, odbiorca podłoga/bryła/postać), czyli 12 bitów + kurz. To prostsze niż schemat z 22d §3.5: każdy element nosi jeden rodzaj, światło sumę rodzajów. Próg drzwi ma bity obu pomieszczeń, a postać dostaje bit pomieszczenia, w którym stoi (w progu oba).
- **Fakty z pomiaru:** (1) kolor `CanvasModulate` jest przy HDR 2D linearyzowany, a kolor światła 2D nie, więc ambient-światło dostaje `srgb_to_linear()`. Bez tego wychodził ok. 4× jaśniejszy. (2) Światło ambientu przechodzi przez normal mapy (N·L ≈ normal.z), więc kompensacja wynosi 1,12 dla podłóg i 1,6 dla brył. (3) **Postacie:** silnik czyta teksturę światła tam, gdzie piksel jest narysowany (`LIGHT_VERTEX` zmienia tylko kierunek N·L). Postać narysowana do 2 m nad stopami przy tylnej ścianie wychodziła poza plamy lamp przed nią i była czarna na tle oświetlonej ściany (błąd był już w kroku 2). Rozwiązanie: `ActorLight`, czyli bliźniak każdego światła, które oświetla postacie (świetlówki, korytarz, poduszka nieba, odbicie), tylko z maską postaci, sięgający 80 px wyżej. Energia: zob. niżej. Bez bliźniaka zostaje przelew z drzwi (`actor_twin = false`), który wypalał twarz. Postać łapie światła pomieszczeń w zasięgu `actor_reach` = 2 m od stóp, więc w progu nie traci naraz lamp pokoju. Ambient sięga 80 px nad podłogę. Oświetlanie postaci w rzędzie stóp przez `LIGHT_VERTEX` odpadło: spłaszczało postać i nie działało na tekstury. (4) Rim próbkuje 3 wysokości × 3 punkty na szerokość ciała (±25 cm), więc cienki cień słupka okna nie gasi całej postaci. Energia rimu idzie w `energy`, nie w kolor (jak w kroku 2).
- **Wynik:** pokój socjalny i Badacz zgodni z krokiem 2 (zestawienie `shots/cmp/porownanie.png`) (średnia luminancja podłogi ±0,005, ścian ±0,015, Badacz ±0,01). Korytarz ma teraz własny ambient z lamp (`art_ambient_share = 0,6`): w dzień jest ciemniejszy niż wcześniej (wtedy dostawał dzienny ambient pokoju), w nocy trochę jaśniejszy i stały przez całą dobę. Zrzuty: `shots/kit_step3/`.
- **Widok za oknem przy lampach** słabiej przyciemniany niż w kroku 1: `view_exposure_power` 0,2 i `view_min` 0,8 (było 0,35 i 0,6), wybór człowieka z `shots/cmp/okno_warianty.png` (wiersz 2).
- **Postać z normal mapami** jak w kroku 2: bliźniaki `ActorLight` stoją w miejscu źródła (w górę przesuwa się tylko tekstura, kierunek N·L bez zmian), energia ×0,75, a materiał `kit/actor.gdshader` pomija N·L dla ambientu (płaski jak dawny `CanvasModulate`). Środek pokoju: jasność/szczegół 0,33/0,137 w nocy, jak w kroku 2.
- **Koszt** (`--bench`, 8:15): GPU 0,42 ms (bez zmian), CPU renderu 0,12 ms, skrypt 0,016 ms. Dwa światła ambientu i bliźniaki postaci (+8 świateł) mieszczą się w szumie pomiaru.
- Jasność Badacza na trasie pokój → próg → korytarz (22:00, lampy): 0,17 / 0,25 / 0,27 / 0,26 / 0,28 (krok 2: 0,11 / 0,27 / 0,22 / 0,21 / 0,27). Klatki chodu na południe (`krogg_walk_front_*`) mają kolor o ~12% jaśniejszy niż `krogg_idle_front` (0,32 wobec 0,289): to błąd assetu, nie oświetlenia.
- Import projektu (potrzebny do `class_name`) wygenerował pliki `.import` i `.uid` w prototypie. Nie są w gicie.

**Krok 4, dowód skalowania (2026-10-28, zaakceptowany):**
- Dwa ogólne klocki geometrii napisane raz: `RoomShell` (podłoga, tylna ściana z otworami wyciętymi pod jej `WindowLight`, ściany boczne i próg z drzwiami, cienie kontaktowe) i `Prop` (mebel z PNG, blokada ruchu, cień). Pomieszczenia to sceny: `rooms/break_room.tscn`, `rooms/office.tscn`, `rooms/corridor.tscn`, złożone w `station_kit.tscn` (`run_station_kit.bat`). `station_kit.gd` nie zna żadnego pomieszczenia, wszystko znajduje w scenie.
- **Pokój socjalny ze sceny = pokój z kodu z kroku 3:** różnice średnich luminancji 0,000–0,005 (śnieg i kurz są losowe).
- **Gabinet bez nowego kodu:** 4,0 × 4,4 m, okno 1,2 m z jednym słupkiem, ściana malowana, biurko z Pixellab, dwie świetlówki (przy jednej był wyraźnie ciemniejszy niż pokój socjalny), lampka biurkowa (`kit/data/desk_lamp.tres`) i zawsze włączony niebieski monitor (`kit/data/monitor.tres`). Biurko ma `Prop.base_y = 13`: stoi na nogach, a nie na kółkach wysuniętego krzesła (cień i sortowanie z postacią). Własna plama słońca i smugi z własnego okna, slot maski 2. Korytarz jest dłuższy (16 m), z trzecią świetlówką przy gabinecie.
- **Przejścia bez szwów:** Badacz na trasie gabinet → próg → korytarz → próg → pokój socjalny (22:00, lampy): 0,24 / 0,31 / 0,36–0,40 / 0,32 / 0,28, bez spadków na progach. Przy zgaszonych lampach: 0,07 → 0,39 (świetlówka korytarza) → 0,15.
- **Koszt** (`-- --bench`, `shots/bench_kit.csv`, kopie pokoju socjalnego w siatce, zegar 1 h / 2 s, RTX 4060 Laptop):

  | Pokoje | Aktywne | Światła | GPU ms (p95) | CPU renderu ms (p95) | Skrypt ms |
  |---|---|---|---|---|---|
  | 1 | wszystkie | 20 | 0,39 (0,42) | 0,12 (0,16) | 0,017 |
  | 4 | wszystkie | 80 | 0,38 (0,38) | 0,15 (0,20) | 0,022 |
  | 4 | widoczne | 40 | 0,38 (0,38) | 0,16 (0,22) | 0,020 |
  | 15 | wszystkie | 300 | 0,40 (0,40) | 0,24 (0,28) | 0,038 |
  | 15 | widoczne | 80 | 0,40 (0,40) | 0,22 (0,31) | 0,026 |

  GPU nie zależy od liczby pomieszczeń: silnik odrzuca światła poza ekranem testem prostokąta, a limit 256 świateł na render dotyczy tylko widocznych. CPU renderu rośnie z ~0,12 do ~0,24 ms przy 15 pokojach. Wyłączanie pomieszczeń poza widokiem daje mało, ale trzyma liczbę świateł na ekranie daleko od limitu. Cały posterunek mieści się w budżecie z dużym zapasem (ok. 0,6 ms na klatkę przy 16,7 ms).
- **Słońce krócej** (decyzja człowieka): plama i smugi od ok. 8:15 do 16:45, `sun_delay_h` = `sun_early_h` = 0,5 h w profilu pory dnia. Nocne minimum nieba (1000 lx) działa tylko przy zgaszonych lampach, zostaje.
- Pomieszczenia są ustawiane w scenie ręcznie (pozycje, sloty masek 0–3, sąsiad za progiem). Okna tylko na tylnej ścianie.

**Do kroku 5 (z oceny człowieka):** „wszystko wygląda super, dopóki nie włączymy świateł”. Świetlówki dają płaskie światło z sufitu, a ekspozycja zjada kontrast. Kierunek: w dzień bez świetlówek, w nocy delikatne źródła punktowe, świetlówki tylko na zdarzenie (włącznik). Następna sesja: 2–3 zestawy nocnych lamp dla pokoju socjalnego i gabinetu do wyboru.

**Po kroku 4, nocne lampy zamiast świetlówek (2026-10-28, decyzja człowieka, bez commita):**
- Wybrany zestaw A „ciepłe kąty” z `shots/cmp/lampy_zestawy.png`. Świetlówki usunięte ze wszystkich pomieszczeń poza korytarzem. Pokój socjalny: lampa stojąca przy kanapie i kinkiet przy lodówce. Gabinet: lampka biurkowa i monitor. Harmonogram `kit/data/evening_lamps.tres`: lampy od 16:20–16:50 do 8:40–9:10, czyli zgaszone dopiero, gdy wejdzie słońce.
- Biurko w gabinecie przy tylnej ścianie, okno przesunięte w lewo, żeby monitor nie nachodził na plamę słońca.
- Monitor: włączony ekran bez Pixellab (`assets/pixellab/desk_screen.png` ze skryptu, `Prop.glow_image`, rysowany unshaded ×1,6), światło kierunkowe w nowym kształcie `LightTextures.Shape.SCREEN` (klin od ekranu w stronę, w którą patrzy ekran), mocniejsze (80 lx, k 0,009).
- Postać należy do jednego pomieszczenia naraz (granica w połowie ściany progu, `LightingDirector.threshold_px`). Wcześniej łapała lampy sąsiedniego pomieszczenia przez ścianę (dół pokoju przy zgaszonych świetlówkach, głowa przy górnej ścianie korytarza) i sumowała oba pomieszczenia w progu. Przelew z drzwi nie oświetla już postaci.
- Lampy nie mają jeszcze sprite'ów (widać tylko światło): kinkiet, lampa stojąca, lampka biurkowa do zrobienia w Pixellab z `glow_image` na żarówki.

**Błąd gamma i przegląd zestawu (2026-10-29):**
- **Źródło „brzydszej postaci”:** `SubViewport` z `use_hdr_2d` renderuje w przestrzeni liniowej, a jego tekstura szła na ekran bez konwersji do sRGB. Każdy kolor był pokazywany podniesiony do potęgi 2,2 (kurtka Badacza 0,16 → 0,02, koszula 0,87 → 0,72). Dotyczyło to całego obrazu od pierwszego prototypu oświetlenia. Poprawka: `display_srgb.gdshader` na `TextureRect` widoku, zrzuty przez `img_save_srgb()` (`game1-proto` commit `832dfef`). Ekran pokazuje teraz assety 1:1, porównanie etapów w `shots/cmp/postac_etapy.png`.
- **Skutek:** wszystkie wartości świateł, ambientu i post-processu były strojone pod za ciemny obraz. Po poprawce obraz jest wyprany (`shots/station_kit_srgb/`). Decyzja człowieka: zostaje architektura zestawu i decyzje o wyglądzie (zestaw A, brak świetlówek poza korytarzem, słońce 8:15–16:45), liczby i łatki wyprowadzamy od nowa.
- **Ten sam błąd** mają starsze prototypy w `game1-proto` (`main.gd`, `station.gd`, `res_compare.gd`, `room.gd`). Zrzuty z tamtych ticketów (19, 22, 25, 29) były oglądane z za ciemną gammą.

**Lista do sprzątania (następna sesja, przed kalibracją):**
1. **Post-process po konwersji:** `post.gdshader` działa w przestrzeni liniowej, więc „podniesione czernie” (+0,012) i ziarno (±0,0175) wychodzą po konwersji kilkukrotnie silniejsze (czarne tło jest niebieskoszare i zaszumione). Przenieść gradację, winietę i ziarno do etapu wyświetlania, po `to_srgb`.
2. **Jeden materiał „lit” dla wszystkich oświetlanych sprite'ów** (podłogi, ściany, meble, postacie): ambient pomija N·L (jak dziś `kit/actor.gdshader`). Wtedy wystarczy jedno światło ambientu na pomieszczenie zamiast dwóch i znikają kompensaty `ambient_comp_floor` 1,12 i `ambient_comp_solid` 1,6.
3. **Ambient bez łatek:** usunąć `srgb_to_linear()` dodane, żeby udawać dawny `CanvasModulate`. Poziom ambientu liczyć wprost w przestrzeni liniowej.
4. **`ActorLight`:** przesunięcie bliźniaka działa inaczej, niż zakładał kod (`offset` światła nie jest skalowany przez `texture_scale`), a `ENERGY` 0,75 dobrano na oko pod złą gammę. Wyprowadzić od nowa: przesunięcie −`HEIGHT_PX`/2 w pikselach ekranu, energia 1, potem kalibracja.
5. **Stałe:** `K_*` w `window_light.gd`, `k` w `kit/data/*.tres`, `k_ambient`, `Exposure.KNEE` i stałe ekspozycji. Kalibrować od zera; rozważyć tonemapper Godota zamiast ręcznego kolana (wymaga sprawdzenia z konwersją sRGB).
6. **Widok za oknem:** reguła `view_k` (`view_exposure_power`, `view_min`, `x_img`) i `night_sky_lux` stroiliśmy pod ciemny obraz. Wyprowadzić od nowa. Drobny błąd: `_snow.modulate = … * view_k` skaluje też alfę śniegu.
7. **Martwe elementy:** `LightFixture.wash` (myło ścianę tylko dla świetlówek, których w pokojach już nie ma), `kit/data/fluorescent.tres`, `office_lamps.tres`, `pendant.tres` (nieużywane), `room.gd` / `room.tscn` / `run_room.bat` (stary uruchamiacz z kroku 3, dubluje `station_kit.gd`). Usunąć albo oznaczyć.
8. **`Prop.glow_energy`** (1,6) i rim (×1,4 energii słońca): sprawdzić po poprawce gammy.

**Sprzątanie zrobione (2026-10-29, `game1-proto`, bez commita):** punkty 1–4 i 7 oraz błąd alfy śniegu z punktu 6. Punkty 5, 6 (reguła widoku za oknem) i 8 to strojenie liczb, przechodzą do kalibracji.
- **Post-process** w `kit/display.gdshader`: zawinięcie, rozmycie i aberracja czytają liniowy widok, potem konwersja do sRGB, a gradacja, ziarno (jedno na piksel bazy), odbarwienie, winieta i powieki działają po niej. Etap wyświetlania to osobny, zwykły `SubViewport` 960×540, więc zrzuty `--shots` zawierają post-process w rozdzielczości bazowej. Czarne tło jest znów czarne. `display_srgb.gdshader` usunięty. `post.gdshader` został tylko dla starych prototypów (`main.gd`, `station.gd`), które nadal mają błąd gammy.
- **Jeden materiał `Lit`** (`kit/lit.gd` + `kit/lit.gdshader`, dawny `actor.gdshader`) na podłogach, ścianach, meblach i postaci, wspólny obiekt materiału. Jedno światło ambientu na pomieszczenie z maską `LightMasks.ALL`. Kompensaty `ambient_comp_*` i `srgb_to_linear()` usunięte. Energia ambientu to teraz wprost poziom liniowy.
- **`ActorLight`:** przesunięcie bliźniaka wynosi −`HEIGHT_PX`/2 na ekranie (offset dzielony przez skalę węzła), energia 1, stała `ENERGY` usunięta.
- **Usunięte:** `LightFixture.wash` i `FixtureDef.wash_scale`, `fluorescent.tres`, `office_lamps.tres`, `pendant.tres`, `room.gd`, `room.tscn`, `run_room.bat`.
- **Wynik:** zrzuty `shots/cleanup/`. Ambient jest teraz wyraźnie za jasny (obraz wyprany), bo `k_ambient` był strojony pod linearyzowany kolor. To pierwsza rzecz do kalibracji.
- **Koszt** (`--bench`, z przebiegiem wyświetlania): GPU 0,48–0,52 ms (p95 do 0,81), CPU renderu 0,14–0,26 ms, skrypt 0,018–0,035 ms. Pokój ma 13 świateł zamiast 20. Dodatkowe ~0,1 ms GPU to przebieg wyświetlania.

**Kalibracja (2026-10-29, `game1-proto` commity `a817f2f`, `6d7633a`, `8c15032`, `dd19d46`):**
- `calib.tscn` mierzy tor obrazu i kształty świateł (`shots/calib/`). Sprite'y z Pixellab pod białym światłem 1,0 (materiał `Lit`) wychodzą na ekran **1:1** (różnica 0/255 dla Badacza, kanapy, lodówki, biurka i tablicy). Szczyt kształtów na białej podłodze przy energii 1 wynosi 0,89–1,0 (`peaks.csv`, w kodzie jako `LightTextures.PEAK_FLOOR`).
- **Jedna reguła zamiast stałych `K`:** energia = lux × X / (250 × szczyt kształtu) (`Exposure.energy`), ambient = lux × X / 250. Powierzchnia pod 250 lx przy X = 1 pokazuje kolor z Pixellab. Dawne `K_SKY`, `K_SUN`, `K_STREET`, `k` opraw i `k_ambient` usunięte. Nastrój ustawia się teraz tylko luksami. Latarnia: `street_lux` to luksy na podłodze, bez DF.
- Dawne `K` nie normalizowały kształtów, tylko podbijały nastrój (np. latarnia ×18, przelew z drzwi ×7,5, niebo ×0,2 względem reguły).
- **Problem:** przy poprawnej gammie noc ledwo różni się od dnia (podłoga 0,5 w nocy, 0,6 w dzień), bo α = 0,7 dobierano pod ciemny obraz. Arkusz `shots/cmp/kalibracja_alfa.png`: stare liczby i reguła przy α 0,7 / 0,5 / 0,3 (`station_kit -- --alpha=`). **Wybór człowieka: α 0,3** (domyślne w `RoomLightingProfile`).
- **Noc** (`shots/cmp/kalibracja_noc.png`, wybór człowieka: N1, „ciemne tło”): `night_sky_lux` 1000 → 150 (poduszka pod oknem nocą ~12 lx zamiast 80), `floor_lux` 9 → 3, `art_ambient_share` 0,3 → 0,1. Lampy bez zmian (mniejsze plamy i lampy 1,5× odrzucone).
- **Korytarz** nocą wyraźnie za jasny (świetlówka 120 lx zawsze włączona, 60% w ambiencie). Warianty w `shots/cmp/kalibracja_korytarz.png`. **Wybór (K2):** udział lamp w ambiencie 10% jak w pokojach (`corridor.tres` bez nadpisania), świetlówki zostają 120 lx (K3 z 80 lx wyglądał prawie tak samo).
- **Słońce, wschód i zachód** (`shots/cmp/kalibracja_zachod.png`, wybór Z3): zachód z nową regułą był blady i szary, bo plama ustawia ekspozycję pokoju, a jej 30% wracało jako różowoszary ambient. Teraz `sun_ambient_share` 0,3 → 0,1, ciepły ambient o zachodzie (gradient `ambient` w `norway_feb.tres` przy 16:18: (0,95; 0,62; 0,42)), bardziej nasycone słońce: wieczór (1; 0,45; 0,18), rano (1; 0,55; 0,38).
- **Jasność plamy** (`shots/cmp/kalibracja_plama.png`, wybór P1): plama jest zawsze na kolanie, więc wygląd ustala kolano, nie luksy. Słońce ma własne kolano `TimeOfDayProfile.sun_knee` = 1,0 (maks. energia 2, było 1,5 i maks. 3). Plama zachowuje kolor zachodu i fakturę podłogi, smugi zostają widoczne (zależą od energii plamy, tak jak kurz i rim).
- **Błąd smug:** smugi (dodawane wielokąty bez światła) nie miały granic i wieczorem wychodziły za lewą ścianę gabinetu. Teraz `WindowLight` przycina je do tylnej ściany i podłogi pomieszczenia (`setup(slot, interior)`, kolor interpolowany na cięciu).
- **Lampy wieczorne** (`shots/cmp/kalibracja_lampy.png`, wybór L3): wielkość i jasność plam bez zmian. Cieplejsze żarówki: lampa stojąca (1; 0,6; 0,3), kinkiet (1; 0,64; 0,34), lampka biurkowa (1; 0,7; 0,42). Lampy o połowę niżej (35 / 30 / 25 px), więc normal mapy mocniej rzeźbią meble i postać. Monitor 250 → 120 lx: niebieski klin jest akcentem, a nie główną plamą gabinetu.
- Zostało do kalibracji: widok za oknem (`view_k`, `night_sky_lux` w szybie), `Prop.glow_energy` i rim, post-process.
- Narzędzie do arkuszy: `sheet.gd` (`--script`, wiersze = katalogi zrzutów, kolumny = ujęcia).

**Stan na koniec sesji 2026-10-29 (następna sesja zaczyna tutaj):**
- Przyjęte i w kodzie: punkt bieli i jedna reguła energii, α 0,3, ciemne tło nocy (N1), korytarz K2, słońce Z3, kolano plamy P1, przycinanie smug, lampy wieczorne L3. `run_station_kit.bat` pokazuje ten stan.
- **Następny krok: widok za oknem.** Reguła `view_k` w `WindowLight.apply()` (`view_exposure_power` 0,2, `view_min` 0,8, `x_img` z `Exposure.X_MAX`) była strojona pod złą gammę i pod α 0,7. Przy α 0,3 ekspozycja nocą to ~1,9 zamiast ~3,8, więc `x_img` (do 8 nocą) trzeba wyprowadzić od nowa. Sprawdzić szybę w dzień, o zmierzchu przy zapalonych lampach i nocą. Potem `Prop.glow_energy` (1,6) i rim (×1,4 energii plamy), na końcu post-process (gradacja, ziarno, winieta w `kit/display.gdshader`).
- Sposób pracy: warianty jako kopie plików z `kit/` w katalogu tymczasowym, zrzuty `station_kit.tscn -- --shots=<katalog>`, arkusz `sheet.gd`, po wyborze człowieka zmiana na stałe i commit. Katalogi zrzutów wariantów nie są w gicie, tylko arkusze w `shots/cmp/`.
- Ekran monitora (`desk_screen.png`) przycięty do kolumny 64: zakrywał jedyną kolumnę prawej ramki w `desk.png` (66). Ramki mają teraz po 2 px.
- Lampy nadal bez sprite'ów (kinkiet, lampa stojąca, lampka biurkowa do zrobienia w Pixellab z `glow_image`).

**Widok za oknem (2026-10-29, `game1-proto` commit `a97fbac`):**
- Stara reguła (`x_img`, `view_exposure_power` 0,2, `view_min` 0,8) nocą i o zmierzchu zawsze trafiała w minimum 0,8, a w dzień dawała ~1,05 plus ręczne mnożniki (×1,3 dzień, ×1,15 noc).
- **Nowa reguła:** jasność widoku = min((`sky_lux` × X / `view_ref_lux`)^`view_power`, `view_max`), jedna dla obrazu dziennego, złotego i nocnego (obrazy wybierają tylko treść). Noc korzysta z istniejącego `night_sky_lux` (150 lx), bez osobnej łatki. Śnieg ma tę samą jasność. `station_kit -- --view=p,ref,max` do arkuszy.
- Arkusze `shots/cmp/kalibracja_okno.png` (W1 p 0,2 / W2 p 0,3 / W3 p 0,3 przy 600 lx) i `kalibracja_okno_dzien.png` (limit 1,4–2,0). **Wybór człowieka: W3 z limitem 1,4** (`view_power` 0,3, `view_ref_lux` 600, `view_max` 1,4): dzień ~1,4 (limit), zachód ~1,4, nocą ~0,8 (ciemniejsza szyba, zgodna z N1). Limit 2,0 przepalał śnieg i dawał poświatę.
- O 17:00 przy zapalonych lampach za oknem jest nadal obraz dzienny/złoty (udział nocy 0,07), niebieska szyba dopiero ok. 17:30. Decyzja człowieka: tak zostaje.

**Ekran i rim (2026-10-29, `game1-proto` commit `8af078b`):**
- Ujęcia `rim rano` (9:00) i `rim zachód` (16:15) z Badaczem w smudze, flagi `--rim=` i `--glow=`. Arkusze `shots/cmp/kalibracja_ekran.png` i `kalibracja_rim_zoom.png`.
- **Ekran monitora:** `Prop.glow_energy` zostaje 1,6 (1,0–1,3 płaski niebieski, 2,2 przepala treść).
- **Rim:** `WindowLight.rim_k` 1,4 → 2,2 (wcześniej stała w kodzie). Przy 1,4 rim był po poprawce gammy prawie niewidoczny. Teraz rano widać światło na włosach i barkach, o zachodzie subtelnie.

**Post-process (2026-10-29, `game1-proto` commit `c061186`):**
- W `kit/display.gdshader` ziarno i stała winieta są osobnymi parametrami (`grain`, `base_vignette`), a nie częścią `grade`. Flaga `--post=grade,grain,winieta`. Arkusze `shots/cmp/kalibracja_post.png` i `kalibracja_post_zoom.png`.
- Pełna gradacja (P0) w dzień dawała zimowy chłód, ale nocą zjadała ciepło lamp i barwiła czarne tło na granatowo. Bez gradacji (P1) dzień wychodził żółtawy.
- **Wybór człowieka: P2 bez winiety:** `grade` 0,5, `grain` 0,015 (było 0,035), `base_vignette` 0. Stała winieta prawie nic nie zmieniała, bo poza budynkiem jest czarno.

**Kalibracja zakończona.** Wszystkie punkty listy (punkt bieli, α, noc, korytarz, słońce, plama, lampy, widok za oknem, ekran, rim, post-process) są przyjęte i w kodzie. Zostało w tym tickecie: krok 5 (plener szkicem decyzji). Sprite'y lamp (kinkiet, lampa stojąca, lampka biurkowa z `glow_image`) powstaną razem z resztą mebli i ozdób przy budowie właściwego posterunku (decyzja człowieka).

**Krok 5, plener: szkic decyzji (2026-10-29, grilling z człowiekiem, bez prototypu):**
- **Plener to osobna scena** (Struktura świata i podróżowanie), więc wnętrza nie dzielą z nim ekranu. Słońce to `DirectionalLight2D` (kierunek przez normal mapy budynków i postaci) plus płaskie światło ambientu nieba, oba z tego samego `TimeOfDayProfile`. Dla zestawu plener jest jeszcze jedną przestrzenią z własną ekspozycją według tej samej reguły (research 22d §3.7).
- **Bez adaptacji oka na progu:** skok ekspozycji (pochmurny dzień ~5 800 lx, wnętrze ~250 lx) ukrywa wygaszenie ekranu przy wejściu do budynku. Każda scena ma stałą ekspozycję.
- **Cienie budynków:** rzutowane ściemniające wielokąty z bryły, tylko przy jasnym słońcu, długość skrócona dla czytelności (jak smugi we wnętrzu). W pochmurne południe tylko AO u podstaw ścian.
- **Noc:** bez światła księżyca. Księżyc może być widoczny na tle pleneru (niebo nad lasem przy górnej krawędzi sceny) jako świecący element z poświatą na niebie, ale nie oświetla sceny (decyzja człowieka). Chłodny ambient „śnieg i łuna” (nastrojowe minimum jak `night_sky_lux`), latarnie sodowe na ulicy i jedna rtęciowa na parkingu posterunku, zapalane według krzywej w profilu pory dnia (sód najpierw różowawo). **Bez poświaty wokół gracza** (decyzja człowieka po researchu [Światło wokół gracza nocą w plenerze](31-swiatlo-wokol-gracza.md)): dodatkowe światło przy graczu wróci ewentualnie jako mechanika latarki (kierowany snop albo poświata).
- **Okna budynków z zewnątrz:** każde okno fasady to świecący sprite z własnym harmonogramem w danych budynku (np. w budynku świeci tylko jedno okno, inny budynek jest całkiem ciemny), z możliwym nadpisaniem przez fabułę. Wnętrz się nie liczy. W dzień okna są ciemne z reguły ekspozycji.
- **Pogoda:** jeden wspólny `TimeOfDayProfile` na wszystkie 4 dni. Krzywa `clear` (słońce rano i wieczorem) to oświetlenie Pory dnia, nie pogoda. Opad śniegu stały. Zmiana Pogody tylko przez **Nadpisanie pogody**: skrypt ustawia na scenie profil pogody (np. śnieżyca przy wypadku na drodze) i go zdejmuje. Nadpisanie jest stanem świata w `GameState` (scena → pogoda) i przechodzi przez zapis. Powrót do sceny później pokazuje zwykłą pogodę. Pojęcia w `GLOSSARY.md`: Plener, Pogoda, Nadpisanie pogody.
- **Poza szkicem:** budowa i strojenie pleneru przy wycinku z Centrum. Reflektory auta, latarka i Odbicie zostają we mgle mapy.

**Plan kalibracji (ustalony przed sesją 2026-10-29):** w pomieszczeniu z ekspozycją 1 postać i meble mają wyglądać 1:1 jak w Pixellab. Potem kolejno okno i słońce, lampy wieczorne, noc, korytarz i post-process, każdy krok z arkuszem porównawczym do akceptacji.
