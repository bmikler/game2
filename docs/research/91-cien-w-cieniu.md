# 91 - Cień w cieniu: czy przedmiot stojący w cieniu budynku rzuca dodatkowy cień? (tylko rzeczywistość)

Data: 2026-11-16. Zakres po zmianie: **wyłącznie świat fizyczny**, czyli zwykła ulica (asfalt, beton, bruk), bez śniegu.
Plik nie mówi nic o grze, silniku ani grach 2D. Pytanie: czy przedmiot stojący w całości w cieniu budynku (ławka, skrzynia,
kosz, samochód), w słoneczny dzień, a także w pochmurny, robi na ziemi pod sobą lub obok siebie ciemniejszą plamę? Jeśli
tak, to jak mocną, jak dużą i od czego to zależy. Druga część odpowiada na tezę „w rzeczywistości nie ma światła nieba,
jest tylko słońce”.

Oceny: **[P]** = źródło pierwotne przeczytane w tej sesji albo zdjęcie obejrzane osobiście (opis jest mój);
**[S]** = źródło wtórne, czyli streszczenie z wyszukiwarki, abstrakt bez pełnego tekstu, wiki lub poradnik;
**[N]** = szukane, ale nie znalezione; **[Wn]** = mój wniosek albo moje obliczenie.

## Streszczenie

1. **W cieniu budynku jest światło, i to dużo.** Daje je niebo, czyli światło słońca rozproszone w powietrzu (rozpraszanie
   Rayleigha [S]), oraz odbicia od ścian i ziemi. Budynek zasłania tarczę słońca. To 0,001% nieba [Wn]. Reszty nieba
   nie zasłania. Nawet u stóp ściany wysokiej na 15 m ziemia widzi połowę nieba, a 5 m od niej 66% [Wn]. W zimowe
   przedpołudnie, przy słońcu około 10° nad horyzontem, niebo daje w przybliżeniu 1/4 całego światła na otwartej ziemi.
   Ziemia w cieniu jest więc tylko około 2 EV (4×) ciemniejsza niż w słońcu, a nie czarna [Wn, model ASHRAE].
2. **Teza „nie ma światła nieba” jest fałszywa.** Dowodów jest wiele: niebieskie cienie [P, zdjęcia], pomiary UV
   w cieniu parasoli i ścian [S] oraz to, że w cieniu da się czytać.
3. **Dodatkowy cień istnieje.** Przedmiot zasłania tę część nieba, której budynek nie zasłonił, więc ziemia pod nim i tuż
   obok niego dostaje mniej światła. Fizyka to przewiduje (Langer i Zucker 1994 [S], klimatologia miejska [S]).
   Widać to na zdjęciach: pod samochodami w pochmurny dzień i w cieniu budynku jest wyraźnie ciemniej [P].
4. **Siła i zasięg zależą od miejsca [Wn, obliczenia].** Pod samochodem jest ciemno, od −2,5 do −5 EV. Pod ławką jest
   −0,5…−0,75 EV. U podstawy skrzyni lub kosza jest −0,6…−0,8 EV, ale efekt szybko słabnie: 10 cm dalej −0,4…−0,55 EV,
   30 cm dalej −0,2…−0,3 EV, a w odległości wysokości przedmiotu −0,1 EV. To płynny gradient bez krawędzi, a nie plama
   o wyraźnym obrysie.
5. **Człowiek ma rację w ważnym punkcie: przesłony się nakładają, a nie dodają.** Tam, gdzie przedmiot zasłania niebo
   już zasłonięte przez budynek, nie dodaje nic. W ulicy oznacza to, że po stronie przedmiotu zwróconej do otwartej
   ulicy dodatkowego cienia praktycznie nie ma (0,00 EV już 10 cm od skrzyni). Wyraźne przyciemnienie powstaje pod
   przedmiotem i w szczelinie między przedmiotem a ścianą (−1,1…−1,7 EV) [Wn, obliczenia].
6. **Twierdzenie, że plamy „nie ma w ogóle”, jest fałszywe.** Zaprzeczają mu zdjęcia i fizyka. Prawdziwe jest natomiast,
   że w cieniu przedmiot nie rzuca kształtnego cienia z ostrą krawędzią. Robi tylko miękkie zaciemnienie przy styku,
   które malarze nazywają „occlusion shadow” (Gurney [P]).
