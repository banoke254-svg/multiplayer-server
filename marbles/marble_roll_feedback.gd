@tool
extends Node3D

@export var min_speed: float = 0.45
@export var max_speed: float = 8.0

var _body: RigidBody3D = null
var _dust: GPUParticles3D = null


func _ready() -> void:
	_body = get_parent() as RigidBody3D
	_build_effect()
	set_process(true)


func _process(_delta: float) -> void:
	if _body == null or _dust == null:
		return

	var speed: float = _body.linear_velocity.length()
	var grounded_like: bool = absf(_body.linear_velocity.y) < 1.1
	var moving: bool = speed > min_speed and grounded_like

	_dust.emitting = moving
	if not moving:
		return

	var motion: Vector3 = _body.linear_velocity
	var planar: Vector3 = Vector3(motion.x, 0.0, motion.z)
	if planar.length_squared() <= 0.0001:
		planar = Vector3.FORWARD
	var direction: Vector3 = planar.normalized()
	var speed_ratio: float = clampf(inverse_lerp(min_speed, max_speed, speed), 0.0, 1.0)

	position = Vector3(0.0, -0.17, 0.0)
	_dust.amount = int(round(lerpf(6.0, 16.0, speed_ratio)))
	_dust.lifetime = lerpf(0.28, 0.45, speed_ratio)
	_dust.position = Vector3(-direction.x * 0.06, -0.01, -direction.z * 0.06)

	var process_material: ParticleProcessMaterial = _dust.process_material as ParticleProcessMaterial
	if process_material != null:
		process_material.direction = (-direction + Vector3.UP * 0.22).normalized()
		process_material.initial_velocity_min = lerpf(0.18, 0.46, speed_ratio)
		process_material.initial_velocity_max = lerpf(0.34, 0.85, speed_ratio)
		process_material.scale_min = lerpf(0.28, 0.42, speed_ratio)
		process_material.scale_max = lerpf(0.42, 0.68, speed_ratio)


func _build_effect() -> void:
	if _dust != null:
		return

	_dust = GPUParticles3D.new()
	_dust.name = "RollDust"
	_dust.amount = 8
	_dust.lifetime = 0.32
	_dust.one_shot = false
	_dust.explosiveness = 0.0
	_dust.randomness = 0.55
	_dust.local_coords = true
	_dust.emitting = false
	_dust.preprocess = 0.1
	_dust.visibility_aabb = AABB(Vector3(-1.5, -0.5, -1.5), Vector3(3.0, 1.5, 3.0))

	var process_material := ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process_material.emission_sphere_radius = 0.045
	process_material.direction = Vector3(0.0, 0.35, -1.0).normalized()
	process_material.spread = 22.0
	process_material.gravity = Vector3(0.0, -0.2, 0.0)
	process_material.initial_velocity_min = 0.2
	process_material.initial_velocity_max = 0.4
	process_material.scale_min = 0.24
	process_material.scale_max = 0.5
	process_material.scale_curve = _make_scale_curve()
	process_material.color_ramp = _make_color_ramp()
	_dust.process_material = process_material

	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.12, 0.12)
	mesh.material = _make_particle_material()
	_dust.draw_passes = 1
	_dust.draw_pass_1 = mesh
	add_child(_dust)


func _make_scale_curve() -> CurveTexture:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 0.25))
	curve.add_point(Vector2(0.2, 0.9))
	curve.add_point(Vector2(1.0, 0.0))
	var texture := CurveTexture.new()
	texture.curve = curve
	return texture


func _make_color_ramp() -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.add_point(0.0, Color(0.88, 0.96, 1.0, 0.22))
	gradient.add_point(0.45, Color(0.76, 0.9, 0.98, 0.14))
	gradient.add_point(1.0, Color(0.56, 0.72, 0.84, 0.0))
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture


func _make_particle_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type spatial;\n\nrender_mode unshaded, blend_add, cull_disabled;\n\nvoid fragment() {\n\tvec2 centered = UV * 2.0 - 1.0;\n\tfloat alpha = smoothstep(1.0, 0.0, length(centered));\n\tALBEDO = COLOR.rgb;\n\tEMISSION = COLOR.rgb * 1.6;\n\tALPHA = alpha * COLOR.a;\n}\n"
	var material := ShaderMaterial.new()
	material.shader = shader
	return material
