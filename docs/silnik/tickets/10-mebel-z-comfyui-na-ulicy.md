---
id: 10
title: Mebel z ComfyUI na Ulicy
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [09]
---

## Co zbudować

Drugi sprawdzian kontraktu assetu, tym razem w prawdziwym silniku: obiekt z pełnej ścieżki „Prowadnic v2” + ComfyUI w wariancie wybranym w prototypie (np. ławka, skrzynia, stragan) stoi na Uliczce. Obiekt ma bogate dodatki spoza modelu z Blendera (przedmioty na blacie, narzuta), bo tu sprawdzamy normalne dodatków z Przepisu mebli (ticket 13 mapy grafiki: „nadmuchane” z sylwetki dodatku). Ma wyglądać jak w prototypie bez żadnej zmiany w kodzie silnika pod ten obiekt.

## Kryteria akceptacji

- [ ] Przed generacją pytanie do człowieka (co, po co, koszt); odrzucone obrazy usuwane od razu.
- [ ] Zero kodu pod konkretny obiekt; potrzebna zmiana kontraktu = stop i rozmowa, nie łatka.
- [ ] Porównanie w F1: obiekt z ComfyUI / prosty sprite z „Oświetlenia sprite'ów na Bryłach”.
- [ ] Normalne dodatków wypełnia narzędzie Przepisu (`style-lab/tools/meble/`), nie silnik.
- [ ] Przełącznik ticketu w F1: normalne dodatków „nadmuchane” / stała normalna do kamery (dwie mapy normalnych tego samego assetu, obie pełne); wybór człowieka zapisany w tickecie i w Przepisie mebli. Jeśli oba źle: stop i rozmowa (następna droga: estymator normalnych w ComfyUI).

## Jak sprawdzić

Uliczka o 9:00, 16:00 i 21:00: obiekt z ComfyUI ma cień zgodny z obrazem i światło z właściwej strony, wygląda jak w prototypie. Dodatki na blacie mają własne modelowanie: nie są przezroczyste (światło jak ściana za nimi) ani płasko pełne.