7. **Odbite światło (ściany, ziemia) osłabia efekt, ale go nie znosi.** Na asfalcie i przy ciemnym przedmiocie osłabia go
   niewiele (−1,0 → −0,8 EV przy styku). Przy jasnym przedmiocie i betonie osłabia go bardziej (−0,6 EV) [Wn].

## 1. Czy w cieniu w ogóle jest światło? (odpowiedź na tezę „nie ma światła nieba”)

### 1a. Światło nieba istnieje fizycznie

- Niebo świeci, bo cząsteczki powietrza rozpraszają światło słońca we wszystkich kierunkach. Siła rozpraszania rośnie
  jak 1/λ⁴, czyli niebieskie światło rozprasza się kilka razy silniej niż czerwone. Stąd błękit nieba [S: Wikipedia
  „Diffuse sky radiation”; powszechny podręcznikowy wynik Rayleigha]. Niebieski kolor nieba sam w sobie dowodzi, że
  do oka (i na ziemię) dochodzi światło z kierunków innych niż słońce.
- Z bezpośredniej wiązki słońca ubywa w atmosferze około 23%, z czego około dwie trzecie dociera na ziemię jako światło
  rozproszone [S: Wikipedia, oznaczone tam „citation needed”].
- W bezchmurny dzień światło rozproszone to zwykle 10–30% światła na poziomej ziemi [S: streszczenie artykułu o
  obserwacjach, bez nazwy stacji]. Przy niskim słońcu ten udział rośnie [S, kilka prac o modelach frakcji rozproszonej].

### 1b. Liczby dla zimowego przedpołudnia [Wn, obliczenie z modelu ASHRAE]

Stary model bezchmurnego nieba ASHRAE: DNI = A·exp(−B/sin h), rozproszone poziome = C·DNI. Dla stycznia
A = 1230 W/m², B = 0,142, C = 0,058 [S: wyciąg z ASHRAE Fundamentals 2001]. W połowie listopada w południowej Polsce
o 9:00 słońce stoi około 10–11° nad horyzontem (moje obliczenie z deklinacji).

| wysokość słońca | słońce na poziomą ziemię | niebo na poziomą ziemię | udział nieba | słońce+niebo / samo niebo |
|---|---|---|---|---|
| 5° | 21 W/m² | 14 W/m² | 40% | 1,3 EV (2,5×) |
| 10° | 94 W/m² | 31 W/m² | 25% | 2,0 EV (4×) |
| 15° | 184 W/m² | 41 W/m² | 18% | 2,5 EV (5,5×) |
| 20° | 278 W/m² | 47 W/m² | 14% | 2,8 EV (7×) |

Zastrzeżenie: ten model (z 1967 r.) zaniża światło rozproszone. Gueymard i Thevenard (2009) zaproponowali jego zastąpienie
[S]. W mieście, gdzie w powietrzu jest więcej pyłu i zamglenia, rozproszonego światła jest więcej. Rząd wielkości jest
jednak pewny: **w zimowe przedpołudnie niebo daje co najmniej 1/5–1/4 światła na otwartej ziemi.** Cień budynku jest
więc tylko kilka razy ciemniejszy od słońca. Fotografowie w podręczniku wojskowym podają, że „otwarty cień” wymaga
około 3 przysłon więcej niż jasne słońce, przy wyższym słońcu [S].

### 1c. Niebieskie cienie: obserwacja, że cień oświetla niebo (krótka ilustracja)

Gdyby cień oświetlało tylko słońce (czyli nic), byłby czarny. Jest natomiast jasny i niebieskawy, bo oświetla go
niebieskie niebo. Najlepiej widać to na białej powierzchni, ale zjawisko nie zależy od śniegu. Na każdej szarej
powierzchni cień jest chłodniejszy od miejsca w słońcu, co fotografowie znają jako „niebieski otwarty cień” [S:
poradniki fotograficzne; Clarkvision: „A blue sky fills shadows with blue light” [P]].

