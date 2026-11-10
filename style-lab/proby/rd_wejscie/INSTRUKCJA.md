# Retro Diffusion (web, darmowe jednostki): ta sama postać co w Pixellab

Cel: sprawdzić, czy RD wygeneruje tę postać w tym stylu (jeden kąt, z przodu, ok. 3/4 z góry jak „high top-down”).

Pliki:
- `koncept_przod_512.png`: przód z arkusza, przezroczyste tło (wejście / referencja).
- `styl_80.png`: ten sam przód zmniejszony do 80×80 (jeśli RD chce referencji w skali piksela).
- `koncept_przod_pelny.png`: oryginalny przód 768×1024 (koncept przod-8302).
- `arkusz_pelny.png`: arkusz obrotu tej postaci (arkusz-8201; gdyby RD przyjmował arkusz jako referencję).

Prompt (EN):
experienced plain-clothes police detective about fifty, well-groomed, dignified, realistic proportions 7 heads tall, lean fit build, dark navy wool winter coat to the knees, muted brick red scarf, light grey knit sweater, charcoal grey trousers, brown leather winter boots, short neatly cut dark hair with grey at the temples, neatly trimmed grey-flecked short beard, standing still, arms at his sides, facing the viewer, seen from a 3/4 top-down game camera, muted cold palette, nordic noir

Ustawienia (do wyboru w web, zapisz które użyłeś):
1. Model z referencją obrazu / img2img (np. RD Plus lub RD Pro z „reference image” albo „input image”), wejście `koncept_przod_512.png`, rozmiar ok. 80×80 (albo najbliższy dostępny, np. 96 lub 128), przezroczyste tło jeśli jest opcja.
2. Jeśli jest styl „character / game asset / top-down”, wybierz go zamiast ogólnego.
3. Po jednej generacji na wariant; zapisz wynik do `../postac_rd/` jako `rd_<model>_<ustawienie>.png` i dopisz koszt (jednostki) w nazwie lub w notatce.
