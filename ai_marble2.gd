extends RigidBody3D

@export var hole: Node3D
@export var shot_force_base: float = 8.6
@export var min_force_value: float = 0.8
@export var max_force_value: float = 3.5
@export var min_shot_impulse: float = 0.08
@export var max_shot_impulse: float = 10.8
@export var power_response_exponent: float = 2.35
@export var min_shot_lift: float = 0.08
@export var max_shot_lift: float = 0.24
@export var max_vertical_shot_impulse: float = 0.52
@export var max_upward_velocity: float = 2.2
@export var stop_threshold: float = 0.05
@export var marbles: Array[Node3D]

var rng := RandomNumberGenerator.new()
var turn_manager: Node = null
var aiming_preview := false
var preview_aim_direction := Vector3.ZERO
var preview_force := 1.2
var indicator_segments: Array[MeshInstance3D] = []
var arrow_tip: MeshInstance3D = null
var _segment_mesh: CylinderMesh = null
var _tip_mesh: CylinderMesh = null
var _aim_material: StandardMaterial3D = null
var aim_line_glow: MeshInstance3D = null
var aim_line_core: MeshInstance3D = null
var aim_line_tip: MeshInstance3D = null
var _aim_glow_material: ShaderMaterial = null
var _aim_core_material: ShaderMaterial = null
var _aim_tip_material: ShaderMaterial = null


func _ready() -> void:
	rng.randomize()
	_create_aim_indicator()
	var visual := get_node_or_null("GlassBallModel")
	if visual and visual.has_method("set_palette"):
		visual.set_palette({
			"marble_type": "default",
			"pattern_name": "default",
			"marble_scene_path": "res://marbles/marble_default_obsidian.tscn"
		})


func _physics_process(_delta: float) -> void:
	_clamp_upward_velocity()


func start_turn(turn_mgr: Node) -> void:
	turn_manager = turn_mgr

	var target: Vector3 = hole.global_position if hole else global_position + Vector3.FORWARD
	if marbles.size() > 1 and rng.randf() < 0.5:
		target = _choose_attack_target()

	var aim := (target - global_position).normalized()
	var force := rng.randf_range(0.8, 1.2)
	shoot(aim, force)


func begin_aim_preview(strategy: Dictionary) -> void:
	preview_aim_direction = (strategy.get("aim", Vector3.ZERO) as Vector3).normalized()
	preview_force = strategy.get("force", 1.2)
	aiming_preview = preview_aim_direction != Vector3.ZERO
	if aiming_preview:
		_show_aim_preview(preview_aim_direction, preview_force)


func end_aim_preview() -> void:
	aiming_preview = false
	preview_aim_direction = Vector3.ZERO
	_hide_aim_indicator()


func is_aiming() -> bool:
	return aiming_preview and preview_aim_direction != Vector3.ZERO


func get_aim_direction() -> Vector3:
	return preview_aim_direction


func get_aim_power_ratio() -> float:
	return _get_effective_power_ratio(_get_force_ratio(preview_force))


func shoot(aim: Vector3, force: float) -> void:
	if aim == Vector3.ZERO:
		return

	end_aim_preview()
	sleeping = false
	var shot_ratio: float = _get_effective_power_ratio(_get_force_ratio(force))
	var shot_context := _get_hole_shot_context(aim)
	var shot_impulse: float = lerpf(min_shot_impulse, max_shot_impulse, shot_ratio) * float(shot_context.get("impulse_multiplier", 1.0))
	var lift: float = lerpf(min_shot_lift, max_shot_lift, ease(shot_ratio, 1.15)) * float(shot_context.get("lift_multiplier", 1.0))
	var shot_direction: Vector3 = shot_context.get("direction", aim.normalized())
	apply_central_impulse(_make_realistic_shot_impulse(shot_direction, shot_impulse, lift, aim))
	_clamp_upward_velocity()


func _make_realistic_shot_impulse(shot_direction: Vector3, shot_impulse: float, lift: float, fallback_aim: Vector3) -> Vector3:
	var planar_direction := Vector3(shot_direction.x, 0.0, shot_direction.z)
	if planar_direction.length_squared() <= 0.0001:
		planar_direction = Vector3(fallback_aim.x, 0.0, fallback_aim.z)
	if planar_direction.length_squared() <= 0.0001:
		planar_direction = Vector3.FORWARD
	planar_direction = planar_direction.normalized()

	var directional_lift := maxf(shot_direction.y, 0.0) * shot_impulse
	var vertical_impulse := minf(lift + directional_lift, max_vertical_shot_impulse)
	return planar_direction * shot_impulse + Vector3.UP * vertical_impulse


func _clamp_upward_velocity() -> void:
	if linear_velocity.y > max_upward_velocity:
		var clamped_velocity := linear_velocity
		clamped_velocity.y = max_upward_velocity
		linear_velocity = clamped_velocity


