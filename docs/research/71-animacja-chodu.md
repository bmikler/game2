# 71. Animacja chodu postaci 72 px (detektyw; stan po zmianie: krótka kurtka, nogi widoczne)

Ticket: `docs/wayfinder/tickets/19-animacja-chodu-research.md`. Data: 2026-11-08. Nic nie zostało wygenerowane, pobrane ani zainstalowane; czytane: OpenAPI i dokumentacja Pixellab, karty modeli, strony narzędzi, lokalne pliki i lista modeli ComfyUI (tylko odczyt).

Oznaczenia: **[OpenAPI]**, **[doc]**, **[karta]** = źródło pierwotne; **[wtórne]** = blog/forum/wyszukiwarka, słabsza wiarygodność; **[log]** = własne próby (ticket 12); **[wniosek]** = moja inferencja; **[brak]** = nie znalazłem źródła.

## Odpowiedź w skrócie

1. Problem pierwszej próby: Qwen-Image-Edit dostaje każdą klatkę osobno, więc nie ma ciągłości; autorzy LoRA SpriteForge piszą, że bazowy Qwen-Image-Edit-2511 daje „niespójny wygląd i niespójne sekwencje klatek” **[wtórne: tantk.github.io/spriteforge-pipeline]**. Pierwotnie dokładał się płaszcz zasłaniający nogi; po zmianie na kurtkę do bioder (zob. „Weryfikacja” na końcu) ten drugi powód odpada, pierwszy zostaje.
2. Lokalne wideo z obrazu (Wan 2.2) **zmieści się** w 8 GB, ale daje wideo 24 fps z kamerą i tłem, bez kontroli liczby klatek i bez gwarancji pętli; nie jest to narzędzie do spriteów 72 px **[wniosek]**. Wan 2.2 TI2V 5B: Apache 2.0, autorzy „nie rościmy praw do wygenerowanych treści” **[karta HF Wan-AI/Wan2.2-TI2V-5B]**.
3. Pixellab ma trzy kandydackie endpointy do animacji **własnego** sprite'a: `animate-with-text-v3`, `animate-pixminimax` i `animate-with-skeleton-v3` (koszty w §3). Pierwsza klatka zostaje bez zmian, kanwa do 256×256 **[OpenAPI, doc]**. Czy trzymają nasz malarski styl, **nie wiadomo [brak]**; da się to sprawdzić za 1-4 generacji.
4. Po zmianie na kurtkę (nogi i spodnie w pełni widoczne) **cut-out przestaje być najlepszą drogą**: trzeba by rigować uda/łydki/kolana na ok. 30 px nogi, co wygląda jak kukiełka. Mocniejsze stają się drogi z pozą: `animate-with-skeleton-v3` (keypointy nóg są teraz estymowalne) oraz render 3D MPFB z kolorowymi strefami (kurtka/spodnie/buty) wprost do pikseli, bo kurtka jest blisko ciała i nie wymaga proxy płaszcza.
5. **Rekomendacja (po zmianie):** (1) Pixellab `animate-pixminimax`/`-text-v3`/`-skeleton-v3` na jednym kierunku (bok) nowego sprite'a w kurtce, 5-6 generacji z puli triala, po zgodzie; (2) lokalnie 0 zł: chód MPFB (`postac_chod.py`, kolorowe strefy) wprost do 72 px jako ruch referencyjny, opcjonalnie przepuszczony przez Qwen z kolorową pozą. Cut-out spada do awaryjnego (przód/tył: bob). Wideo i LoRA arkuszy nadal na potem. **Warunek wstępny:** nowy sprite 72 px w kurtce (koncept9 → Qwen kąt → pikselizacja) musi najpierw powstać.

## 1. Lokalnie (8 GB VRAM, ComfyUI)

