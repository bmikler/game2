# style-lab

Poligony do decyzji graficznych game2 (Godot 4.7.2). To nie jest kod gry. Mapa: `docs/wayfinder/map.md`.

## Uruchamianie

- `run.bat`: gra (start w `demo_ulica`), `edit.bat`: edytor.
- Sterowanie: WASD lub strzałki (8 kierunków). Wejście do domu: wejdź w drzwi środkowego budynku. Wyjście: przerwa w przedniej ścianie.
- **F1**: panel debug (godzina, tempo czasu, pixel perfect, kadr (rozdzielczość bazowa), przełączniki i warianty Poligonu, zrzut). **F12**: zrzut.
- Zrzuty trafiają do `shots/` jako `<poligon>__<opcje>__<HHMM>.png`, w rozdzielczości bazowej, przed skalowaniem do okna.
- Seria zrzutów bez człowieka (do arkuszy porównawczych):
  `Godot.exe --path style-lab -- --shots=9,12,16.8,22 [--scene=res://poligony/demo_dom.tscn] [--spawn=z_ulicy]`

## Prototyp Rzutu (ticket „Rzut, skala i rozdzielczość”)

- `rzut.bat`: kwartał miasta (`poligony/rzut_ulica`) i dom z dwoma pokojami (`rzut_dom`, wejście drzwiami środkowego domu w dolnym rzędzie). Budowane kodem (`RzutPoligon`), układ w metrach na ziemi.
- **F2** kąt (głębia : szerokość), **F3** px/m, **F4** kadr bieżącego miejsca (osobno ulica i wnętrze); po przełączeniu gracz zostaje w tym samym miejscu. Reszta w F1: piętro fasady, ściana pokoju, ściana działowa (pełna / obcięta / wierzch), otoczenie pokoju, siatka 1 m, odczyt wymiarów.
- Kadr pokazuje dokładnie zadaną wysokość, skalowaną do okna (także niecałkowicie), żeby kadry dało się porównać na każdym ekranie.
- Arkusz zrzutów: `node tools/arkusz_rzutu.mjs` → `shots/arkusz_rzut/arkusz.html`. Prowadnice z Blendera: `tools/blender/zestaw_testowy.py` (opis w pliku).

## Prototyp Poligonu Ulica w bryłach (ticket „Poligon Ulica w bryłach”)

- `ulica.bat`: ulica w poziomie, dom piętrowy (drzwi do `rzut_dom`), sklep z witrynami, fasada w głębi; latarnie, drzewa, auto, zaspy. Budowane kodem (`poligony/ulica_bryly.gd`).
- F1: układ głębi (A taras ze schodami, B przecznica T, C cofnięcia z ogródkiem), piętro fasady, dachy (płaskie / kalenica wzdłuż ulicy / szczytem / mieszane), szerokość ulicy, jezdnia odśnieżona lub ubita, zaspy, czapy na dachach, okna nocą, chód w pionie (mnożnik prędkości na ekranie), podgląd całości ×0,5.
- Zrzuty wsadowe: `-- --scene=res://poligony/ulica_bryly.tscn --set=uklad=1,podglad=1 --spawn=przerwa --shots=12,21.5`.

## Prototyp Poligonu Dom w bryłach (ticket „Poligon Dom w bryłach”)

- `dom.bat` (start w domu) albo `ulica.bat` i drzwi domu piętrowego. Parter `poligony/dom_parter`: salon, korytarz ze schodami i drzwiami na ulicę, kuchnia za jadalnią (ściana działowa z drzwiami, chowana, gdy gracz jest w kuchni). Piętro `dom_pietro`: sypialnia, korytarz nad klatką schodową, pokój. Jeden skrypt `poligony/dom_bryly.gd` (`floor_index`). Na piętro: wejdź w dół schodów (lewy koniec); na dół: w górne stopnie (prawy koniec otworu).
- Ustalone: dom bez ramek wisi w czerni, dół i boki płynnie w nią przechodzą; okna w ścianach dolnych i bocznych niewidoczne, tylko światło (`SideWindowLight`: poduszka nieba i smuga słońca, research 47 wzorzec A); drzwi na ulicę: języczek, próg, wycieraczka, chłodne światło z zewnątrz (research 43 §3).
- Trzy kolumny okien fasady = trzy kolumny pomieszczeń, w tej samej kolejności. Lampa pomieszczenia za oknem (F1 „Lampa: …”) zapala to okno na fasadzie nocą (`DomBryly.lamps`, czyta `ulica_bryly`).
- Wnętrze roboczo 1,5× szerokości fasady i 8 m głębi (rozmiar dobiera się przy budowie konkretnych budynków). F1: brzeg w czerń (gradient / A płyta w przekroju / B dither / A+B / C mgła, research 78), góra ekranu (północ / wschód / południe jak w game1 / zachód: `LightingDirector.top_azimuth_deg` obraca słońce, ściany zostają opisane względem ekranu), lampy.
- Zmiany wspólne: `RoomBox` ma przejścia w ścianach bocznych (`left_door_z_m`, `right_door_z_m`) i rysowanie ścian zewnętrznych do wyłączenia (`left_wall`, `right_wall`, `front_wall`); `RzutPoligon._character_options()` chowa warianty postaci.

