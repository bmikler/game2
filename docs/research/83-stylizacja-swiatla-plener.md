# 83 - Stylizacja światła i cieni w plenerze w pixel arcie

Data: 2026-11-15. Ticket: [39](../wayfinder/tickets/39-stylizacja-swiatla-plener-research.md). Kontynuacja researchu
[82](82-stylizacja-swiatla-pixel-art.md). Pytanie: jakim algorytmem zamienić dokładnie policzone światło (bufor z ticketów
36 i 14) na pixel art tak, żeby w plenerze działały i bardzo łagodne przejścia (niebo zasłaniane przez budynki, pochmurny
dzień), i długie ostre cienie słońca; oraz czy wnętrze i ulica mogą mieć jeden algorytm.

## Uczciwe zastrzeżenie o źródłach

Tak jak w 82: prawie żadna z gier z listy nie ma publicznie opisanego algorytmu stylizacji światła w plenerze. W tej
rundzie przeczytano (nie tylko wyszukano) m.in. Ryan Juckett (GDC 2026), 80.lv (Nectarmancer, Kingdom), devlog Blessings
of the Forge, blog Graveyard Keeper, Surma (Ditherpunk), README Dither3D (Rune Skovbo Johansen), wpis Aras P. o
Dither3D na Playdate, PlayStation Blog o Obra Dinn, wątek Unity o per-texel lighting. Slajdy GDC 2026 (Never's End) i
wątek TIGSource Lucasa Pope'a (403 / archiwum zablokowane) **nie były czytelne**.
Ocena: **[P]** = źródło pierwotne (autor, kod, README) przeczytane; **[S]** = wywiad/wtórne/forum; **[W]** = wiedza
ogólna, niezweryfikowana tu źródłem; **[Wn]** = nasz wniosek inżynierski (nie jest twierdzeniem o grach).
Główny wynik negatywny: **nie znaleziono żadnej gry pixel art, która publicznie opisuje miękkie zasłanianie nieba w
plenerze stylizowane ditherem.** To nie dowodzi, że takiej gry nie ma, tylko że nie ma źródła.

## 1. Jak działa dziś nasz wygląd (z kodu, nie ze źródeł)

Pliki: `style-lab/lighting/light_common.gdshaderinc` (`light_levels`, `dither_step`), `lit.gdshader` (`view_level`),
`street_fn.gdshaderinc`.

- **A** (`look = 1`): `e = log2(luma(światło + ambient)) / level_stops` (krok 0,5 EV), `k = floor(e)`, a w górnych
  `level_band` = 30% kroku `t` rośnie 0→1 i porównuje się z Bayer 4×4: `bayer4(px) < t ? k+1 : k`. Szerokość pasa
  ditheru jest więc **stała w jednostkach światła (EV), a nie w pikselach ekranu**.
- Przy `light_res` > 1 poziomy A liczy shader sprite'ów w pikselu widoku z **bilinearnie interpolowanego** bufora
  (`light_map_smooth`, alfa = ambient); bufor zostaje w pikselu świata (ticket 37: bufor ×k zabijał wydajność).
  Bayer jest zakotwiczony w pikselu widoku (`floor(world_pos * light_res)`).
- **B** (`look = 2`): `dither_step` na widoczności klucza (słońce, lampy) z pasem `key_band` w jednostkach widoczności,
  liczone w pikselu świata (interpolacja wygładziłaby twarde krawędzie, stąd schodki 2 px przy ×2 obok ditheru 1 px).

**Dlaczego siatka na ulicy [Wn]:** szerokość pasa w pikselach = (`level_band` × krok) / (gradient EV na piksel).
Gradient jasności w nieboskłonie zasłanianym przez budynki jest rzędu kilku dziesiątych EV na kilkadziesiąt-sto metrów
pikseli (liczba ilustracyjna, nie mierzona), więc jeden krok 0,5 EV zajmuje ~100 px, a jego pas ditheru ~30 px, w którym
Bayer przechodzi przez wszystkie 16 wzorów, każdy po kilka px: to są „pola szachownicy”. We wnętrzu gradient przy
oknie/lampie jest ostry, pas ma 1–3 px i wygląda jak zamierzony półcień. **Wada nie leży w Bayerze ani w krokach, tylko w
tym, że szerokość szwu zależy od stromości gradientu.** Ten sam wniosek, w innych słowach, jest już w 82 (sekcja 3,
„pas stałej szerokości przez `fwidth(L)`”); tu został dopiero sprawdzony na ulicy.

Zrzut `style-lab/shots/t14/user/siatka.png` (obejrzany): pola siatki leżą na chodniku i jezdni pod fasadami (miękka
pomarańczowo-niebieska plama pod nawisem, szeroki pas wokół wejścia), a ostre cienie (lampy, słupy) są czyste. Siatka
dotyczy wyłącznie płytkich gradientów, jak w diagnozie.

## 2. Pytanie 1: czy gry pokazują miękkie zasłanianie nieba, i jak oddają pochmurny dzień

| Gra / źródło | Co ustalono | Ocena |
|---|---|---|
| Blessings of the Forge (Godot, pikselowy bufor światła 640×360) | Plener = tylko dwa stany piksela: słońce albo cień (równoległoboki rzutowane od krawędzi budynków), wnętrze = ciemny ambient; okno rzucone na ziemię + elipsa ambientu. Brak miękkiego zasłaniania nieba; „miękkie i twarde cienie, normalne” są na liście przyszłych prac. Brak kwantyzacji w poście. [devlog](https://darredevyll.itch.io/blessings-of-the-forge/devlog/1009729/update-on-shaders-and-lighting) | [P], autor; słaby jako wzór (hobbysta, wczesny stan) |
| Graveyard Keeper | Ambient = gradient po porze dnia (zmierzch: ciemniej i niebieściej), do tego ~10 LUT-ów na porę dnia; cień = obracany sprite, 1 od słońca + do 3 od lamp; deszcz/wiatr/mgła to osobne efekty (mgła z poziomych warstw chmur). Pochmurny dzień nie opisany. [blog dewelopera](https://slava.lazybeargames.com/graveyard-keeper-how-the-graphics-effects-are-made) | [P/S] autor, 2018; mocny dla „ambient + LUT”, brak o niebie |
| Kingdom | Dev: „wyciągnięte do minimum oświetlenie i render, bliżej piksela”, niska rozdzielczość pozwala na efekty w czasie rzeczywistym. Nic o cieniach i niebie. [80.lv](https://80.lv/articles/kingdom-developer-on-creating-pixel-environments/) | [S], słabe |
| Sea of Stars | Pełne dynamiczne światło własnym pipeline; jedna osoba przez 5 lat; „cały pipeline i assety muszą spełniać wymagania techniczne dynamicznego światła”. Brak opisu algorytmu (przeszukano wywiady). [MobileSyrup](https://mobilesyrup.com/2023/09/11/sea-of-stars-level-design-sabotage-studio-thierry-boulanger-interview/) | [S], wniosek tylko ogólny |
| Eastward | Własny silnik; światło, pogoda i pora dnia „shader textures and lighting systems”; brak szczegółów. Nie znaleziono GDC. [Game Developer](https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures) | [S] |
| Octopath / HD-2D | Światło nowoczesne (UE4), gładkie, nie kwantyzowane; prezentacja Unreal Fest Europe 2019 istnieje, treści slajdów nie odczytano. [UE](https://www.unrealengine.com/events/unreal-fest-europe-2019/the-fusion-of-nostalgia-and-novelty-in-the-development-of-octopath-traveler) | [S] i tak nie jest wzorem (patrz 82) |
| Hyper Light Drifter, The Last Night, Children of Morta, REPLACED | Brak opisu technicznego w odnalezionych źródłach (HLD: jedyny trop to wskazówka z forum Steam o warstwie światła; The Last Night: tylko stos narzędzi Unity). | brak źródła |
| Never's End (GDC 2026, Juckett) | Talk „How We Draw a 3D Sprite World”; slajdy tylko do pobrania, treści nie odczytano. [post](https://www.ryanjuckett.com/how-we-draw-a-3d-sprite-world-gdc2026/) | [P] istnienie talku; treść nieznana, **warto obejrzeć ręcznie** |
| Nectarmancer | Światła punktowe/kierunkowe w structured buffer, mapy krawędzi liczone w edytorze, nic o kwantyzacji ani niebie. [80.lv](https://80.lv/articles/how-pixel-art-lighting-was-set-up-in-seamless-world-of-nectarmancer) | [S] |

**Wnioski (fakty):** wszystkie przeczytane źródła przedstawiają plener jako **twarde cienie kierunkowe + ambient
(gradient/LUT po porze dnia)**; żadne nie opisuje miękkiego, zasłanianego nieba stylizowanego ditherem. Pochmurny dzień
nie jest nigdzie opisany jako osobny algorytm; Graveyard Keeper zmienia nastrój przez LUT/ambient, a mgłę robi osobną
warstwą.
**Wniosek własny [Wn]:** praktyka rynku (a raczej brak śladu czegoś innego) to „ambient płaski lub płynny, kolor przez
LUT/rampę, twarde cienie od słońca”. Pochmurny dzień = słońce wyłączone, zostaje ambient; w naszym modelu to znaczy, że całe
światło ulicy to niebo (cień nieba pod budynkami to jedyna struktura), a więc wyłącznie **płytkie gradienty**: najgorszy
przypadek dla wyglądu A. Pochmurny dzień trzeba traktować jako przypadek testowy numer jeden.

## 2b. Szersze tło: malowane 2D, stare gry, ilustracja i komiks, grafika techniczna

Zakres rozszerzony na prośbę człowieka (zmiana zakresu 2026-11-15): jak w ogóle stopniuje się cień i światło tam,
gdzie nie ma bufora światła. Źródeł pierwotnych jest mało; ocena przy każdym twierdzeniu.

| Obszar | Co ustalono | Ocena |
|---|---|---|
| Przygodówki LucasArts (Ferrari: Loom, Monkey Island, Thimbleweed Park) | Mark Ferrari ma talk GDC 2016 „8 Bit & '8 Bitish' Graphics-Outside the Box” o palecie i ditheringu przy 16 i 256 kolorach (treść: opis talku; materiał za logowaniem, nieczytany). Porównanie Loom EGA vs VGA: większa paleta daje „wyraźnie lepsze wyniki”; w VGA zdarzało się nadużycie gradientów. [GDC Vault](https://gdcvault.com/play/1023586/8-Bit-8-Bitish-Graphics), [Boing Boing](https://boingboing.net/2022/05/31/comparing-the-16-and-256-color-versions-of-the-classic-adventure-game-loom.html) | [S]; treść talku nieznana |
| Thimbleweed Park (Gilbert) | Silnik ma światła „overhead”, a „wiele efektów oświetlenia Mark (artysta) dodaje samą grafiką”. Czyli także w grze z dynamicznym światłem część światła jest malowana. [transkrypt podcastu #14](https://forums.thimbleweedpark.com/t/transcript-podcast-14/2308) | [S] (wypowiedź twórcy, bez szczegółów) |
| Sierra / EGA (16 kolorów) | Dithering był koniecznością ograniczonej palety; szachownica 2×2 to najprostszy, najczęściej używany wzór (zmieszczenie w małych obszarach); stopniowanie tonu = zmiana gęstości dwóch kolorów. Wpisy o proceduralnych tłach Sierry i sterownikach EGA to relacje z forów. [gametechwiki](https://emulation.gametechwiki.com/index.php/Dithering), [Vogons](https://www.vogons.org/viewtopic.php?p=830482), [pixnote](https://pixnote.net/en/learn/dithering) | [S]/forum; nic o Amidze nie znaleziono |
| Współczesne tutoriale pikselarzy | Najpierw jedno źródło światła i spójny kierunek; liczba tonów rośnie z rozmiarem płótna (2 dla 16×16, 3 dla 32×32, 4–5 od 64×64); dithering „rzadko potrzebny we współczesnych kontekstach”, nie dla animowanych sprite'ów, zalecany oszczędnie jako przejście; brak opisu szerokości pasa w px. [pixnote: shading](https://pixnote.net/en/learn/shading), [Pixel Parmesan](https://pixelparmesan.com/dithering-for-pixel-artists) | [S], poradniki; stąd zasady ogólne, nie liczby |
| Kentucky Route Zero, Blackwell | Nie znaleziono opisu techniki światła (KRZ: tylko wątki Polycount bez odpowiedzi autorów); Blackwell to malowane tła. | brak źródła |
| Cel shading (grafika 3D imitująca komiks) | „Gładkie wartości światła liczone per piksel są kwantyzowane do małej liczby płaskich odcieni”; liczby pasm nie podano. [Wikipedia](https://en.wikipedia.org/wiki/Cel_shading) | [S], definicja, nie źródło autorskie |
| Raster / screentone (manga, komiks) | Screentone to „technika nakładania faktur i odcieni”, alternatywa dla kreskowania, nakładany z arkuszy; strona nie opisuje stopniowania odcieni. [Wikipedia](https://en.wikipedia.org/wiki/Screentone) Zasada druku rastrowego (stały odstęp punktów na ekranie, ton przez wielkość/gęstość punktu) to wiedza ogólna. | [S] / [W] |
| Obra Dinn (Pope) | Dither „jak najmniej”; Bayer lepiej oddaje zakres tonalny, niebieski szum organiczniej; wzór związany z kamerą dla stabilności. [PlayStation Blog](https://blog.playstation.com/archive/2019/10/17/lucas-pope-on-return-of-the-obra-dinns-art-style) | [S] |
| Hobbyści Godot/Unity (t3ssel8r, forum Godot, godotshaders) | Wątki mówią o przyciąganiu cienia do siatki pikseli i „banded lighting”, bez treści algorytmów; David Holland opisuje 3D styl inspirowany t3ssel8r (konturami, nie światłem). [Holland](https://davidholland.netlify.app/articles/3d-pixel-art-rendering), [forum Godot](https://forum.godotengine.org/t/how-to-pixelate-lighting-shadows/132464) | [S], słabe |

**Odpowiedź na „na ile takie cienie są w grach pixel art”** (fakty + wniosek [Wn]): przeczytane źródła nie wskazują
żadnej gry, której pixel-artowe, liczone światło ma opisane miękkie cieniowanie z nieba; w grach malowanych, starych i w
komiksie światło/cień to **ręcznie stopniowane, kilka płaskich tonów, dither sporadycznie i w wąskich przejściach**,
twarde cienie rzucane tam, gdzie je widać (kierunek słońca), a miękkie, rozległe zasłonięcie nieba rysuje się jako
**kilka płaskich pasm** (rampa), nie jako dither po całym gradiencie. Z tego wynikają trzy zasady, każdą da się
zrealizować jednym algorytmem z bufora światła:
1. **Mało poziomów, płaskie pola.** Rozległy, płytki gradient = kilka płaskich pasm (tak w rampach pikselarzy, cel
   shadingu, komiksie). [Wn]
2. **Przejście między pasmami wąskie i stałej szerokości na ekranie**, niezależnie od tego, jak stromy jest gradient
   (ta sama zasada co stały odstęp punktów rastra i stały rozmiar kropek Dither3D). [Wn; wsparcie: Dither3D [P] dla stałego
   rozmiaru na ekranie, poradniki [S] dla „dither oszczędnie”]
3. **Jeden kierunek światła i spójne wzory dithera na całym obrazie** (poradniki, Pope). Bayer zakotwiczony w pikselu
   ekranu (u nas jest). [S]

## 3. Pytanie 2: dither, posteryzacja, wzory

**Fakty:**
- Dither uporządkowany = progi z gotowej macierzy, deterministyczny, równoległy per piksel; Bayer „bardziej
  strukturalny”, niebieski szum „równy, bez widocznych wzorów”; progować w przestrzeni liniowej. [P] [Surma](https://surma.dev/things/ditherpunk/)
- Pope (Obra Dinn): dither używa „jak najmniej”; Bayer lepiej oddaje zakres tonalny, niebieski szum wygląda organiczniej;
  przy większej rozdzielczości (640×360 → 800×450) i nowym ditherze oko lepiej łączy wzór w szarość; flicker ograniczył
  przez związanie dithera z kamerą 3D. [S] [PlayStation Blog](https://blog.playstation.com/archive/2019/10/17/lucas-pope-on-return-of-the-obra-dinn-art-style)
  (pierwotny wątek TIGSource nieczytelny; mapowanie na sferę i podział Bayer/blue noise to relacje wtórne, [S]).
- Dither3D (Rune Skovbo Johansen): kropki „przyklejone” do powierzchni, a rozmiar i odstęp kropek **w przestrzeni
  ekranu zostają w przybliżeniu stałe** przez dodawanie/usuwanie kropek przy zmianie skali; wymaga pochodnych UV
  (`ddx`/`ddy`) i tekstury 3D; Bayer jest samopodobny (fraktalny), niebieski szum nie. [P] [README](https://github.com/runevision/Dither3D)
  Koszt na GPU: jeden odczyt 3D + kilkadziesiąt operacji na piksel; port CPU na Playdate: od 830 do 45 ms/klatkę po
  serii uproszczeń. [P] [Aras P.](https://aras-p.info/blog/2025/02/09/Surface-Stable-Fractal-Dither-on-Playdate/)
- Posteryzacja światła liczona per fragment daje „postrzępione plamy łamiące siatkę pikseli”; rozwiązanie: przyciągnąć
  pozycję do środka teksela. [S] [wątek Unity](https://discussions.unity.com/t/the-quest-for-efficient-per-texel-lighting/700574)
  (u nas odpowiednik: `light_px_mid` i Bayer w pikselu widoku).

**Czego nie znaleziono:** gotowej, opisanej techniki „szew ditheru stałej szerokości w px przy granicy poziomu” jako
elementu gry. Dither3D rozwiązuje inny problem (stała gęstość kropek na powierzchni w ruchu), ale **ten sam pomysł
logiczny** (rozmiar wzoru ma być stały na ekranie, a nie zależeć od wejścia) dotyczy nas.

**Wnioski własne [Wn]** (kolejne warianty, każdy do sprawdzenia w Poligonie):
1. **Pas stały w px (A′).** Zamiast `t = (f − (1 − band)) / band`: `t = clamp(1 + (f − 1) / min(w_px · g, 1), 0, 1)`, gdzie
   `f` = ułamek kroku (`e − floor(e)`), `g` = |∇e| w krokach na piksel ekranu (różnice skończone na `light_map_smooth`,
   ±1–2 px, 4 odczyty), `w_px` = 2–3 px. `min(…, 1)` to jedyne ograniczenie i jest bez gałęzi: na stromym gradiencie
   (krok węższy niż `w_px`) pas obejmuje cały krok (zwykły dither między poziomami), na płytkim dostajemy
   **płaskie pole ze szwem `w_px`** (rampa pikselarza). Ta sama formuła, te same stałe, wnętrze i ulica (tylko wnętrze
   zmieni się nieco względem dzisiejszego pasa 30% kroku, do porównania).
   Ryzyko: długie izolinie „schodkowe” (aliasing na ukośnych szwach).
2. **Posteryzacja bez ditheru (A′ przy `w_px` = 0)** [Wn]: twarda granica poziomu wszędzie. Ten sam kod, jedna wartość
   pokrętła; najczystszy wygląd cel shadingu/komiksu, ryzyko „mapy warstwicowej” na płytkim gradiencie i ostrych
   schodków izolinii (bez szwu nic nie maskuje schodka). Mianownik `max(W, 1e-4)`.
3. **Rozdzielenie nieba i kierunkowych (kandydaci B/D/E z 82) nie jest rekomendowane [Wn]:** wymaga osobnego kanału i
   osobnej ścieżki dla źródeł, co koliduje z wymaganiem jednej stylizacji bez specjalnej obsługi i powtarza błąd z
   ticketów 36/37 (progi per źródło). Zachowane tylko jako odniesienie.
4. **Niebieski szum / linie:** brak źródła, że któryś z nich lepiej wygląda przy niskich poziomach dla płytkich
   gradientów; Surma i Pope mówią tylko, że niebieski szum jest „organiczny”, a Bayer „strukturalny”. Dla pixel artu
   (spójność z ditherem reszty gry) **zostać przy Bayer 4×4** [Wn]; niebieski szum odpada, bo gra używa Bayera i nie ma
   dowodu na zysk. Blue noise nie jest samopodobny (README Dither3D), więc nie nadaje się też do wariantu fraktalnego.

## 4. Pytanie 3: rozdzielczość bufora względem widoku

**Fakty z kodu/ticketów:** bufor stoi w pikselu świata; A liczony w pikselu widoku z bilinearnej interpolacji; bufor ×k
zabijał wydajność (ticket 37, pomiar człowieka); pełne przeliczenie bufora ulicy ok. 36 ms rozłożone na 16 klatek,
w ruchu 130–213 kl./s (ticket 14).
**Fakty ze źródeł:** Blessings of the Forge celowo liczy światło w rozdzielczości gry (640×360) jako tekstura-nakładka,
żeby samo światło było pikselowe [P]; Children of Morta robi odwrotnie, światło w HD (82, [S]).
**Wnioski własne [Wn]:**
- Dla **płytkich** gradientów (niebo) rozdzielczość bufora nie ma znaczenia; liczy się szerokość szwu w px (wariant 1).
  Bufor ×2 tu nie pomoże i kosztowałby czterokrotnie.
- Dla **ostrych** krawędzi (cień słońca) potrzebna jest rekonstrukcja z zachowaniem krawędzi bez drugiego, gęstszego
  bufora: to, co robi A (próg na bilinearnej interpolacji), jest wersją techniki „alpha-tested magnification” (Valve:
  wartość zapisana w niskiej rozdzielczości, rekonstruowana bilinearnie i progowana, daje ostrą krawędź w pozycji
  subtekselowej; pierwotnie dla pola odległości, nie dla widoczności) [P, tylko co do istnienia metody, nie czytano
  pełnego PDF] [Green 2007](https://www.advances.realtimerendering.com/s2007/Green-Improved_Alpha-Tested_Magnification_for_Vector_Textures_and_Special_Effects(Siggraph07).pdf).
  Czyli: **cały próg i dither w pikselu widoku z interpolowanego bufora** (tak jak dziś robi A), także dla ostrych
  cieni słońca: osobny próg widoczności klucza w pikselu świata (B, schodki 2 px obok ditheru 1 px) odpada, bo
  wymaga drugiej ścieżki. Zastrzeżenie: interpolacja rozmywa krawędź na 1 texel; próg daje poprawną pozycję krawędzi, ale
  wąskie przeszkody (słup, 1–2 texele) mogą się wyciąć. Do sprawdzenia na słupach lamp (cień słupa na ulicy).
- **Upsampling z zachowaniem krawędzi** w sensie edge-aware (bilateralny) nie ma tu źródeł z gier i jest przesadą; progowanie
  interpolowanej widoczności załatwia ten sam problem taniej [Wn].

## 5. Pytanie 4: jeden algorytm dla wnętrza i pleneru

**Rozstrzygnięte przez człowieka (2026-11-15): TAK, jedna stylizacja, jeden silnik, bez gałęzi i bez osobnych parametrów
wnętrze/ulica.** Research sprawdził, czy da się to spełnić.
**Fakty:** Graveyard Keeper, Blessings of the Forge i Kingdom opisują jeden pipeline wnętrze+plener z różnymi **danymi**
(ambient, LUT, kolor), nie z różnymi algorytmami [P/S]. U nas ticket 14 już przeniósł wspólne `light_common`.
**Wniosek własny [Wn]:** wymaganie da się spełnić **przez konstrukcję**, jeśli jedyną stałą wyglądu jest wielkość w
pikselach ekranu (szew `w_px`) i jedna skala jasności (`level_stops`), a wszystko zależne od sceny (stromość gradientu)
wynika z danych: formuła z sekcji 3, punkt 1, sama daje stromy pas ≤ krok we wnętrzu i płaskie pole + szew 2–3 px na
ulicy. Brak `if` na typ sceny, brak `g_min`, brak osobnych `level_stops`. Cena: wnętrze zmieni się nieco względem dzisiejszego
A (pas 30% kroku → szew `w_px`), więc wartości `level_stops` i `w_px` trzeba stroić **raz**, razem dla Domu i Ulicy
(zgodnie z ticketem 38).
Zastrzeżenie [Wn]: jeden `level_stops` musi dobrze wyglądać i w ciemnym wnętrzu (duży zakres EV na metr), i w jasnej ulicy
(mały zakres); jeśli nie da się znaleźć wartości dobrej dla obu, to jest to wynik badania do zgłoszenia człowiekowi
(a nie powód do wprowadzenia drugiego parametru po cichu).

**Doprecyzowanie człowieka (2026-11-15, później):** w ostateczności algorytm może mieć **dwa warianty, wnętrze i plener**
(osobne zestawy stałych `level_stops`, `w_px`), ale **w obrębie wariantu żadnych `if` na rodzaj światła ani na
pojedyncze przypadki**. Wniosek [Wn]: kolejność prób to (1) jeden zestaw stałych dla obu, (2) dopiero gdy sekcja 5 pokaże, że
jeden `level_stops` nie służy obu scenom, dwa zestawy stałych wybierane **per Poligon (dane sceny, nie gałąź w kodzie)**, ten
sam kod. Rekomendowane warianty z sekcji 6 pozostają bez zmian.

## 6. Rekomendacja do prototypu (Poligon Ulica, sprawdzenie w Domu)

Oba warianty to **ten sam kod** (jedna funkcja poziomów w `light_common` / `lit.gdshader`), różni je jedno pokrętło;
oba wspólne dla wnętrza i ulicy.

### Wariant 1 (zalecany): A′ ze szwem stałej szerokości `w_px` = 2–3
- Zmiana: `view_level` (lit.gdshader) i `light_levels` (light_common) liczą `g` z `light_map_smooth` (4 odczyty) i
  `t` z formuły w sekcji 3; pokrętło `poziom_pas_px` zastępuje `poziom_pas` (część kroku). `light_res` bez zmian.
  Wszystko w pikselu widoku; B (osobna ścieżka klucza w pikselu świata) nie używane.
- Koszt pracy: **3–5 h** (implementacja ~1,5 h; ukośne izolinie, stabilność w ruchu postaci i szwy na krawędziach
  powierzchni ~1–2 h; porównanie i wspólne strojenie Dom/Ulica ~1 h).
- Wpływ na wydajność: tylko shader sprite'ów; 4 odczyty tekstury i kilka operacji na piksel widoku; bufor i `street_fn`
  bez zmian. Oczekiwane: mały spadek kl./s (rząd kilku %), **niezmierzone**, do `--bench`.

### Wariant 2 (do porównania, ten sam kod): posteryzacja bez ditheru, `w_px` = 0
- Zmiana: wartość pokrętła; ewentualnie szew 1 px zamiast 0 do wygładzenia schodków.
- Koszt pracy: **≈ 0,5 h** po wariancie 1; wydajność jak wariant 1 (mniej operacji, bez Bayera).
- Po co: odpowiedź na pytanie człowieka, ile ditheru w ogóle chcemy (poradniki [S] i Pope: „jak najmniej”).

Nie rekomendowane: rozdzielenie nieba i światła kierunkowego na osobne kanały/ścieżki (82: B+D+E) i osobny próg klucza
w pikselu świata (stylizacja B): koliduje z wymaganiem jednej stylizacji, wymaga zmiany bufora (6–10 h) i powtarza
problem progów per źródło (tickety 36/37). Bufor ×2 tylko na ulicy: odpada (płytkich gradientów nie poprawia, zasada
„wspólny kod” i wydajność).

### Kryteria oceny (żywo w Poligonie, nie na zrzutach)
- Pochmurny dzień (tylko niebo): brak pól szachownicy; poziomy z szwem ≤ 3 px (przypadek testowy numer jeden).
- Słońce między domami: ostre długie cienie bez schodków 2 px obok ditheru 1 px.
- Dom: okno/lampa wyglądają dobrze (zmiana względem dzisiejszego A jest oczekiwana; porównać z gałęzią `t37-stylizacja`).
- W ruchu: bez migotania szwów (Bayer zakotwiczony w pikselu widoku, jak dziś).

## 7. Najsłabsze miejsca źródeł (do zapamiętania)
- Brak przeczytanego opisu algorytmu dla jakiejkolwiek gry z listy w plenerze; tabele w sekcjach 2 i 2b to w większości
  „nie opisano” lub źródła wtórne (poradniki, fora, Wikipedia).
- Rozdział o Sierrze/EGA opiera się na forach i wiki; o Amidze nic nie znaleziono; talk Ferrariego (GDC 2016), slajdy
  Never's End (GDC 2026) i wątek TIGSource Pope'a były nieczytelne.
- Dither3D i Aras P. są pierwotne, ale dotyczą 3D z pochodnymi UV: przenosimy **ideę** (stały rozmiar wzoru na ekranie), nie kod.
- Valve (Green 2007): wskazano tylko metodę, pełnego PDF nie czytano, dotyczy pola odległości.
- Zasada „kilka płaskich tonów, wąskie przejścia” to nasz wniosek z poradników [S], cel shadingu i rastra [W]; żadne źródło
  nie podaje szerokości szwu w px.
- Szacunki kosztu godzinowego i wydajnościowego są naszymi ocenami, niezmierzone; liczby gradientu w sekcji 1 są ilustracyjne.
- Warto obejrzeć ręcznie (wideo): Never's End (GDC 2026), Ferrari (GDC 2016), t3ssel8r, Aarthificial, TIGSource Obra Dinn.
