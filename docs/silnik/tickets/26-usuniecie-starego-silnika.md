---
id: 26
title: Usunięcie starego silnika
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [19, 21, 22, 23, 24]
---

## Co zbudować

Po „ok” człowieka dla obu nowych Poligonów: usunięte stary `lighting/`, zależne klasy `world/`, `rzut_*`, `demo_*`, stare Poligony i ich `.bat`, stare bramki (`bufor_roznica.mjs`, `bufor_ulica_*`, `cien_nieba_*`); `main/` przechodzi na nowe Poligony. Ogólne narzędzia pomiaru zostają.

## Kryteria akceptacji

- [ ] „Ok” człowieka dla Poligonu Ulica i Poligonu Dom.
- [ ] Projekt bez błędów, `node tools/test.mjs` zielone.

## Jak sprawdzić

Uruchom grę: start wybiera nowe Poligony, oba działają jak przed usunięciem.
