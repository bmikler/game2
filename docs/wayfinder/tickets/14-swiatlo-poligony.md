---
id: 14
title: Światło w Poligonach: smugi, plama słońca, noc w mieście i poza nim
labels: [wayfinder:prototype]
status: open
assignee: claude
blocked_by: [11, 36, 39]
---

## Question

Jakie światło daje najlepszy klimat w nowym rzucie i skali? Na Poligonach przenieść i poeksperymentować: smugi z okien, drobinki kurzu, plama słońca na podłodze z meblami (pomysły z `docs/grafika.md`, „Plama światła a meble”), kolory za oknem, nocne światło przez okno w mieście (latarnie) vs poza miastem, oświetlenie fasad i śniegu nocą. Kolory z `docs/swiatlo-kolory-game1.md` jako start. Decyzja człowieka: zestaw technik światła i ich strojenie.

Z Wyboru Kotwic stylu: smugi i ciepłe punkty z bloomem jak w REPLACED, kolor jak NORCO; zasada temperatury: baza chłodna, zimowa, ciepło tylko przy źródłach. Referencje: Disco Elysium (paleta zimy), Kentucky Route Zero (małe ciepłe źródło w wielkiej ciemności).

## Zakres po ticketach 27, 31, 33 (2026-11-10)

Wnętrze jest rozstrzygnięte: światło okien, drzwi, lamp i kurz w smudze liczy mapa (ticket [31](31-dynamiczne-slonce-okien-prototyp.md)), orientacja: południe na górze (ticket [27](27-swiatlo-okien-orientacja.md)), cień postaci (ticket [33](33-cien-postaci-z-mapy.md)). Ten ticket zostaje dla **ulicy i zgodności z wnętrzem**:

- światło na Poligonie Ulica (`ulica_bryly`) zgodne z wnętrzem: kierunek słońca (fasady w słońcu lub w cieniu), okna widziane z ulicy w dzień i w nocy, przejście drzwiami (ADR 0007 z game1: stała ekspozycja na przestrzeń);
- zasłanianie nieba przez sąsiednie budynki (różnica między oknami w tej samej ścianie);
- latarnie, noc w mieście i poza nim, oświetlenie fasad i śniegu nocą, kolory za oknem;
- pomysły ze stanu ticketu 27 (do oceny, nie decyzje): bez cieni budynków albo tylko jako wariant, błysk w co trzecim oknie, poświata zapalonych okien na śniegu, ciepła krawędź śniegu na dachach i parapetach przy fasadach w cieniu; pytanie człowieka: czy smugi słońca wpadające do okna pokazać na zewnątrz, czy tylko kolor;
- cień postaci na ulicy wzorem z ticketu [35](35-jeden-model-cienia.md).

Blokada: [Przebudowa światła wnętrza na jeden bufor z cieniami](36-przebudowa-swiatla-jeden-bufor.md) (model światła i cieni wnętrza, który idzie na ulicę). Do uwzględnienia przy ulicy uwagi inżyniera z `docs/research/80-ocena-oswietlenia-inzynier.md`: C (skala na ulicę: mapa wysokości, kafle, portale, pomiar w ms) i D (wiele postaci, test z 5 NPC).

## Zakres po tickecie 36 (2026-11-11)

Model światła wnętrza przyjęty ([36](36-przebudowa-swiatla-jeden-bufor.md)): jedna funkcja i jeden bufor, cień nieba dokładny, postać i meble jedną funkcją. **Najpierw ten sam model na ulicy** (nowe cienie postaci, budynków i obiektów od słońca, nieba, latarni i okien; człowiek chce sprawdzić, jak działają na ulicy, przed strojeniem). Ten ticket rozstrzyga techniki i poprawność na ulicy; **strojenie** (wartości, kolory, złota godzina) idzie do [Krytyka strojenia światła i cieni: wnętrze i ulica](38-krytyk-strojenia-swiatla.md), raz dla wnętrza i ulicy. Stylizacja pixel art: [37](37-stylizacja-cieni-pixel-art.md) (ten sam mechanizm na ulicy). Decyzja człowieka tutaj: zestaw technik światła na ulicy, nie strojenie.

