---
id: 02
title: Sprawdzian assetu w prototypie
labels: [ready-for-agent]
status: closed
assignee: claude
blocked_by: [01]
---

## Co zbudować

Odpowiedź na pytanie człowieka, zanim powstanie silnik: czy mebel wygenerowany tak jak postać, postawiony na uproszczonej Bryle i oświetlony z Bryły, wygląda dobrze. Dwa kroki:

**1. Mebel jak postać (człowiek, 2026-11-15).** Cała grafika ma być jednym stylem, więc mebel powstaje tak jak postacie z Przepisu postaci (`docs/grafika/przepis-postaci.md`): w ComfyUI, w tym samym malarskim, lekko rysunkowym stylu (stały prompt stylu; wzorem stylu może być wygenerowany detektyw albo bibliotekarka), w kącie gry wymuszonym prowadnicą z „Prowadnic v2”, pikselizacja tym samym łańcuchem co postacie. Każdą wersję porównujemy z rzutem z Blendera (sito kąta i sylwetki, jak przy postaciach); odpadają te, które się nie zgadzają. Z tych, które się zgadzają, człowiek dostaje **stronę HTML z kilkoma wersjami obiektu** (obok postaci w tej samej skali) i wybiera asset. Generacji nie przełącza się w F1. Mebli na start 2–3 (np. lada, stół z nogami, kanapa lub fotel); przy kłopotach wystarczy jeden.

**2. Wybrany asset w świetle.** Prototyp do wyrzucenia na gałęzi od `proto-09-nakladanie` (istniejący raycast pudełek, słońce, niebo, lampy, A′): wybrany sprite na Bryle (pozycja z trafienia w ścianę Bryły, normalna ze ściany albo z Blendera), cień z Brył, obok postać. Dzień w słońcu, noc z lampą z boku i z tyłu. Szczegóły techniczne rozstrzyga Claude (człowiek zostawia mu prowadnice, Bryły i cień): co zrobić z namalowanym w sprite'cie światłem, skąd normalne, siła modelowania, piksele bez ściany Bryły pod spodem. Ewentualne kłopoty z Bryłami cienia poprawiamy później, kiedy wyjdą.

## Kryteria akceptacji

- [x] Przed generacją pytanie do człowieka (co, po co, koszt: lokalnie w ComfyUI, 0 zł); odrzucone obrazy usuwane od razu.
- [x] Wycięcie tła i cienia generatora (maska z renderu albo jak w Przepisie postaci).
- [x] Pikselizacja do 40 px/m tym samym łańcuchem co postacie, wyrównana do punktu zaczepienia, bez podwójnych i poszarpanych pikseli; jeden skrypt dla wszystkich mebli.
- [x] Sito: każda wersja porównana z rzutem z Blendera (kąt, sylwetka, skala); do HTML trafiają tylko zgodne.
- [x] HTML wyboru: kilka wersji każdego mebla obok postaci, w skali gry i powiększeniu; wybór człowieka zapisany w tickecie.
- [x] Wybrane meble w prototypie ze światłem i cieniem z Brył, obok postać; bez przełączania generacji w F1.
- [x] Kod prototypu poza `lighting/` i poza przyszłym addonem; nie trafia do silnika.
- [x] Zapis oceny człowieka i decyzji technicznych Claude'a w tickecie (do „Poprawki kontraktu assetu”).

## Jak sprawdzić

1. Otwórz HTML wyboru: czy wersje mebla wyglądają jak z tej samej gry co postać i mają ten sam kąt; wybierz po jednej.
2. Uruchom prototyp w dzień i w nocy: czy wybrany mebel wygląda jak część sceny, czy jego cień i światło lampy z boku są wiarygodne.

## Wykonanie (2026-11-15, Claude)

### Krok 1: meble z ComfyUI i wybór

