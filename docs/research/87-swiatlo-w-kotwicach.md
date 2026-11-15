# 87 - Światło i cienie w Kotwicach i Referencjach

Data: 2026-11-15. Ticket: [03 mapy silnika](../wayfinder-silnik/tickets/03-swiatlo-w-kotwicach-research.md).
Buduje na: [60](60-kotwice-stylu-kandydaci.md) (kandydaci, zrzuty), [22c](22c-gra-swiatla.md) (Octopath, REPLACED, KRZ
w §7), [84](84-stylizacja-swiatla-plener-opus.md) (Disco Elysium, Rain World, Graveyard Keeper, stylizacja A′). Tamtych
ustaleń nie powtarzam, tylko je przywołuję i uzupełniam.

Pytanie: jak Kotwice (Beat Cop, NORCO, REPLACED) i Referencje (Gemini Rue, Disco Elysium, Kentucky Route Zero) oraz
światło Octopath (HD-2D) rysują światło i cienie: krawędzie, kolor cienia, nakładanie źródeł, noc i lampy, wnętrze a
plener, co jest liczone, a co malowane, gdzie gra nagina fizykę. Na końcu: co z tego jest wymaganiem dla modelu Silnika
światła game2.

## Oznaczenia i uczciwość źródeł

- **[P]**: źródło pierwotne przeczytane w tej sesji (devblog, wywiad z twórcą, relacja z prelekcji twórcy).
- **[S]**: wtórne (prasa streszczająca, wyciąg wyszukiwarki, strona niewczytana, a treść znana z wyciągu).
- **[N]**: szukane i nieznalezione albo niedostępne.
- **[Oko]**: mój opis oficjalnych zrzutów ze Steam leżących w repo (`60-assets/`, `67-assets/`). To obserwacja, nie
  wiedza o technice. Zrzuty są materiałem reklamowym, JPEG-iem 1920×1080, i mogą być retuszowane.
- **[Wn]**: mój wniosek.

**Ograniczenie tej sesji:** w trakcie researchu narzędzia sieciowe przestały działać (limit). Nie przeczytałem przez to
pełnego postmortemu Gemini Rue (gamecareerguide przekierowuje, kopii nie pobrałem), wywiadu Alternative Magazine z
Nuernbergerem ani wywiadów o NORCO pod kątem światła. Strony Unreal Engine o Octopath zwracały 403. Prelekcja GDC 2014
„Scenography of Kentucky Route Zero” jest za logowaniem. Te luki są wymienione w sekcji 10.

## TL;DR

1. **Żadna z siedmiu gier nie liczy miękkiego światła z wielu źródeł w pixel arcie tak, jak chce game2.** Trzy są
   malowane (NORCO, Gemini Rue, Beat Cop [Oko]), jedna maluje w oparciu o render i liczy tylko część (Disco Elysium
   [P]), jedna jest płaską geometrią 3D z kształtami światła (KRZ [P]/[Oko]), a dwie to 3D z pełnym światłem pod
   sprite'ami (REPLACED, Octopath [P]). Silnik game2 nie ma więc gotowego wzoru technicznego. Gry dają za to
   **reguły wyglądu**, które da się przełożyć na dane.
2. **Wszędzie, gdzie widać cienie rzucane, są one równoległe i mają jeden kierunek na scenę** (Beat Cop [Oko], Disco
   [P]: „Exteriors have pretty much uniform light direction at each point in time”). Sztywna logika cieni z mapy jest
   zgodna z Kotwicami.
3. **Kolor cienia nie jest czernią, tylko daną pory dnia.** Disco Elysium [P]: „global sun/shade color variables for each
   time of day”. W NORCO i REPLACED cień ma barwę granatu lub zieleni [Oko]. To wprost wspiera krzywe doby w `.tres`.
4. **Noc to ten sam model z innymi danymi:** ciemniejsze tło plus sztuczne źródła. Disco [P]: „cast the neutral
   background image in shadow and used in-engine lights … This is essentially what we do with exteriors during the night”.
5. **Wnętrze i plener mają w Disco jeden pipeline, ale różne dane** [P]: we wnętrzach pora dnia zmienia tylko „intensity
   and warmth based on the window's direction”, w plenerze słońce zmienia kształt cieni. To ta sama zasada co w mapie
   („wnętrze to scena z zasłoniętym niebem i otworami”).
6. **Naginanie fizyki dla nastroju jest powszechne, ale dotyczy oświetlenia postaci i czasu, a nie kierunku cieni.**
   Octopath oświetla postacie stałym „reflektorem jak na scenie” [P, relacja z prelekcji]. Disco ma 3 zestawy cieni słońca
   na dobę i maskuje przeskoki pogodą [P]. KRZ przyciemnia światło przy przejściu chmur „small programmatic operation”
   [P]. Beat Cop pomija cienie budynków na chodniku [Oko].