Stan lokalny (odczyt): zainstalowane `ComfyUI-GGUF`, `flux-2-klein-4b-fp8`, `qwen-image-edit-2511-Q4_K_M.gguf`, LoRA Multiple Angles i Lightning 4, `pixel-art-xl`, `controlnet-depth-sdxl`. **Brak** modeli Wan/LTX/VACE, węzłów wideo (VideoHelperSuite, WanVideoWrapper), `comfyui_controlnet_aux` (DWPose) i ControlNetów dla Qwen. Każda poniższa droga wymaga więc pobrań i instalacji (zgoda człowieka).

| Droga | Co mówią źródła | Ocena dla nas |
|---|---|---|
| **Wan 2.2 I2V / TI2V 5B** | 5B: Apache 2.0, I2V w jednym modelu; oficjalne polecenie 24 GB VRAM, z offloadem mniej **[karta]**. ComfyUI: 5B „powinien się zmieścić w 8 GB z natywnym offloadem” **[wtórne: docs.comfy.org/tutorials/video/wan/wan2_2]**. GGUF Q4 5B przy ok. 8 GB szczytu **[wtórne: localmodel.run]**. Czasy na 8 GB: 111 s/klip (14B „Rapid”, `--lowvram`, lilting.ch), 181 s za 5 s 480p (GGUF, 6 kroków, Runflow); **[wtórne, rozrzut]** | Zmieści się, ~2-4 min/klip **[wtórne]**. Ryzyka **[wniosek]**: kamera/tło ruszają się, postać ma 72 px (po przeskalowaniu do 480p to ok. 12% wysokości kadru), dryf palety i szczegółu, brak pętli, 24 fps trzeba rzedzić do 8 kl./s i kwantyzować. Licencja czysta. |
| **Wan VACE / Fun Control (poza, głębia)** | VACE-1.3B: Apache 2.0, tylko 480p, ok. 81 klatek, wejścia `src_video`/`src_mask`/`src_ref_images`; poza/głębia wymagają preprocessingu **[karta HF Wan2.1-VACE-1.3B]**. Wan 2.2 Fun Control wspiera pose, depth, canny **[wtórne: blog.comfy.org]**; Fun VACE 14B wymaga ok. 60 GB **[wtórne]**, GGUF od Kijai istnieją. Czasów dla 8 GB z kontrolą nie znalazłem **[brak]**. | Teoretycznie to „właściwy” lokalny kierunek (poza z MPFB + referencja = nasza postać), ale wymaga DWPose/OpenPose, modeli ~kilkanaście GB i tuningu; przy widocznych nogach (kurtka) model nie musi zgadywać nóg pod płaszczem, więc jest to teraz sensowniejsze, ale nadal ciężkie (pobrania, DWPose, brak czasów dla 8 GB). Nie jako pierwszy krok. |
| **LTX-Video** | Licencja „other”, pliki `LTX-Video-Open-Weights-License-0.X.txt`; strona nie podaje warunków komercyjnych **[karta HF Lightricks/LTX-Video]**. | **Licencję trzeba przeczytać przed użyciem**; do wydania na Steam traktować jako niepotwierdzone. |
| **AnimateDiff + ControlNet** | Nie sprawdzano źródeł pierwotnych (SDXL/SD1.5, kostium obcisły z depth, odrzucone w tickecie 12). | Pomijam; zaawansowany stos pod SD1.5, słaby pixel art. |
| **Qwen-Image-Edit-2511 + kontrola pozy** | Karta modelu: Apache 2.0; **nie wspomina** o ControlNet/pozie, tylko o spójności postaci, zintegrowanych LoRA (nowy kąt) i „geometric reasoning” **[karta HF Qwen/Qwen-Image-Edit-2511]**. InstantX Qwen-Image-ControlNet-Union (canny/soft edge/depth/pose, pose z DWPose, skala 0,8-1,0) jest zrobiony pod **Qwen-Image**, nie Edit **[karta HF InstantX]**. Workflow społeczności: DWPose → szkielet jako obraz wejściowy Qwen-Edit-2511 **[wtórne: HF JahJedi]**. | To praktycznie nasza dotychczasowa metoda (druga referencja z pozą), tylko z kolorowym szkieletem zamiast manekina; może poprawić przeniesienie nóg, nie naprawia braku ciągłości. Tania próba (§4, próba L1). |
| **Siatka / arkusz klatek w jednym obrazie** | LoRA `svntax-dev/pixel_spritesheet_4walk_combat_32x48_v1` (Qwen-Image-Edit-2511, prompt „Create a pixel art spritesheet of the character in the image”) i `Mystic07/flux-lora-spritesheet` (FLUX.2 klein, LPC 4 kierunki) **[wtórne: wyniki wyszukiwania, strony HF]**; SpriteForge celuje w siatkę 4×4 po ok. 100 par treningowych **[wtórne]**. Licencji LoRA nie sprawdzono **[brak]**, spójności klatek nie zmierzono nigdzie **[brak]**. | Jeden obraz = wspólny kontekst, więc spójność lepsza niż osobne klatki, ale: styl LoRA to 32×48 stylizowany sprite, a nasz jest malarski 72 px; płótno 8 klatek × 72 px to ok. 576×144 poza rozdzielczością modelu (trzeba duże kafle, potem Lanczos). Opcja eksperymentalna, nie rekomendowana jako pierwsza. |

