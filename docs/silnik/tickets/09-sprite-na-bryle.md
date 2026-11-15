---
id: 09
title: Oświetlenie sprite'ów na Bryłach
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [07, 08]
---

## Co zbudować

Odbiorniki bryłowe w silniku według kontraktu poprawionego w „Poprawce kontraktu assetu”: piksel sprite'a leży na widocznej ścianie swojej Bryły (reguła dla pikseli bez ściany pod spodem z tamtego ticketu), normalna z mapy normalnych albo ze ściany Bryły, ten sam kod w obu przypadkach. Modelowanie, kontrświatło, wypełnienie z Zestawu strojenia. Sprite nie rzuca cienia. Na Uliczce skrzynia i ławka z prostymi sprite'ami.

## Kryteria akceptacji

- [ ] Asset jako scena: sprite, Bryły, punkt zaczepienia, opcjonalnie mapa normalnych i przyczepione Źródła.
- [ ] Wczytanie Brył i punktu zaczepienia z eksportu „Prowadnic v2”.
- [ ] Bramka: strona Bryły zwrócona do słońca jaśniejsza niż odwrócona; z mapą normalnych i bez.
- [ ] Parametry Odbiorników w Zestawie, punkty startowe z prototypu.

## Jak sprawdzić

Uliczka 9:00 i 15:00: skrzynia i ławka jaśniejsze od strony słońca, cień zgodny z obrazem, w cieniu kamienicy oświetlone niebem.
