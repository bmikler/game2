#!/bin/bash
# PROTOTYP (ticket silnika 02): generacje mebli w Qwen (lokalnie, 0 zł). Uruchamiać z style-lab/.
. proby/meble/prompt.sh
STYL=proby/bibliotekarka/qwen/przod_a15_s9000.png
gen() { # mebel wersja seed0 seeds "mebel" "szczegóły"
  node tools/postac/qwen_kat.mjs shots/prowadnice_v2/$1/prowadnica_szary.png proby/meble/$1/qwen/$2 "$(prompt_mebla "$5" "$6")" \
    --angles 0 --pose $STYL --seed0 $3 --seeds $4
}
gen lada a 9100 2 "an old shop counter made of dark stained wood with two panelled doors and a thick wooden top" \
  "an old brass cash register and a stack of papers on the top"
gen lada b 9100 2 "an old shop counter painted muted dark green with a worn light oak top and two panelled doors" \
  "a glass jar of sweets and a thick ledger book on the top"
gen stol a 9100 2 "an old wooden kitchen table with four straight legs" \
  "an embroidered white linen tablecloth hanging down over the front edge, a teapot and two cups on it"
gen stol b 9100 2 "an old dark walnut table with four straight legs" \
  "a lace table runner, a brass candle holder and a folded newspaper on it"
gen fotel a 9100 2 "an old armchair upholstered in worn bottle-green velvet with short dark wooden legs" \
  "a knitted cream wool throw draped over one armrest and a small patterned cushion"
gen fotel b 9100 2 "an old armchair upholstered in worn brown leather with short dark wooden legs" \
  "a red checked wool blanket with fringes folded over the backrest and a book on the seat"
