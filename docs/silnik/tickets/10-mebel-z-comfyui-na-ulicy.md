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

## Wykonanie (2026-11-16, Claude)

- **Obiekt:** stragan (stół targowy) wybrany przez człowieka spośród propozycji. Scena Blendera `stall` w `style-lab/tools/blender/zestaw_testowy.py`: blat z oskrzynią i cztery nogi; Bryły: uniesiony blat (0,72–0,86 m) i cztery nogi. Prowadnice v2 w `style-lab/shots/prowadnice_v2/stall/`.
- **Generacja** (lokalnie w ComfyUI, 0 zł, za zgodą człowieka): Qwen-Image-Edit jak w tickecie 02 (`style-lab/proby/meble/generate_stall.sh`), 2 opisy × 3 seedy. Sito (`tools/meble/mebel_piksele.gd`) odrzuciło 3 obrazy (dodatki poza podstawą 39–42% > 30%), usunięte. Zgodne: `a_s9100`, `a_s9101`, `b_s9100` (strona wyboru `node proby/meble/wybor.mjs stall`). Człowiek: „wszystkie są spoko, sam sobie wybierz”; Claude wybrał **`a_s9101`** (skrzynka jabłek, słoiki i waga na blacie, najszersza pasiasta narzuta zwisająca z przodu, czyli najwięcej dodatków poza modelem).
- **Normalne dodatków** (narzędzie Przepisu `style-lab/tools/meble/addon_normals.gd`, testy `style-lab/test/tools/test_addon_normals.gd`): piksele modelu biorą normalne z Blendera, piksele dodatków (alfa sprite'a minus maska Blendera) dostają: **nadmuchane** (wysokość ćwiartką okręgu o promieniu 3 px gry z odległości od brzegu obszaru, normalna ze spadku; w środku do kamery, przy brzegu na zewnątrz) albo **stałą normalną do kamery**. Obie mapy pełne (bramka: brak ostrzeżeń walidacji dla każdego wyglądu). Dodatki namalowane wewnątrz obrysu blatu (jabłka, słoiki) leżą w masce Blendera, więc biorą normalną blatu; własne normalne dostają części ponad krawędzią blatu i narzuta pod nią. Brzeg dodatku styka się też z modelem (np. dół narzuty przy blacie), więc i tam normalna pochyla się na zewnątrz.
- **Silnik bez zmian** (`addons/swiatlo` nietknięty). Stragan na Uliczce przy kamerze (x 3 m, d 3,5 m) jako scena assetu z `build_asset_scene.gd`.
- **F1 „Stragan (ticket 10)”** (Poligon, nie silnik): `ComfyUI, dodatki nadmuchane` / `ComfyUI, dodatki stała normalna do kamery` / `prosty sprite` (malowany z maski jak w tickecie 09, normalne z Blendera). Wygląd to zasób `AssetLook` (`engine_poligons/asset_look.gd`, pliki `props/stall/look_*.tres`); zmiana przebudowuje Opis sceny; zapisany w zrzutach jako „wygląd assetu”.
- **Pomiar Claude'a** (zrzuty przez odtwarzanie, kamera `-100;0`): nadmuchane i stała różnią się w ok. 200 pikselach brzegów dodatków, do 15% jasności (9:00–16:00); w nocy do 4%. Cień straganu zgodny z obrazem (nogi i blat), stragan w słońcu ok. 11:00–14:00.
- **Testy:** `node tools/test.mjs`: 127 zielone (nowe: 3 testy normalnych dodatków, 2 testy przełącznika wyglądu); testy pikselizacji mebli i 9 testów Blendera zielone.

### Uwaga do „Jak sprawdzić”

O 9:00 i 16:00 stragan stoi w cieniu kamienic (słońce w południe 30°), więc świeci tylko niebem; o 21:00 jest noc bez lamp (lampy w tickecie 13). Narzuta zwisa z przodu, a słońce świeci z południa, czyli zza stołu, więc w dzień narzuta jest w cieniu blatu. Kierunek światła najlepiej widać o 11:00 i 14:00.

## Jak sprawdzić (uzupełnienie)

`style-lab/street_engine.bat`, F1, kamera strzałkami w dół i w prawo (stragan na prawo od skrzyni):
1. **11:00 i 14:00:** cień straganu na chodniku po stronie przeciwnej do słońca, blat i dodatki jasne.
2. Przełącz „Stragan (ticket 10)”: nadmuchane / stała do kamery. Patrz na brzegi jabłek i wagi ponad blatem i na narzutę. Nadmuchane: brzegi z modelowaniem; stała: dodatki płasko jednolite.
3. **9:00, 16:00, 21:00:** stragan oświetlony niebem, nie czarny; „prosty sprite” do porównania.
4. Wybierz: nadmuchane czy stała (albo „oba źle”: wtedy rozmowa o estymatorze normalnych w ComfyUI).

### Ocena człowieka

(czeka)
