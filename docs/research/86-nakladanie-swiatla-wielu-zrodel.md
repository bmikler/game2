# 86 - Nakładanie światła i cieni z wielu źródeł w 2D i pixel arcie

Data: 2026-11-15. Ticket: [02 mapy silnika](../wayfinder-silnik/tickets/02-nakladanie-cieni-wiele-zrodel-research.md).
Buduje na [02](02-pixel-art-oswietlenie.md), [81](81-spojne-cienie-architektura.md), [82](82-stylizacja-swiatla-pixel-art.md),
[83](83-stylizacja-swiatla-plener.md) i [84](84-stylizacja-swiatla-plener-opus.md). Tamtych ustaleń nie powtarzam,
tylko się do nich odwołuję (zwłaszcza formuła A′ z 84, sekcja 6).

Pytanie: jak gry 2D i pixel art z dynamicznym światłem łączą światło i cienie z wielu źródeł naraz (słońce, niebo,
lampy, świecące okna): addytywnie czy inaczej? Jaki kolor ma cień? Jak cień jednego źródła wygląda w świetle drugiego?
Co z kolejnością, nasyceniem, clampem, tone mappingiem i ekspozycją? Jak stylizacja do pikseli (progi, dither) radzi
sobie z sumą wielu źródeł?

## Oceny źródeł

- **[P]**: źródło pierwotne (dokumentacja silnika, kod źródłowy, tekst autora) przeczytane w tej sesji.
- **[S]**: wtórne (fragmenty z wyszukiwarki, fora, streszczenia) albo pierwotne, ale nieotwarte.
- **[N]**: szukane, nie znalezione albo nieczytelne.
- **[Wn]**: mój wniosek inżynierski, nie twierdzenie źródła.

**Zastrzeżenie:** w trakcie sesji na chwilę wyczerpał się limit narzędzi sieciowych. Po wznowieniu doczytałem
darktable, Gurneya („Downfacing Planes”) i Minecrafta. Devlogów gier pixel art o nakładaniu cieni więcej nie znalazłem
(sekcja 8).

Wynik jest podobny jak w 82–84: **żadna gra pixel art nie opisuje w przeczytanych źródłach, jak stylizuje sumę wielu
źródeł z cieniami.** Mocne źródła pierwotne są za to w trzech miejscach: kod i dokumentacja silników 2D (Godot,
Unity URP 2D, box2dlights) pokazują, jak się światła **składa**; malarstwo plenerowe (Gurney) mówi, **skąd bierze się
kolor cienia**; poradniki pikselarzy (Slynyrd) mówią, jak **kolor zmienia się z jasnością**.

## 1. Jak silniki 2D łączą światła (fakty)