Na tej karcie (RTX 4060 Laptop 8 GB) nasz sprawdzony czas Qwen to ok. 2,5-3 min/klatkę **[log]**, czyli 8 klatek × 4 kierunki to ponad godzina na wersję próbną, bez gwarancji spójności.

## 2. Klasycznie i hybrydowo (bez AI per klatka)

### 2a. Cut-out 2D z naszego sprite'a (po zmianie na kurtkę: tylko awaryjnie / przód i tył)

- Dostępne: sprite'y 72 px w DŁUGIM płaszczu (`proby/postac_kat5/`) są nieaktualne; nowy w kurtce jeszcze nie istnieje (koncept `proby/koncept9/edit_kurtka_s9000.png`: kurtka do bioder, szare spodnie, brązowe buty, szalik, wyraźny czarny kontur, styl bardziej komiksowy niż poprzedni malarski; **[wniosek]** warto to ocenić przed dalszymi krokami).
- Narzędzia: Godot 4 ma `Skeleton2D`/`Bone2D`/`Polygon2D` (rig i deformacja siatką) **[wniosek, znane z dokumentacji Godot; nie weryfikowane w tej sesji]**; Spine/DragonBones niepotrzebne (koszt, runtime) **[wniosek]**.
- Plan (jeśli w ogóle): warstwy bok: głowa+szalik, tułów+ramię, udo, łydka+but (x2 nogi), korpus kurtki z shear dolnego rąbka ±1 px. Przy 72 px nogi mają ok. 30 px, więc przeguby kolan są widoczne i kukiełkowe; opłaca się tylko dla przodu/tyłu (bob + przesuw butów) lub jako baza do ręcznego dopracowania.
- Zalety: 0 zł, 0 GPU, pełne sterowanie skryptem, identyczne piksele ubrania. Wady (większe niż przy płaszczu): „kukiełkowość” nóg, dziury po rozcięciu (wnętrze nogawki, tył uda), osobny rig dla każdego widoku.

### 2b. 3D (MPFB) → render → pikselizacja

- Mamy MPFB2 (kod GPL, wyniki CC0 wg ticketu 12) i `tools/blender/postac_chod.py` (chód proceduralny 8 kl.). Pikselizacja Lanczos do 72 px jak dziś.
- Dead Cells: jeden artysta, modele i animacja w 3ds Max (80.lv), render do niskiej rozdzielczości bez wygładzania własnym narzędziem; animacja „na kluczach” jak 2D, międzyklatki dodawane dopiero po przekonującym timingu przy minimum klatek **[wtórne: jikguard/Habr (cytaty Vasseura), 80.lv, forum]**; **nie sprawdzono tekstu oryginalnego (Game Developer 2018)**.
- Po zmianie: kurtka do bioder i spodnie są blisko ciała, więc nie potrzeba proxy płaszcza; wystarczą strefy materiałów/kolorów wierzchołków na siatce MPFB (kurtka ≈ tułów+ręce do bioder, spodnie, buty, szalik) w kolorach z konceptu, render płaski bez światła, Lanczos do 72 px. To tania droga do poprawnego chodu (ruch, kąt, ciągłość), ale styl (rysunkowy kontur, zmarszczki) trzeba przywrócić: albo przepuścić klatki przez Qwen ze sprite'em jako image1 (próba L1), albo przyjąć „płaski” wygląd **[wniosek, do próby]**. Koszt kilka godzin w Blenderze + ocena w Poligonie; MPFB nie ma w instalacji paczki ubrań **[ticket 12]**.

