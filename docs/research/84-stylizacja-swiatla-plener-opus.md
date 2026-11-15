# 84 - Stylizacja światła i cieni w plenerze (i we wnętrzu): jeden algorytm

Data: 2026-11-15. Ticket: [39](../wayfinder/tickets/39-stylizacja-swiatla-plener-research.md). Kontynuacja
[82](82-stylizacja-swiatla-pixel-art.md). Niezależna wersja researchu [83](83-stylizacja-swiatla-plener.md): z 83 wzięte
tylko tropy, każde twierdzenie sprawdzone osobno (różnice w sekcji 10).

Pytanie: jakim **jednym** algorytmem zamienić dokładnie policzone światło (bufor z ticketów 36 i 14) na pixel art, żeby
działał przez konstrukcję i na stromych przejściach (okna, lampy, cień słońca), i na bardzo łagodnych (niebo zasłaniane
przez budynki, pochmurny dzień). Ma to być bez gałęzi na rodzaj sceny lub źródła i bez osobnych stałych dla wnętrza i ulicy.

## Uczciwe zastrzeżenie o źródłach

Oceny: **[P]** = źródło pierwotne (autor, dokumentacja, kod, artykuł twórcy) przeczytane w tej sesji; **[S]** = wtórne
(wywiad, prasa, wiki, forum, streszczenie z wyszukiwarki, rekonstrukcja fanów); **[N]** = szukane, nie znalezione albo
nieczytelne (403, sam film, PDF z obrazkami); **[Wn]** = mój wniosek inżynierski albo obliczenie, a nie twierdzenie o grach.

Wynik negatywny, ten sam co w 82 i 83, ale sprawdzony szerzej: **żadna przeczytana gra pixel art nie opisuje miękkiego,
liczonego zasłaniania nieba w plenerze, stylizowanego poziomami lub ditherem.** Gry mają w plenerze albo twarde cienie
i płaski lub stopniowany ambient (LUT, paleta), albo gładkie światło HD nad pikselami. Jest jednak mocne źródło
pierwotne o *ręcznej* stylizacji przejść (saint11, Pixel Parmesan) i o technice progu o stałej szerokości na ekranie
(Gustavson, GPU Gems, Valve). Na tych dwóch filarach opiera się rekomendacja.

Nieczytelne, a warte obejrzenia ręcznie: slajdy Never's End (GDC 2026, Juckett; PDF z samymi obrazkami, kopia lokalna
pobrana przez agenta, nieobejrzana), talk Ferrariego (GDC 2016, za logowaniem), slajdy Motomury (Guilty Gear Xrd, GDC
2015, połączenie odrzucone), wątek TIGSource Pope'a (403), slajdy INSIDE (Playdead, GDC 2016), Ben Golus (403).

## 1. Jak działa dziś wygląd A (z kodu) i dlaczego na ulicy jest siatka

Pliki: `style-lab/lighting/light_common.gdshaderinc` (`light_levels`, `dither_step`, `key_style`),
`style-lab/lighting/lit.gdshader` (`view_level`), `light_map.gdshader` / `street_map.gdshader` (wywołanie),
`sun_map.gd` / `street_map.gd` (`view_levels`, `light_res`), `display.gdshader` (post).

- **A** (`look = 1`): `e = log2(luma(światło + ambient)) / level_stops` (krok 0,5 EV), `k = floor(e)`, w górnej części
  kroku o szerokości `level_band` = 0,3 kroku `t` rośnie od 0 do 1 i `bayer4(px) < t` podnosi poziom; wynik
  `q = max(2^((k+0,5)·stops), amb)`, kolor `rgb · (q − amb) / own` (odcień zachowany, kwantyzowana luminancja).
  Szerokość pasa ditheru jest więc **stała w EV (0,15 EV), a nie w pikselach**. [kod]
- Przy `light_res = 1` A liczy się w shaderze bufora (piksel świata). Przy `light_res > 1` liczy go shader sprite'ów
  (`view_level`) w pikselu widoku z bilinearnie czytanego bufora (`light_map_smooth`, alfa = luma ambientu). Bayer jest
  zakotwiczony w pikselu widoku świata (`floor(world_pos · light_res)`), a na postaci w pikselu paska postaci. [kod]
- **B/C** (`look = 2/3`): osobny próg widoczności dla każdego źródła kluczowego (`key_style` dla słońca, okien nocą i lamp),
  liczony w pikselu świata, oraz cień kontaktowy dla nieba. [kod] To jest progowanie **per źródło**, czyli dokładnie
  to, czego wymaganie 1 zabrania. Przy ×2 daje ono schodki 2 px obok ditheru 1 px.
- Post (`display.gdshader`) dodaje **ziarno filmowe** (`grain = 0.015`, `hash` zależny od `TIME`), czyli losowy szum
  na każdej klatce. Na ulicy włączona jest też poświata renderera (glow, ticket 14). Oba elementy rozmywają albo
  zaszumiają strukturę pikseli. Na powiększonym zrzucie widać pod ditherem gładki szum. [kod, zrzut] Nie należy to do
  stylizacji światła, ale wpływa na ocenę wyglądu (sekcja 8).

**Zrzut `style-lab/shots/t14/user/siatka.png`** (obejrzany w powiększeniu ×4): na chodniku pod fasadami i wokół wejścia
widać szerokie łuki ditheru o szerokości kilkudziesięciu pikseli. Cała jezdnia pokryta jest polem szachownicy o
zmiennej gęstości. Ostre krawędzie (słupy, lampy) są czyste. Siatka dotyczy więc wyłącznie płytkich gradientów.

