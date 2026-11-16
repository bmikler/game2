# 92 - Światło w cieniu w silniku: niebo, AO, odbicia i stylizacja A′ bez krawędzi z gradientów

Data: 2026-11-16. Kontynuacja [91](91-cien-w-cieniu.md) (fizyka) i [84](84-stylizacja-swiatla-plener-opus.md) (A′).
Pytanie: jak oświetlić obszar w cieniu i przedmioty w nim stojące tak, żeby skrzynia, ławka i stragan w cieniu kamienic
nie miały płaskiej, ciemnej plamy z ostrą krawędzią, a reguła była jedna dla całej sceny, bez wyjątków i bez suwaków.

Oceny: **[P]** = źródło pierwotne (artykuł, kod, dokumentacja, devblog twórcy) przeczytane w tej sesji;
**[P w 84]** / **[P w 91]** = źródło pierwotne przeczytane we wcześniejszym researchu, tu niesprawdzane ponownie;
**[S]** = wtórne (wywiad, prasa, forum, streszczenie z wyszukiwarki, abstrakt); **[N]** = szukane, nie znalezione;
**[Wn]** = mój wniosek inżynierski albo obliczenie; **[kod]** = odczyt z repo.

## Streszczenie

1. **Główna przyczyna to stylizacja, a nie fizyka [Wn, kod].** A′ ma szew o stałej szerokości 3 px niezależnie od
   długości kroku. Gradient wokół przedmiotu ma krok 0,5 EV na długości ok. 5–30 px, więc A′ robi z niego 1–2 płaskie
   pierścienie z wąskim szwem, czyli „krążek z krawędzią”. Na ulicy (krok 80–285 px) ta sama reguła daje pożądane
   płaskie pasy. **Jedna stała w px nie pasuje do obu skal.** Brakuje reguły zależnej od skali, którą 84 opisało
   słowami („pas rośnie z długością kroku tylko do kilku pikseli”), ale której nie wdrożono: dziś szew nigdy nie rośnie.
2. **Zalecana poprawka stylizacji: krótkie kroki ditherować w całości, długie zostawić jako pola z wąskim szwem.**
   Jedna formuła w `light_style.gdshader`, z jedną nową stałą w px ekranu (`full_dither_px`, propozycja 24). To jest
   wariant (b) z propozycji Claude'a, ale z górną granicą. Bez granicy (b) wraca do siatki z 84.
3. **Wariant (a) (poziomy tylko dla światła kierunkowego, niebo ciągłe) odradzam.** W cieniu budynku całe światło
   pochodzi z nieba, więc cała zacieniona ulica stałaby się gładkim gradientem HD. Człowiek odrzucił ten wygląd
   (ticket 37), a 84 odrzuciło rozdział nieba i słońca na kanały. Ma precedens w 3D (toon na N·L, AO mnożone osobno [S]),
   ale u nas uderza w ulicę, nie tylko w aureolę.
4. **Multi-bounce AO (Jimenez 2016) jest tani i poprawny, ale problemu nie rozwiązuje [Wn, obliczone].** Przy albedo
   0,2 zmienia −0,80 → −0,69 EV przy styku i −0,50 → −0,43 EV w 0,4 m. Badanie 91 daje w 30 cm −0,2…−0,3 EV. Odbicia
   to efekt rzędu 0,1–0,2 EV, a różnica w środkowym zasięgu wynosi 0,2–0,3 EV i ma inne źródło.
5. **Za ciemny środek to najpewniej geometria Brył, a nie brak odbić [Wn, obliczone].** Mój niezależny rachunek dla samej
   skrzyni 0,6 m daje w 0,4 m −0,21 EV, a dla pełnej bryły straganu 2×1×2,2 m −0,63 EV. Zmierzone −0,5 EV pasuje do
   wysokiej albo „pełnej” Bryły (stragan, ławka jako pełny klocek bez prześwitu), a nie do skrzyni. Zasłanianie nieba
   całkuje całą objętość Bryły, więc jest dużo wrażliwsze na „zapełnione” prześwity niż cień słońca, który człowiek
   zaakceptował z uproszczonych brył.
6. **„Krótki zasięg zasłaniania” (jak SSAO) odradzam [Wn].** Liczenie bliskiego zasłaniania osobno i mnożenie go przez
   dalekie sumuje przesłony, czyli robi dokładnie błąd, który człowiek wskazał („cienie się nie sumują”). Dzisiejsze pełne
   promienie do 1000 m nakładają przesłony poprawnie i to jest zaleta silnika.
