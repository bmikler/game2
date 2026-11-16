class_name AssetLook
extends Resource
## One look of an asset a Poligon compares in F1 (a ticket's switch): its sprite and normal map.

## The name in F1 and in shots.
@export var look_name: String = ""
@export var sprite: Texture2D
## Optional, as in the asset contract.
@export var normal_map: Texture2D