func end_turn() -> void:
	turn_manager = null


func is_moving() -> bool:
	return linear_velocity.length() > stop_threshold


func _get_force_ratio(force: float) -> float:
	if max_force_value <= min_force_value:
		return 1.0 if force >= max_force_value else 0.0
	return clampf(inverse_lerp(min_force_value, max_force_value, force), 0.0, 1.0)


func _get_effective_power_ratio(force_ratio: float) -> float:
	return clampf(pow(clampf(force_ratio, 0.0, 1.0), power_response_exponent), 0.0, 1.0)


func _get_hole_shot_context(base_direction: Vector3) -> Dictionary:
	if hole == null:
		return {"direction": base_direction.normalized(), "lift_multiplier": 1.0, "impulse_multiplier": 1.0}

	var local_position: Vector3 = hole.to_local(global_position)
	var pocket_radius: float = float(hole.get("pocket_radius")) if hole.get("pocket_radius") != null else 1.0
	var depth: float = float(hole.get("depth")) if hole.get("depth") != null else 1.0
	var bottom_stop_lift: float = float(hole.get("bottom_stop_lift")) if hole.get("bottom_stop_lift") != null else 0.08
	var bottom_stop_height: float = float(hole.get("bottom_stop_height")) if hole.get("bottom_stop_height") != null else 0.18
	var bottom_touch_y: float = -depth + bottom_stop_lift + bottom_stop_height + 0.23
	var planar: Vector2 = Vector2(local_position.x, local_position.z)
	var inside_hole := planar.length() <= pocket_radius * 0.92 and local_position.y <= bottom_touch_y
	if not inside_hole:
		return {"direction": base_direction.normalized(), "lift_multiplier": 1.0, "impulse_multiplier": 1.0}

	var deepest_playable_y: float = -depth + bottom_stop_lift + bottom_stop_height * 0.5 + 0.2
	var depth_ratio := clampf(inverse_lerp(bottom_touch_y, deepest_playable_y, local_position.y), 0.0, 1.0)
	var outward := Vector3(local_position.x, 0.0, local_position.z)
	if outward.length_squared() <= 0.0001:
		outward = Vector3(base_direction.x, 0.0, base_direction.z)
	if outward.length_squared() <= 0.0001:
		outward = Vector3.FORWARD
	outward = outward.normalized()

	var assist_direction := (base_direction.normalized() + outward * lerpf(0.72, 1.05, depth_ratio) + Vector3.UP * lerpf(0.82, 1.18, depth_ratio)).normalized()
	var adjusted_direction := base_direction.normalized().slerp(assist_direction, lerpf(0.42, 0.68, depth_ratio)).normalized()
	var lift_multiplier := lerpf(2.45, 3.25, depth_ratio)
	var impulse_multiplier := lerpf(1.42, 1.62, depth_ratio)
	return {"direction": adjusted_direction, "lift_multiplier": lift_multiplier, "impulse_multiplier": impulse_multiplier}


func _choose_attack_target() -> Vector3:
	var best_target: Node3D = null
	var shortest_dist := INF

	for marble in marbles:
		if marble == self:
			continue
		var distance_to_marble := global_position.distance_to(marble.global_position)
		if distance_to_marble < shortest_dist:
			shortest_dist = distance_to_marble
			best_target = marble

	if best_target:
		return best_target.global_position
	return hole.global_position if hole else global_position + Vector3.FORWARD


func _create_aim_indicator() -> void:
	_segment_mesh = CylinderMesh.new()
	_segment_mesh.top_radius = 1.0
	_segment_mesh.bottom_radius = 1.0
	_segment_mesh.height = 1.0
	_segment_mesh.radial_segments = 16

	_aim_glow_material = _make_aim_extension_material(Color(0.28, 0.95, 1.0, 0.2), 1.5)
	_aim_core_material = _make_aim_extension_material(Color(0.84, 1.0, 0.98, 0.78), 2.6)
	_aim_tip_material = _make_aim_extension_material(Color(0.48, 1.0, 0.9, 0.62), 2.1)

	aim_line_glow = _make_aim_line_instance("AiAimExtensionGlow", _aim_glow_material)
	add_child(aim_line_glow)

	aim_line_core = _make_aim_line_instance("AiAimExtensionCore", _aim_core_material)
	add_child(aim_line_core)

	arrow_tip = MeshInstance3D.new()
	arrow_tip.name = "AiAimExtensionTip"
	var tip_mesh: SphereMesh = SphereMesh.new()
	tip_mesh.radius = 0.08
	tip_mesh.height = 0.16
	tip_mesh.radial_segments = 12
	tip_mesh.rings = 6
	arrow_tip.mesh = tip_mesh
	arrow_tip.material_override = _aim_tip_material
	arrow_tip.visible = false
	aim_line_tip = arrow_tip
	add_child(arrow_tip)