7. **Gry nie liczą tego, co liczymy my [P/S/N].** Pixel art z dynamicznym światłem ma albo malowane lub wypalane
   „fałszywe odbicia” (Disco Elysium [P]), albo mapy normalnych i światła punktowe (Eastward, Dead Cells, Sea of Stars [S]),
   albo gładkie światło 3D (HD-2D [S]). Opisu kwantyzacji miękkiego zasłaniania nieba w pixel arcie nie znalazłem [N].
   Radiance cascades 2D to światło w płaszczyźnie („flatland”) i nie pasuje do rzutu 3/4 z bryłami 3D.
8. **Odporność daje test fizyki niezależny od strojenia.** Wyrocznia (prosty rachunek na CPU dla pudełka na płaskiej
   ziemi, jak w 91) porównana z kanałem nieba bufora, niezmiennik danych „Bryła nie wystaje poza sylwetkę sprite'a” i
   bramki stylizacji uruchamiane na **każdym** Wariancie krytyka, a nie tylko na bazowym.
9. **Koszt:** w klatce praktycznie zero (kilka operacji ALU w dwóch istniejących shaderach, bez nowych odczytów
   tekstur). Praca około 1,5 dnia, z czego połowa to bramki.

## 1. Diagnoza w liczbach

### 1a. Co robi dziś A′ z gradientem wokół przedmiotu [kod, Wn]

`light_style.gdshader`: `s = log2(Y / anchor) / level_stops + 0,5`, nachylenie `g` z łagodniejszej różnicy jednostronnej
(w krokach na piksel), `W = clamp(seam_px · g, 0, 1)`, `k = floor(s + W · (próg − 0,5))`. Szerokość szwu w pikselach to
`W / g = seam_px`, o ile krok jest dłuższy niż `seam_px`. Reszta kroku to płaskie pole. [kod]

Skala ekranu z 84: 40 px/m w poziomie i 24 px/m w głąb. Zmierzony profil silnika (z ambientem): −0,8 EV przy styku,
−0,5 EV w 0,4 m i −0,1 EV w 1 m. To nachylenie ok. 0,7–0,75 EV/m, czyli 1,4–1,5 kroku na metr i **krok o długości
ok. 17–28 px**. Przy szwie 3 px zostaje 14–25 px płaskiego pola na krok. Skoro całe zaciemnienie to 1,6 kroku,
powstają dwa koncentryczne płaskie pola, każde z wąskim szwem. Tak powstaje opisany przez człowieka „krążek z
krawędzią”. [Wn]

Rzeczywistość wg 91: −0,6…−0,8 EV przy styku i −0,2…−0,3 EV w 30 cm, czyli nachylenie ok. 1,5 EV/m. Krok ma tam
ok. 8–13 px, więc A′ zrobiłby **jeden** węższy pierścień, ale nadal z krawędzią. **Poprawienie fizyki zmniejsza plamę,
ale jej nie usuwa. Krawędź robi A′.** [Wn]

Dla porównania długości kroku w innych miejscach (84, [Wn]): przy fasadzie na ulicy 81–285 px, przy lampie we wnętrzu
ok. 21 px, a na krawędzi cienia słońca poniżej 1 px.

### 1b. Odbicia: ile daje multi-bounce AO [P, Wn]

Funkcja Jimeneza i in. (2016) w kodzie Unity HDRP, `CommonLighting.hlsl` [P]:

```hlsl
real3 a =  2.0404 * albedo - 0.3324;
real3 b = -4.7951 * albedo + 0.6417;
real3 c =  2.7552 * albedo + 0.6903;
return max(x, ((x * a + b) * x + c) * x);   // x = widoczność (AO)
```

Założenie (slajdy SIGGRAPH 2016, za streszczeniem [S]): albedo otoczenia punktu jest podobne do albedo punktu. Unity
stosuje funkcję tylko do światła pośredniego. Komentarz w PR 5836: „when affecting direct lighting we don't used the
fake bounce” [P]. Sprawdziłem też, że f(1) = 1 (suma współczynników = 0,9996 + 0,0005ρ) [Wn].

Zastosowane do naszego udziału nieba x (otwarty chodnik x = 0,96, ambient 8% nieba bez zasłaniania) [Wn, obliczone]:

| albedo ρ | przy styku (x = 0,52) | 0,4 m (x = 0,66) | 1 m (x = 0,89) |
|---|---|---|---|
| 0 (dziś) | −0,80 EV | −0,50 EV | −0,10 EV |
| 0,1 (asfalt) | −0,79 | −0,48 | −0,09 |
| 0,2 | −0,69 | −0,43 | −0,08 |
| 0,3 (beton) | −0,61 | −0,37 | −0,08 |
| 0,5 | −0,45 | −0,27 | −0,06 |

Wniosek: przy realnych nawierzchniach (0,1–0,3) zysk wynosi 0,0–0,2 EV. To zgadza się z rachunkiem 91 z jednym
odbiciem: −1,00 → −0,78 EV przy ciemnym przedmiocie na asfalcie. **Odbicia nie wyjaśniają różnicy w 30–40 cm.**

