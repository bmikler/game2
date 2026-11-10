---
id: 35
title: Jeden model cienia dla postaci i obiektów
labels: [wayfinder:prototype]
status: open
assignee:
blocked_by: []
---

## Question

Jak ma wyglądać jeden wspólny model cienia, żeby postać i obiekty (meble, ściany działowe, schody) rzucały cień tak samo od każdego źródła (słońce, niebo z okien wszystkich ścian, lampy, noc)? Wymaganie człowieka z ticketu [Cień postaci z mapy światła](33-cien-postaci-z-mapy.md): „cienie postaci i obiektów muszą działać tak samo”; wygląd cieni: gładki albo 3 poziomy z ditherem (wybór na makiecie z teksturami).

Stan wyjścia (ticket 33, preset A4): postać ma osobne reguły (lampa liczona dalej ×1,4, długość ×1,6, słońce jako punkt 10 m, gradient przez miękkość, analityczne zasłanianie nieba, AO pod stopami, kwantyzacja z ditherem tylko dla postaci, okno cienia 320×320 odejmowane od map); meble zasłaniają niebo binarnie (4 promienie), słońce i lampy próbkami tarczy/żarówki, cień twardy i pikselowy. Do sprawdzenia w Poligonie Dom: jedna reguła dla wszystkich przesłon (np. minimalna efektywna wysokość źródła względem przesłony zamiast „lampa liczona dalej” tylko dla postaci; ten sam wzór zasłaniania szyby, analityczny albo binarny; ta sama kwantyzacja i dither); czy artystyczne odstępstwa A4 (krótszy, wolniej rozszerzający się cień) przenieść na meble, czy z nich zrezygnować. Przy okazji: cień nieba postaci na ścianie z oknem i ostry prostokąt na przodzie mebla za postacią (wygasić z wysokością), „kierunkowy cień nieba” od każdego okna (propozycja krytyka). Koszt: jedno okno cienia dla wszystkich ruchomych przesłon vs mapy liczone przy zmianie. Powiązane: uwaga H w [Uwagi inżyniera do oświetlenia](34-uwagi-inzyniera-oswietlenie.md) (capsule shadows, wiele postaci).

Decyzja człowieka: wspólny model cienia (reguła długości i rozszerzania, wzór nieba, miękkość, wygląd), który trafi do Przepisu i na ulicę.


## Notatka dla następnej sesji (2026-11-10)

Repo git (lokalne): `main` = stan sprzed ticketu 35 (cień postaci A4 z ticketu 33, meble twardo w mapie). Gałąź `t35-wersja1-bledna` = pierwsza próba, **odrzucona przez człowieka** („cienie totalnie zbugowane”, najlepiej widać w F1 „Cień postaci: wygląd” = 2 poziomy twarde; zrzuty `style-lab/shots/t35/z_h.png`, poza repo). Pracuj na nowej gałęzi od `main`, każdy krok osobnym commitem.

Czego nie powtarzać (błędy wersji 1):
- Osobne przybliżenia tylko dla mebli (prostokąty kątowe nieba dla pudełek, kotwice A4 w środku podstawy, wyjątki „własna ściana”): dały czarne plamy i artefakty.
- Wygląd kwantyzował jeden wspólny „udział cienia” dla słońca, lamp i nieba naraz (alfa map domu): szeroki, miękki cień nieba powyżej 50% robił się czarny w trybie twardym.

Kierunek uzgodniony z człowiekiem: **ustawienia postaci (A4) działają na wszystkie obiekty, wszystko liczone jedną mapą.**
1. Jedna funkcja cienia w mapie dla wszystkich przesłon (meble jak dziś + postać jako walec), z regułami A4 (lampa liczona dalej ×1,4, długość ×1,6, słońce jako punkt 10 m, miękkość rosnąca z odległością od przesłony). Postać: dalej okno 320×320 co klatkę albo cała mapa co klatkę (człowiek: 100 kl./s wystarczy, optymalizacja dopiero w grze).
2. Niebo jednym sposobem dla postaci i mebli (bez osobnego przybliżenia dla mebli).
3. Wygląd (poziomy, dither) osobno dla każdego źródła (słońce, lampy, niebo), nie na jednym wspólnym udziale.
4. Każdą wersję najpierw sprawdzić na „2 poziomy twarde” (`--set=` z rozpisanym presetem A4 i `cienie_krytyk=0,cien_wyglad=2`, bo preset A4 przy starcie nadpisuje wygląd), porównać z `main` i dopiero potem pokazać człowiekowi.

Narzędzia: zrzuty `--shots=9.5,12.5,22 --at=3.2,1.6` (przy oknie) i `--at=1.6,1.2` (przy lampie), koszt `--bench=godzina`, wycinek `tools/pomiar/kadr.mjs`, różnica `tools/pomiar/roznica.mjs`. Godot: `C:/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64.exe`.