## 3. Pixellab (źródło pierwotne: OpenAPI v2, doc)

| Endpoint | Co robi | Koszt (generacje) | Uwagi |
|---|---|---|---|
| `POST /animate-with-text-v3` | Własna klatka pierwsza + tekst akcji (np. „walk”) + `frame_count` 4-16 parzyste **[OpenAPI, doc]** | Doc narzędzia: **64×64: 1 / 1 / 1; 96×96: 1 / 2 / 3; 128×128: 1 / 2 / 4** (4 / 8 / 16 kl.); UI pokazuje dokładny koszt; „Free for all users, bez subskrypcji” (w narzędziu) **[doc]**. Dla 80×80 8 kl. oczekuję 1-2 **[wniosek]**, w OpenAPI cena nieopisana **[brak]** | Max 256×256, w×h×klatki ≤ 524 288; czas 30-180 s; pierwsza klatka zostaje identyczna. Kierunek nie jest parametrem (dajemy klatkę z żądanym kierunkiem). |
| `POST /animate-pixminimax` (beta) | Jak wyżej, do 40 klatek, krotność 4 | **80×80, 8 kl. = 1 gen.**; 64×64: 4/8/16/40 kl. = 1/1/2/6; kanwa tuż nad 64 lub 128 tańsza niż tuż pod **[OpenAPI]** | Klatka 0 = wejście bez zmian; opis ruchu przez podpisy. Najtańszy wariant. |
| `POST /animate-with-skeleton-v3` | Jedna klatka referencyjna + `first_frame_keypoints` + `keypoints` na każdą klatkę; 18 stawów humanoidalnych, współrzędne 0-1, `depth` opcjonalne; **3-15 klatek**, kanwa do 256×256 **[OpenAPI]** | **3 kl. = 2; 8 kl. = 3; 15 kl. = 4** (cena zależy od klatek, nie od kanwy) **[OpenAPI]**; czas ok. 3-5 min | To jedyny tor sterowany skryptowo: keypoints możemy wyeksportować z Blendera (kości MPFB `openpose`, projekcja do rzutu gry) lub z własnej krzywej chodu. |
| `POST /estimate-skeleton` | Keypoints z obrazu (do 256×256, przezroczyste tło) | **0,1 gen.** **[OpenAPI]** | Potrzebny do `first_frame_keypoints`; z kurtką do bioder nogi są widoczne, więc estymacja powinna być wiarygodna (do sprawdzenia w P0) **[wniosek]**. |
| `POST /animate-character` | Dla postaci utworzonej w Pixellab (`character_id`); tryb `template`: **1 gen./kierunek** (kl. 4-6, ai_freedom 0-1000); v3 (tekst, 4-16 kl.); pixminimax; pro 10-25 **[OpenAPI]** | j.w. | Dotyczy postaci z Pixellab, nie naszego sprite'a; ticket 12 przyjął, że sprite robimy lokalnie, więc omijamy. |
| `POST /interpolation-v2` | Klatki pośrednie między dwoma kluczami (14 pośrednich dla ≤64 px) | 10 gen. do 128 px **[OpenAPI]** | Za drogie jak na wartość. |

