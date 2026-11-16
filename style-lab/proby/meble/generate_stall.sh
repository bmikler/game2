#!/bin/bash
# Engine ticket 10: the street stall in Qwen (locally, 0 zł), the same path as the furniture of ticket 02.
# Run from style-lab/.
. proby/meble/prompt.sh
STYLE=proby/bibliotekarka/qwen/przod_a15_s9000.png
gen() { # furniture version seed0 seeds "furniture" "details"
  node tools/postac/qwen_kat.mjs shots/prowadnice_v2/$1/prowadnica_szary.png proby/meble/$1/qwen/$2 "$(prompt_mebla "$5" "$6")" \
    --angles 0 --pose $STYLE --seed0 $3 --seeds $4
}
mkdir -p proby/meble/stall/qwen
gen stall a 9100 3 "an old wooden market stall table with thin straight legs" \
  "a faded red and white striped cotton cloth laid on the top and hanging down over the front edge, wooden crates of red apples, jars of honey and a small brass scale standing on the top"
gen stall b 9100 3 "a weathered market table painted muted grey-blue with thin straight legs" \
  "a coarse linen cloth hanging down over the front edge, wicker baskets of potatoes and onions, a tin bucket of flowers and a small chalk price board standing on the top"
