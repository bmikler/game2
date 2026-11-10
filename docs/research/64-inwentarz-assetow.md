# 64. Zgrubny inwentarz assetów gry ze scenariusza

Ticket: `docs/wayfinder/tickets/05-inwentarz-assetow.md`. Cel: widełki liczby assetów całej gry do planu Miesiąca produkcji.

**PRYWATNE.** Plik streszcza treść scenariusza „Druga”. Nie publikować, nie wysyłać do usług webowych. Research wyłącznie lokalny (bez wyszukiwań w sieci). Źródła: `druga.md`, `input-fixed.txt`, `docs/game1/wayfinder-map.md` (struktura świata: chodzone Centrum + Lokacje peryferyjne przez Mapę podróży; 4 dni gry; <10 kluczowych NPC i lokacji w game1, tu rozszerzone do całej „Drugiej”).

## Wynik w skrócie

| Klasa assetów | Jednostka | Min | Typowo | Max |
|---|---|---|---|---|
| Postacie | arkusze (postać × strój) | 32 | ~45 | 67 |
| Animacje podstawowe (idle + chód) | klipy (animacja × kierunek) | 190 | ~360 | 1070 |
| Animacje akcji (w tym konfrontacje) | klipy (× kierunek) | 44 | ~90 | 166 |
| Zwierzęta | klipy | 18 | ~50 | 130 |
| Pojazdy | sprite'y (z obrotami) | 8 | ~12 | 20 |
| Fasady i budynki z zewnątrz | sztuk | 16 | ~24 | 34 |
| Meble i rekwizyty wnętrz | unikalne (po reużyciu) | 120 | ~350 | 660 |
| Rekwizyty plenerowe | sztuk | 30 | ~50 | 80 |
| Teren (kafle + elementy: drzewa, skały, tory) | sztuk | 125 | ~290 | 560 |
| Widok za oknem | panoramy | 24 | ~45 | 70 |
| Portrety | obrazy | 60 | ~120 | 215 |
| Ikony Przedmiotów | sztuk | 25 | ~40 | 60 |
| Efekty i ozdoby atmosfery | animowane sprite'y | 15 | ~22 | 30 |
| **Razem (jednostki do wygenerowania, bez klatek)** | | **~700** | **~1500** | **~3200** |

Liczby to jednostki zamawiane/generowane, nie klatki. Najbardziej niepewne: liczba kierunków (3 vs 8) i liczba mebli. Klatek (animacje): rdzeń ok. 1000 (min) – 7500 (max); akcje ok. 180 – 1300.

## Założenia (do potwierdzenia przez człowieka)

1. Zakres = cała „Druga” wg scenariusza (11 miejsc śledztwa + 5 zakończeń), bez cutscenek (intro z autem, finał) i bez muzyki. Scena otwierająca na drodze: jako Lokacja „droga” liczona, sam komiks nie.
2. Świat jak w game1: chodzone Centrum (komisariat, bar, warsztat, biblioteka/ratusz, szpital, zabudowa statystów) i peryferia przez Mapę podróży (dom Madsenów, Stenberg, Hilda, bocznica, cegielnia, droga, las).
3. Płeć gracza stała (scenariusz: „dowolnej płci”; Krogg ma płeć przeciwną). Jeśli gracz wybiera płeć: dodać ok. +4 arkusze gracza i +2 Krogga (+ ich animacje, portrety).
4. Widok 3/4 jak w game1: ściany, podłogi i okna wnętrz rysowane kodem (nie liczone jako assety), meble generowane. Światło, cienie, smugi, kurz: kod.
5. Kierunki: min 3 wygenerowane (przód, tył, bok; reszta lustro), typowo 4, max 8. Animacje podstawowe: idle 4–6 klatek, chód 6–8 klatek. Akcje: 4–8 klatek, 1 kierunek (min) lub 2 (max).
6. Reużycie: meble/rekwizyty w wielu pomieszczeniach (krzesło, stół, szafa) liczone po deduplikacji (×0,5 w min, ×0,7 w max względem sumy brutto).
7. Brak walki (input): „konfrontacje” to dialog + animacje (wyciągnięcie broni, strzał w powietrze, szczekanie psa). Brak efektów koszmaru poza Piaskunem. Sceny konfrontacji mogą korzystać z dynamicznych portretów zamiast części animacji (to obniża liczbę klipów akcji).
8. Statyści z Rutynami (rdzeń: idle + chód); część siedząca (bar) ma tylko idle/siedzenie.
9. Tryb „typowo” = D=4, ok. 45 arkuszy, środek widełek dla pozostałych klas.

