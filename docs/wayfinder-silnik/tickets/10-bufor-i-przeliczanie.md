---
id: 10
title: Bufor i przeliczanie
labels: [wayfinder:grilling]
status: closed
assignee: claude
blocked_by: [07, 04]
---

## Question

Jak Silnik światła trzyma i przelicza bufor: jedno ujęcie stanu światła (godzina, źródła) dla całego bufora, okno wokół postaci, pasy, rozdzielczość bufora względem sprite'ów (×1–×3), duże Lokacje (kafle?), budżet ms przy >60 fps, i czy któraś część idzie do C++? Punkt wyjścia: research „C++ (GDExtension) czy shadery” (statyczne osobno od ruchomych, kafle, compute). Wejście z „Nakładanie cieni z kilku źródeł”: bufor niesie dwa kanały światła (naturalny, sztuczny), a niebo przy małej liczbie stałych próbek daje prążki.

**Z „Kontrakt danych sceny” (08):** wiele ruchomych Przesłon (NPC z rutynami, samochód) i ruchome Źródła (reflektory, papieros z animowanym natężeniem); brak stałych limitów w kontrakcie, limity i koszt ustala ten ticket; samochód z reflektorami i podwyższenia podłogi to ozdoby do skreślenia, jeśli drogie.

## Resolution

2026-11-15. Grilling z człowiekiem. Człowiek rozstrzygnął upływ czasu, zakres i budżet; architekturę bufora zostawił Claude'owi (punkty 1–7).

1. **Rozdzielczość:** 1 px bufora = 1 px gry (×1); światło drobniejsze niż piksel sprite'a łamie pixel art. Rozproszenie w powietrzu (smugi) w ½ rozdzielczości, drobinki kurzu w pełnej.
2. **Bufor to warstwy według tego, kiedy co się zmienia** (wszystkie z kanałem naturalnym lub sztucznym z „Nakładanie cieni z kilku źródeł”); co klatkę tylko składanie warstw z mnożnikami ze Stanu doby:
   - **niebo:** widoczność kopuły zależy tylko od geometrii, liczona raz przy wczytaniu Lokacji z tysiącami próbek narastająco przez kilka klatek (koniec prążków i duchów okien); kolor i siła nieba to mnożnik ze Stanu doby;
   - **nieruchome Źródła powierzchniowe:** światło przy natężeniu 1 liczone raz przy wczytaniu; jedna warstwa na grupę Źródeł o tym samym profilu i tym samym mnożniku animacji (wszystkie latarnie jednego profilu dzielą warstwę, papieros i neon mają swoją); włączanie, gradienty doby i animacja to tylko mnożniki;
   - **słońce:** widoczność przeliczana kaflami rozłożonymi na klatki dla bieżącej godziny, stary i nowy stan przenikają się płynnie (bez skoku pasów); przy przewijaniu doby cienie doganiają godzinę z opóźnieniem ok. ¼ s (człowiek: akceptuje);
   - **ruchome Przesłony** (postać, NPC, samochód): co klatkę, tylko w oknie wokół każdej i tylko dla Źródeł w zasięgu; ich cień mnoży gotowe warstwy; zasłonięcie nieba przez ruchomą Przesłonę wzorem, bez próbek; powierzchnie ruchomej Przesłony (postać) liczone co klatkę ze wszystkich Źródeł (zastępuje pasek postaci `ACTOR_STRIP`);
   - **ruchome Źródła** (reflektory, niesiona lampa): co klatkę w swoim zasięgu, tą samą funkcją.
   Okna liczone tylko, gdy przecinają kadr. Ten sam Stan doby dla wszystkich warstw w klatce.
3. **Przycinanie kaflami:** każdy kafel (rząd 32×32 px) ma listę Brył i Źródeł, które mogą na niego wpłynąć; koszt piksela nie rośnie z rozmiarem Lokacji. Bufor obejmuje całą Lokację (obszar z Brył); Lokacja większa niż limit tekstury to osobne Lokacje.
4. **Technika:** shadery `canvas_item` w SubViewportach, listy kafli w teksturach danych; działa w podglądzie edytora (research 06) i w bramkach buforów. Bez C++ (GDExtension). Compute shader (RenderingDevice z GDScriptu) tylko, gdy bramka wydajności nie zmieści budżetu.
5. **Budżet (człowiek: gra ma mieć 60 fps na słabszym sprzęcie niż jego):** na RTX 4060 Laptop światło w ruchu ≤ 4 ms GPU na klatkę (zapas na ok. 3× słabszą kartę), CPU silnika ≤ 1 ms; przeliczanie nieba i nieruchomych Źródeł przy wczytaniu ≤ 2 s dla Lokacji wielkości Poligonu Ulica (człowiek: na razie wystarczy). Bez wypiekania w edytorze (nieaktualny wypiek łatwo przeoczyć). Bramka wydajności w scenach testowych.
6. **Cel obciążenia (człowiek):** najbardziej zatłoczony kadr miasta: do 8 postaci, 1 samochód, do 4 kołyszących się drzew naraz. Więcej działa, bez gwarancji 60 fps. Samochód z reflektorami i podłoga na różnych wysokościach zostają (w tym modelu tanie: reflektor to ruchome Źródło, podwyższenie to wierzch Bryły).
7. **Wiatr (człowiek: drzewa to głównie iglaki, drobna ozdoba klimatu):** Przesłona ma opcjonalne wychylenie od wiatru (w metrach); taka Przesłona idzie ścieżką ruchomych Przesłon, a jej pozycję daje wspólny wiatr Lokacji (bez kodu pod drzewa). Do oceny na żywo w scenie testowej: A (cień stały, kołysze się tylko sprite) i B (cień kołysze się z koroną). Jeśli B okaże się trudne albo drogie, zostaje A. Migotanie cienia liści (przepuszczalność z teksturą) odłożone do ozdób.

Do „Strategia testów i sceny testowe”: bramka wydajności (cel z p. 6, budżet z p. 5, czas wczytania), scena porównania wiatru A/B, przewijanie doby (płynne doganianie cieni słońca), niebo bez prążków we wnętrzu.
