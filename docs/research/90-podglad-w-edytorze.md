# 90. Podgląd światła w edytorze Godota 4.7 (ticket 06 mapy silnika)

Pytanie: czy Lokację z węzłów `@tool` (przesłony, otwory, źródła światła) da się układać w edytorze tak, żeby widać było na żywo bufor światła i cienie; jakie są ograniczenia `@tool`; jak najprościej zbierać dane sceny z węzłów.

Model: Sonnet. Metoda: dokumentacja Godota + własny próbny projekt poza repo (Godot 4.7.2, Forward+, NVIDIA RTX 4060 Laptop). Kod repo nie był zmieniany.

## Fakty

### Z dokumentacji (źródła pierwotne)

- `Engine.is_editor_hint()` zwraca true, gdy kod działa w edytorze; skrypt `@tool` działa i w edytorze, i w grze. Zasady: skrypt, który używa innych skryptów, wymaga, by tamte też były `@tool` (wyjątek: metody statyczne, stałe, enumy); dziedziczenie po `@tool` nie robi potomka `@tool`. Zmiany `@tool` w edytorze są trwałe, bez undo; zmiany z kodu nie oznaczają sceny jako niezapisanej (`EditorInterface.mark_scene_as_unsaved()` albo `EditorUndoRedoManager`). Po edycji skryptu czasem trzeba przeładować scenę, a w niektórych wersjach restart edytora (GH-66381). https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html
- Węzeł dodany przez `add_child()` bez ustawienia `owner` na korzeń edytowanej sceny nie pokazuje się w panelu sceny i nie jest zapisywany do `.tscn`. https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html oraz https://docs.godotengine.org/en/stable/classes/class_node.html
- `Node.add_to_group(group, persistent)`: `persistent = true` zapisuje grupę przy pakowaniu do `PackedScene` (grupy z panelu Groups są trwałe). `add_child(node, false, Node.INTERNAL_MODE_FRONT/BACK)` dodaje dziecko wewnętrzne. https://docs.godotengine.org/en/stable/classes/class_node.html
- `SubViewport.render_target_update_mode`: `UPDATE_DISABLED` (nigdy), `UPDATE_ONCE` (raz, potem DISABLED), `UPDATE_WHEN_VISIBLE` (domyślnie); `render_target_clear_mode`: ALWAYS / NEVER / ONCE. https://docs.godotengine.org/en/stable/classes/class_subviewport.html

### Z próby (Godot 4.7.2, edytor uruchomiony z `--editor`, wtyczka `EditorPlugin` sterująca; projekt w scratchpadzie sesji)

Zbudowane: `Occluder` (`@tool`, `Node2D`, `@export size`, grupa `occluders`), `LightBuffer` (`@tool`, tworzy w `_ready` `SubViewport` + `ColorRect` z shaderem canvas_item; shader dostaje tablicę prostokątów jako uniform i robi test promień-prostokąt do źródła).

1. **`_ready`, `_enter_tree`, `_process` skryptów `@tool` działają w edytorze** (`Engine.is_editor_hint() == true`), także przy otwarciu sceny z dysku. Przy starcie gry (`is_editor_hint() == false`) ten sam kod działa tak samo.
2. **Shader w `SubViewport` renderuje się w edytorze.** Po przesunięciu przesłony w buforze był właściwy cień (piksel za przesłoną 0,2, poza nią 1,0). Dziecko `SubViewport` i `TextureRect` z jego teksturą, dodane jako węzły wewnętrzne (`INTERNAL_MODE_FRONT/BACK`) bez `owner`, **nie trafiły do zapisanego `.tscn`** (zapis sceny zawierał tylko węzły ułożone ręcznie i ich właściwości; nic z bufora).
3. **Tryb `UPDATE_ONCE` ustawiany przy zmianie działa w edytorze:** licznik renderów rósł tylko przy zmianie (1 na start, +1 na przesunięcie, +1 na zmianę `size`); 300 przesunięć dało 303 rendery.
4. **Koszt:** bufor 2400x1350 z 8 prostokątami i prostym shaderem: render + odczyt na CPU (`get_image`) = 14,2 ms (górna granica kosztu samego rysowania, bo odczyt synchronizuje GPU). Przy `UPDATE_ONCE` koszt płacony jest tylko w klatce, w której coś się zmieniło. Edytor ma włączone `OS.low_processor_usage_mode` (6900 us snu), więc `Engine.get_frames_per_second()` w edytorze (10) nic nie mówi o koszcie; edytor odrysowuje się przy zdarzeniach, nie ciągle.
5. **Powiadomienia o przesunięciu:** `set_notify_transform(true)` + `NOTIFICATION_TRANSFORM_CHANGED` działa w edytorze, ale **jest dostarczane z opóźnieniem, na końcu klatki** (po `position = ...` licznik w tej samej klatce 0, w następnej 1; tak samo przy zmianie przez `EditorUndoRedoManager`). Setter `@export` (`size`) emituje od razu.
6. **Przeszukanie drzewa:** `get_tree().get_nodes_in_group(&"occluders")` w edytorze zwraca węzły edytowanej sceny; grupa dodana w `_enter_tree` kodem (bez `persistent`) nie ląduje w `.tscn`, a odtwarza się przy każdym wejściu do drzewa. Odpytywanie co klatkę (hash pozycji i rozmiarów 2 węzłów w `_process`) działało; przy kilkudziesięciu węzłach koszt hasha jest pomijalny, ale nie mierzony.
7. **Uid-y:** zapis sceny przez edytor dopisał `uid` do nagłówka i `unique_id` do węzłów (normalne zachowanie edytora 4.7).

