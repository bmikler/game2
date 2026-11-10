---
id: 25
title: Kierunek graficzny: ideacja i style frame'y
labels: [wayfinder:prototype]
status: closed
assignee: bmikler
blocked_by: [24, 28, 29]
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/25-kierunek-graficzny.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Jak wygląda gra? Ustalić kierunek graficzny przez ideację z Claude: concept arty z opisu i obrazów referencyjnych człowieka, iteracja, wybór. Wynik to wejście dla pipeline'u assetów: 2–3 style frame'y w kamerze gry (3/4, 16:9; wersja z równym światłem i wersja nastrojowa), arkusz postaci Krogga (4 widoki i zbliżenie twarzy pod portret w rozmowie, neutralne tło; portret i sprite muszą do siebie pasować, patrz Generowanie UI, czcionek i portretów), paleta projektu 16–32 kolory (.hex/.gpl) i `STYLE.md` z opisem stylu i promptów.

Wejście z ticketu Assety pixel art bez ręcznego rysowania, sterowane przez Claude: lokalne ComfyUI (portable, SDXL) sterowane przez Claude skryptem Node w `tools/concept/`, bez kosztów za obraz. Zmienione przez Setup ComfyUI do ideacji sterowanej przez Claude: Comfy Desktop + FLUX.2 [klein] 4B z referencjami, 5–11 s/obraz; spójność twarzy między arkuszem a portretem umiarkowana, do dopracowania tutaj. Struktura `art/concept/` (`_refs`, `_style`, lokacje, postacie, `picks.md`, `prompts.jsonl`) z docs/research/24d-concept-art.md.

Wejście z mapy: klimat (zima, pixel art z dynamicznym światłem; Replaced, Octopath Traveler, Disco Elysium, Fahrenheit, Twin Peaks, Alan Wake), skala (postać ok. 75 px na płótnie 80×80 jak Krogg z Pixellab; 1 m = 40 px, kafel 32 px i tabela wymiarów mebli w `STYLE.md` z ticketu Skala grafiki dla postaci ok. 75 px; baza 960×540, kadr ok. 24×13,5 m, i wnętrza na tyle duże, by w większości wypełniały kadr, z ticketu Rozdzielczość bazowa: 640×360 czy większa), wycinek „Dzień na posterunku” (posterunek, Krogg).

Preferencja człowieka (2026-10-28): najpierw ścieżka darmowa. Pierwsza iteracja to 2 postacie z kilkoma animacjami i jedno pomieszczenie (posterunek); styl może się później zmieniać i ulepszać, więc nie musi być ostateczny. Po teście Pixellab człowiek wybrał: ideacja lokalnie w ComfyUI (RTX 4060 8 GB, wersja portable, SDXL; Claude steruje przez HTTP API), potem konwersja w Pixellab.

Wytyczna człowieka po teście Pixellab (2026-10-28): Krogg z Pixellab jest „bardzo ładny i czysty”, a klimat ma być brudniejszy, realistyczny i biedniejszy. Postacie zwyczajne, zmęczone, nie heroiczne: Krogg z trochę rozczochranymi włosami, mniej napakowany, w znoszonym ubraniu. Do `STYLE.md` i promptów (także negatywnych, np. bez „heroic”, „clean”, „muscular”) w ComfyUI i Pixellab; w Pixellab sprawdzić `proportions` (np. `realistic_male` lub własne, węższe ramiona) i opis zamiast domyślnej sylwetki.

Krok dla człowieka: ComfyUI postawione w tickecie Setup ComfyUI do ideacji sterowanej przez Claude, obrazy referencyjne do `art/concept/_refs/`.

Wstępne wyniki z sesji Setup ComfyUI (2026-10-28), wejście dla tego ticketu (szczegóły w `art/concept/picks.md`): wybrany arkusz Badacza (`badacz-sheet-v14-5003`, granatowa parka policyjna, kremowy sweter) i portret do rozmów (`badacz-portret-6003`) z twarzą zgodną z arkuszem. Preferencje człowieka: styl malarski concept artu (nie zdjęcie, nie komiks), klimat skandynawski/amerykański, nie „rosyjski”; Badacz szczupły, zmęczony, ale budzący sympatię; rok 2010. Wnioski techniczne: kolejne edycje tego samego obrazu rozmywają go, więc każdą zmianę robić z ostrego oryginału; edycja z kilkoma referencjami naraz miesza widoki. Posterunek do wygenerowania osobno: realistyczny układ dla 2 policjantów (2 biurka z komputerami, kuchnia z ekspresem i wersalką z narzutą, archiwum z pudłami, korytarz z 2 celami z kratami i pryczami), lekko zakurzony.

## Postęp

**Ideacja posterunku (2026-10-28), zrobione.** Wszystkie pomieszczenia wycinka mają wybrany klimat, nie układ (rozkład mebli i wymiary w skali 40 px/m projektujemy osobno, przy budowie sceny). Wybory i uwagi człowieka: `art/concept/picks.md`, sekcja Posterunek; pliki w `art/concept/locations/posterunek/` (surowe PNG poza gitem, wybrane do `git add -f`).

