---
id: 27
title: Test końcowy
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [12, 15, 25, 26]
---

## Co zbudować

Świeży subagent widzi tylko Dokumentację kontraktu sceny i buduje w edytorze: wnętrze (piwnica lub strych z oknem dachowym, gołą żarówką i wąskim okienkiem pod sufitem) i plener (wieś nocą i o świcie, drzewa, stodoła, jedna latarnia, świecące okno). Każda zmiana w katalogu silnika = wynik negatywny i powrót do modelu.

## Kryteria akceptacji

- [ ] Lokacje wyłącznie z węzłów kontraktu; zero zmian w katalogu silnika.
- [ ] Testy, bramki i test „bez kodu pod scenę” zielone.
- [ ] Każda wartość wizualna w `.tres`; Warianty działają w F1.
- [ ] Ponad 60 fps w obu Lokacjach i na Skwerze.
- [ ] Człowiek przesuwa w edytorze jedną Przesłonę i jedną lampę (cienie idą od razu), ocenia w grze o kilku godzinach.

## Jak sprawdzić

Otwórz obie Lokacje w edytorze, przesuń stodołę i latarnię; uruchom grę i przewiń dobę: świt, południe, zmierzch, noc.