## 1. Postacie i warianty strojów

| Postać | Role / sceny | Stroje min | Stroje max | Uwagi o wariantach |
|---|---|---|---|---|
| Gracz (Badacz) | wszędzie | 2 | 4 | kurtka / bez (posterunek); max: strój nocny/domowy, ciężka zimowa |
| Branja (Odmieniec) | bar, dom, las, cegielnia | 2 | 3 | skórzana/punkowa; max: strój na wyjazd, impreza |
| Branja (prawdziwa) | droga, szpital, komisariat | 2 | 4 | halka + bose stopy + różowa wstążka; szpitalna koszula; koc; ubrana (po pożyczce) |
| Ingrid Madsen | dom, szpital, komisariat | 2 | 3 | dom; szpital (płaszcz); max: strój nocny (włamanie nocą) |
| Yngvar Madsen | wagon, bocznica | 1 | 1 | max: wersja uprzątnięta na spotkanie z rodziną (w „1” nie liczona) |
| Hjortur Stenberg | dom nad jeziorkiem | 1 | 2 | w domu / przy wędkowaniu |
| Jakub Marmol | bar, warsztat, las | 1 | 2 | skórzana kurtka; max: wariant „zaczarowany” / bez kurtki |
| Artur Marmol | warsztat | 1 | 2 | kombinezon; max: strój domowy |
| Krogg (Bjartar/Liv) | komisariat, wszędzie z graczem | 1 | 2 | mundur; max: cywilny / kurtka zimowa |
| Hilda Krogg | chatka, finał | 1 | 2 | max: strój wyjściowy (starszyzna) |
| dr Nielsen | szpital, komisariat | 1 | 2 | fartuch; max: płaszcz |
| Ødegård (bibliotekarz) | biblioteka | 1 | 1 | |
| Herbert Vest (barman) | bar | 1 | 1 | |
| Piaskun | efekt specjalny | 1 | 2 | max: wersja zjawy/duża |
| **Razem postaci nazwanych** | 14 | **18** | **31** | |

Statyści (arkusze):

| Grupa | Min | Max |
|---|---|---|
| Wokalistka (czerwona suknia) + zespół | 3 | 4 |
| Goście baru | 3 | 8 |
| Personel szpitala / posterunku | 1 | 3 |
| Starszyzna (zbiorowa interwencja przy komisariacie) | 3 | 8 |
| Bezdomni przy bocznicy | 2 | 4 |
| Młodzież z imprez (cegielnia; może zostać tylko śladami) | 0 | 3 |
| Przechodnie w Centrum | 2 | 6 |
| **Razem statystów** | **14** | **36** |

**Arkusze razem: 32–67** (typowo ~45; reużycie palet/ubrań statystów może obniżyć dolną granicę).

## 2. Animacje na postać

### 2a. Podstawowe (każdy arkusz)

| Element | Min | Typowo | Max |
|---|---|---|---|
| Animacje | idle, chód | idle, chód | idle, chód |
| Kierunki | 3 (+lustro) | 4 | 8 |
| Klipy (arkusze × kierunki × 2) | 32×3×2 = ~190 | 45×4×2 = 360 | 67×8×2 = ~1070 |
| Klatki (idle 4–6, chód 6–8) | ~1000 | ~2000 | ~7500 |

Bieg (Branja/Jakub ucieka, pościg w lesie): +1 klip na 2–5 postaci, ujęty w akcjach.

### 2b. Akcje i sceny konfrontacji (klipy, 1 kierunek min / 2 max)

