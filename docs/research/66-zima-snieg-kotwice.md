# Zima i śnieg w pixel arcie 3/4: kandydaci na Kotwicę

Stan: 2026-11-08. Uzupełnienie `60-kotwice-stylu-kandydaci.md` (luka: „żaden kandydat nie jest Kotwicą na śnieg”). Research bez decyzji. Plansza lokalna (nie publikować): `docs/research/66-assets/plansza.html`; zrzuty `66-assets/<gra>-<n>.jpg`, gdzie `n` = indeks zrzutu w Steam API (`store.steampowered.com/api/appdetails`, `screenshots[].path_full`). Tylko do prywatnej oceny.

Oznaczenia jak w 60: **[zweryfikowane]** (Steam API, oficjalne strony, pomiar), **[pomiar]** (skrypt na JPEG-u), **[zrzut]** (widoczne na zrzucie), **[wtórne]**, **[wniosek]**, **[niezweryfikowane]**.

## TL;DR

1. **Stoneshard: brak śniegu w 20 oficjalnych zrzutach Steam** [zweryfikowane]. Wiki (Biomes & Weather) wymienia Field, Forest, Steppe, Coast, Mountains, Sea i Swamp („in development”), a o zimie tylko zdanie „the north will be cold forests” [zweryfikowane]. Devlog #35 zapowiadał biom Taiga (śnieżny wariant pinewoods), ale nie potwierdziłem, że jest w grze [wtórne: GameBanshee]. **Nie ma kadru do pobrania.**
2. **Eastward: brak śniegu w 11 zrzutach Steam** [zweryfikowane]. Wyszukiwanie w wiki i w sieci nie dało śnieżnej lokacji [niezweryfikowane: nie można wykluczyć].
3. **Najlepszy wzorzec „śnieg + 3/4 + nieinfantylnie”: CrossCode** (dzień, rzemiosło śniegu w czystych pikselach) i **Octopath Traveler** (noc na śniegu, ale HD-2D = efekty 3D) [wniosek].
4. **Noc na śniegu w czystym pixel arcie 3/4 z dorosłymi postaciami: nie znalazłem** w zrzutach ~35 sprawdzonych gier [wniosek]. Najbliżej: CrossCode (lodowa jaskinia, zimne światło), Coromon (latarnie na śniegu, ale chibi), Octopath (3D).
5. **Wspólne rzemiosło:** cień na śniegu jest niebieski/lawendowy, nie szary; śnieg to prawie biel + 1-2 błękity; ciemny kontur zostaje na drzewach i obiektach, krawędź samego śniegu jest bez konturu lub w jaśniejszym obrysie [zrzut].

## Metoda

- Dla ~35 gier pobrano miniatury wszystkich zrzutów Steam i obejrzano plansze zbiorcze. Pełne pliki do `66-assets/` tylko dla kadrów ze śniegiem (1920×1080; CrossCode: 1136×640, tak go serwuje Steam) [zweryfikowane].
- Skala natywna: skrypt Node (`jpeg-js`, scratch) liczył koncentrację krawędzi pionowych na jednej reszcie `x mod k`, jak w 60. ≥0,9 = pewne ×k [pomiar].
- Kolor śniegu: kwantyle luminancji (p10/p50/p90) pikseli „chłodnych jasnych”. Metoda zanieczyszczona (łapie też niebo, wodę, lód), tylko orientacja [pomiar przybliżony].
- Wysokość postaci i proporcje: na oko, ±15% [wniosek].

## Stoneshard i Eastward

| Gra | Zimowe/śnieżne lokacje | Zrzuty ze śniegiem | Źródło |
|---|---|---|---|
| Stoneshard (20 zrzutów) | Brak w zrzutach. Wiki: „north will be cold forests”; Taiga zapowiedziana w devlogu #35 [wtórne] | brak | Steam API; stoneshard.com/wiki/Biomes_&_Weather; gamebanshee.com/k4hd6 |
| Eastward (11 zrzutów) | Brak w zrzutach; fandom wiki: brak trafień na „snow/frozen” [niezweryfikowane] | brak | Steam API; eastward.fandom.com (API search) |

Reszta listy ze zrzutów Steam: Children of Morta (13), Moonlighter (16), Death Trash (12), Graveyard Keeper (11), Core Keeper (16), Nobody Saves the World (10), Crossing Souls (14), Pathway (12): **bez śniegu** [zweryfikowane]. Pinstripe (11): jest śnieg i noc, ale widok z boku i malarska grafika, nie pixel art. The Last Night: side-scroll, szczegółowo nie sprawdzano. Kynseed (28) i Sun Haven (26): są zimowe kadry.

