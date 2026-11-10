class_name Lit
extends RefCounted
## The one material shared by every lit sprite (floors, walls, props, actors), see lit.gdshader.

const AMBIENT_HEIGHT: float = 10000.0 ## A light this high is a room's ambient: no N·L (see the shader).
const SHADER: Shader = preload("res://world/lighting/lit.gdshader")

static var _material: ShaderMaterial


static func material() -> ShaderMaterial:
	if _material == null:
		_material = ShaderMaterial.new()
		_material.shader = SHADER
	return _material
