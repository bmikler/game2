# Przepis postaci

Wersja 1, 2026-11-09. Sprawdzony na detektywie (ticket „Przepis postaci”, `docs/wayfinder/tickets/12-przepis-postaci.md`).

Z jednego opisu postaci powstaje sprite stania w 3 widokach i chód w 4 kierunkach, gotowe do gry. Prawie wszystko robimy lokalnie (0 zł). Pixellab służy tylko do animacji.

## Wynik

Na jedną postać:

- **Stanie:** 3 sprite'y 80×80 (przód, bok, tył). Postać ma 72 px wysokości, a stopy są 7 px nad dolną krawędzią.
- **Chód:** 3 pętle po 8 klatek (przód, bok, tył). Bok patrzy w lewo, a ruch w prawo to jego lustro w grze.
- **Kąt gry:** 0,60 (`style-lab/config/projection.tres`).

## Zasady

- **Wybór człowieka:** każdy etap kończy się wyborem spośród kilku opcji. Dalej idzie tylko wersja zatwierdzona.
- **Ocena:** w Poligonie (`style-lab/rzut.bat`) albo na arkuszu porównawczym, nie na pojedynczym obrazku.
- **Kąt:** mierzymy (krok 3). Ocena „na oko” nie jest wzorcem.
- **Generacje w Pixellab:** tylko za zgodą człowieka. Przed wywołaniem podajemy co, po co i ile generacji to kosztuje.
- **Odrzucone obrazy:** usuwamy od razu. Zostają tylko kandydaci i bazy, z których powstali.
- **Ubiór:** strój do bioder (kurtka) animuje się dobrze. Płaszcz do kolan sprawia kłopot.

## Narzędzia

Wszystkie polecenia uruchamiamy z `style-lab/`, chyba że zaznaczono inaczej. Skróty:

```
G=C:/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64_console.exe
gd() { "$G" --headless --path . --script "$@"; }        # skrypty .gd z tools/postac/
B="C:/Program Files/Blender Foundation/Blender 5.2/blender.exe"
```

- **ComfyUI** (Comfy Desktop, `127.0.0.1:8188`):
  - FLUX.2 klein 4B (koncept);
  - Qwen-Image-Edit-2511 GGUF Q4_K_M z LoRA Multiple Angles i Lightning 4 kroki (widoki);
  - węzeł ComfyUI-GGUF.
- **Blender 5.2 z MPFB2:** manekiny jako wzorzec pozy i kąta.
- **Orient Anything:** `tools/orient/measure.cmd`, pomiar kąta na CPU.
- **Pixellab:** klucz `PIXELLAB_API_KEY` w `C:\Users\bartl\.secrets\game2\keys.env`.

Raz na kąt gry trzeba mieć dwa rendery manekina (już są dla 0,60):

```
"$B" -b -P tools/blender/postac_mpfb.py -- --df 0.6 --out shots/mpfb_060                  # bok jako wzór profilu
"$B" -b -P tools/blender/postac_mpfb.py -- --df 0.6 --legs 5 --out shots/mpfb_060_proste  # proste nogi, wejście do animacji
```

Katalog roboczy postaci: `proby/<postac>/` z podkatalogami `koncept`, `widoki`, `wejscie`, `chod`.

## 1. Koncept

1. Razem z człowiekiem ustalamy opis: kim jest, wiek, budowa, twarz, włosy, strój z kolorami.
2. Generujemy po 4–8 konceptów z przodu, uruchamiając z `tools/`:

   ```
   cd tools && node game1/concept/comfy.mjs --out ../style-lab/proby/<postac>/koncept --name przod --seed 8300 --count 4 --w 768 --h 1024 "<prompt>"
   ```

3. Prompt składamy z czterech części, w tej kolejności:
   1. opis postaci;
   2. stała poza: „One single figure standing relaxed, arms at his sides, facing the viewer, whole figure with feet visible, plain light grey background.”;
   3. proporcje: „realistic adult proportions 7 heads tall”;
   4. stały styl: „Hand-painted digital illustration, video game concept art painting, visible brush strokes, slightly stylized drawn look like a graphic novel, not a photograph, muted cold palette with warm lamp accents, Nordic noir mood.”

   Twarz opisujemy rzeczowo i z godnością, na przykład „dignified, composed face … well-groomed, symmetrical features, steady intelligent eyes, a few lines of age”. Unikamy „tired, dark circles”, bo wtedy wychodzi wrak. Wzór całego promptu: wpis `koncept7/przod-8302` w `tools/art/concept/prompts.jsonl`.
