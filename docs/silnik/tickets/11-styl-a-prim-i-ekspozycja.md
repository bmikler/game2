---
id: 11
title: Stylizacja A′ i ekspozycja automatyczna
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [08]
---

## Co zbudować

A′ (poziomy EV, szew ditheru o stałej szerokości w px, kotwica `Y_ref`) kwantyzuje oświetlenie powierzchni. Dwa tryby w Zestawie (A′ na luminancji sumy z ciągłą barwą; A′ osobno na kanale naturalnym i sztucznym, potem suma), przełączane na żywo w F1. Ekspozycja automatyczna z jasności odniesienia Lokacji i Stanu doby. Zestawy `plener.tres` i `wnetrza.tres` z punktami startowymi ze Ściągi.

## Kryteria akceptacji

- [ ] Zestaw strojenia ze wszystkimi polami ze specyfikacji, dwa pliki domyślne.
- [ ] Obraz = albedo × stylizowane światło; rozproszenie dodawane po A′.
- [ ] Przełącznik trybu A′ w F1.
- [ ] Bramka: liczba poziomów zgodna z Zestawem; szerokość szwu w px stała.
- [ ] Brak ręcznej ekspozycji na Lokację.

## Jak sprawdzić

Uliczka, przewiń dobę: wyraźne poziomy z wąskim szwem ditheru, noc ciemna, ale czytelna; mebel z ComfyUI nie gryzie się z ditherem.
