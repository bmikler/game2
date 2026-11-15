# 89. Testy Silnika światła w Godot 4.7.2: GUT czy gdUnit4, testy shaderów i buforów, jedna komenda

Ticket: `docs/wayfinder-silnik/tickets/05-testy-godot-research.md`. Data: 2026-11-15. Model: Sonnet.
Metoda: dokumentacja i repozytoria narzędzi (źródła pierwotne) oraz własne próby na kopii próbnej POZA repo
(`...\scratchpad\p`, `pg`, `pu`) z Godot 4.7.2 (`Godot_v4.7.2-stable_win64_console.exe`). Repo gry i `project.godot` nietknięte, żaden addon nie został dodany do `style-lab/`.

## 1. Fakty (z odnośnikami)

### 1.1 Zgodność z Godot 4.7

- **GUT**: lista wydań wskazuje, że 9.7.0 (19 czerwca) zawiera "Compatibility changes for Godot 4.7"; 9.6.0 to 4.6, 9.5.0 to 4.5. Najnowsze to 9.7.1 (10 lipca). Źródło: <https://github.com/bitwes/Gut/releases>. Licencja MIT: <https://github.com/bitwes/Gut>.
- **gdUnit4**: tabela zgodności w README: linia `v6.2.x` = Godot 4.5 do 4.7.1; `master (v7.0.0)` = 4.7, 4.7.1, 4.8.dev7. Najnowsze wydanie 6.2.3 (1 listopada) naprawia błąd rozmiaru czcionki "na świeżym edytorze 4.7". Źródła: <https://github.com/godot-gdunit-labs/gdUnit4> (README, tabela), <https://github.com/godot-gdunit-labs/gdUnit4/releases>. Licencja MIT.
- Odczytane tą drogą daty w obu listach wydań nie zawierają roku; kolejność i numery są pewne, rok wnioskuję z kontekstu (2026).

### 1.2 Uruchamianie z linii poleceń