## Sesja 2026-11-15: model wnętrza na ulicy

Gałąź `t14-ulica-swiatlo` (od `t37-stylizacja`). Opis i uruchamianie: `style-lab/README.md`, „Prototyp światła ulicy”.

- **Jeden model:** funkcja `street_parts` (`street_fn.gdshaderinc`) i bufor `StreetMap`, wspólne z domem: lampy, stylizacja A/B/C, rozdzielczość (`light_common.gdshaderinc`, przeniesione bez zmian; bufor domu bajt w bajt jak przed zmianą, 9:30, 16:30, 22:00, także B). Źródła: słońce z cieniami budynków (z dachami), niebo zasłaniane przez bryły (współczynnik kształtu ścian brył), latarnie jako punkty, zapalone okna nocą jako świecące szyby (ta sama matematyka co niebo przez szybę, odwrócona). Ręczne warstwy ulicy (płaskie słońce na fasadach, poświata okien, plamy latarń, plamka pod stopami) wyłączone przy mapie; przełącznik „Światło ulicy: stare” do porównania.
- **Zgodność z domem:** to samo słońce (`_toward_sun`), góra ekranu domyślnie południe na obu Poligonach. Fasady od ulicy patrzą na północ, więc słońce jest zawsze za domami: rano i po południu ulica leży w cieniu budynków, a przez przerwy między domami wpada smuga słońca; w domu w tym czasie świecą okna tylne. Pytanie z ticketu 27 (smugi słońca wpadające do okna widziane z ulicy) odpada: w okna od ulicy słońce nie wpada.
- **Bramka (sprawdzone):** postać jako pudełko = pudełko w miejscu postaci (0 różnych px, 9:30, 15:30, 22:00, przed domem i w przerwie); bufor po spacerze = bufor liczony w całości co klatkę (0 px; także wygląd B). Wszystkie obiekty (postać tak samo jak meble) mają ten sam zasięg cienia nieba (4 m od obrysu, wygaszany). Przejście ulica → dom sprawdzone zrzutem; dom → ulica do sprawdzenia w grze (teleport w zrzutach nie uruchamia drzwi domu).
- **Naprawione po drodze:** bufor ulicy łapał poświatę (glow) sceny i kumulował ją tam, gdzie okno postaci nie przemalowywało (własny świat 2D i 3D bufora).
- **Koszt:** bufor liczony tylko przy zmianie: stojąc ok. 350 kl./s, w ruchu 70–90 kl./s; pełne przeliczenie ok. 110 ms rozłożone na 8 klatek co minutę gry.
- **Uwagi:** dzień jasny (słońce na śniegu ×0,5, do strojenia w [38](38-krytyk-strojenia-swiatla.md)); poświata renderera (glow) na ulicy włączona, w domu wyłączona, a dom wyłącza ją na wspólnym zasobie środowiska bez przywracania (po wizycie w domu ulica też bez glow) — do ujednolicenia przy strojeniu; dekoracje z ticketu 27 (ciepła krawędź śniegu, błysk w szybach) nie znają cieni mapy.

**Po ocenie człowieka (2026-11-15):** z domu nie dało się wyjść (przednia krawędź korytarza bez przerwy na drzwi; błąd sprzed tego ticketu) — naprawione. Cienie na ulicy inne niż w domu: budynki 6–10 m od ziemi rozlewały półcień tarczy słońca na ~40 cm ziarnistego pasa; teraz półcień ograniczony do `sun_pen_max` (6 cm) przy najbliższej przesłonie (próbki tarczy drugi raz na zwężonej tarczy tylko w półcieniu), krawędzie zwarte jak w domu. Wydajność: obiekty dalej niż zasięg ich cienia nieba pomijane przed liczeniem ścian, ulica przeliczana co 5 minut gry (opcje od razu) w 16 pasach; w ruchu 116–161 kl./s (było 70–90), pełne przeliczenie ~36 ms rozłożone na 16 klatek. F1 na ulicy jak w domu: kadr, światło ulicy (mapa / stare), cienie budynków, wygląd, rozdzielczość, widok debug; reszta ukryta (`--set=` działa). Bramki po zmianach: pudełko = postać i spacer = całość, 0 różnych px.

