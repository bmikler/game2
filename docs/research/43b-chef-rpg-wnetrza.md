> Kopia z game1 (`repo/game1/docs/research/43b-chef-rpg-wnetrza.md`, stan 2026-11-03). Ścieżki i numery notatek odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Wnioski dla game2 są w `docs/grafika.md`.

# Wnętrza Chef RPG: ściany, wnęki i pokoje różnej głębokości

Dodatek do `43-sciany-wnetrz-3-4.md` (wzorzec A: każda podłoga ma pełne lico ściany tylnej, boki i przody tylko jako ciemny wierzch, drzwi jako otwór w licu). Data researchu: **2026-10-29**. Research jest celowo krótki, ok. 20 wywołań narzędzi.

**Pytanie:** jak Chef RPG (World 2 Studio, Steam Early Access od 12.09.2024, appid 1796790) rysuje wnętrza z kilkoma pokojami i co sprawia, że układ nie jest „rzędem pudełek”.

**Źródła.** Twórcy nie opisują ścian w devlogach. Źródłem pierwotnym są więc:
- 9 oficjalnych zrzutów ze strony sklepu (API `store.steampowered.com/api/appdetails?appids=1796790`), z czego wnętrza pokazują tylko dwa,
- obrazy i teksty z ogłoszeń Steam (API `ISteamNews/GetNewsForApp`, 46 wpisów od 06.2024 do 09.2026), z których trzy obrazy pokazują wnętrza.

Trailera nie oglądałem. Oznaczenia jak w 43: **[zrzut]**, **[źródło]** (tekst od twórcy), **[wiedza ogólna]** (z pamięci, niesprawdzone), **[wniosek]**.

## Streszczenie