| Postać | Akcje | Min | Max |
|---|---|---|---|
| Gracz | wyciągnięcie broni, celowanie, strzał w powietrze (rozbłysk), schowanie, klęk/przeszukanie, omdlenie, siad, rozmowa-gest; max: sen (leżenie), drżenie z zimna, podnoszenie, pukanie, dyktafon, latarka, papieros | 6 | 14 |
| Branja (Odmieniec) | gniewna gestykulacja, zamach/szarpnięcie, pije/pali przy stoliku, Oczarowanie Ofiary; max: bieg, wzdrygnięcie, siad | 4 | 8 |
| Branja (prawdziwa) | krzyk, kulenie się ze strachu, siad/leżenie (szpital); max: bieg, obrona | 4 | 7 |
| Jakub | siad zamroczony, szarpnięcie/pchnięcie; max: wsiadanie na motor, bieg, klęk | 3 | 6 |
| Ingrid | palenie, siad, płacz; max: szok, gest | 3 | 6 |
| Krogg | wyciągnięcie broni (starszyzna), pisanie na komputerze; max: gest, siad | 3 | 6 |
| Hilda | siad w fotelu, gest „wiedźmy”; max: chodzenie z laską, ogień | 2 | 4 |
| Yngvar | siad przy piecyku, mamrotanie; max: kulenie się, ucieczka | 2 | 4 |
| Hjortur | wędkowanie/siad, gest; max: tryumf („Wiedziałem!”) | 2 | 4 |
| Artur | praca pod autem, wycieranie rąk; max: gest | 2 | 3 |
| Nielsen | badanie, pisanie; max: gest | 2 | 3 |
| Ødegård | czytanie; max: sięganie po książkę | 1 | 2 |
| Vest | nalewanie, wycieranie szklanki; max: gest | 2 | 3 |
| Piaskun | pojawienie się/zniknięcie, dmuchnięcie piaskiem, powolny chód; max: szarpnięcie, spojrzenie | 4 | 7 |
| Scena baru | wokalistka śpiewa; zespół gra 1–3 pętle | 4 | 6 |
| **Razem klipów akcji** | | **44** | **83** |

Klipy × kierunki (1–2): **44–166**. Klatki: ~180 (4 kl. × 1 kierunek) do ~1300 (8 kl. × 2 kierunki).

## 3. Zwierzęta

| Zwierzę | Modeli min | Modeli max | Animacje | Kierunki | Klipy min–max |
|---|---|---|---|---|---|
| Zdziczałe psy (cegielnia; scena konfrontacji: szczekanie, warczenie, cofnięcie się po strzale) | 1 (recolor) | 2 | idle, chód, bieg, szczeka, warczy, ucieka | 3–8 | 18–96 |
| Zwierzęta ambientowe (wrony, kot, jeleń w lesie; ew. pies Stenberga) | 0 | 4 | 2 | 2–4 | 0–32 |
| **Razem** | | | | | **18–130** |

Szczekający pies z portretem/zbliżeniem w konfrontacji: opcjonalnie +1–2 portrety (liczone w sekcji 8).

## 4. Pojazdy (jako rekwizyty duże)

| Pojazd | Min | Max |
|---|---|---|
| Auto Badacza (z obrotami; wejście/wysiadanie bez animacji) | 1 | 1 |
| Czarna Honda Jakuba (parkowana + ew. jazda) | 1 | 2 |
| Radiowóz | 0 | 1 |
| Auta w warsztacie / na parkingu (opony, wraki) | 3 | 8 |
| Auta uliczne / tło | 1 | 4 |
| Wagony towarowe (bocznica) | 2 | 4 |
| Laweta / karetka | 0 | 2 |
| **Razem** | **8** | **22** (przyjęto ~20) |

## 5. Lokacje i budynki: wnętrza