## Notatka dla następnej sesji (2026-11-15, zaparkowane)

Gałąź `t14-ulica-swiatlo`, ostatni commit z poprawkami A/B/C. Zrobione w tej sesji po uwagach człowieka:
- wyjście z domu (przerwa w krawędzi korytarza), F1 na ulicy skrócone, wydajność (ulica w ruchu 130–213 kl./s);
- półcień słońca osobno dla każdej przesłony (najwyżej `sun_pen_max` 6 cm przy jej odległości; wcześniej najbliższa przesłona decydowała za wszystkie i robiła jasną ramkę wokół cienia postaci);
- próbki tarczy słońca, żarówek, wstęg i nieba ze stałym wzorem (bez obrotu Bayera w każdym pikselu: dawało ziarno 2×2 obok ditheru A 1 px), więcej próbek (słońce 16, lampy 16, siatka nieba 4×4) — **zmienia też bufor domu** (świadomie; dom sprawdzony wzrokowo, bramki domu bajt w bajt nie dotyczą tej zmiany);
- na ulicy niebo zasłania tylko architektura (F1 „Cień nieba zasłania”: tylko architektura / architektura i obiekty); znikła plamka pod postacią i „uszy” przy zaspach;
- bramki ulicy: postać jako pudełko = pudełko w miejscu postaci, spacer = całość co klatkę (0 px).

Ocena człowieka: lampy nocą „spoko”; dzień „średnio”: na całej ulicy siatkowaty cień. Przyczyna: wygląd A na bardzo łagodnym przejściu nieba (pas ditheru jako część kroku EV rozlewa się na dziesiątki px). Zamiast łatać: research [Stylizacja światła i cieni w plenerze w pixel arcie](39-stylizacja-swiatla-plener-research.md).

Otwarte:
- **błąd:** auto jest jednym pudłem 1,65 m, a narysowane jest niższe nadwozie (1,05 m) z cofniętą kabiną (0,6 m) — piksele nad maską biorą światło dachu pudła (jasne miejsce nad autem, człowiek). Poprawka: dwa pudła zgodnie z `_car()` w `ulica_bryly.gd`;
- w domu cień skrzynki (komoda pod oknem w prawym górnym pokoju parteru) na ścianie obok: to cień nieba z okna w prawej ścianie (geometria zgodna ze wzorcem z ticketu 36), wygląda jak „pływający” prostokąt; plus dither A — do oceny razem z researchem 39;
- decyzja człowieka w tym tickecie (zestaw technik na ulicy) po prototypie z researchu 39.

## Wstrzymane do mapy silnika (2026-11-15)

Commit `135ec42`: wydajność (dom przelicza bufor tylko przy zmianie; odrzucanie przesłon testem wiązki `bundle_hits`, bufory bajt w bajt), F1 „Ziarno i poświata” (wspólne, domyślnie wyłączone), bufor domu we własnym świecie. Kolejne poprawki psuły drugą kopię silnika (dom ↔ ulica), więc stop: najpierw jeden silnik światła na osobnej mapie `docs/wayfinder-silnik/map.md`. Ten ticket wraca po jej zakończeniu (techniki światła ulicy na nowym silniku + stylizacja A′ z ticketu 39). Obserwacje człowieka do nowego silnika: przy szybkim przewijaniu czasu okno wokół postaci ma inną godzinę niż reszta bufora; ściany budynków w kratkę (A, ticket 39).
