---
id: 28
title: Schody w pomieszczeniach i wejście na piętro
labels: [wayfinder:prototype]
status: open
assignee:
blocked_by: []
---

## Question

Jak w rzucie niskie 3/4 pokazać schody wewnątrz domu i przejście między kondygnacjami? Na Poligonie Dom (`style-lab/dom.bat`) schody działają słabo (ocena człowieka 2026-11-09). Teraz to bieg wzdłuż lewej ściany korytarza, wznoszący się w głąb, ucięty sufitem (2,2 m), a wejście w dwa dolne stopnie od razu przełącza scenę na piętro; na piętrze otwór klatki z balustradą i zejście przez górne stopnie z tyłu. Do rozstrzygnięcia: gdzie i jak stoi bieg (czołowy, boczny, zabiegowy, wzdłuż ściany tylnej czy bocznej), jak go rysować pod sufitem przekroju, czy gracz idzie po stopniach (schodkowe przesunięcie sprite'a jak na ulicy) i w którym miejscu następuje zmiana kondygnacji (próg, wygaszenie, przejście kamery), jak wygląda otwór klatki na piętrze i zejście, jak to współgra z oknem i światłem korytarza. Decyzja człowieka: wariant schodów i przejścia, grany na Poligonie Dom.

Punkt wyjścia: research [Jak pokazać wchodzenie po schodach i progach w rzucie 3/4](24-schody-zmiana-poziomu-research.md) (`docs/research/77-schody-zmiana-poziomu.md`) i schody z [Poligonu Ulica w bryłach](10-poligon-ulica-bryly.md) (A czołowe, B boczne, przesunięcie 8 px na stopień, wolniejszy chód); kod: `_flight`, `_stairwell` w `style-lab/poligony/dom_bryly.gd`, `_front_stairs`, `_side_stairs` w `style-lab/poligony/ulica_bryly.gd`. Jeśli żaden wzorzec z 77 nie pasuje do schodów wewnątrz, najpierw krótki research (gry 3/4 z piętrami: Stardew, Eastward, Graveyard Keeper, To the Moon, Children of Morta).