- W starym narzędziu skeleton (nie v3) „trzeba mieć co najmniej Tier 1”, kanwy 16/32/64/128/256 **[doc]**; v3 przyjmuje dowolne wymiary do 256 **[OpenAPI]**.
- Ile kierunków: v3 animuje jedną klatkę (jeden kierunek) na wywołanie; dla bok + przód + tył to 3 wywołania (lustro darmowe) **[wniosek]**. Orientacyjny koszt kompletu 8 kl. × 3 widoki: pixminimax ≈ 3 gen., text-v3 ≈ 3-6, skeleton-v3 = 9.
- Pula triala: według ticketu 12 zużyte 31/40, czyli zostało 9; stan zweryfikować `GET /v2/balance` przed próbami **[log]**.
- Czy trzyma nasz styl: **[brak]** pierwotnego źródła; doc mówi tylko „ustaw postać jako referencję, żeby model zachował wygląd” (skeleton) i „pierwsza klatka identyczna” (text-v3) **[doc]**. Nasz sprite jest malarski, miękki, zbliżony do Pixellab „image-to-pixelart faithful”, ale to nie jego styl domowy **[wniosek]**; w ticketach 12 Pixellab (bitforge) już raz zmienił styl na „anime”. Stąd próba P1 ocenia przede wszystkim styl.
- Licencja/UE: zasady dla Pixellab (prawa do wyników u użytkownika, zakaz trenowania na wynikach, ujawnienie AI na Steam) w `docs/research/61-narzedzia-limity-koszty.md` i ticket 02; nie powtarzam. Animacja v3 jest w grupie tych samych warunków **[wniosek, sprawdzić regulamin]**.

## 4. Kurtka do bioder (wcześniej: długi płaszcz): co robi animacja

Źródła pierwotne tutaj praktycznie nie istnieją; poniżej reguły z kanonu animacji i własnych obserwacji, **[wniosek]**.

- Z kurtką widać całe nogi: krok jest czytelny wprost jako rozkrok, zgięcie kolana i unoszenie stopy; dolny rąbek kurtki (pas) wymaga co najwyżej ±1 px przesunięcia w przeciwfazie do ruchu bioder.
- Krok normalny dla człowieka 1,8 m przy skali 40 px/m (rozstaw stóp ok. 10-14 px w 72 px), bob głowy ±1 px dwa razy na cykl, ramiona w przeciwfazie do nóg, tułów lekko się obraca; standardowy chód, bez skracania **[wniosek]**.
- Z przodu i z tyłu różnice to bob, przesuw butów w pionie (skrót perspektywiczny przy kamerze 0,60), lekkie przechylenie ramion; 6 klatek + lustro zwykle wystarcza **[wniosek]**.
- Nieudana pierwsza próba (`postac_chod_060/arkusz.png`) miała płaszcz zasłaniający nogi i nogi z manekina niezgodne z konceptem; dla kurtki ta przyczyna znika, więc metoda Qwen+poza zasługuje na ponowną, tanią próbę (L1 niżej), choć ciągłość klatek zostaje problemem.
- Dead Cells (z wtórnych cytatów): minimalna liczba klatek, kluczowe pozy najpierw, międzyklatki na końcu; to ta sama kolejność co dla cut-outu **[wtórne]**.

## 5. Porównanie dróg

| Droga | Jakość (oczek.) | Spójność | Czas / pieniądze | Skrypt | Licencja |
|---|---|---|---|---|---|
| Qwen per klatka + poza | niska-średnia, **lepsza niż przy płaszczu** (nogi widoczne) | zła (niezależne klatki) | 2,5-3 min/kl., 0 zł | tak | Apache 2.0 |
| Wan 2.2 5B I2V | niska dla 72 px | średnia (dryf) | 2-4 min/klip, 0 zł, plus pobrania | częściowo | Apache 2.0 |
| LoRA arkusz (siatka) | niepewna | średnia | min. minut, 0 zł, plus pobrania | tak | niesprawdzona |
| Cut-out w Godocie | niska-średnia (kukiełka przy widocznych nogach) | idealna | kilka h pracy, 0 zł | tak (pełne) | nasze + Godot MIT |
| 3D MPFB + kolorowe strefy (kurtka/spodnie/buty) | średnia (styl płaski; Qwen może go przywrócić) | wysoka | kilka h, 0 zł | tak | MPFB CC0 wyniki |
| Pixellab text/pixminimax | do zbadania | do zbadania | 1-2 gen./kierunek | API | warunki Pixellab |
| Pixellab skeleton-v3 | do zbadania, wyższa kontrola | do zbadania | 3 gen./8 kl./kierunek | API + keypoints | j.w. |

