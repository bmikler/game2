> Kopia z game1 (`repo/game1/docs/research/22c-gra-swiatla.md`, stan 2026-11-03). Ścieżki i numery notatek odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Nic z §6 nie zostało tam uruchomione w całości. Wnioski dla game2 są w `docs/grafika.md`.

# Gra światła w pokoju socjalnym: smugi z okna, odbicia, cienie, atmosfera (Godot 4 2D)

Ticket: `docs/wayfinder/tickets/22-pipeline-assetow.md` (pokój socjalny w docelowej grafice, `room.tscn`). Data researchu i dostępu do wszystkich źródeł: **2026-10-28**. Wejście: `prototype/lighting/room.gd` (repo `game1-proto`), zrzuty `shots/room_{wschód,dzień,zachód,noc}.png`, wcześniejszy research kolorów `22a-kolory-wnetrz.md`. Kolorów ambientu, podłogi ani struktury palety tu nie powtarzam; ten dokument zakłada rekomendacje z 22a (ambient chłodny i mało nasycony, ciepło niosą światła, noc nie jest czarna).

Źródła pierwotne: kod źródłowy Godota (renderer 2D, `master`), dokumentacja klas Godot, karty katalogowe Philips/Signify, tabela ciała doskonale czarnego M. Charity'ego, blog Jamesa Gurneya. O technice oświetlenia w konkretnych grach (Eastward, The Last Night, Octopath, Sea of Stars, Replaced, Children of Morta) twórcy mówią mało i ogólnikowo; cytuję to, co da się przypisać twórcom, a resztę oznaczam jako własną obserwację. Pozycję słońca liczyłem sam (algorytm NOAA, skrypt Node).

## Streszczenie i rekomendacja

