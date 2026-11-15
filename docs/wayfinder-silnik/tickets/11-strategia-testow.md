---
id: 11
title: Strategia testów i sceny testowe
labels: [wayfinder:grilling]
status: closed
assignee: claude
blocked_by: [05, 08]
---

## Question

Co sprawdzają testy jednostkowe, co bramki buforów, a co ocena człowieka na żywo? Jaki jest zestaw scen testowych z trudnymi przypadkami (np. kilka lamp na słońcu, wąska uliczka, okno dachowe, wysoki obiekt w półcieniu)? Jak dokładnie wygląda test końcowy z nową Lokacją wnętrza i nową Lokacją w plenerze?

Z „Jeden model światła i cienia dla wszystkich źródeł”: do trudnych scen dodać plamy i smugi z okien bocznych (zakaz plamy uchylony, wygląd do oceny), słońce skierowane w kamerę (research 85), promienie słońca między budynkami w plenerze.

**Z „Kontrakt danych sceny” (08):** sceny z żaluzjami (paski w pikselach), papierosem przy twarzy, nocą wieś vs miasto przez okno, oknami przedniej (niewidocznej) ściany; ostrzeżenia walidacji w edytorze.

**Z „Bufor i przeliczanie” (10):** bramka wydajności (kadr z 8 postaciami, samochodem i 4 kołyszącymi się drzewami; ≤ 4 ms GPU, ≤ 1 ms CPU na RTX 4060 Laptop; wczytanie ≤ 2 s), scena porównania wiatru A (cień stały) i B (cień z koroną), przewijanie doby (płynne doganianie cieni słońca), niebo bez prążków we wnętrzu.

## Resolution

2026-11-15. Grilling z człowiekiem.

1. **GUT 9.7.1** (zgoda człowieka) w `style-lab/addons/gut/`, poza katalogiem silnika. Jedna komenda `node tools/test.mjs` uruchamia GUT i bramki; testy shaderów w oknie poza ekranem (`--resolution 64x64 --position -3000,-3000`), bo wymagają GPU.
2. **Trzy warstwy:**
   - **testy jednostkowe (GUT, headless):** Stan doby z godziny (krzywe drogi słońca, kolory), rzut metry → ekran, wyliczanie Odbiorników i obszaru bufora z Brył, geometria Otworów z wypełnieniem, ostrzeżenia walidacji kontraktu, wczytywanie i zapis zestawów `.tres` i `--set=`, przydział do warstw zmienności i kafli; test „bez kodu pod scenę” (katalog silnika nie odwołuje się do `style-lab` ani do nazw scen);
   - **bramki buforów (GPU, małe syntetyczne sceny z węzłów kontraktu, robi je Claude):** sprawdzają zasady, nie wygląd: cień po przeciwnej stronie niż Źródło, dwa Źródła razem = suma osobno, przyczepione Źródło niezasłaniane przez swoją Przesłonę, pokój bez Otworów ciemny, brak skoków między kolejnymi minutami doby, niebo we wnętrzu bez prążków; plus regresja w ustalonych punktach z tolerancją, wzorzec odświeżany tylko po akceptacji wyglądu przez człowieka; bramka wydajności: benchmark kadru z „Bufor i przeliczanie” (≤ 4 ms GPU, ≤ 1 ms CPU, wczytanie ≤ 2 s);
   - **człowiek na żywo:** wyłącznie wygląd. Stare bramki (`bufor_roznica.mjs` itd.) → „Migracja”.
3. **Trudne sceny w dwóch Poligonach** (przełączanie sceny i godziny w F1), nie w osobnych scenach:
   - **Poligon Dom (wnętrze):** górne i boczne okna (smugi, plamy, kurz), okno dachowe, żaluzje (paski w pikselach), okna przedniej niewidocznej ściany, lampa przy słońcu, postać z papierosem przy twarzy, niebo bez prążków, noc; noc wieś vs miasto przez okno = przełączenie profilu nieba w F1;
   - **Poligon Ulica (plener, miasto):** wąska uliczka, wysoki obiekt w półcieniu, kilka lamp i latarń w słońcu, promienie słońca między budynkami, słońce w kamerę, świecące okna, przewijanie doby, kadr wydajności (8 postaci, samochód, 4 drzewa na wietrze), wiatr A/B.
4. **Każdy zaimplementowany ticket wykonawczy sprawdza człowiek ręcznie** (zmiana wobec „reszta na końcu”). Ticket kończy się sekcją „Jak sprawdzić” (komenda/scena, godzina, co przestawić w F1, co ma być widać). Po `/implement` (który commituje) status „do sprawdzenia”; zamknięcie dopiero po „ok” człowieka; poprawka w tym samym tickecie jako kolejny commit; gdy poprawki się piętrzą: stop i powrót do modelu.
5. **Każdy ticket widoczny:** `/to-tickets` tnie pionowymi plastrami, tak by każdy zmieniał coś widocznego w Poligonie albo edytorze. Silnik ma **własny widok debug** w F1 (część addonu, działa w każdej Lokacji, bez zależności od debugu `style-lab`): kontury Brył, Odbiorniki, kafle i warstwy przeliczania, odczyt Stanu doby (godzina, wysokość i azymut słońca, kolory).
6. **Test końcowy:** nowe Lokacje buduje świeży subagent, który widzi tylko dokumentację kontraktu sceny, nie kod silnika; każda zmiana w katalogu silnika = wynik negatywny. Wnętrze: piwnica lub strych z oknem dachowym, gołą żarówką i wąskim okienkiem pod sufitem. Plener: wieś nocą i o świcie, drzewa, stodoła, jedna latarnia, świecące okno. Człowiek otwiera je w edytorze, przesuwa jedną Przesłonę i jedną lampę (cienie mają od razu iść za nimi), potem ocenia w grze o kilku godzinach doby.