## Kandydaci ze śniegiem

3/4 z góry (oblique), o ile nie zaznaczono inaczej.

| Gra | Rok | Skala natywna | Postać (px natyw.) | Proporcje | Śnieg | Wniosek |
|---|---|---|---|---|---|---|
| **CrossCode** (Radical Fish) | 2018 | **568×320** (×2 z 1136×640) [pomiar 1,00] | ok. 24-26 | ok. 4-5 głów | dzień; jaskinia lodowa; noc w deszczu | najlepsze rzemiosło |
| **Octopath Traveler** | 2018/19 | nie całkowita (HD-2D) [pomiar] | ok. 30-35 [niezweryfikowane] | ok. 3,5-4 głowy | **noc + opad** | najlepsza noc, ale efekty 3D |
| **Sea of Stars** | 2023 | 640×360 (×3) [pomiar 1,00] | ok. 28 | ok. 3 głowy | dzień, jaskinia | czyste piksele, chibi |
| **Stardew Valley** | 2016 | 480×270 (×4) [pomiar 0,91] | ok. 25 | ok. 3 głowy | dzień | kanon zimy, infantylny |
| **Sun Haven** | 2023 | 960×540 (×2) [pomiar 0,99] | ok. 35 | ok. 3,5 głowy, anime | dzień, miasteczko | gęste miasteczko zimą |
| **Kynseed** | 2022 | 640×360 (×3) [pomiar 0,96] | ok. 33 | ok. 3-4 głowy | dzień, cienka warstwa | wzór cienkiego śniegu |
| **Coromon** | 2022 | 480×270 (×4) [pomiar 1,00, ale 2:1,00] | ok. 14 | chibi | opad + latarnie | światło i opad, infantylny |
| **Heroes of Hammerwatch** | 2018 | 480×270 (×4) [pomiar 0,93] | ok. 14-16 | małe sylwety | dzień, plamy | wzór patchy snow |

### 1. CrossCode [Steam, zrzut]
- **Kadry:** `crosscode-16.jpg` (śnieżne miasteczko, dzień), `crosscode-10.jpg` (lodowa jaskinia, zimne światło), `crosscode-5.jpg` (noc w deszczu, nie śnieg).
- **Widok:** oblique 3/4, dachy z góry, fasady od frontu [zrzut].
- **Śnieg:** płaty prawie białe z lawendowo-niebieskim cieniem (p10 ok. `#8998b9`, światło `#d3ded9`) [pomiar przybliżony]. Czapy na dachach jako „bloby” bez konturu; kolory dachu i ściany zostają widoczne, śnieg leży plamami, nie jako pełna pokrywa. Sople na okapach, śnieg na gałęziach jako białe kępy na ciemnozielonym [zrzut].
- **Opad:** rzadkie pojedyncze białe piksele plus kilka płatków 2×2 w kształcie gwiazdki, bez rozmycia [zrzut].
- **Kontur na śniegu:** krawędź śniegu bez konturu; ciemny kontur tylko na obiektach (drzewa, rury) [zrzut].
- **Ślady:** nie widziałem [niezweryfikowane].
- **Noc:** lodowa jaskinia (10): niebieskie tło (`#486d8c` w cieniu), źródła cyjanowe jako rozmyte halo i białe iskry. To jedyny kadr „zimno + ciemno” w czystym pixel arcie. Noc w deszczu (5): ciepłe okna kontra szaro-brązowa mokra kostka z odbiciami [zrzut].

### 2. Octopath Traveler [Steam; nazwa HD-2D wg Square Enix, wtórne]
- **Kadr:** `octopath-10.jpg` (katedra nocą, śnieg, pochodnie).
- **Widok:** świat 3D, sprite'y jako billboardy, tilt-shift [zrzut].
- **Śnieg:** zaspy jako gładkie niebiesko-fioletowe gradienty (p10 `#596780`, p50 `#849bb9`) [pomiar przybliżony]. Płomienie pomarańczowe na niebieskim tle (kontrast ciepło/zimno). Płatki jako rozmyte bokeh, duże bliżej kamery [zrzut].
- **Noc na śniegu:** tak, najlepszy kadr. Okna jasnobiałe, śnieg odbija niebieskie światło; postacie to małe sprite'y, ok. 3,5-4 głowy, dorośli.
- **Uwaga:** efekt to DoF, bloom i cząsteczki 3D, nie sam pixel art [wniosek].

### 3. Sea of Stars [Steam]
- **Kadr:** `seaofstars-0.jpg` (walka w śnieżnej jaskini).
- Śnieg lekko niebieski, cień pod postaciami lawendowo-niebieski; ciemnofioletowe skały z jasnymi kępami śniegu na szczytach; sosny z białymi kępami i ciemnym konturem; opad to pojedyncze białe piksele [zrzut]. Chibi (ok. 3 głowy), więc tylko rzemiosło śniegu.

