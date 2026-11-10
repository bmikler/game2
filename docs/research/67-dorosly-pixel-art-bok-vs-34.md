# Dorosły pixel art: 3/4 i izo (priorytet) oraz bok (tylko nastrój)

Stan: 2026-11-08. Ciąg dalszy `60-kotwice-stylu-kandydaci.md` po odrzuceniu Stoneshard i Eastward jako „zbyt dziecinnych (proporcje i styl)”. **Aktualizacja człowieka:** gra ma swobodną eksplorację miasta (ruch w 4/8 kierunkach po ciągłej mapie), wnętrza jako osobne mapy, jeden rzut w całej grze; **widok z boku odpada jako rzut**, zostaje jako źródło nastroju, koloru i postaci. NORCO jest „najbliżej klimatu, ale nie idealne”; szukamy inspiracji na cały styl (vibe, postacie, pomieszczenia), nie na śnieg. Kryteria „nie-dziecinne”: 6-7 głów, kanciaste kształty, oszczędne twarze, stonowana paleta, dość pikseli na postać. Nic tu nie jest decyzją.

Plansza (lokalnie, nie publikować): `docs/research/67-assets/plansza.html` (sekcje „3/4 i izo” oraz „Bok”). Zrzuty: `67-assets/<gra>-<n>.jpg` (Steam `appdetails`, `path_full`, po 4 na grę; Death Trash i NORCO skopiowane z `60-assets/`).

Oznaczenia: **[zweryfikowane]** opis sklepu (Steam API) lub wymiar pliku; **[pomiar]** skrypt na JPEG-u; **[zrzut]** to, co widać na obejrzanym kadrze; **[wtórne]** z pamięci/ogólnej wiedzy, nieweryfikowane tu; **[niezweryfikowane]**; **[wniosek]** moja interpretacja.

## TL;DR

