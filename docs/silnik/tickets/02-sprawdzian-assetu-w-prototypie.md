---
id: 02
title: Sprawdzian assetu w prototypie
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [01]
---

## Co zbudować

Odpowiedź na pytanie człowieka, zanim powstanie silnik: czy mebel wygenerowany tak jak postać, postawiony na uproszczonej Bryle i oświetlony z Bryły, wygląda dobrze. Dwa kroki:

**1. Mebel jak postać (człowiek, 2026-11-15).** Cała grafika ma być jednym stylem, więc mebel powstaje tak jak postacie z Przepisu postaci (`docs/grafika/przepis-postaci.md`): w ComfyUI, w tym samym malarskim, lekko rysunkowym stylu (stały prompt stylu; wzorem stylu może być wygenerowany detektyw albo bibliotekarka), w kącie gry wymuszonym prowadnicą z „Prowadnic v2”, pikselizacja tym samym łańcuchem co postacie. Każdą wersję porównujemy z rzutem z Blendera (sito kąta i sylwetki, jak przy postaciach); odpadają te, które się nie zgadzają. Z tych, które się zgadzają, człowiek dostaje **stronę HTML z kilkoma wersjami obiektu** (obok postaci w tej samej skali) i wybiera asset. Generacji nie przełącza się w F1. Mebli na start 2–3 (np. lada, stół z nogami, kanapa lub fotel); przy kłopotach wystarczy jeden.

**2. Wybrany asset w świetle.** Prototyp do wyrzucenia na gałęzi od `proto-09-nakladanie` (istniejący raycast pudełek, słońce, niebo, lampy, A′): wybrany sprite na Bryle (pozycja z trafienia w ścianę Bryły, normalna ze ściany albo z Blendera), cień z Brył, obok postać. Dzień w słońcu, noc z lampą z boku i z tyłu. Szczegóły techniczne rozstrzyga Claude (człowiek zostawia mu prowadnice, Bryły i cień): co zrobić z namalowanym w sprite'cie światłem, skąd normalne, siła modelowania, piksele bez ściany Bryły pod spodem. Ewentualne kłopoty z Bryłami cienia poprawiamy później, kiedy wyjdą.

## Kryteria akceptacji

- [ ] Przed generacją pytanie do człowieka (co, po co, koszt: lokalnie w ComfyUI, 0 zł); odrzucone obrazy usuwane od razu.
- [ ] Wycięcie tła i cienia generatora (maska z renderu albo jak w Przepisie postaci).
- [ ] Pikselizacja do 40 px/m tym samym łańcuchem co postacie, wyrównana do punktu zaczepienia, bez podwójnych i poszarpanych pikseli; jeden skrypt dla wszystkich mebli.
- [ ] Sito: każda wersja porównana z rzutem z Blendera (kąt, sylwetka, skala); do HTML trafiają tylko zgodne.
- [ ] HTML wyboru: kilka wersji każdego mebla obok postaci, w skali gry i powiększeniu; wybór człowieka zapisany w tickecie.
- [ ] Wybrane meble w prototypie ze światłem i cieniem z Brył, obok postać; bez przełączania generacji w F1.
- [ ] Kod prototypu poza `lighting/` i poza przyszłym addonem; nie trafia do silnika.
- [ ] Zapis oceny człowieka i decyzji technicznych Claude'a w tickecie (do „Poprawki kontraktu assetu”).

## Jak sprawdzić

1. Otwórz HTML wyboru: czy wersje mebla wyglądają jak z tej samej gry co postać i mają ten sam kąt; wybierz po jednej.
2. Uruchom prototyp w dzień i w nocy: czy wybrany mebel wygląda jak część sceny, czy jego cień i światło lampy z boku są wiarygodne.
