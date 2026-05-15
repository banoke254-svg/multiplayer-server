extends Node3D

var _last_global_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	_duplicate_shader_overrides(self)
	if _uses_flame_effects():
		_setup_flame_trail()
	else:
		_remove_illumination_effects()
	_last_global_position = global_position
	set_process(get_node_or_null("FlameTrail") != null)

func _duplicate_shader_overrides(node: Node) -> void:
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance != null:
		var shader_material: ShaderMaterial = mesh_instance.material_override as ShaderMaterial
		if shader_material != null:
			mesh_instance.material_override = shader_material.duplicate(true)
		elif mesh_instance.material_override != null:
			mesh_instance.material_override = mesh_instance.material_override.duplicate(true)
		elif mesh_instance.mesh != null and mesh_instance.mesh.get_surface_count() > 0:
			for surface_index in range(mesh_instance.mesh.get_surface_count()):
				var surface_material: Material = mesh_instance.mesh.surface_get_material(surface_index)
				if surface_material != null:
					mesh_instance.set_surface_override_material(surface_index, surface_material.duplicate(true))

	for child in node.get_children():
		_duplicate_shader_overrides(child)


func _process(_delta: float) -> void:
	var flame_trail: GPUParticles3D = get_node_or_null("FlameTrail") as GPUParticles3D
	if flame_trail == null:
		return

	var process_material: ParticleProcessMaterial = flame_trail.process_material as ParticleProcessMaterial
	if process_material == null:
		return

	var velocity: Vector3 = Vector3.ZERO
	var body: RigidBody3D = get_parent() as RigidBody3D
	if body != null:
		velocity = body.linear_velocity
	else:
		velocity = global_position - _last_global_position
		_last_global_position = global_position

	if velocity.length() > 0.1:
		flame_trail.emitting = true
		process_material.direction = -velocity.normalized()
	else:
		flame_trail.emitting = true
		process_material.direction = Vector3.UP * 0.35


func _remove_illumination_effects() -> void:
	for node_name in ["FlameTrail", "FlameCrown3D"]:
		var effect_node: Node = get_node_or_null(node_name)
		if effect_node != null:
			effect_node.queue_free()


func _uses_flame_effects() -> bool:
	return scene_file_path.to_lower().find("flame") != -1


func _setup_flame_trail() -> void:
	var flame_trail: GPUParticles3D = get_node_or_null("FlameTrail") as GPUParticles3D
	if flame_trail == null:
		return

	flame_trail.amount = 20
	flame_trail.lifetime = 0.5
	flame_trail.one_shot = false
	flame_trail.explosiveness = 0.0
	flame_trail.local_coords = false
	flame_trail.emitting = true
	flame_trail.position = Vector3.ZERO
	flame_trail.draw_passes = 1
	flame_trail.preprocess = 0.2
	flame_trail.visibility_aabb = AABB(Vector3(-1.8, -1.8, -1.8), Vector3(3.6, 3.6, 3.6))

	var process_material: ParticleProcessMaterial = flame_trail.process_material as ParticleProcessMaterial
	if process_material == null:
		process_material = ParticleProcessMaterial.new()
		flame_trail.process_material = process_material

	process_material.direction = Vector3.ZERO
	process_material.gravity = Vector3.ZERO
	process_material.initial_velocity_min = 0.65
	process_material.initial_velocity_max = 0.9
	process_material.spread = 28.0
	process_material.scale_min = 0.9
	process_material.scale_max = 1.3
	process_material.scale_curve = _make_scale_curve_texture()
	process_material.color_ramp = _make_flame_gradient_texture()

	flame_trail.draw_pass_1 = _make_flame_particle_mesh()


func _make_scale_curve_texture() -> CurveTexture:
	var curve: Curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.5))
	curve.add_point(Vector2(0.45, 0.36))
	curve.add_point(Vector2(1.0, 0.0))

	var curve_texture: CurveTexture = CurveTexture.new()
	curve_texture.curve = curve
	return curve_texture


func _make_flame_gradient_texture() -> GradientTexture1D:
	var gradient: Gradient = Gradient.new()
	var colors: Array[Color] = _get_flame_colors_for_scene()
	gradient.add_point(0.0, colors[0])
	gradient.add_point(0.55, colors[1])
	gradient.add_point(1.0, colors[2])

	var gradient_texture: GradientTexture1D = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	return gradient_texture


func _make_flame_particle_mesh() -> QuadMesh:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.26, 0.36)
	quad.material = _make_flame_particle_material()
	return quad


func _make_flame_particle_material() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = "shader_type spatial;\n\nrender_mode unshaded, blend_add, cull_disabled;\n\nvoid fragment() {\n\tALBEDO = COLOR.rgb;\n\tEMISSION = COLOR.rgb * 1.8;\n\tALPHA = COLOR.a;\n}\n"

	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	return material


func _get_flame_colors_for_scene() -> Array[Color]:
	var path: String = scene_file_path.to_lower()
	if path.find("blue") != -1:
		return [
			Color(0.82, 0.92, 1.0, 1.0),
			Color(0.28, 0.52, 1.0, 0.9),
			Color(0.06, 0.12, 0.32, 0.0)
		]
	if path.find("green") != -1:
		return [
			Color(0.92, 1.0, 0.58, 1.0),
			Color(0.24, 0.9, 0.30, 0.9),
			Color(0.06, 0.18, 0.08, 0.0)
		]
	if path.find("violet") != -1:
		return [
			Color(1.0, 0.9, 1.0, 1.0),
			Color(0.62, 0.28, 1.0, 0.9),
			Color(0.12, 0.04, 0.20, 0.0)
		]
	return [
		Color(1.0, 0.7, 0.2, 1.0),
		Color(1.0, 0.3, 0.0, 0.9),
		Color(0.2, 0.0, 0.0, 0.0)
	]
