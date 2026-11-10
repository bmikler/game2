---
id: 07
title: Szkielet projektu style-lab z panelem debug i światłem z game1
labels: [wayfinder:task]
status: closed
assignee: claude
blocked_by: []
---

## Question

AFK. Założyć projekt Godot 4.7.2 `style-lab/` (statyczne typowanie, styl z `~/.claude/CLAUDE.md`; Godot: `C:/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64.exe`) z: postacią-placeholderem sterowaną WASD w 8 kierunkach; przejściem drzwiami między dwiema scenami (plener ↔ wnętrze); portem systemu światła z `reference/game1/lighting/` (kolory z `docs/swiatlo-kolory-game1.md`); panelem debug (F1): suwak godziny i tempo upływu czasu, rejestr przełączników on/off i wariantów (każdy Poligon dorejestrowuje własne), pixel perfect on/off, zrzut ekranu do `style-lab/shots/` z nazwą wariantu i godziną. Rozdzielczość bazowa i px/m jako dane (zasób `.tres`), żeby prototyp Rzutu mógł je przełączać. Bez assetów docelowych, bryły rysowane kodem. Wynik: projekt uruchamiany `run.bat`, krótkie README.

## Resolution

Zrobione (2026-11-08). Projekt `style-lab/` (Godot 4.7.2, Forward+, statyczne typowanie z ostrzeżeniami jako błędami jak w game1). Opis i instrukcja: `style-lab/README.md`.

- Start: `style-lab/run.bat` (gra), `edit.bat` (edytor). WASD/strzałki w 8 kierunkach, F1 panel debug, F12 zrzut.
- Dwie sceny demo: `poligony/demo_ulica.tscn` (plener ze śniegiem, trzy bryły budynków, dwie latarnie na harmonogramie, niebo za fasadami) i `poligony/demo_dom.tscn` (pokój z oknem, lampą stojącą, lampką, zimną poświatą drzwi, meblami-bryłami). Przejście drzwiami w obie strony sprawdzone testem (ulica → dom → ulica → dom).
- Światło: port `reference/game1/lighting/` do `style-lab/lighting/` z kolorami i profilami z `docs/swiatlo-kolory-game1.md` (pliki `.tres` 1:1). Zmiany: px/m z konfiguracji, prostokąty pokoju z `RoomBox`, tryb plenerowy (`outdoor`, `outdoor_night_lux` = 20 lx, wartość robocza), bez `room_shell`/`prop` z game1, rim light niepodpięty.
- Panel debug: suwak godziny, tempo (0–60 min gry/s), pixel perfect on/off, rejestr `DebugRegistry` (każdy Poligon dodaje przełączniki i warianty w `_register_options()`; demo: grading, ziarno, latarnie, kolor śniegu, lampa, kolor ścian), zrzut do `style-lab/shots/<poligon>__<opcje>__<HHMM>.png`.
- Rozdzielczość bazowa (960×540), px/m (40), `depth_factor` (1), wzrost postaci (1,8 m) i prędkość chodu w `style-lab/config/projection.tres`; układ scen podany w metrach, więc prototyp Rzutu przełącza skalę przez `ProjectionConfig.use()` + `Main.reload_world()`.
- Dodatkowo: tryb wsadowy zrzutów bez człowieka, `-- --shots=9,12,16.8,22 [--scene=...] [--spawn=...]`, do arkuszy porównawczych.

Fakty dla kolejnych ticketów: w plenerze nocą ambient wychodzi chłodny i dość jasny (śnieg), latarnie są słabe; ustawienie to sprawa ticketu „Światło w Poligonach”. Widok za oknem to na razie gradienty (dzień, złota godzina, noc). Bloom HDR z game1 daje halo wokół jasnego okna w dzień.