### 1c. Geometria: czego się spodziewać po Bryłach różnej wielkości [Wn, obliczone]

Mój skrypt: niebo o równej jasności, czynnik widoku ważony cosinusem, 200 000 kierunków (sferyczny Fibonacci, jak
`sky_layer.gdshader`), punkt na ziemi przed środkiem przedniej ściany pudełka, bez ambientu. Dla skrzyni 0,6 m wyniki
zgadzają się z tabelą 91 (−0,67 / −0,30 / −0,11 EV), co sprawdza sam skrypt.

| Bryła | 2 cm | 10 cm | 30 cm | 40 cm | 60 cm | 1 m |
|---|---|---|---|---|---|---|
| skrzynia 0,6 × 0,6 × 0,6 m | −0,93 | −0,67 | −0,30 | −0,21 | −0,11 | −0,04 |
| skrzynia 1,2 × 0,6 × 0,6 m | −0,95 | −0,75 | −0,41 | −0,30 | −0,17 | −0,06 |
| ławka jako pełny klocek 1,5 × 0,45 × 0,45 m | −0,93 | −0,71 | −0,34 | −0,24 | −0,13 | −0,04 |
| stragan jako pełny klocek 2 × 1 × 2,2 m | −0,98 | −0,89 | −0,71 | −0,63 | −0,50 | −0,32 |

Zmierzone w silniku −0,5 EV w 0,4 m (ok. −0,55 bez ambientu) leży między skrzynią a pełnym straganem. **Hipoteza:**
punkty pomiaru były w zasięgu wysokiej Bryły straganu albo Bryły są większe lub „pełniejsze” niż przedmiot na sprite'cie.
Prawdziwy stragan ma pod blatem i pod markizą wolną przestrzeń, a ławka ma prześwit pod siedziskiem. Pełny klocek zasłania
tam zenit, który daje najwięcej światła na poziomą ziemię (91, §7). Rozstrzyga to widok debug Brył i bramka-wyrocznia
z §5. **Nie zmierzyłem tego w silniku.**

## 2. Pytanie 1: jak gry oświetlają obszar w cieniu i przedmioty w nim

