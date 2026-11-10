class_name Lit
extends RefCounted
## The one material shared by every lit sprite (floors, walls, props), see lit.gdshader, and its twin
## for actors (style-lab, ticket 31: the light maps light them from their own strip).

const AMBIENT_HEIGHT: float = 10000.0 ## A light this high is a room's ambient: no N·L (see the shader).
const SHADER: Shader = preload("res://lighting/lit.gdshader")

static var _material: ShaderMaterial
static var _actor_material: ShaderMaterial


static func material() -> ShaderMaterial:
	if _material == null:
		_material = ShaderMaterial.new()
		_material.shader = SHADER
	return _material


static func actor_material() -> ShaderMaterial:
	if _actor_material == null:
		_actor_material = ShaderMaterial.new()
		_actor_material.shader = SHADER
		_actor_material.set_shader_parameter(&"is_actor", true)
	return _actor_material


## Both materials.
static func set_all(param: StringName, value: Variant) -> void:
	material().set_shader_parameter(param, value)
	actor_material().set_shader_parameter(param, value)
