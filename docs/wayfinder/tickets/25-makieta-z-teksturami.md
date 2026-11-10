---
id: 25
title: Makieta ulicy i wnętrza z teksturami: ostateczny rozmiar fasady i rozdzielczość
labels: [wayfinder:prototype]
status: open
assignee:
blocked_by: [11, 13, 23]
---

## Question

Rozmiar fasady (piętro 1,6 czy 1,3 × postać) i rozdzielczość (40 px/m, postać 72 px, kadr 960×540) są dziś roboczo ustalone na bryłach. Człowiek rozstrzygnie je dopiero na makiecie z teksturami: kawałek ulicy (dom, sklep, fasada w głębi, teren, śnieg) i jedno wnętrze, z pierwszymi assetami z Przepisów (postać z Przepisu postaci, meble z Przepisu mebli, fasady i teren z próby Pixellab albo innej drogi z Przepisu budynków), w obu wariantach piętra i w dzień i w nocy.

Punkt wyjścia: Poligon Ulica w bryłach (`style-lab/poligony/ulica_bryly.gd`: głębia budynków 50%, dachy mieszane, schody A/B) i Poligon Dom w bryłach. Wynik: ostateczne stałe do `PROJECTION.md` (piętro fasady, px/m, ewentualnie zmiana rozdzielczości) albo potwierdzenie obecnych.