4. Człowiek wybiera jeden koncept. Poprawki stroju robimy edycją Qwen na wybranym koncepcie (prompt: „Replace … Keep exactly the same man, face, … pose, camera and drawing style. Plain light grey background.”, `--angles 0`).
5. **Wariant stroju** tej samej postaci powstaje tak samo, jako edycja zatwierdzonego konceptu. Potem przechodzi kroki 2–8.

## 2. Widoki w kącie gry

Używamy `node tools/postac/qwen_kat.mjs <wejście> <prefiks> "<prompt>" --angles <siła LoRA> [--pose <wzór>] --seed0 <s> --seeds <n>`. Jedna generacja trwa ok. 1,5–2 min.

**Ważne:** skrypt nazywa pliki tylko po seedzie. Siłę LoRA wpisujemy w prefiks, np. `widoki/przod_a13`, inaczej wyniki się nadpiszą.

| Widok | Wejście | Prompt | LoRA | Uwagi |
|---|---|---|---|---|
| Przód | koncept | `<sks> front view elevated shot full shot` | seria 1,1 / 1,2 / 1,3 | siła zależy od postaci, kalibrujemy serią |
| Bok | koncept, `--pose shots/mpfb_060/postac_bok.png` | `<sks> right side view elevated shot full shot. The man from image 1, same clothes, face and drawing style, standing in exactly the same pose, orientation and camera angle as the grey mannequin in image 2, seen in full profile. Plain light grey background.` | 1,3 | wychodzi profil patrzący w lewo |
| Tył | wybrany przód | `<sks> back view elevated shot full shot` | 1,0–1,3 | z przodu, nie z konceptu |

Na każdy widok robimy 2–3 seedy na siłę LoRA, potem stosujemy sito z kroku 3.

## 3. Sito kąta

Mierzymy na obrazach z Qwen w pełnej rozdzielczości. Na sprite'ach 72 px pomiar nie działa.

- **Przód i tył:** uruchamiamy `tools\orient\measure.cmd --aug 9 <obrazy>` i bierzemy kolumnę `polar`. Wzorcem jest ubrany, wyprostowany detektyw MPFB (`proby/kat_detektywa/sweep_stoi_aug9.csv`). Dokładność to około ±0,1.

  | df | 0,50 | 0,55 | **0,60** | 0,65 | 0,70 |
  |---|---|---|---|---|---|
  | przód (°) | 11,0 | 12,6 | **14,0** | 15,7 | 16,6 |
  | tył (°) | 17,9 | 18,8 | **20,6** | 22,1 | 23,9 |

- **Bok:** uruchamiamy `gd tools/postac/stopy.gd -- <przód.png> <bok.png>`. Kąt boku to `uskok` z boku podzielony przez `rozstaw` z przodu (cel 0,60, dokładność około ±0,01). Pomiar wymaga brązowych butów i tego samego rozstawu stóp w obu widokach. Dodatkowo Orient: azymut boku musi być w przedziale 80–100°. Poza nim to ujęcie 3/4, nie profil.
- Do człowieka trafiają tylko widoki bliskie 0,60 i spójne między sobą. Wybór kończy krok.

## 4. Wejście do animacji

Wejście do animacji to osobne obrazy, nie sprite stania. Nogi są proste, a stopy równoległe, ustawione wzdłuż kierunku ruchu. Sprite stania może mieć szerszy rozstaw (o tym decyduje człowiek).

Każdy wybrany widok edytujemy w Qwen z `--angles 0`, bo widok ma już kąt. Jako `--pose` podajemy manekina z prostymi nogami w tym samym widoku (`shots/mpfb_060_proste/postac_{przod,bok,tyl}.png`), po 2–3 seedy. Prompt dla przodu, a dla boku i tyłu analogicznie:

