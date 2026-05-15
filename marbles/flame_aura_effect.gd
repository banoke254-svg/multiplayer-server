@tool
extends Node3D

@export var texture_path: String = "res://marbles/blue_fire_aura.png"
@export var tint: Color = Color(0.92, 1.0, 1.0, 0.88)
@export var outer_tint: Color = Color(0.42, 0.9, 1.0, 0.58)
@export var core_size: Vector2 = Vector2(0.88, 0.88)
@export var outer_size: Vector2 = Vector2(1.08, 1.08)
@export var pulse_speed: float = 2.4
@export var pulse_amount: float = 0.08

var _core: MeshInstance3D = null
var _outer: MeshInstance3D = null
var _time: float = 0.0


func _ready() -> void:
	_build_if_needed()
	set_process(true)


func _process(delta: float) -> void:
	_build_if_needed()
	_face_camera()
	_time += delta

	var pulse: float = 1.0 + sin(_time * pulse_speed) * pulse_amount
	if _core != null:
		_core.scale = Vector3(pulse, pulse * 1.04, 1.0)
	if _outer != null:
		var outer_pulse: float = 1.0 + sin(_time * pulse_speed * 0.82 + 0.7) * (pulse_amount * 1.4)
		_outer.scale = Vector3(outer_pulse, outer_pulse * 1.08, 1.0)


func _build_if_needed() -> void:
	if _core != null and _outer != null:
		return

	for child in get_children():
		child.queue_free()

	_outer = _create_flame_quad("OuterFlame", outer_size, outer_tint)
	_outer.position = Vector3(0.0, 0.02, -0.002)
	add_child(_outer)

	_core = _create_flame_quad("CoreFlame", core_size, tint)
	_core.position = Vector3(0.0, 0.04, 0.002)
	add_child(_core)


func _create_flame_quad(node_name: String, size: Vector2, color: Color) -> MeshInstance3D:
	var quad := MeshInstance3D.new()
	quad.name = node_name

	var mesh := QuadMesh.new()
	mesh.size = size
	quad.mesh = mesh
	quad.material_override = _make_flame_material(color)
	return quad


func _make_flame_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = 1.8
	if ResourceLoader.exists(texture_path):
		var texture: Texture2D = load(texture_path) as Texture2D
		material.albedo_texture = texture
	return material


func _face_camera() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	look_at(camera.global_position, Vector3.UP, true)