| Gra / źródło | Światło w cieniu, AO, odbicia, cień kontaktowy | Ocena |
|---|---|---|
| Disco Elysium ([devblog „Shedding light”](https://discoelysium.com/devblog/2016/02/02/shedding-light)) | Brak świateł w silniku. Mapa mnożnika światła i cienia w alfie albedo koduje też „faux indirect illumination”: niska alfa przy oknach daje silne światło kierunkowe i głębsze cienie, a wysoka alfa więcej odbitego światła, które zmiękcza cienie i owija przedmioty. Metoda „relies on lighting conditions being very low frequency”. | [P]. Odbicia są **daną** (mapą), a nie liczeniem. O cieniach postaci i AO nic |
| Octopath / HD-2D ([Unreal Engine spotlight](https://www.unrealengine.com/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true)) | Gładkie światło UE4. Dodatkowe światło punktowe przy efektach, żeby postacie rzucały cień na otoczenie. Talku CEDEC o AO nie znalazłem. | [S] wywiad; technika AO [N] |
| Hades | Malowane otoczenie. Przy postaciach wypalane AO, krzywizna i grubość w Substance (talk Paige Carter, streszczenie po rosyjsku). O świetle otoczenia nic. | [S]/[N] |
| Eastward ([Game Developer](https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures)) | Assety odbudowane w 3D, ręcznie malowane mapy wypukłości, własny silnik na MOAI. O AO i świetle nieba nic. | [S] |
| Sea of Stars ([MobileSyrup](https://mobilesyrup.com/2023/09/11/sea-of-stars-level-design-sabotage-studio-thierry-boulanger-interview/)) | Własny pipeline dynamicznego światła, jedna osoba od 2018. Algorytmu nie opisano. | [S] |
| Dead Cells ([80.lv](https://80.lv/articles/interview-with-the-developers-of-dead-cells)) | Tła w pixel arcie przerysowane jako mapy normalnych, dynamiczne światło 3D na sprite'ach. | [S] |
| Children of Morta | Światło HD nad pikselami (za 84). | [S] |
| Blasphemous | Nic o technice światła. | [N] |
| Guilty Gear Xrd ([handout Motomury, GDC 2015](https://www.ggxrd.com/Motomura_Junya_GuiltyGearXrd.pdf), przez streszczenia i Polycount) | Toon: próg na N·L, kanał koloru wierzchołka **przesuwa próg** (malowane zasłanianie). Artyści ręcznie czyścili normalne, żeby nie było plam. | [S]. Precedens „AO przed kwantyzacją”, ale z ręczną korektą, na którą u nas nie ma zgody |
| Pixel art 3D (t3ssel8r i naśladowcy: [Holland](https://davidholland.netlify.app/articles/3d-pixel-art-rendering), forum LÖVE) | Toon na świetle bezpośrednim, AO mnożone **po** kwantyzacji albo wypalone i dodane do ditheru. | [S], oryginału (wideo) nie obejrzałem |
| Path of Exile 2 (radiance cascades) | GI w przestrzeni ekranu z kaskadami Sannikova. Według wtórnego źródła ok. 3 ms na klatkę. | [S] |
| Gurney, malarstwo (za 91) | „occlusion shadows”: ciemny akcent przy styku, w cieniu brak kształtnych cieni rzuconych. | [P w 91] |

**Fakty łącznie:** żadna z przeczytanych gier pixel art nie opisuje liczonego zasłaniania nieba ani AO poddanego
kwantyzacji. Odbicia i AO są w nich malowane, wypalane albo wynikają z gładkiego światła 3D. Gdy kwantyzuje się światło
(toon), stosuje się dwie szkoły: AO przesuwa próg i wymaga ręcznej korekty (Xrd [S]) albo AO mnoży się po kwantyzacji,
gładko (naśladowcy t3ssel8r [S]). [Wn]

**Wniosek [Wn]:** z gier da się wziąć zasadę „okluzja dotyczy tylko światła pośredniego” (Unity [P], Disco Elysium [P])
i obraz docelowy „miękki akcent przy styku, bez kształtu” (Gurney). Gotowego algorytmu dla naszego połączenia (liczone
niebo, kwantyzacja EV, dither) w źródłach nie ma.

## 3. Pytanie 2: tanie techniki światła pośredniego i dopasowanie do silnika

Nasz bufor to w praktyce G-bufor: każdy piksel ma punkt w świecie i normalną (`find_surface`), a widoczność nieba
liczymy prawdziwymi promieniami 3D przeciw Bryłom, raz na scenę [kod]. To więcej, niż daje SSAO.

| Technika | Co daje | Koszt | Dopasowanie do silnika | Ocena [Wn] |
|---|---|---|---|---|
| Ambient półkuli (niebo/ziemia wg normalnej) | Ściany i boki przedmiotów dostają światło od ziemi | ~0 | Mamy już lepsze: prawdziwą widoczność nieba. Kierunki pod horyzontem (`direction.z ≤ 0`) liczą się dziś jako 0 [kod], więc boki skrzyń nie dostają nic od ziemi | Opcjonalnie: odbicie od ziemi jako ρ_ziemi × (niebo + ambient otwartej ziemi) × udział dolnej półkuli. Nie dotyczy aureoli, tylko boków przedmiotów |
| Multi-bounce AO (Jimenez 2016 [P kod]) | Jaśniejsze zakamarki, kolor od albedo | ~6 ALU na piksel | Idealne: wejściem jest nasz udział nieba x | Tak, ale efekt to 0,0–0,2 EV (§1b). Albedo jako dana Lokacji albo średnia z tekstur podłoża, nie suwak |
| Bent normals (średni kierunek widocznego nieba) | Kierunkowe niebo (jaśniejszy horyzont, strona słońca, jasna fasada naprzeciwko, 91 §3) | Przy wczytaniu: 3 dodatkowe kanały warstwy nieba. W klatce 1 odczyt | Dobre, bo warstwę nieba już liczymy | Później. Nie jest potrzebne do usunięcia plamy |
| Wypalane mapy (lightmapy, sondy irradiancji) | Pełne odbicia statyczne | Przy wczytaniu dużo, w klatce ~0 | Warstwa nieba to już wypalona mapa geometrii. Odbicie od nasłonecznionej fasady zależy od godziny, więc trzeba by wypalać na porę dnia | Za drogie w pracy jak na zysk 0,1–0,3 EV. Na później, jeśli człowiek zobaczy za ciemne wąskie ulice |
| Radiance cascades 2D (Sannikov, [repo artykułu](https://github.com/Raikiri/RadianceCascadesPaper) [P istnienie]; [Holographic RC, arXiv 2505.02041](https://arxiv.org/abs/2505.02041) [P abstrakt]) | GI 2D bez szumu, koszt niezależny od liczby świateł; 1,85 ms przy 512² i 7,67 ms przy 1024² na RTX 3080 Laptop | Wysoki w naszym budżecie 4 ms na cały silnik | **Nie pasuje.** To światło w płaszczyźnie („flatland”), a nasz rzut 3/4 ma wysokości i Bryły 3D. Wersja ekranowa 3D (PoE2) wymaga bufora głębi i kosztuje ok. 3 ms [S] | Nie |
| SDF GI 2D (Godot `texture_sdf` z `LightOccluder2D`, [dokumentacja](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html) [P]) | Tanie odległości do przesłon 2D | Niski | Nasze przesłony to Bryły 3D, nie `LightOccluder2D`. Pole SDF jest płaskie | Nie |
| Light propagation volumes | Odbicia dynamiczne w siatce 3D | Średni do wysokiego | Siatka 3D nad całą Lokacją, przeciek światła przez cienkie ściany | Nie |
| SSAO / GTAO / „krótki zasięg” | Okluzja z bliskiego otoczenia | 0,5–2 ms | Mamy dokładniejszą okluzję. Krótki zasięg **sumuje** przesłony (§4c) | Nie |

## 4. Pytanie 3: jak stylizować miękkie gradienty, żeby nie robić krawędzi, których nie ma

### 4a. Możliwości

1. **Kwantyzować tylko światło bezpośrednie** (toon 3D [S]). U nas cień budynku jest oświetlony wyłącznie niebem, więc
   cała zacieniona ulica wyszłaby gładka. To przeczy wyborowi człowieka (ticket 37) i rekomendacji 84. Odpada jako
   docelowe, może zostać jako punkt odniesienia w F1.
2. **LUT lub rampa palety** (Graveyard Keeper, Rain World za 84 [P w 84]). Zmienia kolory poziomów, ale nie usuwa
   granic: rampa to też schody. Nie rozwiązuje problemu.
3. **Dither na całym gradiencie** (klasyczna posteryzacja z ditherem). Na długich krokach daje siatkę z 84. Odpada w
   czystej postaci.
4. **AO po kwantyzacji, gładko** (naśladowcy t3ssel8r [S]). Wymaga oddzielenia bliskiej okluzji od dalekiej, czyli
   drugiej warstwy nieba z ograniczonym zasięgiem i stałej „co jest blisko” w metrach. Gładkie mnożenie w pixel arcie
   daje gradient HD wokół każdego przedmiotu. Odpada.
5. **Szew zależny od skali: krótki krok cały w ditherze, długi krok jako pole z wąskim szwem** (saint11: „a long step
   should have a proportionally long anti-alias halftone strip” [P w 84], ograniczone z góry, jak wnioskuje 84 §2b).
   **Zalecane.**

### 4b. Formuła (zmiana jednej linii w `levels()`)

Dziś: `W = clamp(seam_px · g, 0, 1)`. Proponuję:

```glsl
uniform float full_dither_px = 24.0;   // krok krótszy niż to: dither przez cały krok
// g: kroki na piksel (jak dziś). Krok w px = 1/g. Liczone w dziedzinie g, bez dzielenia.
float narrow = clamp(seam_px * g, 0.0, 1.0);                    // dzisiejszy szew
float t = smoothstep(0.5 / full_dither_px, 1.0 / full_dither_px, g); // 1: krok ≤ full_dither_px
float w = mix(narrow, 1.0, t);
float k = floor(s + w * (threshold - 0.5));
```

Zachowanie [Wn]:

- krok ≤ `full_dither_px`: `W = 1`, czyli zwykły dither uporządkowany między sąsiednimi poziomami przez cały krok, bez
  płaskiego pola i bez krawędzi. Uśrednione po komórce Bayera 4×4 odtwarza wejście. Tak wygląda aureola przedmiotu
  (krok 8–28 px) i akcent przy styku;
- krok ≥ 2 × `full_dither_px`: dzisiejsze A′, czyli płaskie pola z szwem `seam_px`. Tak wygląda ulica przy fasadach
  (81–285 px) i pochmurny dzień;
- krok < `seam_px`: jak dziś pełny dither, a krawędź cienia słońca zostaje ostra (≤ 1–3 px);
- pomiędzy: płynne przejście, bez przełącznika. Szerokość szwu w px nie rośnie monotonicznie z długością kroku. Każda
  reguła „krótkie całe, długie wąsko” musi gdzieś zmaleć, a `smoothstep` robi to bez skoku.

Jednostka `full_dither_px` jest ekranowa, jak `seam_px`, więc ta sama wartość działa we wnętrzu i na ulicy (zasada z 84
§5). Ryzyko: ogony lamp we wnętrzu (krok ok. 21 px) też przejdą w pełny dither i staną się „miększe” niż dziś. To wynik
do oceny przez człowieka, a nie powód do wyjątku. Warianty krytyka w F1: `full_dither_px` = 0 (dzisiejsze A′), 16, 24
i 40, każdy z Bayerem. Opcjonalnie szachownica.

Koszt: `smoothstep` i `mix`, czyli ok. 5 ALU na piksel bufora, bez nowych odczytów tekstur. [Wn]

### 4c. Dlaczego nie „krótki zasięg zasłaniania” [Wn]

Okluzja bliska liczona osobno (promień do R) i pomnożona przez daleką liczy dwa razy kierunki, które zasłania i budynek,
i skrzynia. W ulicy po stronie ściany zaciemnia to podwójnie, a 91 §2–3 pokazuje, że prawda to „przesłony się
nakładają”. Dzisiejsze promienie do `FAR_M = 1000` [kod] robią to poprawnie z definicji. Ta sama pułapka dotyczy
**analitycznego zasłaniania nieba przez ruchome Przesłony** (spec, warstwa ruchomych Przesłon): jeśli wzór po prostu
mnoży, postać przy ścianie w cieniu dostanie podwójną plamę. Potrzebna bramka „postać przy ścianie w cieniu” (§5).

## 5. Pytanie 4: co czyni rozwiązanie odpornym na późniejsze strojenie

**Zasada [Wn]:** wygląd stroją krytycy Wariantami, ale fizyka i własności stylizacji są zapisane w bramkach, które nie
zależą od wartości strojenia i uruchamiają się na każdym Wariancie. Każdy test ma jednostki niezależne od sceny (EV,
px ekranu, udział nieba).

### 5a. Niezmienniki fizyki (bramki GPU, kanał nieba z widoku debug „kanały”)

1. **Wyrocznia nieba.** Pudełko 0,6 m na płaskiej ziemi pod całym niebem. Udział nieba z bufora (niebieski w
   `VIEW_CHANNELS`) porównany z prostym rachunkiem na CPU w teście (ray-box, kilka tysięcy kierunków) w punktach 2, 10,
   30 i 60 cm. Tolerancja ±0,1 EV. Wartości: −0,93 / −0,67 / −0,30 / −0,11 EV (§1c, 91). Bramka sprawdza warstwę nieba,
   rzut i ustawienie Brył, a nie strojenie.
2. **Cień w cieniu (nakładanie).** To samo pudełko 1 m od ściany 15 m. Po stronie otwartej ulicy dodatkowy spadek w 30 cm
   ≤ 0,05 EV, w szczelinie przy ścianie ≥ 0,8 EV (91, tabela ulicy). Bramka łapie każde przyszłe „mnożenie” przesłon.
3. **Monotoniczność i granice:** światło rośnie z udziałem nieba; multi-bounce spełnia f(x) ≥ x i f(1) = 1; odbicie
   ≤ ρ × zasłonięty udział × światło otoczenia (energia).
4. **Ruchoma Przesłona przy ścianie:** postać stojąca przy ścianie w cieniu zaciemnia ziemię po stronie ściany nie
   bardziej niż ta sama postać jako statyczna Bryła (ten sam wzór co bramka 2).

### 5b. Niezmienniki danych (walidacja Lokacji i assetu, ostrzeżenie w edytorze)

5. **Bryła w sylwetce sprite'a.** Rzut Brył assetu leży w kanale alfa sprite'a z tolerancją 1 px. Inaczej zaciemnienie
   pojawi się poza przedmiotem.
6. **Prześwity jako prześwity.** Wolna przestrzeń pod blatem, siedziskiem czy markizą o wysokości ≥ ok. 0,3 m ma być
   pusta (nogi i słupki jako osobne cienkie Bryły). To reguła modelowania danych, nie kodu. Spec już dopuszcza wiele
   Brył na asset. Sprawdzenie automatyczne jest trudne, więc wystarczy zasada w instrukcji assetu i widok debug Brył. [Wn]

### 5c. Niezmienniki stylizacji (bramki na `LightStyle` z syntetycznym wejściem, jak w `test_light_style_gpu.gd`)

7. **Brak krawędzi z gradientu.** Gradient promienisty o amplitudzie 0,5–2 kroków na długości 8–`full_dither_px` px.
   Średnia krocząca 4 px wyjścia (w krokach) śledzi wejście z błędem ≤ 0,35 kroku, a skok średniej między sąsiednimi
   oknami 4 px wynosi ≤ 0,5 kroku. Dzisiejsze A′ tego nie przechodzi, nowa formuła przechodzi z konstrukcji.
8. **Ostre zostaje ostre.** Skok 2 EV na 1–2 px daje przejście ≤ `seam_px` + 1 px.
9. **Ulica bez zmian.** Gradient z kroku 85–285 px daje płaskie pola i szew ≤ `seam_px` (regresja 84).
10. **Kotwica.** Mnożenie nieba i ambientu przez c nie przesuwa granic poziomów w obszarze oświetlonym tylko niebem
    (już jest w 84).
11. **Każdy Wariant.** `node tools/test.mjs` przechodzi bramki 7–10 dla każdego Wariantu z rejestru. Krytyk może zmienić
    wygląd, ale nie może przywrócić krawędzi z gradientów ani siatki.

### 5d. Granice zakresów (w `TuningSet`)

- `full_dither_px` ≥ 2 × `seam_px` (inaczej wariant krótkich kroków się nie włączy): walidacja z ostrzeżeniem.
- `full_dither_px` ≤ ok. 48 px. Powyżej wraca siatka na ulicy (84 §1). Zakres `@export_range(0, 48)`.

## 6. Rekomendacja: jeden spójny plan

**Fizyka (bez zmian w zasadzie, korekta danych):**
1. Najpierw bramka-wyrocznia nieba (5a.1–2). Jeśli przechodzi, różnica w środkowym zasięgu pochodzi z Brył: sprawdzić
   w widoku debug Bryły straganu, ławki i skrzyni i zastosować reguły danych 5b (prześwity, Bryła w sylwetce). Jeśli
   nie przechodzi, jest to błąd w warstwie nieba lub rzucie, do naprawy w modelu, bez łatek.
2. Multi-bounce Jimeneza na udziale nieba w `light_buffer.gdshader`: `sky = f(sky_raw, ρ)`. ρ jako dana Lokacji
   (`LocationEnvironment`, albedo podłoża, domyślnie 0,2) albo średnia albedo tekstur podłoża liczona przy budowie
   Opisu sceny. Bez suwaka. Daje 0,1–0,2 EV jaśniejsze zakamarki i spójność z 91. Tylko dla nieba, nie dla słońca
   (zgodnie z Unity [P]).
3. Ambient zostaje bez zasłaniania (spec), ale bez podnoszenia go „żeby było jaśniej w cieniu”, bo to już robi
   multi-bounce. Odbicie od ziemi na bokach przedmiotów i bent normals na później.

**Stylizacja:** formuła 4b w `light_style.gdshader` i `full_dither_px` w `TuningSet`. Warianty w F1: 0 / 16 / 24 / 40
(0 = dzisiejsze A′ do porównania). Człowiek wybiera na żywo w Poligonie Ulica o 9:00 (skrzynia, ławka, stragan w cieniu)
i sprawdza Dom przy lampie.

**Bramki:** 5a.1–4, 5c.7–11 oraz walidacja 5b.5.

**Koszt w klatce [Wn, szacunek, niezmierzone]:** stylizacja ok. 5 ALU na piksel, multi-bounce ok. 6 ALU na piksel
bufora, bez nowych odczytów. Przy buforze rzędu 1–2 mln pikseli to setne części milisekundy. Warstwa nieba bez zmian.
Do potwierdzenia `--bench`.

**Koszt w pracy [Wn]:** stylizacja + Warianty 2 h; bramki stylizacji 3 h; wyrocznia nieba i bramka nakładania 3 h;
diagnoza Brył i poprawka danych 1–2 h; multi-bounce + albedo 1 h; walidacja Bryła w sylwetce 1–2 h. **Razem ok. 11–13 h.**

## 7. Porównanie z propozycją Claude'a

| Punkt propozycji | Moja ocena |
|---|---|
| 1. Multi-bounce AO z albedo z `LocationEnvironment` | **Tak samo**, z korektą oczekiwań: daje 0,1–0,2 EV, nie usuwa nadmiaru w 30–40 cm (§1b). Albedo raczej liczone z tekstur niż nowa wartość ustawiana ręcznie. Dziś `LocationEnvironment` nie ma pola albedo [kod] |
| 2a. Poziomy tylko dla światła kierunkowego | **Odrzucam jako cel.** W cieniu budynku całe światło to niebo, więc cała ulica w cieniu stałaby się gładka (ticket 37, 84). Najwyżej jako punkt odniesienia w F1, ale wymaga rozdzielenia kanału naturalnego, więc to praca bez celu |
| 2b. Szew rośnie z długością zbocza | **Tak, ale z górną granicą i płynnym powrotem do wąskiego szwu** (`full_dither_px`). Bez granicy wraca siatka 85 px z 84 |
| 3. Bramki „cień w cieniu”, „brak krawędzi z gradientu”, „ostre zostaje ostre” | **Tak samo.** Dodaję: wyrocznię CPU zamiast tolerancji „w zakresie z 91”, bramkę nakładania przy ścianie, regresję ulicy, kotwicę i **uruchamianie na każdym Wariancie** |
| „Krótki zasięg zasłaniania” | **Odrzucam.** Sumuje przesłony, czyli robi błąd wskazany przez człowieka (§4c) |
| **Brakuje** | (1) diagnozy geometrii: −0,5 EV w 0,4 m pasuje do wysokiej lub pełnej Bryły, a nie do skrzyni (§1c); (2) niezmienników danych (Bryła w sylwetce, prześwity); (3) ryzyka podwójnej plamy przy analitycznym zasłanianiu nieba przez ruchome Przesłony; (4) skutków dla wnętrza (ogony lamp 21 px) |
| **Zbędne** | Wariant (a) w F1 i krótki zasięg. Dwa warianty (a/b) zastępuje jedna formuła z Wariantami wartości `full_dither_px` |

## 8. Najsłabsze miejsca

- **Nie zmierzyłem bufora.** Liczby silnika (−0,8 / −0,5 / −0,1 EV) pochodzą z zadania. Hipoteza o Bryłach (§1c) to
  rachunek na pudełkach, a nie odczyt sceny. Długości kroku 8–28 px są przeliczone ze skali 40/24 px/m.
- **Formuła 4b nie ma precedensu w grach** [N]. Opiera się na saint11 (proporcjonalny pas dla krótkiego kroku [P w 84])
  i na wniosku 84 o ograniczonym pasie. Wartość 24 px dobrałem tak, żeby objęła aureolę (8–28 px) i ominęła ulicę (≥ 81
  px). To propozycja do Wariantów, nie wynik.
- **Pełny dither na 10–25 px może się czytać jako faktura** (Pixel Parmesan: „sparingly” [P w 84]). Dlatego Warianty
  w F1, a ocena na żywo.
- Współczynniki Jimeneza sprawdziłem w kodzie Unity HDRP [P]. PDF artykułu pobrałem, ale tekst był nieczytelny
  (zakodowane glify), więc założenie o albedo znam ze streszczenia slajdów [S].
- Większość źródeł o grach to [S] lub [N]. Disco Elysium i Unity to jedyne pierwotne źródła o świetle pośrednim w tej
  sesji. Talku CEDEC o Octopath i opisu techniki Hades, Blasphemous, Sea of Stars nie znalazłem.
- Radiance cascades: koszt PoE2 (3 ms) ze źródła wtórnego. Liczby Holographic RC z abstraktu arXiv.
- Koszty w klatce i w godzinach to szacunki.

## 9. Źródła

Technika:
- Jimenez J., Wu X.-C., Pesce A., Jarabo A. (2016), *Practical Real-Time Strategies for Accurate Indirect Occlusion*,
  [Activision Research](https://research.activision.com/publications/archives/practical-real-time-strategies-for-accurate-indirect-occlusion),
  [PDF](https://www.iryoku.com/downloads/Practical-Realtime-Strategies-for-Accurate-Indirect-Occlusion.pdf),
  [slajdy SIGGRAPH 2016](https://blog.selfshadow.com/publications/s2016-shading-course/activision/s2016_pbs_activision_occlusion.pdf) [S, tekst nieczytelny].
- Unity HDRP, `GTAOMultiBounce` w
  [CommonLighting.hlsl](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonLighting.hlsl) [P];
  [PR 5836](https://github.com/Unity-Technologies/Graphics/pull/5836/files) (bez „fake bounce” dla światła bezpośredniego) [P].
- Intel [XeGTAO](https://github.com/GameTechDev/XeGTAO) (bent normals w GTAO) [P].
- Sannikov A., *Radiance Cascades*, [repozytorium artykułu](https://github.com/Raikiri/RadianceCascadesPaper) [P];
  Freeman, Sannikov, Margel (2025), [Holographic Radiance Cascades for 2D Global Illumination](https://arxiv.org/abs/2505.02041) [P abstrakt];
  [80.lv o radiance cascades](https://80.lv/articles/radiance-cascades-new-approach-to-calculating-global-illumination) [S];
  [habr, PoE2](https://habr.com/en/articles/897956) [S].
- Godot, [canvas_item shader: funkcje SDF](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html) [P].

Gry:
- Disco Elysium, [Shedding light (2016)](https://discoelysium.com/devblog/2016/02/02/shedding-light) [P].
- Octopath Traveler, [Unreal Engine spotlight (2019)](https://www.unrealengine.com/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true) [S].
- Hades, [talk Paige Carter (streszczenie, DTF)](https://dtf.ru/id64954/238431-sozdanie-materi-nochi-process-modelirovaniya-nikty-iz-hades) [S].
- Eastward, [Game Developer](https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures) [S].
- Sea of Stars, [MobileSyrup](https://mobilesyrup.com/2023/09/11/sea-of-stars-level-design-sabotage-studio-thierry-boulanger-interview/) [S].
- Dead Cells, [80.lv](https://80.lv/articles/interview-with-the-developers-of-dead-cells) [S].
- Guilty Gear Xrd, [handout Motomury, GDC 2015](https://www.ggxrd.com/Motomura_Junya_GuiltyGearXrd.pdf) [S przez streszczenia i Polycount].
- Pixel art 3D, [David Holland, 3D pixel art rendering](https://davidholland.netlify.app/articles/3d-pixel-art-rendering) [S].

Z wcześniejszych researchów (niesprawdzane ponownie): saint11, Pixel Parmesan, Graveyard Keeper, Rain World [P w 84];
Gurney, „occlusion shadows” [P w 91].
