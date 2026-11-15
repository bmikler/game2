---
id: 12
title: Warianty strojenia
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [11]
---

## Co zbudować

Strojenie wyłącznie Wariantami krytyków: katalog z kopiami dowolnych plików strojenia (brakujący = bazowy) i opisem w jednym zdaniu. Przełącznik Wariantów w panelu silnika, nowe Warianty wczytywane bez restartu. `--set=<zasób>.<pole>=<wartość>` po nazwie i `--wariant=nazwa`.

## Kryteria akceptacji

- [ ] Nakładanie Wariantu na bazę (testy).
- [ ] Przełączenie na żywo przelicza tylko to, co trzeba.
- [ ] Nowy katalog Wariantu widoczny bez restartu.
- [ ] `--set=` i `--wariant=` (testy parsowania); Wariant w opisie zrzutu.
- [ ] Bez suwaków i zapisu z F1.
- [ ] Dwa Warianty testowe, usuwane po „ok”.

## Jak sprawdzić

Uliczka o 16:30: przełączaj bazowy / testowy A / testowy B, obraz zmienia się od razu. Skopiuj katalog Wariantu przy uruchomionej grze: pojawia się w F1.
