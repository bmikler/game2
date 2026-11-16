---
id: 08
title: Niebo jako kopuła
labels: [ready-for-agent]
status: closed
assignee:
blocked_by: [06]
---

## Co zbudować

Niebo to kopuła zasłaniana przez wszystkie Przesłony; widoczność liczona przy wczytaniu narastająco przez kilka klatek (tysiące próbek), kolor i siła nieba oraz ambient to mnożniki ze Stanu doby. Profil nieba (miasto, wieś) z Otoczenia Lokacji.

## Kryteria akceptacji

- [x] Zasób profilu nieba, punkty startowe ze Ściągi (wieś: punkt startowy Claude'a).
- [x] Warstwa nieba raz przy wczytaniu, co klatkę tylko mnożnik.
- [x] Bramka: otwarta podłoga ma pełne niebo, wąski prześwit mniej, brak prążków.
- [x] Widok debug: kanały.

## Jak sprawdzić

Uliczka o zmierzchu i w pochmurnej godzinie: cień kamienic nie jest czarny, prześwit ciemniejszy niż otwarta ulica, bez pasów.

## Wykonanie (2026-11-16, Claude)

- **Profil nieba:** zasoby z ticketu 04 (`tuning/sky_city.tres`: noc #4b5590, 20 lx, poświata miasta `outdoor_night_lux` ze Ściągi; `tuning/sky_village.tres`: #26305c, 3 lx, punkt startowy Claude'a), wybierane w Otoczeniu Lokacji. Bez zmian.
- **Warstwa nieba** (`buffer/sky_layer.gd`, `sky_layer.gdshader`): udział kopuły widziany przez Odbiornik piksela, ważony cosinusem do normalnej (1 = otwarta podłoga, ½ = otwarta ściana). Tylko geometria, ta sama funkcja widoczności co słońce, zasłaniają wszystkie Bryły. Liczona raz po zbudowaniu Opisu sceny: **2048 kierunków w 32 klatkach** (64 na klatkę), stały zbiór (spirala Fibonacciego), więc bez szumu i bez migotania między wczytaniami. Przebiegi przeplatają się, każdy obejmuje całą kopułę: niebo widać od pierwszej klatki, potem tylko się wygładza. Warstwa trzyma liczby otwartych kierunków (całkowite sumują się w half-float dokładnie; ułamki gubiły do 3%).
- **Co klatkę tylko mnożnik:** bufor `E = ambient + niebo(kolor × natężenie ze Stanu doby) × udział + słońce`. Zmiana godziny nie przelicza warstwy.
- **Wspólne szukanie Odbiornika** (`buffer/receivers.gdshaderinc`): bufor i warstwa nieba zgadzają się co do piksela.
- **Widok debug „Kanały”** (F1): czerwony = słońce (kąt × widoczność), niebieski = udział nieba, zielony zostaje dla kanału sztucznego (ticket 13). Legenda pod wyborem widoku.
- **Zrzut:** odtwarzanie (`--z-zrzutu`) czeka na gotowe niebo.
- **Pomiar** (Uliczka, 15 Brył, bufor 4000 × 1536 px): niebo gotowe po ok. 1,9 s (34 klatki, ok. 55 ms na przebieg), potem 16 ms na klatkę. Mieści się w budżecie 2 s, na styk; kafle (spec) skrócą to później.
- **Testy:** `node tools/test.mjs`: 101 zielonych. Nowe bramki GPU: otwarta podłoga = 1, otwarta ściana = ½, wierzch Bryły = 1; prześwit 2 m między Bryłami 8 m ciemniejszy od wylotu, wylot ciemniejszy od ulicy, ale nie czarny (> 0,05); **bez prążków**: od środka prześwitu na ulicę udział tylko rośnie, a nachylenie zmienia się łagodnie (sprawdzone: przy 64 kierunkach bramka pada); warstwa budowana przez kilka klatek, nowa godzina jej nie przelicza, otwarta podłoga = ambient + niebo + słońce; widok Kanały. Dotychczasowe bramki słońca czytają teraz kanał słońca (niebo pod markizą zmienia luksy).
- **Uwagi, poza zakresem:** w Krzywych doby nie ma pochmurnej godziny (zachmurzenie 0 przez całą dobę, wzór dla krytyka); zamiast niej do sprawdzenia: godzina po zejściu słońca za dachy (17:48), kiedy świeci samo niebo.

## Jak sprawdzić (uzupełnienie)

`style-lab/street_engine.bat`, F1:
1. **17:48** (słońce już za dachami, świeci samo niebo), kamera przy prześwicie 2 m (start): fasady i ulica w cieniu nie są czarne, w prześwicie ciemniej niż na ulicy, ulica jaśnieje z odległością od kamienic, bez pasów.
2. To samo **18:36** (zmierzch) i przy przejściu w głąb (kamera w prawo, ok. x = 18 m): szersze przejście jaśniejsze niż wąski prześwit.
3. **12:30**, „Widok debug” → „Kanały”: ulica w cieniu kamienic niebieska, w prześwicie czerwono (słońce, mało nieba), na otwartej ulicy fiolet; niebieski gładko jaśnieje od fasad.

### Ocena człowieka

2026-11-16: „poza tym paskiem ze screena wszystko wygląda dobrze”. Pasek (zrzut `shots/engine/poligon_street__0747__…`, 07:47, przejście w głąb) to nie błąd silnika: słońce 7° od południowego wschodu przechodzi szczeliną ok. 0,7 m między tylnym narożnikiem środkowej kamienicy (x = 15, d = −18) a przednim narożnikiem oficyny na podwyższeniu (x = 12, d = −23). Sprawdzone promieniami punkt po punkcie w poprzek smugi: z lewej zasłania kamienica, z prawej oficyna, pośrodku otwarte. Znika, gdy słońce się podniesie.

### Plac (prośba człowieka, 2026-11-16)

„Zrób na mapie przerwę w budynkach (jakiś plac), żeby więcej słońca wchodziło przy południu na górze.” Zachodnia kamienica skrócona do 15 m (x −16…−1), **plac** 20 m (x −36…−16), dalej nowa kamienica do brzegu mapy (x −50…−36, 9,5 m); plac zamyka od południa kamienica 22 m od ulicy (d −40…−32, 9 m). W południe słońce oświetla cały plac i ulicę przed nim; o 9:30 skośny cień sąsiedniej kamienicy. Kamera: w lewo do x ≈ −26 m.

2026-11-16: „wszystko ok” (niebo, pasek wyjaśniony, plac).
