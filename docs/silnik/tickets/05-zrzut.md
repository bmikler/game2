---
id: 05
title: Zrzut z opisem stanu
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [04]
---

## Co zbudować

Przycisk „Zrzut” w panelu silnika i F12 zapisują PNG z opisem stanu (scena, godzina, Wariant, pozycja postaci, przełączniki), ścieżka trafia do schowka. `--z-zrzutu=plik` odtwarza tę samą klatkę.

## Kryteria akceptacji

- [ ] Przycisk i akcja z Input Map zapisują PNG + opis.
- [ ] Ścieżka w schowku systemowym.
- [ ] `--z-zrzutu=plik` odtwarza scenę, godzinę i przełączniki (test zgodności opisu).
- [ ] Część addonu, bez zależności od debugu `style-lab`; Poligon dopisuje swoje przełączniki.

## Jak sprawdzić

Poligon Ulica o 7:30, F12, wklej ścieżkę Claude'owi; Claude odtwarza klatkę z `--z-zrzutu` z tą samą godziną.
