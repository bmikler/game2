# Okna w ścianach bocznych i dolnych (do kamery) w widoku 3/4: techniki i zestawy

Data: **2026-11-03**. Pytanie człowieka: „czyli na ścianie dolnej i bocznych mamy po prostu ścianę, z której wychodzi światło jak z okna?”. Notatka nie powtarza ustaleń z `43` §5, `35b` i `47` (kto nie rysuje okien, przepis na pas szkła 8/10/12 px, geometria smug). Dokłada: szerszy przegląd gier i paczek, katalog technik, rekomendację zestawów dla game2.

Oznaczenia (jak w `51`):
- **[zweryfikowane]**: widziałem sam obraz (zrzut ze Steam API, plik z repo) albo przeczytałem tekst twórcy. Dla zrzutów podaję, co faktycznie było widać.
- **[wtórne]**: streszczenie strony przez narzędzie albo wynik wyszukiwarki, bez lektury całości.
- **[niezweryfikowane]**: pamięć lub wiedza ogólna, dziś niesprawdzona.
- **[wniosek]**: moje rozumowanie albo propozycja.

## TL;DR

1. **Odpowiedź: tak, to jest „ściana ze światłem”, ale samo światło nie wystarcza, żeby gracz zrozumiał „okno”.** Nie znalazłem ani jednej gry w widoku 3/4 z wierzchem zamiast ścian bocznych i dolnej, która rysuje szkło w tym wierzchu. Wszystkie albo pomijają okno, albo mają dla niego lico (Moonlighter), albo w ogóle usuwają ścianę (Unpacking, Zomboid, Sims) [zweryfikowane tam, gdzie widziałem zrzut; reszta niżej]. Więc „okno” trzeba złożyć z kilku słabych sygnałów, a nie z jednego sprite'a.
2. **Cztery sygnały, które razem czytają się jako okno [wniosek]:**
   1. **Kształt światła:** plama na podłodze ma **cień ościeżnicy i szprosów** (krata 2×2 albo 2×3), a nie gładki klin. To najtańszy i najmocniejszy sygnał. Lampa nie ma kraty.
   2. **Ślad otworu na wierzchu ściany:** przerwa w rytmie wierzchu, **parapet wystający 1–2 px na podłogę**, ciemne słupki ościeża i najwyżej jedna cienka jasna linia szkła (15–20% grubości wierzchu, nie panel). Bez „szyby z ukośnymi błyskami”.
   3. **Rekwizyty, które „wiedzą”, że tam jest okno:** pionowy pas zasłony przy ścianie, kaloryfer pod oknem, doniczka albo gwiazda adwentowa na parapecie, szron i śnieg na zewnętrznym parapecie (1 px).
   4. **Spójność z zewnątrzem:** ten sam okienny rekord (ściana, pozycja, szerokość) rysuje świecące okno na fasadzie i poświatę na śniegu na zewnątrz. Gracz widział to okno z ulicy, więc wie, że jest w środku [zweryfikowane: Zomboid, Eastward, Sun Haven, widoczne na zrzutach].
3. **Ściana dolna jest trudniejsza niż boczne.** Kamera widzi tam zewnętrzną stronę ściany, więc wnętrze okna jest „za plecami” obrazu. Światło idzie w górę ekranu, sygnałem jest parapet od strony pokoju i rekwizyty. W konwencji projektu (`47` §4.3) okna dolne to strona północna, czyli tylko zimne światło nieba, bez słońca. To akurat ułatwia: jedna chłodna plama z kratą, bez smugi w powietrzu.
4. **Rekomendacja:** trzy standardowe zestawy (§6): **S0 „światło z kratą”** (domyślny, zero szkła), **S1 „szczelina”** (S0 + cienka linia szkła i parapet) i **K „okno bohater”** (lokalnie krótkie lico à la Moonlighter, tylko 2–3 miejsca w grze). Do tego wspólne dodatki: zasłona, kaloryfer, szron, śnieg na parapecie, wariant dzień/noc. Dziurę w tym przeglądzie (brak dowodu na S1 w 3/4) zamykamy testem czytelności na arkuszu (§7), nie kolejną teorią.
5. **Czego nie wiem:** nie znalazłem źródła pierwotnego, które pokazuje okno boczne w wierzchu ściany w grze 3/4 (poza top-down: DK2, Hotline Miami, Police Stories z `35b`). Gobo kraty okna jako technika jest dobrze znane z filmu i gier 3D, ale **nie potwierdziłem go w żadnej grze pixel art 3/4** (§2, T2).

## 1. Co faktycznie obejrzałem (nowe względem 43 i 35b)

Pobrałem oficjalne zrzuty ze Steam (`store.steampowered.com/api/appdetails`, 1920×1080) dla: Eastward, Sea of Stars, Chained Echoes, CrossCode, Hyper Light Drifter, Unpacking, SIGNALIS, Fields of Mistria, Sun Haven, Cassette Beasts, OMORI, Disco Elysium, Project Zomboid, RimWorld, Prison Architect, LISA, Kentucky Route Zero, Graveyard Keeper, Coral Island, Stardew Valley, Cult of the Lamb. **Obejrzałem planszami 3×2 (miniatury 640×360, więc drobny detal mógł mi umknąć):** Eastward (11), Fields of Mistria (12), SIGNALIS (6), Unpacking (6), Sun Haven (6), Cassette Beasts (6), Project Zomboid (6), Disco Elysium (6), OMORI (6), Sea of Stars (6), Chained Echoes (6), Coral Island (6). **Pobrane, ale nieobejrzane:** CrossCode, Hyper Light Drifter, KRZ, LISA, Prison Architect, RimWorld, Cult of the Lamb, Graveyard Keeper, Stardew (te dwie są w `43`, a PA i RimWorld w `35b`).