| Lokacja | Pomieszczenia min | max | Rekwizytów/pomieszczenie | Brutto min | Brutto max |
|---|---|---|---|---|---|
| Komisariat (sala główna, gabinet, przesłuchań, archiwum-klitka; max: cela, socjalny, korytarz, WC) | 5 | 8 | 10–18 | 50 | 144 |
| Bar „Zombie Drink Machine” (sala + scena + zadymiona część; max: zaplecze, WC, magazyn) | 2 | 4 | 15–25 | 30 | 100 |
| Warsztat Marmolów + piętrowy dom obok (garaże z kanałami, pokój Jakuba; max: biuro, salon, kuchnia) | 2 | 6 | 12–15 | 25 | 90 |
| Biblioteka + ratusz (czytelnia, archiwum; max: biuro bibliotekarza, sala ratusza) | 2 | 4 | 10–20 | 20 | 80 |
| Szpital (sala chorych, gabinet; max: izba przyjęć, korytarz, prosektorium) | 3 | 6 | 8–15 | 24 | 90 |
| Dom Madsenów (parter + pokój Branji; max: sypialnia, łazienka, hall, kuchnia) | 3 | 7 | 12–20 | 36 | 140 |
| Dom Stenberga (izba z rybami; max: kuchnia, sypialnia) | 1 | 3 | 15–30 | 15 | 90 |
| Chatka Hildy (salon z kominkiem; max: kuchnia, sypialnia) | 1 | 3 | 12–20 | 12 | 60 |
| Wagon Yngvara | 1 | 1 | 15–25 | 15 | 25 |
| Cegielnia (hala ze ścianą-„drzwiami”; max: piec, wieża) | 1 | 3 | 8–15 | 8 | 45 |
| Dom Badacza (opcja spoza scenariusza, wg game1) | 0 | 3 | 10–15 | 0 | 45 |
| Świat koszmaru / lustrzane wnętrza (opcja: zakończenie wchodzące do krainy Piaskuna) | 0 | 2 | 10–15 | 0 | 30 |
| **Razem pomieszczeń** | **21** | **50** | | **235** | **939** |

Unikalne po deduplikacji (×0,5 min, ×0,7 max): **~120–660** (typowo ~350). Dodatkowo drzwi (6–10 typów) i okna/elementy okienne (6–12 typów) mimo rysowania ścian kodem: +12–22 sprite'y (nie wliczone do 120–660). Elementy specjalne scenariusza (poszlaki jako obiekty): pamiętnik pod materacem, plakaty punk (3–6), teczki i szafy archiwum, wypchane ryby (5–12), kominek, koza w wagonie, graffiti (3–5 plansz, w tym „drzwi” węglem).

## 6. Lokacje: plener i budynki z zewnątrz

### 6a. Sceny plenerowe

| Scena | Min | Max |
|---|---|---|
| Centrum Stoksjö (chodzone; ulica, rynek, parking warsztatu, wejścia) | 1 | 3 ekrany |
| Droga w kotlinie (scena otwierająca; rów, miejsce potrącenia) | 1 | 3 |
| Las / ślady / pościg (zaspy, ścieżki) | 2 | 5 |
| Bocznica z wagonami | 1 | 2 |
| Cegielnia i niecka ze skałkami | 1 | 2 |
| Dom Stenberga + jeziorko + pomost | 1 | 2 |
| Chatka Hildy (obrzeża) | 1 | 1 |
| Dom Madsenów (podwórko) | 1 | 1 |
| Mapa podróży (ekran + ikony miejsc 10–14) | 1 | 1 |
| **Razem scen plenerowych** | **9** | **20** |

### 6b. Fasady i budynki z zewnątrz

| Grupa | Min | Max | Uwagi |
|---|---|---|---|
| Budynki do wejścia (komisariat, bar, warsztat + dom, biblioteka/ratusz, szpital, dom Madsenów, Stenberg, Hilda, cegielnia, wagon) | 10 | 14 | 1 fasada na budynek; max: +boczna/tylna ściana i oddzielny dach/śnieg dla największych |
| Budynki tła Centrum (domy mieszkalne, sklep, kościół, stacja benzynowa, apteka, szkoła) | 6 | 20 | nie do wejścia, reużywalne moduły |
| **Razem** | **16** | **34** | okna z harmonogramem świateł: kod |

## 7. Teren i elementy plenerowe

