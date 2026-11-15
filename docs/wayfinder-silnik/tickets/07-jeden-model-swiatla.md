---
id: 07
title: Jeden model światła i cienia dla wszystkich źródeł
labels: [wayfinder:grilling]
status: closed
assignee: claude
blocked_by: [01, 02, 03]
---

## Question

Jaki jest jeden model światła i cienia dla wszystkich źródeł (słońce, niebo, lampy, latarnie, świecące okna), działający bez gałęzi we wnętrzach i w plenerze? W szczególności: jedno niebo pod gołym niebem i przez okna; jeden półcień dla każdego źródła i każdej przesłony; jak łączą się źródła; które wielkości są geometrią (sztywna logika cieni), a które krzywymi artystycznymi w `.tres` (droga słońca w czasie, kolory doby, długość cieni, szerokość półcienia, siła nieba); jak godzina wchodzi do silnika jako jedno wejście dla całego bufora; jak w tym modelu powstają smugi z górnych okien, plama na podłodze i drobinki kurzu w smudze (obowiązkowe, człowiek); czy mgła i atmosfera omijają kwantyzację A′ i czy logika gry odczytuje poziom światła (z „Cienie w pixel arcie w Project Shadowglass”); czy postać dostaje wyjątek od „cień zawsze od źródła” (stały reflektor jak Octopath) i jakie parametry postaci (modelowanie, kontrświatło) oraz zachmurzenie (z „Światło i cienie w Kotwicach i Referencjach”).

## Resolution

2026-11-15. Grilling z człowiekiem. Człowiek ocenia wygląd w grze; szczegóły techniczne (Q1, Q9) zostawił Claude'owi.

1. **Łączenie źródeł:** `E = ambient + Σ kolor_i(Stan doby) × natężenie_i × widoczność_i`, liniowo w HDR, jeden bufor. Bez trybów mieszania, bez kolejności źródeł, bez parametru „kolor cienia”: cień ma kolor tego, co do niego dalej dociera. Ambient to jeden składnik sumy z krzywą doby w `.tres` (research 86 §7).
2. **Źródło światła:** jedno pojęcie, trzy kształty geometrii: kierunkowe (słońce, tarcza o rozmiarze kątowym), kopuła (niebo), powierzchniowe (lampa, latarnia, świecące okno; prostokąt lub kula w metrach, zanik jako krzywa w `.tres`). „Lampa”, „latarnia”, „świecące okno” istnieją tylko w danych, nie w kodzie.
3. **Jedno niebo:** zawsze kopuła; widoczność nieba = niezasłonięta część kopuły, próbkowana kierunkami tak samo wszędzie. Wnętrze ma przesłonę „dach”, więc niebo wpada tylko przez otwory. Zasłaniają wszystkie przesłony (także meble i postać); znika „niebo szyby” i `sky_objects`. Dokładność cienia nieba z okien (ticket 36 mapy grafiki) wynika z liczby próbek; koszt w „Bufor i przeliczanie” (niebo statyczne).
4. **Jeden półcień:** szerokość z geometrii, rozmiar źródła × (przesłona→odbiornik) / (źródło→przesłona), dla każdego źródła i przesłony. Dwa wspólne pokrętła w `.tres`: mnożnik półcienia i maksimum w px ekranu (zastępuje `sun_pen_max` tylko na ulicy). Rozmiar tarczy słońca może mieć krzywą doby.
5. **Stan doby:** jedynym wejściem czasu jest godzina. Z niej raz na klatkę powstaje Stan doby: kierunek słońca z krzywej artystycznej (godzina → wysokość, azymut), kolory i natężenia każdego źródła (także włączanie lamp i świecących okien), ambient, tarcza, zachmurzenie, ekspozycja. Cały bufor, łącznie z oknem wokół postaci, liczy się z jednego Stanu doby. Długość cieni wynika wyłącznie z krzywej wysokości słońca (bez osobnego mnożnika), więc plamy okien i cienie zawsze się zgadzają.
6. **Pogoda:** hack zachmurzenia z game1 (11:00–13:30, osłabiał za mocne okna) usuwamy. Pogoda to jeden stały schemat dobowy (krzywa zachmurzenia w `.tres`, zmiany o określonych godzinach, codziennie taki sam), działający przez dane: słońce × (1−c), niebo jaśniejsze i bielsze, szersza tarcza. Nie jest wejściem od gry. Wartości ustala się przy strojeniu końcowym.
7. **Rozproszenie w powietrzu (smugi, kurz):** plama na podłodze to zwykłe bezpośrednie słońce przez otwór (ta sama widoczność co cienie). Smuga to składnik rozproszenia: całka po słupie powietrza nad punktem (rzut 0,60) z widoczności źródła × gęstość powietrza. Gęstość to dana Lokacji (wnętrze: kurz, plener: mgła albo nic). Drobinki kurzu rysujemy tam, gdzie rozproszenie przekracza próg. Reguła działa dla każdego źródła (promienie między budynkami, stożki latarni we mgle). Człowiek: możliwe wzmocnienie smug i plam we wnętrzach, ale tylko jako wartość zestawu wnętrz w `.tres`, nie logika.
8. **Okna ze wszystkich ścian liczy geometria (zmiana decyzji 27/31 mapy grafiki, człowiek):** Lokacja może mieć okna dookoła; z każdego okna smuga i plama powstają wtedy, gdy wyliczy je silnik. Okna boczne nie mają zakazu plamy (stara zasada wzięła się z tego, że ręczne plamy wyglądały dziwnie). Wygląd plam z okien bocznych idzie do scen testowych.
9. **Stylizacja zależy od rodzaju składnika, nie od sceny (decyzja Claude'a):** A′ (poziomy EV i szew) kwantyzuje tylko oświetlenie powierzchni (suma z p. 1). Rozproszenie w powietrzu dodaje się po kwantyzacji, bez progów, z własną stylizacją (drobinki, ewentualnie rzadki dither), żeby smuga nie robiła pasów poziomów.
10. **Postać bez wyjątku od źródeł:** brak stałego reflektora (Octopath). Postać rzuca cień od wszystkich źródeł i ma cień kontaktowy. Odbiorniki bryłowe (postać i meble) mają trzy parametry w `.tres`: siła modelowania, kontrświatło, wypełnienie (minimum światła na bryle).
11. **Brak odczytu światła dla logiki gry:** żadna mechanika nie używa cienia (bez skradania, bez reakcji na ciemność); cienie są tylko dla wyglądu i klimatu. Silnik nie ma takiego API.
12. **Ekspozycja automatyczna:** mnożnik sumy przed A′, liczony z jasności odniesienia Lokacji (`Y_ref` z research 84) i Stanu doby, przez jedną krzywą w `.tres`. Bez ręcznej ekspozycji na Lokację.

Otwarte dalej: kwantyzacja barwy (jeden kanał luminancji czy chłodny i ciepły) w „Nakładanie cieni z kilku źródeł”.
