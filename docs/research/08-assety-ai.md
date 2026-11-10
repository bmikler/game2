> Kopia z game1 (`repo/game1/docs/research/08-assety-ai.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Generowanie assetów pixel art i audio przez AI

Ticket: `docs/wayfinder/tickets/08-assety-ai.md`. Zakres: narzędzia, workflowy, ograniczenia, koszt. Bez prawa (osobny ticket). Data researchu: 2026-10-27.

**Zastrzeżenie o jakości źródeł:** strony producentów (Pixellab, Retro Diffusion, Scenario, Suno, ElevenLabs, Stability) opisują możliwości marketingowo. Nie znalazłem w tym podejściu devlogów z pełnym, mierzalnym workflowem dla gry o skali „Drugiej”, więc oceny spójności stylu niżej to wnioski z opisu funkcji, nie z zweryfikowanych case studies. Ceny Pixellab i Retro Diffusion (strona www) nie były dostępne w pobranej treści: do sprawdzenia ręcznie.

## 1. Pixel art: narzędzia

### Pixellab (pixellab.ai)
- Funkcje wg strony: animacje (jednoklik, szkieletowe, z promptu), obroty postaci i obiektów 4/8 kierunków (także izometria), generowanie spójne stylistycznie, inpainting „widzący” oryginał, sceny, tekstury, tilesety, mapy top-down i side-scroll, elementy UI. Dostęp: web, API, serwer MCP, workflow z Aseprite. Modele działają w chmurze, nie trzeba GPU. [pixellab.ai](https://www.pixellab.ai/)
- FAQ: subskrypcja miesięczna, użycie komercyjne dozwolone (zakaz trenowania nowych modeli na wynikach), nie trenują na danych użytkownika, użycie assetów AI na Steam wskazane jako dozwolone (to deklaracja producenta, nie Valve). [FAQ](https://www.pixellab.ai/docs/faq)
- Cena, limity płótna i klatek: nie ustalone (strona planów nie wczytała się). Jest darmowy trial bez karty.
- Ważne dla projektu: **rotacje 4/8 kierunków i animacje szkieletowe** to dokładnie to, czego potrzebuje widok 2D z postaciami. Integracja MCP pasuje do pracy z Claude, ale to dopiero do przetestowania.

### Retro Diffusion (Astropulse)
- Dwie różne rzeczy, nie mylić: (a) strona retrodiffusion.ai z większymi modelami (animacje, tilesety, w kredytach), (b) rozszerzenie do Aseprite uruchamiane lokalnie, kupowane jednorazowo.
- Rozszerzenie v15: generowanie w Aseprite, neural pixelate/resize/detail, palettize, tiling, mapy tekstur, usuwanie tła, filtr PixFix. Pełna wersja 65 USD, Lite 20 USD, bez subskrypcji. Model trenowany na licencjonowanych assetach artystów z ich zgodą. **Brak animacji/sprite sheetów w rozszerzeniu** (tylko na stronie, za kredyty). Wyniki lokalne nie dorównują stronie. Wymaga GPU (64x64 ok. 2 s na RTX 3090, nawet ok. 10 min na niektórych CPU), AMD na Windows bez wsparcia, Mac 8 GB poniżej minimum. Deweloper pisze, że rozszerzenie jest wygaszane na rzecz natywnego edytora. [itch.io](https://astropulse.itch.io/retrodiffusion)
- Pixeldetector (Astropulse): skrypt Python do przywracania/zmniejszania pixel artu po skalowaniu lub kompresji; przydatny do sprzątania wyników, jeśli generator zwraca „rozmyty” pixel art. [GitHub](https://github.com/Astropulse/pixeldetector)

### Scenario (scenario.com): własne LoRA/modele stylu
- Trening własnego modelu: od planu Pro (45 USD/mies., 5000 kredytów); 10-30 obrazów na styl, 5-15 na postać/obiekt. Starter 15 USD/mies. (1500 kredytów, bez treningu). Plany płatne mają licencję komercyjną; darmowy tier tylko do użytku osobistego i oceny. Prywatność domyślnie. [pricing](https://www.scenario.com/pricing)
- To jedyna z zbadanych dróg do „stylu własnego” przez LoRA bez stawiania infrastruktury. Wymaga najpierw zestawu 10-30 obrazów w docelowym stylu (np. ręcznie zrobionych lub wybranych), więc nie zastępuje decyzji o stylu.
- Brak potwierdzonych w źródle funkcji pixel-art-specyficznych (animacje, tilesety); trzeba sprawdzić na próbce.

### Normal mapy: Laigter (nie-AI, ale kluczowe)
- Darmowy, open source (GPL3), generuje mapy normalne, specular, parallax, occlusion z samego sprite'a; podgląd oświetlenia na żywo, obsługa wsadowa z linii poleceń (`-d`, `-n`, `-r` dla presetów), opcja trybu pixel art. Deweloper w trybie głównie utrzymaniowym. [dokumentacja](https://laigter.readthedocs.io/en/latest/Introduction/intro.html), [itch.io](https://azagaya.itch.io/laigter), [repo](https://github.com/azagaya/laigter)
- Wniosek: normal mapy najrozsądniej generować algorytmicznie z gotowych sprite'ów (Laigter), a nie przez AI. Dla „Replaced/Octopath”-owego światła jakość trzeba zweryfikować w prototypie oświetlenia (osobny ticket). Nie znalazłem w źródłach pierwotnych narzędzia AI, które wiarygodnie generuje normal mapy dla pixel artu.

## 2. Wzorce workflowu (wniosek z opisów narzędzi)
1. Styl ustala człowiek (referencje/ręczne wzorce), następnie generacja w narzędziu spójnym stylistycznie (Pixellab) lub model/LoRA (Scenario).
2. Generacja nigdy nie jest końcowa: ręczna poprawka w Aseprite (PixFix/inpainting nie zastępują „ręki”, sam autor Retro Diffusion to mówi).
3. Normal mapy z gotowych sprite'ów (Laigter), jako krok automatyczny po finalizacji.
4. Ograniczenia: rozmiary płótna ograniczone (nieznane liczbowo), spójność postaci między animacjami i kątami wymaga testu, tła o dużej rozdzielczości i portrety to słabszy obszar niż małe sprite'y (hipoteza, do sprawdzenia na trialu).

## 3. Muzyka ambient i SFX

| Narzędzie | Koszt | Uwagi |
|---|---|---|
| Suno | Free 0 (bez praw komercyjnych, bez pobrań); Pro 8 USD/mies. (2500 kredytów, 20 pobrań/mies., prawa komercyjne); Premier 24 USD/mies. [suno.com](https://suno.com/pricing) | Limity pobrań; wg Stability od 3.09.2026 limity obejmują całą bibliotekę (źródło konkurenta). Brak self-hostingu. |
| ElevenLabs (Music + SFX) | SFX ok. 200 kredytów/generację, muzyka ok. 900 kredytów/min; plany od Starter 1 USD (30k kredytów), Creator 11 USD (121k); licencja komercyjna od Starter [elevenlabs.io](https://elevenlabs.io/pricing) | Wspólna pula kredytów. Wg dokumentacji API prawa do dużych gier mogą wymagać Enterprise (do weryfikacji; to cytat z porównania Stability, nie z ElevenLabs). |
| Stable Audio 3.0 | Aplikacja od 12 USD/mies.; otwarte wagi (Small, Small SFX, Medium) na Hugging Face; Community License bezpłatna poniżej 1 mln USD przychodu; do 6:20 min; bez wokali [Stability](https://stability.ai/explainers/stable-audio-vs-competitors-licensing-export-rights-and-self-hosting-compared), [licencja](https://stability.ai/license) | Jedyne z rozważanych z lokalnym uruchomieniem i brakiem limitu pobrań; źródło jest stroną producenta. Model „Small SFX” sensowny do dźwięków otoczenia. |
| Udio | Pobrania wyłączone od 10.2025 (wg Stability) | Odpada do eksportu do gry. |

Wniosek: ambient (instrumentalny) jest tu realistycznym zastosowaniem AI; muzyka dynamiczna (warstwy/stemy pod porę dnia, koszmar, odwracany dźwięk) wymaga osobnego przetwarzania w silniku audio, nie w generatorze. Stemy: Suno Pro daje 2 typy rozdziału. Koncert w barze: wymaga wokali/utworu o kontrolowanym charakterze; Stable Audio ich nie generuje.

## 4. Koszty (rząd wielkości, hobby)
- Pixel art: Pixellab (subskrypcja, kwota do ustalenia, trial) lub Retro Diffusion Lite/Full 20-65 USD jednorazowo (bez animacji) lub Scenario 45 USD/mies. (LoRA). Realnie wystarcza jeden miesiąc subskrypcji w intensywnej fazie produkcji assetów.
- Audio: 8-12 USD/mies. przez 1-2 miesiące lub 0 USD przy lokalnym Stable Audio (wymaga GPU).
- Laigter, Aseprite (ok. 20 USD jednorazowo wg strony Retro Diffusion) i narzędzia sprzątające: bez lub niskie koszty.

## 5. Luki i do zweryfikowania
- Cennik Pixellab, limity płótna i klatek, jakość spójności na realnej próbce (trial bez karty).
- Czy Scenario daje użyteczny pixel art po treningu na 10-30 obrazach.
- Warunki licencyjne konkretnych narzędzi i polityka Steam wobec AI: osobny ticket prawny.

## Rekomendacja
(Decyzja należy do późniejszego ticketu z człowiekiem.) Trade-offy:
- **Pixellab** jest najbliżej potrzeb (rotacje, animacje szkieletowe, tilesety, MCP), kosztem subskrypcji i zależności od chmury. Najtańszy test: darmowy trial na jednej postaci (Badacz) z 4 kierunkami i animacją chodu.
- **Retro Diffusion lokalnie** to tani zakup jednorazowy i dobre do tilesetów/sprzątania, ale bez animacji i z wymaganiem GPU.
- **Scenario/LoRA** ma sens dopiero gdy istnieje własny zestaw wzorców stylu; inaczej nie ma na czym trenować.
- **Normal mapy:** Laigter z gotowych sprite'ów, ocena w prototypie oświetlenia.
- **Audio:** Stable Audio lokalnie (ambient/SFX, brak limitów) lub Suno Pro na 1-2 miesiące (utwory z wokalem, np. koncert). Wszystko pod warunkiem ręcznej selekcji i obróbki; opcja „AI + ręczna poprawka” jest realna, „czysty AI bez poprawek” nie.
- Alternatywa warta uwzględnienia w decyzji: assety ręczne lub z gotowych paczek tam, gdzie AI nie daje spójności (portrety, tła).