Czego nie sprawdzono: ręcznego przeciągania myszą w widoku 2D (symulowane programowo; ścieżki `position =`, `global_position =`, `translate`, `EditorUndoRedoManager` tak), zachowania przy edycji skryptu w edytorze (przeładowanie tool-skryptu, GH-66381), dużych scen (kilkadziesiąt do setek przesłon i źródeł), działania dla `Node3D`/rzutu 0,60 (silnik jest 2D), instancji podscen z węzłami `@tool` (zapis zmian w instancji), czasu pełnego bufora silnika (shadery `light_fn` / `street_fn` są dużo cięższe niż shader próbny).

## Wnioski

1. **Podgląd na żywo jest wykonalny.** Węzły `@tool` w edytorze mogą zbudować własny `SubViewport` z shaderem bufora i pokazywać wynik; nic w próbie nie wymagało specjalnych obejść. Koszt zależy głównie od shadera silnika, nie od edytora; należy go zmierzyć na prawdziwym shaderze przed decyzją o rozmiarze bufora w edytorze.
2. **Dane sceny: najprostszy wzorzec to grupa + zbieranie w jednym miejscu.** Każdy węzeł kontraktu (przesłona, otwór, źródło) w `_enter_tree` dodaje się do swojej grupy (po jednej na rodzaj) i emituje sygnał `changed` w setterach `@export` oraz w `NOTIFICATION_TRANSFORM_CHANGED`. Jeden węzeł (np. kontroler bufora) zbiera dane `get_nodes_in_group()` w ustalonym kolejności i ustawia uniformy. Bez rejestru globalnego (autoload nie działa tak prosto w edytorze) i bez przeszukiwania całego drzewa.
3. **Odświeżanie sterowane zmianą, nie co klatkę.** Zdarzenie `changed` ustawia flagę `dirty`; w `_process` jeśli `dirty`, zbierz dane, ustaw uniformy, `render_target_update_mode = UPDATE_ONCE`. Ponieważ `TRANSFORM_CHANGED` przychodzi na końcu klatki, odświeżenie nastąpi najpóźniej klatkę później; to wystarcza. Skutek: w spoczynku koszt zero. Wariant awaryjny: hash transformów w `_process` (działał w próbie), tańszy w implementacji, kosztowny dopiero przy bardzo wielu węzłach. Godzina doby i zestaw wartości (Resource) powinny też ustawiać `dirty` (np. przez `changed` zasobu).
4. **Zapisywanie sceny jest bezpieczne, jeśli własne dzieci kontrolera są wewnętrzne i bez `owner`.** `SubViewport`, `ColorRect` i podgląd tworzone w `_ready` nie trafiają do `.tscn`; Lokacja zapisuje się wyłącznie jako węzły kontraktu z ich `@export`. Nie ustawiać `owner` dla niczego, co kontroler tworzy sam, i nie używać `persistent` grup.
5. **Główne ryzyka `@tool`:** (a) wszystkie skrypty w łańcuchu zależności muszą być `@tool` (poza statykami, stałymi, enumami), więc kontrakt danych silnika i klasy pomocnicze są `@tool` od początku; (b) błędy w skryptach `@tool` wykonują się w edytorze i mogą psuć edycję (zalecenie dokumentacji: najpierw napisać jak zwykły skrypt, `@tool` na końcu, i rozdzielić kod edytora i gry); (c) po zmianie skryptu może być potrzebne ponowne otwarcie sceny (GH-66381); (d) dane w edytorze, np. `Resource` zmieniany z kodu, nie oznaczają sceny jako zmodyfikowanej bez `mark_scene_as_unsaved()`/`UndoRedo`; (e) w edytorze nie ma stanu gry (gracz, godzina z dyrektora), więc kontroler musi mieć własne wejścia podglądu (godzina, tryb) jako `@export`.
6. **Konsekwencje dla Poligonów jako scen edytora:** budowanie kodem w `dom_bryly.gd`/`ulica_bryly.gd` zastępują sceny z węzłami kontraktu; stan bufora (np. `CLEAR_MODE_NEVER` i `UPDATE_ONCE` w dzisiejszym `sun_map.gd`) trzeba przenieść do modelu „dirty + jedno przeliczenie” z wniosku 3. Edytor odrysowuje się tylko przy zdarzeniach, więc podgląd jest „na żywo przy edycji”, nie animowany; ciągły ruch (doba) sprawdzać w grze.

## Rekomendacja wzorca

Węzły kontraktu = małe `@tool` węzły z `@export`, grupą dodawaną w `_enter_tree` i sygnałem `changed` (setter + `NOTIFICATION_TRANSFORM_CHANGED`). Jeden `@tool` kontroler bufora: zbiera dane z grup, ustawia uniformy, trzyma `SubViewport` jako dziecko wewnętrzne bez `owner`, renderuje `UPDATE_ONCE` po `dirty`. Przed zatwierdzeniem: zmierzyć czas bufora na prawdziwych shaderach w edytorze (zalecany ticket 10) i sprawdzić ręczne przeciąganie oraz podsceny.

## Źródła

- https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html
- https://docs.godotengine.org/en/stable/classes/class_subviewport.html
- https://docs.godotengine.org/en/stable/classes/class_node.html
- Issue GH-66381 (przywołany w dokumentacji; nie otwierany osobno): https://github.com/godotengine/godot/issues/66381
- Próbny projekt (poza repo, do odtworzenia): scratchpad sesji, `.../scratchpad/p6/` (`occluder.gd`, `buffer.gd`, `l.gdshader`, wtyczka sterująca).
