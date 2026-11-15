---
id: 02
title: Nakładanie cieni i światła z wielu źródeł w 2D i pixel arcie
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Jak gry 2D i pixel art z dynamicznym światłem łączą światło i cienie z wielu źródeł naraz (słońce, niebo, kilka lamp, świecące okna): addytywnie czy inaczej, jaki kolor ma cień (czarny, kolor nieba, kolor dopełniający), jak cień jednego źródła wygląda w świetle drugiego, co z kolejnością i nasyceniem (clamp, tone mapping, ekspozycja), jak stylizacja do pikseli (progi, dither) radzi sobie z sumą wielu źródeł? Źródła pierwotne: devlogi, GDC, posty autorów, dokumentacja silników 2D (Godot, Unity 2D, własne).

Model: Opus. Wynik: `docs/research/86-*.md`.

## Resolution

2026-11-15. Research: `docs/research/86-nakladanie-swiatla-wielu-zrodel.md` (Opus). Żadna gra pixel art nie opisuje stylizacji sumy wielu źródeł; zalecenia to wnioski z budowy silników 2D i zasad malarskich.

- **Źródła się dodają:** `albedo × (ambient + Σ światło × widoczność)` (Godot `canvas.glsl`, Unity URP 2D, box2dlights). Przy sumie kolejność źródeł nie ma znaczenia.
- **Bez parametru „kolor cienia”:** cień ma kolor sumy źródeł, które do niego nadal docierają (Gurney: pod niebem niebieski, w pochmurny dzień biały). Zgodne z „baza chłodna, ciepło tylko przy źródłach”.
- **Kwantyzacja sumy, nie każdego źródła:** cień słabej lampy w słońcu sam znika po progowaniu A′, przecięcia cieni dają niższy poziom bez dodatkowej logiki. Gotowe `PointLight2D`/Light2D progują per źródło, więc odpadają; potwierdza jeden własny bufor.
- **Kolejność stylizacji:** suma w HDR → ekspozycja jako mnożnik → kwantyzacja w EV → tabela „poziom → jasność i odbarwienie” w `.tres` zamiast clampu RGB (clamp przesuwa barwę).
- **Nowa luka:** A′ kwantyzuje tylko luminancję, więc na styku ciepłej lampy i chłodnego nieba zostaje gładki gradient barwy w jednym poziomie. Kandydat: dwa kanały (chłodny, ciepły) kwantyzowane osobno, kolor z palety 2D (precedens: tabela 16×16 w Minecrafcie, źródła fanowskie). Dotyka kontraktu bufora; do rozstrzygnięcia w „Nakładanie cieni z kilku źródeł” (plik ma 5 scen testowych).
