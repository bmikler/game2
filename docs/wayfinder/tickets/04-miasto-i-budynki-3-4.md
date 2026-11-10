---
id: 04
title: Miasto i budynki w 3/4: głębia ulicy, skala budynku z zewnątrz i wnętrza, zgodność okien
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Jak gry pixel art 3/4 (Chef RPG jako wzorzec układu, też Stardew, Eastward, Fields of Mistria, Sun Haven, Graveyard Keeper, Project Zomboid i inne) budują ulicę i miasteczko: głębia bez ustawiania budynków jeden za drugim (uskoki, poziomy, płoty, drzewa), wysokość fasad i dachów względem postaci, ile budynków mieści się w kadrze. Jak skalują budynek z zewnątrz względem wnętrza („większy w środku”): typowe proporcje, czy zgadza się liczba i kolejność okien, położenie drzwi, kształt bryły; czy widok za oknem wnętrza odpowiada ulicy. Wynik: `docs/research/63-*.md` z regułami do przyjęcia na Poligonie Ulica i Poligonie Dom (nie powtarzać `43`, `43b`, `53`, `54`; uzupełniać).

## Resolution

- Głębię ulicy robi się pionem (tarasy, murki, schody, skrzyżowanie T, elementy wypełniające), nie rzędem budynków; w kadrze 3 budynki różnej szerokości (ok. 3, 5, 9-10 wysokości postaci), przesunięte w pionie o 0,5-1,5 WP, z różnymi dachami (Eastward, Mistria, Sun Haven, Stardew).
- Fasada: ściana 1,3-1,9 WP, drzwi 1,1-1,75 WP, dach 2-2,5 WP (szacunek z oka z oficjalnych zrzutów, ±15%).
- Wnętrze jest ok. 1,9x szersze niż fasada (Le Sequoia, Chef RPG), okno wnętrza ok. 1,35x większe, ale w tym samym stylu; liczba okien nie musi się zgadzać, bo ściany tylnej z ulicy nie widać. Zgodne mają być styl, okna i kolejność na fasadzie południowej oraz oś X drzwi.
- Okno tylne wnętrza pokazuje tył budynku (podwórko, las), nie ulicę; brak dev-logów twórców, więc liczby wymagają sprawdzenia na Poligonach.
- Notatka: `docs/research/63-miasto-budynki-glebia-skala.md` (zrzuty w `63-assets/`).
