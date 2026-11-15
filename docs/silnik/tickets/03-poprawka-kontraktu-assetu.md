---
id: 03
title: Poprawka kontraktu assetu
labels: [ready-for-agent]
status: do sprawdzenia
assignee: claude
blocked_by: [02]
---

## Co zbudować

Wnioski ze „Sprawdzianu assetu w prototypie” wpisane tam, gdzie żyje kontrakt: specyfikacja silnika (kontrakt assetu, Odbiorniki bryłowe, Zestaw strojenia), dopisek do ticketu „Kontrakt danych sceny” mapy silnika i ticket „Przepis mebli” mapy grafiki (wymagania dla generacji: płaskie światło albo inna droga, maska, siatka, normalne, Bryły z tej samej sceny). Jeśli prototyp pokazał, że kontrakt nie działa, stop i rozmowa z człowiekiem o modelu, zanim ruszy silnik.

## Kryteria akceptacji

- [x] Reguła dla pikseli bez ściany Bryły pod spodem rozstrzygnięta i wpisana w kontrakt.
- [x] Wybrana droga generacji (styl spójny z postaciami), pikselizacja, wariant sprite'a (albedo / wypalony) i normalnych zapisane jako wymaganie Przepisu mebli.
- [x] Zmiany w ticketach silnika, jeśli wynikają (np. pola w Zestawie strojenia).
- [x] Bez zmian kodu.

## Jak sprawdzić

Przeczytaj diff specyfikacji i ticketów: wnioski z prototypu zgadzają się z Twoją oceną.

## Wykonanie (2026-11-15, Claude)

Prototyp nie podważył kontraktu (ocena człowieka w tickecie 02: meble wyglądają jak część sceny, cienie od nieba „super”, wybór normalnych z Blendera), więc bez zatrzymania i bez rozmowy o modelu. Zmiany:

- **`docs/silnik/spec.md`:** historyjka 25a (szczegóły poza Bryłami); w „Asset” poprawiony kontrakt: Bryły niewidoczne, sprite = albedo z miękkim namalowanym światłem (bez spłaszczania), punkt zaczepienia na rogu piksela i siatka 1/40 m, pozycja piksela z trafienia linii widzenia (najbliżej kamery), **reguła pikseli bez ściany Bryły** (ponad wierzchem: pionowa płaszczyzna w połowie głębokości wierzchu; reszta: płaszczyzna przodu obrysu Brył), mapa normalnych pokrywa każdy nieprzezroczysty piksel, kodowanie normalnych; w „Odbiorniki bryłowe” odsunięcie 2 cm dla cieni własnych; w „Further Notes” wynik sprawdzianu.
- **Mapa silnika, ticket 08 „Kontrakt danych sceny”:** dopisek doprecyzowujący punkt 4.
- **Mapa grafiki, ticket 13 „Przepis mebli”:** wymagania: droga generacji (Qwen-Image-Edit z szarym renderem i postacią jako wzorem stylu), światło w sprite'cie (miękkie, bez spłaszczania), maska i sito, pikselizacja i paleta 40 kolorów, Bryły i siatka z tej samej sceny Blendera, normalne z Blendera plus **normalne dodatków „nadmuchane” z ich sylwetki** (sprawa otwarta w tickecie 02).
- **Ticket 09:** kryteria dla niewidocznych Brył, pozycji z trafienia, reguły pikseli bez ściany, odsunięcia 2 cm, kodowania i walidacji normalnych.
- **Ticket 10:** obiekt z bogatymi dodatkami i przełącznik ticketu „nadmuchane / stała normalna do kamery” dla normalnych dodatków (wypełnia je narzędzie Przepisu, nie silnik).
- **Zestaw strojenia:** bez nowych pól. Źródło normalnych to dane assetu, siła modelowania to istniejące pole Odbiorników; tryb „pół na pół” z prototypu odpada.

**Decyzja techniczna Claude'a do potwierdzenia w tickecie 10:** normalne dodatków „nadmuchane” z sylwetki to jedna reguła dla każdego dodatku, bez narzędzi zewnętrznych, ale jeszcze nieoglądana w świetle. Jeśli w tickecie 10 wygląda źle, następna droga to estymator normalnych z obrazu generatora (ComfyUI, pytanie przed generacją).