func _show_aim_preview(direction: Vector3, force: float) -> void:
	if direction == Vector3.ZERO:
		_hide_aim_indicator()
		return

	var shot_ratio := _get_effective_power_ratio(_get_force_ratio(force))
	var path_length := lerpf(1.3, 4.6, shot_ratio)
	var arc_height := lerpf(0.1, 0.65, shot_ratio)
	var safe_direction := direction.normalized()
	var start := global_position + Vector3.UP * 0.12 + safe_direction * 0.26
	var finish := global_position + Vector3.UP * 0.12 + safe_direction * path_length + Vector3.UP * minf(arc_height * 0.1, 0.08)
	var line_vector := finish - start
	var line_length := maxf(line_vector.length(), 0.1)
	var line_direction := line_vector.normalized()
	var line_center := start.lerp(finish, 0.5)
	var beam_basis := _basis_from_y(line_direction)
	var core_radius := lerpf(0.022, 0.038, shot_ratio)
	var glow_radius := core_radius * 1.75

	_update_aim_extension_materials(shot_ratio)
	_position_aim_line(aim_line_glow, beam_basis, line_center, line_length, glow_radius)
	_position_aim_line(aim_line_core, beam_basis, line_center, line_length, core_radius)

	if arrow_tip:
		arrow_tip.visible = true
		arrow_tip.global_position = finish
		var tip_scale := lerpf(0.38, 0.68, shot_ratio)
		arrow_tip.scale = Vector3.ONE * tip_scale


func _hide_aim_indicator() -> void:
	for segment in indicator_segments:
		segment.visible = false
	if aim_line_glow:
		aim_line_glow.visible = false
	if aim_line_core:
		aim_line_core.visible = false
	if arrow_tip:
		arrow_tip.visible = false


func _make_aim_line_instance(node_name: String, material: Material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.mesh = _segment_mesh
	mesh_instance.material_override = material
	mesh_instance.visible = false
	return mesh_instance


func _make_aim_extension_material(color: Color, energy: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = _get_aim_extension_shader()
	material.set_shader_parameter("beam_color", color)
	material.set_shader_parameter("emission_energy", energy)
	return material


func _get_aim_extension_shader() -> Shader:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 beam_color : source_color = vec4(0.5, 1.0, 0.95, 0.7);
uniform float emission_energy = 2.0;

void fragment() {
	ALBEDO = beam_color.rgb;
	ALPHA = beam_color.a;
	EMISSION = beam_color.rgb * emission_energy;
}
"""
	return shader


func _position_aim_line(line: MeshInstance3D, basis: Basis, center: Vector3, length: float, radius: float) -> void:
	if line == null or not is_instance_valid(line):
		return
	line.visible = true
	line.global_transform = Transform3D(basis, center)
	line.scale = Vector3(radius, length, radius)


func _update_aim_extension_materials(shot_ratio: float) -> void:
	var trail_color := _get_aim_extension_color()
	var core_color := trail_color.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.42)
	core_color.a = lerpf(0.58, 0.86, shot_ratio)
	var glow_color := trail_color
	glow_color.a = lerpf(0.16, 0.28, shot_ratio)
	var tip_color := trail_color.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.2)
	tip_color.a = lerpf(0.46, 0.68, shot_ratio)

	if _aim_core_material != null:
		_aim_core_material.set_shader_parameter("beam_color", core_color)
	if _aim_glow_material != null:
		_aim_glow_material.set_shader_parameter("beam_color", glow_color)
	if _aim_tip_material != null:
		_aim_tip_material.set_shader_parameter("beam_color", tip_color)


func _get_aim_extension_color() -> Color:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_selected_trail_preset"):
		var selected_preset: Dictionary = customization.call("get_selected_trail_preset")
		if selected_preset.has("emission"):
			return selected_preset.get("emission", Color(0.42, 1.0, 0.94, 1.0))
		if selected_preset.has("color"):
			return selected_preset.get("color", Color(0.42, 1.0, 0.94, 1.0))
	return Color(0.42, 1.0, 0.94, 1.0)


func _quadratic_bezier(start: Vector3, control: Vector3, finish: Vector3, t: float) -> Vector3:
	var inv_t: float = 1.0 - t
	return inv_t * inv_t * start + 2.0 * inv_t * t * control + t * t * finish


func _basis_from_y(direction: Vector3) -> Basis:
	var up_axis: Vector3 = direction.normalized()
	var side_axis: Vector3 = Vector3.FORWARD.cross(up_axis)
	if side_axis.length_squared() == 0.0:
		side_axis = Vector3.RIGHT
	side_axis = side_axis.normalized()
	var forward_axis: Vector3 = up_axis.cross(side_axis).normalized()
	return Basis(side_axis, up_axis, forward_axis)