- **Fakt, który zmienia założenie „smugi tylko przy niskim słońcu”:** w drugiej połowie lutego na ~63°N (Trondheim) słońce **przez cały dzień jest nisko**: w południe ok. 15° nad horyzontem. Wschód ok. 8:05 z azymutu ~114° (ESE), zachód ok. 17:00 na ~244° (WSW). Fizycznie smugi byłyby długie przez cały dzień. To, że w środku dnia ich nie ma, trzeba uzasadnić **pogodą** (zachmurzenie w dzień, przejaśnienia o świcie i zmierzchu) albo przeszkodami (wzgórza, budynki). Rekomendacja: krzywa „jasność nieba” per pora i smugi tylko przy przejaśnieniu (§1.1).
- **Kierunek smug w prototypie jest odwrócony względem fizyki.** Rano smugi idą w lewo w dół, a to odpowiada oknom na północ. W lutym na północ nie wpada żadne bezpośrednie słońce. Ściana z oknami powinna patrzeć na **południe/SSW**: rano plama przesuwa się w prawo, wieczorem w lewo (§1.2).
- **Prawdziwa geometria nie mieści się w pokoju 6 m.** Przy 15° plama z okna o wysokości 0,9–2,3 m leży 3,3–8,4 m od ściany, a przy zachodzie 6–20 m, czyli poza kadrem. Trzeba skompresować długość (efektywna wysokość słońca ≥ ~24°), zachowując kierunek i równoległość promieni. Gurney pokazuje na Hopperze, że widz wybacza nieprawdziwą długość, ale nie wybacza promieni nierównoległych i niespójnych kątów (§1.3).
- **Przepis (kolejność wdrażania):** (1) plama w kształcie okna z rzutu ukośnego (`PointLight2D` z teksturą okna i macierzą ze ścięciem), (2) smuga w powietrzu jako addytywne czworoboki per szyba, (3) kurz widoczny tylko w smudze (cząsteczki `LIGHT_ONLY` oświetlone osobnym światłem), (4) chłodne światło nieba z każdego okna, (5) ciepłe odbicie od plamy słońca na ścianę, meble i postać, (6) AO i cienie kontaktowe jako sprite'y `MUL`, (7) kontrświatło na postaci w smudze, (8) praktyczne źródła nocą o realnych temperaturach barwowych, (9) cienie mebli w plamie słońca przez wypiekanie tekstury plamy na CPU, (10) dostrojenie glow w HDR. Szczegóły, parametry i koszt w §6.
- **`LightOccluder2D` nie nadaje się do słońca w widoku 3/4.** Cień 2D to rzut z punktu w płaszczyźnie ekranu na nieskończenie wysoką przeszkodę. Słońca z okna nie da się tak opisać, a opcja „cień za rodzicem” według zgłoszeń nie działa w 4.x. Zostawić okludery do latarki i świateł w korytarzach (§3).
- **Skalowanie na posterunek:** twardy limit silnika to **16 świateł na jeden canvas item** i 256 świateł na jeden render (stałe `MAX_LIGHTS_PER_ITEM` i `MAX_LIGHTS_PER_RENDER` w źródłach Godota). Wniosek: podłoga i ściany jako wiele małych elementów (kwadranty `TileMapLayer`, osobne sprite'y per pokój), wyłączanie zestawu świateł pokoju poza ekranem, maski światła przydzielane naprzemiennie sąsiednim pokojom i ambient per pokój przez duże, słabe światła wypełniające, bo `CanvasModulate` jest jeden na canvas (§5.6).

## 1. Światło z okna w widoku 3/4

### 1.1 Słońce w lutym na ~63°N (własne obliczenia)

Algorytm NOAA, Trondheim 63,43°N 10,40°E, 20.02.2010, UTC+1 (deklinacja −11,2°):

| Godzina | Wysokość | Azymut | Długość cienia na 1 m (cot) |
|---|---|---|---|
| 8:30 | 2,3° | 121° | 24,5 |
| 9:00 | 5,1° | 128° | 11,2 |
| 10:00 | 9,8° | 142° | 5,8 |
| 12:00 | 15,1° | 172° | 3,7 |
| 12:30 | 15,4° (max) | 179° | 3,6 |
| 14:00 | 13,5° | 202° | 4,2 |
| 15:00 | 10,2° | 217° | 5,5 |
| 16:00 | 5,6° | 231° | 10,2 |
| 16:30 | 2,9° | 238° | 19,7 |

Wschód ok. 8:05, zachód ok. 17:00. Klucze w `room.gd` (8:15 / 16:30) pasują do połowy lutego albo miejsca trochę dalej na północ; to w porządku.

Wniosek projektowy: „smugi tylko o wschodzie i zachodzie” to stylizacja, nie fizyka. Najprostsze wiarygodne uzasadnienie to **pogoda**. Proponuję dodać do tabeli pór klucz `CLEAR` (0–1, przejaśnienie): ok. 0,8–1 w oknach 8:30–9:45 i 14:45–16:45, ok. 0,1–0,2 w południe (pochmurno: brak twardych smug, tylko miękkie światło nieba). Energię słońca mnożyć przez `CLEAR`, a światło nieba przez `1 − 0,5·CLEAR`. Później można dodać dni pogodne jako wariant fabularny.

### 1.2 Orientacja okien i kierunek plamy

Kamera patrzy przez pokój na tylną ścianę z oknami, więc **patrzymy pod słońce** (kontrświatło). Okno o normalnej zewnętrznej `A_w` (azymut) i słońce o azymucie `A_s` dają kąt `φ = A_s − A_w`. Przy `φ > 0` słońce jest po prawej stronie okna (patrząc z wnętrza na zewnątrz), więc plama przesuwa się **w lewo**.

Dla ściany na południe (`A_w = 180°`): rano `φ ≈ −50°` (plama w prawo), w południe ~0°, wieczorem `φ ≈ +45…+58°` (plama w lewo). Przy `|φ| > ~70°` światło tylko muska ościeże i do pokoju wpada niewiele. Prototyp (`rotation = −off·0,55`) daje rano plamę w lewo, czyli odwrotnie. Do poprawy: znak rotacji albo założenie, że okna patrzą na północ, ale wtedy w lutym nie ma żadnego bezpośredniego słońca.

### 1.3 Rzut plamy na podłogę (rzut ukośny 1 m = 40 px w głąb i w górę)

W tym widoku punkt pokoju `(x, d, z)` (d: odległość od tylnej ściany, z: wysokość) rysuje się na ekranie w `(x, FY + 40·d − 40·z)`. Promień słońca przechodzący przez punkt okna na wysokości `z` trafia w podłogę w poziomej odległości `z·cot(e)`. Na ekranie punkt okna `(x, FY − 40z)` przechodzi w plamę:

```
dx = −40 · z · cot(e) · sin(φ)
dy = +40 · z · cot(e) · cos(φ)          (od linii FY w dół)
```

Parapet `z = 0,9 m` daje bliską krawędź plamy, górna krawędź otworu `z = 2,3 m` daleką. Okno na podłodze jest więc **odwrócone** (góra okna ląduje najdalej), a mullion i ślemię odciskają się jako linie równoległe do boków plamy. Plama to równoległobok, bo promienie słońca są równoległe. Przykłady (ściana na S, bez kompresji): 12:00 → bliska krawędź 132 px, daleka 338 px (pokój ma 240 px), 15:30 → odpowiednio 182/465 px w dół i 176/449 px w lewo.

**Kompresja (rekomendacja):** liczyć z efektywnym `c = min(cot(e), c_max)`, gdzie `c_max` daje daleką krawędź w ok. 85% głębokości pokoju: `40·2,3·c·cos(φ) ≤ 204` ⇒ `c_max ≈ 2,2` (efektywnie ~24°). `φ` przyciąć do ±55°. Długość smugi niech rośnie z niskim słońcem tylko w tym zakresie, np. `c = lerp(1,3; 2,2; low_sun)`.

Gurney o Hopperze: promienie Hoppera „nie są równoległe”, a ukośna krawędź plamy na podłodze „czuje się źle”. Sam przyznaje, że artyście wolno wszystko, co mu ujdzie, ale lepiej zachować zgodność z prawdą. [Gurney Journey, Hopper's Light: Evocative or Illogical?](http://gurneyjourney.blogspot.com/2020/06/hoppers-light-evocative-or-illogical.html). Dla nas: wszystkie trzy okna dają **ten sam** wektor ścięcia, a krawędzie plamy są równoległe do krawędzi smugi w powietrzu.

**Ostrość krawędzi:** Słońce ma ok. 0,53° średnicy, więc półcień to ok. 0,93 cm na każdy metr od otworu. Przy 3–5 m daje to 3–5 cm, czyli 1–2 px. Plamy słońca mają mieć **twarde krawędzie** (najwyżej 1 px miękko, mocniej przy dalekiej krawędzi). Rozmycie należy do światła nieba (obliczenie własne z geometrii).

### 1.4 Parapet, ościeża, ściana wokół okna

- **Parapet:** słońce oświetla górną płaszczyznę parapetu, a rama i mullion rzucają na niego krótkie cienie przesunięte o `dx`. W kodzie parapet ma normalne `UP`. Wystarczy mała, mocna plama na parapecie (osobne światło albo pas w teksturze plamy, §6.1).
- **Ościeża:** obecne okno jest płaskie. Warto dorysować 2–3 px ościeża (grubość ściany ~25–30 cm) po bokach i na dole otworu. Oświetla się ościeże **po stronie przeciwnej do słońca**: wieczorem, gdy słońce jest po prawej, świeci lewe. To jest najtańszy sygnał „tu wpada słońce”, widoczny nawet przy pochmurnym niebie jako jaśniejszy pas od nieba.
- **Ściana z oknami jest najciemniejszą ścianą pokoju.** Nie dostaje światła z okna, tylko odbite od podłogi. Gurney: wnętrze bez sztucznego światła jest „znacznie ciemniejsze niż scena na zewnątrz”, często najciemniejsze miejsce za oknem jest jaśniejsze od najjaśniejszego we wnętrzu. Radzi malować pokój ciemniej, a widok jaśniej, niż widzi oko. [Bright Window Views](http://gurneyjourney.blogspot.com/2012/05/bright-window-views.html). Dla nas: w dzień szyby jako HDR (>1), tylna ściana wyraźnie ciemniejsza od nieba, a jej dolna część ocieplona odbiciem od plamy (§2.1).

### 1.5 Światło nieba (rozproszone, chłodne) a słońce (ciepłe, twarde)

- Światło dzienne z okna to miękkie źródło: cienie szybko się rozmywają, światło mocno słabnie w głąb pokoju, a jego ilość w danym miejscu jest proporcjonalna do tego, jak duży kawałek nieba widać z tego punktu. Jest chłodne względem ciepłych lamp we wnętrzu. [Gurney Journey, Window Light](https://gurneyjourney.blogspot.com/2010/05/window-light.html)
- Gurney opisuje też kontrast chłodnego światła okna z cieplejszymi świetlówkami w kuchni. [Lunch Prep in Casein](https://gurneyjourney.blogspot.com/2014/09/lunch-prep-in-casein.html)
- W 3/4: z punktu blisko okna widać dużo nieba, z głębi pokoju mało. Światło nieba to więc szeroka, miękka poświata przyklejona do tylnej ściany, szersza od okna, zanikająca w ciągu ~2–3 m. Śnieg za oknem (bardzo jasne podłoże) odbija dodatkowo światło w górę na sufit, którego nie widać; w kadrze daje jasny dół szyby i chłodny parapet.

## 2. Światło pośrednie: odbicia, AO, cienie kontaktowe

### 2.1 Ciepłe odbicie od plamy słońca
Gurney: w cieniu działają dwa źródła, ciepłe światło odbite od ziemi i niebieskie światło nieba, przy czym płaszczyzny skierowane w dół łapią głównie ciepłe odbicie. Silne ciepłe odbicie potrafi ocieplić cień bardziej niż stronę oświetloną. [Reflected light in shadow](http://gurneyjourney.blogspot.com/2014/11/reflected-light-in-shadow.html), [How to Apply the Warm-and-Cool Approach](http://gurneyjourney.blogspot.com/2018/06/how-to-apply-warm-and-cool-approach.html)

W pokoju plama słońca na podłodze sama staje się źródłem. Rozjaśnia dół tylnej ściany, kaloryfery, spód kanapy i przód postaci stojącej obok plamy, a kolor to słońce × albedo podłogi. Implementacja: §6.5.

### 2.2 AO i cienie kontaktowe
Narożnik ściana–podłoga, kąty pokoju, przestrzeń pod kanapą i lodówką oraz za kaloryferem dostają mniej światła nieba i odbić. W pixel arcie najtaniej zrobić to **gradientowymi sprite'ami w trybie mnożenia** (`CanvasItemMaterial.blend_mode = BLEND_MODE_MUL`, dostępny w Godot 4 obok MIX/ADD/SUB/PREMULT_ALPHA). [CanvasItemMaterial](https://docs.godotengine.org/en/stable/classes/class_canvasitemmaterial.html). Alternatywa to światło w trybie SUB. Implementacja w §6.6.

## 3. Cienie: `LightOccluder2D` w 3/4 i co zamiast

Jak działają cienie 2D w Godot (z dokumentacji i źródła):
- Cień rzuca `LightOccluder2D` (wielokąt). `shadow_item_cull_mask` światła wybiera okludery, a `range_item_cull_mask` wybiera, kto dostaje światło. `height` światła **nie wpływa na cienie**, tylko na normal mapy. Cienie `DirectionalLight2D` są zawsze nieskończenie długie; po skończone dokumentacja odsyła do własnego shadera czytającego SDF. Filtry: None (najszybszy, pod pixel art), PCF5, PCF13 („tylko dla kilku świateł naraz”). [2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html), [Light2D](https://docs.godotengine.org/en/stable/classes/class_light2d.html)
- W shaderze cień liczony jest z mapy odległości wokół **pozycji światła w płaszczyźnie ekranu** (`canvas.glsl`, `light_shadow_compute`). To model „latarka nad mapą, ściany nieskończenie wysokie”.

Co wygląda źle w 3/4:
- **Słońce z okna:** źródło jest „za ścianą” i wysoko, a promienie są równoległe. Okluder wachlarzowo rozrzuca cień od punktu światła i przedłuża go do krawędzi tekstury. Kanapa rzuci cień w złą stronę i bez końca.
- **Samocienie i kolejność:** okluder na sprycie zaciemnia sam sprite. Opcja „Show Behind Parent” według zgłoszenia nie działa w żadnej wersji 4.x, a sekcja zniknęła z dokumentacji 4.5. [forum Godot: LightOccluder2D self-shadowing](https://forum.godotengine.org/t/lightoccluder2d-how-to-prevent-self-shadowing/123443). Ściany w 3/4 oświetlają się od złej strony, gdy światło jest za nimi; pomaga osobna maska światła dla ścian. [godotforums 23964](https://godotforums.org/d/23964-problems-with-light2d-and-tilemaps-in-a-topdown-game)
- **Koszt:** każde światło z cieniem renderuje własną mapę cieni co klatkę (`light_update_shadow` w `renderer_viewport.cpp`).

Kiedy okludery mają sens: latarka gracza i lampy w korytarzach posterunku, gdzie źródło jest nisko, a ściany zasłaniają widok (model „nieskończenie wysokiej ściany” jest wtedy wystarczający). Także drzwi uchylone do jasnego korytarza.

Zamiast okluderów dla słońca:
1. **Wypiekana tekstura plamy (rekomendacja dla mebli):** przy zmianie godziny policzyć na CPU obraz plamy. Dla każdego teksela podłogi w obrysie plamy rzucić promień do słońca i sprawdzić, czy przechodzi przez otwór szyby (nie przez ramę ani mullion) i nie przecina prostopadłościanu mebla (`blockers` już istnieją jako rzuty, trzeba dodać wysokość). Wynik to tekstura światła z mullionami i cieniem kanapy, dokładna w tej samej geometrii co §1.3 (§6.9).
2. **Malowane / rzutowane wielokąty cienia:** prostopadłościan mebla rzutowany wektorem słońca to 2 czworoboki. Rysuje się je jako `Polygon2D` w trybie MUL nad podłogą, przycięty do plamy. To prostsze, ale cień przyciemnia też ambient, więc trzeba go trzymać słabym.
3. **Cienie kontaktowe** (zawsze, niezależnie od słońca): §6.6.

## 4. Atmosfera

### 4.1 Smugi w powietrzu i kurz
Gurney podaje trzy warunki widocznych promieni: (1) przesłona z nielicznymi otworami (ciemne tło), (2) drobny pył lub para w powietrzu (drobniejsze cząstki barwią światło ku żółci i czerwieni), (3) **patrzenie w stronę źródła**, bo patrząc od światła promienie znikają. Smuga zmienia głównie walor cieni, nie stron oświetlonych. [Gurney Journey, Sunbeams](http://gurneyjourney.blogspot.com/2008/05/sunbeams.html). Promienie zajmują konkretną objętość między źródłem a podłożem i są równoległe, choć w perspektywie wydają się rozbiegać.

U nas wszystkie trzy warunki są spełnione: ciemne wnętrze, kurz pokoju socjalnego i kamera patrząca pod słońce. Smugi i kurz są więc uzasadnione, ale **tylko przy bezpośrednim słońcu**. W pochmurny dzień smug nie rysować.

Smuga na ekranie to obwiednia rzutu otworu okna (na ścianie) i plamy (na podłodze). Rysujemy ją jako cztery czworoboki, po jednym na szybę (2 kolumny × 2 rzędy przez ślemię), więc przerwy po mullionie i ślemieniu wychodzą same. Szczegóły w §6.2. Kurz w §6.3.

### 4.2 Temperatury barwowe źródeł (2010, Norwegia)
Kolory sRGB ciała doskonale czarnego (CIE 1964 10°) z tabeli Charity'ego; [vendian.org bbr_color](http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html):

| Źródło | Dane | Ciało czarne (sRGB) | Proponowany kolor światła (zgaszony, do strojenia) |
|---|---|---|---|
| Sód wysokoprężny (latarnie uliczne) | Philips SON-T PIA Plus: CCT 2000 K, pole CRI puste w karcie [datasheet](https://www.assets.lighting.philips.com/is/content/PhilipsLighting/fp928144709230-pss-en_ae) | 2000 K `ff8912` | `(1,0; 0,62; 0,32)` |
| Żarówka / lampka biurkowa | ~2700 K (wiedza ogólna) | 2700 K `ffa957` | `(1,0; 0,78; 0,55)` |
| Świetlówka T8 840 (biuro) | Philips TL-D Super 80 /840: 4000 K, CRI 80 [Signify](https://www.signify.com/en-gb/prof/conventional-lamps-and-tubes/fluorescent-lamps-and-starters/tl-d/philips-master-tl-d-super-80/927923084014_EU/product) | 4000 K `ffd1a3` | `(0,86; 0,95; 0,88)`: neutralna z odchyleniem w zieleń |
| Rtęciówka (starsze latarnie, parkingi) | Philips HPL-N 542: 4200 K, CRI 45–49, „chłodna, niebieskawa biel” [datasheet](https://www.assets.lighting.philips.com/is/content/PhilipsLighting/fp928053007422-pss-en_za) | 4100 K `ffd3a8` | `(0,78; 0,92; 1,0)` |
| Dzień pochmurny / niebo | ~6500–7500 K | 7500 K `ebeeff` | kolor `SKY_LOW/SKY_TOP` z `room.gd` |
| Księżyc + śnieg (noc) | — | — | obecne `(0,45; 0,55; 0,95)` |

Uwagi:
- Zieleń świetlówek: Rosco sprzedaje filtry Minus Green właśnie do „cięcia zielonego” ze świetlówek i lamp wyładowczych. [Adorama, Rosco 1/8 Minus Green](https://www.adorama.com/RO3318.html). Kolor ciała czarnego 4000 K jest ciepławy; filmowy „chłodny, zielonkawy” wygląd świetlówki bierze się z balansu bieli kamery na dzień i z widma rtęci. Obecne `FLUO_COLOR (0,82; 0,93; 1,0)` jest niebieskie, a nie zielonkawe. Proponuję przesunąć je w zieleń i zmniejszyć niebieski, żeby chłód niosły okna i noc (zgodnie z 22a).
- Sód i rtęć obok siebie (pomarańcz kontra sinobiały) to dobry kontrapunkt za oknem: jedna latarnia sodowa przy ulicy, jedna rtęciowa przy parkingu posterunku.
- Kolory jako punkt startowy, nie wartości z pomiaru. Przy `use_hdr_2d` renderowanie jest liniowe (zob. §5), więc ocena wymaga zrzutów.

### 4.3 Noc i czytelność
Zasady z 22a (ambient L 0,13–0,20, trzy poziomy jasności) obowiązują. Do tego:
- **Każde praktyczne źródło ma trzy elementy:** emisyjny sprite oprawy (unshaded, HDR > 1, łapie glow), plamę światła na podłodze (`PointLight2D`) i słabą plamkę na najbliższej ścianie lub meblu. Gurney o silnych, kolorowych źródłach: zamiast malować samo źródło na pełną moc, maluj kolorową poświatę, którą rzuca na otoczenie. [Neon Window Light](http://gurneyjourney.blogspot.com/2016/01/neon-window-light.html)
- **Kontrświatło na postaci** (rim) od okna nocą (śnieg, latarnia) utrzymuje sylwetkę na ciemnym tle (§6.7).
- **Przelew z korytarza:** w docelowym posterunku najciekawsze nocne źródło to światło z korytarza przez drzwi i szybkę w drzwiach. Tekstura w kształcie otworu drzwi, rzucona na podłogę jak okno w §1.3, tylko z niskiego źródła.

## 5. Godot 4 (4.7) — co jest pewne (dokumentacja i źródło)

- **Model mieszania (kod `canvas.glsl`):** `kolor = albedo × modulate × CanvasModulate`, potem każde światło w trybie Add dodaje `albedo × tekstura_światła × color × energy` (z N·L przy normal mapach). Sub odejmuje to samo, a Mix robi `mix(kolor, światło, alfa)`. Światło SUB może więc zejść **poniżej** ambientu, aż do czerni. [canvas.glsl](https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_rd/shaders/canvas.glsl)
- **Tekstura światła pracuje w pełnej transformacji węzła.** Macierz tekstury to odwrotność `xform_cache × scale(rozmiar_tekstury·texture_scale)` z przesunięciem o `offset` (`renderer_viewport.cpp`, `light_shader_xform`). Rotacja, skala i **ścięcie** (`Node2D.skew` albo dowolna `Transform2D`) deformują teksturę. Poza zakresem UV [0,1] światło daje zero. Tekstura może być **kolorowa** (RGB mnoży `color`), więc jedno światło może mieć np. ciepły rdzeń i chłodniejsze brzegi. [renderer_viewport.cpp](https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_viewport.cpp), [renderer_canvas_render_rd.cpp](https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_rd/renderer_canvas_render_rd.cpp)
- **`height`:** w pikselach (wysokość 100 oświetla obiekt 100 px dalej pod 45°). Działa tylko na normal mapy, nie na cienie. Po włączeniu normal map światła wydają się słabsze, więc trzeba podnieść `height` i trochę `energy`. [PointLight2D](https://docs.godotengine.org/en/stable/classes/class_pointlight2d.html)
- **Maski:** `range_item_cull_mask` ↔ `CanvasItem.light_mask` (kto odbiera światło), `shadow_item_cull_mask` (kto rzuca cień), `range_z_min/max`, `range_layer_min/max`. `DirectionalLight2D` **ignoruje** `range_item_cull_mask` i oświetla wszystko. [Light2D](https://docs.godotengine.org/en/stable/classes/class_light2d.html)
- **Limity (źródło, `renderer_canvas_render_rd.h`):** `MAX_LIGHTS_PER_ITEM = 16`, `MAX_LIGHTS_PER_RENDER = 256`, `MAX_LIGHT_TEXTURES = 1024`. Na forum potwierdzają, że po przekroczeniu limitu kolejne światła na danym sprite'cie znikają. [forum](https://forum.godotengine.org/t/working-around-godots-2d-light-limitations-for-a-dark-game/81311). Liczą się tylko światła włączone (`enabled`), z teksturą, których prostokąt przecina ekran (`clip_rect.intersects`).
- **`CanvasModulate`:** jeden na canvas. Inne `CanvasLayer` renderują się niezależnie. [CanvasModulate](https://docs.godotengine.org/en/stable/classes/class_canvasmodulate.html)
- **`CanvasItemMaterial.light_mode`:** NORMAL, UNSHADED, **LIGHT_ONLY** („jakby było tylko światło”). W shaderze LIGHT_ONLY pomija `CanvasModulate`, a alfa to suma świateł, więc taki sprite jest niewidoczny poza światłami. [CanvasItemMaterial](https://docs.godotengine.org/en/stable/classes/class_canvasitemmaterial.html), `canvas.glsl` (`MODE_LIGHT_ONLY`).
- **Addytywne sprite'y są tańsze od świateł**, ale nie rzucają cieni, ignorują normal mapy i źle oświetlają całkiem ciemne miejsca. [2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- **Oświetlenie liczy się w rozdzielczości viewportu.** U nas 960×540 skalowane w górę, więc światło jest już „pikselowe”. Przyciąganie `LIGHT_VERTEX` z dokumentacji nie jest potrzebne.
- **HDR 2D i glow:** `use_hdr_2d` daje bufor RGBA16, renderowanie na wartościach liniowych i wynik nieobcięty do 0–1. [Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html). `glow_hdr_threshold` trzeba obniżyć poniżej 1,0 dla glow w 2D, bo 2D renderuje się w SDR. Przy włączonym HDR 2D można trzymać próg ~1,0 i świecić tylko tym, co ma wartości > 1. `glow_levels` 1–7: od lokalnego do globalnego. `glow_map` mnoży glow teksturą ekranu. [Environment](https://docs.godotengine.org/en/stable/classes/class_environment.html)
- **`TileMapLayer`:** kwadrant renderowania (domyślnie 16×16 kafli) to jeden canvas item. Przy Y-sort kwadranty grupuje się po Y. [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html)

### 5.6 Skalowanie na wiele połączonych pomieszczeń (posterunek bez ekranów ładowania)

Wnioski własne na podstawie powyższych limitów:
1. **Limit 16 świateł na canvas item jest realnym ryzykiem już teraz.** Podłoga pokoju to jeden sprite 480×240. Gdy ten przepis zostanie wdrożony, w dzień trafią w nią: 3 plamy + 3 niebo + 3 odbicia + 2 świetlówki + 3 kontrświatła = 14. Nocne światła muszą być wtedy wyłączone (`enabled = false`), a nie tylko mieć `energy = 0`. W posterunku podłoga i ściany mają być wieloma elementami: `TileMapLayer` (kwadranty 8×8–16×16 kafli) albo sprite per pokój lub segment. Wtedy limit dotyczy tylko świateł nad danym kawałkiem.
2. **Zestaw świateł per pokój:** każdy pokój ma węzeł `Lights` (dzieci: okna, praktyczne, wypełnienie). Rodzic (scena posterunku) włącza tylko pokój z graczem i jego sąsiadów, a reszcie ustawia `enabled = false` (np. przez `VisibleOnScreenNotifier2D` na obrysie pokoju). Silnik i tak odrzuca światła poza ekranem, ale wyłączenie oszczędza też mapy cieni i liczenie pozycji słońca.
3. **Przeciekanie przez ściany:** światło 2D nie zna ścian. Lampa z pokoju A świeci na podłogę pokoju B za ścianą. Rozwiązanie: sąsiednim pokojom przydzielić naprzemiennie bity `light_mask` (kolorowanie grafu, 3–4 bity wystarczą dla planu posterunku). Światła pokoju mają `range_item_cull_mask` = bit pokoju, a progi drzwi i korytarze dostają oba bity. To tańsze od cieni.
4. **Ambient per pokój:** `CanvasModulate` zostaje globalny (najciemniejszy wspólny poziom, np. korytarz nocą). Różnice między pokojami (słoneczny socjal kontra bezokienny areszt) dają **duże, miękkie, słabe światła wypełniające** (tekstura prostokątna z miękkim brzegiem na cały pokój, `energy` 0,1–0,3, wysokie `height`) z maską pokoju. Przejście przez drzwi płynnie zmienia ambient bez skryptów.
5. **Słońce jako jeden stan:** pozycję i kolor słońca liczy jeden węzeł (scena posterunku albo istniejący zegar gry) i wywołuje w dół `apply_sun(state)` na zestawach świateł pokoi z oknami („call down”). Każdy zestaw sam przelicza swoje transformacje z orientacji swojej ściany (`A_w` jako `@export`).
6. **Tekstury współdzielone:** jedna tekstura okna na typ okna, jedna radialna i jedna prostokątna (atlas świateł ma limit 1024 tekstur). Tekstury wypiekane (§6.9) robić tylko dla pokoju z graczem.

## 6. Przepis: techniki do `room.gd` (kolejność wdrażania)

Koszt: **niski** = kilka węzłów, bez narzutu na klatkę; **średni** = dodatkowe światła pełnoekranowe albo cząsteczki; **wysoki** = praca CPU przy zmianie godziny albo shader.

### 6.1 Plama słońca w kształcie okna (zamiast obróconego „promienia”) — niski
- **Tekstura:** `_window_cookie()` o proporcjach otworu (np. 64×56 albo ×2), biała w szybach, czarna w ramie (1–2 px), mullionie (2 px) i ślemieniu (1 px), z 1 px wygładzeniem brzegów. Wiersz 0 to **parapet**, ostatni wiersz to góra okna, bo góra okna ląduje najdalej. Opcjonalnie lekki gradient: daleka krawędź o 10–15% słabsza.
- **Węzeł:** `PointLight2D` per okno, `texture` = powyższa, `offset = 0`, `height` ~40–60 (żeby normal mapy podłogi `UP` łapały światło), `range_item_cull_mask` = bit „podłoga” (tylko podłoga i dywaniki; kanapa i postacie mają osobne światła, §6.7). Transformacja liczona co zmianę godziny:
  ```gdscript
  var c := minf(1.0 / tan(e), C_MAX)                    # C_MAX ≈ 2.2
  var s := Vector2(-sin(phi), cos(phi)) * 40.0 * c      # przesunięcie ekranowe na 1 m wysokości okna
  var o_s := Vector2(OX + wx, FY) + s * 0.9             # środek bliskiej krawędzi (parapet)
  var o_t := Vector2(OX + wx, FY) + s * 2.3             # środek dalekiej krawędzi (góra okna)
  # Tekstura światła jest centrowana na węźle i ma rozmiar tex_w × tex_h px.
  l.transform = Transform2D(Vector2(WIN.x / tex_w, 0.0), (o_t - o_s) / tex_h, (o_s + o_t) / 2.0)
  ```
  Oś x zachowuje szerokość okna, a oś y daje ścięcie i długość. Wszystkie okna dzielą tę samą oś y.
- **Kolor/energia:** `SUN × CLEAR × smoothstep(1°, 4°, e)`. Kolor zgaszony jak w 22a.
- **Efekt:** rozpoznawalny kształt okna z krzyżem na podłodze, przesuwający się w ciągu dnia; kąt i długość spójne między oknami. **To główna zmiana „gry światła”.**

### 6.2 Smuga w powietrzu (god ray) — niski
- **Węzeł:** jeden `MeshInstance2D` (albo 4 × `Polygon2D`) per okno, `CanvasItemMaterial` z `blend_mode = ADD` i `light_mode = UNSHADED`, `z_index` nad podłogą, a pod meblami i postacią (lub nad wszystkim, ale wtedy słabiej).
- **Geometria:** dla każdej z 4 szyb czworobok od prostokąta szyby na ścianie do jej rzutu na podłodze (te same `s` co w §6.1). Kolory wierzchołków: przy oknie `SUN × 0,10–0,18`, przy podłodze 0. Mullion i ślemię zostają jako ciemne przerwy.
- **Opcja:** prosty shader z wolnym szumem (2 oktawy, przesuw ~2 px/s) modulującym alfę, żeby smuga „oddychała”. Cięcie na poziomy alfy co 1/8 utrzyma pixelartowy charakter.
- **Efekt:** widoczna objętość światła; od razu czytelne, skąd świeci słońce. Tylko przy `CLEAR` > ~0,5.

### 6.3 Kurz widoczny tylko w smudze — niski/średni
- **Węzeł:** `GPUParticles2D` (albo `CPUParticles2D`) na cały obszar okien i smug, ~60–150 cząstek 1×1 px, prędkość 1–4 px/s, lekki szum, życie 6–12 s. Materiał `CanvasItemMaterial` z `blend_mode = ADD` i **`light_mode = LIGHT_ONLY`**, `light_mask` = bit „kurz”.
- **Światło „powietrza”:** drugi `PointLight2D` per okno z tą samą teksturą okna, ale z transformacją od środka otworu na ścianie do środka plamy (równoległobok przybliżający smugę), `range_item_cull_mask` = bit „kurz”, `energy` 1–2.
- **Efekt:** drobinki zapalają się tylko wewnątrz smugi i gasną poza nią, bez żadnej logiki. Zgodne z obserwacją Gurneya, że pył widać, patrząc pod światło.

### 6.4 Chłodne światło nieba z każdego okna — niski
- **Tekstura:** szeroka, miękka „poduszka”: w poziomie ~2× szerokość okna z gaussowskim brzegiem, w pionie zanik od tylnej ściany (`pow(1 − t, 2)` na ~100–140 px), początek tuż pod parapetem.
- **Węzeł:** `PointLight2D` per okno, pozycja u stopy ściany pod oknem, `height` 60–80, `color` = `SKY_LOW` w danym momencie (zgaszony), `energy` 0,25–0,5 × (1 − 0,5·`CLEAR`) × `sun_up`. Maska: podłoga + meble + postacie.
- **Plus:** szyby (`outside`, sky) w dzień z `modulate` 1,2–1,6, żeby były jedynymi wartościami > 1 i łapały glow. Ościeża 2–3 px dorysowane w `_build_shell()` (§1.4).
- **Efekt:** pokój ma kierunek światła także w pochmurne południe, a okna dominują w dzień zgodnie z 22a. Tylna ściana zostaje ciemniejsza od szyb.

### 6.5 Ciepłe odbicie od plamy słońca — niski
- **Węzeł:** `PointLight2D` radialny (istniejące `Art.light_radial(0)`), pozycja w środku plamy z §6.1, `texture_scale` ≈ 1,3–1,6 × długość plamy / 256, `height` 100+, `color` = `SUN × albedo podłogi` (dla `8a8276` ok. `(0,54; 0,51; 0,46)` × kolor słońca, potem ocieplić), `energy` = 0,15–0,3 × energia plamy. Maska: **ściana, kaloryfery, meble, postacie, bez podłogi** (żeby nie rozmyć ostrej plamy).
- **Efekt:** dolna część tylnej ściany, kaloryfery i spód kanapy dostają ciepły pogłos przy zachodzie. Pokój wygląda na „wypełniony” światłem, nie tylko pocięty smugami.

### 6.6 AO, cienie kontaktowe, narożniki — niski
- **Węzły:** `Sprite2D` z teksturami gradientowymi, `CanvasItemMaterial.blend_mode = BLEND_MODE_MUL`, `light_mode = UNSHADED` (mnoży wynik po oświetleniu):
  - pas wzdłuż `FY` (styk ściana–podłoga): 8–12 px w głąb podłogi, od `0,70` do `1,0`;
  - pionowe pasy przy bocznych ścianach i ciemniejsze kąty (gradient promieniowy w rogach, ~40 px);
  - elipsa pod kanapą i lodówką (szerokość podstawy + 4 px, wysokość 6–10 px, środek `0,55`, brzeg 1,0) oraz krótki pas za kaloryferem na ścianie;
  - pod postacią: mała elipsa 14×5 px, `0,6`, jako dziecko gracza (kontakt z podłogą, którego teraz brak na zrzutach).
- **Alternatywa:** światło SUB z tymi samymi teksturami i maską podłogi; odejmuje proporcjonalnie do albedo i nie dotyka mebli. Prostsze w kolejności rysowania, ale łatwo „przepalić” w czerń.
- **Efekt:** meble „stoją” na podłodze, a pokój dostaje głębię w kątach. Bardzo mały koszt.

### 6.7 Kontrświatło (rim) na postaci w smudze i przy oknie — niski
- **Dlaczego osobno:** plama z §6.1 opisuje podłogę. Piksel ciała na wysokości z leży na ekranie w innym miejscu niż punkt podłogi, który oświetla, więc wspólne światło oświetla postać w złym miejscu.
- **Implementacja:** w `_physics_process` dla gracza (i NPC) sprawdzić 3 punkty (stopy, pas, głowa: z = 0,1; 1,0; 1,7 m), czy promień ku słońcu przechodzi przez szybę: `z_w = z + d / (c·cos φ)` ∈ [0,9; 2,3] i odpowiednie x w szerokości szyby. Udział 0–1 daje `energy` małego `PointLight2D` dziecka postaci: pozycja ~20 px **nad** postacią (w stronę okna), `height` 30–50, kolor słońca, maska = tylko postacie. Normal mapy (`UP`, krawędzie) zrobią jasną krawędź góry i ramion.
- Nocą to samo światło, z kolorem śniegu lub latarni i małą energią, utrzymuje sylwetkę (§4.3).
- **Efekt:** postać wchodząca w smugę „zapala się” konturem. To najmocniejszy pojedynczy efekt noir w tym kadrze.

### 6.8 Praktyczne źródła i nastrój każdej pory — niski/średni
Propozycja scenariusza (strojenie na zrzutach):

| Pora | Dominujące | Kontrapunkt | Uwagi |
|---|---|---|---|
| świt 8:15–9:45 | krótkie, różowo-pomarańczowe smugi w prawo (SE), słabe | świetlówki jeszcze włączone (zielonkawe) | pierwsze minuty bez smug: tylko różowe niebo i ościeża |
| dzień 10–14:30 | chłodne światło nieba (pochmurno), jasne szyby | świetlówki na ~35% | bez smug i kurzu, „urzędowo” |
| zachód 14:45–16:45 | długie, ciepłe smugi w lewo, kurz, ciepłe odbicie | świetlówki zapalają się ok. 16:00 z migotaniem startera | kulminacja gry światła |
| niebieska godzina 16:45–18 | głęboki błękit szyb, świetlówki | latarnia sodowa za oknem zapala się (najpierw różowawo, potem pomarańczowo), rtęciowa na parkingu | ciepło-zimne zderzenie |
| noc | świetlówki albo tylko lampka (tryb „po godzinach”) | chłodny śnieg i księżyc z okien, rim gracza | ewentualnie zielony znak wyjścia, przelew z korytarza przez drzwi |

- **Świetlówka** jako światło prostokątne, a nie radialne: tekstura 2:1 z miękkim brzegiem (oprawa 2 × 120 cm), `height` 120, kolor z §4.2. Do tego emisyjny prostokąt oprawy, jeśli sufit kiedyś będzie widoczny, albo tylko plama.
- **Lampka biurkowa / czajnik / lodówka:** małe ciepłe radialne o `energy` 0,6–1,0, `height` 20–30, plus 1–2 px emisyjne (HDR 2–3) dla glow.
- **Migotanie:** zostawić jedno źródło z defektem (już jest), ale dodać ciche „zapalanie” świetlówek: 2–4 błyski w 0,8 s przy włączeniu.

### 6.9 Wypiekana tekstura plamy z cieniami mebli i ram — wysoki (CPU przy zmianie godziny)
- Zamiast tekstury okna z §6.1 generować `Image` w przestrzeni podłogi dla obrysu plam (np. 240×140 px, połowa rozdzielczości i powiększenie ×2) i ustawić ją jako teksturę światła z prostą transformacją (bez ścięcia). Dla każdego teksela: punkt podłogi → promień do słońca → przecięcie z płaszczyzną ściany (wysokość `z_w` i x) → test „w szybie, nie w ramie/mullionie” i test prostopadłościanów mebli (`blockers` + wysokość mebla). Wynik 0/1 plus 1 px wygładzenia.
- Przeliczać, gdy słońce przesunie się o > 0,5° (co kilka minut gry), w `WorkerThreadPool` albo kawałkami po kilka wierszy na klatkę. Tylko w pokoju gracza.
- **Efekt:** cień kanapy i zasłon w plamie, fizycznie spójny z kierunkiem smug. Robić dopiero, gdy pokój będzie miał docelowe meble.

### 6.10 Glow i grading — niski
- Przy `use_hdr_2d = true` ustawić `glow_hdr_threshold` ~1,0 (teraz 0,9) i świadomie podawać wartości > 1 tylko emiterom: szybom w dzień, rdzeniowi smugi przy oknie, oprawom, oknom domów i latarni. Glow lokalny (`glow_levels` 1–3), z małym udziałem 4–5 dla „przepalonych” okien w dzień.
- Grading w `post.gdshader` zostaje. Ewentualna tabela LUT (`adjustment_color_correction`) według dokumentacji działa tylko w zakresie SDR; do sprawdzenia, czy to koliduje z HDR 2D, zanim się jej użyje.

## 7. Eastward i The Last Night: co mówią twórcy i co z tego bierzemy

**Eastward (Pixpil).** Co da się przypisać twórcom:
- Pixpil określa styl jako „retro-pixel + 3D lighting”, a celem jest odczucie bliskie japońskiej animacji lat 90. [Siliconera](https://www.siliconera.com/?p=522687)
- Współzałożyciel Feng Ye (wywiad Red Bull): oświetlenie to „w zasadzie zwykłe deferred shading”, które pozwala level designerowi wstawiać więcej świateł do poziomu i stroić ambient pod nastrój. Silnik jest własny, oparty na MOAI. [Red Bull, Eastward interview](https://www.redbull.com/my-en/eastward-interview). Strona nie wczytała się przy pobraniu; cytat znam z wyciągu wyszukiwarki. Silnik nazywa się Gii i jest zbudowany na MOAI. [Game Developer, Road to the IGF: Eastward](https://www.gamedeveloper.com/disciplines/road-to-the-igf-pixpil-s-i-eastward-i-)
- Nie znalazłem pierwotnego źródła o normal mapach, smugach ani cieniach w Eastward. Na forach są tylko domysły (np. że gra nie używa normal map).

Wnioski dla nas (własne, z założenia „deferred = dużo tanich świateł + ambient per scena”): bogactwo bierze się z **wielu małych praktycznych źródeł** (lampy, okna, ekrany, ogień), każde z małym zasięgiem, i z **ambientu strojonego per lokacja**. To dokładnie §5.6 (wypełnienie per pokój) i §6.8. Nasz limit 16 świateł na element wymusza drobniejszy podział podłogi niż w silniku deferred.

**The Last Night (Odd Tales, Tim Soret).** Co da się przypisać twórcom:
- Wersja z game jamu 2014 (pixel art 2D): Soret pisze, że duża część nastroju pochodzi z jego triku z oświetleniem. Niewidoczne kolorowe punkty są rozsiane po scenie, a sprite'y postaci są **barwione przez interpolację między najbliższymi kolorami**. Już wtedy „ulepszali pixel art oświetleniem i post-processingiem”; pełna wersja ma mieć „złożone dynamiczne oświetlenie”. [Tim Soret, wątek na Twitterze (Thread Reader)](https://threadreaderapp.com/thread/976819508441681920.html)
- Pełna gra: według relacji prasy to pixel art 2D wyświetlany w przestrzeni 3D w Unity, a oświetlenie daje płaskim postaciom głębię (TechRaptor z pokazu E3 2017, znane z wyciągu; strona zwraca 403). [TechRaptor](https://techraptor.net/content/e3-2017-the-last-night-presentation-details), [80.lv](https://80.lv/articles/the-last-night-pixel-art-cyberpunk-open-world). Wikipedia podaje Unity. [Wikipedia](https://en.wikipedia.org/wiki/The_Last_Night_(video_game)). Nie znalazłem prelekcji ani breakdownu technicznego od studia.

Wnioski dla nas:
1. **„Sondy światła” dla postaci** (trik z jamu): w każdym pokoju posterunku kilka punktów z kolorem (pod świetlówką, przy oknie, w kącie, w drzwiach). `modulate` postaci to ważona odległością mieszanka 2–3 najbliższych. Koszt zerowy (bez świateł), skaluje się na cały posterunek, a postać „łapie” kolor pokoju przy przejściu korytarzem. Łączyć z §6.7 (rim) zamiast dokładać światła na postacie.
2. **Post-processing jako część oświetlenia:** u Soreta nastrój w dużej mierze robi post (glow, mgła, grading). U nas to glow HDR (§6.10), smugi (§6.2) i istniejący `post.gdshader`.

Inne gry z briefu: Octopath Traveler (wywiad Unreal: dodanie światła punktowego do efektów walki, żeby rzucały cienie postaci na otoczenie; strona zwróciła 403, znane z wyciągu wyszukiwarki) [Unreal Engine spotlight](https://www.unrealengine.com/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true). Sea of Stars („Radiant Lighting”, własny pipeline, cykl dnia i nocy; tylko materiały prasowe) [Sabotage](https://sabotagestudio.com/press-release/sea-of-stars-the-highly-anticipated-turn-based-rpg-from-sabotage-studio-primed-for-playstation-consoles-in-2023/). Replaced (własny Scriptable Render Pipeline w Unity z efektami z HDRP; inspiracje Limbo, Inside, The Last Night) [GamingBolt](https://gamingbolt.com/replaced-interview-inspirations-for-art-style-ranged-and-melee-combat-exploration-and-more). Kentucky Route Zero (prelekcja GDC 2014 „Scenography of KRZ”, za logowaniem) [GDC Vault](https://gdcvault.com/play/1020596/Scenography-of-Kentucky-Route). Dla Children of Morta, Blasphemous i Hyper Light Drifter nie znalazłem źródeł o technice oświetlenia.

## 8. Niezweryfikowane
- **Nic z przepisu nie zostało uruchomione.** Szczególnie do sprawdzenia w prototypie: (a) czy `PointLight2D` ze ścięciem w transformacji daje oczekiwany równoległobok (z kodu wynika, że tak, ale nie testowałem) i jak zachowuje się wtedy kierunek normal map (pozycja światła to origin węzła); (b) cząsteczki w `LIGHT_ONLY` + `ADD` (z kodu shadera wynika niewidoczność poza światłem); (c) koszt wypiekania plamy w GDScript.
- Pozycje słońca liczone przybliżonym algorytmem NOAA, bez refrakcji. Wschód i zachód w rzeczywistości są ok. 3–5 min wcześniej/później, a przy wysokości < 1° błąd jest największy. Dla gry bez znaczenia.
- Uzasadnienie „pochmurno w południe” to decyzja projektowa. Nie sprawdzałem statystyk zachmurzenia met.no dla lutego.
- Kolory w tabeli §4.2 to kolor ciała doskonale czarnego plus moje zgaszenie. Świetlówki i lampy wyładowcze nie są ciałami czarnymi (widmo liniowe); „zielonkawy” odcień to konwencja filmowa, nie pomiar. Nie wiem też, czy Godot przy `use_hdr_2d` konwertuje kolory `Color` świateł z sRGB do liniowego (od tego zależy, jak wyjdą wartości); stroić na zrzutach.
- Jakie lampy były w norweskich biurach i na ulicach w 2010 r. (T8 830/840, sód, rtęć): wiedza ogólna, bez źródła norweskiego. Wycofywanie żarówek w UE od 1.09.2009 (rozporządzenie 244/2009) jest potwierdzone, ale objęcie Norwegii przez EOG już nie.
- Eastward: cytat Feng Ye znany tylko z wyciągu wyszukiwarki, bo strona Red Bull nie wczytała się. The Last Night: technika pełnej wersji znana tylko z relacji prasy. Octopath: strona Unreal zwróciła 403, treść z wyciągu.
- Limit 16 świateł na canvas item odczytany z `master`. Nie sprawdzałem, czy w 4.7.2 jest identyczny (stała jest od 4.0, zgłoszenia z 4.2–4.3 mówią o 15–16).
