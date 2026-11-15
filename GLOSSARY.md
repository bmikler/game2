# game2: grafika

Słownik pracy nad stylem graficznym i produkcją grafiki game2. Inne obszary gry (fabuła, mechaniki) dopiszą swoje terminy osobno.

## Language

**Poligon**:
Mała, grywalna scena testowa w projekcie `style-lab/`, która służy do oceny wyglądu przy podejmowaniu decyzji graficznych. Nie jest fragmentem gry.
_Avoid_: mapa testowa, scena testowa, prototyp mapy

**Poligon Ulica**:
Poligon z plenerem: krótka ulica małego miasteczka z trzema budynkami różnej skali, jednym z nich do wejścia.
_Avoid_: mapa zewnętrzna

**Poligon Dom**:
Poligon z wnętrzem domu z Poligonu Ulica, do którego gracz wchodzi z ulicy.
_Avoid_: mapa wewnętrzna

**Mapa**:
Wyłącznie mapa wayfindera: mapa grafiki (`docs/wayfinder/map.md`) albo mapa silnika (`docs/wayfinder-silnik/map.md`). Na sceny gry mówimy Poligon albo Lokacja.
_Avoid_: mapa pomieszczenia, mapa zewnętrzna (to Lokacje)

**Lokacja**:
Jedna scena gry wczytywana osobno: wnętrze albo plener. Przejście między Lokacjami odbywa się przez wczytanie.
_Avoid_: mapa, poziom

**Silnik światła**:
Jeden moduł, który liczy światło i cienie ze wszystkich źródeł w każdej Lokacji, wnętrzu i plenerze, tym samym kodem i tą samą stylizacją. Lokacje różnią się dla niego tylko danymi.
_Avoid_: SunMap, StreetMap, system oświetlenia wnętrz/ulicy

**Źródło światła**:
Wszystko, co oświetla Lokację: słońce, niebo, lampa, latarnia, świecące okno. Ma jeden z trzech kształtów (kierunkowe, kopuła, powierzchniowe); rodzaj źródła to tylko jego dane.
_Avoid_: lampa (jako nazwa ogólna), światło okna

**Przesłona**:
Bryła sceny, która zatrzymuje światło każdego Źródła i rzuca cień: ściana, dach, mebel, postać, budynek. Wnętrze to Lokacja przykryta dachem.
_Avoid_: blocker, okluder

**Otwór**:
Miejsce w Przesłonie, przez które przechodzi światło: okno, drzwi, przerwa w murze.
_Avoid_: szyba (to tylko część okna)

**Stan doby**:
Wszystko, co w danej chwili zależy od godziny: kierunek słońca, kolory i natężenia Źródeł, zachmurzenie, ekspozycja. Jeden dla całej Lokacji w danej klatce.
_Avoid_: profil pogody, pora dnia (jako nazwa danych)

**Smuga**:
Widoczne w powietrzu światło Źródła na drodze przez Otwór lub między Przesłonami, czasem z drobinkami kurzu. Powstaje z gęstości powietrza Lokacji.
_Avoid_: wstęga, promień, god ray

**Plama okna**:
Jasny ślad bezpośredniego słońca na podłodze lub ścianie, w kształcie Otworu, przez który wpadło.
_Avoid_: rzut okna

**Kotwica stylu**:
Jedna z najwyżej 3 istniejących gier wybranych przez człowieka jako wzorzec docelowego wyglądu w nazwanej roli (np. Kotwica proporcji, Kotwica światła). Poza swoją rolą nie jest wzorcem.
_Avoid_: referencja (za ogólne)

**Referencja**:
Gra lub obraz przypięty do jednego Przepisu jako wzór pojedynczego szczegółu (np. woda, gęstość rekwizytów, kolumna dialogu). Nie wyznacza stylu całej gry.
_Avoid_: kotwica, inspiracja

**Klasa assetów**:
Grupa assetów produkowanych jednym przepisem: postacie (z wariantami i animacjami), meble i rekwizyty, budynki i fasady, teren, widok za oknem, UI.

**Przepis**:
Spisany, powtarzalny pipeline produkcji jednej Klasy assetów: wejścia, narzędzia, ustawienia, test, ocena.
_Avoid_: workflow, procedura

**Miesiąc produkcji**:
Okres jednej płatnej subskrypcji (ok. 100 zł/mies., maks. 2 miesiące), w którym generujemy grafikę do całej gry według gotowych Przepisów.
