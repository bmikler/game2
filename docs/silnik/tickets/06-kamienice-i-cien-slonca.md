---
id: 06
title: Kamienice i cień słońca
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [04]
---

## Co zbudować

Odcinek Uliczka: rząd kamienic od południa (pudełka) z prześwitem 2 m rzuca ostry cień słońca na ulicę, fasady (Odbiorniki) oświetlone zgodnie z kierunkiem słońca. Pierwsza wersja Bufora światła (×1, cała Lokacja, kanał naturalny w HDR) i Opisu sceny (Bryły → Odbiorniki, obszar Bufora).

## Kryteria akceptacji

- [ ] Węzły Przesłona i Bryła (pudełko) w metrach, pozycja z rzutu.
- [ ] Opis sceny jako czysta logika (Odbiorniki, obszar), testy.
- [ ] Jedna funkcja widoczności, używana później przez wszystkie Źródła.
- [ ] Bramka: cień po przeciwnej stronie niż słońce.
- [ ] Widok debug: brak / Bryły / Odbiorniki.

## Jak sprawdzić

Uliczka, 8:00 → 16:00: cień kamienic sunie po ulicy z lewej na prawą, w prześwicie pas słońca. Widok debug „Bryły” pokrywa się z kamienicami.
