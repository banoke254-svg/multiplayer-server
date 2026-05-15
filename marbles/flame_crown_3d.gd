@tool
extends Node3D

var _flame_body: GPUParticles3D = null
var _flame_sparks: GPUParticles3D = null
var _time: float = 0.0
var _follow_parent: Node3D = null

@export var wind_direction: Vector3 = Vector3(0.9, 0.0, 0.25)
@export var wind_strength: float = 0.95
@export var wind_wave_speed: float = 1.4
@export var wind_wave_amount: float = 0.24


func _ready() -> void:
	_follow_parent = get_parent() as Node3D
	_build_effect()
	_lock_world_pose()
	set_process(true)


func _process(delta: float) -> void:
	_time += delta
	_lock_world_pose()
	_apply_wind()


func _build_effect() -> void:
	if _flame_body != null and _flame_sparks != null:
		return

	for child in get_children():
		child.queue_free()

	var colors: Array[Color] = _get_flame_colors()
	_flame_body = _make_flame_body(colors)
	add_child(_flame_body)

	_flame_sparks = _make_flame_sparks(colors)
	add_child(_flame_sparks)


func _make_flame_body(colors: Array[Color]) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "FlameBody"
	particles.amount = 28
	particles.lifetime = 0.72
	particles.one_shot = false
	particles.explosiveness = 0.0
	particles.randomness = 0.24
	particles.local_coords = true
	particles.emitting = true
	particles.preprocess = 0.2
	particles.position = Vector3(0.0, 0.1, 0.0)
	particles.visibility_aabb = AABB(Vector3(-2.4, -1.8, -2.4), Vector3(4.8, 5.2, 4.8))

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.26
	process.direction = Vector3(0.0, 1.0, 0.0)
	process.spread = 12.0
	process.gravity = Vector3(0.0, 0.72, 0.0)
	process.initial_velocity_min = 0.24
	process.initial_velocity_max = 0.52
	process.scale_min = 1.05
	process.scale_max = 1.95
	process.scale_curve = _make_scale_curve()
	process.color_ramp = _make_gradient(colors, true)
	particles.process_material = process

	var quad := QuadMesh.new()
	quad.size = Vector2(0.34, 0.72)
	quad.material = _make_flame_material()
	particles.draw_passes = 1
	particles.draw_pass_1 = quad
	return particles


func _make_flame_sparks(colors: Array[Color]) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "FlameSparks"
	particles.amount = 20
	particles.lifetime = 0.95
	particles.one_shot = false
	particles.explosiveness = 0.15
	particles.randomness = 0.3
	particles.local_coords = true
	particles.emitting = true
	particles.preprocess = 0.2
	particles.position = Vector3(0.0, 0.18, 0.0)
	particles.visibility_aabb = AABB(Vector3(-2.8, -2.0, -2.8), Vector3(5.6, 5.8, 5.6))

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.3
	process.direction = Vector3(0.0, 1.0, 0.0)
	process.spread = 18.0
	process.gravity = Vector3(0.0, 0.36, 0.0)
	process.initial_velocity_min = 0.42
	process.initial_velocity_max = 0.9
	process.scale_min = 0.28
	process.scale_max = 0.52
	process.scale_curve = _make_spark_scale_curve()
	process.color_ramp = _make_gradient(colors, false)
	particles.process_material = process

	var sphere := SphereMesh.new()
	sphere.radius = 0.03
	sphere.height = 0.06
	sphere.material = _make_spark_material()
	particles.draw_passes = 1
	particles.draw_pass_1 = sphere
	return particles