## 6. Rekomendacja i tanie próby

Zasada z pamięci: **przed każdą generacją zewnętrzną pokazać wejście, powód i koszt i dostać zgodę**; poniższe próby P1-P3 to propozycja do zatwierdzenia, nie wykonane.

### Droga 1 (do próby): Pixellab na naszym sprite'cie, jeden kierunek (bok)

Wejście: nowy sprite 72 px w kurtce, bok (jeszcze do zrobienia z `proby/koncept9/edit_kurtka_s9000.png`) na przezroczystym 80×80 (lub 96×96); `unzoom` niepotrzebny (natywna siatka).

| # | Próba | Koszt | Co sprawdzić |
|---|---|---|---|
| P0 | `GET /v2/balance`, `estimate-skeleton` na boku | 0 + 0,1 | rzeczywiste saldo; czy keypointy nóg i kolan są poprawne (z kurtką powinny; poprawić w JSON) |
| P1 | `animate-pixminimax`, 80×80, 8 kl., akcja: „walking forward, natural stride, arms swinging” | 1 | czy styl/paleta/twarz trzymają; widoczny krok; klatka 0 = wejście; pętla (kl. 7 → 0) |
| P2 | `animate-with-text-v3`, ten sam wsad, 8 kl. | 1-2 (UI pokaże) | jakość względem P1 (v3 to „standard”, pixminimax beta) |
| P3 | `animate-with-skeleton-v3`, 8 kl., keypoints z MPFB (`openpose`, projekcja w rzut gry) | 3 | czy poza wykonuje zadany krok; styl; dłonie i buty |
| **Razem** | | **5-6 z 9** | |

Kryteria oceny (na żywo w Poligonie, 8 kl./s, nie po zrzutach): (a) krok czytelny z 3 m (stopy wyraźnie przesuwają się, kolana się zginają), (b) kurtka i twarz bez dryfu między klatkami, (c) paleta nie zmieniła się względem sprite'a (histogramy), (d) pętla bez skoku, (e) piksele na siatce (brak półpikseli). Jeśli P1-P2 psują styl, P3 pomijamy i bierzemy tylko ruch jako referencję do ręcznego dopracowania. Wymagania `tier` dla skeleton-v3: w OpenAPI nie znalazłem (stare narzędzie skeleton: Tier 1) **[brak]**.

### Droga 2 (w tle, 0 zł): chód MPFB z kolorowymi strefami wprost do 72 px (+ opcjonalnie Qwen)

| # | Krok | Czas | Co sprawdzić |
|---|---|---|---|
| M1 | Dodać strefy kolorów do siatki MPFB (kurtka/spodnie/buty/szalik/skóra) w `postac_mpfb.py`, render płaski bez światła, bok, 8 klatek z `postac_chod.py` | 2-3 h | czy sylwetka kurtki/nóg czytelna po Lanczos do 72 px; kąt 0,60 poprawny |
| M2 | Lanczos 72 px + `alpha_cut.gd`, ocena w Poligonie; porównać proporcje z nowym sprite'em | 0,5 h | ciągłość i rytm kroku (referencja ruchu za 0 zł) |
| L1 | Opcjonalnie: Qwen-Edit ze sprite'em jako image1 i klatką M1 jako image2 (kolorowa poza zamiast manekina bez ubrania), 1-2 klatki | ok. 3 min/kl. | czy poza nóg tym razem się przenosi i czy styl wraca; ciągłość (stały seed) |
| M3 | Przód i tył: bob + przesuw butów (cut-out wystarczy) lub ten sam render MPFB | 1 h | wiarygodność z kamery 0,60 |

