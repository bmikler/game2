---
id: 15
title: Podgląd światła w edytorze
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [06]
---

## Co zbudować

Bufor światła w edytorze Godota: przesuwasz kamienicę (myszą po podłodze x, d; wysokość w inspektorze), cień od razu idzie za nią. Godzina i tryb podglądu to pola kontrolera; render tylko po zmianie.

## Kryteria akceptacji

- [ ] Węzły kontraktu i kontroler jako `@tool`; ten sam kod w grze i edytorze.
- [ ] Przeliczenie tylko po zmianie.
- [ ] Przeciąganie zmienia x, d, nie pozycję ekranową.
- [ ] Zapisany `.tscn` zawiera tylko węzły kontraktu.

## Jak sprawdzić

Poligon Ulica w edytorze, godzina podglądu 10:00, przeciągnij kamienicę: cień idzie za nią. Zapisz i obejrzyj diff `.tscn`.