| Gra | Co widziałem na zrzutach | Wniosek dla okien bocznych i dolnych |
|---|---|---|
| **Unpacking** | Izometryczny przekrój pokoju: dwie tylne ściany pełne, **obie z oknami** (rama, ceglany widok za szybą, przez szybę ukośne smugi światła, zasłony i rolety z boku okna). Dwie ściany od kamery usunięte. | Okno czyta się tak mocno, bo ma **ceglany widok, zasłonę i smugę na szkle**. Wszystkie okna są na ścianach stojących tyłem do kamery. Pokazuje trzy rekwizyty okna (zasłona, roleta, widok), nie rozwiązuje ściany dolnej. [zweryfikowane] |
| **Project Zomboid** | Nocny zrzut osiedla w śniegu: **okna domów świecą ciepło i zimno (niebieski, pomarańczowy, fiolet), na śniegu leżą poświaty od wnętrza**. Zrzut wnętrza: pokój z wycięciem (widać tylko dwie ściany, reszta znika). | Okno „na zewnątrz” czyta się przez poświatę na śniegu. Wnętrze: cutaway usuwa ścianę od kamery, nie rysuje w niej okna. [zweryfikowane na zrzucie; mechanizm cutaway: [wtórne] z blogu PZ] |
| **Eastward** | 11 zrzutów: wszystkie wnętrza bez okien w bocznych ścianach; nocny zrzut z przyczepami, **jasno świecące żółte okna na fasadach i latarnia z ciepłą poświatą**; przeważnie exterior. | Pokazuje świecące okna na elewacji, nie okna w wierzchu ściany bocznej. [zweryfikowane] |
| **Fields of Mistria** | Zrzut wnętrza w tle dialogu: dom z kominkiem, **dwa okna z szprosami na ścianie tylnej**, ściana przednia i boczne nie istnieją (czarne tło). Zimowa wioska: **domy z zaśnieżonymi dachami i oknami na fasadach**. | Wnętrza jak Stardew: okna tylko z tyłu. [zweryfikowane] |
| **Sun Haven** | Śnieżna wioska: fasady z oknami, dachy ze śniegiem; brak wnętrz. | Tylko elewacja. [zweryfikowane] |
| **SIGNALIS** | Top-down ciemny statek: stożki światła od lamp i latarki, **pasy ostrzegawcze zamiast okien**; okno tylko w widoku z kokpitu (pierwsza osoba, oszronione szyby). | Nastrój przez kontrast i stożki światła, nie przez okna. Nic o oknach w ścianach. [zweryfikowane] |
| **Disco Elysium** | 6 zrzutów to głównie UI i plenery; brak wnętrza z oknem w widoku. | Blog (niżej) opisuje technikę światła przy oknie. [zweryfikowane] |
| **Chained Echoes** | Karczma z góry: widać wierzch ścian, **żadnych okien w bocznych wierzchach**. | Konwencja jak w `43`. [zweryfikowane] |
| **Cassette Beasts, OMORI, Sea of Stars, Coral Island** | Brak wnętrz z oknami w ścianach bocznych/dolnych na obejrzanych zrzutach. | Nic do dodania. [zweryfikowane, w skali miniatur] |