- Zdjęcie [Blue shadows (geograph 1652749)](https://commons.wikimedia.org/wiki/File:Blue_shadows_-_geograph.org.uk_-_1652749.jpg)
  [P]: cień drzewa na polu jest wyraźnie niebieski i jasny. Widać w nim fakturę powierzchni, więc nie jest czarny.
- Zdjęcie [Blue shadows (geograph 1156431)](https://commons.wikimedia.org/wiki/File:Blue_shadows_-_geograph.org.uk_-_1156431.jpg)
  [P]: niebieskie cienie gałęzi, a w nich ślady zwierząt są dobrze widoczne.
- Malarstwo: Claude Monet, [„Sroka” (La Pie, 1868–69)](https://commons.wikimedia.org/wiki/File:Claude_Monet_-_The_Magpie_-_Google_Art_Project.jpg)
  [P, obraz obejrzany]. Cienie płotu i furtki są niebieskofioletowe i jasne, a nie czarne. To klasyczny przykład
  impresjonistów, którzy malowali kolor cienia z natury.

### 1d. Budynek zasłania słońce, a nie całe niebo [Wn, geometria]

Słońce to mała tarcza: około 6,8·10⁻⁵ steradiana wobec 2π steradianów półkuli nieba, czyli około 0,001% nieba.
Punkt w cieniu budynku ma zasłonięte słońce i część nieba za budynkiem. Resztę nieba widzi. Dla długiej ściany o
wysokości H udział zasłoniętego nieba (ważony kątem padania na poziomą ziemię) wynosi ½·(1 − d/√(d² + H²)):

| odległość od ściany 15 m | widoczna część nieba |
|---|---|
| 0 m (u stóp) | 50% |
| 2 m | 57% |
| 5 m | 66% |
| 10 m | 78% |

**Wniosek dla przedmiotu w cieniu:** przedmiot stoi w miejscu, które widzi jeszcze 50–80% nieba, a na szerokim placu
nawet więcej. Jeśli zasłoni część tego nieba, ziemia przy nim dostanie mniej światła. Teza „obiekt w cieniu nie może
rzucić dodatkowego cienia, bo budynek i tak nie przepuszcza światła” byłaby prawdziwa tylko wtedy, gdyby budynek
zasłaniał **całe** niebo. Tak nie jest.

## 2. Mechanizm i to, w czym człowiek ma rację

- Pod rozproszonym światłem (pochmurny dzień, cień) jasność powierzchni zależy głównie od tego, **ile nieba widzi**
  dany punkt, a mniej od kierunku powierzchni [S: Langer i Zucker 1994, „Shape-from-shading on a cloudy day”, JOSA A,
  abstrakt]. Badania percepcji pokazują, że ludzie odczytują to jako regułę „ciemne = głębokie” [S: Langer i Bülthoff
  2000, abstrakt].
- W klimatologii miejskiej ta sama wielkość to **sky view factor (SVF)**, czyli udział widocznego nieba. Steruje ona
  ilością promieniowania rozproszonego, które dociera do punktu w kanionie ulicy. Pominięcie przesłon przy liczeniu
  promieniowania nieba „może prowadzić do poważnych błędów” [S, streszczenia prac o kanionach ulicznych].
- **Przesłony się nakładają, a nie dodają [Wn].** Liczy się suma kierunków nieba zasłoniętych przez cokolwiek. Jeśli
  skrzynia zasłania kierunek, który już zasłania budynek, nic nie zmienia. To uściśla intuicję człowieka: przedmiot
  nie „dodaje cienia do cienia”, tylko zabiera resztkę nieba, którą budynek zostawił. Dlatego przy słońcu cień skrzyni
  wewnątrz cienia budynku nie istnieje (słońca nie ma), a jej „cień od nieba” istnieje tylko w tej części nieba, którą
  budynek pozostawił odsłoniętą.

## 3. Jak mocno i jak daleko: obliczenia [Wn]

Model: ziemia pozioma, niebo o równej jasności, czynnik widoku ważony cosinusem (200 000 kierunków, sferyczny Fibonacci;
skrypt w notatkach sesji). Kolumna „CIE pochmurne” zakłada niebo pochmurne standardu CIE (Moon i Spencer 1942: zenit
3× jaśniejszy od horyzontu [S]). Kolumny „z odbiciem” dodają jedno odbicie od ścian przedmiotu: ściana pionowa widzi
pół nieba i pół ziemi, a spód widzi tylko ziemię. Albedo asfaltu przyjąłem 0,1, betonu 0,3. Wartości to spadek względem
tego samego miejsca bez przedmiotu, w EV (−1 EV = połowa światła).

**Przedmiot na otwartym terenie (np. szeroki plac w cieniu, prawie całe niebo widoczne):**

| przedmiot, punkt | samo niebo | CIE pochmurne | z odbiciem: ciemny przedmiot 0,3 + asfalt | z odbiciem: jasny 0,5 + beton |
|---|---|---|---|---|
| skrzynia 0,6 m, przy styku | −1,00 | −1,00 | −0,78 | −0,59 |
| skrzynia, 10 cm | −0,67 | −0,66 | −0,54 | −0,42 |
| skrzynia, 30 cm | −0,30 | −0,28 | −0,25 | −0,20 |
| skrzynia, 60 cm | −0,11 | −0,09 | −0,09 | −0,07 |
| kosz 1,1 m, 30 cm | −0,37 | −0,36 | −0,31 | −0,24 |
| kosz, 1 m | −0,07 | −0,06 | −0,06 | −0,05 |
| ławka (siedzisko 0,4 m na 0,45 m), pod środkiem | −0,75 | −0,91 | −0,73 | −0,68 |
| ławka, 30 cm przed | −0,22 | −0,21 | −0,21 | −0,19 |
| wąskie siedzisko 0,3 m, pod środkiem | −0,55 | −0,66 | −0,54 | −0,50 |
| samochód (prześwit 18 cm), 20 cm pod krawędzią | −2,9 | −3,3 | −2,8 | −2,3 |
| samochód, pod środkiem | −5,6 | −6,6 | −4,8 | −3,4 |
| samochód, 30 cm obok | −0,72 | −0,69 | −0,59 | −0,48 |
| samochód, 1 m obok | −0,32 | −0,28 | −0,27 | −0,21 |

**Ta sama skrzynia w ulicy** (ściany po 15 m z obu stron, skrzynia 1 m od ściany, dodatkowy spadek względem ziemi
w tym samym miejscu bez skrzyni):

| szerokość ulicy | szczelina skrzynia–ściana, 10 cm od skrzyni | strona ulicy, przy styku | strona ulicy, 10 / 30 / 60 cm |
|---|---|---|---|
| 12 m | −1,12 EV | −0,21 EV | 0,00 / 0,00 / 0,00 |
| 20 m | −1,46 EV | −0,16 EV | 0,00 / 0,00 / 0,00 |
| 40 m | −1,67 EV | −0,14 EV | 0,00 / 0,00 / 0,00 |

Co z tego wynika:

- **Na otwartym terenie** wokół przedmiotu powstaje miękka „aureola”. Przy styku jest ona mocna (−0,6…−1 EV), ale na
  odległości równej mniej więcej połowie wysokości przedmiotu spada do −0,2…−0,3 EV, a na odległości równej wysokości
  do około −0,1 EV, czyli poniżej tego, co zwykle zauważa się bez porównania. Nie ma krawędzi.
- **Pod przedmiotem z niskim prześwitem** (samochód, kontener) jest naprawdę ciemno. To najpewniejszy i najlepiej
  widoczny przypadek.
- **W ulicy** obraz jest jednostronny. Po stronie zwróconej do otwartej ulicy dodatkowego cienia praktycznie nie ma,
  bo przedmiot zasłania tylko niebo już zasłonięte przez ścianę. Mocno ciemnieje natomiast szczelina między przedmiotem
  a ścianą, bo tam przedmiot zabiera właśnie tę część nieba, która zostawała.
- **Kształt nieba ma znaczenie.** Przy pochmurnym niebie (jaśniejszy zenit) bardziej ciemnieje pod daszkiem lub ławką,
  a mniej obok niskich brył. Przy bezchmurnym niebie w cieniu najjaśniejsze bywa niebo przy horyzoncie i nasłonecznione
  fasady naprzeciwko. To kierunki niskie, które niski przedmiot zasłania. Wtedy przyciemnienie jest „kierunkowe”: po
  stronie przedmiotu odwróconej od jasnej fasady [Wn, bez pomiaru].

## 4. Zdjęcia: co widać

Wszystkie zdjęcia pochodzą z Wikimedia Commons. Każde obejrzałem i powiększyłem w zaznaczonych miejscach. Nie znalazłem
kontrolowanego zdjęcia z pary „ten sam przedmiot w cieniu budynku, a obok czysta ziemia w tym samym cieniu” wykonanego
celowo do pomiaru [N]. Poniższe to zdjęcia przypadkowe.

| zdjęcie | warunki | co widać | siła dowodu |
|---|---|---|---|
| [DFC 4002, ulica rano, samochody w cieniu](https://commons.wikimedia.org/wiki/File:DFC_4002_Quiet_morning_on_a_sunlit_street_of_row_houses_with_parked_cars_and_shaded_storefronts.jpg) | słonecznie, niebo błękitne; pikap stoi w cieniu budynków i markiz, auta po lewej w cieniu drzew | pod czarnym pikapem asfalt jest wyraźnie ciemniejszy niż zacieniony asfalt obok. Pod autami po lewej to samo. Granica jest miękka. Dalej od aut zacieniony asfalt jest jednolity, bez widocznej „aureoli” [P] | dobry dla „pod spodem ciemno”, słaby dla „obok”: tam nic nie widać |
| [DSC 6624, ulica pod pochmurnym niebem](https://commons.wikimedia.org/wiki/File:DSC_6624_Quiet_residential_street_under_a_cloudy_sky_with_low-town_houses_and_parked_cars_lining_the_road.jpg) | całkowite zachmurzenie, brak słońca | pod każdym z trzech zaparkowanych aut jest ciemny pas o miękkich brzegach, sięgający niewiele poza obrys auta [P] | mocny: przy samym świetle nieba przedmiot robi „cień” |
| [DSC 9538, dziedziniec z betonowymi donicami](https://commons.wikimedia.org/wiki/File:DSC_9538_A_modern_urban_courtyard_with_trees_planters_and_curved_benches_a_person_sits_on_a_bench_while_red_lanterns_and_decorations_hang_near_a_walkway_between_contemporary_buildings_and_high-rise_towers_in_the_background.jpg) | jasne, rozproszone światło, budynki wokół | u podstawy jasnych donic na szarej posadzce widać tylko wąską, słabą ciemniejszą linię styku, bez szerokiej plamy [P] | zgodny z obliczeniem dla jasnego przedmiotu: efekt słaby i wąski |
| [Bournemouth, ławka po śniegu](https://commons.wikimedia.org/wiki/File:Bournemouth,_a_wintry_Upper_Gardens_scene_-_geograph.org.uk_-_1653474.jpg) | niskie słońce, ławka w cieniu drzew | pod ławką jest ciemna plama, ale to **gołe, mokre podłoże, na które nie spadł śnieg**, a nie efekt światła [P] | pułapka: nie jest dowodem ani za, ani przeciw |
| [Bench at the top of the snowy hill (Mississauga, 10.12.2025, CC0)](https://commons.wikimedia.org/wiki/File:Bench_at_the_top_of_the_snowy_hill.jpg) | mgła, śnieg, całkowite zachmurzenie | pod wąskim, ciemnym siedziskiem nie widać przyciemnienia [P] | słaby, z trzech powodów niżej |

**Dlaczego ławka z Mississaugi nie przeczy fizyce [Wn].** (1) Aparat stoi prawie na wysokości grzbietu wzgórza, więc
ziemię pod siedziskiem widać pod bardzo ostrym kątem i w większości zasłania ją krawędź śniegu. Paska pod ławką
praktycznie nie widać. (2) Śnieg jest prześwietlony prawie do bieli, więc różnica rzędu −0,5 EV mogła zniknąć w
nasyceniu. (3) We mgle światło rozprasza sama mgła, również powietrze **pod** siedziskiem, a śnieg odbija je z powrotem.
Światło przychodzi wtedy z każdej strony, także z boku i z dołu (stąd „whiteout”, w którym znikają cienie i kontrast
[S: Wikipedia „Whiteout”]). To warunki skrajne, odwrotne do ulicy w słoneczny dzień. Hipoteza koordynatora („śnieg
i mgła = światło ze wszystkich stron”) jest więc rozsądna. Dodaję jednak, że samo to zdjęcie niczego nie rozstrzyga
z powodu kąta widzenia.

## 5. Pomiary

- **UV w cieniu parasoli i ścian** to najbliższe pomiary „ile światła jest w cieniu i od czego to zależy”. Ultrafiolet
  jest w dużej części rozproszony, więc zachowuje się jak światło nieba.
  - Pod parasolem plażowym dociera około 34% UV, głównie z odsłoniętej części nieba [S: badanie z Walencji, prasa
    naukowa].
  - Ou-Yang i Shyr (2017) zmierzyli miernikiem UV i modelem widoku nieba ochronę pod parasolami i przy ścianach. Ochrona
    rośnie z większym zakryciem, z niższym odbiciem otoczenia i **im bliżej środka cienia**. Typowy parasol daje
    współczynnik 3–7 [S: abstrakt]. To bezpośredni pomiar zasady „w cieniu jaśniej tam, gdzie widać więcej nieba,
    ciemniej tam, gdzie mniej”, czyli dokładnie mechanizmu dodatkowego cienia.
  - Turnbull i Parisi dzielą cień na „widok nieba > 40%” i „< 40%” i pokazują, że przy niskim słońcu (kąt zenitalny
    70–76°) pod zadaszeniami jest nadal 51–65% UV pełnego słońca, bo dominuje niebo [S: abstrakty i raport].
- **Bezpośredni pomiar natężenia oświetlenia (luksów) pod ławką lub skrzynią w cieniu budynku: nie znalazłem [N].**
  Liczby z sekcji 3 to obliczenia, a nie pomiary.

## 6. Obserwacje malarzy i fotografów

- James Gurney (malarz realista, autor „Color and Light”) pisze o „occlusion shadows”: „Wherever two forms touch each
  other, or a form touches a floor, a dark line or accent results … Not much light makes it to that point of contact”
  [P, blog 2007]. Oraz: „The darkest parts of the shadow are usually at points of contact, called occlusion shadows”,
  bo nie dociera tam światło wtórne [P, blog 2010].
- Ten sam autor o świetle pochmurnym: „there's no sharp demarcation between light and shadow, and there aren't any
  definite cast shadows” [P, blog 2008].
- **Te dwa zdania nie są sprzeczne, ale trzeba je czytać razem [Wn].** W świetle rozproszonym (pochmurno, cień) nie ma
  wyraźnych, kształtnych cieni rzucanych. Są tylko ciemne akcenty przy styku. Gurney potwierdza więc i człowieka (brak
  „prawdziwego” cienia rzuconego w cieniu), i drugą stronę (przy styku jest ciemniej). Nie podaje liczb.
- Fotografowie: „otwarty cień” wymaga, żeby nad obiektem było niebo. Cień pod niskim, gęstym drzewem lub markizą
  „nie jest otwarty” i jest wyraźnie ciemniejszy [S: poradniki fotograficzne]. To ta sama zasada widoku nieba.

## 7. Od czego zależy siła dodatkowego cienia [Wn, chyba że zaznaczono]

- **Prześwit i zakrycie od góry.** To najsilniejszy czynnik. Daszek, siedzisko i podwozie zasłaniają zenit, który daje
  najwięcej światła na poziomą ziemię. Samochód: bardzo ciemno. Ławka: wyraźnie. Niska skrzynia: tylko przy styku.
- **Odległość od przedmiotu.** Efekt maleje mniej więcej do zera na odległości rzędu wysokości przedmiotu.
- **Ile nieba zostawia budynek i z której strony.** Na szerokim placu efekt jest symetryczny. W ulicy jest jednostronny:
  silny w szczelinie przy ścianie, zerowy po stronie otwartej ulicy (sekcja 3).
- **Odbicia (ściany, ziemia, sam przedmiot).** Jasny przedmiot i jasna nawierzchnia oddają część światła i osłabiają
  efekt przy styku z −1,0 do około −0,6 EV. Ciemny przedmiot na asfalcie prawie go nie osłabia. Nasłoneczniona fasada
  naprzeciwko to jasne źródło nisko nad horyzontem. Niski przedmiot je zasłania, więc może pojawić się słaby,
  kierunkowy cień po stronie odwróconej od tej fasady.
- **Pogoda.** Pochmurno: efekt najczystszy, podobny do cienia w cieniu. Mgła lub śnieg z chmurami: światło z każdej
  strony, więc efekt najsłabszy (whiteout [S]).
- **Wrażenie, a nie fizyka.** Oko porównuje sąsiednie pola, a miękki gradient −0,3 EV bez krawędzi łatwo przeoczyć. Ta
  sama różnica z ostrą krawędzią będzie wyraźnie widoczna. Dlatego ludzie często „nie widzą” aureoli wokół przedmiotów
  w cieniu, choć ją zmierzy światłomierz [Wn, bez źródła liczbowego].

## 8. Kto ma rację w samym sporze o rzeczywistość

| twierdzenie | ocena |
|---|---|
| Człowiek: „w rzeczywistości nie ma światła nieba, tylko słońce” | **Fałsz.** Niebo daje w zimowe przedpołudnie około 1/4 światła na otwartej ziemi, a w cieniu prawie całe (sekcja 1) |
| Człowiek: „przedmiot w całości w cieniu innego nie rzuca dodatkowego cienia” | **Fałsz dosłownie, prawda co do kształtu.** Pod przedmiotem i przy styku jest ciemniej, co widać na zdjęciach. Nie ma natomiast kształtnego cienia z krawędzią |
| Człowiek: „cienie się nie sumują” | **Prawda, jeśli myśleć o niebie.** Przesłony nieba nakładają się. Przedmiot zabiera tylko niebo, którego budynek nie zabrał. W ulicy po stronie ściany zabiera dużo, po stronie otwartej ulicy nic |
| Druga strona: „przedmiot w cieniu też przyciemnia ziemię obok, tylko słabo” | **Częściowo prawda.** Daleko (> ½ wysokości przedmiotu) słabo: −0,1…−0,3 EV, gradient. Przy styku i pod spodem wcale nie słabo: −0,6…−1 EV, pod autem −3 EV i więcej |
| Druga strona: „plama jest za mocna, bo brakuje odbić” | **Częściowo prawda dla rzeczywistości.** Odbicia osłabiają efekt przy styku o 0,2–0,4 EV (asfalt, ciemny przedmiot), a przy jasnych powierzchniach o więcej. Nie usuwają go jednak. Odbicia to nie jedyny czynnik: duży wpływ ma też to, czy budynek nie zasłania już tych samych kierunków nieba (sekcja 3) |

## 9. Najsłabsze miejsca

- **Brak bezpośredniego pomiaru luksów** pod przedmiotem w cieniu budynku [N]. Liczby to model z jednym odbiciem
  i niebem o równej jasności. Prawdziwe niebo w cieniu nie jest równe (jaśniejszy horyzont, jasne fasady), co zmienia
  kierunek i siłę efektu o kilka dziesiątych EV.
- **Zdjęcia są przypadkowe**, z kompresją JPEG i nieznaną krzywą tonalną aparatu. Mówią „jest ciemniej / nie widać
  różnicy”, a nie „o ile”. Nie znalazłem zdjęcia skrzyni lub ławki stojącej w cieniu budynku na pustym, jednolitym
  chodniku, gdzie dałoby się porównać ziemię przy niej i 1 m dalej [N]. Najprostszy sposób rozstrzygnięcia: zrobić
  takie zdjęcie samemu (słoneczny dzień, chodnik w cieniu kamienicy, skrzynia lub kosz, aparat z ręczną ekspozycją,
  ujęcie z góry) albo zmierzyć luksomierzem w telefonie przy styku, w 30 cm i w 1 m.
- Langer i Zucker, Langer i Bülthoff, Ou-Yang i Shyr, Turnbull i Parisi, Gardiner: znam z abstraktów lub streszczeń, bez
  pełnego tekstu. PDF Turnbull i Parisi i strona PubMed nie dały się pobrać.
- Model ASHRAE jest stary i zaniża światło rozproszone, więc udział nieba 25% przy 10° to raczej dolna granica.
- Strona dokumentacji z jednego ze źródeł (wiki „Whiteout”) ma przypisy oznaczone jako „better source needed”.

## 10. Źródła

Fizyka i pomiary:
- Langer M. S., Zucker S. W. (1994), *Shape-from-shading on a cloudy day*, JOSA A 11(2):467–478,
  [doi:10.1364/JOSAA.11.000467](https://doi.org/10.1364/JOSAA.11.000467) [S]. Wersja konferencyjna:
  [ICCV 1993](https://mlanthology.org/iccv/1993/langer1993iccv-diffuse) [S].
- Langer M. S., Bülthoff H. H. (2000), *Depth discrimination from shading under diffuse lighting*, Perception,
  [doi:10.1068/p3060](https://doi.org/10.1068/p3060) [S].
- Wikipedia, [Diffuse sky radiation](https://en.wikipedia.org/wiki/Diffuse_sky_radiation) (rozpraszanie Rayleigha,
  udziały) [S].
- Model bezchmurnego nieba ASHRAE (współczynniki A, B, C dla stycznia),
  [wyciąg ASHRAE Fundamentals](https://www.scribd.com/doc/299647429/Appendix-Solar-Radiation-pdf) [S]; Gueymard,
  Thevenard (2009), propozycja nowego modelu, [OSTI](https://www.osti.gov/biblio/21236005) [S].
- Niebo pochmurne CIE (Moon i Spencer 1942, L(θ)/Lz = (1 + 2 sin θ)/3),
  [dokumentacja colour-science](https://colour.readthedocs.io/en/latest/generated/colour.phenomena.sky_luminance_distribution_overcast_CIE2003.html) [S].
- Ou-Yang H., Shyr Y.-H. (2017), *Sun protection by umbrellas and walls*, Photochem. Photobiol. Sci.,
  [RSC](https://pubs.rsc.org/en/content/articlelanding/2017/PP/C7PP00214A),
  [PubMed 28850147](https://pubmed.ncbi.nlm.nih.gov/28850147/) [S].
- Turnbull D. J., Parisi A. V., [Spectral UV in public shade settings](https://research.usq.edu.au/item/9xw08/spectral-uv-in-public-shade-settings),
  [Scattered UV beneath public shade structures during winter](https://research.usq.edu.au/item/9xw09/scattered-uv-beneath-public-shade-structures-during-winter),
  [raport 2009](https://research.usq.edu.au/download/1c3625577a766335b1a934dfd8b3f1b30e9671db7b9972c3f84c25f3260a10cc/1390252/Turnbull_Parisi_Report_2009.pdf) [S].
- Parasol plażowy, 34% UV: [news-medical.net](https://www.news-medical.net/news/20100720/Diffused-ultraviolet-radiation-penetrates-beach-umbrellas.aspx) [S].
- Kanion uliczny i SVF: [projekt MULTICAST, Sky View Factor](https://www.multicastproject.polimi.it/satellites/city-scale-sky-view-factor),
  [Oke i in., model radiacyjny dla dzielnic](https://www.researchgate.net/profile/T_Oke/publication/258567817_A_Multi-layer_Radiation_Model_for_Urban_Neighbourhoods_with_Trees/links/5709f97d08ae8883a1fa5a5b.pdf) [S].
- Wikipedia, [Whiteout (weather)](https://en.wikipedia.org/wiki/Whiteout_(weather)) [S].

Malarze i fotografowie:
- Gurney J., [Albino Frogs / Occlusion Shadows (2007)](https://gurneyjourney.blogspot.com/2007/12/albino-frogs-occlusion-shadows.html) [P].
- Gurney J., [Light and Form, part 2 (2010)](https://gurneyjourney.blogspot.com/2010/02/light-and-form-part-2.html) [P].
- Gurney J., [Overcast Light, part 1 (2008)](https://gurneyjourney.blogspot.com/2008/01/overcast-light-part-1.html) [P].
- Clark R. N., [Clarkvision: lighting, part 6](https://clarkvision.com/articles/lighting.part6) [P].
- Podręcznik wojskowy, ekspozycja w otwartym cieniu: [armycommunications.tpub.com](https://armycommunications.tpub.com/SS0508/SS05080022.htm) [S].
- Otwarty cień, wymaga nieba nad głową: [Shotkit](https://shotkit.com/open-shade-photography/) [S].

Zdjęcia i obraz (Wikimedia Commons, obejrzane) [P]:
- [DFC 4002: ulica rano, auta w cieniu](https://commons.wikimedia.org/wiki/File:DFC_4002_Quiet_morning_on_a_sunlit_street_of_row_houses_with_parked_cars_and_shaded_storefronts.jpg)
- [DSC 6624: ulica pod pochmurnym niebem](https://commons.wikimedia.org/wiki/File:DSC_6624_Quiet_residential_street_under_a_cloudy_sky_with_low-town_houses_and_parked_cars_lining_the_road.jpg)
- [DSC 9538: dziedziniec z donicami](https://commons.wikimedia.org/wiki/File:DSC_9538_A_modern_urban_courtyard_with_trees_planters_and_curved_benches_a_person_sits_on_a_bench_while_red_lanterns_and_decorations_hang_near_a_walkway_between_contemporary_buildings_and_high-rise_towers_in_the_background.jpg)
- [Bournemouth: ławka po śniegu](https://commons.wikimedia.org/wiki/File:Bournemouth,_a_wintry_Upper_Gardens_scene_-_geograph.org.uk_-_1653474.jpg)
- [Bench at the top of the snowy hill](https://commons.wikimedia.org/wiki/File:Bench_at_the_top_of_the_snowy_hill.jpg)
- [Blue shadows (1652749)](https://commons.wikimedia.org/wiki/File:Blue_shadows_-_geograph.org.uk_-_1652749.jpg),
  [Blue shadows (1156431)](https://commons.wikimedia.org/wiki/File:Blue_shadows_-_geograph.org.uk_-_1156431.jpg)
- Claude Monet, [La Pie / The Magpie](https://commons.wikimedia.org/wiki/File:Claude_Monet_-_The_Magpie_-_Google_Art_Project.jpg)
