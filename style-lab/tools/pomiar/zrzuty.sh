#!/bin/sh
# Ticket 14: zrzuty wsadowe do katalogu: zrzuty.sh <katalog_wyjscia> <prefiks> <argumenty Godota po -->
# Kopiuje nowe pliki (png, bufor) z shots/ jako <prefiks>_<HHMM>.<ext>; przywraca project.godot.
cd "$(dirname "$0")/../.." || exit 1
G=/c/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64.exe
OUT="$1"; PREFIX="$2"; shift 2
mkdir -p "$OUT"
STAMP=$(mktemp); sleep 1
timeout 600 "$G" --path . -- "$@" 2>&1 | grep -E "SCRIPT ERROR|Parse Error|ERROR: .*shader|error\(|BENCH|POMIAR" | grep -v custom_samplers | head -20
git checkout -q project.godot 2>/dev/null
find shots -maxdepth 1 -newer "$STAMP" -type f | while IFS= read -r f; do
  hhmm=$(echo "$f" | sed -E 's/.*__([0-9]{4})\.(png|bufor)$/\1/'); ext="${f##*.}"
  mv "$f" "$OUT/${PREFIX}_${hhmm}.${ext}"
done
rm -f "$STAMP"
ls "$OUT" | grep "^${PREFIX}_"