> `<sks> front view elevated shot full shot. The man from image 1 with exactly the same clothes, the same brown leather lace-up boots, face, drawing style and camera angle. Take only the body pose from the grey mannequin in image 2, not its bare skin: both legs straight, feet hip-width apart, the two boots parallel to each other with the boot tips pointing straight at the viewer, not turned outward, arms relaxed at the sides. He wears boots, no bare feet. Plain light grey background.`

Buty i ich kolor wpisujemy według postaci. Nie używamy słowa „toes”, bo daje bose stopy. Poza z manekina podnosi kąt o około 0,05, więc wyniki przepuszczamy przez sito z kroku 3.

## 5. Pikselizacja

Ten sam łańcuch stosujemy do sprite'ów stania i do wejścia do animacji:

```
gd tools/postac/crop_ref.gd -- <in.png> <out.png> 0 0 880 1184 80 72 0.08 0.5 0.85
gd tools/postac/alpha_cut.gd -- <out.png> <out.png> 0.5 0
```

- **Rozmiar:** `880 1184` to wymiar obrazu z Qwen.
- **Cień:** ostatni argument `crop_ref` to wysokość (ułamek obrazu), od której usuwamy cień rzucony przez Qwen. Jeśli na sprite'cie zostanie plama cienia, obniżamy go do 0,75 albo 0,6.
- **Obrys:** bez czyszczenia obrysu i bez konturu. Sprite zostaje taki, jak wychodzi ze zmniejszenia.

Opcje pokazujemy człowiekowi w arkuszu porównawczym: `node tools/postac/porownanie_wejsc.mjs proby/<postac>/wejscie`, konfiguracja w `opcje.json`, wzór w `proby/wejscie_anim/`. Arkusz pokazuje manekina, nakładkę i sprite'y 80×80. Duże obrazy do arkusza robimy przez `crop_ref` z `400 72` i `wyrownaj.gd`, bez `alpha_cut`.

## 6. Chód (Pixellab)

Każdy kierunek kosztuje 2 generacje i trwa ok. 3 min. Generujemy kierunki po kolei, bo trial obsługuje jedno zadanie naraz.

```
export PIXELLAB_SUBJECT="<krótki opis wyglądu i stroju po angielsku>"
# krok 1: dwa kroki od stania do stania (wejście = pierwsza i ostatnia klatka), 1 gen.
node tools/postac/pixellab_anim.mjs pixminimax <wejście.png> proby/<postac>/chod "<opis 16>" 16 1 <wejście.png> <kier>16
# wybór klatki w rozkroku (wypisuje ścieżkę w ostatniej linii)
gd tools/postac/rozkrok.gd -- proby/<postac>/chod/<kier>16_{0..16}.png
# krok 2: pętla od rozkroku do rozkroku, 1 gen.
PIXELLAB_POSE="<poza rozkroku>" node tools/postac/pixellab_anim.mjs pixminimax <rozkrok.png> proby/<postac>/chod "<opis 8>" 8 1 <rozkrok.png> <kier>
```

Wynik to `<kier>_0..8`, gdzie klatka 8 = klatka 0, więc pętlę tworzą klatki 0–7.

| Kierunek | Zmienne | Opis 16 | Poza rozkroku / opis 8 |
|---|---|---|---|
| bok | (domyślne: `side`, `west`) | two full walking steps in strict side profile at a calm natural pace: the near leg steps forward, then the far leg steps forward; each leg bends clearly at the knee while it swings forward and straightens when the heel touches down; arms swing gently opposite to the legs; the body stays in profile and never turns toward the camera; ending in the starting pose | mid-stride in side profile, near leg forward and far leg back, arms swinging opposite / one complete calm walking cycle in side profile, both knees bend in turn, returning to the same stride |
| przód | `PIXELLAB_VIEW="high top-down" PIXELLAB_DIR=south`, krok 1: `PIXELLAB_POSE="standing upright facing the camera, arms at his sides"` | two full walking steps toward the camera at a calm natural pace: one leg steps forward, then the other; each leg bends clearly at the knee while it swings forward; arms swing gently opposite to the legs; the body keeps facing the camera and never turns sideways; ending in the starting pose | mid-stride facing the camera, one leg forward and the other back, arms swinging opposite / one complete calm walking cycle toward the camera, both knees bend in turn, returning to the same stride |
| tył | `PIXELLAB_VIEW="high top-down" PIXELLAB_DIR=north`, krok 1: `PIXELLAB_POSE="standing upright with his back to the camera, arms at his sides"` | two full walking steps away from the camera at a calm natural pace: one leg steps forward, then the other; each leg bends clearly at the knee while it swings forward; arms swing gently opposite to the legs; the body keeps its back to the camera and never turns sideways; ending in the starting pose | mid-stride with his back to the camera, one leg forward and the other back, arms swinging opposite / one complete calm walking cycle away from the camera, both knees bend in turn, returning to the same stride |