| Element | Min | Max | Uwagi |
|---|---|---|---|
| Rodziny kafli (śnieg, ubity śnieg, asfalt, żwir, błoto, lód, drewno pomostu, podkłady torowe) | 6 | 12 | każda: 16 (min) – 47 (max) kafli z przejściami = 100–500 kafli |
| Kafle razem | 100 | 500 | do wygenerowania/złożenia kodem |
| Drzewa (świerk, sosna, brzoza, martwe, pień) + wariant śniegu + animacja wiatru (4–6 klatek) | 8 | 20 | |
| Krzaki, zaspy | 4 | 12 | |
| Skałki (cegielnia, niecka) | 3 | 6 | |
| Tory (prosty, łuk, zwrotnica), słupy | 4 | 8 | |
| Tło wzgórz/lasu (warstwy parallax) | 3 | 6 | per pora dnia 3–5 ujęte w „oknie” |
| Rów, jeziorko, pomost | 3 | 8 | |
| **Razem (kafle + elementy)** | **125** | **560** | |

Rekwizyty plenerowe (latarnie, ławki, śmietniki, płoty, znaki, skrzynki, beczki z ogniem, opony, graffiti, lawetki): **30–80**.

## 8. Widok za oknem

Panorama zgodna z fasadą na każdą porę dnia; ddodatkowo noc w mieście vs poza miastem (input).

| | Min | Max |
|---|---|---|
| Budynki z oknami na zewnątrz | 8 | 14 |
| Pory (dzień / zmierzch / noc; max 5 pór jak w game1) | 3 | 5 |
| **Panoramy** | **24** | **70** |

## 9. Portrety

| Element | Min | Max |
|---|---|---|
| Postacie mówiące (nazwane warianty strojów) | 18 | 31 |
| Wyrazy twarzy na portret | 3 | 6 |
| Portrety nazwane | 54 | 186 |
| Portrety dynamiczne (np. z wyciągniętą bronią: gracz, Krogg; pies w konfrontacji) | 2 | 8 |
| Portrety rodzajowe (statyści mówiący) | 4 | 20 |
| **Razem** | **60** | **215** |

Karty osób w Dzienniku korzystają z tych samych portretów. Dokumenty (Pomoce #1–#7, wycinki, pamiętnik) to grafika UI, poza tą klasą, ok. 7–12 arkuszy.

## 10. Ikony Przedmiotów, efekty i atmosfera

| Klasa | Min | Max | Uwagi |
|---|---|---|---|
| Ikony Przedmiotów/Dokumentów w plecaku (dyktafon, telefon, broń, notes, papierosy…) | 25 | 60 | wg input (przedmioty startowe) |
| Para z ust (pętla), dym papierosa, dym z kominów/komina cegielni | 4 | 8 | |
| Telewizor (4 ekrany w pętli) | 4 | 4 | świecący nocą |
| Ogień (kominek, koza, beczka) | 2 | 4 | |
| Neon baru, reflektory aut, odblaski szyb | 3 | 6 | część kodem |
| Efekt Piaskuna (piasek, srebrne drobiny) | 2 | 4 | w stylu koszmaru z game1 |
| **Razem efektów** | **15** | **26** | (~22 typowo, zaokrąglone w tabeli głównej do 15–30) |

## Wnioski dla planu Miesiąca produkcji

- Największy rozrzut dają: kierunki animacji (3 vs 8) i liczba mebli. Decyzja „4 kierunki + lustro, idle + chód dla wszystkich, akcje tylko 1 kierunek” prowadzi do ok. 1500 jednostek; to punkt odniesienia dla Przepisów.
- Przepis postaci z wariantami dominuje liczbą (arkusze + klipy + portrety ≈ 40–60 % jednostek). Przepis mebli i rekwizytów jest drugi.
- Jednostki do ograniczenia bez utraty fabuły: statyści (palety zamiast unikatów), opcjonalne lokacje (dom Badacza, krajina koszmaru), wyrazy portretów (3 zamiast 6).

## Ograniczenia

Szacunek z samego tekstu scenariusza, bez planu przebiegu gry (ticket mapy: fabuła, zakończenia, lista miejsc dostępnych z Centrum jeszcze niezaplanowane). Liczby pomieszczeń i rekwizytów to założenia typowe dla gier tego gatunku, nie wymierzone na rysunkach. Skala (jeden arkusz = jedna jednostka) nie odzwierciedla kosztu generatora (np. animacje w Pixellab liczone na kierunek).