- **Chef RPG stosuje ten sam wzorzec A co my.** Wysokie lico ma tylko ściana tylna. Ściany boczne i dolna to ciemny pas wierzchu (grafit/fiolet, ok. 0,5–1 kafla), a za nim czarna pustka [zrzut 1, 2, 3]. Ściana dolna nie ma w ogóle lica. Podłoga przy dolnej krawędzi ciemnieje winietą i przechodzi w czerń [zrzut 1].
- **Najważniejsza sztuczka to ściana tylna „łamana” w głąb.** Ściana tylna nie jest jedną prostą. Składa się z kilku odcinków na różnych wysokościach ekranu i każdy ma pełne lico. Między odcinkami stoją krótkie ukośne fazy (45°) albo pionowe uskoki. Daje to wnęki, wykusze i węższe strefy [zrzut 1, 2].
- **Pokoje różnej głębokości stoją obok siebie** i łączą się szerokim otworem, nie drzwiami. Płytszy pokój kończy się u dołu ciemnym wierzchem, a głębszy ciągnie się niżej. Granica między nimi to krótki słupek ściany (koniec ściany działowej) przy górze [zrzut 3].
- **W dużej sali strefy wyznacza się meblami, nie ścianami:** ladą, rzędem donic z żywopłotem, ławami boksów. Kuchnię od sali oddziela wąska lada-wyspa [zrzut 1, 4].
- **Na licu ściany tylnej dzieje się dużo:** okna z widokiem na zewnątrz, schody rysowane po ścianie, kominek, regał wbudowany w ścianę, małe drzwi w licu do sąsiedniego pomieszczenia [zrzut 2, 3].
- **Mechanika ścian:** gra ma „tall walls & black ceilings”, które pokazują się i chowają zależnie od sytuacji. Ma też „hidden wall colliders” i drzwi przesuwne [źródło: Patch #14, Patch #3]. Gracz może zmienić styl ścian we wnętrzach [źródło: Tidehaven]. Jest to więc system kafelkowy z wymiennym licem, a nie ręcznie malowane tła [wniosek].

## 1. Co widać na zrzutach

**Zrzut 1. Le Sequoia, zaniedbana restauracja** ([ss_828718…](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_82871847df216baa534b10b5777cb4606a731d57.1920x1080.jpg)) [zrzut]
- Ściana tylna ma trzy poziomy. Lewy odcinek (kuchnia z lodówką i regałem) jest **niżej na ekranie**, czyli płytszy. Środek z trzema łukowymi oknami jest najwyżej, czyli najgłębszy. Prawy odcinek z jednym oknem znów jest niżej.
- Lewy i prawy odcinek łączą się ze środkiem **ukośnymi fazami lica** (ok. 45°), nie pionowym uskokiem. Ciemny obrys wierzchu na górze też ma ścięte narożniki. Pokój czyta się przez to jak sala z wykuszem, a nie prostokąt.
- Ściany boczne to tylko ciemny pas. Ściany dolnej nie widać, a podłoga ciemnieje winietą.
- Kuchnię (lewy odcinek) od sali oddziela tylko wolnostojąca lada, bez ściany.

**Zrzut 2. Wnętrze ze zmianą stylu ściany na tatami** (ogłoszenie Tidehaven, [obraz](https://clan.akamai.steamstatic.com/images/41514609/5b2503a8388d630423378fd24fc9de7cc8079d8a.png)) [zrzut]
- Środkowy odcinek ściany tylnej jest cofnięty, czyli jego wierzch leży wyżej o ok. 0,5 kafla. Tworzy płytką wnękę z ławą i dwoma oknami. Boczne odcinki stoją bliżej. Uskoki są pionowe i mają ciemny obrys.
- Wszystkie odcinki mają pełne lico tej samej wysokości. Zmienia się tylko położenie w pionie. To dokładnie nasza reguła „lico tam, gdzie zaczyna się podłoga”.
- Ciemny obrys wierzchu ściany obiega całość także po bokach, a podłoga przy krawędziach ma winietę.

**Zrzut 3. Powiększony dom gracza** (ogłoszenie Flavors, [obraz](https://clan.akamai.steamstatic.com/images/41514609/c78f1b9934bc4a54513f7d6e105e78603a428d77.jpg)) [zrzut]
- Po lewej jest pokój z drewnianą podłogą. Na licu ściany tylnej widać schody biegnące ukośnie w górę, regał wbudowany pod schodami i kominek. Po prawej jest pracownia z podłogą w szachownicę.
- Pokoje łączy **szeroki otwór**. Przy górze stoi tylko krótki słupek, czyli koniec ściany działowej (jasne lico i wierzch).
- **Pracownia jest płytsza:** kończy się ciemnym pasem wierzchu, pod którym jest czerń, a pokój drewniany ciągnie się niżej. Na styku widać ciemny „schodek” wierzchu w kształcie litery L. Plan ma więc kształt L bez żadnej specjalnej grafiki.
- Zmiana materiału podłogi (deski i szachownica) sama oznacza granicę pomieszczeń.
- W licu pracowni, w prawym górnym rogu, są małe drzwi do kolejnego pomieszczenia.

**Zrzut 4. Restauracja w pełni** ([ss_0e8f5c…](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1796790/ss_0e8f5c414197a2631fc57af714d9d1758120eefb.1920x1080.jpg)) [zrzut]
- Jedna duża podłoga podzielona na strefy: kuchnia przy lewej ścianie, pas donic z kwiatami, korytarz obsługi, a dalej boksy z siedziskami otoczone żywopłotem. Ścian działowych nie ma.
- Lewa krawędź to czarna pustka i ciemny wierzch. Kamera pokazuje tę krawędź tylko w zbliżeniu.

**Pozostałe zrzuty** to sceny zewnętrzne. Wejścia są tam ważne: drzwi w licu fasady, ganek, schody [zrzut 0, 6, 7]. Wnętrz nie pokazują.

## 2. Z ogłoszeń twórców [źródło]

- Patch #14 (24.12.2024): „Fixed tall walls & black ceilings sometimes appearing or disappearing at the incorrect time”. Wysokie ściany i czarne „sufity” są więc chowane i pokazywane dynamicznie. Zapewne chodzi o lico, które zasłania gracza, albo o pokoje poza zasięgiem gracza zakryte czernią [wniosek, mechanizmu nie widziałem]. [ogłoszenie](https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1786573930770349)
- Patch #3 (14.09.2024): „Improved door & hidden wall colliders… back side of sliding doors… ‘invisible’ door”. Są ukryte ściany i drzwi przesuwne. [ogłoszenie](https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/6250522009519975163)
- Patch #22 (03.2026): „furniture items rendering behind walls when in build mode”. Meble są sortowane względem ścian. [ogłoszenie](https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1826362059925978)
- Tidehaven (21.08.2026): style ścian do wyboru (Red Brick, Red Wood, Tatami, Yellow, Modern, Cyberpunk) i trzy nowe podłogi. Lico jest więc wymiennym zasobem, a nie częścią tła. [ogłoszenie](https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1841579228669460)
- Flavors (28.02.2026): większy dom gracza, a do tego klapa w podłodze (trapdoor) do Maintenance Room. Sąsiednie piętro jest więc osobną sceną, do której wchodzi się przez obiekt w podłodze. [ogłoszenie](https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1825727806713758)
- Version 0.62: meble sterują światłem pokoju („overhead lights always on” albo dekoracyjne) [źródło]. Uwaga poboczna, pasuje do naszego ADR 0007.

## 3. Krótkie porównanie

- **Stardew Valley, rozbudowy domu** [wiedza ogólna]: każda rozbudowa dokłada pokój za otworem w ścianie bocznej albo tylnej. Sypialnia i pokój dziecięcy mają ściany tylne na innych wysokościach niż kuchnia, więc dom ma kształt L i schodków. Community Center to sala centralna z promieniście ułożonymi salkami o różnej głębokości (potwierdzone na zrzucie w 43).
- **Graveyard Keeper, tawerna i kostnica** [zrzut w 43]: wiele poziomów ściany tylnej w jednym kadrze, a pokoje dolne mają lico pod wierzchem pokoju górnego. Chef RPG różni się tym, że rzadziej stawia pokoje jeden nad drugim. Woli pokoje **obok siebie, różnej głębokości**, i łamaną ścianę tylną.

## 4. Czego nie sprawdziłem

- Nie oglądałem trailera ani nagrań gry, więc nie wiem, jak wygląda przejście przez drzwi między pomieszczeniami (cięcie, przewijanie kamery) ani chowanie „tall walls”.
- Nie widziałem pokoju postawionego bezpośrednio pod innym pokojem. Wniosek „Chef RPG unika piętrowania pokojów w pionie” opiera się na pięciu obrazach.

## 5. Techniki do użycia (posterunek i kolejne wnętrza)

1. **Łamana ściana tylna w jednym pokoju.** Sala główna dostaje 2–3 odcinki ściany tylnej przesunięte w pionie o 0,5–1,5 m. Głębszy odcinek to wnęka: ławka dla petentów, tablica ogłoszeń, okno. W kodzie to kilka odcinków lica z różnym `y`, a reguła wzorca A się nie zmienia.
2. **Ukośne fazy lica (45°) na styku odcinków** zamiast pionowego uskoku. Wystarczy jeden kafel „lico ukośne lewe/prawe” i jeden kafel narożnika wierzchu. Pokój przestaje wyglądać na prostokąt. Na posterunku sprawdzi się przy dyżurce.
3. **Pokoje różnej głębokości obok siebie, połączone szerokim otworem.** Np. pokój socjalny jest płytszy niż sala główna i kończy się ciemnym wierzchem, a sala ciągnie się niżej do wyjścia. Kształt L powstaje za darmo z wierzchu i czerni.
4. **Słupek, czyli koniec ściany działowej, zamiast pełnej ściany z drzwiami.** Tam, gdzie pokoje mają być razem (hol i dyżurka), wystarczy krótki odcinek lica i wierzchu przy górze. Zmiana podłogi dopowiada resztę.
5. **Zmiana materiału podłogi jako granica.** Sala: lastryko, gabinet: deski, cela: beton, socjalny: linoleum. Taniej niż ściana i dobrze się czyta.
6. **Strefy meblami w dużej sali.** Lada dyżurnego z bramką, rząd krzeseł, barierka albo donice dzielą hol na strefę petenta i strefę służbową bez nowej ściany.
7. **Lico jako miejsce na treść:** okna (światło według ADR 0007), drzwi do sąsiedniego pomieszczenia, schody narysowane na ścianie (wejście na piętro albo do piwnicy jako przejście sceny), wbudowane szafki, a w celi krata zamiast lica.
8. **Winieta i czerń poza obrysem.** Podłoga ciemnieje przy krawędziach bez lica, a poza budynkiem jest czerń. Dolna krawędź nie potrzebuje ściany, wystarczy wyjście jako „języczek” podłogi (patrz 43).
