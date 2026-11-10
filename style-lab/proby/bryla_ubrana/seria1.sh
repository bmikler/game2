cd /c/Users/bartl/Desktop/game2/style-lab
R=proby/bryla_ubrana/render/ubrana_przod.png
C=proby/koncept9/edit_kurtka_s9000.png
G=proby/bryla_ubrana/gen
P1="Redraw the man from image 1 (same face, grey-flecked short beard, short dark hair grey at the temples, navy wool jacket, grey knit sweater, brick-red scarf, charcoal trousers, brown leather boots, same hand-painted graphic novel illustration style) exactly in the pose, body proportions, camera angle and framing of image 2. Keep the silhouette, limb positions and camera of image 2 precisely. Plain light grey background."
P2="Repaint this simple 3D clay mannequin as a hand-painted graphic novel illustration of a 50 year old man: dark navy wool jacket half-zipped open over a light grey knit sweater, brick-red scarf, charcoal trousers, brown leather boots, short dark hair grey at the temples, grey-flecked short beard, serious face. Keep the exact pose, camera angle, proportions and silhouette. Plain light grey background, no shadow."
node tools/postac/ubrana_gen.mjs qwen2 $R $G/q2_d100 --concept $C --denoise 1.0 --prompt "$P1"
node tools/postac/ubrana_gen.mjs qwen2 $R $G/q2_d075 --concept $C --denoise 0.75 --prompt "$P1"
node tools/postac/ubrana_gen.mjs qwen1 $R $G/q1_d060 --denoise 0.6 --prompt "$P2"
node tools/postac/ubrana_gen.mjs flux $R $G/fx_d060 --denoise 0.6 --prompt "$P2"
node tools/postac/ubrana_gen.mjs flux $R $G/fx_d045 --denoise 0.45 --prompt "$P2"
