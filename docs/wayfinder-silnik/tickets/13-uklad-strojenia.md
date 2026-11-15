---
id: 13
title: Układ strojenia
labels: [wayfinder:grilling]
status: closed
assignee: claude
blocked_by: []
---

## Question

Jak są ułożone zasoby strojenia (`.tres`): które zasoby, co w zestawie wnętrza i pleneru, jak działają warianty krytyka (3 do przeklikania), zapis zestawów z F1, `--set=` w zrzutach? Które parametry są krzywymi doby, a które stałymi? Gdzie w F1 widok debug silnika (ze „Strategia testów i sceny testowe”)?

## Resolution

2026-11-15. Grilling z człowiekiem.

1. **Zasoby strojenia:**
   - **Krzywe doby** (jeden plik dla całej gry, wspólny dla wnętrz i pleneru, żeby słońce za oknem zgadzało się z ulicą): droga słońca (godzina → wysokość, azymut), kolory i natężenia słońca i nieba, ambient, zachmurzenie, tarcza słońca, ekspozycja;
   - **Zestaw strojenia** (dwa: `wnetrza.tres`, `plener.tres`), same stałe: A′ (tryb z „Nakładanie cieni z kilku źródeł”, szew w px, poziomy), półcień (mnożnik, maksimum w px), Odbiorniki (modelowanie, kontrświatło, wypełnienie), siła Smug i Plam okna, stylizacja kurzu;
   - profile nieba i profile Źródeł bez zmian (z „Kontrakt danych sceny”); Lokacja (Otoczenie Lokacji) tylko wybiera Zestaw, bez własnych pokręteł.
2. **Krzywa czy stała:** wszystko, co zależy od godziny, to krzywa lub gradient w Krzywych doby albo w profilu (Źródła: godziny świecenia, kolor, natężenie); reszta to stałe w Zestawie.
3. **Bez ręcznego strojenia (człowiek):** w F1 nie ma suwaków wartości ani zapisu zestawów. Stroi się wyłącznie **Wariantami strojenia** od krytyków: Wariant to katalog z kopiami dowolnych plików strojenia (Zestawy, Krzywe doby, profile nieba i Źródeł; brakujący plik = bazowy) i opisem w jednym zdaniu. Krytyków może być kilku o różnych profilach, każdy daje A/B/C (w F1 np. „bazowy / Malarz A–C / Kontrast A–C”). Gra wczytuje nowe Warianty bez restartu. Wybrany Wariant Claude przenosi do plików domyślnych i commituje w tickecie; poprzednia wersja zostaje w gicie.
4. **F1 (minimum):** godzina, tempo czasu, przełącznik Wariantów, przycisk „Zrzut”, stały przełącznik „Widok debug” (brak / Bryły / Odbiorniki / kafle i warstwy / kanały / odczyt Stanu doby) oraz przełączniki bieżącego ticketu wykonawczego, które znikają po „ok” człowieka. Panel silnika jest częścią addonu; Poligon pokazuje go w swoim F1 obok swoich opcji (przełącznik trudnych scen).
5. **Zrzut dla agenta:** przycisk w F1 i F12 zapisują PNG z opisem stanu (scena, godzina, Wariant, pozycja postaci, przełączniki); ścieżka trafia do schowka. `--z-zrzutu=plik` odtwarza tę samą klatkę. Wiersz poleceń: `--set=` po nazwie wartości (np. `--set=styl.szew_px=2`), `--wariant=nazwa`; stare `--set=` z indeksami zostaje tylko dla opcji Poligonów.

Zmienia kryterium 4 mapy: wartości w `.tres`, Warianty przełączane na żywo w F1 (bez suwaków i zapisu z F1). Do „Krzywe doby i noc” i „Stylizacja rozproszenia w powietrzu”: oceniane jako Warianty krytyków, nie suwakami.