func _make_flame_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type spatial;\n\nrender_mode unshaded, blend_add, cull_disabled;\n\nvoid fragment() {\n\tvec2 centered = UV * 2.0 - 1.0;\n\tfloat body = 1.0 - clamp(length(vec2(centered.x * 0.85, centered.y * 0.55)), 0.0, 1.0);\n\tfloat tip = smoothstep(-0.35, 0.95, centered.y);\n\tfloat alpha = pow(max(body, 0.0), 1.8) * tip * COLOR.a;\n\tALBEDO = COLOR.rgb;\n\tEMISSION = COLOR.rgb * 2.4;\n\tALPHA = alpha;\n}\n"
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _make_spark_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type spatial;\n\nrender_mode unshaded, blend_add, cull_disabled;\n\nvoid fragment() {\n\tALBEDO = COLOR.rgb;\n\tEMISSION = COLOR.rgb * 3.0;\n\tALPHA = COLOR.a;\n}\n"
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _make_scale_curve() -> CurveTexture:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 0.25))
	curve.add_point(Vector2(0.35, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	var texture := CurveTexture.new()
	texture.curve = curve
	return texture


func _make_spark_scale_curve() -> CurveTexture:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 0.6))
	curve.add_point(Vector2(0.6, 0.22))
	curve.add_point(Vector2(1.0, 0.0))
	var texture := CurveTexture.new()
	texture.curve = curve
	return texture


func _apply_wind() -> void:
	var planar_wind: Vector3 = wind_direction
	planar_wind.y = 0.0
	if planar_wind.length_squared() <= 0.0001:
		planar_wind = Vector3(1.0, 0.0, 0.0)
	var wind_normalized: Vector3 = planar_wind.normalized()
	var wave: float = sin(_time * wind_wave_speed + global_position.x * 0.42 + global_position.z * 0.28)
	var side_wave: float = cos(_time * wind_wave_speed * 0.72 + global_position.x * 0.31)
	var wind_offset: Vector3 = wind_normalized * (wind_strength + wave * wind_wave_amount)
	wind_offset += Vector3(-wind_normalized.z, 0.0, wind_normalized.x) * (side_wave * wind_wave_amount * 0.22)

	_apply_wind_to_particles(_flame_body, wind_offset, 0.18, 0.68)
	_apply_wind_to_particles(_flame_sparks, wind_offset * 1.22, 0.22, 0.34)


func _lock_world_pose() -> void:
	if _follow_parent == null:
		return
	global_position = _follow_parent.global_position + Vector3(0.0, 0.02, 0.0)
	global_basis = Basis.IDENTITY


func _apply_wind_to_particles(particles: GPUParticles3D, wind_offset: Vector3, spread: float, up_gravity: float) -> void:
	if particles == null:
		return
	var process: ParticleProcessMaterial = particles.process_material as ParticleProcessMaterial
	if process == null:
		return
	process.direction = (Vector3.UP + wind_offset).normalized()
	process.spread = rad_to_deg(spread)
	process.gravity = Vector3(wind_offset.x * 0.22, up_gravity, wind_offset.z * 0.22)


func _make_gradient(colors: Array[Color], include_core: bool) -> GradientTexture1D:
	var gradient := Gradient.new()
	if include_core:
		gradient.add_point(0.0, colors[0])
		gradient.add_point(0.4, colors[1])
		gradient.add_point(1.0, Color(colors[2].r, colors[2].g, colors[2].b, 0.0))
	else:
		gradient.add_point(0.0, Color(colors[1].r, colors[1].g, colors[1].b, 0.95))
		gradient.add_point(1.0, Color(colors[2].r, colors[2].g, colors[2].b, 0.0))

	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture


func _get_flame_colors() -> Array[Color]:
	var owner_path: String = ""
	var parent_node: Node = get_parent()
	if parent_node != null:
		owner_path = str(parent_node.scene_file_path).to_lower()

	if owner_path.find("blue") != -1:
		return [
			Color(0.88, 1.0, 1.0, 1.0),
			Color(0.18, 0.92, 1.0, 0.95),
			Color(0.02, 0.26, 0.78, 0.0)
		]
	if owner_path.find("green") != -1:
		return [
			Color(0.96, 1.0, 0.72, 1.0),
			Color(0.34, 1.0, 0.34, 0.95),
			Color(0.08, 0.28, 0.08, 0.0)
		]
	if owner_path.find("violet") != -1:
		return [
			Color(1.0, 0.92, 1.0, 1.0),
			Color(0.74, 0.28, 1.0, 0.95),
			Color(0.16, 0.06, 0.32, 0.0)
		]

	return [
		Color(1.0, 0.92, 0.68, 1.0),
		Color(1.0, 0.46, 0.08, 0.95),
		Color(0.26, 0.04, 0.02, 0.0)
	]