| Silnik / źródło | Jak łączy | Ocena |
|---|---|---|
| **Godot 4, renderer 2D (kod `canvas.glsl`)** | Kolor zaczyna od albedo i jest mnożony przez `canvas_modulation` (ambient). Potem w pętli po światłach każde światło jest mnożone przez albedo (`light_color.rgb *= base_color.rgb`) i dokładane do akumulatora: tryb Add `color.rgb += light_color.rgb * light_color.a`, Sub `color.rgb -= …`, Mix `color.rgb = mix(color.rgb, light_color.rgb, light_color.a)`. [kod](https://github.com/godotengine/godot/blob/master/drivers/gles3/shaders/canvas.glsl) | [P] (kod czytany przez narzędzie streszczające, cytaty dosłowne) |
| **Godot 4, dokumentacja 2D** | „The default Add is suited for most use cases.” Subtract „can be used for negative lights, which are not physically accurate”. `CanvasModulate` to „the base "ambient" color … the final lighting color in areas that are *not* reached by any 2D light”. [2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html) | [P] |
| **Godot 4, shader `canvas_item`** | „Godot no longer draws the object again for each light … all lighting is done during the regular draw pass.” `light()` zwraca `LIGHT`: „Output color for this Light2D”, czyli wynik **jednego** światła. Dokumentacja nie daje w `light()` dostępu do sumy wszystkich świateł. [canvas_item shader](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html) | [P] |
| **Godot 4, HDR 2D** | `use_hdr_2d`: framebuffer `RGBA16`, rysowanie 2D „performed on linear values”, wynik „will not be clamped to the `0-1` range”. Bez tej opcji wynik 2D jest więc ograniczony do 0–1. [Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html) | [P] |
| **Unity URP 2D** | Każde światło ma Blend Style: Multiply („Multiplies the light with the background”), Additive, Multiply/Additive with Mask. Przy nakładaniu świateł Overlap Operation: „Additive: Adds the colors together so the lights blend. This is the default.” albo Alpha Blend (alfa koloru decyduje, jedno światło przykrywa drugie). Light Order „has the most effect … when you set Overlap Operation to Alpha Blend”. Intensity > 1 w Multiply „will brighten sprites beyond their original color”. Cień: Strength 0–1, „0 means no light is blocked and 1 means all light is blocked”. [2D light properties](https://docs.unity.com/en-us/engine/6000.6/manual/unity2d/2d-urp/2d-index/2dlight-properties) | [P] |
| **Unity URP 2D, Custom Blend Factors** | Wszystkie tryby jako dwa współczynniki: Multiply = Modulate 1, Additive 0; Additive = 0, 1; Subtractive = 0, −1. [Light Blend Styles 9.0](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@9.0/manual/LightBlendStyles.html) | [P]; sam wzór `tło·Modulate + światło·Additive` to mój odczyt [Wn] |
| **box2dlights (libGDX)** | Światła bez cieni: blend `GL_SRC_ALPHA, GL_ONE`, czyli dodawanie. Ambient: „Specifies how shadows colored and their brightness”, alfa „clamped to [0f; 1f]”. Tryb „diffuse”: „more realistic model than normally used as it preserve colors but might look bit darker”. [RayHandler.java](https://github.com/libgdx/box2dlights/blob/master/src/box2dLight/RayHandler.java) | [P] (kod) |
| **Frank Force (Faster Blaster)** | Jedna wspólna mapa światła: każde światło renderowane do niej „with an additive blend”, potem rozmycie Gaussa i mnożenie przez scenę. Kolor światła = kolor, w jakim rysuje się jego mapę cienia. Brak ambientu i clampu w opisie. [blog](https://frankforce.com/2d-light-mapping/) | [P] (autor) |
| **Crystal 2D (GameMaker)** | Tryby Multiply, Multiply Normalized, Multiply Linear, Add; autor: światła „multiplicatively additive”; „Lights compensation … multiplies after blending (basically an exposure control)”; w HDR „Multiply LDR” jako „clamp”. [itch.io](https://foxyofjungle.itch.io/crystal-2d-lighting-engine) | [P] (autor, strona produktu; bez wzorów) |
| **Minecraft** (dla porównania, nie pixel art 2D) | Dwa rodzaje światła na blok, każdy 0–15: niebo i bloki (pochodnie). Poziom światła dla logiki gry to „`max(sky light, block light)`”, a nie suma [wiki](https://minecraft.wiki/w/Light). Do **rysowania** obie wartości są współrzędnymi w teksturze 16×16: „Each texel corresponds to a combination of Block Light and Sky Light”, kolor sprite'a jest „modulated” tym tekselem; „Block light imparts a reddish/brownish colour whereas Sky Light does not”; tablicę zmienia się z porą dnia („full sun, sunset”) i migotaniem pochodni [greyminecraftcoder](https://greyminecraftcoder.blogspot.com/2013/08/lighting.html) | wiki fanowska [S], ale szczegółowa; blog moddera czytający kod [S]. Ważny precedens: **tabela kolorów indeksowana dwoma kanałami światła zamiast sumy RGB** |
| **Graveyard Keeper** | Do 4 cieni na obiekt: „one from the sun and up to three additional ones from dynamic light sources”, cienie to obracane sprite'y, „all the shadows are black anyway”. Jak nakładają się dwa cienie, **nie podano**. Ambient z gradientu po porze dnia, 10 LUT-ów. [blog twórcy](https://slava.lazybeargames.com/graveyard-keeper-how-the-graphics-effects-are-made) | [P]; ponownie sprawdzone pod kątem nakładania |

**Fakty zbiorcze:**
1. Domyślnym i zalecanym sposobem łączenia świateł we wszystkich przeczytanych silnikach 2D jest **dodawanie**.
   Ambient działa jako podłoga: mnożnik albedo w Godocie, osobny kolor „cieni” w box2dlights.
2. W Godocie i w Unity wynik ma postać `albedo × (ambient + Σ światło_i × widoczność_i)`. W Unity oprócz tego
   istnieje Multiply jako alternatywa (światło jako mnożnik tła).
3. Tryby **nieprzemienne** (Godot Mix, Unity Alpha Blend) istnieją, ale tylko w nich ma znaczenie **kolejność**
   świateł (Unity: Light Order). Przy dodawaniu kolejność nie ma znaczenia. Maksimum (Minecraft, logika gry) też jest
   przemienne, ale gubi nakładanie [Wn]: miejsce oświetlone przez dwa źródła nie jest jaśniejsze niż przez mocniejsze z nich.
4. Minecraft pokazuje trzecią drogę: źródła nie są sumowane w RGB, tylko trzymane w **osobnych kanałach** (niebo,
   bloki), a kolor wynika z **tabeli 2D** (artystycznej, zmienianej z porą dnia), w której ciepło niesie tylko kanał
   bloków.
5. Clamp: Godot bez HDR 2D obcina wynik do 0–1; box2dlights obcina ambient do 0–1; Crystal proponuje „Multiply LDR”
   jako clamp. Żaden z przeczytanych silników 2D nie ma w dokumentacji tone mappingu specjalnie dla 2D.

## 2. Kolor cienia (fakty)

| Źródło | Co mówi | Ocena |
|---|---|---|
| Godot `Light2D.shadow_color` | „By default, shaded areas are fully black, but this can be changed for artistic purposes. The color's alpha channel controls how much the shadow is tinted”. W kodzie: `return mix(light_color, shadow_color, shadow)`, a wynik idzie do Add. [docs](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html), [kod](https://github.com/godotengine/godot/blob/master/drivers/gles3/shaders/canvas.glsl) | [P] |
| box2dlights | Kolor ambientu jest tym, jak „shadows colored and their brightness”. | [P] |
| Gurney, „Complementary Shadows” (2014) | „shadows really are in a complementary color range compared to the sunlit surfaces”, bo cień oświetla błękitne niebo; „the sunlit surfaces are lit by the sum of the sunlight and the skylight, with the sunlight dominating”; efekt rośnie przy niskim słońcu. Zastrzeżenie: „the shadow side of any object receives not only skylight, but also reflected light from other sources”, więc cień bywa ciepły. Część wrażenia daje sam wzrok: „exposure to any color causes adjacent colors to appear complementary”. [blog](https://gurneyjourney.blogspot.com/2014/09/complementary-shadows.html) | [P] (malarz, autor „Color and Light”) |
| Gurney, „Cast Shadows Part 2” (2009) | cienie rzucane są niebieskie „only because they're normally thrown across surfaces” zwróconych do nieba; jasność i temperaturę cienia wyznaczają widoczne z niego jasne płaty: „Those patches of light determine the brightness and color temperature of your shadow”; „On overcast days, the fill light is white”. [blog](https://gurneyjourney.blogspot.com/2009/07/cast-shadows-part-2.html) | [P] |
| Gurney, „Downfacing Planes” (2008) | „In shadows, upfacing planes are cool, and downfacing planes are warm.” Płaszczyzny w dół „pick up the warm reflected color of illuminated surfaces below them”; w górę są niebieskie „beneath an open stretch of sky”. [blog](https://gurneyjourney.blogspot.com/2008/02/downfacing-planes.html) | [P] |
| Disco Elysium | Globalne kolory słońca **i cienia** zależne od pory dnia (za 84). [devblog](https://discoelysium.com/devblog/2016/02/02/shedding-light) | [P] za 84 |
| Slynyrd (Raymond Schlitter), Pixelblog 1 | Rampa koloru z przesunięciem barwy: „the hue is shifting by positive degrees as the brightness increases”, „warming as they become brighter”; „As the colors reach high brightness levels it's important to decrease saturation”; „Generally, darker colors have more saturation”, ale bardzo ciemne nie mogą być przesycone. [blog](https://www.slynyrd.com/blog/2018/1/10/pixelblog-1-color-palettes) | [P]; artykuł nie wiąże tego ze źródłem światła |

**Fakty zbiorcze:**
1. W silnikach kolor cienia to **parametr artystyczny** jednego światła (Godot) albo ambientu (box2dlights).
   Uwaga: w Godocie `shadow_color` przechodzi przez tryb Add, więc kolorowy cień **dodaje światło** w miejscu,
   gdzie dane światło jest zasłonięte. To nie jest „cień w kolorze”, tylko drugie, sztuczne źródło przypięte do cienia.
2. U malarzy kolor cienia **nie jest osobnym parametrem**: to kolor tych źródeł, które nadal do niego docierają (niebo,
   światło odbite, zachmurzenie). Dlatego cień słońca jest niebieski pod niebem i biały w pochmurny dzień.
3. Pikselarze robią rampę, w której jaśniej = cieplej i mniej nasycone, ciemniej = chłodniej i bardziej nasycone.

## 3. Jak cień jednego źródła wygląda w świetle drugiego

**Fakty:** przy dodawaniu (sekcja 1) cień źródła A to po prostu brak składnika A. W tym miejscu zostaje suma pozostałych
źródeł. Gurney opisuje dokładnie to w plenerze: cień słońca = światło nieba i odbić. Unity „Strength” 0–1 to ułamek
światła **danego** źródła, który przesłona blokuje. Jak Graveyard Keeper łączy 4 czarne sprite'y cieni, autor nie
podaje [P/N].

**Wnioski [Wn]:**
- **Cień słabego źródła w świetle mocnego prawie znika.** Lampa przy ulicy w południe: cień postaci od lampy zmienia
  luminancję o ułamek procenta. Fizycznie jest, ale nie widać go.
- **Kolor cienia wynika sam.** Cień ciepłej lampy na ulicy oświetlonej niebem jest chłodny (zostaje niebo). Cień słońca
  wieczorem przy świecącym oknie jest ciepły od okna. Nie trzeba żadnego parametru „kolor cienia”.
- **Przecięcie cieni dwóch źródeł** (np. dwie latarnie, postać pośrodku) jest ciemniejsze niż każdy z nich osobno, bo
  brakuje obu składników. Półcienie dodają się liniowo, więc przejścia nadal są gładkie przed stylizacją.
- **Kolejność nie istnieje.** Dodawanie jest przemienne, więc wynik nie zależy od tego, które źródło liczy się pierwsze.
  To jest dokładnie warunek „działa przez konstrukcję”: dodanie latarni do Lokacji nie wymaga ustawiania kolejności ani
  kolorów cieni.

## 4. Nasycenie, clamp, tone mapping, ekspozycja

**Fakty:**
- Godot, tryby tone mappingu: Linear „unnaturally clips bright values”; Reinhard „rolls off bright values to prevent
  clipping”, przy White 1,0 równy Linear; ACES „desaturates bright values”; AgX „Better than other tonemappers at
  maintaining the hue of colors as they become brighter”. Exposure „Adjusts the brightness of values before they are
  provided to the tonemapper”. [Environment and post-processing](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html) [P].
  Dokumentacja nie mówi wprost, czy ten tone mapping działa na 2D (tylko tło Canvas w scenie 3D) [P/N].
- Krzywa stosowana **osobno do każdego kanału RGB** popycha jasne, nasycone kolory ku sześciu barwom podstawowym i
  dopełniającym. Instrukcja darktable: krzywa per kanał „introduces color shifts, with color tending towards the
  primary (red, green and blue) and secondary” colors; „Per-channel S-curves have the property of desaturating
  highlights”; AgX daje „path to white”, w którym kolory „desaturate and shift hue in a way that looks more natural”.
  [darktable AgX](https://docs.darktable.org/usermanual/5.6/en/module-reference/processing-modules/agx/) [P].
  Nazwa „notorious six” pochodzi z forów pixls.us [S].
- Slynyrd: najjaśniejsze kolory trzeba odbarwiać (sekcja 2) [P]. ACES i AgX robią to samo krzywą [P].
- Crystal: „exposure control” jako mnożnik po zsumowaniu świateł [P].

**Wnioski [Wn]:**
- Clamp na kanał (LDR, `min(rgb, 1)`) przy sumie wielu źródeł psuje barwę: ciepła lampa przy mocnym świetle traci
  niebieski i zielony w różnym tempie i robi się żółta, a potem biała. Dlatego suma musi się liczyć w HDR (liniowo,
  bez clampa), a ograniczenie jasności powinno działać **na luminancji z zachowaniem stosunków RGB** albo przez krzywą
  typu AgX, nie na każdym kanale osobno.
- **Ekspozycja to mnożnik sumy, a nie pojedynczych źródeł.** Inaczej przestaje działać przemienność z sekcji 3.
- W pixel arcie tone mapping „ciągły” (Reinhard, AgX) stoi w konflikcie z płaskimi poziomami: krzywa zmienia odstępy
  między poziomami w jasnych partiach. Czysta kolejność to **najpierw kwantyzacja w EV, potem mapowanie numeru poziomu
  na jasność i nasycenie ekranu**. Krzywa jest wtedy tabelą „poziom → jasność, odbarwienie”, czyli rampą jak u
  pikselarzy (Slynyrd) i jak paleta Rain World „3 tony w słońcu, 3 w cieniu” (za 84).

## 5. Stylizacja (progi, dither) a suma wielu źródeł

**Fakty:**
- Toon shading w Unity: Unity Toon Shader stroi „light steps (boundaries) added in the ForwardAdd pass, such as
  real-time point lights” [docs](https://docs.unity3d.com/Packages/com.unity.toonshader@0.9/manual/ShadingStepAndFeather.html) [P].
  ForwardAdd to osobne przejście addytywne na każde dodatkowe światło, więc progi powstają **dla każdego światła
  osobno** [Wn, wiedza o pipeline Unity]. Toon RP: dodatkowe światła per piksel używają „the same diffuse ramp as the
  main light”, limit 4 światła na obiekt, „Additional lights do not support shadows” [wiki](https://github.com/Delt06/toon-rp/wiki/Additional-Lights) [P].
- Godot 2D: `light()` widzi tylko jedno światło (sekcja 1) [P]. Stylizacja zrobiona w `light()` jest więc z
  konstrukcji stylizacją **per źródło**.
- Crystal ma dither „for retro aesthetic” jako opcję; gdzie stoi w potoku, strona nie mówi [P].
- Żadna przeczytana gra pixel art nie opisuje kwantyzacji **sumy** światła z cieniami wielu źródeł [N]. To ten sam
  wynik negatywny co w 82–84.

**Wnioski [Wn]:**
- Gotowe ścieżki silników (Light2D w Godocie, ForwardAdd w Unity) prowadzą do progowania per źródło. Daje to dwie znane
  wady: każda słaba lampa rysuje własną twardą krawędź, nawet gdy w sumie jest niewidoczna, a przy nakładaniu dwóch
  źródeł granice dwóch progów tworzą schodki i podwójne linie. To zgodne z porażką B/C opisaną w 82 i 84.
- **Próg na sumie (A′ z 84) obsługuje wiele źródeł przez konstrukcję.** Słaby cień lampy w słońcu zmienia `s` o mniej
  niż jeden krok, więc zwykle nie przekracza granicy poziomu i znika. Pojawia się dopiero tam, gdzie lampa ma udział
  porównywalny ze słońcem. To jest zachowanie fizyczne, tylko w schodkach. Przecięcia cieni dają po prostu niższy
  poziom, a wiele granic w kilku pikselach obsługuje formuła `k = floor(s + W·(b − 0,5))` bez żadnej logiki.
- **Nowa luka, której 84 nie dotyka: barwa.** A′ kwantyzuje tylko luminancję, a kolor odtwarza jako `rgb · (q − amb) / own`.
  Gdzie ciepła lampa przechodzi w chłodne niebo przy podobnej luminancji, w środku płaskiego poziomu zostaje **gładki
  gradient barwy**. Tak samo cień lampy w świetle nieba: luminancja w obrębie jednego poziomu, ale barwa płynnie się
  zmienia, więc ślad cienia jest widoczny jako miękka plama koloru. W rampie pikselarza barwa skacze razem z tonem.
  Możliwe rozwiązania, wszystkie bez gałęzi na źródło:
  1. **nic nie robić** i ocenić na żywo (gradient barwy w pixel arcie może być akceptowalny, bo luminancja dominuje
     w odbiorze struktury);
  2. **kwantyzować udział ciepła** `h = L_ciepłe / L_razem` (albo ogólniej współrzędną barwy, np. stosunek R/B) tą samą
     formułą ze szwem w px: kilka stopni mieszanki, szew wyśrodkowany na izolinii. Wymaga to, żeby bufor niósł tę
     wielkość, a nie tylko gotowe RGB;
  3. **paleta 2D** (poziom jasności × stopień barwy) jako dane w `.tres`. Precedens: tabela 16×16 Minecrafta
     indeksowana światłem nieba i światłem bloków (sekcja 1), zmieniana z porą dnia. U nas osie byłyby np. „poziom
     światła chłodnego (niebo, słońce)” × „poziom światła ciepłego (lampy, okna nocą)”, oba skwantyzowane formułą A′.
     Wtedy barwa skacze razem z poziomem, jak w rampie pikselarza, a kolory doby to dane tabeli.
  Precedens dla 3 jest z gry 3D i bez cieni stylizowanych ditherem; dla 1 i 2 źródeł brak. To pytanie do prototypu
  nakładania (ticket 09 mapy silnika).
- **Dither na granicy dwóch źródeł:** formuła z 84 liczy gradient `s` sumy. Gradient sumy jest zawsze dobrze określony,
  więc szew ma stałą szerokość także tam, gdzie spotykają się plamy dwóch lamp. Nie trzeba niczego dodawać.

## 6. Odpowiedzi na pytania ticketu (krótko)

| Pytanie | Co robią inni (fakty) | Wniosek dla nas [Wn] |
|---|---|---|
| Addytywnie czy inaczej? | Dodawanie domyślnie wszędzie (Godot, Unity, box2dlights, Frank Force). Mix/Alpha Blend i Multiply jako opcje artystyczne. | Dodawanie w liniowym HDR. Przemienne, więc kolejność źródeł nie istnieje. |
| Kolor cienia? | Silniki: parametr (czarny domyślnie, `shadow_color`, kolor ambientu). Malarze: kolor pozostałych źródeł (niebo = niebieski, odbicie = ciepły, pochmurno = biały). | Bez parametru „kolor cienia”. Cień ma kolor sumy pozostałych źródeł. Zgadza się to z ustaleniem mapy „baza chłodna, ciepło tylko przy źródłach”. |
| Cień źródła A w świetle B? | Brak składnika A, zostaje B (Gurney; wzór silników). | Wynika sam. Słaby cień w mocnym świetle znika po progowaniu sumy. |
| Kolejność? | Ma znaczenie tylko przy Alpha Blend/Mix (Unity Light Order). | Nie potrzebna. |
| Clamp, tone mapping, ekspozycja? | Linear obcina; Reinhard/ACES/AgX zaokrąglają; ACES i AgX odbarwiają; per kanał zmienia barwę [S]. Ekspozycja przed tone mappingiem. | Suma w HDR, ekspozycja na sumie, kwantyzacja w EV, potem tabela „poziom → jasność, odbarwienie” zachowująca barwę. Bez clampa na kanał. |
| Stylizacja przy sumie? | Gotowe pipeline'y stylizują per światło (ForwardAdd, `light()`); brak gry z kwantyzacją sumy. | A′ na luminancji sumy działa przez konstrukcję. Otwarta zostaje barwa (sekcja 5). |

## 7. Co z tego dla Silnika światła game2

Wszystko w tej sekcji to wnioski [Wn] z faktów powyżej. Decyzje należą do człowieka (ticket 07 „Jeden model światła”,
09 „Nakładanie cieni, prototyp”, 12 „Specyfikacja”).

1. **Jedna reguła łączenia:** `E = ambient + Σ_i kolor_i(godzina) × natężenie_i × widoczność_i`, liczona liniowo
   w HDR w jednym buforze. Słońce, niebo, lampy, latarnie i świecące okna to te same składniki sumy, różnią się tylko
   danymi (kształt, kolor i krzywa doby). Bez trybów Mix, Subtract, Multiply i bez kolejności źródeł. To spełnia zasadę
   „bez ifów, działa przez konstrukcję”.
2. **Bez parametru „kolor cienia” na źródło** (odpowiednika `Light2D.shadow_color`). Cień ma kolor tego, co zostaje.
   Chłodne cienie w plenerze dostajemy z nieba, ciepłe cienie przy oknie nocą z okna. Jeśli cienie będą za czarne, to
   jest sygnał, że brakuje źródła (niebo, odbicie), a nie że trzeba barwić cień. Dozwolone pokrętło to **ambient jako
   jeden składnik sumy** (podłoga, odpowiednik światła odbitego, które Gurney opisuje jako ciepłe pod spodem), dane
   w `.tres`, w krzywej doby.
3. **Odbicie od ziemi (Gurney: płaszczyzny zwrócone w dół są ciepłe)** to ewentualny przyszły składnik danych
   (np. słabe światło od podłogi), nie wyjątek w kodzie. Na teraz poza zakresem; warto zapisać w „Not yet specified”.
4. **Kolejność potoku dla każdego piksela:** suma w HDR → ekspozycja przestrzeni (mnożnik sumy, ADR 0007) →
   A′ na luminancji sumy (84) → tabela „numer poziomu → jasność ekranu i odbarwienie” (krzywa w `.tres`, strojona w F1)
   → odtworzenie RGB ze stosunków kanałów → sRGB. Żadnego clampa na kanał przed kwantyzacją. Tabela zastępuje tone
   mapping i daje jasnym poziomom odbarwienie jak w rampie pikselarza (Slynyrd) i w AgX.
5. **Stylizacja tylko na sumie, nigdy w `light()` Light2D.** Wbudowane światła 2D Godota liczą `light()` per źródło,
   więc nie da się w nich progować sumy. To potwierdza wcześniejszą decyzję mapy grafiki (jeden bufor, ticket 36)
   i wyklucza budowę Silnika na `PointLight2D` z cieniami Godota.
6. **Bufor musi nieść więcej niż gotowe RGB, jeśli kwantyzujemy barwę.** Jeśli prototyp pokaże, że gradient barwy
   wewnątrz poziomu przeszkadza (sekcja 5), potrzebna jest współrzędna barwy (np. udział źródeł ciepłych) obok
   luminancji, kwantyzowana tą samą formułą szwu, albo dwa kanały „chłodne” i „ciepłe” jak w tabeli Minecrafta.
   To trzeba przewidzieć w kontrakcie bufora (ticket 08 lub 10), żeby nie przebudowywać go później. Podział na
   kanały musi wynikać z danych źródła (np. pole „kanał” w zasobie źródła), a nie z jego typu w kodzie.
7. **Sceny testowe dla prototypu nakładania (ticket 09):** (a) postać między dwiema latarniami nocą: dwa cienie,
   przecięcie, kolory; (b) latarnia zapalona w dzień: jej cień ma zniknąć po progowaniu; (c) zmierzch: słońce, niebo
   i włączające się lampy naraz, czy granice poziomów nie skaczą (kotwica `Y_ref` z 84 działa dla nieba; lampy
   przesuwają granice, co jest zamierzone); (d) wnętrze nocą: lampa i świecące okno od ulicy, cień mebla od każdego;
   (e) bardzo jasny rdzeń lampy: czy barwa nie żółknie i czy odbarwienie z tabeli wygląda dobrze.
8. **Czego nie robić:** progów per źródło (B/C z 84), kolorów cienia przypiętych do świateł, trybów nieprzemiennych,
   clampa LDR przed stylizacją, osobnego tone mappingu dla wnętrza i pleneru (dwa zestawy `.tres` są dozwolone, osobna
   logika nie).

## 8. Najsłabsze miejsca

- Brak opisu z gry pixel art, jak stylizuje sumę wielu źródeł z cieniami. Wszystkie zalecenia z sekcji 5 i 7 to moje
  wnioski, oparte na budowie silników 2D i na zasadach malarskich, nie na precedensie.
- Nie sprawdzone: Terraria i Starbound [N]; instrukcja Sprite Lamp (cel shading, wiele świateł; znalazłem tylko
  stronę sklepu) [N]; slajdy Never's End (GDC 2026), które 84 wskazał jako najbardziej obiecujące [N].
- Minecraft: obie strony to źródła fanowskie (wiki, blog moddera), nie Mojang. Opis tablicy 16×16 jest spójny w obu.
- Kod Godota (`canvas.glsl`, renderer Compatibility) czytałem przez narzędzie streszczające; cytaty linii są dosłowne,
  ale nie sprawdzałem odpowiednika w rendererze Forward+ (`drivers/vulkan`/`servers/rendering/renderer_rd`). Zasada
  dodawania jest ta sama według dokumentacji.
- To, że Unity Toon Shader progował per światło, wynika z opisu „ForwardAdd pass”, nie z kodu.
- Kwantyzacja barwy (sekcja 5) nie ma żadnego źródła; to kandydat do prototypu.