7. **Postać:** sprite z namalowanym cieniowaniem plus prawdziwe światło daje „podwójny wyraz” (Octopath [P, relacja]), a
   płaska postać bez cienia „wisi” (REPLACED [P]: „The character is flat. So he wouldn't have any shadows beneath him.”).
   Silnik musi dać postaci cień kontaktowy i rzucany, a światło na sprycie trzymać w ryzach (parametr, nie normal mapy).
8. **Nakładania cieni z wielu źródeł żadna Kotwica nie pokazuje wprost.** REPLACED ma do 60 świateł naraz [P] w 3D, ale
   bez opisu cieni. To pole game2 musi zaprojektować samo (ticket 09 mapy silnika).

## 1. Tabela zbiorcza

| Gra | Co liczone, co malowane | Krawędź cienia | Kolor cienia | Wiele źródeł | Noc, lampy | Wnętrze a plener | Naginanie fizyki |
|---|---|---|---|---|---|---|---|
| **Beat Cop** (Kotwica: rzut) | wygląda na malowane tła + jednolite sprite'y cienia postaci i słupów [Oko]; brak źródła [N] | twarda, jeden ton, półprzezroczysta [Oko] | przyciemnienie podłoża (mnożenie), bez osobnej barwy [Oko] | nie widać; jeden kierunek na scenę [Oko] | noc to globalne przyciemnienie; plam lamp na zrzucie nie widać [Oko] | wnętrza płasko oświetlone, bez cieni rzucanych [Oko] | brak cieni budynków na chodniku, tylko drobne obiekty rzucają cień [Oko] |
| **NORCO** (Kotwica: kolor, malarskość) | malowane w pikselach [Oko]; o technice światła brak źródła [N] | miękka, ale w płaskich gromadach pikseli, bez widocznego wzoru ditheru [Oko] | granat, chłodny błękit, ciepłe tylko przy źródłach [Oko] | wiele małych ciepłych źródeł (okna, szyldy) na chłodnej bazie [Oko] | okna i neony jako źródła; postacie w kontrze z ciepłym konturem [Oko] | n/d (malowane każde tło osobno) | zachód: postać prawie sylwetka z ciepłym brzegiem [Oko] |
| **REPLACED** (Kotwica: postać i światło) | świat 3D, światło liczone w czasie rzeczywistym, postacie 2D [P] | miękka, filmowa, mgła wolumetryczna, DoF [P]/[Oko] | zielono-turkusowy przy ciepłych lampach [Oko] | „up to 60 real-time light sources simultaneously” [P] | „a lot of small lights … like lamps” [P] | n/d (jeden pipeline) [Wn] | lampy ustawiane pod kątem, żeby „złapać” płaskie sprite'y [P] |
| **Octopath (HD-2D)** (światło, ticket 01) | 3D w UE4, sprite'y 2D, światło liczone [P]; postacie oświetlane stałym reflektorem [P, relacja] | miękka z UE4, rozmycie DoF [S]/[Oko] | ciepło-brązowe, zależne od sceny [Oko] | światła punktowe dodane do efektów walki, żeby postacie rzucały cień [S] | pochodnie z halo, latarnia w lochach też jako „reflektor” [P, relacja] | n/d | stały reflektor na postaci zamiast realizmu; światło na sprite'ach „控えめ” (oszczędne) [P, relacja] |
| **Disco Elysium** (Referencja: światło, paleta zimy) | render 3D, malowany na wierzchu; mapa mnożnika cienia + ręczna mapa kierunku światła + kolory słońca i cienia na porę dnia; cienie postaci w czasie rzeczywistym [P] | malarska, ostra w słońcu, miękka przy oknach [P]/[Oko] | globalny kolor cienia na porę dnia [P]; chłodny szaro-niebieski w zimie [Oko] | lampy w silniku dla światła sztucznego, mapa pola światła dla okien [P] | noc w plenerze: tło w cieniu + światła silnika [P] | wnętrza: 1 mapa cienia na całą dobę; plener: 3 mapy (rano, południe, wieczór) [P] | 3 stany zamiast ciągłego ruchu słońca, przeskoki ukryte pogodą [P]; pole światła to przybliżenie „good enough” [P] |
| **Kentucky Route Zero** (Referencja: małe ciepłe źródło w ciemności) | płaska geometria 3D w Unity, kolor z wierzchołków, linie [P]; światło jako płaskie kształty (stożki, kliny) [Oko] | twarda, płaskie pola, aliasing celowy [P]/[Oko] | ciemniejszy ton tej samej barwy, warstwy mgły [Oko] | zwykle jedno dominujące źródło w kadrze [Oko] | jedna lampa lub reflektor w granatowej ciemności [Oko] | n/d | w akcie V cienie pokazują upływ czasu, chmury przyciemniają światło [P] |
| **Gemini Rue** (Referencja: postać) | malowane tła („mass-produce backgrounds”) [P] | miękkie stożki światła malowane gradientem z widocznymi pierścieniami [Oko] | szaro-fioletowy, zimny [Oko]; ograniczona paleta fiolet/zieleń [S] | jedno, dwa źródła w kadrze [Oko] | lampy sufitowe jako stożki z plamą na podłodze [Oko] | wnętrza przemysłowe, światło sztuczne [Oko] | postać bez cienia rzucanego [Oko] |

## 2. Beat Cop (Kotwica rzutu)

**Fakty:** brak pierwotnego źródła o świetle. Wyszukiwanie devlogów Pixel Crow i wywiadów dało tylko recenzje [N].

**Na oko** (`67-assets/beatcop-0..3.jpg`):
- Ulica za dnia (`beatcop-2`): każda postać, latarnia i parkometr rzuca **jeden długi, twardy cień w lewo w dół**, jednym
  półprzezroczystym tonem przyciemniającym chodnik. Wszystkie cienie są równoległe. Fasady **nie rzucają** cieni na
  chodnik, a samochody mają tylko ciemny pas pod spodem.
- Wieczór (`beatcop-0`): całość w ciepłym, sepiowym tonie, cienie dalej równoległe i długie. Pora dnia wygląda na
  globalną zmianę koloru, a nie na nowe źródła.
- Noc (`beatcop-3`): cała ulica przyciemniona i schłodzona. Na tym kadrze nie widać plam światła latarni.
- Wnętrza jako przekroje (`beatcop-1`): oświetlone płasko, bez cieni rzucanych, a podłoga ulicy pod nimi w ciemności.

**Wnioski [Wn]:** Beat Cop to wzór **kąta i czytelności**, a nie modelu światła. Bierze dwie rzeczy, które silnik
game2 robi przez konstrukcję: jeden kierunek cieni dla wszystkich obiektów i cień jako jeden płaski ton. Pominięcie
cieni budynków to uproszczenie produkcyjne. Mapa (cień zawsze od źródła) go wyklucza.

## 3. NORCO (Kotwica koloru i malarskości)

**Fakty:** Steam: „painterly and cinematic pixel art” (za 60). Twórca grafiki Yuts mówi o ograniczeniach pixel artu jako
narzędziu stylu (wywiad Carbon Copy, znany z wyciągu wyszukiwarki) [S]. Opisu techniki światła nie znalazłem [N].

**Na oko** (`60-assets/norco-1.jpg`, `norco-3.jpg`):
- Noc w Dzielnicy Francuskiej: **granatowa baza**, ciepłe okna, szyldy i neony jako wiele małych źródeł. Na chodniku
  ciepłe plamy pod witrynami, zrobione płaskimi gromadami pikseli w 2–3 tonach. **Nie widać uporządkowanego ditheru.**
  Postacie stoją w półmroku, a od strony witryn dostają ciepły kontur (kontrświatło).
- Zachód na podwórku: niebo i liście w pomarańczu, a postać i samochód na pierwszym planie **prawie sylwetkami** w
  granacie, z cienkim ciepłym brzegiem tam, gdzie patrzą na słońce.
- Kolor cienia to zawsze chłodna barwa nieba, nigdy szarość ani czerń.

**Wnioski [Wn]:** NORCO pokazuje zasadę temperatury z ticketu 08 (baza chłodna, ciepło przy źródłach) i to, że
przejścia światła to **kilka płaskich tonów, a nie dither na polu**, co jest zgodne z A′ z 84. Kontrświatło na postaci
to najmocniejszy efekt nastroju w tych kadrach. Wszystko jest malowane, więc silnik musi to uzyskać z danych (kolory
źródeł i nieba), a nie z ręki artysty.

## 4. REPLACED (Kotwica postaci i światła)

**Fakty:**
- Reżyser Yura Zhdanovich w wywiadzie Bonus Action (2026) [P]: „The only thing 2D in the game is the characters”,
  „Everything else is just super stylized 3D.”, „The character is flat. So he wouldn't have any shadows beneath him.”,
  „There were a lot of small lights, actually, in this game, like lamps.” Narracja autorki artykułu: zespół zbudował
  własny pipeline renderowania, a gra obsługuje do 60 źródeł światła w czasie rzeczywistym. Lampy są ustawiane pod
  kątem, który „łapie” płaskie sprite'y i daje im ciężar (opis autorki, nie cytat) [P/S].
  [Bonus Action](https://bonus-action.com/feature/replaceds-director-taught-himself-everything-from-scratch-to-make-the-most-beautiful-pixel-art-game-of-the-year-i-just-got-a-keen-eye-on-things/)
- Studio w wywiadzie GamingBolt [P]: „Lighting is the core component of any cinematic scene”; „we have spent a lot of time
  developing our own Scriptable Rendering Pipeline for Unity”, „combining some of the great visual features and post
  processing effects found in Unity's HDRP”. Inspiracje: Octopath Traveler, The Last Night, Limbo, Inside.
  [GamingBolt](https://gamingbolt.com/replaced-interview-inspirations-for-art-style-ranged-and-melee-combat-exploration-and-more)
- Xbox Wire (wpis studia, 2026) [P]: „Whenever we tried experimenting with 3D models, the result was sub-par and very
  noisy.” (o postaciach); styl to „pixel art enhanced by modern depth-of-field, lighting, and cinematic visual effects”.
  [Xbox Wire](https://news.xbox.com/en-us/2026/04/14/replaced-combat/)
- Artykuł Indie Games Devel [S]: wiele świateł wolumetrycznych, kurz, mgła; „clouds can also cast shadows on themselves”.
  [Indie Games Devel](https://indiegamesdevel.com/replaced-all-we-know/)

**Na oko** (`60-assets/replaced-0.jpg`, `replaced-1.jpg`): cztery ciepłe lampy z mocnym bloomem na zielono-turkusowym,
zamglonym tle; postać ciemna z cienkim jasnym konturem od lamp za nią. Cienie miękkie, rozmyte mgłą i DoF. Bardzo
mocny kontrast ciepło/zimno.

**Wnioski [Wn]:** z REPLACED ticket 08 bierze „smugi światła, ciepłe punkty z bloomem”, a odrzuca DoF i tła 3D. Dla
silnika ważne są trzy rzeczy: (1) **wiele małych źródeł naraz** (60) jest normą tego wyglądu, (2) twórcy sami mówią,
że płaska postać bez cienia wygląda na nieważką, i rozwiązują to ustawieniem świateł, (3) postać ma czytelny kontur
w kontrze. W game2 nie ustawiamy świateł pod postać (to byłoby strojenie pod scenę), więc ciężar postaci musi dać
**cień kontaktowy i cień rzucany z każdego źródła**, a kontur w kontrze musi wynikać z danych źródła.

## 5. Octopath Traveler, HD-2D (światło z ticketu 01)

**Fakty:**
- Relacja Famitsu (2019) z prelekcji CEDEC+KYUSHU 2018 „「懐かしさ」と「新しさ」の融合” [P, relacja z prelekcji twórców]:
  pixel art ma światło i cień namalowane w pikselach, więc „そこに光をそのまま当てると、2重の表現になってしまい違和感がある”
  (gdy oświetli się go wprost, powstaje podwójny wyraz i coś zgrzyta), dlatego „ライティング表現は控えめにした” (światło
  ograniczono). Realistyczne światło sprawiało, że postacie wyglądały jak „非常に薄っぺらい” (bardzo płaskie), więc
  artystka 飯塚三華 (Iizuka) zmieniła je na „必ず同じ位置からスポットライトが当たる“舞台演出”” (inscenizację teatralną, w której
  reflektor zawsze pada z tego samego miejsca). Latarnia w lochach też działa „スポットライト方式”. Obiekty mniejsze od
  postaci są 2D, większe 3D, a podobnej wielkości (drzewa, trawa, skały) to „2,5D” bez tylnej ściany.
  [Famitsu](https://www.famitsu.com/news/201906/07169244.html)
- Wywiad Nintendo Dream (tłumaczenie Nintendo Everything) [P/S, tłumaczenie fanowskie]: Asano chciał „lighting mixed with
  pixels in a way that emphasized how light shines on objects and how shadows fall”; Morimoto: samo dramatyczne światło
  w 2D „wasn't enough”. [Nintendo Everything](https://nintendoeverything.com/octopath-traveler-devs-on-character-origins-visual-style-initial-hd-rumble-plans-much-more/)
- Unreal Engine Spotlight (2019): światło punktowe dodane do efektów walki, „the light could create shadows of the
  characters on the environment” [S: strona zwraca 403, treść z wyciągu wyszukiwarki].
  [Unreal Engine](https://www.unrealengine.com/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true)
- Octopath II: dynamiczny cykl dnia i nocy (Unreal, wyciąg [S]); wywiad Dengeki mówi o dniu i nocy tylko jako o zmianie
  życia NPC i muzyki [P]. [Dengeki](https://dengekionline.com/articles/151745/)
- 4Gamer relacjonuje prelekcję artystyczną z Unreal Fest East 2018 (śródtytuły: Bloom, DoF, Bokeh, Lens Flares, Vignette)
  [N: strona nieczytelna przez złe kodowanie]. [4Gamer](https://business.4gamer.net/article/1810/18101801/)

**Na oko** (`60-assets/octopath-1.jpg`): miasto nocą przy pochodniach; pochodnie mają halo, płoty i słupki rzucają długie,
miękkie cienie w jedną stronę, postać jest oświetlona równo i jasno na tle ciemniejszego otoczenia, brzegi kadru
rozmyte (DoF tilt-shift).

**Wnioski [Wn]:** najcenniejsze w Octopath jest to, **jak twórcy nagięli światło na postaci**: nie liczą go fizycznie
z otoczenia, tylko dają stały reflektor, bo realistyczne światło spłaszczało sprite'y i dublowało namalowane
cieniowanie. W game2 odpowiednikiem jest pytanie, jak mocno bufor światła modeluje sprite postaci (o tym w sekcji 9).
Cienie rzucane w Octopath pozostają fizyczne (UE4), a naginane jest tylko oświetlenie samej postaci.

## 6. Disco Elysium (Referencja: światło i paleta zimy)

Najlepiej udokumentowana gra z listy (devblog ZA/UM 2016). Uzupełniam 84, które cytowało tylko „Shedding light”.

**Fakty [P]:**
- Aleksander Rostov, [devblog 2016-02-01](https://discoelysium.com/devblog/2016/02/01/so-the-first-month-of-2016-has-come-and-gone):
  światło dzienne we wnętrzach w czterech stanach („morning, noon, evening and night”). Wcześniejszy system addytywny
  z mapą światła na każde okno i porę dnia dawał „a realistic global illumination look”, ale za dużo pełnych obrazów.
  Przełom przyszedł przy oświetlaniu postaci: naiwnie można by położyć tło w cień i oświetlić scenę światłami silnika,
  „This is essentially what we do with exteriors during the night”. We wnętrzach byłoby to „bland”, bo czas
  rzeczywisty nie daje „diffused bounce light ambience”. Dlatego postacie oświetla się „a mixture of a lightfield map
  for natural light coming in the window and in engine light sources for artificial illumination such as desk lamps”.
  Jednokanałowa mapa cienia tła z samym światłem naturalnym pozwala „dim and colourize background art based on time of
  day and the weather outside”.
- Siim Raidma, [Shedding light](https://discoelysium.com/devblog/2016/02/02/shedding-light): scena „has no in-engine
  lights”; składniki: neutralny render z przemalowaniem, czarno-biała mapa mnożnika światła/cienia w alfie albedo, mapa
  kierunku światła, „global sun/shade color variables for each time of day”. Niska alfa przy oknach daje „strongly
  directional light with stronger shades/shadows”, wysoka rozprasza światło i zmiękcza cienie. Metoda zakłada nisko
  częstotliwościowe światło i jest przybliżeniem „good enough”.
- Siim Raidma, [Weather duty](https://discoelysium.com/devblog/2016/02/10/weather-duty): „Exteriors have pretty much uniform
  light direction at each point in time”, a we wnętrzach „light shine in from the windows” i „daytime modulates only the
  light's intensity and warmth based on the window's direction”, więc wystarcza „a single shadow map for the whole day
  cycle”. W plenerze „We are going to bake shadows for morning, noon and night”; „Lack of a color means that spot is in
  shadow”; „shadow casting between the characters and the background is real time”. Pogoda z sum sinusów
  (opady, temperatura, mgła, zachmurzenie od „clear to overcast to gloomy”). Najciekawsze dla nas: „I misuse a shadow map
  to mask whatever comes down from sky … anything in "shadow" remains dry and rest of the scene gets affected by rain,
  snow, hail”, a mokre miejsca schną szybciej w słońcu dzięki mapie cienia słońca.
- Siim Raidma, [Picture math](https://discoelysium.com/devblog/2016/03/07/picture-math): „since we want to use real time
  lights we can't just bake shadows into the background”; cień wyciąga się przez **dzielenie** renderu z słońcem przez
  render neutralny („Dividing the renders instead of subtracting gave us exactly what we wanted”), dla trzech pór dnia,
  przy neutralnym pochmurnym świetle bazowym.

**Na oko** (`67-assets/disco-0.jpg`): zimowe podwórko w południe; ostre, malarskie cienie płotu i drzewa leżą w jednym
kierunku, mają chłodny szaro-niebieski kolor, a nie szary; śnieg w cieniu jest niebieski.

**Wnioski [Wn]:**
- Disco ma **jeden pipeline z danymi**: kolory słońca i cienia na porę dnia, mapa cienia, kierunek. Wnętrze i plener
  różnią się danymi (jedna mapa na dobę kontra trzy), nie logiką. To mocne potwierdzenie zasady z mapy.
- „Pochmurne” światło neutralne jest **bazą**, a słońce to mnożnik nad nią. To ten sam rozkład co nasze niebo + słońce.
- Trzy stany słońca na dobę to kompromis produkcyjny malowania. Silnik liczący bufor go nie potrzebuje, ale pokazuje,
  że **ciągły ruch słońca nie jest konieczny dla nastroju**. Krzywe w `.tres` mogą mieć płaskie odcinki.
- Nakładanie: światła sztuczne silnika dodają się do światła naturalnego zapisanego w mapie. Disco nie opisuje
  stylizacji nakładających się cieni.
- Mapa „co widzi niebo” użyta do pogody (śnieg, mokro) to pomysł na później dla śniegu w Poligonie Ulica.

## 7. Kentucky Route Zero (Referencja: małe ciepłe źródło w wielkiej ciemności)

**Fakty:**
- Tamas Kemenczy, [Uses This](https://usesthis.com/interviews/tamas.kemenczy/) [P]: gra w Unity Pro, Blender do „obsolete
  vertex-based coloring and line art”, Grapher do krzywych i filtrów w shaderach.
- Kemenczy i Jake Elliott, [VICE](https://www.vice.com/en/article/kentucky-route-zero-creators-on-finding-hope-and-the-burden-of-4k-gaming/)
  [P]: o akcie V: „incorporating the shadows to indicate the passage of time”, „during the mid-day, there's clouds and the
  light dims a little and then dims back up”, „it's such a small programmatic operation but I was really happy with the
  emotional effect it drew”. „The game was always meant to have visible aliasing, or 'jaggies' as part of the art
  style.” Wzorce: gry DOS z wielokątami (VGA, SVGA), Another World. Elliott: Kemenczy zbudował własne skalowanie, które
  zachowuje cienkie linie.
- Prelekcja GDC 2014 „Scenography of Kentucky Route Zero” (teatr, scenografia, slow cinema) [N: za logowaniem].
  [GDC Vault](https://gdcvault.com/play/1020596/Scenography-of-Kentucky-Route)

**Na oko** (`67-assets/krz-0.jpg`, `krz-2.jpg`): światło jest **płaskim kształtem**: biały klin pod dachem stacji, smuga
w oknie sklepu jako jasny wielokąt, stożek reflektora ciężarówki. Granatowa noc, jedno źródło, postacie bez cieni
rzucanych, płaskie wypełnienia bez gradientów. Głębia w lesie z warstw tonu (bliżej ciemniej, dalej jaśniej, mgła).

**Wnioski [Wn]:** KRZ dowodzi, że **twarde, płaskie pola światła** z aliasingiem dają nastrój mocniejszy niż gładkie
gradienty. Z wypowiedzi Kemenczy'ego wynika, że drobna, programowa modulacja jasności (chmury) ma duży efekt
emocjonalny. U nas to krzywa lub szum siły słońca w danych, a nie osobna logika.

## 8. Gemini Rue (Referencja: postać)

**Fakty:** Joshua Nuernberger, [postmortem (Game Developer, streszczenie)](https://www.gamedeveloper.com/production/gamecareerguide-feature-postmortem---i-gemini-rue-i-)
[P]: styl dobrany tak, żeby „mass-produce backgrounds” i „evoke a strong atmosphere with minimal time investment”;
„the combination of pixel art, impressionistic brush strokes, and a striking palette”. Inspiracja: Cowboy Bebop. Opis
ograniczonej palety fiolet/zieleń pochodzi z podcastu Silver Spook [S]. Pełny postmortem i artykuł „Visually Directing
the Player” [N].

**Na oko** (`67-assets/geminirue-0.jpg`, `geminirue-2.jpg`): światło sufitowe jako miękki stożek namalowany na ścianie
i plama na podłodze; **na podłodze widać koncentryczne pierścienie gradientu** w kilku płaskich krokach, bez ditheru.
Postać nie rzuca cienia. Zimna, fioletowo-szara baza.

**Wnioski [Wn]:** Gemini Rue jest Referencją postaci, nie światła. Przy okazji pokazuje ten sam wygląd co A′:
schodkowy gradient lampy z płaskich pierścieni. Brak cienia postaci to brak, nie wzór.

## 9. Odpowiedzi na pytania ticketu, przekrojowo

| Pytanie | Co mówią źródła i zrzuty | Wniosek dla modelu [Wn] |
|---|---|---|
| Krawędzie cieni | Twarde, jednotonowe: Beat Cop, KRZ [Oko]. Malarskie, ostre w słońcu i miękkie przy oknach: Disco [P]. Miękkie filmowe: REPLACED, Octopath [Oko]. Dither na polu nie występuje w żadnym kadrze [Oko]. | Twardość ma wynikać z geometrii (słońce ostre, okno i niebo miękkie, jak w Disco), a stylizacja A′ zamienia miękkość na kilka pól ze szwem. Zgodne z 84. |
| Kolor cienia | Globalny kolor cienia na porę dnia: Disco [P]. Granat, turkus, chłodny błękit: NORCO, REPLACED, Disco [Oko]. Beat Cop: ciemniejszy ton [Oko]. | Cień = światło nieba + ambient w danym miejscu, z kolorem z krzywej doby. Nigdy czerń. |
| Nakładanie wielu źródeł | Wiele źródeł naraz: REPLACED (60) [P], NORCO [Oko]. Światła sztuczne dodane do naturalnego: Disco [P]. Graveyard Keeper (z 84): 1 cień od słońca i do 3 od świateł [P]. Stylizacji nakładających się cieni nie opisuje nikt [N]. | Brak wzorca. Nakładanie musi wynikać z sumy światła w buforze (cień jednego źródła tam, gdzie świecą inne, jest tylko jaśniejszy). Do sprawdzenia w prototypie 09. |
| Noc i lampy | Noc w plenerze = tło w cieniu + światła silnika: Disco [P]. Wiele małych lamp: REPLACED [P]. Jedno ciepłe źródło w ciemności: KRZ [Oko]. Kontrświatło na postaci: NORCO, REPLACED [Oko]. | Noc to ten sam model z niskim niebem i włączonymi lampami. Kontur postaci w kontrze ma wynikać ze źródeł za postacią. |
| Wnętrze a plener | Disco: we wnętrzu pora dnia zmienia tylko natężenie i ciepło zależnie od kierunku okna; w plenerze słońce zmienia kształt cieni; jeden pipeline [P]. | Potwierdza zasadę mapy: różnią się tylko dane. |
| Liczone a malowane | Liczone: REPLACED, Octopath (3D), cienie postaci w Disco [P]. Malowane: NORCO, Gemini Rue, Beat Cop [Oko]; Disco częściowo (mapy z renderu + przemalowanie) [P]. | Game2 liczy wszystko. Malarskość musi przyjść z danych (kolory, krzywe) i stylizacji, a nie z ręki. |
| Gdzie nagina fizykę | Postać w stałym reflektorze: Octopath [P, relacja]. Lampy pod kątem pod sprite'y: REPLACED [P/S]. 3 stany słońca i pogoda zamiast ciągłości: Disco [P]. Chmury przyciemniają: KRZ [P]. Brak cieni budynków: Beat Cop [Oko]. | Naginane jest **oświetlenie postaci, czas i pogoda**, a nie kierunek cieni. Silnik ma to przyjmować jako dane, a nie jako wyjątek w kodzie. |

## 10. Najsłabsze miejsca i czego nie przeczytałem

- **Beat Cop, NORCO, Gemini Rue:** brak pierwotnych źródeł o świetle. Wszystko o ich świetle to [Oko] z 2–4 zrzutów
  reklamowych.
- **Octopath:** kluczowe zdania pochodzą z relacji Famitsu z prelekcji CEDEC+KYUSHU 2018, a nie ze slajdów. Część
  zdań to narracja dziennikarza. Strona Unreal (cienie postaci od świateł efektów) była niedostępna (403). Relacja 4Gamer
  z Unreal Fest East 2018 nieczytelna.
- **REPLACED:** zdanie o lampach ustawianych pod sprite'y i liczba 60 to narracja autorki Bonus Action, a nie cytat
  reżysera. Nie wiem, jak gra rzuca cień płaskiej postaci.
- **KRZ:** prelekcja GDC za logowaniem; „światło jako płaskie kształty” to obserwacja, nie opis twórców.
- Narzędzia sieciowe wyczerpały limit w połowie sesji. Do doczytania ręcznie: pełny postmortem Gemini Rue
  (gamecareerguide, dziś przekierowuje), wywiad [Alternative Magazine](https://alternativemagazineonline.co.uk/2011/04/16/interview-in-conversation-with-joshua-nuernberger-creator-of-gemini-rue/),
  wywiady o NORCO ([Game Developer, Road to IGF](https://www.gamedeveloper.com/road-to-igf-2023/-i-norco-i-and-capturing-the-spirit-of-louisiana-through-sci-fi-storytelling),
  [MCV](https://mcvuk.com/business-news/when-we-made-norco-geography-of-robots-talks-crunch-religion-and-preserving-a-culture-in-their-debut-title)),
  [GamesRadar o KRZ](https://www.gamesradar.com/the-making-of-kentucky-route-zero/).

## 11. Co z tego dla Silnika światła game2

Wymagania i wnioski do modelu (ticket 07 „Jeden model światła”) i kontraktu (08). Wszystko poniżej to [Wn] oparte na
faktach z sekcji 2–8. Nie są to decyzje człowieka.

**Wymagania potwierdzone przez Kotwice (wejście do modelu):**

1. **Jeden kierunek na źródło, równoległe cienie słońca.** Każda gra z cieniami rzucanymi tak robi (Beat Cop [Oko],
   Disco [P]). Zgodne ze „sztywną logiką cieni” z mapy. Silnik nie może mieć źródła, które daje cienie o różnych
   kierunkach w jednej scenie.
2. **Kolor cienia to dana doby, nie czerń.** Model ma rozdzielać światło na składniki (słońce, niebo, źródła
   sztuczne), a cień jednego składnika ma pokazywać kolor pozostałych. Kolory słońca i nieba jako krzywe doby w `.tres`
   (Disco [P]: kolory słońca i cienia na porę dnia).
3. **Noc to te same dane, nie tryb.** Niebo i słońce schodzą krzywymi do nocy, lampy i okna się zapalają (Disco [P]).
   Żadnego przełącznika „noc”.
4. **Wnętrze i plener: jeden model, różne dane** (Disco [P]). We wnętrzu słońce i niebo wchodzą tylko przez otwory.
   To już jest zasada mapy, a Disco pokazuje, że działa w wydanej grze.
5. **Wiele małych źródeł naraz.** REPLACED ma do 60 [P], NORCO wiele okien i szyldów [Oko]. Model nie może mieć małego
   limitu źródeł na obiekt (przypomnienie: Light2D w Godot ma 16 na element, 22c §5). Bufor liczony raz na scenę jest
   tu właściwym kierunkiem. Liczbę źródeł do testu wydajności trzeba wpisać do specyfikacji (propozycja do decyzji:
   rząd kilkudziesięciu w Lokacji).
6. **Ciężar postaci przez cień, nie przez ustawianie świateł.** REPLACED mówi wprost, że płaska postać bez cienia jest
   problemem [P], i rozwiązuje go ręcznym ustawieniem lamp. Game2 tego nie może (zakaz strojenia pod scenę), więc
   kontrakt postaci musi dawać silnikowi bryłę do cienia kontaktowego i rzucanego od każdego źródła. Mapa grafiki
   to już ustaliła (postać i meble jedną funkcją cienia, ticket 36). Kotwica to potwierdza.
7. **Pola zamiast gradientów.** NORCO, KRZ i Gemini Rue pokazują przejścia światła jako kilka płaskich tonów
   [Oko], a Disco zakłada nisko-częstotliwościowe światło [P]. To wspiera A′ z 84 (płaskie poziomy, wąski szew).
   Żaden kadr nie ma ditheru na całym polu.

**Gdzie Kotwice naginają fizykę, a game2 może to wyrazić danymi (kandydaci do krzywych w `.tres`):**

8. **Siła modelowania postaci światłem.** Octopath ograniczył światło na sprite'ach, bo dublowało namalowane cieniowanie
   [P, relacja]. Kandydat na jeden parametr `.tres`: ile kierunkowej zmienności bufora trafia na sprite (od „postać
   tylko przyjmuje kolor i jasność miejsca” do „pełne modelowanie”). Parametr jest globalny, nie per scena.
9. **Kontrświatło (kontur postaci).** NORCO i REPLACED czytają postać w ciemności dzięki jasnemu brzegowi od źródeł za
   nią [Oko]. Kandydat: kontur jako funkcja źródeł (światło z tyłu postaci względem kamery) z siłą w `.tres`. Wymaga
   maski brzegu sprite'a w kontrakcie postaci. Do oceny w prototypie, nie przesądzam.
10. **Czas jako dane artystyczne.** Disco ma 3 stany słońca na dobę [P], KRZ przyciemnia słońce chmurami [P]. Mapa już
    przewiduje krzywe godzina → wysokość i azymut oraz kolory w czasie. Dochodzi kandydat: modulacja siły słońca
    (zachmurzenie) jako krzywa lub wolny szum w danych, bez osobnej logiki pogody w silniku.
11. **Stały reflektor na postaci (Octopath)** odrzucam jako wzór dla game2 [Wn]: światło niezależne od źródeł łamie
    „cień zawsze od źródła”. Zostawiam to jako pytanie dla człowieka, gdyby postacie w prototypie wyglądały płasko.

**Czego Kotwice nie rozstrzygają (do zaprojektowania w game2):**

12. **Nakładanie cieni z wielu źródeł.** Żadna gra tego nie pokazuje ani nie opisuje. Prototyp „Nakładanie cieni” (09)
    jest więc niezbędny. Kotwice podpowiadają tylko cel wyglądu: chłodny cień, ciepło przy źródłach i płaskie pola.
13. **Cienie architektury w plenerze.** Beat Cop je pomija [Oko], Disco je maluje [P]. Game2 musi je liczyć z
    geometrii. Brak wzorca stylizacji długich cieni fasad w pixel arcie.

**Na później (poza zakresem tej mapy, zanotować):**

14. **Bufor widoczności nieba jako maska pogody.** Disco używa mapy cienia z góry do maskowania deszczu i śniegu, a mapy
    słońca do schnięcia [P]. Dla śniegu w Poligonie Ulica silnik mógłby udostępniać innym systemom swój składnik nieba,
    tylko do odczytu. Warto, żeby kontrakt nie zamykał tej drogi.