- **Generacja** (lokalnie, 0 zł, za zgodą człowieka): Qwen-Image-Edit-2511 przez `tools/postac/qwen_kat.mjs`, obraz 1 = szary render z Prowadnic v2 (`shots/prowadnice_v2/<mebel>/prowadnica_szary.png`), obraz 2 = bibliotekarka (`proby/bibliotekarka/qwen/przod_a15_s9000.png`) jako wzór stylu, LoRA kątów 0 (kąt daje render). Ok. 1,5–2 min na obraz. Skrypty: `proby/meble/prompt.sh`, `proby/meble/generuj.sh`.
- **Seria 1** (12 obrazów, prompt „przemaluj szary model”): wszystkie zgodne z rzutem, ale meble gołe. **Uwaga człowieka:** render z Blendera ma dawać tylko rzut, położenie i wielkość (jak manekin MPFB przy postaci), a mebel ze szczegółami (poduszka, narzuta, obrus, przedmioty) ma powstać w ComfyUI, w jednym assecie; wzór bogactwa: meble z Pixellab w game1 (`repo/game1/game/world/station/sprites/{armchair,sofa,desk}.png`).
- **Seria 2** (prompt „szary kształt to tylko prowadnica położenia; stwórz mebel z naturalnymi szczegółami”): przerwana przez człowieka po 3 ladach (nadal dość skromne; bogactwo szczegółów przeniesione do mapy grafiki: „Przepis mebli i rekwizytów”, pomysł: najpierw mebel ze szczegółami, potem przeróbka pod rzut). Ten ticket sprawdza cienie, nie szczegóły assetów.
- **Wybór człowieka:** lada `b_s9100` (seria 2, zielona ze słojem), stół i fotel `a_s9000` (seria 1). Sprite'y: `proby/meble/wybrane/{lada,stol,fotel}.png`. Strona wyboru: `proby/meble/wybor.html` (`node proby/meble/wybor.mjs`). Odrzucone obrazy usunięte.
- **Liczba kolorów (człowiek):** wszystkie assety mają mieć tyle kolorów co animacja z Pixellab. Pomiar: klatki chodu D 32–46 kolorów, stanie D z ComfyUI 974, bibliotekarka 1164, meble po zmniejszeniu 540–1160. Meble: paleta 40 kolorów. Stanie postaci D i bibliotekarki nie jest jeszcze na palecie chodu (poza tym ticketem; wpis w mapie grafiki).

### Łańcuch mebla: `tools/meble/mebel_piksele.gd`

Jeden skrypt dla wszystkich mebli (testy: `tools/meble/test_mebel_piksele.gd`, 6 testów, headless):

```
"$G" --headless --path . --script tools/meble/mebel_piksele.gd -- shots/prowadnice_v2/<mebel> proby/meble/<mebel>/wynik proby/meble/<mebel>/qwen/*.png
```

1. Obraz z Qwen (1024 px) wraca na płótno prowadnic (960 px, Lanczos).
2. **Maska generatora:** tło zalane od krawędzi (kolor rogu, tolerancja 0,08 jak `crop_ref` w Przepisie postaci); wszystko poniżej linii podłogi z Blendera (+1 px gry) odcięte, to cień generatora.
3. **Sito** względem maski z Blendera: podstawa pokryta ≥ 95%, dodatki poza podstawą ≤ 30% jej powierzchni, dolna krawędź na linii podłogi ±10 px prowadnic (1 px gry). Pokrycie i linia podłogi trzymają kąt, skalę i położenie; dodatki mogą wychodzić poza podstawę. Wynik w `sito.jsonl` i `<nazwa>_kontrola.png` (kontur Blendera czerwony, generatora turkusowy). Seria 1: pokrycie 100%, dodatki 1–4%, dół 1–3 px; seria 2 (lady): pokrycie 100%, dodatki 4–5%.
4. **Pikselizacja** jak u postaci (Lanczos, twarda alfa): płótno zmniejszane dokładnie ×1/10 (płótno to wielokrotność siatki gry wyrównana do punktu zaczepienia, więc bez podwójnych pikseli); alfa = udział pikseli mebla w pikselu gry > 0,5; przed zmniejszeniem piksele tła dostają kolor najbliższego piksela mebla (bez szarej obwódki).
5. **Paleta** 40 kolorów: median cut w Lab + 8 kroków k-średnich, kolor = średnia klastra.

