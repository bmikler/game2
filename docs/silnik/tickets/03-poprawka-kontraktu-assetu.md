---
id: 03
title: Poprawka kontraktu assetu
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [02]
---

## Co zbudować

Wnioski ze „Sprawdzianu assetu w prototypie” wpisane tam, gdzie żyje kontrakt: specyfikacja silnika (kontrakt assetu, Odbiorniki bryłowe, Zestaw strojenia), dopisek do ticketu „Kontrakt danych sceny” mapy silnika i ticket „Przepis mebli” mapy grafiki (wymagania dla generacji: płaskie światło albo inna droga, maska, siatka, normalne, Bryły z tej samej sceny). Jeśli prototyp pokazał, że kontrakt nie działa, stop i rozmowa z człowiekiem o modelu, zanim ruszy silnik.

## Kryteria akceptacji

- [ ] Reguła dla pikseli bez ściany Bryły pod spodem rozstrzygnięta i wpisana w kontrakt.
- [ ] Wybrana droga generacji (styl spójny z postaciami), pikselizacja, wariant sprite'a (albedo / wypalony) i normalnych zapisane jako wymaganie Przepisu mebli.
- [ ] Zmiany w ticketach silnika, jeśli wynikają (np. pola w Zestawie strojenia).
- [ ] Bez zmian kodu.

## Jak sprawdzić

Przeczytaj diff specyfikacji i ticketów: wnioski z prototypu zgadzają się z Twoją oceną.
