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
Wyłącznie mapa wayfindera (`docs/wayfinder/map.md`). Na sceny gry mówimy Poligon albo Lokacja.

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