Dopasowanie do stylu: render 3D daje poprawny ruch i kąt, ale nie styl; jeśli L1 nie zadziała, ruch z M2 służy jako wzorzec do ręcznego dopracowania lub jako `keypoints` do skeleton-v3 (P3).

### Co zostawić na potem

- Wan 2.2 5B I2V: dopiero jeśli Pixellab zawiedzie i render MPFB nie przejdzie oceny; widoczne nogi pomagają, ale kamera i dryf zostają; pobranie GGUF + WanVideoWrapper + VHS ≈ kilkanaście GB, test 1 klipu ≈ 4 min, kryteria: nieruchoma kamera, pętla, styl po downsamplu.
- Qwen + szkielet OpenPose zamiast manekina: wariant L1 powyżej; z kolorowym renderem MPFB wystarczą istniejące narzędzia, z DWPose potrzebny `comfyui_controlnet_aux` (instalacja). Poprawia przeniesienie nóg, nie ciągłość klatek.
- LoRA arkuszy: sprawdzić licencję (HF) przed pobraniem.
- Proxy płaszcza / symulacja ubrania: tylko gdyby wrócił długi płaszcz lub były warianty stroju.

## 7. Luki

- **[brak]** Cennik `animate-with-text-v3` dla 80×80 w OpenAPI; użyć UI/`/v2/balance`.
- **[brak]** Przykłady wyników Pixellab dla naszego sprite'a (nowego, w kurtce); wszystko ocenimy sami w P1-P3.
- **[brak]** Weryfikacja oryginalnego artykułu Dead Cells (Game Developer) i licencji LTX-Video; licencja LoRA arkuszy.
- Godot Skeleton2D opisano z pamięci, nie ze źródła w tej sesji.

## Weryfikacja 2026-11-08 (kurtka)

Zmiana założeń: człowiek zrezygnował z długiego płaszcza; koncept `proby/koncept9/edit_kurtka_s9000.png` pokazuje krótką kurtkę do bioder, szare spodnie i brązowe buty, nogi w pełni widoczne. Styl konceptu jest bardziej rysunkowy (gruby czarny kontur) niż wcześniejszy malarski.

**Co się zmieniło w wnioskach**
- Cut-out w Godocie: z drogi gwarantowanej zdegradowany do awaryjnej (nogi widoczne w całości, wychodzi kukiełka); sens zostaje dla przodu i tyłu (bob + stopy).
- 3D MPFB: awansowało; kurtka i spodnie są blisko ciała, więc zamiast proxy płaszcza wystarczą kolorowe strefy materiału; dostajemy poprawny ruch i kąt, styl do odzyskania (Qwen lub ręcznie).
- Qwen+poza/OpenPose: przyczyna porażki „nogi pod płaszczem” znika; sensowna tania próba L1, ale ciągłość klatek nadal nierozwiązana.
- Pixellab skeleton-v3: `estimate-skeleton` powinien teraz estymować nogi poprawnie; próby P0-P3 bez zmian, ale wejściem ma być nowy sprite w kurtce (jeszcze nie ma).
- Wan, LoRA arkuszy: widoczne nogi pomagają nieznacznie; zostają „na potem” z tych samych powodów (kamera, dryf, 72 px, brak weryfikacji licencji).
- Reguły animacji (§4) przepisane: zwykły chód 10-14 px rozstawu zamiast skróconego kroku i ruchu poły.