W kroku 1 postać pod koniec zwykle obraca się ku kamerze. Nie szkodzi, bo z kroku 1 bierzemy tylko klatkę w rozkroku. Klatek z różnych prób nie mieszamy.

Przy subskrypcji robimy po 2–3 wersje każdego kierunku (różne seedy) i człowiek wybiera najlepszą w Poligonie.

## 7. Poprawka klatek

Pixellab zostawia w tułowiu przezroczyste szczeliny szerokości 1 px. W grze prześwituje przez nie podłoże i wygląda to jak biała koszula albo plama. Na boku dochodzą piksele „rozchylonej” kurtki. Poprawiamy to lokalnie:

```
gd tools/postac/zamaluj_tors.gd -- 0.19 0.44 0.52 <bok_i.png> <bokc_i.png> ...     # szczeliny + obce kolory w pasie kurtki
gd tools/postac/zamaluj_tors.gd -- 0.19 0.19 0.52 <przod_i.png> <przodc_i.png> ... # tylko szczeliny
```

Tył zwykle nie potrzebuje poprawki. Kolor kurtki to stałe `JACKET_V` i `JACKET_WARM` w skrypcie, dobrane do ciemnego granatu. Dla innego stroju trzeba je zmienić. Wynik zawsze sprawdzamy w powiększeniu, bez wygładzania.

## 8. Ocena w Poligonie

1. Podpinamy postać w `poligony/rzut_poligon.gd`: ścieżki stania w `D_STAND`, klatki chodu w `D_WALK`; tryb `Dc` czyta klatki poprawione.
2. Człowiek ocenia w `rzut.bat` (F1 „Chód”): w dzień i w nocy, we wszystkich kierunkach, przy ruszaniu i zatrzymaniu.

## 9. Mapy normalnych (po zatwierdzeniu chodu)

Jeszcze nieustalone. Ticket „Mapy normalnych postaci: Pixellab, Laigter czy własny skrypt” (`docs/wayfinder/tickets/22-mapy-normalnych-postaci.md`) porówna trzy źródła map:
- Pixellab `/normal-map`;
- własny skrypt z game1-proto;
- Laigter.

W Godot mapę podpinamy jako `CanvasTexture.normal_texture`, żeby światła 2D cieniowały postać.

## Koszt i czas na postać

- **Lokalnie (0 zł):** ok. 15–25 obrazów Qwen (ok. 40 min pracy karty) i kilka konceptów FLUX.
- **Pixellab:** 6 generacji na jedną wersję chodu w 3 kierunkach. 3 wersje do wyboru to 18 generacji. Mapy normalnych: 0 albo ok. 0,6 generacji, zależnie od wyniku ticketu 22.
- **Plan na Miesiąc produkcji:** subskrypcja Pixellab z ok. 2000 generacji.
- **Czas człowieka:** ok. 1–2 h na postać (opis, wybory na każdym etapie, ocena w Poligonie).

## Jeszcze nie sprawdzone

- idle;
- wariant stroju z animacją;
- animacje scen konfrontacji (broń, pies);
- mapy normalnych w dzień i w nocy;
- inne sylwetki: kobieta, płaszcz, dziecko, zwierzę.

Przy chodzie bokiem zostają drobne błędy, akceptowalne w wersji 1.

Chód przodem wygląda na szeroki, choć stopy stawiane są wąsko (6–8 px wobec 11 px w staniu). Nogi tworzą odwrócone V, kolana odstają na boki, a dłonie odchodzą od ciała. Do sprawdzenia przy pierwszej postaci do gry: w opisie 8 klatek przodem dopisać „narrow natural gait, knees stay close together and move straight forward, feet land close to the center line, arms swing close to the body” i wybrać najlepszą z 2–3 wersji.