## Prototyp światła okien i orientacji mapy (ticket „Światło okien ze wszystkich ścian i orientacja mapy”)

- `dom.bat` (start w domu, drzwi na ulicę) i `ulica.bat`; „Góra ekranu” (północ / południe) i godzina wspólne dla obu scen.
- Dom, F1: plama okna w dzień wł/wył (północ: tylko okna dolne, południe: tylko tylne; boczne nigdy, tylko smugi przy wschodzie i zachodzie); z plamą smuga zwęża się do niej, bez plamy rozszerza się i wygasa (`WindowLight.LONG_EXTEND`); smugi okien niewidocznych brak / boczne / boczne i dolne; noc: rzut okna (ostry, jak w game1-proto) brak / dolne sodowe / górne chłodne / oba; noc: poduszki nieba.
- Ulica, F1: słońce na fasadach; szyby w dzień (niebo, błysk w co trzecim oknie); poświata zapalonych okien na śniegu; ciepła krawędź śniegu na dachach, kominach i parapetach (słońce, mocniej w złotej godzinie); lampy w co drugim oknie w dzień.
- Główne: „Drzwi: wygaszenie” brak / 0,3 s / 0,6 s (ekspozycja na przestrzeń jak w ADR 0007 z game1).
- Zrzuty: `-- --scene=res://poligony/dom_parter.tscn --set=gora_mapy=1 --shots=9,15.5,22`; wybrane w `shots/t27/`.

## Układ

| Katalog | Zawartość |
|---|---|
| `lighting/` | Port światła z game1 (`reference/game1/lighting/`, ADR 0007 game1): pora dnia `norway_feb.tres`, okna, lampy, ekspozycja, widok HDR → sRGB z gradingiem. Zmiany względem game1 opisane niżej. |
| `config/` | `projection.tres` (`ProjectionConfig`): rozdzielczość bazowa, px/m, `depth_factor`, wzrost postaci, prędkość chodu. |
| `debug/` | Autoload `DebugRegistry` (rejestr przełączników i wariantów) i panel F1. |
| `world/` | Bryły rysowane kodem: `RoomBox` (pokój lub kawałek ulicy, okna jako `WindowLight`), `Block` (budynek, mebel, słup), `PlaceholderActor`, `Door`, `MetricAnchor`, baza `Poligon`. |
| `poligony/` | Sceny. Na razie demo szkieletu: `demo_ulica` (plener) i `demo_dom` (wnętrze). |
| `main/` | `Main`: zegar gry, przełączanie Poligonów przez drzwi, zrzuty. |

## Nowy Poligon

1. Scena z korzeniem `Node2D` i skryptem dziedziczącym po `Poligon`; dzieci: `%Lighting` (`LightingDirector` z profilem pory dnia), `%World` (y-sort), `%Spawns` (`MetricAnchor` o nazwach punktów wejścia).
2. Każdy pokój lub ulica to `RoomLighting` z dzieckiem `RoomBox` (wskazanym w `box`), lampy to `LightFixture` pod `MetricAnchor` wewnątrz `RoomLighting`. Plener: profil z `outdoor = true` (np. `lighting/data/outdoor.tres`).
3. Przełączniki i warianty: nadpisz `_register_options()` i wołaj `DebugRegistry.add_toggle(self, ...)` / `add_variant(self, ...)`. Znikają razem z Poligonem; ich stan trafia do nazwy zrzutu.
4. Pozycje i wymiary podajemy w metrach (`at_m`, `size_m`), więc zmiana skali w `ProjectionConfig` nie psuje układu. Inną skalę włącza `ProjectionConfig.use(config)` i `Main.reload_world()`.

## Zmiany w świetle względem game1