1. **Najlepszy nowy trop: Pixel Noir** (2024, izo, noir, noc, deszcz, wnętrza z odciętą ścianą, mocne punktowe światło) [zrzut]. Najbliższy wszystkim kryteriom naraz: dorosły rysunek, kanciaste sylwety, mała liczba pikseli na twarz, noir. Do sprawdzenia: skala natywna i liczba kierunków (zrzuty są ze skalowaniem).
2. **Dorosłe proporcje w 3/4 i izo mają:** Pixel Noir (ok. 6 głów), Death Trash (5-6), Drova (5,5-6), klasyki pre-renderowane Fallout 2 i Arcanum (ok. 7, ale to sprite'y z modeli 3D, nie rysowany pixel art) [zrzut/wtórne]. Odpadają jako chibi/stylizowane: Children of Morta, Hammerwatch II, Unsighted (anime), Ruinarch.
3. **Niski kąt kamery z frontalnymi ścianami** (postać prawie z boku) w dorosłym pixel arcie to **rzadkość** [wniosek]: znalazłem **Beat Cop** (ulica jako fasady frontalne, postać ok. 28-30 px, wnętrza jako przekroje) i częściowo **Fear & Hunger** (RPG Maker, ściany frontalne). Reszta „niskiego kąta” to chibi (Eastward, Stardew-podobne).
4. **Wysokość postaci a dorosłość** (szczegóły w sekcji niżej): w 3/4 dorosłe proporcje *z czytelną twarzą* zaczynają się ok. **40-50 px natywnych**; przy **ok. 30-35 px** czytają się tylko sylwetką (Death Trash, Beat Cop) i wymagają oszczędnych twarzy [wniosek].
5. **Zima:** Disco Elysium (malarskie, tylko nastrój) i Vampire's Fall (pre-render, nie pixel art) pokazują śnieg na dachach; żaden pixel-artowy kandydat z listy nie [zrzut]. Reszta w `66-*`.
6. **Bok** zostaje do nastroju: NORCO (najbliżej klimatu), Kathy Rain, Lamplight City, Gemini Rue, Lacuna (5 gier, zob. sekcja A).

## Metoda i jej ograniczenia

- Zrzuty oficjalne ze sklepu, 4 na grę, obejrzane jako arkusze 2×2 [zweryfikowane]. Pomiar skali: te same kryteria co w 60 (koncentracja krawędzi na jednej reszcie `x mod k`; ≥0,85 = pewne). Gry pre-renderowane (Fallout 2, Arcanum, Blade Runner) i z filtrami nie mają skali pikselowej [pomiar].
- Wysokość postaci z arkuszy: **±20-25%**, w P&C zależy od głębi; w 3/4 od kadru [wniosek].
- Liczba kierunków i mapa świata: wiedza ogólna [wtórne], nie sprawdzana grą.

## B. Widok 3/4, izo, top-down (priorytet)

| Gra | Rzut | Skala natywna | Postać (px natyw.) | Głowy (czy dorosłe?) | Kontur | Paleta | Światło nocą | Eksploracja |
|---|---|---|---|---|---|---|---|---|
| **Pixel Noir** (2024) | izo 2:1, wnętrza z odciętą ścianą | niezmierzona (zrzuty 1286-1450 px, nie pełne HD) [niezweryfikowane] | ok. 45-50 [niska pewność] | **tak, ok. 6**, kanciaste, twarze to kilka pikseli [zrzut] | selektywny, ciemny | ciemna zieleń/brąz/granat, akcenty neonu | stożek lampy, latarnie ze świetlnymi plamami na mokrej jezdni, deszcz [zrzut] | detektyw w mieście, wnętrza osobno [zrzut/wtórne: klasyczne RPG] |
| **Death Trash** (2021) | izo 2:1 | ×4 (480×270) [pomiar 0,97] | ok. 35 | **tak, ok. 5-6**, oszczędne twarze | brak ciągłego | rdza/czerń, cyjan | jedno-dwa punkty zimnego światła na czerni | ciągła mapa regionów [zrzut: mapa] |
| **Drova - Forsaken Kin** (2024) | 3/4 oblique | ×2 (960×540) [pomiar 0,94-0,99] | ok. 55-70 [niska pewność] | **tak, ok. 5,5-6**, ludzkie ubrania [zrzut] | selektywny ciemny | ziemista, akcent czerwony | pochodnie z kołem światła, jaskinie czarne | otwarty świat [wtórne] |
| **Beat Cop** (2017) | **niski kąt: fasady frontalne**, ulica poziomo, wnętrza jako przekroje | ×3 (640×360) [pomiar 0,58-0,65, niepewne] | ok. 28-30 | ok. 5, **proporcje uproszczone, ale nie chibi** [zrzut] | selektywny ciemny | ceglana, żółta, niebieska, nasycenie średnie | noc = przyciemniony kadr + ciepłe okna/latarnie [zrzut] | jedna ulica z wejściami do wnętrz [zrzut] |
| **Fear & Hunger** (2019) | RPG Maker, ściany frontalne | niezmierzona (zrzuty 540-814 px) [niezweryfikowane] | ok. 40-50 [niska pewność] | ok. 4-5, standard RPG Makera, portrety walki realistyczne [zrzut] | ciemny miękki | szaro-brązowa | koło światła wokół postaci na czerni | kafle, segmenty [wtórne] |
| **Fallout 2** (1998; Steam 2009) | izo pre-render, hex | 640×480 natywnie [zweryfikowane: rozmiar zrzutu] | ok. 45-50 [niska pewność] | **ok. 7**, realistyczne (modele 3D renderowane do sprite'ów) | n/d | zgaszona brudna zieleń/brąz | prawie bez dynamicznego światła; ciemniejsze lochy [zrzut] | mapa świata + lokalne mapy [wtórne] |
| **Arcanum** (2001; Steam 2016) | izo pre-render | 800×600 [niezweryfikowane] | ok. 50 [niska pewność] | **ok. 7**, realistyczne | n/d | ciemna, fiolet/brąz, nocny pokład statku [zrzut] | noc granatowa, ciepłe okna wnętrz [zrzut] | mapa świata + lokalne mapy [wtórne] |
| **Blade Runner 1997** (EE 2022) | pre-render 3D tła + modele 3D, **nie pixel art** | n/d | n/d | realistyczne | n/d | mgła, ciepły punkt w ciemnym błękicie [zrzut] | tylko jako wzorzec światła i mgły | n/d |
| **Disco Elysium** (2019) | izo, malarskie 3D, **nie pixel art** | n/d | n/d | realistyczne | n/d | gryzące, malarskie; w `disco-0` zaśnieżone dachy [zrzut] | tylko nastrój i portrety | miasto jako zbiór lokacji [wtórne] |

Odrzucone / niepasujące jako Kotwice:

| Gra | Powód [zrzut] |
|---|---|
| **Children of Morta** (2019) | proporcje „bohaterskie” ok. 4-5 głów, glow i nasycone efekty; postać ok. 35-45 px [niska pewność] |
| **Hammerwatch II** (2023) | ×3 [pomiar 0,74-0,87], postać ok. 20 px, 3-4 głowy, chunky, fantasy |
| **Unsighted** (2021) | ładna noc i deszcz (`unsighted-2`: dachy, granat), ale postać ok. 25 px i styl anime-chibi; wzór *koloru deszczowej nocy* |
| **ZERO Sievert** (2024) | top-down ×4 [pomiar 0,85-0,95]; postać ok. 15-20 px, widać głowę i ramiona, proporcje nie do oceny; dobry wzór dachów/dróg i latarek |
| **Ruinarch** (2023), **Hotline Miami 2** (2015), **Teleglitch** (2013) | god-sim chibi / schemat z góry / top-down low-poly; Teleglitch jako wzorzec stożków widzenia |
| **Vampire's Fall: Origins** (2020) | 3/4 z pre-renderowanych modeli, **zimowa wioska** (`vampiresfall-3`, dachy ze śniegiem) [zrzut], ale to nie pixel art |
| **HellSign** (2021), **Lisa: The Painful** (2014) | HellSign 3D, nie pixel art; Lisa to grube, kreskówkowe sprite'y z boku |
| Stoneshard, Eastward | zob. 60, odrzucone przez człowieka |

### Karty (skrót)

- **Pixel Noir** [zweryfikowane: Steam, „noir-influenced mystery … classic RPG elements”]. Kadry `pixelnoir-0` (biuro: izometryczny pokój z odciętą ścianą, lampa, monitory), `-1` (walka na ulicy, pomarańczowe lampiony), `-2` (laboratorium z dużym stworem), `-3` (miejsce zbrodni nocą: radiowozy, deszcz, lampy uliczne z halo). Wnętrza i ulice w jednym rzucie; ciepłe punkty światła na mokrej, ciemnej powierzchni [zrzut]. **Nie przenosić:** potworów sci-fi, wyskakujących ramek dialogu z żółtymi tytułami (inny styl niż w 65).
- **Death Trash**: zob. 60 i `deathtrash-*.jpg`; `-1` pokazuje iso wnętrze i UI w czerni [zrzut].
- **Drova** [zweryfikowane: Steam, „dark grim tones … Celtic mythology”]. `drova-*.jpg`: budynki frontem i dachem, ciemny kamień i drewno, pochodnie [zrzut]. **Nie przenosić:** celtyckiego fantasy.
- **Beat Cop** [zweryfikowane: Steam, „retro pixel art … ’80s cop shows”, Nowy Jork]. Kadry `beatcop-0/2`: ulica jako ciągły pas fasad (ceglane kamienice z reklamami, schody, hydranty), postacie ok. 28-30 px, oczy jako 1-2 piksele; `beatcop-1/3`: **nocny wariant to ten sam kadr przyciemniony + ciepłe okna i latarnie**, a wnętrza (komisariat, bar) jako **pokoje-przekroje** wstawione w fasadę [zrzut]. **Pułapka:** postać jest uproszczona do 4-5 głów, bo ma tylko ok. 30 px; to nie „6-7 głów” [wniosek].
- **Fear & Hunger**: kadr `feargunger-0` pokazuje pokój z kamienną podłogą jako koło światła na czerni; tylko mały sprite, rozdzielczość zrzutów niska [zrzut]. **Nie przenosić:** brutalności, estetyki RPG Makera 32-px.
- **Fallout 2 / Arcanum**: dorosłe proporcje (7 głów), ciemna, brudna paleta, wnętrza i miasto na tym samym rzucie izo [zrzut]. Wniosek: **dorosłość daje realistyczna sylwetka + brak koloru, nie sama skala** [wniosek]; ale sprite'y z modeli 3D są inną technologią niż rysowany pixel art (mogą służyć jako wzór siatki 8 kierunków i oświetlenia postaci) [wniosek].
- **Blade Runner 1997 EE, Disco Elysium**: tylko nastrój. BR: **jedno ciepłe źródło w niebieskiej mgle, długie smugi światła** (`bladerunner-1`, `-2`) [zrzut]. Disco: miasto w malarskiej zgaszonej palecie, portrety jako osobna warstwa UI [zrzut].

## Przy jakiej wysokości postaci 3/4 osiąga dorosłe proporcje

Dane (wszystkie **[pomiar/wniosek z zrzutu, ±20-25%]**):

| Gra | Wysokość (px natyw.) | Głowy | Czy czyta się dorośle? |
|---|---|---|---|
| Hammerwatch II | ok. 20 | 3-4 | nie: chunky |
| Children of Morta | ok. 35-45 | 4-5 | nie: stylizacja, nie liczba pikseli |
| Beat Cop | ok. 28-30 | ok. 5 | średnio: sylwetka tak, twarz nie |
| Stoneshard (60) | ok. 32 | 4,5-5 | **odrzucone przez człowieka** |
| Death Trash | ok. 35 | 5-6 | tak: oszczędne, kanciaste, twarz prawie bez detalu |
| Eastward (60) | ok. 43 | 3,5 | **nie, mimo większej skali** |
| Chef RPG (54) | ok. 48 | chibi | nie |
| Pixel Noir | ok. 45-50 | ok. 6 | tak |
| Fallout 2 / Arcanum | ok. 45-50 | ok. 7 | tak |
| Drova | ok. 55-70 | 5,5-6 | tak |

[wniosek]:
- **Liczba pikseli sama nie daje dorosłości**: Eastward (43 px) i Chef RPG (48 px) są większe niż Death Trash (35 px), a wyglądają dziecinnie przez proporcje (głowa ok. 1/3,5-1/3 wysokości).
- Dla 7 głów głowa ma ok. 1/7 wysokości: **przy 35 px to ok. 5 px głowy**, **przy 48 px ok. 7 px**, **przy 56 px 8 px**. Poniżej ok. 6 px głowy nie ma miejsca na oczy i nos, więc twarz musi być „oszczędna” (jak w Death Trash, Beat Cop).
- Praktyczne progi: **ok. 30-35 px** = dorosła *sylwetka* (kanciaste kształty, zero detalu twarzy, jak Death Trash, Beat Cop); **ok. 40-50 px** = dorosła sylwetka *z czytelną mimiką w kilku pikselach* (Pixel Noir, klasyki); **powyżej ok. 55 px** (Drova) = swoboda detalu, ale większy koszt animacji. Rzecz do potwierdzenia na próbce z własnymi postaciami [wniosek].
- Przy kafelku 24 px (z 54) postać 48 px to **2 kafle** (proporcja chibi w Chef RPG); dorosły człowiek 6-7 głów ma ok. 1,5-2 kafle, jeśli ok. 36-48 px [wniosek].

## C. Eksploracja miasta i kierunki postaci (wymaganie: ciągła mapa, wnętrza osobno)

[wtórne / niezweryfikowane], poza tym, co widać na zrzutach.

| Gra | Model eksploracji | Wnętrza | Kierunki postaci |
|---|---|---|---|
| Pixel Noir | miasto, lokacje; ciągłość nie sprawdzona [niezweryfikowane] | osobne pokoje z odciętą ścianą [zrzut] | 8 (izo) [niezweryfikowane] |
| Death Trash | ciągła mapa regionów [wtórne], mapa świata [zrzut] | osobne mapy | 8 (izo) [niezweryfikowane] |
| Drova | otwarty świat bez ekranów ładowania [wtórne] | osobne wnętrza [niezweryfikowane] | 4-8 [niezweryfikowane] |
| Beat Cop | ulica jako jeden poziomy kadr, wejścia do wnętrz [zrzut] | przekroje wstawiane w fasadę [zrzut] | 2-4 (przód/tył, boki) [niezweryfikowane] |
| Fear & Hunger | kafle, segmenty [wtórne] | wnętrza jak świat | 4 (RPG Maker) [niezweryfikowane] |
| Fallout 2 / Arcanum | mapa świata + lokalne mapy (miasta, wnętrza jako osobne mapy) [wtórne] | osobne mapy | 6 (Fallout, hex) / 8 (Arcanum) [wtórne] |

Z boku (do nastroju): NORCO, Kathy Rain, Lamplight City, Gemini Rue, Lacuna używają **scen/ekranów i mapy** [wtórne]; to model, który nie pasuje do wymagania ciągłej mapy.

## Koszt produkcji: izo / 3/4 (priorytet) vs bok

Same wnioski [wniosek], bez danych twórców.

- **Kierunki postaci.** Izo i 3/4: **4 kierunki** minimum, **8** przy ruchu po przekątnej (Pixel Noir, Death Trash izo); koszt animacji ok. 2-4× wyższy niż w boku (2 kierunki, lustro) [wniosek, szacunek]. Dorosła proporcja (6-7 głów) to droższe klatki niż chibi, bo więcej detalu na tej samej wysokości. **Oszczędność:** 8 kierunków tylko dla chodu i bezczynności, 4 dla reszty.
- **Fasady vs dachy.** Niski kąt (Beat Cop): budynek to **jedna fasada**, brak dachów, najtańsza kosztem rzutu i czytelności w głąb [wniosek]. Izo/3/4: dach + fasada + cień od ściany, więcej rysunków na budynek, ale składalne z kafli [wniosek, zob. 63/65].
- **Wnętrza.** Osobne mapy (wymóg człowieka): w izo pokój z odciętą ścianą (Pixel Noir `-0/-2`), meble w 4 obrotach; w niskim kącie pokój-przekrój (Beat Cop) jest tańszy, ale mebli nie da się obracać [wniosek, zob. 43/51b].
- **Ciągła mapa miasta.** Kafle i kolizje zamiast malowanych scen: koszt rośnie z powierzchnią mapy, nie z liczbą ulic [wniosek].
- **Światło.** W izo/3/4 światło dynamiczne (stożki, maski, cień pod ścianą, jak Pixel Noir, Teleglitch, ZERO Sievert) [wniosek, zob. 22c/31]. W niskim kącie (Beat Cop) noc to ten sam kadr przyciemniony plus ciepłe prostokąty okien: tanio, ale płasko [zrzut/wniosek].

## A. Bok: tylko nastrój, kolor, postacie (skrócone do 5 gier)

| Gra | Skala natywna | Postać (px) | Głowy | Co brać (nastrój/kolor/postać) | Czego nie przenosić |
|---|---|---|---|---|---|
| **NORCO** (2022) | niepewna, bardzo duże piksele [60] | n/d | realistyczne | kolumna dialogu z portretem, ciepłe okna kontra zimny granat, malarskie tła (wg człowieka najbliżej klimatu) [60/zrzut] | rzutu z boku, bardzo dużych pikseli |
| **Kathy Rain** (2016) | 320×240 ×3 [pomiar 0,99] | ok. 33 | ok. 6-6,5 | małe miasteczko, burza nad polem, ciepłe wnętrza, dorosłe twarze [zrzut] | kółek portretowych |
| **Lamplight City** (2018) | 640×400 ×2 [pomiar 1,00] (zrzut 1280×800) | ok. 110-120 [niska pewność] | ok. 7 | nocna ulica: latarnia gazowa, ciepłe witryny, mokry bruk [zrzut] | steampunku, dużych sprite'ów |
| **Gemini Rue** (2011) | 320×240 ×4 [pomiar 1,00] | ok. 40-50 | ok. 6,5-7 | noir, deszcz, stożek zimnego światła na mokrym bruku [zrzut] | sci-fi, 4:3 |
| **Lacuna** (2021) | 320×180 ×6 [pomiar 0,85 na 1 kadrze] | ok. 30-35 | ok. 6-7 | drobne sylwety w ciepłych, wielolampowych wnętrzach i ulicach [zrzut] | cyjanowego UI |

Usunięte ze skróconej listy (zostają zrzuty w katalogu, bez planszy): Technobabylon (neonowa paleta), Unavowed (duże sprite'y, różowe niebo), Whispers of a Machine (malarskie, chłodne), Katana ZERO (nasycone neony, akcja), Born Punk, Primordia (zbyt ciemne i sepiowe), The Last Door (×5, grube piksele), Kentucky Route Zero (**nie pixel art**, wektor). Thimbleweed Park tylko jako porównanie kreskówkowe: ok. 320×180 ×6 [niezweryfikowane], ok. 45-50 px, 4-5 głów, ładna noc z księżycem.

## Co z tego wynika (nie decyzja)

| Rola | Propozycje | Dlaczego |
|---|---|---|
| Rzut, proporcje, noir/miasto | **Pixel Noir**, **Death Trash** | dorosłe sylwety, noc, izo z wnętrzami osobno |
| Rzut oblique, proporcje | **Drova** | najbliższy układ 3/4, dorosłe sylwety, ale fantasy |
| Niski kąt / fasady | **Beat Cop** | jedyny dorosły przykład; proporcje uproszczone |
| Klasyczny CRPG, wnętrza i miasto na jednym rzucie | **Fallout 2**, **Arcanum** | siatka 8 kierunków i 7 głów; tylko jako wzorzec, nie technika |
| Nastrój, dialogi, kolor | **NORCO**, **Kathy Rain**, **Lamplight City**, **Blade Runner 1997**, **Disco Elysium** | światło, kolumny dialogu, malarska atmosfera |

## Ryzyka i luki

- Pixel Noir: skala natywna i kierunki niezmierzone (zrzuty 1286-1450 px); wysokość ok. 45-50 px to szacunek z dwukrotnie przeskalowanego arkusza.
- Wysokości i głowy: ±20-25%; Lamplight City, Unavowed, Whispers: wysokości 110-140 px mają niską pewność.
- Pre-renderowane gry (Fallout 2, Arcanum, Blade Runner) mają zrzuty o niskiej rozdzielczości lub UI; ich ocena światła jest powierzchowna.
- Eksploracja i kierunki to głównie wiedza ogólna [wtórne].
- Nie licencja: nie kopiujemy assetów, tylko oceniamy styl.

## Do decyzji człowieka

1. Czy sprawdzamy **Pixel Noir** (film/rozgrywka, skala, ciągłość mapy, kierunki) jako główną Kotwicę rzutu izo?
2. Czy akceptujemy sylwetkę ok. 35 px (Death Trash) z oszczędną twarzą, czy chcemy ok. 45-50 px z mimiką (więcej pracy)?
3. Czy zostajemy przy izo 2:1, czy szukamy dalej niskiego kąta (Beat Cop jest jedynym znalezionym)?
