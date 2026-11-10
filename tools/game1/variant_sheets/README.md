# Arkusze wariantów i panel strojenia

Narzędzia do decyzji o wyglądzie (ticket 27). Sterują sceną `Main` z zewnątrz, tak jak `tools/reference_shots/capture_game.gd`, bo gra nie ma flag wariantów (§14). Otwierają okno, bo renderowanie wymaga GPU.

## Panel strojenia na żywo

`run_tuning.bat` uruchamia grę z panelem suwaków na dole ekranu: godzina (zegar domyślnie zatrzymany), lampka i monitor w gabinecie, jasność ekranu, okna nocą (widok, poświata, jej barwa, maksymalna jasność widoku), cienie przy ścianach; przełącznik śniegu. Badaczem chodzi się normalnie. Zmiany nie trafiają do zasobów. „Zapisz wartości” wypisuje je do konsoli i dopisuje do `user://tuning_values.txt` (`%APPDATA%\Godot\app_userdata\Dzien na posterunku\`).

## Arkusz wariantów

Warianty i godziny są w `SHEETS` w `capture_variants.gd`. Każdy wariant to lista poprawek na świeżym `Main`.

```powershell
.\tools\godot\Godot_v4.7.2-stable_win64_console.exe --path game `
  --script "$PWD\tools\variant_sheets\capture_variants.gd" `
  -- --sheet=office "--out=<katalog>" [--variants=a,b]
node tools\variant_sheets\compose.mjs --in=<katalog> --out=<plik.png> --rows=a,b --hours=0815,1200 `
  [--rect=x,y,w,h] [--scale=2] [--reference=art\reference\prototype]
```

Wiersz `referencja` bierze klatki z `--reference`. Poprawka `windows` zmienia wspólny profil okien w pamięci, więc taki wariant trzeba uruchamiać osobno (`--variants=`).