**Sprawdzone ponownie w źródłach pierwotnych (2026-11-08)**
- OpenAPI `animate-pixminimax` (beta): max 256×256, klatki krotność 4 w zakresie 4-40 przy każdym rozmiarze do 256; „priced by generation time, 6 generations for the longest clip”; przykład 64×64: 1/1/2/6 gen. dla 4/8/16/40 kl.; kanwa tuż nad 64 lub 128 tańsza niż tuż pod. **Potwierdzone.** Wartość „80×80, 8 kl. = 1 gen.” pochodzi z pierwszego odczytu i nie została ponownie zacytowana; **potwierdzić w UI przed próbą**.
- OpenAPI `animate-with-text-v3`: max 256×256, w×h×klatki ≤ 524 288, 4/8/16 jako wskazówka, czas 30-180 s; **tekstu kosztu w OpenAPI nie ma**. Tabela kosztów (64: 1/1/1; 96: 1/2/3; 128: 1/2/4) pochodzi z dokumentacji narzędzia (`/docs/tools/animate-with-text-new`), nie z OpenAPI; dla 80×80 tylko szacunek.
- OpenAPI `animate-with-skeleton-v3` (beta): 3-15 klatek, kanwa do 256×256; koszt zależy od liczby klatek, nie od kanwy: 3 kl. = 2, 8 = 3, 15 = 4 gen. **Potwierdzone.** Wymagań tier w widocznym tekście brak.
- OpenAPI `estimate-skeleton`: 0,1 gen./wywołanie, do 256×256, całkiem przezroczysty obraz odrzucany (422) przed obciążeniem. **Potwierdzone.**
- Wan 2.2 TI2V-5B (karta HF): Apache 2.0, autorzy nie rościmy praw do wygenerowanych treści; VRAM: „at least 24GB VRAM (e.g, RTX 4090)” dla domyślnego polecenia, 5 s 720P w <9 min na „single consumer-grade GPU”. **Potwierdzone; „mieści się w 8 GB” NIE pochodzi z karty, tylko ze źródeł wtórnych (docs ComfyUI, blogi), niezweryfikowane na naszej karcie.**
- Qwen-Image-Edit-2511 (karta HF): licencja Apache 2.0; **brak jakiejkolwiek wzmianki o pose/ControlNet/szkielecie/OpenPose** (jest tylko „Improved Multi-Person Consistency”). Pose przez drugi obraz lub zewnętrzny ControlNet Union (dla Qwen-Image) pozostaje wnioskiem ze źródeł wtórnych.
- **Niepotwierdzone:** czy Pixellab v3 trzyma nasz styl (brak źródła); licencja LTX-Video i LoRA arkuszy; Godot Skeleton2D (z pamięci); czasy Wan na 8 GB (wtórne); artykuł Dead Cells (tylko wtórne).

## Źródła

- Pixellab: `https://api.pixellab.ai/v2/openapi.json` (animate-with-skeleton-v3, animate-with-text-v3, animate-pixminimax, estimate-skeleton, animate-character, interpolation-v2), `https://api.pixellab.ai/v2/llms.txt`, `https://www.pixellab.ai/docs/tools/animate-with-text-new`, `/docs/tools/animate-with-skeleton`.
- Karty modeli: `https://huggingface.co/Wan-AI/Wan2.2-TI2V-5B`, `/Wan-AI/Wan2.1-VACE-1.3B`, `/Qwen/Qwen-Image-Edit-2511`, `/InstantX/Qwen-Image-ControlNet-Union`, `/Lightricks/LTX-Video`.
- ComfyUI: `https://docs.comfy.org/tutorials/video/wan/wan2_2`, `https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511`, `https://blog.comfy.org/p/comfyui-wan22-fun-inp-support`.
- Wtórne: `https://lilting.ch/en/articles/wan22-comfyui-rtx4060-i2v`, `https://tantk.github.io/spriteforge-pipeline`, `https://huggingface.co/svntax-dev/pixel_spritesheet_4walk_small_lora_v1`, `https://www.jikguard.com/news/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-dead-cells`, `https://80.lv/articles/interview-with-the-developers-of-dead-cells`.
- Lokalnie: `docs/research/70-wejscie-pixellab.md`, `docs/wayfinder/tickets/12-przepis-postaci.md`, `02-narzedzia-limity-koszty.md`, `style-lab/proby/postac_kat5/arkusz.png`, `style-lab/proby/postac_chod_060/arkusz.png`, `style-lab/tools/blender/postac_chod.py`, lista modeli `ComfyUI-Shared/models`.
