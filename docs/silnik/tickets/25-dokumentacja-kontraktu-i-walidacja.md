---
id: 25
title: Dokumentacja kontraktu sceny i ostrzeżenia w edytorze
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [23, 24]
---

## Co zbudować

Dokumentacja kontraktu sceny w addonie, wystarczająca do zbudowania Lokacji wnętrza, pleneru i assetu bez czytania kodu silnika (w tym droga assetu z „Prowadnic v2”). Ostrzeżenia w edytorze: Otwór poza Ścianą, Źródło w Bryle, brak lub kilka Otoczeń Lokacji, Bryła o zerowym wymiarze itd.

## Kryteria akceptacji

- [ ] Jeden plik dokumentacji: węzły, pola, jednostki, rzut, południe u góry, asset, profile, Zestawy, Warianty, typowe układy.
- [ ] Ostrzeżenia z testami.
- [ ] Świeży subagent z samą dokumentacją buduje małą scenę próbną; braki dopisane.

## Jak sprawdzić

W edytorze wysuń Otwór poza Ścianę i wstaw Źródło w Bryłę: ostrzeżenia. Przeczytaj dokumentację.
