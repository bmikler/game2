---
id: 16
title: Migracja ze starego silnika
labels: [wayfinder:grilling]
status: closed
assignee: claude
blocked_by: []
---

## Question

W jakiej kolejności Poligony przechodzą z `SunMap`/`StreetMap` na nowy silnik, żeby nie zgubić ustaleń mapy grafiki (lista ustaleń do przeniesienia)? Co ze starymi bramkami buforów (`bufor_roznica.mjs` itd.): usunąć, czy użyć jako odniesienia wyglądu? Kiedy usunąć stary `lighting/`?

## Resolution

2026-11-15. Grilling z człowiekiem.

1. **Stare Poligony zostają nietknięte do końca wykonania** jako porównanie na żywo („jak było”, ta sama godzina). Nowy silnik i nowe Poligony nie importują niczego ze starego `lighting/`, `world/` ani starych `poligony/`.
2. **Kolejność:** pierwsze plastry w nowym Poligonie Ulica (słońce, niebo, cień na ziemi: model bez Otworów), potem Poligon Dom (Ściany z Otworami, Smugi, Plamy okna, kurz, żaluzje); dalej każdy ticket w Poligonie, w którym leży jego trudna scena.
3. **Nowe Poligony nie są 1:1 ze starymi;** układ pod testowanie silnika, zbędne rzeczy odpadają (człowiek):
   - **Poligon Ulica** (plener, miasto, jedna ulica przewijana w poziomie): odcinek **Uliczka** (rząd kamienic od południa z prześwitem 2 m: promienie między budynkami, cień kamienic na ulicy, słońce w kamerę nad dachami, wysoki komin lub słup ogłoszeniowy w półcieniu); **Sklep** (witryna i okna świecące nocą, trzy latarnie i lampa nad drzwiami w słońcu: nakładanie cieni wielu źródeł, przewijanie doby); **Skwer** (8 chodzących postaci, samochód, 4 iglaki na wietrze: kadr wydajności, wiatr A/B). Bez tarasu, zasp, płotów, jeśli żaden test ich nie wymaga;
   - **Poligon Dom** (wnętrze, jedno piętro, bez schodów): **salon** (duże okna w tylnej, południowej ścianie: Smugi, Plamy i kurz w stronę kamery; okno w niewidocznej przedniej ścianie: samo niebo; lampa stojąca przy słonecznym oknie; meble z cieniem: stół, regał, kanapa); **kuchnia** (za ścianą działową z drzwiami, chowaną przy wejściu postaci; okno boczne od wschodu; żaluzje w drugim oknie); **pracownia** (okno dachowe, goła żarówka, postać z papierosem, noc z przełącznikiem nieba miasto/wieś);
   - bez przejścia drzwiami ulica → dom, bez pięter i schodów; chowanie ściany działowej zostaje.
4. **Południe na górze ekranu: stała zasada całej gry** (każda Lokacja, także z testu końcowego). Lokacja nie ma pola orientacji; słońce idzie za sceną ze wschodu (lewo) na zachód (prawo). Przełącznik „góra ekranu” ze starego Poligonu Dom znika.
5. **Stare ustalenia to Ściąga wyglądu, nie wymagania** (człowiek: „vibe podobny, ale bez twardych wartości i ustaleń”; część ustaleń łatała problemy). Specyfikacja bierze reguły wyłącznie z rozstrzygnięć tej mapy; łatki nie przechodzą (jeśli problem wróci, rozwiązuje go model). Stare wartości (krytyk C „Pośredni”, `norway_feb.tres` itd.) najwyżej jako punkt startowy w `.tres`, dowolnie zmieniany Wariantami. Ściągę kompiluje Claude (ze `style-lab/README.md` i ticketów 14, 27, 31, 33, 35, 36 mapy grafiki) w ramach „Specyfikacji silnika”; dostają ją krytycy przy strojeniu. Człowiek nie ocenia pozycji.
6. **Stare bramki** (`bufor_roznica.mjs`, `bufor_ulica_*`, `cien_nieba_*`) nie przechodzą; nowe bramki od zera według „Strategii testów i scen testowych”. Ogólne narzędzia pomiaru (`png.mjs`, `jasnosc.mjs`, `kadr.mjs`, `roznica.mjs`, `obok.mjs`, `postac.mjs`) zostają (m.in. pomiar względem game1).
7. **Usunięcie starego silnika:** osobny ticket wykonawczy po „ok” człowieka dla obu nowych Poligonów, przed testem końcowym. Usuwa `lighting/`, zależne klasy `world/`, `rzut_*`, `demo_*`, stare Poligony i ich `.bat`, stare bramki; `main/` przechodzi na nowe Poligony. Test końcowy i test „bez kodu pod scenę” idą na czystym projekcie.
8. **Poza mapą:** brzeg kadru w czerni (temat nierozpoznany w mapie grafiki) to prototyp kilku wariantów na działającym silniku, w mapie grafiki.