- `WindowLight.PX_M` i `ActorLight.HEIGHT_PX` to funkcje (`px_m()`, `height_px()`) czytające `ProjectionConfig`.
- `RoomLighting.box`: prostokąty podłogi i ambientu z `RoomBox`. `RoomLightingProfile.outdoor` i `outdoor_night_lux`: plener oświetlony niebem i słońcem na całej powierzchni (jasność nocy w plenerze to wartość robocza, do strojenia w tickecie światła).
- Bez `room_shell.gd` i `prop.gd` (zależne od sprite'ów game1); `SideWindowLight` bez szyb rysowanych w `RoomShell`. Rim light dla aktorów nie jest podpięty.
- `LitView`: świat wymienny (`set_world`), rozmiar z `ProjectionConfig`, tryb pixel perfect (skala całkowita, filtr nearest, przyciąganie do pikseli) i tryb wygładzony.
- W trybie `--headless` Godot wypisuje błędy `custom_samplers` z `display.gdshader`; tak samo jest w game1, a w oknie ich nie ma.

## Prototyp mapy światła słońca okien (ticket „Słońce okien liczone mapą światła na makiecie pokoju”)

- `dom.bat` (parter i piętro Poligonu Dom: ściany działowe pionowe i poziome, okna we wszystkich ścianach).
- Dane: `lighting/sun_geometry.gd` (`SunGeometry`, metry: skorupa domu, skrzydła okien każdej ściany z `WindowLight`/`SideWindowLight`, pudełka z każdego `Block` i ścian między kolumnami). Liczy `lighting/sun_map.gd` (`SunMap`): dla każdego piksela shader (`sun_map.gdshader`, wspólne `sun_geometry.gdshaderinc`) odtwarza powierzchnię (podłoga, tylna ściana, przód i wierzch pudełka) i puszcza promień do słońca: musi wyjść ze skorupy przez szybę skrzydła i ominąć pudełka. Wynik w `SubViewport`; `lit.gdshader` czyta go w `light()` dla płaskich świateł o wysokości 7000/7500 (Godot nie przyjmuje `ViewportTexture` jako tekstury `PointLight2D`). Smuga w powietrzu: `sun_air.gdshader`, próbki na linii widzenia piksela (cienie szprosów, mebli i postaci w smudze).
- F1: „Słońce okien” ręczne / mapa światła (na żywo); przebudowa sceny: „Okna (wszystkie ściany)” obecne / większe, „Podział okien” 2 skrzydła / krzyż 2×2 / 3×2 (także rysowane okna tylne); na żywo: „Mapa: jasność plamy” (×0,35–×1, domyślnie ×0,5), „plama z okien bocznych”, „cienie mebli”, „cień postaci” (domyślnie brak: lampy i drzwi go nie rzucają), „miękkość”, „smuga w powietrzu”, „noc przez okna dolne” (brak / ulica równo: daleki kierunek prosto z ulicy / latarnia przed każdym oknem / jedna na środku). Plama z okna, przez które słońce tylko się ślizga, wygasa (`SunMap.FACING_FULL`). Jadalnia ma okno w prawej ścianie (smugi z boku przy wschodzie i zachodzie).
- Sesja 6: F1 „Widok za oknem: jasność” (×0,55 = średnia malowanego widoku game1), „Drzwi: światło” (miękka poświata), „Mapa: smugi okien bocznych” (z geometrii / stare wstęgi), kurz w smugach liczony z mapy (`lighting/sun_dust.gdshader`). Pomiar jasności kadru: `node tools/pomiar/jasnosc.mjs plik.png [nazwa=x,y,w,h ...]`, wycinek: `tools/pomiar/kadr.mjs`.
- **Zasada:** światło okien i drzwi liczy mapa z geometrii (`SunGeometry` → `SunMap`); nie stroimy okien ani drzwi pojedynczo, są tylko globalne pokrętła w F1. Lampy w pokojach są jeszcze ręczne.
- Postać oświetlona mapą (sesja 13): mapy światła mają pasek na prawo od domu (`SunMap.ACTOR_STRIP`, 32×96 px), w którym ten sam shader liczy światło na postaci stojącej w miejscu stóp; postać ma osobny materiał (`Lit.actor_material()`) i czyta ten pasek zamiast piksela domu. F1 „Mapa: światło na postaci”: stare (bliźniaki poduszek) / światło podłogi pod stopami / bryła (słońce w każdym punkcie ciała przez szybę ×0,7, niebo średnio z czterech stron, odbicie od podłogi ×0,3), domyślnie bryła; „Mapa: jasność postaci” ×0,5–×2. Działa też nocą (mapa nocna). Postać nie zasłania sama siebie. Zrzut w wybranym miejscu: `--at=x,d` (metry, jak `player_spot()`); pomiar: `node tools/pomiar/postac.mjs plik.png x d`.
- Panel F1 na Poligonie Dom: tylko licznik klatek, godzina i „Kadr wnętrza” (`DomBryly.SHOWN_OPTIONS`, `DebugRegistry.minimal`); światło to zestaw krytyka C „Pośredni” (`DomBryly.PRESETS`), suwaki schowane (`SLIDER_OPTIONS`), `--set=` dalej je zmienia. Licznik klatek (średnia i najdłuższa klatka) jest w panelu na każdym Poligonie. Panel przebudowuje się raz na klatkę (wcześniej przy każdej dodanej opcji: 3 s wczytywania sceny).
- Lampy w pokojach z mapy (sesja 13): trzecia mapa (`point_source` 3, przeliczana tylko przy zmianie), źródła punktowe z `FixtureDef.map_source` (`source_height_m`, `source_back_m`): 1/d² × cos, abażur (w bok i w górę ×0,25), najwyżej 2× jasności pod lampą, miękkie cienie mebli od żarówki 10 cm, ściany działowe zatrzymują światło. Ręczna plama lampy gaśnie; postać na razie dostaje lampy przez stare bliźniaki. F1: „Lampy w pokojach z mapy”, „Lampy z mapy: jasność”, suwaki ambientu i ekspozycji w dzień i w nocy (`RoomLighting.day/night_ambient_k`, `day/night_exposure_k`). Panel ma suwaki (`DebugRegistry.add_slider`).
- Uwaga: w profilu pogody game1 między ok. 11:00 a 13:30 jest zachmurzenie (brak słońca).
- Zrzuty: `-- --scene=res://poligony/dom_parter.tscn --set=gora_mapy=1 --shots=9.5,10.5,14.5,15.5,22`; wybrane w `shots/t31/`.

## Prototyp cienia postaci z mapy światła (ticket „Cień postaci z mapy światła”)

- `dom.bat`, F1: „Cień postaci: kształt” (brak / **walec**, domyślny / pudełko / płaski prostokąt / płaska sylwetka), „od czego” (wszystkie / bez nieba / tylko lampy / tylko okna / tylko słońce), „liczenie (koszt)” (**okno wokół postaci** / cała mapa co klatkę), „miękkość” (jeden kąt źródła dla wszystkich: pośrodku 0,03 lub jak okno 0,045), suwaki „Cień od lamp: lampa liczona dalej” (żarówka dla cienia odsunięta od stóp ×1–×8, domyślnie ×3: cień krótszy i węższy) i „promień walca” (0,15–0,5 m); od czego domyślnie bez nieba (cień nieba dawał rozmytą plamę), „siła” (×0,25–×1), „Plamka pod stopami” (stała jak dziś / **miękka kontaktowa** / brak).
- Jak liczy: mapy domu zostają bez postaci (przeliczane tylko przy zmianie). Obok paska postaci każda z trzech map (słońce i niebo, noc, lampy pokojowe) ma okno 320×320 px wokół stóp (`SunMap.SHADOW_WIN`, 220 px nad stopami: podłoga za postacią i tylna ściana), liczone co klatkę: ile światła danego źródła postać zabiera z każdego punktu (`lost_at` w `sun_map.gdshader`: słońce i noc próbkami tarczy, niebo siatką 3×3 promieni na każdą szybę, każda lampa próbkami żarówki; test postaci najpierw, meble dopiero przy trafieniu). `lit.gdshader` odejmuje to od mapy; brzeg okna wygaszony na 24 px. Kształty płaskie to karta obrócona do każdego źródła (cień sprite'a); sylwetka ma szerokość z wysokości (nogi, tułów, szyja, głowa). Bryły (walec, pudełko) zaciemniają podłogę między nogami.
- „Cała mapa co klatkę”: stara droga z ticketu 31 (postać w `blocked()`, trzy mapy domu przeliczane co klatkę), ten sam obraz.
- Koszt (`--bench=godzina`: kl./s bez vsync, 3 s): bez cienia 390; okno 326 (9:30) / 285 (22:00), ok. 1 ms; cała mapa 143 / 113, ok. 6 ms.
- Zrzuty i arkusz kształtów: `shots/t33/` (`p1` lewy pokój obok lampy, `p2` lewy pokój w plamie okna, `p3` prawy dolny pokój przy lampie; `s0` bez cienia, `s4` sylwetka, `d_*` różnice ×6: `node tools/pomiar/roznica.mjs a.png b.png wy.png 6`).
- Stan końcowy ticketu 33: F1 pokazuje tylko „Cienie: ustawienia krytyka” (domyślnie **A4 „Oddech okna, poprawiony”**, decyzja człowieka) i „Cień postaci: wygląd” (gładki / 3 poziomy z ditherem / 2 poziomy twarde, `lit.gdshader`); suwaki cieni i nieba schowane (`--set=` działa). Cień nieba liczony analitycznie (`sky_lost`: nakładanie kątowe szyby i walca), AO nieba pod stopami, postać we wstęgach bocznych (`sun_ribbon.gdshader`), plamka jak w game1. Pomiar kosztu: `--bench=godzina`.


## Prototyp jednego bufora światła (ticket „Przebudowa światła wnętrza na jeden bufor z cieniami”)

- `dom.bat`. Całe światło wnętrza z jednej funkcji (`lighting/light_fn.gdshaderinc`) i jednego bufora (`SunMap`, `light_map.gdshader`): słońce, wstęgi okien bocznych, niebo każdej szyby i drzwi wejściowych, noc, lampy; jedne przesłony (ściany, meble, schody, postać jako walec). Bez warstw rysowanych na wierzchu (poświata drzwi, plamka pod stopami, stare wstęgi). Szczegóły i stan: ticket 36.
- F1: wygląd cieni (gładki / 3 poziomy z ditherem / 2 twarde), tarcza słońca, żarówka, widok debug bufora, smugi okien górnych, test cieni.
- Zrzuty z ruchem: `-- --scene=res://poligony/dom_parter.tscn --at=3.2,1.6 --shots=9.5,22 --path=1.6,1.2;5.05,6.5;3.2,1.6`; przy zrzucie powstaje `.bufor` (surowy bufor), porównanie: `node tools/pomiar/bufor_roznica.mjs a.bufor b.bufor 652`. Koszt: `--bench=godzina` (`--set=liczenie=1`: cały dom co klatkę).

## Prototyp światła ulicy (ticket „Światło w Poligonach”)

- `ulica.bat` (start na ulicy; drzwi domu piętrowego prowadzą do `dom_parter` i z powrotem). Góra ekranu domyślnie: południe (jak w domu).
- Ten sam model co we wnętrzu: jedna funkcja (`lighting/street_fn.gdshaderinc`, wspólne części z domem w `light_common.gdshaderinc`), jeden bufor (`StreetMap`, `street_map.gdshader`), jedne przesłony: budynki z dachami (bryła: pudło przycięte płaszczyznami dachu, `box_roof`), taras, każdy `Block` (latarnie, zaspy, płoty, murki), drzewa, auto, postać jako walec. Źródła: słońce (tarcza, cienie budynków), niebo (półsfera minus ściany brył, współczynnik kształtu), latarnie (punkty, `street_lamp.tres: map_source`), zapalone okna nocą (szyba świecąca na zewnątrz, zasięg 6 m z wygaszaniem). Płaski ambient ulicy to tylko odbicie (`RoomLighting.sky_in_map`).
- F1: „Światło ulicy” mapa / stare (płaskie, t27), „Cienie budynków od słońca”, wygląd A/B/C i rozdzielczość (wspólne z domem), widok debug bufora ulicy, test cieni (postać jako pudełko / pudełko w miejscu postaci), liczenie (okno / całość co klatkę), suwaki krytyka: słońce, udział nieba w mapie, okna, latarnie.
- Koszt: bufor liczy się tylko przy zmianie (postać stoi: ok. 350 kl./s), w ruchu okno wokół postaci (ok. 70–90 kl./s), pełne przeliczenie co minutę gry rozłożone na 8 klatek (`StreetMap.BANDS`). `--bench=godz --ruch` mierzy ruch, `--okno` wypisuje rozmiar okna.
- Bufor ulicy przy zrzucie: `.bufor` (RGBA half); porównanie bez paska postaci: `node tools/pomiar/bufor_ulica_roznica.mjs a.bufor b.bufor 1780 1812`, podgląd: `bufor_ulica_png.mjs`. Zrzuty do katalogu: `tools/pomiar/zrzuty.sh <katalog> <prefiks> <argumenty>`.
