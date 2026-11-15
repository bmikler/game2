---
id: 05
title: Zrzut z opisem stanu
labels: [ready-for-agent]
status: closed
assignee:
blocked_by: [04]
---

## Co zbudować

Przycisk „Zrzut” w panelu silnika i F12 zapisują PNG z opisem stanu (scena, godzina, Wariant, pozycja postaci, przełączniki), ścieżka trafia do schowka. `--z-zrzutu=plik` odtwarza tę samą klatkę.

## Kryteria akceptacji

- [x] Przycisk i akcja z Input Map zapisują PNG + opis.
- [x] Ścieżka w schowku systemowym.
- [x] `--z-zrzutu=plik` odtwarza scenę, godzinę i przełączniki (test zgodności opisu).
- [x] Część addonu, bez zależności od debugu `style-lab`; Poligon dopisuje swoje przełączniki.

## Jak sprawdzić

Poligon Ulica o 7:30, F12, wklej ścieżkę Claude'owi; Claude odtwarza klatkę z `--z-zrzutu` z tą samą godziną.

## Wykonanie (2026-11-15, Claude)

- Addon: `style-lab/addons/swiatlo/shot/`. `ShotDescription` (opis stanu: scena, godzina, tempo, Wariant, pozycja postaci, przełączniki; JSON obok PNG, ta sama nazwa) i węzeł `EngineShot` (akcja `screenshot` z Input Map, czyli F12, oraz `take()` dla przycisku „Zrzut (F12)” w panelu silnika). Ścieżka PNG (bezwzględna) trafia do schowka i pod przycisk w F1.
- Poligon dopisuje swoje przełączniki przez `add_switch(nazwa, odczyt, ustawienie)`; Poligon Ulica dopisał „kadr”. Zrzuty Poligonu: `style-lab/shots/engine/` (w `.gitignore`).
- Odtworzenie: `godot --path style-lab res://addons/swiatlo/shot/replay.tscn -- --z-zrzutu=<png albo json> [--wyjdz]`. `replay.tscn` otwiera scenę z opisu, `EngineShot` ustawia godzinę, przełączniki i postać, zatrzymuje czas i zapisuje obok `<zrzut>__odtworzenie.png` (+ opis), żeby Claude zobaczył klatkę; z `--wyjdz` kończy program (kod 1 przy braku opisu albo innej scenie). Można też uruchomić od razu scenę Poligonu z `-- --z-zrzutu=…`.
- Wariant: pole w opisie jest, ale zawsze puste do ticketu 12 (Warianty); odtworzenie z niepustym Wariantem tylko ostrzega. Postać: pole `character` w `EngineShot`; Poligon Ulica nie ma jeszcze postaci (ticket 17).
- Testy: `node tools/test.mjs` (z `style-lab`): 54 zielone, w tym zapis PNG + opisu, schowek, F12 (akcja), przycisk panelu, zgodność opisu po odtworzeniu w świeżym Poligonie (godzina 19:45, kadr 640×360). Ręcznie: `replay.tscn` z opisem 7:30 / 640×360 dał klatkę 640×360 i opis zgodny z oryginałem.
- Znane drobiazgi: po odtworzeniu suwak tempa w F1 nie pokazuje zatrzymanego czasu (godzina tak).

### Ocena człowieka

2026-11-15: bez ręcznego sprawdzania („jak przetestowałeś, że screeny działają, to jest git”); wystarcza test Claude’a (zapis, schowek, odtworzenie 7:30 / 640×360).