**Liczby [Wn, obliczone].** Model: ulica między dwoma rzędami fasad (nieskończenie długie ściany, wysokość H = 9 m,
odstęp 14 m), tylko niebo, bez ambientu (najgorszy przypadek). Udział nieba z czynnika widzenia ściany wynosi
`F(x) = ½(1 − x/√(x² + H²))`, a `v = 1 − F(x) − F(14 − x)`. Skala ekranu: 24 px na metr głębokości (`px_per_m` 40 ×
`depth_factor` 0,6). Skrypt jest w notatkach sesji, wyniki:

| odległość od fasady | v (niebo) | EV | gradient EV/px | krok 0,5 EV w px | pas A (0,3 kroku) w px |
|---|---|---|---|---|---|
| 0,5 m | 0,44 | −1,17 | 0,0062 | 81 | 24 |
| 2 m | 0,51 | −0,98 | 0,0047 | 107 | 32 |
| 3 m | 0,55 | −0,88 | 0,0037 | 136 | 41 |
| 5 m | 0,60 | −0,75 | 0,0018 | 285 | 85 |

Wewnątrz, przy lampie (1/d², 3 m od żarówki), gradient wynosi ok. 0,024 EV/px, więc pas A ma ok. 6 px. Na krawędzi
cienia słońca (półcień 6 cm ≈ 2,4 px, skok rzędu 2 EV) pas ma poniżej 1 px. **Ten sam pas EV ma więc szerokość od <1 px
do ~85 px**, zależnie od stromości. To jest cała przyczyna siatki: nie Bayer i nie kroki, tylko pas zdefiniowany w
jednostkach światła zamiast w pikselach. [Wn]

**Drugi, dotąd nienazwany problem [Wn, obliczone]: przesuwanie się granic poziomów w czasie.** Ekspozycja jest stała
na przestrzeń (ADR 0007, `exposure.gd`: „nothing follows the player”), więc gdy niebo jaśnieje lub ciemnieje w ciągu
dnia, całe `e` przesuwa się o stałą, a izolinie poziomów wędrują po ulicy. Przy gradientach z tabeli zmiana jasności
nieba o 3% przesuwa granicę o **12 px** (3 m od fasady) do **24 px** (5 m). Ulica przelicza się co 5 minut gry w 16
pasach, więc granice będą skakać o dziesiątki px przy każdym przeliczeniu. We wnętrzu tego nie widać, bo gradienty są
strome. Rozwiązanie jest w sekcji 6 (kotwica siatki).

## 2. Pytanie 1: czy gry pokazują miękkie zasłanianie nieba w plenerze i jak oddają pochmurny dzień