**Tekst twórcy, który się liczy:** devblog Disco Elysium „Shedding light”: scena nie używa świateł silnika; światło liczone jest z renderu neutralnego z paintoverem, mnożnika jasności, **mapy kierunku światła (RGB) i ręcznej „lightfield” map „the direction and magnitude of a single ray of light in each point”**. Niskie wartości alfa przy oknach dają „strongly directional light with stronger shades/shadows”, wyższe światło rozproszone. Autor zaznacza ograniczenie: technika wymaga, by światło było „very low frequency and similar on and behind the objects and characters” [zweryfikowane, [discoelysium.com](https://discoelysium.com/devblog/2016/02/02/shedding-light)]. Dla nas: **kierunkowość światła przy oknie jest ręcznie sterowana i słabnie z odległością, co nasze 2D `PointLight2D` z normal mapami umie dobrze imitować.**

**Eastward (Gamedeveloper, wywiad z Pixpil):** ściany i dachy w osobnych warstwach, ręcznie malowane bump mapy „for correct lighting performance”, w kamerze „fixed perspective … big asset and a challenge”, układ tak, żeby gracz nie był schowany za otoczeniem, „sunlight beams breaking through the landscape during dawn and dusk” [wtórne, streszczenie przez narzędzie, [gamedeveloper.com](https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures)]. Nie wspomina o oknach ani wnętrzach.

**Paczki:** LimeZu Modern Interiors: wyszukiwanie nie dało żadnego opisu okien w ścianach bocznych (strona i komentarze nie mówią o tym) [niezweryfikowane; `35b` §8.2 widział jeden GIF: okna tylko z tyłu]. Seliel „Half-Timber Home” 3.0: „single-tile wall thickness” i większa różnorodność ram okien i drzwi, bez opisu boków [wtórne, [itch](https://seliel-the-shaper.itch.io/half-timber-home/devlog/905239/interior-revision-30)]. Strony Kieren Day i Venova zwróciły 404. Kenney, Cainos: nie oglądałem.

**Nic nie znalazłem** (szukałem pod hasłami top-down room windows side wall, LimeZu windows, cutaway front wall) o tym, jak 3/4 pokazuje okno w wierzchu ściany bocznej lub dolnej [niezweryfikowane: nieobecność źródła, nie dowód nieobecności].

**Z pamięci** (nieweryfikowane dziś): Pokémon gen 3–5 i BDSP, EarthBound i Mother 3, Undertale, Octopath: okna tylko w ścianie tylnej; EarthBound ma ściany boczne ukośne, może z oknami [niezweryfikowane]. Lisa: top-down z licami, okna w licu [niezweryfikowane]. Kentucky Route Zero: okna jako element sceny teatralnej, inny rzut [niezweryfikowane]. Signalis, HLD: bez okien bocznych [niezweryfikowane poza SIGNALIS].

## 2. Katalog technik

Skala czytelności: **N** niska (okno nie jest odgadywane), **Ś** średnia, **W** wysoka. Koszt w naszym potoku: **mały** (gotowa funkcja albo jeden sprite) / **średni** (nowy kod lub kilka assetów) / **duży** (nowy rzut lub zmiana modelu ścian). Wszystkie oceny czytelności i kosztów to **[wniosek]**, o ile nie napisano inaczej.

### T1. Samo światło (plama lub smuga na podłodze), bez śladu na wierzchu
- **Precedensy:** Stardew pod oknami tylnymi (smugi) i Moonlighter (ciepłe plamy) [zweryfikowane w `43`/`35b`]; Darkwood miał to według `35b` §1, ale `35b` §8.3 tego nie potwierdził.
- **Czytelność: N–Ś.** Mówi „tu coś świeci”. Bez dodatkowego sygnału czyta się jak lampa w ścianie (`47` §3).
- **Koszt:** mały (jest w prototypie). **Ryzyko:** „lampa w ścianie”.

### T2. Światło z cieniem ościeżnicy i szprosów (gobo kraty)
- **Co:** tekstura plamy ma ciemne linie ramy i krzyża: 2×2 albo 2×3 jasne prostokąty. Przy niskim słońcu zimą kształt jest ścięty i wydłużony (jak w `47`). Zimą kratę można „zaszronić”: miękkie, nieregularne rogi pól.
- **Precedensy:** Disco Elysium ma kierunkowe światło przy oknach, ale tekst nie mówi o kracie [zweryfikowane, tylko kierunkowość]. Wyniki wyszukiwania wskazały devlog gry na itch.io, gdzie maska światła daje cień ramy okna na podłodze [wtórne, tylko snippet wyszukiwarki, nie lektura]. W żadnej grze pixel art 3/4 nie potwierdziłem [niezweryfikowane].
- **Czytelność: W** (jedyny sygnał, który odróżnia okno od lampy bez żadnego rysunku na ścianie).
- **Koszt:** mały. Jedna tekstura światła (np. 128×64) generowana skryptem, kilka wariantów (1 szyba, 2×2, 2×3, zaszroniona). **Ryzyko:** zbyt ostre linie wyglądają jak siatka UI; przy małym oknie 54 px krata może zlać się w szum, więc kratę robimy z **jednego** krzyża.

### T3. Ślad otworu na wierzchu: przerwa, parapet, słupki ościeża
- **Co:** parapet jaśniejszy o stopień i **wystający 1–2 px na podłogę**, ciemne słupki 1–2 px na końcach, wierzch w rytmie przerwany.
- **Precedensy:** Door Kickers 2: słupki ościeża szersze niż ściana, wystają po obu stronach; HM2: kontur wokół szyby [zweryfikowane w `35b` §8.1].
- **Czytelność: Ś.** Mówi „ściana ma otwór”, ale bez szkła może się czytać jako wnęka lub drzwiczki.
- **Koszt:** mały (jeden pasek sprite'a, 2 normal mapy). **Ryzyko:** „uszka” przy małej skali, `35b` §8.4 mierzył to jako problem.

### T4. Cienka linia szkła w wierzchu
- **Co:** 1–2 rzędy szkła w ciemnym konturze, w kolorach nieba i śniegu, `unshaded` (patrz `35b` §8.5).
- **Precedensy:** Door Kickers 1 i 2, Hotline Miami 1 i 2, Police Stories (top-down; szkło 15–33% grubości ściany) [zweryfikowane w `35b` §8].
- **Czytelność: Ś w top-down, niepewna w 3/4** (nasz wierzch jest szeroki i kremowy, szkło to wąski pas ze wzorem z projektu; poprzednia próba wyszła „za ciemno, nie czyta się jako szkło”). Czyta się lepiej razem z T2 i T5.
- **Koszt:** mały–średni (dwa warianty `unshaded` dzień/złota/noc). **Ryzyko:** średnie. Powtórka niepowodzenia, jeśli szkło będzie `Lit` albo ciemne.

### T5. Zasłona, roleta, firanka jako rekwizyt
- **Precedensy:** Door Kickers 2: zasłona jako biały zygzak od środka okna [zweryfikowane w `35b`]; Unpacking: firanki, zasłony i rolety zaznaczają każde okno [zweryfikowane na zrzucie].
- **Jak to wygląda w naszym rzucie [wniosek]:** przy ścianie bocznej płaszczyzna zasłony jest równoległa do ściany, więc w widoku 3/4 jest **cienkim pionowym pasem** (3–6 px szerokości, wysokość: długość okna po skrócie plus wysokość zasłony). Przy ścianie dolnej zasłona widziana jest „od tyłu” jako poziomy pas nad wierzchem. Zasłona może być częściowo odsłonięta, a jej stan może zmieniać porę dnia (zaciągnięta nocą).
- **Czytelność: W razem z T2.** Zasłona to najbardziej jednoznaczny znak „tu jest okno” w ludzkim doświadczeniu.
- **Koszt:** mały–średni (2–3 sprite'y zasłon w 3 orientacjach, normal mapa). **Ryzyko:** pasek może wyglądać jak słup lub parawan; ustawiać tylko przy oknie.

### T6. Kaloryfer, parapet z doniczką, gwiazda adwentowa, świeca
- **Co:** meble i rekwizyty, które sygnalizują okno bez rysowania szkła: kaloryfer żeberkowy pod oknem (typowe w Skandynawii), parapet z roślinami, świecznik adwentowy (siedmioramienny elektryczny w oknie zimą), papierowa gwiazda, lampka. Do tego zimą szron i zapotnienie na szkle.
- **Precedensy:** Unpacking pokazuje rekwizyty na parapecie jako część okna [zweryfikowane]. Szczegóły skandynawskie (świecznik adwentowy, kaloryfer pod oknem) to wiedza ogólna [niezweryfikowane].
- **Czytelność: Ś–W**, dodaje klimat nordic noir i zimowy rytm roku (adwent: świecznik w oknach od końca listopada).
- **Koszt:** mały (rekwizyty to zwykłe obiekty, wymagają tylko wygenerowania). **Ryzyko:** mebel stawiany „przy bocznej ścianie” bywa pustym pudłem w widoku 3/4 (`grafika.md`, decyzja 6); kaloryfer ma być niski.

### T7. Krótkie ukośne lico tylko przy oknie (Moonlighter „misa”)
- **Co:** ściana boczna to wierzch, a **tylko w miejscu okna** wierzch rozszerza się na lokalne lico 6–10 px, w którym rysujemy okno z frontu (skrócone).
- **Precedensy:** Moonlighter: okno boczne rysowane na pochylonej ścianie, prawie białe szyby, aureola [zweryfikowane w `35b` §8.2, zrzut nr 10]. Nie widziałem gry, która robi to tylko lokalnie [niezweryfikowane].
- **Czytelność: W.** Okno jest oknem, jak okno tylne.
- **Koszt: duży.** Lokalne lico przerywa wierzch; trzeba zmienić schodki ściany i wygląd w narożnikach. Podnosi też decyzję 6 z `grafika.md` (wąski pasek boku 6–8 px). **Ryzyko:** wysokie, bo to inny rzut w jednym miejscu ściany.

### T8. Niska ściana przednia lub cutaway z oknami
- **Co:** ściana dolna rysowana jako niskie lico (np. 20–30 px) z oknami widocznymi „od zewnątrz” albo przezroczysta/wygaszana przy graczu; albo całkiem usunięta.
- **Precedensy:** Project Zomboid: cutaway „sims-style”, usuwa ściany zasłaniające widok [wtórne, blog PZ], pokazuje się też na zrzucie [zweryfikowane: pokój z wyciętymi ścianami]. Unpacking: ściany od kamery usunięte [zweryfikowane]. `43` §6 odradza wygaszanie w 3/4 (stan zależny od gracza, ADR 0007).
- **Czytelność:** W dla okna (rysujemy je normalnie), ale kosztem zakrycia podłogi i zmiany konwencji.
- **Koszt:** duży (kod wygaszania, sortowanie, lico dolne z oknami). **Ryzyko:** wysokie, sprzeczne z decyzją projektu (`grafika.md`: ściana dolna to sam wierzch).

### T9. Widok z zewnątrz: świecące okna na fasadzie i poświata na śniegu
- **Precedensy:** Project Zomboid nocą: okna domów świecą różnymi barwami, na śniegu leżą poświaty [zweryfikowane na zrzucie]. Eastward: żółte okna na przyczepach nocą [zweryfikowane]. Sun Haven i Fields of Mistria: fasady z oknami w śniegu [zweryfikowane].
- **Czytelność:** W dla „ten dom ma okna i ktoś w nim jest”. Bardzo nastrojowe, szczególnie zimą nocą.
- **Dlaczego to dotyczy okien bocznych i dolnych [wniosek]:** gracz, który zna elewację, wie, że w tej ścianie jest okno, a w środku widzi tylko światło. Okno ma jeden rekord danych (ściana, pozycja, szerokość, typ), z którego robimy i okno na fasadzie, i światło wewnątrz, i poświatę na śniegu na zewnątrz.
- **Koszt:** średni (fasady już planujemy; jedna `PointLight2D` poświaty na okno z tekstury; sync dzień/noc/zapalone światło). **Ryzyko:** niskie.

### T10. Cząsteczki w smudze: kurz, płatki śniegu
- **Co:** w obrębie smugi lub plamy 6–16 powolnych, bardzo bladych cząstek (kurz w dzień, płatki śniegu w opadzie), kasowane poza maską plamy.
- **Precedensy:** Eastward: „sunlight beams breaking through the landscape during dawn and dusk” [wtórne]; wcześniejsza analiza fanowska wspomina „window light scattering” [niezweryfikowane, blog fanowski]. W Unpacking smugi na szkle [zweryfikowane].
- **Czytelność: Ś (wzmacniacz, nie sygnał samodzielny).** Pokazuje, że światło ma objętość.
- **Koszt:** mały (`GPUParticles2D` z maską lub kilka sprite'ów). **Ryzyko:** migotanie, gdy za dużo cząstek.

### T11. Odbicie okna na meblach i podłodze
- **Co:** meble w plamie okna dostają jaśniejszy wierzch (normal mapa + światło), na lustrze albo szklanym blacie krata okna jako odbicie; na mokrej podłodze (wejście) rozmyta plama.
- **Precedensy:** nie widziałem w obejrzanych grach [niezweryfikowane]. To naturalny skutek 2D lights z normal mapami, który mamy za darmo.
- **Czytelność: Ś (uzupełnienie).** **Koszt:** zerowy poza tym, że meble muszą mieć normal mapy. **Ryzyko:** brak.

### T12. Światło nocą: chłodne z okna, ciepłe z lamp, księżyc, latarnia
- **Co:** noc ma inną barwę smugi. Okna północne i dolne dają błękit śniegu (`415d7a`, `547188` z `35b`), okno od strony latarni dostaje sodową żółć `e8c27a`. Odbicie lampy z pokoju w szkle (1–2 px) zamiast „gołego granatu”.
- **Precedensy:** Zomboid: kolorowe poświaty nocą [zweryfikowane na zrzucie]. Palety w `35b` §8.5 są własne.
- **Czytelność: Ś–W**, jeśli noc ma wyraźny kontrast chłodne/ciepłe. **Koszt:** mały. **Ryzyko:** noc zlewa się z ciemnym wierzchem, jeśli szkło nie jest jaśniejsze od ściany.

### T13. Unikanie: układ pokoi pod okna tylne
- **Co:** ważne okna tylko w ścianach tylnych; okna boczne/dolne robimy rzadko albo wcale, a pokój po stronie bez okien dostaje światło z lamp, kominka, telewizora.
- **Precedensy:** praktycznie cały gatunek (Stardew, GK, TTM, Mistria, Pokémon; `43`) [zweryfikowane tam].
- **Czytelność:** n/d (okno jest czytelne, bo ma lico). **Koszt:** zerowy. **Ryzyko:** ogranicza projekt posterunku i mieszkań, bo pokoje boczne zostają bez widoku. Wniosek: tak projektować domyślnie, a zestawy S0/S1 dla wyjątków.

### Porównanie krótkie

| Technika | Czytelność samodzielnie | Z innymi | Koszt | Ryzyko |
|---|---|---|---|---|
| T1 sama plama | N–Ś | Ś | mały | „lampa w ścianie” |
| **T2 plama z kratą** | **W** | W | mały | gobo za ostre |
| T3 ślad na wierzchu | Ś | W | mały | „uszka” |
| T4 linia szkła | Ś (top-down) / niepewna 3/4 | W | mały–średni | powtórka porażki z prototypu |
| **T5 zasłona** | W | W | mały–średni | wygląda jak słup |
| T6 kaloryfer, parapet | Ś–W | W | mały | pusty mebel przy ścianie |
| T7 lico lokalne | W | W | **duży** | zmiana rzutu w jednym miejscu |
| T8 cutaway/niska ściana | W | W | **duży** | sprzeczne z decyzją |
| **T9 fasada i śnieg na zewnątrz** | W | W | średni | niskie |
| T10 cząstki | Ś (wzmacniacz) | Ś | mały | migotanie |
| T11 odbicia | Ś | Ś | ~0 | brak |
| T12 noc | Ś–W | W | mały | zlewa się z wierzchem |
| T13 układ pokoi | n/d | n/d | 0 | ogranicza projekt |

## 3. Dlaczego sama „ściana ze światłem” nie wystarcza, i co czyni okno oknem [wniosek]

- **Lampa i okno różni geometria światła.** Lampa daje okrągły lub stożkowy spadek jasności od jednego punktu. Okno daje **prostokąt z ostrym brzegiem, kratą cienia i kierunkiem**, mocniejszy przy ścianie i słabnący z odległością. Gracz to rozpoznaje podświadomie z życia.
- **W małej skali rozpoznanie robi kontekst, a nie rysunek szkła** (`35b` §2). Dlatego T2, T3, T5, T6 razem dają więcej niż T4 samo.
- **Prawdziwe okno ma stronę zewnętrzną.** Gracz widział okno z zewnątrz (T9). W środku to uzupełnienie: światło ma źródło, które pamięta z ulicy.

## 4. Ściany boczne a ściana dolna: różnice

| | Ściana boczna (lewa/prawa) | Ściana dolna (do kamery) |
|---|---|---|
| Co widać z kamery | wierzch (wąski, pionowy pas), brak lica | wierzch (poziomy pas); lico (zewnętrzne) zostało wycięte |
| Gdzie jest „wnętrze okna” | po stronie pokoju, w profilu, więc parapet i zasłona są widoczne **z boku** | „za plecami” obrazu, więc widać tylko to, co leży nad pasem wierzchu |
| Kierunek światła w pokoju | w poprzek pokoju, poziomo | od dołu w górę ekranu, do tylnej ściany |
| Konwencja z `47` §4.3 | słońce zależne od strony świata | okna dolne = strona północna, **bez słońca**, tylko zimne światło nieba |
| Najtańszy dobry zestaw | S0: plama z kratą + parapet | S0 jak obok, bez smugi w powietrzu |
| Zasłona | cienki pionowy pas przy ścianie | pas poziomy tuż nad wierzchem, widziany od tyłu |
| Ryzyko | pion światła mylony z lampą | okno „przykryte” przez gracza stojącego nad pasem; plama nie sięga w głąb |

W obu przypadkach rola pasa wierzchu: **wierzch jest grubą krawędzią, a parapet wychodzi z jego strony pokoju.**

## 5. Szkic: jak wygląda wierzch z oknem

Skala poglądowa: 1 znak = 2 px wzdłuż ściany. Pas wierzchu 10 px (jak w `35b` §8.5). Legenda: `#` ciemny wierzch, `|` słupek ościeża (ciemny, `2e2a25`), `=` linia szkła (jasna, `unshaded`), `s` parapet (jaśniejszy o stopień, wystaje 1–2 px do pokoju), `.` podłoga pokoju, `*` światło na podłodze, `x` cień szprosa w świetle, `o` śnieg na zewnętrznym parapecie (1 px).

### 5.1 Ściana dolna (pokój u góry, pas poniżej)

```
  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
  .  .  .  *  *  *  *  *  *  *  *  *  *  *  .  .  .   plama zimnego światła
  .  .  .  *  *  *  x  *  *  *  x  *  *  *  .  .  .   z cieniem szprosów (x)
  .  .  .  .  *  *  x  *  *  *  x  *  *  .  .  .  .
  .  .  [kot]  .  .  .  .  .  .  .  [kaloryfer] .  .   rekwizyty stoją w pokoju
 ##############ss ssssssssssssss ss##################   <- rząd 0: parapet (s) wystaje 1-2 px
 ##############|   |            |##################      do pokoju (rząd nad pasem)
 ##############| = = = = = = = |###################      rząd 3-4: ciemny kontur, szkło `=`
 ##############|                |##################      (1 linia; w S0 brak i zostaje `#`)
 ##############|oooooooooooooooo|##################      rząd 8: śnieg na zewn. parapecie
 ####################################################    rząd 9: ciemna krawędź zewn.
```

### 5.2 Ściana boczna lewa (pokój po prawej, pas pionowy; rysunek obrócony)

Kolumny od lewej: krawędź zewn. | śnieg | kontur | szkło | kontur | parapet | podłoga.

```
 #|o|=|s  .  .  .  .  *  *  *  *  .  .       przerwa w rytmie wierzchu = otwór
 #|o|=|s  .  .  .  *  *  x  *  *  *  .       plama światła zimnego/ciepłego
 #|o|=|s  .  .  .  *  *  x  *  *  *  .       z cieniem szprosa
 #|o|=|s  [zasłona: pas 4 px]  .  .  .
 #|o|=|s  [kaloryfer niski]  .  .  .  .
 ###|  s  .  .  .  .  .  .  .  .  .  .       słupek ościeża na końcu
```

### 5.3 Wariant S0 (sama kratka, bez szkła)

```
 ##############ss ssssssssssssss ss##################   parapet + słupki, wierzch bez szkła
 ##############|##############|###################
 ##############|##############|###################      wnęka ciemna, nic nie świeci w pasie
 ####################################################
 (nad pasem) plama z kratą jak wyżej
```

Zasada: w S0 cała informacja idzie przez światło i parapet, w S1 dochodzi 1 linia szkła, w K lokalne lico.

## 6. Rekomendacja dla game2: zestawy okien

**Odpowiedź na pytanie:** tak, ściana boczna i dolna zostają „ścianą”, z której świeci, ale **światło ma kształt okna** (krata, kierunek, ostry brzeg), wierzch ma **ślad otworu** (parapet, słupki, ewentualnie cienka linia szkła), a obok stoją **rekwizyty okna** (zasłona, kaloryfer, roślina). Ta kombinacja odpowiada na „czy to okno”, a „lampa w ścianie” zostaje wykluczona. Same plamy bez kraty i bez śladu na wierzchu zostawiają tę wątpliwość.

### Zestaw S0: „światło z kratą” (domyślny dla boku i dołu)

| Warstwa | Zawartość | Węzeł w Godot 4 | Uwagi |
|---|---|---|---|
| Wierzch (sprite) | pas wierzchu z otworem: parapet o stopień jaśniejszy, wystający 1–2 px do pokoju; dwa słupki ościeża 1–2 px (`a8978e` lub ciemniejsze); wnęka ciemna | `Sprite2D` + normal map (parapet łapie poduszkę nieba; normal „do pokoju”) | bez `unshaded`. 1 sprite na długość okna (54 px = 1,35 m) i wariant 1 m / 2 m |
| Światło 1 | poduszka nieba przy ścianie (miękki prostokąt, kolor nieba) | `PointLight2D` z teksturą `SKY_PILLOW`, `blend_mode = ADD`, `shadow_enabled = false`, `height` ok. 70 | wzorzec A z `47` §5 |
| Światło 2 | plama z kratą (gobo) o kierunku zgodnym z `47` §4.1; długość zależna od pory | `PointLight2D` z teksturą gobo, obrócona do ściany; kolor z `sun.gold`/`sun.night`; energia z `view_k` | tekstura generowana skryptem (jeden krzyż, wariant zaszroniony); przy oknie dolnym tylko chłodne światło nieba, bez słońca |
| Okluder | wierzch ściany ma `LightOccluder2D` **z przerwą nad oknem**, żeby światło nie było odcięte; sama bryła ściany dalej rzuca cień na meble | `LightOccluder2D` | źródło umieszczone po stronie pokoju, na wewnętrznej krawędzi parapetu |
| Dodatki | zasłona (T5), kaloryfer lub doniczka (T6) | `Sprite2D` y-sort | zawsze 1–2 rekwizyty na okno, nigdy gołe |
| Zima | szron na rogach gobo (wariant tekstury), 1 px śniegu na zewnętrznym parapecie (część sprite'a wierzchu) | w teksturach | bez animacji |
| Cząstki | kurz (dzień) lub płatki (opad) w plamie | `GPUParticles2D`, `emission_shape` = prostokąt plamy | 6–16 cząstek, alfa < 0,4 |

**Dzień/noc:**

| Pora | Światło (gobo) | Poduszka | Ślad na wierzchu |
|---|---|---|---|
| Dzień, słońce (strona S/E/W) | ciepły biały, krata wyraźna, długa | `sky_color` | parapet jasny |
| Dzień, pochmurno/północ | chłodny, krata miękka i krótka | niebo, bez słońca | jak wyżej |
| Złota godzina (13–16 w lutym ok. 63°N) | żółto-pomarańczowy, długi i niski | złota | parapet ciepły (modulate) |
| Błękitna godzina | błękit, krata słaba | błękitna | bez zmian |
| Noc | księżyc (blady błękit) lub latarnia (`e8c27a`), krata słaba | chłodna | bez zmian |

### Zestaw S1: „szczelina” (S0 + cienka linia szkła)

- Dodajemy do wierzchu **jedną** linię szkła (1–2 rzędy), według przepisu `35b` §8.5, z poprawkami: **szkło `unshaded` i jaśniejsze od ściany**, kontur po obu stronach, bez ukośnych błysków i bez wzoru. Słupki równe ze ścianą, jednolity kolor.
- Szkło jako osobny sprite z `CanvasItemMaterial` w trybie `Unshaded`; kolor z `view_k` jak widok okna tylnego (dzień/złota/noc) [`35b` §4.3].
- Noc: szkło `262e47 → 415d7a`, plus **1 px odbicia lampy** (ciepły, `e8c27a` przy lampie w pokoju) zamiast samego granatu. To jest ten element, który mówi „szkło” w nocy, gdy za oknem jest czerń; **[wniosek]**, nie sprawdzone w grze.
- Używać tam, gdzie okno musi być czytelne bez kontekstu (np. okno główne pokoju, okno z fabularnym znaczeniem).

### Zestaw K: „okno bohater” (lokalne lico, tylko 2–3 w grze)

- Dla okna, które gracz ma zauważyć (np. okno mieszkania z widokiem na ulicę, okno posterunku, oranżeria): wierzch na tej długości rozszerza się o lokalne lico 6–10 px z oknem narysowanym z frontu, skróconym (jak Moonlighter) [zweryfikowane precedens, [zrzut 10 w `35b`]].
- Zależy od decyzji 6 z `grafika.md` (czy dopuszczamy wąski pasek boku ok. 6–8 px). **Jeśli ten pasek wejdzie na stałe, okna boczne mogą po prostu nim być**, a K staje się standardem dla boków, a nie wyjątkiem.
- Koszt duży, więc nie jako domyślny.

### Wspólne elementy

1. **Rekord okna** (np. zasób `WindowDef`): ściana (N/E/S/W), pozycja, szerokość, typ (S0/S1/K), kierunek słońca, stan zasłony. Z niego powstaje okno na fasadzie (T9), światło wewnątrz i poświata na śniegu na zewnątrz. Jedno źródło prawdy, zero rozjazdów.
2. **Fasada:** szyby żółte, gdy w pokoju świeci lampa, wciąż ciemne w dzień; poświata na śniegu pod oknem (`PointLight2D` z miękką teksturą), kolor z lampy.
3. **Zasłona:** 2–3 sprite'y (otwarta, półotwarta, zaciągnięta) dla ściany bocznej (pionowy pas) i dolnej (poziomy pas). Stan zależy od pory: noc zaciągnięta, w dzień odsłonięta. Zaciągnięta zasłona **blokuje światło** (plama znika, zostaje tylko ciepły rozbłysk na samej zasłonie).
4. **Kaloryfer:** niski sprite z 1 orientacją przy bocznej ścianie (profil) i 1 przy dolnej. Wprowadza „zimę w domu” i uzasadnia parapet.
5. **Śnieg i szron:** 1 px śniegu na zewnętrznej krawędzi parapetu w wierzchu, szron w rogach gobo, a przy pogodzie ze śniegiem lekkie `GPUParticles2D` w plamie.
6. **Generowanie assetów:** wierzch z otworem rysujemy z szarego boxa jako prowadnicy, jak inne elementy ściany (`grafika.md`: geometria jako wejście). Zasłony i kaloryfer to zwykłe meble (generacja + test). Tekstury gobo robimy skryptem, nie AI: kontrola nad kształtem i spójnością. Okna w licu tylnym zostają bez zmian (generowane jako sprite'y frontowe).

### Czego unikać

- Szkło `Lit` (ściemnia się razem z ścianą, `35b` §3).
- Ukośne błyski i wzory na szkle w wierzchu.
- Jasny słupek środkowy dzielący linię szkła na dwa „świetlówki” (`35b` §8.4).
- Okno w ścianie dolnej z ciepłym słońcem, jeśli ściana dolna to północ (`47` §4.3).
- Rekwizytów wysokich przy ścianie dolnej, które zasłaniają gracza (`51b`).

## 7. Test, który rozstrzyga (zamiast kolejnej debaty)

Arkusz porównawczy w stylu `35b` §6, ale z testem czytelności:

| Wariant | Opis |
|---|---|
| A | tylko plama (T1), jak teraz |
| B | S0 (plama z kratą + parapet i słupki) |
| C | S1 (B + linia szkła) |
| D | S1 + zasłona + kaloryfer |
| E | K (lokalne lico) dla porównania |

Pory: dzień słoneczny, pochmurno, złota godzina, błękitna godzina, noc. Ściany: boczna prawa, boczna lewa, dolna.

**Kryterium (do wykonania przez kogoś, kto nie wie, co jest na obrazku):** pokazać kadr 960×540 przez 5 s i zapytać „co jest w tej ścianie?”. Wynik = odsetek odpowiedzi „okno”. Cel: ≥ 80% dla D i S1, ≥ 60% dla S0, dla A oczekiwane wyraźnie niżej. Oprócz tego dwa pytania jakościowe: czy zimą to wygląda jak okno na mróz, czy nocą nie zamienia się w czarną dziurę. Gdy S0 przechodzi 60%, wystarczy jako domyślny, a S1 zostaje dla wyjątków.

## 8. Rzeczy niesprawdzone i uczciwe zastrzeżenia

- **Zrzuty oglądałem w miniaturach 640×360**, więc małe okno w wierzchu mogłem przeoczyć. Brak okna na zrzucie nie dowodzi, że gra go nie ma.
- **Nie znalazłem żadnego opisu okna w wierzchu ściany w paczce pixel art 3/4** (LimeZu, Seliel, Kenney, Cainos). Strony zwracały 404 albo nie opisywały boków.
- **Gobo kraty okna w pixel art 3/4:** technika jest znana, ale nie zweryfikowałem jej w żadnej konkretnej grze. Jedyne wsparcie: wzmianka z wyszukiwarki o devlogu z maską cienia ramy na podłodze [wtórne] i opis kierunkowego światła z Disco Elysium [zweryfikowane, bez kraty].
- **Szczegóły skandynawskie** (kaloryfer pod oknem, świecznik adwentowy, szron na szybie od środka) to wiedza ogólna [niezweryfikowane].
- **Pokémon, EarthBound, Mother 3, Undertale, Octopath, Lisa, KRZ:** z pamięci.
- **Moonlighter lokalnie:** nie widziałem gry, która robi lico tylko przy oknie. K to propozycja.
- **Zimowe kolory i szron:** nie próbowane w prototypie, tylko w teorii. Wartości kolorów z `35b` §8.5 wymagają oceny w scenie.
- **Wydajność:** 2 `PointLight2D` plus cząstki na okno, kilka okien na ekran. W razie potrzeby poduszkę i gobo da się zlać w jedno światło. Nie mierzyłem.

## Źródła

Pliki z repo (wszystkie przeczytane, w tym oba PNG z `35b`):
- `C:\Users\bartl\Desktop\game2\docs\grafika.md`, `docs\research\43-sciany-wnetrz-3-4.md`, `35b-okna-w-wierzchu-sciany.md` (+ `35b-okna-makieta.png`, `35b-okna-przyklady.png`), `47-swiatlo-okien-z-roznych-scian.md`, `51-spojna-grafika-3-4.md` (przeczytane tylko streszczenie i spis), `51b-obroty-i-uklad-obiektow-3-4.md` (spis treści; nie czytałem całości).

Zrzuty ze Steam (API `store.steampowered.com/api/appdetails`, obrazy pobrane do katalogu roboczego, oglądane jako plansze miniatur):
- Eastward (appid 977880), Sea of Stars (1244090), Chained Echoes (1229240), Fields of Mistria (2142790), Sun Haven (1432860), Cassette Beasts (1321440), OMORI (1150690), Disco Elysium (632470), Project Zomboid (108600), Unpacking (1135690), SIGNALIS (1262350), Coral Island (1158160). Pobrane, nieoglądane: CrossCode (368340), Hyper Light Drifter (257850), LISA (335670), Kentucky Route Zero (231200), Graveyard Keeper (599140), Stardew (413150), RimWorld (294100), Prison Architect (233450), Cult of the Lamb.

Strony i teksty:
- Disco Elysium, „Shedding light”: https://discoelysium.com/devblog/2016/02/02/shedding-light [zweryfikowane, tekst przez narzędzie].
- Gamedeveloper, Eastward: https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures [wtórne].
- Seliel the Shaper, Half-Timber Home, Interior Revision 3.0: https://seliel-the-shaper.itch.io/half-timber-home/devlog/905239/interior-revision-30 [wtórne].
- Blog Project Zomboid (cutaway): https://projectzomboid.com/blog/?p=7049, `?p=3389`, `?p=6220` [wtórne, tylko streszczenia z wyszukiwarki].
- Wyniki wyszukiwania o oknach w paczkach top-down (kitofi, reakain, sweeetpotatoo, spectralgame, Hyades RPG itp.), tylko jako tytuły i snippet [niezweryfikowane].
- LimeZu Modern Interiors: https://limezu.itch.io/moderninteriors (wyniki wyszukiwania, bez opisu okien bocznych) [niezweryfikowane].
- Wcześniejsze źródła przytoczone z `35b`: Door Kickers 1 i 2, Hotline Miami 1 i 2, Police Stories, Moonlighter, The Escapists 2, RimWorld + Open The Windows (patrz tabele w `35b` §8) [zweryfikowane w `35b`, nie ponawiane].