- **GUT** (<https://gut.readthedocs.io/en/latest/Command-Line.html>): bazowa komenda `godot -d -s --path "$PWD" addons/gut/gut_cmdln.gd`; opcje `-gdir`, `-ginclude_subdirs`, `-gselect`, `-gexit`, `-gjunit_xml_file`, `-gconfig` (domyślnie `res://.gutconfig.json`). Dokumentacja: kod wyjścia 0 gdy wszystkie testy przechodzą, 1 gdy któryś nie. Raport: tekst w konsoli + JUnit XML (bez HTML).
- **gdUnit4** (<https://godot-gdunit-labs.github.io/gdUnit4/latest/advanced_testing/cmd/>): narzędzie `res://addons/gdUnit4/bin/GdUnitCmdTool.gd`, opakowania `runtest.sh` / `runtest.cmd` (zmienna `GODOT_BIN`); opcje `-a <katalog>` (powtarzalne), `-i` (pomiń), `-c` (nie zatrzymuj się na pierwszej porażce), `-rd` (katalog raportów, domyślnie `res://reports/`), `-rc` (ile raportów trzymać, domyślnie 20). Kody wyjścia: 0 sukces, 100 porażki testów, 101 ostrzeżenia. Raporty: `index.htm` (HTML) i `results.xml` (JUnit).
- Dokumentacja gdUnit4 nie wspomina o trybie headless; w praktyce (sekcja 2) narzędzie go odrzuca.

### 1.3 Render offscreen i odczyt tekstury (próby własne, Godot 4.7.2, Windows, RTX 4060)

Skrypt próbny: `extends SceneTree`, `SubViewport` 64x64 z `ColorRect` i shaderem `canvas_item` (`COLOR = vec4(UV.x*k, UV.y, 0.25, 1.0)`), `await process_frame` x2, `get_texture().get_image()`.

| Wariant uruchomienia | Wynik |
|---|---|
| `--headless` | Obraz niedostępny: `ERROR: Parameter "t" is null. at: texture_2d_get (./servers/rendering/dummy/storage/texture_storage.h:110)`, `get_image()` zwraca null. Tryb headless używa "dummy" renderera, więc nic się nie rysuje. |
| `--display-driver headless --rendering-driver vulkan` | To samo (dummy renderer). |
| `--path . --resolution 64x64 --position -3000,-3000` (okno poza ekranem, prawdziwy Vulkan) | Działa: `px(32,32)=(0.2549, 0.5059, 0.251, 1.0)`, zgodne z wzorem shadera, format `Image.FORMAT_RGBA8`. Całość ok. 2,1 s. |

- Silnik ma już ten sam mechanizm: `SunMap.dump_buffer` (`style-lab/lighting/sun_map.gd:280`) robi `_view.get_texture().get_image()` i zapisuje `get_data()`; `StreetMap.dump_current` analogicznie. Bramki `bufor_roznica.mjs` (RGBH, 6 B/px) i `bufor_ulica_roznica.mjs` (RGBA half, 8 B/px) porównują te surowe bajty.
- Odnośnik do opisu argumentów silnika (`--headless`, `--resolution`, `--position`, `-s`): <https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html>.

### 1.4 Wyniki prób obu narzędzi na tym samym teście (3 testy: piksel shadera w (32,32), czysta logika, celowa porażka)

| | GUT 9.7.1 | gdUnit4 6.2.3 |
|---|---|---|
| Okno poza ekranem, prawdziwy GPU | działa, 2 przeszły, 1 oblany jak trzeba, kod wyjścia 1, ok. 3,4 s całości (testy 0,86 s) | działa, to samo, kod wyjścia 100, ok. 4,7 s całości (testy 0,81 s) |
| `--headless` | testy logiki działają (kod 1), testy pikseli oblane (brak obrazu) | **odmowa**: "Headless mode is not supported!", kod 103; wymaga `--ignoreHeadlessMode` |
| Raporty | JUnit XML (`-gjunit_xml_file=res://gut.xml`) | HTML + JUnit XML w `reports/report_N/` |
| Komunikat porażki | `expected to equal [0.2549] +/- [0.01]` + numer linii | zakres + numer linii i stos |
| Uwaga | `--minimized` w linii poleceń daje `Unknown arguments` i kod 1 (GUT sprawdza argumenty); `--position`/`--resolution` przechodzą | działa z tym samym zestawem argumentów; wypisuje kody ANSI (kolory) do konsoli |
| Włączenie wtyczki w edytorze | niepotrzebne do uruchamiania z CLI | niepotrzebne do uruchamiania z CLI |
| Import | oba wymagały jednorazowego `--headless --import` po skopiowaniu addonu | j.w. |

- API asercji: GUT `assert_almost_eq(float, float, tol)` (parametry `Variant`); gdUnit4 `assert_float(x).is_equal_approx(a, tol)` (fluent, typowane). Oba przyjmują testy pisane w typowanym GDScripcie (próby kompilowały się bez ostrzeżeń).

## 2. Wnioski (moje, oddzielone od faktów)

1. **Testy shaderów i buforów wymagają prawdziwego GPU i okna, nie `--headless`.** To kluczowy wynik: żadne z narzędzi tego nie obchodzi. Okno poza ekranem (`--position -3000,-3000 --resolution 64x64`) daje pełny render Vulkan i `get_image()`; nie ma "render offscreen bez okna" w Godot na Windows z shaderami. Test GPU nie pójdzie więc na serwerze bez GPU. Na maszynie człowieka to nie przeszkadza.
2. **Wymaga sprawdzenia przy wdrożeniu:** czy okno poza ekranem nie miga przy starcie (nie zaobserwowałem, ale nie mierzyłem) i czy bajty bufora są identyczne między uruchomieniami i między GPU. Inne GPU mogą dać różnice rzędu 1 LSB w shaderach z `sin`, `pow` i próbkowaniem; bramka powinna mieć tolerancję w ustalonych punktach, nie równość bajtów, albo złote bufory per sprzęt. Obecne `.mjs` porównują bajt w bajt, co działa tylko na tym samym GPU i sterowniku.
3. **GUT czy gdUnit4:** obie opcje działają w 4.7.2 i spełniają wymagania (CLI, JUnit, typowany kod, ok. 1 s na testy z renderem). Rekomenduję **GUT 9.7.1**:
   - 4.7 jest wymienione wprost w notatkach wydania (9.7.0), a 9.7.1 to poprawka; gdUnit4 6.2.x deklaruje 4.7.1 w tabeli i właśnie naprawiał błąd 4.7 w 6.2.3;
   - jedna komenda `godot -s addons/gut/gut_cmdln.gd ...` bez skryptów `.cmd` i zmiennej `GODOT_BIN`, prostszy przypadek do wywołania z `/implement`, kod wyjścia 0/1;
   - mniejszy, jeden katalog `addons/gut`; nie wymaga wtyczki w edytorze do biegu z CLI.
   Minus GUT: brak raportu HTML (JUnit wystarcza dla skilla), asercje słabiej typowane (`Variant`). gdUnit4 jest sensowną alternatywą, jeśli człowiekowi zależy na HTML i na typowanych asercjach (fluent API); jego odmowa trybu headless jest bez znaczenia, bo i tak potrzebny jest GPU.
4. **Brak addonu też jest opcją.** Skrypt `extends SceneTree` odpalany `-s` (jak w próbie 1.3) ładuje się w 2 s i może wywołać `quit(kod)`. Dla samych bramek pikseli (porównanie buforów, tolerancje) to wystarcza i nie wymaga zgody na addon; GUT daje wygodę dla logiki (asercje, doubles, parametryzacja, wykrywanie testów, raport).
5. **Podział testów dla Silnika (do specyfikacji):**
   - logika w czystych klasach (krzywe doby, kontrakt danych, kolejność nakładania, matematyka cienia): GUT, bez GPU, ok. ułamka sekundy;
   - shadery i bufory: GUT, testy z `SubViewport`, `await get_tree().process_frame` x2, `get_image()`, asercje w ustalonych punktach (z tolerancją) oraz porównanie ze złotym buforem w `tests/zlote/` (nowy mechanizm: zapis przez `--set-golden`, a nie ręczny);
   - dyfy wizualne dla człowieka zostają w `tools/pomiar/*.mjs` (mapa różnic `bufor_roznica.mjs` PNG); testy GDScript mogą zapisywać `.bufor` obok wyniku, żeby narzędzia Node dalej działały.
6. **Jedna komenda dla `/implement`:** wystarczy skrypt `style-lab/tools/test.mjs` (Node, bo `jq`, `rg`, Python nie ma) wywołujący po kolei: (a) GUT z oknem poza ekranem, (b) ewentualnie bramki `.mjs`, i zwracający niezerowy kod wyjścia, gdy którykolwiek krok oblał. Dla trybu "często" (w pętli TDD): `-gselect=<fragment nazwy>`; "pełny zestaw na końcu": bez `-gselect` plus bramki `.mjs`.

## 3. Rekomendacja i przykładowe komendy

Narzędzie: **GUT 9.7.1** (MIT), addon w `style-lab/addons/gut/` (poza `addons/swiatlo/`, żeby kopiowanie silnika do gry nie zabierało testów; dodanie addonu wymaga zgody człowieka, patrz mapa). Jednorazowo po dodaniu: `Godot_..._console.exe --headless --path style-lab --import`.

Wszystkie testy (pełny zestaw; jedna komenda, sprawdzona w próbie, kod 0 = zielone, 1 = czerwone):

```sh
G=/c/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64_console.exe
"$G" --path style-lab --resolution 64x64 --position -3000,-3000 \
  -s addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit \
  -gjunit_xml_file=res://test_wyniki.xml
```

Jeden plik lub fragment nazwy (szybka pętla TDD):

```sh
"$G" --path style-lab --resolution 64x64 --position -3000,-3000 \
  -s addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gselect=cien_ -gexit
```

Szkielet testu piksela (typowany, wzorowany na próbie):

```gdscript
extends GutTest

func _render(shader: Shader, size: Vector2i) -> Image:
	var view: SubViewport = SubViewport.new()
	view.size = size
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	# ... węzły sceny lub ColorRect z ShaderMaterial ...
	add_child_autofree(view)
	await get_tree().process_frame
	await get_tree().process_frame
	return view.get_texture().get_image()

func test_punkt_w_cieniu() -> void:
	var image: Image = await _render(preload("res://...shader"), Vector2i(64, 64))
	assert_almost_eq(image.get_pixel(32, 32).r, 0.25, 0.01)
```

Propozycja `style-lab/tools/test.mjs` (do zrobienia w ticketach wykonawczych, nie w tym researchu): `spawnSync` komendy GUT powyżej, potem `node tools/pomiar/...` dla bramek, `process.exit(kod)`.

Alternatywa równorzędna: **gdUnit4 6.2.3**. Komenda sprawdzona w próbie (kod 100 = porażki):

```sh
"$G" --path style-lab --resolution 64x64 --position -3000,-3000 \
  -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://test -c -rd C:/Temp/raport
```

## 4. Czego nie sprawdzono

- Powtarzalność bajtów między uruchomieniami i między GPU (wnioski 2); nie mierzono migotania okna.
- Test na `SubViewport` z formatem `RGBAH` (HDR 2D, jak bufor `SunMap`/`StreetMap`): odczyt realnych buforów silnika nie był przedmiotem próby; użyto RGBA8. `dump_buffer` w repo już to robi, więc odczyt `RGBAH` jest znany, ale nie przez GUT.
- Pomiar szybkości na dużych scenach (próby miały 64x64 i 3 testy).
- Ciężar dokumentacji testów dla `mock`/`double` w typowanym kodzie (GUT 9.7.0 zmienia zachowanie doubles na 4.7 wg notatek wydania); nieistotne dopóki Silnik testowany jest bez doubles.
