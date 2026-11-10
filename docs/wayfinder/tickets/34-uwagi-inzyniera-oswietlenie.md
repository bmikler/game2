---
id: 34
title: Uwagi inżyniera do oświetlenia: co zmienić przed ulicą i NPC
labels: [wayfinder:grilling]
status: open
assignee:
blocked_by: []
---

## Question

Które uwagi z technicznej oceny oświetlenia (`docs/research/80-ocena-oswietlenia-inzynier.md`, krytyk-inżynier, ticket [Cień postaci z mapy światła](33-cien-postaci-z-mapy.md)) przyjmujemy, w jakiej kolejności i czy jako prototyp przed Przepisami, czy jako wymaganie do kodu gry? Przechodzimy je z człowiekiem jedna po drugiej:

1. **A (wysoki): powierzchnia zgadywana z y piksela** → bufor pozycji sprite'ów (x, d, z) zamiast `surface_at`; ważne przed Przepisem mebli (stoły, krzesła, rośliny).
2. **B (wysoki): mapy bez normalnych** → mapa kierunkowa (kierunek + natężenie), N·L w `lit`; od tego zależy sens map normalnych postaci (ticket 22).
3. **C (wysoki): skala na ulicę** → przesłanianie przez mapę wysokości, pokoje i portale, dane w teksturach, kafle map wokół kamery, przeliczanie rozłożone na klatki; prototyp na kwartale z 50+ przesłonami, pomiar w ms (też słabszy sprzęt).
4. **D (wysoki): jedna postać** → capsule shadows w jednym przebiegu, atlas pasków światła postaci; test z 5 NPC.
5. **E (średni): wysokości 7000/7500/7700 jako identyfikator mapy** → globalne uniformy, światło mapy w `fragment()`.
6. **F (średni): spiętrzone pokrętła** → zasób `LightingLook` (.tres) na lokację/porę, kolejność warstw fizyka → mnożniki → ekspozycja; usunięcie przegranych wariantów; tonemap zamiast clampu.
7. **G (średni): przypadki specjalne** (ściana działowa z wymiarów, `room_index` jako najbliższy prostokąt, wstęgi i wielokąty smug) → jawne metadane rodzaju przesłony i otworu.
8. **H (średni): inna reguła cienia postaci i mebli** (lampa liczona dalej, słońce jako punkt tylko dla postaci) — częściowo omawiane w ticket 33 (człowiek: „postać jest cieniowana inaczej niż obiekty”).
9. **I (średni): pudełko za grube dla mebli** → złożone bryły / pusty dół, gizmo, walidator metadanych (łączy się z decyzją o metadanych z ticketu 31).
10. **J (niski): brak odbitego światła** → tani fake GI albo świadomie bez (noir).

Wynik: lista przyjętych zmian z priorytetem i miejscem (prototyp w style-lab / Przepis / kod gry), ewentualnie nowe tickety prototypu.

**Powiązania (2026-11-10):** H prototypujemy w [Jeden model cienia dla postaci i obiektów](35-jeden-model-cienia.md) (tu tylko kolejność). Do G i I dochodzi decyzja z ticketu 31: jakie metadane do mapy światła dostaje każdy mebel i okno w Przepisie (`SunGeometry`: obrys i wysokość mebla, skrzydła okien, `receives` dla schodów). Na wyniku czekają: [Przepis mebli](13-przepis-mebli.md) (A, G, I), [Mapy normalnych postaci](22-mapy-normalnych-postaci.md) (B), [Światło w Poligonach](14-swiatlo-poligony.md) (ulica: C, D).