### Krok 2: prototyp w świetle (gałąź `silnik-02-proto` od `proto-09-nakladanie`)

- Kopia robocza: `C:\Users\bartl\Desktop\game2-proto-02`, uruchomienie `style-lab/nakladanie.bat`. Kod tylko w `proby/nakladanie/` i `proby/meble_proto/` (poza `lighting/` i addonem), do wyrzucenia.
- Ulica i wnętrze z proto-09 (słońce, niebo, lampy, A′), w obu lada, stół i fotel na swoich Bryłach, obok postać (pudełko). Klawisze: `M` modelowanie, `K` lampa stojąca przy stole: brak / z boku / z tyłu. Zrzuty wsadowe: `-- --meble-shots` (dzień 10:00 i 14:30, noc 21:00 z lampą z boku i z tyłu); kopie w `proby/meble/zrzuty/`.

**Decyzje techniczne (do „Poprawki kontraktu assetu”):**

- **Bryły mebla** z `bryly.json` jako niewidoczne pudełka (tylko zasłaniają): rzucają cień i zasłaniają niebo tym samym raycastem co reszta sceny. Kolor daje sprite.
- **Pozycja piksela sprite'a:** linia widzenia piksela trafia w Bryły mebla (przód albo wierzch, najbliżej kamery). Z tego trafienia pochodzi punkt do świateł i cieni oraz głębia do zasłaniania (mebel za postacią i przed nią).
- **Piksele bez Bryły pod spodem:** przedmiot ponad wierzchem Bryły (kasa, słój, monitor) stoi na pionowej płaszczyźnie w połowie głębokości tego wierzchu. Reszta (np. zwisająca narzuta obok Brył, prześwity między uproszczonymi Bryłami) leży na płaszczyźnie przodu obrysu Brył.
- **Normalne:** domyślnie z mapy z Blendera (`normalne_gra.png`, modelowanie kształtu, np. zaokrąglony fotel); do porównania w `M`: normalna ściany Bryły (płasko) albo pół na pół. Siła modelowania = wybór człowieka w `M`.
- **Namalowane światło w sprite'cie** zostaje jako część albedo (bez spłaszczania). Generator dostaje w prompcie „soft even light, no cast shadow”, więc namalowane cieniowanie jest słabe; spłaszczanie niszczyłoby malarski styl. Światło sceny dokłada kierunek.
- **Cienie własne:** punkt odsunięty 2 cm od ściany Bryły wzdłuż jej normalnej, żeby promienie nie startowały w niej.
- **Punkt zaczepienia** w sprite'cie (`zaczepienie_gra`) na rogu piksela; pozycje mebli w metrach na siatce 1/40 m, więc sprite i Bryły leżą w tym samym miejscu co do piksela.

### Ocena człowieka

2026-11-15, w prototypie:

- Meble wyglądają jak część sceny, cienie są wiarygodne. **Cienie od nieba „wyglądają super”.** Od lamp czasami dziwnie, ale prawdopodobnie tak powinno być przy takim ustawieniu lamp.
- Modelowanie `M` widać w zasadzie tylko na ladzie. Przy normalnej ściany Bryły słój i książka ponad krawędzią lady są trochę przezroczyste; z Blendera jest dobrze. **Wybór: normalne z Blendera.**
- Na podłodze dziwne układy cieni niezwiązane z meblami: to poziomy i dither A′ z proto-09, do dopracowania w ticketach stylu (11) i strojenia (12).

**Otwarte do „Poprawki kontraktu assetu” (ticket 03):** piksele dodatków spoza modelu z Blendera (słój, książka, narzuta) nie mają normalnej: mapa ma tam (128, 128, 128), czyli wektor zerowy, więc w trybie „z Blendera” dostają tylko ambient i przez to wyglądają na pełne. To przypadek, nie reguła. Przy normalnej ściany Bryły (płaszczyzna jak ściana za nimi) dostają to samo światło co tło i wyglądają na przezroczyste. Kontrakt musi dać dodatkom własne normalne (np. z obrazu generatora albo przyjęta stała normalna dla „przedmiotu na wierzchu”) i sprawdzić to na meblu z bogatymi dodatkami.