- Główna sala: `sala-c-8302`. Pokój socjalny: `socjal-9002e-9202`. Archiwum: `archiwum-9500e-9703`. Cele: `cele-d-10201`. Gabinet Badacza: `gabinet-b-10400`.
- Klimat: Alan Wake + Twin Peaks + zimowa Skandynawia, małe miasteczko. Budynek zadbany i skromny (jasna boazeria, brzozowe meble, linoleum), chłodne świetlówki z pojedynczą ciepłą lampką, noc i śnieg tylko za oknem. Bałagan tylko w szczegółach (papiery, popielniczka, niedopita kawa, resztki jedzenia, kurz w archiwum); nie rudera, nie „rosyjski” brud, nie świątecznie ani cukierkowo, bez pajęczyn, bez śniegu w środku.
- Kamera: ujęcie z lekko podwyższonej kamery na tylną ścianę daje najlepszy klimat; wysoka kamera 3/4 (`sala-e`) dawała nienaturalny układ mebli i została odrzucona dla concept artów. Style frame'y w prawdziwej kamerze gry są nadal do zrobienia.
- Zmiany zakresu wycinka (do naniesienia w Zakresie wycinka scenariusza przy budowie): **jedna cela** zamiast dwóch, pomieszczenie przedzielone kratą na przejście i celę, cela bez okna; **gabinet Badacza to osobny pokój** z drzwiami z głównej sali; **archiwum bez biurka**, dokumenty czyta się przy swoich biurkach.
- Wnioski o FLUX.2 [klein]: model nie zna negacji, więc słowo w prompcie (np. „cobwebs”, „falling snow”) zawsze się pojawi; opisywać tylko to, co ma być. Edycja z referencją trzyma kadr 1:1 i dobrze dodaje lub usuwa drobiazgi, ale nie zmienia kamery ani liczby elementów konstrukcji (krat, ścian); do tego generować od nowa. Obraz da się odtworzyć 1:1 z promptu i seeda z `prompts.jsonl`.
- Wspólny opis stylu użyty w wybranych obrazach (baza dla `STYLE.md`): „Small-town police station in a quiet snowy town in northern Scandinavia, dark February winter morning, year 2010. Tidy, well kept and modest building, clean dry floor, clean but not new, light wood panelling and plain birch office furniture. Lighting: cold fluorescent ceiling light mixed with a warm desk lamp, deep blue darkness and snow visible only outside the windows, a dark pine forest beyond. Restrained, sober and quietly uneasy, not festive. Mysterious small-town atmosphere like Twin Peaks and Alan Wake, Scandinavian winter. Empty room, no people. Wide shot from a slightly high camera, looking straight at the back wall, the front wall removed, the whole room visible from wall to wall, logical realistic furniture layout. Painterly concept art, realistic, muted desaturated colours.”

**Arkusz Krogga (2026-10-28), zrobione.** Arkusz `krogg-sheet-f-602` i portret do rozmów `krogg-portret-b-801` (z arkusza jako jedynej referencji); szczegóły w `art/concept/picks.md`, sekcja Krogg. Krogg: młody (pod 30), wysoki i chudy, w ciągłym biegu, rozczochrane, lekko tłuste blond włosy, kilkudniowy zarost, czysty granatowy mundur (sweter na jasnoniebieskiej koszuli) i granatowa czapka z daszkiem z logo policji. Portret: poważny, lekko podkrążone oczy.

- Ryzyko dla sprite'a (do sprawdzenia w Pipeline assetów pixel art z normal mapami): Krogg i Badacz są obaj w granatach. Odróżniają ich czapka, jasna koszula i blond włosy Krogga oraz kremowy sweter i brązowe buty Badacza; czy to wystarczy przy 75 px, pokaże prototyp.
- Wnioski o FLUX.2 [klein]: opis pośpiechu („hurried”, „on the run”) zmienia pozę na krok, więc w arkuszu pod sprite prosić wprost o stojącą, neutralną pozę, a pośpiech trzymać w twarzy i detalach. Model dopisuje losowe napisy (plakietki, róg kadru); usuwać edycją albo przy konwersji do pikseli. Portret z arkusza znów ma grubszy kontur i nieco starszą twarz niż arkusz: ujednolicić w `STYLE.md` razem z Badaczem.

Zostaje w tym tickecie: 2–3 style frame'y w kamerze gry (3/4, 16:9, równe światło i nastrojowe), paleta 16–32 kolory, `STYLE.md`.

## Resolution

Zrobione 2026-10-28. Kierunek graficzny jest w `art/concept/_style/STYLE.md` (klimat, zakazy, wnioski o FLUX.2 [klein], prompty bazowe, opisy postaci, zasady pixel artu, tabela wymiarów w skali 40 px/m), a wybrane obrazy w `art/concept/picks.md`.

- **Posterunek:** wszystkie pomieszczenia wycinka mają wybrany klimat (Alan Wake + Twin Peaks + zimowa Skandynawia; budynek zadbany i skromny, bałagan tylko w szczegółach, chłodne świetlówki z jedną ciepłą lampką). Układ mebli projektujemy przy budowie sceny, nie w concept arcie.
- **Postacie:** arkusze i portrety Badacza i Krogga wybrane. Ryzyko: obaj w granatach, czytelność przy 75 px do sprawdzenia w Pipeline assetów.
- **Paleta:** 32 kolory (`palette.hex`, `.gpl`, `.png`) z median cut po wybranych obrazach plus ręcznie dobrane akcenty; wstępna, do sprawdzenia na sprite'ach pod światłem.
- **Style frame'y w kamerze gry odpadają.** Próba we FLUX dała poprawną kamerę 3/4, ale nie skalę postaci ani wygląd pikseli; człowiek uznał, że FLUX tego sensownie nie wygeneruje, a obrazy usunięto. Kadr gry powstaje z prawdziwych sprite'ów w Godot w Pipeline assetów. Wersja z równym światłem i nastrojowa to w grze to samo albedo pod innymi światłami 2D: sprite'y rysujemy w neutralnym świetle.
- **Zmiany zakresu wycinka** (do naniesienia przy budowie): jedna cela przedzielona kratą zamiast dwóch, gabinet Badacza jako osobny pokój, archiwum bez biurka.
