# Ocena podejścia do oświetlenia (krytyk: inżynier grafiki gier)

Kontekst: ticket „Cień postaci z mapy światła” (33), 2026-11-10. Ocena techniczna podejścia z ticketów 31 i 33 (style-lab), nie code review. Autor: subagent (Opus) na podstawie README style-lab, ticketów 31/33, researchu 79 i kodu `style-lab/lighting/`. Materiał wejściowy, nie decyzje.

## 1. Ocena ogólna

Kierunek dobry i zgodny ze sztuką: analityczna mapa światła z jednego modelu geometrii w metrach, z lokalną dynamiczną poprawką (cień postaci). Wzorzec statyczna mapa przeliczana przy zmianie + dynamiczna nakładka jest typowy dla 2.5D. Deterministyczny, bez szumu w pixel arcie. Słabości: skala i sprzężenie z widokiem (powierzchnia zgadywana z y piksela, sztywne limity tablic, jedna postać, dom jako jedno pudło) oraz narastające pokrętła artystyczne. Na prototyp OK; przed ulicą i NPC do przebudowy.

## 2. Do zachowania

- Jedno źródło prawdy (`sun_geometry.gd`): skrzydła, pudełka, ściany w metrach; z tych samych danych plama, smuga, kurz, światło postaci.
- Niebo jako współczynnik kształtu wielokąta (Lambert, `sun_map.gdshader`): poprawna technika światła powierzchniowego, gładka.
- Podział statyczne/dynamiczne: mapy przy zmianie, cień postaci jako „utracone światło” w oknie 320×320 (~1 ms zamiast 6 ms); widoczność cienia zgodna z próbkami plamy.
- Jednostki fizyczne (luksy, ekspozycja na przestrzeń, HDR 2D) i pomiary kadru względem game1.
- Proces: warianty na żywo, presety krytyka, decyzje w tickecie.

## 3. Problemy i ryzyka

| | Problem | Dlaczego | Propozycja | Priorytet |
|---|---|---|---|---|
| A | Powierzchnia odtwarzana z y piksela (`surface_at`: podłoga, tylna ściana, przód i wierzch pudełek) | Nieregularne sprite'y (krzesło, roślina, stół na nogach) dostają światło pudełka albo podłogi za nimi; nakładające się obiekty czytają ten sam piksel; pod stołem brak światła | Bufor pozycji (G-buffer 2.5D): każdy oświetlany sprite zapisuje (x, d, z) z kotwicy i gradientu/mapy wysokości; mapa czyta bufor (deferred) | wysoki, przed produkcją mebli |
| B | Mapy bez normalnych (`lit.gdshader`: światło mapy bez N·L; pasek postaci zależy tylko od wysokości) | Lampa z lewej nie oświetla lewego boku; mapy normalnych (ticket 22) nic nie dadzą w świetle mapy | Mapa kierunkowa (dominujący kierunek + natężenie, jak directional lightmaps / SH L1): druga tekstura, N·L w `lit` | wysoki dla postaci i NPC, średni dla rekwizytów |
| C | Skala: limity uniformów (64 skrzydła, 63 pudełka, 4 pokoje, 16 lamp), pętla po wszystkich pudełkach na promień, `sky_share` 4 promienie × pudełka × skrzydła, skorupa jako jedno AABB | Na ulicy koszt rośnie liniowo z przesłonami; skok czasu klatki przy zmianie godziny | Raymarch po mapie wysokości (stały koszt; też cienie budynków i zasłanianie nieba na ulicy); pokoje i portale; dane w teksturach; kafle map wokół kamery z cache; przeliczanie na kilka klatek albo mieszanie dwóch map co ~15 min gry | wysoki (blokuje ulicę) |
| D | Jedna postać na sztywno (pasek, okno cienia, uniformy) | NPC = N × 3 okna co klatkę; dwa nakładające się cienie mogą odjąć to samo światło dwa razy; brak cieni postaci na siebie | Capsule shadows (Naughty Dog, UE): widoczność mnożona per źródło dla listy pobliskich kapsuł w jednym przebiegu; paski postaci w atlasie | wysoki dla NPC |
| E | Wysokości 7000/7500/7700 jako identyfikator mapy w `lit.gdshader` | Kruche (obejście braku `ViewportTexture` w `PointLight2D`); 3 dodatkowe światła na sprite | `global uniform sampler2D` i światło mapy w `fragment()`; Light2D tylko dla świateł lokalnych | średni |
| F | Spiętrzone pokrętła (44 `static var` w `sun_map.gd`, statyki `RoomLighting`, presety jako słowniki); mnożniki kompensują się nawzajem | Strojenie nieortogonalne, wierne tylko dla jednego domu i pory | Zasób `LightingLook` (.tres) na lokację/porę z kolejnością warstw: fizyka → mnożniki artystyczne → ekspozycja; usunąć przegrane warianty; jeden tonemap (Reinhard rozszerzony / AgX) zamiast clampu w `display.gdshader` + knee w `Exposure` | średni |
| G | Przypadki specjalne wbrew „jednej regule”: wstęgi boczne (osobny shader), wielokąty smug tylnych, ściana działowa wykrywana z wymiarów, `room_index` jako najbliższy prostokąt, ściany działowe zasłaniają, ale nie są powierzchnią, `sky_other_k` | Nowy układ domu może to złamać | Rodzaj przesłony i otworu jako jawne metadane (mebel / ściana działowa / nadproże / schody / drzwi); odstępstwa widokowe jako reguła przekroju | średni |
| H | Cień postaci inny niż mebli (lampa liczona dalej, długość, słońce jako punkt tylko dla postaci) | Krzesło obok postaci przy tej samej lampie rzuci inny wachlarz | Ta sama reguła dla wszystkich przesłon, np. minimalna efektywna wysokość źródła względem przesłony | średni |
| I | Produkcja assetów: metadane lekkie (`size_m`, `lift_m`, `receives`, skrzydła, `map_source`), ale pudełko za grube dla stołów i krzeseł | Złe cienie i światło pod meblami | Opcjonalnie 2–3 pudełka albo pudełko z pustym dołem; gizmo w edytorze; walidator (brak AABB, przesłona poza pokojem, limity) | średni |
| J | Brak odbitego światła (plama słońca nie rozjaśnia otoczenia; płaski ambient) | Mniej wiarygodne wnętrza | Tani fake GI: zmniejszona i rozmyta mapa jako „bounce” w kolorze podłogi; radiance cascades nadal przerost (zgodnie z researchem 79) | niski (noir może tego nie chcieć) |

## 4. Rekomendacje na następny krok

1. Przed ulicą: prototyp przesłaniania przez mapę wysokości i portale na kwartale z 50+ przesłonami; czas przeliczenia mapy w ms GPU, też na słabszym sprzęcie (Steam Deck / iGPU).
2. Bufor pozycji sprite'ów i mapa kierunkowa: test na jednym nieregularnym meblu i na postaci z mapą normalnych.
3. Wiele postaci: capsule shadows w jednym przebiegu i atlas pasków; test z 5 NPC.
4. Porządek w strojeniu: `LightingLook`, tonemap zamiast clampu, usunięcie wariantów odrzuconych w ticketach 31/33.
5. Specyfikacja metadanych mebla, okna i lampy z walidatorem (decyzja z ticketu 31 do Przepisu).
