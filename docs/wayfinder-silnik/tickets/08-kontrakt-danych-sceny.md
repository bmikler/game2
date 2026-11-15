---
id: 08
title: Kontrakt danych sceny
labels: [wayfinder:grilling]
status: closed
assignee: claude
blocked_by: [07, 06]
---

## Question

Co Lokacja daje Silnikowi światła i w jakiej postaci: przesłony (pudełka, dachy, walce, pusty dół), otwory (okna, drzwi), źródła, odbiorniki (podłoga, ściany, postać, meble)? Które dane są węzłami układanymi w edytorze, a które silnik wylicza sam? Czego silnik oczekuje od assetu (mebel, ściana, postać), tak żeby Przepis mebli (ticket 13 mapy grafiki) mógł to produkować?

Wejście z „Jeden model światła i cienia dla wszystkich źródeł”: Źródło ma trzy kształty (kierunkowe, kopuła, powierzchniowe); wnętrze to przesłona „dach” z otworami; gęstość powietrza to dana Lokacji; odbiorniki bryłowe (postać, meble) mają parametry modelowania, kontrświatła i wypełnienia.

## Resolution

2026-11-15. Grilling z człowiekiem. Rozpoznanie starego silnika: SunMap/StreetMap nie czytają węzłów; Poligon wypełnia tablice pudełek i szyb, do tego jedna skorupa domu, maks. 4 pokoje, przejścia zgadywane z cienkich pudełek, stałe w `dom_bryly.gd`/`ulica_bryly.gd`, losowe świecenie okien, `sky_objects`, walec postaci w stałych. Kontrakt to wszystko zastępuje.

1. **Lokacja z węzłów kontraktu** (`@tool`, w widoku 2D gry, pola w metrach x, d, z; pozycja na ekranie liczona z rzutu; mysz przesuwa po podłodze x, d, wysokość w inspektorze):
   - **Otoczenie Lokacji** (jedno na Lokację): zestaw strojenia (wnętrza albo plener), **profil nieba** `.tres` (na start: miasto: nocne niebo z łuną; wieś: ciemne, chłodne, księżyc), gęstość powietrza (kurz, mgła), jasność odniesienia ekspozycji. Wnętrze nie liczy niczego z Lokacji na zewnątrz; konkretna latarnia za oknem to zwykłe Źródło postawione poza kadrem.
   - **Ściana**: odcinek na planie, grubość, wysokość. Dzieci: **Otwory** (położenie wzdłuż ściany, szerokość, dół, góra) z opcjonalnym **wypełnieniem**: listwy pionowe i poziome (rozstaw, grubość; szprosy i żaluzje), część zasłonięta od góry do wysokości (opuszczona żaluzja), przepuszczalność (firanka, matowa szyba). Okno, drzwi, przejście to ten sam Otwór; kierunek wynika ze Ściany. Otwory są stałe (bez otwierania w grze na start).
   - **Przesłona**: jedna lub kilka **Brył**: pudełko, pudełko z dachem (spad wzdłuż x albo d), walec, uniesione pudełko (pusty dół). Flaga „ruchoma” (postać, NPC, samochód); wymiary są danymi, nie stałymi. Dach / strop to zwykła Przesłona; wnętrze = Ściany + strop.
   - **Źródło powierzchniowe** (prostokąt albo kula w metrach): profil `.tres` (kolor, natężenie, zanik, godziny świecenia), **mnożnik natężenia sterowany animacją** (papieros, migotanie neonu), może być ruchome i przyczepione do Przesłony. Reguła ogólna: Źródła nie zasłania Przesłona, do której jest przyczepione. Lampa, latarnia, świecące okno, neon, reflektor, papieros to tylko dane. Bez losowości w kodzie; różnorodność z różnych profili.
2. **Silnik wylicza sam:** Odbiorniki (każda powierzchnia Bryły widoczna w rzucie 0,60; bez flagi `receives`), przejścia (to Otwory), obszar bufora (z Brył i podłogi), słońce i niebo ze Stanu doby. Nie zna pokoi, budynków, rodzajów okien ani lamp.
3. **Podłoga na różnych wysokościach dopuszczona:** podłoga to wierzch Bryły, postać ma wysokość stóp. Opcjonalne (ozdoby w mieście); zrezygnować, jeśli drogie. Piętro budynku to osobna Lokacja (schody = wczytanie).
4. **Asset** (mebel, rekwizyt, fasada, postać, samochód) to scena `.tscn`: sprite, Bryły (uproszczone, nie 1:1 z obrazem, na start generowane z tej samej sceny Blendera co prowadnice Przepisu), punkt zaczepienia (środek przedniej dolnej krawędzi), opcjonalnie mapa normalnych, opcjonalnie przyczepione Źródła. Sprite nie rzuca cienia; piksel sprite'a leży na widocznej ścianie Bryły (pozycja do bufora) i bierze normalną z mapy normalnych, a bez niej ze ściany Bryły. Ten sam kod w obu przypadkach. Parametry brył z „Jednego modelu” (modelowanie, kontrświatło, wypełnienie) działają na tych normalnych.
5. **Silnik widzi całą geometrię.** Niewidoczna przednia ściana rzuca cień i wpuszcza światło swoimi Otworami; chowanie ścian działowych przy wejściu postaci dotyczy tylko rysowania sprite'ów.
6. **Walidacja:** węzły kontraktu dają ostrzeżenia w edytorze (Otwór poza Ścianą, Źródło w Bryle, brak Otoczenia Lokacji itd.). Kontrakt nie ma stałych limitów; liczba ruchomych Przesłon i Źródeł oraz koszt → „Bufor i przeliczanie”.

Do „Bufor i przeliczanie”: wiele ruchomych Przesłon (NPC z rutynami, samochód) i ruchome Źródła (reflektory, papieros); samochód z reflektorami i podwyższenia to ozdoby do skreślenia, jeśli drogie. Do „Strategia testów”: żaluzje (paski w pikselach: rozstaw listew to wartość strojenia), papieros przy twarzy, noc wieś vs miasto przez okno, okna przedniej ściany.

**Dopisek (2026-11-15, Poprawka kontraktu assetu, ticket silnika 03):** Sprawdzian assetu w prototypie (ticket silnika 02) potwierdził punkt 4: mebel z ComfyUI na niewidocznych Bryłach z Prowadnic v2, oświetlony z Brył, wygląda jak część sceny. Doprecyzowanie punktu 4 (pełna treść w `docs/silnik/spec.md`, „Asset”): Bryły assetu są niewidoczne (tylko cień i zasłanianie), sprite to albedo z miękkim namalowanym światłem (bez spłaszczania), punkt zaczepienia na rogu piksela gry i pozycja na siatce 1/40 m; pozycja piksela z trafienia linii widzenia w Bryły (najbliżej kamery), a piksele bez ściany Bryły pod spodem: ponad wierzchem Bryły na pionowej płaszczyźnie w połowie głębokości wierzchu, reszta na płaszczyźnie przodu obrysu Brył; mapa normalnych, jeśli jest, pokrywa każdy nieprzezroczysty piksel.
