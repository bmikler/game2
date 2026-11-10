# Kandydaci na Kotwice stylu: pixel art 3/4 o realistyczniejszych proporcjach

Stan: 2026-11-08. Ticket 01 (wayfinder). Notatka robocza dla ticketu „Wybór Kotwic stylu”. Nic tu nie jest decyzją. Nie powtarzam `54-chef-rpg-styl.md` (Chef RPG: kafel 24 px, postać ok. 48 px, natywnie 640×360, ×3/×4) ani `51*.md`.

Plansza zrzutów (lokalnie, nie publikować): `docs/research/60-assets/plansza.html` (otworzyć w przeglądarce z dysku). Wszystkie zrzuty to oficjalne screenshoty ze sklepu Steam (API `store.steampowered.com/api/appdetails`), tylko do prywatnej oceny. Pliki `60-assets/<gra>-<id>.jpg`.

Oznaczenia: **[zweryfikowane]** opis twórców/sklepu (Steam API) lub pomiar na pliku; **[pomiar]** skrypt na JPEG-u zrzutu; **[wtórne]**; **[niezweryfikowane]**; **[wniosek]** moja interpretacja zrzutu.

## TL;DR

1. **Żadna gra nie spełnia wszystkich kryteriów naraz** (3/4 + realistyczne proporcje + zima/miasteczko/noir + mocne światło) [wniosek]. Pasuje się dobierać: jedna Kotwica na *rzut i proporcje*, druga na *światło i atmosferę*, trzecia (opcjonalnie) na *detal postaci i portrety/UI*.
2. **Najlepsze na rzut i proporcje:** **Death Trash** (iso, dorosłe proporcje, ciemno, UI), **Stoneshard** (3/4 z góry, najbardziej „realistyczne” sylwetki, małe, brud i faktura, ×2 z 960×540), **Eastward** (3/4 oblique, szczegółowe, ale proporcje „komiksowe” ok. 3,5 głowy).
3. **Najlepsze na światło i atmosferę:** **REPLACED** i **Octopath Traveler** (światło + głębia ostrości na pikselowych sprite'ach, ale to efekty 3D/post-process, nie sam pixel art), **NORCO** i **Eastward** (kolorowe światło i zmiana barwy w cieniu bezpośrednio na pikselach), **Signalis** odpada (3D, nie pixel art).
4. **Odrzucone jako Kotwice rzutu (zły widok):** REPLACED, NORCO, A Space for the Unbound (widok z boku / side-scroll). Zostają jako referencje do światła, portretów i oprawy dialogów.
5. **Pułapka dla wszystkich kandydatów:** żaden nie ma zimy i miasteczka w noir; do tego trzeba je „dosumować” z dwóch gier [wniosek].

## Metoda

- Zrzuty: 1920×1080 (Steam API `screenshots[].path_full`), 6 na grę, obejrzane wzrokowo [zweryfikowane].
- Skala natywna: skrypt Node (`jpeg-js`, lokalnie w katalogu scratch) szukał krawędzi poziomych i pionowych i liczył, przy jakim `k` (2..8 px) krawędzie koncentrują się na jednej reszcie `x mod k`. Wynik ≥0,85 = pewne ×k. Kadry z efektami (bloom, winieta, rozmycie) dają niski wynik, bo JPEG i filtry rozmywają krawędzie [pomiar].
- Wysokość postaci = wysokość sprite'a na zrzucie ÷ skala; mierzone **na oko** z zrzutu, dokładność ok. ±15% [wniosek]. Liczby kolorów nie mierzyłem (JPEG zawyża): tylko wnioski z wyglądu.
- Nie ściągałem gier ani spritesheetów; wartości „natywne” to estymaty z zrzutów, nie dane twórców, chyba że zaznaczono.

## Tabela zbiorcza

| Gra | Rok | Widok | Skala (natywna) | Postać (px natyw., ok.) | Proporcje | Kontur | Wniosek |
|---|---|---|---|---|---|---|---|
| Death Trash | 2021 | iso 2:1, dół ekranu, dorośli | ok. ×4 (480×270) [pomiar, 0,65] | ok. 35 | ok. 5-6 głów, realistyczne | brak ciągłego, ciemny, miękki | **kandydat: rzut + nastrój** |
| Stoneshard | 2020 | 3/4 z góry | ×2 (960×540) [pomiar, 0,95] | ok. 32 | ok. 4,5-5 głów, realistyczne | selektywny ciemny | **kandydat: proporcje + faktura** |
| Eastward | 2021 | 3/4 oblique | ×3 (640×360) [pomiar, 0,91] | ok. 43 | ok. 3,5 głowy, komiksowe | selektywny kolorowy | **kandydat: szczegół + światło** |
| Sea of Stars | 2023 | 3/4 z góry | ×3 (640×360) [pomiar, 1,00] | ok. 28 | ok. 3 głowy, chibi | selektywny ciemny | tylko światło/woda/śnieg; za infantylne |
| Octopath Traveler | 2018/19 | 3/4 + tilt-shift 3D | nie całkowita [pomiar] | ok. 30-32 [niezweryfikowane] | ok. 3-4 głowy | brak, z cieniowaniem | światło i DoF jako wzorzec nastroju |
| Hyper Light Drifter | 2016 | 3/4 z góry | ×4 (480×270) [pomiar, 1,00] | ok. 22 | stylizowane | brak (bezkonturowy) | paleta i światło, nie proporcje |
| Unsighted | 2021 | 3/4 | niepewna | ok. 40 [niezweryfikowane] | ok. 4 głowy | selektywny | UI/portret (zrzut z menu), słabo na rzut |
| Chef RPG | 2024 | 3/4 oblique | ×3 (640×360) [`54`] | ok. 48 | chibi | selektywny kolorowy | tylko układ (jak w tickecie) |
| Signalis | 2022 | iso 3D, nie pixel art | n/d | n/d | realistyczne | n/d | odpada, ale zob. niżej |
| REPLACED | 2026 | side-scroll 2.5D | n/d | n/d | realistyczne | n/d | odpada jako rzut; wzorzec światła |
| NORCO | 2022 | widok z boku, malarski pixel art | niepewna | n/d | realistyczne | brak | portrety, UI dialogów, kolor |
| A Space for the Unbound | 2023 | side-view | niepewna | n/d | ok. 4-5 głów | selektywny | detal małego miasteczka, dzień |

## Karty gier

### 1. Death Trash (Crafting Legends, 2021) [zweryfikowane: Steam]
- **Zrzuty:** `deathtrash-1.jpg` (menu postaci, nocny kadr), `deathtrash-3.jpg` (dialog, organiczny potwór).
- **Rzut:** izometria 2:1 z kafli ukośnych [zrzut], więc **nie to samo co 3/4 oblique** z `54`. Gdybyśmy zostali przy kamerze „oblique”, bierzemy z niej tylko nastrój i bryły [wniosek].
- **Skala i postać:** ×4 (480×270) słabo potwierdzone (0,65; 2:0,76, 4:0,65). Postać ok. 140 px na 1920 ≈ 35 px natywnych [pomiar/wniosek].
- **Proporcje:** dorosłe, ok. 5-6 głów, bez „chibi”.
- **Kontur:** brak ciągłego czarnego; sylwety odcinają się światłem i ciemnym tłem.
- **Światło:** prawie wszystko to ciemność z jednym lub dwoma punktami zimnego światła (lampa cyjan, twarz) i miękka winieta [zrzut]. Kolor akcentowy rdzawy/czerwony w UI.
- **Nie przenosić:** izometrii (jeśli wybierzemy oblique), post-apo dystopii, krwi, organicznego horroru.

### 2. Stoneshard (Ink Stains Games, 2020) [zweryfikowane: Steam]
- **Zrzuty:** `stoneshard-1.jpg` (jaskinia, bardzo ciemna z pochodniami), `stoneshard-3.jpg` (wioska za dnia, ekwipunek).
- **Rzut:** 3/4 z góry z lekkim skrótem; budynki pokazane dachem i ścianą [zrzut].
- **Skala i postać:** ×2 (960×540) [pomiar, 0,95]. Postać ok. 65 px na 1920 ≈ 32 px natywne; w kadrze „realistyczny” rycerz w hełmie, kilka głów wysokości.
- **Proporcje:** najbardziej realistyczne z całej listy [wniosek]; krępe, zbrojne sylwety.
- **Kontur:** selektywny, ciemny; wewnątrz detali faktury (deski, mech, bruk).
- **Światło:** wyraźne koło światła pochodni na czarnym tle (zasięg + miękka krawędź), bez kolorów poza ciepłym żółtym [zrzut].
- **Atmosfera:** brud, mech, zniszczone drewno; mało koloru. Zimy nie widziałem na zrzutach [niezweryfikowane, w grze są biomy śnieżne według opisów, nie sprawdzałem źródła].
- **Nie przenosić:** średniowiecznego fantasy, bardzo drobnych (32 px) postaci, jeśli chcemy czytelną mimikę.
- **Wniosek:** dobra Kotwica na *proporcje i nieinfantylność* przy skali, która mieści się w 960×540.

### 3. Eastward (Pixpil, 2021) [zweryfikowane: Steam]
- **Zrzuty:** `eastward-3.jpg` (targ, dzień), `eastward-1.jpg` (las, światło przez liście), `eastward-0.jpg`.
- **Rzut:** 3/4 oblique, budynki widziane frontem z dachem z góry [zrzut].
- **Skala i postać:** ×3 (640×360) [pomiar, 0,91/0,88]. Postać ok. 130 px na 1920 ≈ 43 px natywne.
- **Proporcje:** komiksowe, ok. 3,5 głowy; twarze mają mimikę, rekwizyty i ubrania szczegółowe.
- **Kontur:** selektywny, kolorowy (ciemniejszy odcień koloru wypełnienia).
- **Światło i atmosfera:** zmiana barwy w cieniu, plamy światła przez liście, winieta, delikatna siatka scanlines na kadrze dialogu; paleta mocno sezonowa (zielone, żółte, pomarańcz) [zrzut]. Dla nas ważne: **nocne i zmierzchowe sceny są w innych barwach, nie tylko ciemniejsze** [wniosek].
- **Nie przenosić:** żywej, „landrynkowej” palety dziennej, 2-3 głowy w sylwetach.

### 4. Sea of Stars (Sabotage, 2023) [zweryfikowane: Steam]
- **Zrzuty:** `seaofstars-4.jpg`, `seaofstars-1.jpg`.
- **Rzut:** 3/4 z góry, skały i drzewa są wolumetryczne dzięki cieniowaniu na stronie [zrzut].
- **Skala i postać:** ×3 (640×360) [pomiar, 1,00]. Postać ok. 85 px na 1920 ≈ 28 px natywnych.
- **Proporcje:** chibi (ok. 3 głowy).
- **Światło:** Sabotage opisuje „custom-made render pipeline” [zweryfikowane: Steam] (światła i cienie jako warstwa), a nie wymalowane piksele [wniosek]; woda i cienie kolorowe i głębokie.
- **Nie przenosić:** infantylnych proporcji, zasady „wszystko kolorowe”. Przydatne jako wzór **jakości terenu** (woda, skały).

### 5. Octopath Traveler (Square Enix / Acquire, 2018 konsole, 2019 PC) [zweryfikowane: Steam]
- **Zrzuty:** `octopath-1.jpg` (miasto nocą, tilt-shift), `octopath-3.jpg` (walka).
- **Rzut:** świat 3D, sprite'y 2D jako billboardy; Steam: „visuals inspired by retro 2D RPGs with beautiful realistic elements set in a 3D world” [zweryfikowane]. Nazwa „HD-2D” jest oficjalna w materiałach Square Enix [wtórne, nie sprawdzałem źródła pierwotnego].
- **Skala:** nie całkowita (pomiar nie daje stabilnego k), bo kamera i sprite'y żyją w 3D z perspektywą [pomiar]. Postać w mieście ok. 90 px na 1920 [zrzut].
- **Światło:** pochodnie z halo, długi cień pod światło z lewej, głębia ostrości (blur przy krawędziach), mgła i kurz [zrzut]. **Prawie cała „atmosfera” pochodzi z efektów 3D/post-process.**
- **Nie przenosić:** kamery 3D z perspektywą i rozmyciem (nie da się w czystym Godot 2D bez shaderów; da się z shaderem DoF [wniosek]). Wzorcem jest *efekt*, nie technika.

### 6. Hyper Light Drifter (Heart Machine, 2016) [zweryfikowane: Steam]
- **Zrzuty:** `hld-1.jpg`, `hld-3.jpg`.
- **Skala:** ×4 (480×270) [pomiar, 1,00]; postać ok. 22 px natywnych [wniosek].
- **Kontur:** brak; kształty z plam koloru i zmiany jasności.
- **Światło:** neon (róż, cyjan, zieleń) na granatowym tle, gradienty jako dithering/poziomy koloru [zrzut].
- **Nie przenosić:** nasyconych neonów i „gry z kolorem”; za proste dla dorosłych postaci. Wzorcem jest *ekonomia detalu*.

### 7. Chef RPG (World 2 Studio, 2024) — tylko układ
Zob. `54-chef-rpg-styl.md`. Zrzut `chefrpg-1.jpg` (lokal): chibi 2 kafle, meble osiowe, zielone żywopłoty oddzielają strefy. Nie bierzemy kolorystyki ani proporcji.

### 8. Unsighted (Studio Pixel Punk, 2021) [zweryfikowane: Steam]
- **Zrzuty:** `unsighted-1.jpg` (menu postaci) — to jedyny użyteczny kadr z tej gry, reszta niewidziana (tylko pobrane do `60-assets/`). Pokazuje **portret i UI o dorosłej, szczegółowej oprawie** [zrzut].
- Skala niepewna; **nie oceniam rzutu**, bo nie obejrzałem kadrów z gry [niezweryfikowane].

### 9. REPLACED (Sad Cat Studios, 14.04.2026) [zweryfikowane: Steam]
- **Zrzuty:** `replaced-1.jpg` (hala, bossfight), `replaced-4.jpg` (rozmyty plan).
- Steam: „signature 2.5D style: best in class pixel art enhanced by modern depth-of-field, lighting, and cinematic visual effects” [zweryfikowane]. Widok: **side-scroll**, nie 3/4.
- **Światło/atmosfera (do podpatrzenia):** ciepłe źródła punktowe z bloomem + zimne tło zielono-niebieskie, mgła wolumetryczna, bardzo mocne DoF i ziarno; sprite'y z ciemnym konturem na tle [zrzut]. UI w jednym kolorze (pomarańcz).
- **Nie przenosić:** rzutu bocznego, post-procesu 3D, 3D tła pod sprite'ami (zbyt drogie w produkcji dla nas [wniosek]).

### 10. NORCO (Geography of Robots, 2022) [zweryfikowane: Steam]
- **Zrzuty:** `norco-1.jpg` (ulica, noc, dialog + portret), `norco-3.jpg` (podwórko o zmierzchu).
- Steam: „painterly and cinematic pixel art” [zweryfikowane]. Widok boczny/point-and-click, nie 3/4.
- **Do podpatrzenia:** **kolumna dialogu z portretem** z lewej, ciemna ramka, czcionka szeryfowa; tła z mocnym kontrastem ciepłe okna kontra zimny granat [zrzut]. Dobre do ticketu „oprawa dialogów”.
- **Nie przenosić:** widoku z boku, bardzo dużych pikseli (ok. 5-6 px na 1920) [wniosek z zrzutu].

### 11. A Space for the Unbound (Mojiken, 2023) [zweryfikowane: Steam]
- **Zrzuty:** `spaceunbound-1.jpg`, `spaceunbound-3.jpg`. Widok z boku, dzień/zmrok, bardzo szczegółowe małe miasteczko (Indonezja lat 90.) [zrzut].
- **Do podpatrzenia:** gęstość drobnych rekwizytów (kable, bramy, rośliny), kolor cienia (niebiesko-zielony w kolorze nieba).
- Skala nie zmierzona (zrzut 1408×792) [niezweryfikowane].

### 12. Signalis (rose-engine, 2022) — odrzucona
Steam: „fluid 3D character animations, dynamic lights and shadows, and complex transparency effects” [zweryfikowane]. To **grafika 3D z pikselowanym renderem**, nie pixel art sprite'ów; zrzut `signalis-3.jpg` pokazuje jednak dobrze, jak wygląda **nocna ciemność z jednym światłem i długim cieniem** w widoku z góry [zrzut]. Ticket zalecał ją jako startowy kandydat; zapis tutaj to wynik sprawdzenia.

### Odrzucone przy wstępnym przeglądzie (nie oceniałem szczegółowo)
- **Backbone** (EggNut, 2021): noir w Vancouver, ale side-scroller z antropomorficznymi zwierzętami [wtórne: PC Gamer, Gematsu w wyszukiwaniu]; nie znalazłem go w Steam API przez wyszukiwarkę.
- **Darkwood** (hand-drawn, nie pixel art) — nie sprawdzałem.

## Co z tego wynika dla wyboru Kotwic

| Rola | Propozycja | Dlaczego |
|---|---|---|
| Rzut, skala, proporcje | **Stoneshard** lub **Death Trash** | dorosłe, nieinfantylne sylwety w małym rozmiarze |
| Szczegół postaci, mimika | **Eastward** | czytelna twarz w 3/4 przy 43 px, ale chibi do przerobienia |
| Światło, noc, atmosfera | **Octopath** (efekt) + **REPLACED** (kontrast ciepło/zimno) | ciepłe punkty światła w zimnej ciemności |
| Dialog, portret, UI | **NORCO** | kolumna z portretem, ciemna oprawa |

[wniosek] Zima i śnieg: **żaden kandydat nie jest Kotwicą na śnieg**; Sea of Stars daje wzór wody i skał w niebieskim cieniu, Eastward wzór plam światła i cienia. Ten brak trzeba rozwiązać na Poligonie Ulica.

## Ryzyka i luki
- Nie zmierzono liczby kolorów (JPEG). Do ewentualnego pomiaru potrzebne PNG-i (np. z własnej kopii gry) [niezweryfikowane].
- Wysokości postaci i proporcje głów to oceny z zrzutów (±15%).
- Nie sprawdzano licencji na wykorzystanie stylu: styl nie podlega prawu autorskiemu, ale nie kopiujemy konkretnych assetów [wniosek, nie porada prawna].
- Zrzuty to materiały reklamowe i mogą być retuszowane (UI, kadr).

## Do decyzji człowieka (ticket Wybór Kotwic stylu)
1. Czy wybieramy Kotwicę rzutu **oblique** (Eastward/Chef RPG) czy **izo** (Death Trash)?
2. Czy akceptujemy 3 Kotwice z podziałem ról (rzut+proporcje, światło, dialogi/UI), skoro żadna sama nie pasuje?
3. Czy sprawdzamy dodatkowo Stoneshard w zimowym biomie (zrzuty/film) przed zamknięciem?