### 4. Stardew Valley [Steam]
- **Kadr:** `stardew-11.jpg` (zima, dzień).
- Śnieg bardzo jasny błękit (`#c1f2fc`..`#fcfefe`), krawędź śniegu w jaśniejszym cyjanowym obrysie zamiast ciemnego konturu; cienie drzew lawendowo-szare; krzaki ciemnoturkusowe [zrzut]. Proporcje infantylne.

### 5. Sun Haven [Steam]
- **Kadr:** `sunhaven-2.jpg` (miasteczko zimą, dzień).
- Śnieg prawie biały, cienie lawendowo-szare; chmurkowe plamy śniegu na kostce, sosny z jasnoniebieskimi kępami, dachy bez czap śniegu [zrzut]. Latarnie ciepłe (pomarańcz) na jasnym tle. Postacie anime, infantylne.

### 6. Kynseed [Steam]
- **Kadr:** `kynseed-7.jpg`.
- Cienka warstwa: lila i jasnoniebieski z białymi „kryształkami” rozproszonymi na ziemi; nie zakrywa faktury skał [zrzut]. Cień lila (`#9678c0`) [pomiar przybliżony].

### 7. Coromon [Steam]
- **Kadr:** `coromon-2.jpg` (śnieg, opad, latarnie).
- Opad w regularnej siatce białych kropek (mało naturalny); nasycone niebieskie skały z ciemnym konturem; sosny z białymi kępami; latarnie z miękkim żółtozielonym halo na zimnym tle [zrzut]. Chibi, użyteczny tylko jako wzorzec punktowego światła na śniegu.

### 8. Heroes of Hammerwatch [Steam]
- **Kadr:** `hammerwatch-5.jpg` (plamy śniegu pod sosnami, miasto).
- Nieregularne płaty bieli na zielono-brązowej ziemi; sosny z lekką bielą, bez pełnej pokrywy; ciepłe wnętrza z ogniem; cienie ciemne [zrzut]. Sylwety ok. 14 px, bez znaczenia dla proporcji.

## Odrzucone
- **Pinstripe** (zima w piekle, noc): widok z boku, nie pixel art.
- **Hyper Light Drifter**: brak śniegu na zrzutach Steam.
- **Death Trash, Graveyard Keeper, Moonlighter, Children of Morta, Core Keeper, Pathway, Crossing Souls, Nobody Saves the World**: brak śniegu na zrzutach Steam.

## Wzorce rzemieślnicze (wniosek z kadrów)

| Element | Obserwacja |
|---|---|
| Kolor cienia na śniegu | niebieski/lawendowy (`#8998b9`, `#9678c0`, `#8f9ec7`), nie neutralny szary [pomiar przybliżony] |
| Kolor światła śniegu | nie czysta biel, raczej `#d3ded9`..`#e9f1ef` [pomiar przybliżony] |
| Kontur | brak na śniegu; ciemny na drzewach i obiektach; Stardew: jasny cyjanowy obrys |
| Bryły ze śniegiem | czapy „blobami”, nieregularny brzeg; kolor podłoża prześwituje (CrossCode, Kynseed, Hammerwatch) |
| Opad | rzadkie kropki 1-2 px, czasem 2×2 gwiazdki (CrossCode, Sea of Stars); w HD-2D rozmyte bokeh (Octopath) |
| Ślady, koleiny | nie widziałem na żadnym zrzucie [niezweryfikowane] |
| Światło w nocy | ciepłe halo na niebieskim tle (Octopath, Coromon) |

## Ryzyka i luki
- Zrzuty to materiały reklamowe; zimowa noc w czystym pixel arcie mogła istnieć w grach bez trafienia do zrzutów.
- Nie oglądałem filmów ani trailerów (Stoneshard Taiga, śnieżne miejsca Eastward). Wymagają wideo albo kopii gry.
- Kolory ze zrzutów JPEG: orientacyjne. Skale i wysokości postaci: estymaty (±15%).

## Do decyzji człowieka
1. Czy Octopath jest akceptowalną Kotwicą *nocy na śniegu* mimo 3D, czy szukamy czystego pixel artu (trailery Stoneshard i CrossCode)?
2. Czy CrossCode (568×320, ok. 4-5 głów) wystarcza jako Kotwica *rzemiosła śniegu w dzień*?
3. Czy robimy własny test „śnieg + noc” (kafel + sprite) na Poligonie Ulica zamiast dalszego szukania?