| Gra / źródło | Co ustalono | Ocena |
|---|---|---|
| Graveyard Keeper | Ambient jako gradient po porze dnia, ok. 10 LUT-ów koloru na porę dnia (robione w Photoshopie ze zrzutu). Cienie to obracane sprite'y: 1 od słońca i do 3 od najbliższych świateł. Brak AO i zasłaniania nieba, o pochmurnym dniu nic. [blog twórcy](https://slava.lazybeargames.com/graveyard-keeper-how-the-graphics-effects-are-made) | [P], 2018. Mocne dla zasady „ambient + LUT + twarde cienie” |
| Rain World | Światło i cień rysuje się w edytorze poziomu jako jedną dużą maskę: „re-draw what parts of the level you wanted to be lit and what parts should be in shadow”, render ok. 10 min, „The sunlight is able to fade back and forth” ([archiwum devlogu](https://candlesign.github.io/Rain-World-Devlog/Pages/014)). Paleta ma 3 wiersze w słońcu i 3 w cieniu, czyli twarde klasy słońce/cień i 3 tony w każdej ([rekonstrukcja fanów](https://gist.github.com/EtiTheSpirit/97dfdc63f667e19acb6314dc8c1e2d18)) | devlog: [P] przez lustro fanów; paleta: [S] |
| Disco Elysium | Scena bez świateł w silniku: mapa mnożnika cienia (alfa albedo), ręczna mapa kierunku światła i globalne kolory słońca i cienia na porę dnia. Metoda „relies on lighting conditions being very low frequency”. [devblog](https://discoelysium.com/devblog/2016/02/02/shedding-light) | [P]. Malowane, nisko-częstotliwościowe światło, kolor po porze dnia |
| Octopath / HD-2D | Nowoczesne gładkie światło UE4 nad sprite'ami, dodatkowe światło punktowe dla cieni postaci, bloom, DoF i mgła w poście ([Wikipedia](https://en.wikipedia.org/wiki/HD-2D)). Talk z Unreal Fest 2019 tylko jako wideo | [S]. Bez kwantyzacji, nie jest wzorem |
| The Last Night | Render 360×150 ×2, później 640×270, „complex dynamic lighting”, wiele warstw paralaksy ([wątek Soreta, Thread Reader](https://threadreaderapp.com/thread/976819508441681920.html)). Rozdzielczości samego światła nie ustalono | [S] |
| Eastward | Własny silnik, „shader textures and lighting systems”, światło pokazuje pogodę i porę dnia, ręcznie malowane mapy wypukłości ([Game Developer](https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures)). O cieniach i niebie nic | [S] |
| Sea of Stars | Dynamiczne światło we własnym pipeline, jedna osoba od 2018, assety podporządkowane wymaganiom światła ([MobileSyrup](https://mobilesyrup.com/2023/09/11/sea-of-stars-level-design-sabotage-studio-thierry-boulanger-interview/)) | [S], bez algorytmu |
| Children of Morta | Światło w rozdzielczości HD nad pikselami rozciągniętymi ~4× (za 82, [TechRaptor](https://techraptor.net/content/how-dead-mage-created-the-art-for-children-of-morta)) | [S], nie weryfikowane ponownie |
| Never's End (GDC 2026) | Talk „How We Draw a 3D Sprite World”: dynamiczne światło ze sprite'ową estetyką ([post](https://www.ryanjuckett.com/how-we-draw-a-3d-sprite-world-gdc2026/), [PDF](https://www.hypersect.com/gdc2026/GDC_2026_NeversEnd.pdf)) | [P] istnienie, treść [N] (slajdy jako obrazy). **Najbardziej obiecujące źródło do obejrzenia ręcznie** |
| Kingdom, Hyper Light Drifter, Blasphemous, Signalis, Dead Cells, Nectarmancer, Blessings of the Forge | Brak opisu zasłaniania nieba lub kwantyzacji światła w przeczytanych źródłach (Nectarmancer: mapy krawędzi, światła punktowe i kierunkowe, [80.lv](https://80.lv/articles/how-pixel-art-lighting-was-set-up-in-seamless-world-of-nectarmancer) [P]; Blessings of the Forge i Kingdom za 82/83, nie weryfikowane ponownie) | [N]/[S] |

**Fakty:** każda przeczytana gra z dynamicznym światłem rozwiązuje plener na jeden z trzech sposobów:
(a) twarde cienie kierunkowe + ambient stopniowany po porze dnia (LUT, kolor),
(b) ręczna maska światła/cienia z kilkoma tonami w palecie (Rain World),
(c) gładkie światło HD nad pikselami (HD-2D, Children of Morta).
Żadna nie opisuje pochmurnego dnia jako osobnego algorytmu. Pora dnia i pogoda to kolor ambientu lub LUT.

**Wniosek [Wn]:** miękkie zasłanianie nieba w pixel arcie jest rzadkie, bo jest drogie i trudne do stylizacji, a nie
dlatego, że źle wygląda. Rysowane ręcznie odpowiedniki istnieją: Rain World rysuje cień jako płaskie pole jednego tonu,
a Disco Elysium maluje nisko-częstotliwościowy mnożnik. Oba robią z łagodnego cienia **kilka płaskich obszarów z
wyraźną granicą**, a nie gładki gradient ani pole ditheru. Pochmurny dzień to u nas przypadek, w którym zostaje
wyłącznie niebo, czyli same płytkie gradienty. **To przypadek testowy numer jeden.**

## 2b. Szersze tło: stare gry, poradniki pikselarzy, ilustracja i komiks

| Obszar | Co ustalono | Ocena |
|---|---|---|
| saint11 (Pedro Medeiros), artykuł 5 | „a long step should have a proportionally long anti-alias halftone strip”; „The amount of pixels you should fill depends mostly on the length of the step and the available colors”; banding „making the object look flat”; brak antyaliasu na liniach 45° i prostych. [saint11](https://saint11.art/pixel_art_articles/article5/) | [P]. Dotyczy krawędzi linii, nie tonów, ale ta sama zasada: przejście proporcjonalne do kroku |
| Pixel Parmesan, dithering | „generally works best when used sparingly”; „Extraneous dithering often creates visual noise or the unwanted illusion of texture”; „Rather than transitioning between every pattern available, try selecting just a few”; wzór „more obvious as … displayed at a larger scale”. [Pixel Parmesan](https://pixelparmesan.com/dithering-for-pixel-artists) | [P]. Najbliższe naszemu objawowi: pole ditheru czyta się jako faktura |
| Mark Ferrari (LucasArts, EGA) | Dither szachownicą na 16 kolorach jako „mixing paint”; na CRT „the checkerboard dither blurred into a solid third colour”; to stało się „the new house style for Lucasfilm Games”. [CGMagazine](https://www.cgmagonline.com/articles/an-interview-with-pixel-artist-extraordinaire-mark-ferrari) | [P] wywiad. Bez szerokości pasów; talk GDC 2016 [N] |
| 16 bit (SNES) | Niebo przez HDMA: kolor tła zmieniany co kilka linii, czyli pasy bez ditheru ([OpenSNES](https://k0b3n4irb.github.io/opensnes/examples_graphics_effects_hdma_gradient.html)) | [S] homebrew/fora |
| Lospec, generator wzorów | Narzędzie robi pasy ditheru „the same width”, dla nieba ([Lospec](https://lospec.com/articles/dither-pattern-generator-a-new-free-online-tool-for-pixel-art)) | [S] |
| Sierra SCI0, Amiga/DPaint | Nic pierwotnego o wypełnieniach ditherem | [N] |
| Komiks: raster, screentone | Płaskie tony na całe powierzchnie, rastry gradientowe jako wyjątek; w rastrze gradientowym rośnie kropka, a komórka ma stały rozmiar ([Clip Studio Tips](https://tips.clip-studio.com/en-us/articles/2418)) | [S] |
| Cel shading, Guilty Gear Xrd | Próg światła na normalnej: „the slightest difference in the surface normal may end up as a huge blotch”, więc artyści poprawiali normalne, „to make sure that they had clean areas of only shadow or light” ([PDF Motomury](https://www.ggxrd.com/Motomura_Junya_GuiltyGearXrd.pdf), nieotwarty; cytaty z wyszukiwarki i Polycount) | [S] |
| Obra Dinn (Pope) | „Trying a new dither matrix. Blue noise instead of Bayer” (2014); „Reducing 1-bit dot flicker via sphere-mapped dither pattern” (2017), cytaty przez [Zucconiego](https://www.alanzucconi.com/?p=10365); Bayer dla ludzi i obiektów, niebieski szum dla otoczenia ([Surma](https://surma.dev/things/ditherpunk/)) | [S]; TIGSource [N] |
| Kentucky Route Zero, Blackwell, NORCO, Gemini Rue | Brak opisu techniki światła | [N] |

**Zasady wyprowadzone [Wn, z podanym wsparciem]:**
1. **Kilka płaskich tonów.** Rozległy, łagodny spadek światła to kilka płaskich pól (Rain World [P], Disco Elysium [P],
   komiks [S], cel shading [S]).
2. **Dither tylko na granicy pól, w wąskim pasie.** Nigdy nie wypełnia całego obszaru, bo wtedy czyta się jako faktura
   lub szum (Pixel Parmesan [P]).
3. **Mało wzorów w pasie, najlepiej jeden lub dwa** (szachownica 50%, ewentualnie 25/75) zamiast całej rampy 16 gęstości
   (Pixel Parmesan [P], Ferrari [P]).
4. **Stały rozmiar komórki wzoru na ekranie i stała faza** (raster [S], Dither3D [P] w sekcji 3, Pope [S]).
5. **Kształt cienia ma być czysty: „only shadow or light”.** Próg na gładkim polu łatwo daje plamy (Xrd [S]), dlatego
   pole przed progiem ma być gładkie i nisko-częstotliwościowe. Nasz bufor taki jest (dokładne liczenie z ticketu 36).

Napięcie między saint11 („długi krok, proporcjonalnie długi pas”) a zasadą 2: saint11 mówi o antyaliasie *linii* przy
2–4 kolorach, gdzie pas to kilka pikseli. Przy 85 px pasa na ulicy proporcjonalność daje dokładnie dzisiejszy błąd.
Poradniki o dużych powierzchniach (Pixel Parmesan, raster) wskazują na pas ograniczony. Wniosek [Wn]: **pas ma rosnąć
z długością kroku tylko do kilku pikseli i tam się zatrzymać.** To właśnie daje formuła w sekcji 6.

## 3. Pytanie 2: szew ditheru w px ekranu, posteryzacja bez ditheru, inne wzory

**Fakty (technika):**
- Próg z antyaliasem o szerokości jednego piksela niezależnie od skali: `aastep` „the edge is smoothed across the width
  of a single fragment to create anti-aliasing at any scale” ([glsl-aastep](https://github.com/glslify/glsl-aastep)) [P];
  Gustavson: „use the automatic derivatives dFdx() and dFdy() to compute the step width” ([tutorial](https://itn-web.it.liu.se/~stegu76/webglshadertutorial/shadertutorial.html)) [P];
  GPU Gems rozdz. 25: `filterwidth` z `ddx/ddy`, „will generally overestimate the change”, wariant teksturowy
  ok. 3 instrukcje + 1 odczyt ([GPU Gems](https://developer.nvidia.com/gpugems/gpugems/part-iv-image-processing/chapter-25-fast-filter-width-estimates-texture-maps)) [P].
- Dither3D: kropki „stick to surfaces, and yet the dot sizes and spacing remain approximately constant on the screen”,
  przez dodawanie i usuwanie kropek (samopodobieństwo Bayera); kontrast progu powiązany z pochodną; koszt 1 odczyt 2D +
  1 odczyt 3D na kanał ([README](https://github.com/runevision/Dither3D), kod przez streszczenie) [P].
- Dither uporządkowany jest deterministyczny i równoległy per piksel; Bayer „very structured … especially at lower
  levels”, niebieski szum „natural and organic”; progować w liniowym świetle ([Surma](https://surma.dev/things/ditherpunk/)) [P].
  U nas bufor jest liniowy (HDR), a sRGB robi dopiero `display.gdshader` [kod], więc to jest spełnione.
- **Nie znaleziono** gry ani devlogu z opisaną techniką „pas ditheru o stałej szerokości w px na granicy poziomu”.
  Typowe shadery posteryzacji w Godot dodają dither do wartości przed `floor` na całym obrazie
  ([godotshaders](https://godotshaders.com/shader/pixel-quantization/)) [S], co daje ten sam błąd co nasz A.

**Odpowiedzi [Wn]:**
- **Pas w px ekranu zamiast części kroku: tak.** To jest `aastep` z ditherem zamiast alfy. Dobrze ugruntowane
  (Gustavson, GPU Gems, Valve), ale w wersji z ditherem uporządkowanym bez precedensu w źródłach. Konkret w sekcji 6.
- **Posteryzacja bez ditheru:** ta sama formuła przy szerokości szwu 0. Najczystsze płaskie pola, ale granice na płytkim
  gradiencie są ostre jak warstwice, a na ukośnych izoliniach widać schodki. Zostaje jako pokrętło i punkt odniesienia,
  nie jako wariant docelowy.
- **Dither tylko w półcieniu źródeł kierunkowych:** jako reguła „per źródło” odpada (wymaganie 1, porażka z ticketów
  36/37). **Wychodzi jednak sam z formuły:** gdzie cały krok mieści się w szwie (półcień słońca, brzeg plamy okna,
  pierścień lampy), szew obejmuje cały krok i wygląda jak dither półcienia. Gdzie krok jest długi (niebo), zostaje pole
  i wąski szew. Formuła nie wie, które to źródło.
- **Niebieski szum:** odpada. Gra ma Bayera (spójność), niebieski szum nie jest samopodobny (README Dither3D) i w wąskim
  szwie 2–3 px jest nie do odróżnienia od losowego ziarna, którego człowiek nie chce.
- **Linie (raster liniowy, kreskowanie):** to jest tylko inna macierz progów, formuła działa z każdą. Brak źródła, że
  wygląda lepiej. Opcjonalnie do zabawy, niezalecane w prototypie.
- **Szachownica 50% w szwie** (zamiast rampy Bayera 4×4) zgadza się z zasadą 3 i z praktyką EGA/LucasArts. To jest
  wariant 2.

## 4. Pytanie 3: rozdzielczość bufora względem widoku

**Fakty:** bufor stoi w pikselu świata; A przy ×2 liczy się w pikselu widoku z bilinearnej interpolacji; bufor ×k
zabijał wydajność (ticket 37, człowiek) [kod/ticket]. Valve (Green 2007): pole zapisane w niskiej rozdzielczości,
interpolowane bilinearnie i progowane daje ostrą krawędź w położeniu podtekselowym, lepiej dla pola odległości niż
pokrycia, które daje „wiggles” (PDF nieczytelny, streszczenia) [S]. Joint bilateral upsampling (Kopf 2007) wymaga
przewodnika w wysokiej rozdzielczości (głębia, normalne) ([abstrakt](https://www.johanneskopf.de/publications/jbu)) [P].

**Wnioski [Wn]:**
- Dla płytkich gradientów rozdzielczość bufora nie ma znaczenia: bufor ×2 nie usunie siatki, a kosztuje 4×.
  **Bufor ×2 tylko na ulicy odpada**, zarówno przez wymaganie 1, jak i przez koszt bez zysku.
- Dla ostrych krawędzi wystarcza próg na interpolowanym buforze (metoda Valve): półcień słońca ma ok. 2,4 px, więc
  bufor jest gładki w skali teksela, a to jest przypadek „pole odległości”, nie „pokrycie”. **Cała stylizacja w pikselu
  widoku z `light_map_smooth`, także przy ×1** (przy ×1 bilinear w środku piksela zwraca dokładnie teksel). Jedna
  ścieżka zamiast dwóch (`light_levels` w buforze przy ×1 i `view_level` w sprite'ach przy ×2) i koniec schodków 2 px
  obok ditheru 1 px, bo nie ma już B w pikselu świata.
- Upsampling z zachowaniem krawędzi (bilateralny) nie ma tu przewodnika ani źródeł z gier. Odpada. Znana półpikselowa
  poświata na krawędziach powierzchni (ticket 37) zostaje bez zmian i nie jest częścią tego ticketu.
- Rozmiar komórki ditheru (1 px widoku czy 1 px grafiki) to decyzja wyglądu, nie algorytmu. Dziś jest to 1 px widoku i
  tak zostawiam (człowiek wybrał A ×2). Formuła działa tak samo w obu jednostkach, jeśli gradient mierzy się w tych samych.

## 5. Pytanie 4: jeden algorytm dla wnętrza i pleneru

**Wymaganie człowieka: jeden.** Sprawdzam, czy da się je spełnić przez konstrukcję.

**Fakty:** Graveyard Keeper, Rain World i Disco Elysium mają jeden pipeline z różnymi **danymi** (LUT, maska, kolory
pory dnia), a nie różnymi algorytmami [P].

**Wniosek [Wn]: tak, jeśli każda stała wyglądu ma jednostkę niezależną od sceny.** Dziś `level_band` ma jednostkę
„część kroku EV”, więc jego szerokość w px zależy od sceny i to jest źródło konfliktu wnętrze/ulica. Po zmianie:
- `level_stops` (EV na poziom) to stała percepcyjna, ta sama wszędzie;
- `seam_px` (szerokość szwu w px) to stała ekranowa, ta sama wszędzie;
- `level_ref` (kotwica siatki) to nie stała, tylko **wielkość fizyczna o jednej definicji** (sekcja 6), wyliczana tak samo
  dla domu i ulicy.

Wnętrze i ulica różnią się tylko danymi (gradientem światła), a formuła sama daje dither półcienia na stromych
przejściach i pola ze szwem na łagodnych. **Nie ma `if` na scenę ani na źródło i nie ma dwóch zestawów stałych.**

Ryzyko, że jedno `level_stops` nie pasuje obu scenom: wnętrze ma duży zakres EV (lampa vs kąt), ulica w pochmurny dzień
mały (~1 EV na całą szerokość). Przy 0,5 EV ulica dostaje 2–3 pola, co jest zgodne z zasadą 1. Gdyby człowiek uznał,
że to za mało lub za dużo, jest to wynik do zgłoszenia, a nie powód do drugiego zestawu stałych.

Uwaga poza stylizacją [Wn]: model światła ma dziś jedną różnicę wnętrze/ulica, `sky_objects = 0` na ulicy (niebo
zasłania tylko architektura), a w domu zasłaniają też obiekty (ticket 14). To parametr modelu, nie stylizacji. Wprowadzono
go, bo cień nieba postaci dawał ciemną plamkę. Po zmianie stylizacji warto sprawdzić, czy jest jeszcze potrzebny
(do decyzji człowieka, poza zakresem tego ticketu).

## 6. Algorytm (do wdrożenia od razu)

### 6.1 Wzory

Dla piksela widoku: `m = texture(light_map_smooth, …)` (rgb światło, a = luma ambientu), `own = luma(m.rgb)`,
`Y = own + m.a`.

1. **Wartość w krokach, zakotwiczona:** `s = log2(Y / Y_ref) / level_stops + 0.5`.
   `Y_ref` to luma światła **otwartego nieba na płaskim terenie przy ekspozycji tej przestrzeni + ambient**. Na ulicy:
   `luma(street_sky) + luma(room_ambient[0])`; w domu ta sama wielkość dla ekspozycji pokoju. Liczy ją CPU tam, gdzie
   dziś liczy `street_sky` / `skies`. Dzięki `+0.5` otwarte niebo leży w środku poziomu.
2. **Gradient w krokach na piksel widoku:** `g = length(vec2(dFdx(s), dFdy(s)))`.
3. **Szerokość szwu w krokach, ograniczona do całego kroku:** `W = clamp(seam_px · g, 0, 1)`.
4. **Poziom z ditherem uporządkowanym:** `k = floor(s + W · (b − 0.5))`, gdzie `b ∈ (0,1)` to próg wzoru w tym pikselu.
5. **Odtworzenie:** `q = max(Y_ref · 2^(k · level_stops), m.a)` (środek poziomu k: tam `s = k + 0.5`), kolor `m.rgb · (q − m.a) / own`.

Dlaczego to działa przez konstrukcję:
- Gdy `W = 1`, wzór 4 to zwykły dither uporządkowany między sąsiednimi poziomami. Tak zachowuje się krawędź stroma, na
  której krok jest węższy niż `seam_px`: półcień słońca, brzeg plamy okna, bliski pierścień lampy.
- Gdy `W < 1`, przejście przy każdej granicy całkowitej ma szerokość `W` w krokach, czyli `W / g = seam_px` pikseli
  na ekranie. Reszta kroku to płaskie pole. Tak zachowuje się niebo zasłaniane przez budynki i pochmurny dzień.
- Gdy `g = 0`, nie ma izolinii i nie ma ditheru.
- Wiele granic w kilku pikselach (skok 2–3 EV na krawędzi cienia) obsługuje się samo: każdy piksel wybiera poziom
  niezależnie, bez logiki „najbliższej granicy”.
- Szew jest **wyśrodkowany** na izolinii, a nie „pod górną krawędzią kroku” jak dziś. Dzięki temu położenie granicy
  nie zależy od `seam_px`.
- Kotwica: gdy niebo zmienia jasność o czynnik c, w obszarach oświetlonych tylko niebem `Y` i `Y_ref` mnożą się przez
  c, więc `s` stoi w miejscu. Granice cienia nieba nie wędrują w ciągu dnia (sekcja 1: 12–24 px na 3% bez kotwicy).
  Słońce w ruchu dalej przesuwa swoje krawędzie, tak jak powinno. Lampy o zmierzchu przesuwają się o `Δs/g`, co jest
  małe, bo ich gradient jest stromy.

Przykład na modelu z sekcji 1 (H = 9 m, ulica 14 m, pochmurno) [Wn, obliczone]: granice wypadają przy −0,25 EV (nie ma
ich na ulicy, bo cała leży poniżej), −0,75 EV (4,9 m od fasady) i −1,25 EV (przy samej fasadzie). Na ulicy są więc **dwa
płaskie pasy**: środek jezdni i 4,9 m przy każdej fasadzie, rozdzielone szwem 3 px. Dziś w tym samym miejscu jest pas
ditheru 85 px.

### 6.2 Pseudokod (lit.gdshader)

Godot: `dFdx`/`dFdy` są „Available only in the fragment shader” ([dokumentacja funkcji](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shader_functions.html)) [P],
a „It's also possible to send data from fragment to light processors using varying keyword” ([język shaderów](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html)) [P].
Przykład w dokumentacji jest dla `spatial`, więc dla `canvas_item` trzeba to sprawdzić przy wdrożeniu. Dlatego bufor
czyta się w `fragment()`, a `light()` tylko kwantyzuje.

```glsl
uniform float level_stops = 0.5;
uniform float seam_px = 3.0;      // szerokość szwu w px widoku (0 = posteryzacja bez ditheru)
uniform int seam_pattern = 0;     // 0: Bayer 4×4, 1: szachownica 50% (wariant 2)
uniform float level_ref = 1.0;    // Y_ref: luma otwartego nieba + ambient, przy ekspozycji przestrzeni

varying vec4 lm;                  // bufor (rgb światło, a ambient)
varying float lm_s;               // s
varying float lm_g;               // |grad s| w px widoku
varying vec2 lm_px;               // piksel wzoru

float pattern(vec2 px) {
	ivec2 p = ivec2(floor(px)) & 3;
	if (seam_pattern == 1) {                      // uniform: bez rozbieżności
		return ((p.x + p.y) & 1) == 0 ? 0.25 : 0.75;
	}
	int a = p.x ^ p.y;                            // Bayer 4×4 bez tablicy:
	int v = ((a & 1) << 3) | ((p.y & 1) << 2) | (a & 2) | ((p.y >> 1) & 1);
	return (float(v) + 0.5) / 16.0;               // = dzisiejsza macierz m[16]
}

void fragment() {
	// … dotychczasowy fragment …
	vec2 fine = …;                                // jak dziś w light(): pasek postaci lub świat
	lm = texture(light_map_smooth, fine / map_size);
	float y = dot(lm.rgb, vec3(0.2126, 0.7152, 0.0722)) + lm.a;
	lm_s = log2(max(y, 1e-5) / level_ref) / level_stops + 0.5;
	lm_g = length(vec2(dFdx(lm_s), dFdy(lm_s)));  // poza gałęziami
	lm_px = floor((is_actor ? world_pos - actor_rect.xy : world_pos) * light_res);
}

vec3 levels(vec4 m, float s, float g, vec2 px) {
	float own = dot(m.rgb, vec3(0.2126, 0.7152, 0.0722));
	if (own < 1e-6) {
		return m.rgb;
	}
	float w = clamp(seam_px * g, 0.0, 1.0);
	float k = floor(s + w * (pattern(px) - 0.5));
	float q = max(level_ref * exp2(k * level_stops), m.a);
	return m.rgb * (q - m.a) / own;
}
// light(): w gałęzi bufora: map = view_levels ? levels(lm, lm_s, lm_g, lm_px) : texture(light_map, …).rgb;
```

Zmiany poza `lit.gdshader`:
- `sun_map.gd` / `street_map.gd`: `view_levels = (look == 1)` niezależnie od `light_res`, bez stylizacji w shaderze bufora.
  `light_levels` w `light_common` przestaje być używane i może zostać usunięte. B/C (`key_style`, `contact_shade`)
  zostają tylko jako porównanie w F1 albo do usunięcia (decyzja człowieka).
- CPU ustawia `level_ref` (`Lit.set_all`) przy każdej zmianie nieba, ekspozycji lub ambientu. W domu z różnymi
  ekspozycjami pokoi: tablica `level_ref[4]` indeksowana jak `room_ambient`, alfa bufora bez zmian.
- Pokrętła dla krytyka (ticket 38): `poziom_ev` (bez zmian), `szew_px` (zastępuje `poziom_pas`), `szew_wzor`.
  W F1 do oceny dodatkowo przełącznik „kotwica siatki: tak/nie”, tylko na czas porównania.

**Plan awaryjny, jeśli varying fragment→light nie działa w `canvas_item` albo pochodne z quadów 2×2 dają widoczne
skoki szerokości szwu:** w `light()` dwa dodatkowe odczyty `light_map_smooth` przesunięte o 1 px widoku w x i y,
różnice skończone `s` (dwa dodatkowe `log2`). Formuła pozostaje bez zmian.

### 6.3 Koszt w shaderze i wydajność

| Element | Dziś (`view_level`) | Po zmianie (pochodne) | Plan awaryjny |
|---|---|---|---|
| Odczyty tekstury na piksel sprite'a | 1 (`light_map_smooth`) | 1 (przeniesiony do `fragment()`) | 3 |
| Transcendentalne | `log2`, `exp2` | `log2`, `exp2` | 3× `log2`, `exp2` |
| Pozostałe ALU | ~15 + Bayer z tablicy lokalnej | ~20 (pochodne, `length`, `clamp`); Bayer bitowo bez tablicy | ~30 |
| Varyingi | — | 7 floatów fragment→light | — |

[Wn, szacunek] Przy 1920×1080 (×2) i nakładaniu sprite'ów ~2× to ok. 4 mln wywołań na klatkę i kilkadziesiąt dodatkowych
milionów prostych operacji, czyli dziesiąte części milisekundy lub mniej na każdym dzisiejszym GPU. W Godot 4 `light()`
liczy się w tym samym przebiegu rysowania, raz na światło na fragment („all lighting is done during the regular draw
pass”, [canvas_item](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html)) [P],
a światło bufora to jedno światło. Bayer z lokalnej tablicy `int m[16]` z indeksem dynamicznym może trafić do pamięci
lokalnej na niektórych GPU, a wersja bitowa tego unika. Przy ×1 zmiana **zdejmuje** kwantyzację z shadera bufora, czyli
przeliczenia w oknie postaci i pasach ulicy robią mniej. **Nic z tego nie jest zmierzone**: przed i po trzeba zrobić
`--bench` (Dom 22:00 przy lampie, Ulica w ruchu).

## 7. Rekomendacja do prototypu (Poligon Ulica, sprawdzenie w Domu)

Oba warianty to **ta sama funkcja z sekcji 6** (jedna ścieżka, piksel widoku, kotwica `level_ref`). Różnią się wzorem
w szwie. Oba są wspólne dla wnętrza i ulicy, z tymi samymi stałymi.

### Wariant 1 (zalecany): poziomy EV + szew Bayera 4×4 o stałej szerokości, `seam_px` = 3
- Wygląd: płaskie pola, w szwie 3 px krótka rampa Bayera (kilka gęstości), na stromych krawędziach pełny dither
  między poziomami (jak dziś we wnętrzu, nieco węższy).
- Praca: implementacja 1,5–2 h (shader, `level_ref` na CPU w domu i na ulicy, ujednolicenie ścieżki ×1/×2, pokrętła F1),
  sprawdzenie 1,5–2 h: pochmurno na ulicy (12:24), słońce między domami, Dom przy oknie, lampie i drzwiach, ruch
  postaci, upływ czasu z kotwicą i bez, `--bench`. **Razem 3–4 h.**
- Wydajność: jak w 6.3, oczekiwany wpływ niemierzalny w kl./s. Przy ×1 możliwy drobny zysk.

### Wariant 2 (do porównania, +0,5 h): szew szachownicy 50%, `seam_px` = 4
- Przy `b ∈ {0,25; 0,75}` przejście to pas czystej szachownicy o szerokości `seam_px / 2` = 2 px między płaskimi
  polami. To klasyczny „pas szachownicy” z EGA i 16 bitów (zasady 2–3), bez gradientu gęstości.
- Na stromych krawędziach szachownica zamiast rampy, więc krawędź jest bardziej „rysowana”, a mniej miękka.
- Praca: przełącznik wzoru, kilka minut kodu, reszta to ocena. Wydajność taka sama jak wariantu 1.

Punkt odniesienia w tym samym kodzie: `seam_px = 0` (posteryzacja bez ditheru), żeby człowiek zobaczył, ile ditheru
w ogóle chce.

**Nie rekomendowane:**
- B/C (próg per źródło, cień kontaktowy nieba): łamią wymaganie 1 i liczą się w pikselu świata.
- Bufor ×2 tylko na ulicy: koszt 4× i nie usuwa siatki.
- Rozdzielenie nieba i źródeł kierunkowych na osobne kanały (82: B+D+E).
- Niebieski szum.
- Wygładzanie światła HD (Children of Morta, HD-2D): człowiek odrzucił gładki wygląd (ticket 37).

## 8. Kryteria oceny (żywo w Poligonie, nie na zrzutach)

- **Pochmurny dzień (tylko niebo), ulica:** brak pól szachownicy; 2–3 płaskie pasy równoległe do fasad; szew ≤ 3 px.
- **Upływ czasu** (przyspieszony zegar, kotwica tak/nie): granice cienia nieba stoją w miejscu; bez kotwicy skaczą.
- **Słońce między domami:** długie ostre cienie z krawędzią ≤ 3 px, bez schodków 2 px obok ditheru 1 px.
- **Dom:** plama okna, pierścień lampy, cień postaci przy oknie. Zmiana względem dzisiejszego A jest oczekiwana
  (węższy pas na łagodnych ogonach lamp i plam), porównać z gałęzią `t37-stylizacja`.
- **Ruch:** szwy nie migoczą (wzór zakotwiczony w pikselu widoku świata, jak dziś).
- **Uwaga przy ocenie:** ziarno filmowe (`grain` 0,015) i glow ulicy nakładają się na dither. Do oceny stylizacji warto
  je na chwilę wyłączyć, żeby nie mylić ziarna z wzorem (bez zmiany kodu: pokrętła istnieją).

## 9. Najsłabsze miejsca źródeł

- Żadna gra z listy nie ma przeczytanego opisu algorytmu stylizacji światła w plenerze. Tabela w sekcji 2 to w
  większości [S] lub [N]. Najmocniejsze pierwotne źródła o grach (Graveyard Keeper, Rain World, Disco Elysium) opisują
  światło **malowane lub z LUT**, a nie liczone.
- Zasady 1–5 wynikają z poradników (saint11, Pixel Parmesan [P]) i z wtórnych źródeł o komiksie i cel shadingu. Żadne
  źródło nie podaje szerokości szwu w px. Wartości 2–4 px to moja propozycja do strojenia.
- Technika `aastep` jest pierwotnie udokumentowana (Gustavson, GPU Gems), ale w wersji z ditherem uporządkowanym nie
  ma precedensu w źródłach. Valve (Green 2007) znam tylko ze streszczeń.
- Godot: `dFdx` tylko w `fragment()` [P]; varying fragment→light udokumentowany na przykładzie `spatial` [P]. Dla
  `canvas_item` jest to niesprawdzone (stąd plan awaryjny).
- Liczby z sekcji 1 pochodzą z modelu analitycznego (nieskończone ściany, bez ambientu), a nie z pomiaru bufora. Rzędy
  wielkości są wiarygodne, wartości dokładne nie. Skok 3% jasności nieba na 5 minut gry to wartość przyjęta, nie zmierzona.
- Koszty godzinowe i wydajnościowe to szacunki, niezmierzone.
- Część wyników web zebrali agenci pomocniczy w tej sesji. Ich cytaty oznaczone [P] pochodzą z otwartych stron.
  Osobiście sprawdziłem saint11, Disco Elysium i dokumentację języka shaderów Godot.

## 10. Różnice względem 83

- **Zgodne co do kierunku:** przyczyna siatki to pas w jednostkach EV; szew o stałej szerokości w px; bez bufora ×2 na
  ulicy; bez progów per źródło; Bayer zamiast niebieskiego szumu. Te wnioski zweryfikowałem niezależnie i dodałem liczby
  (sekcja 1).
- **Odrzucone:** akapit 83 „Doprecyzowanie człowieka” (dwa zestawy stałych wnętrze/plener) nie pochodzi od człowieka i
  przeczy wymaganiu 1. Tutaj jest **jeden zestaw stałych bez wyjątków**, a jednostki stałych są niezależne od sceny (sekcja 5).
- **Inna formuła:** 83 proponuje `t = clamp(1 + (f − 1) / min(w_px·g, 1))`, czyli pas pod górną krawędzią kroku i
  logikę „ułamka kroku”. Tutaj jest `k = floor(s + W·(b − 0,5))`, `W = clamp(seam_px·g, 0, 1)`: szew wyśrodkowany na
  izolinii, wiele granic w kilku pikselach obsługiwane naturalnie, a przy `W = 1` dokładnie zwykły dither uporządkowany.
- **Nowe: kotwica siatki `level_ref`.** 83 nie zauważa, że przy stałej ekspozycji granice poziomów wędrują po ulicy wraz
  z jasnością nieba (12–24 px na 3%). Tutaj są przywiązane do jasności otwartego nieba, z jedną definicją dla domu i ulicy.
- **Nowe: ograniczenie Godot.** `dFdx` nie działa w `light()`, tylko w `fragment()` [P]. 83 zakłada 4 odczyty tekstury
  w `light()`. Tutaj jest 0 dodatkowych odczytów (pochodne w `fragment()`, varying do `light()`) i plan awaryjny
  z 2 odczytami.
- **Nowe: jedna ścieżka dla ×1 i ×2.** Stylizacja tylko w shaderze sprite'ów, kwantyzacja zdjęta z shadera bufora.
- **Nowe: wariant 2 jest innym wzorem**, czyli szachownicą 50% w szwie zgodną z praktyką EGA i poradnikami. W 83
  wariant 2 to `w_px = 0`, który tutaj jest tylko punktem odniesienia.
- **Szersze źródła pierwotne:** Rain World (maska światła), Disco Elysium (devblog), saint11, Pixel Parmesan, Ferrari
  (wywiad), Gustavson, GPU Gems, dokumentacja Godot. Tabele 83 opierały się głównie na wywiadach i wiki.
- **Nowe obserwacje z kodu:** ziarno filmowe w `display.gdshader` i glow na ulicy zaburzają ocenę ditheru. Do tego
  `sky_objects` to różnica modelu dom/ulica, warta ponownego sprawdzenia.
