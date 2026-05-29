extends Node3D

const SFX_PATHS: Dictionary = {
	"hit": "res://audiomass-output.mp3",
	"sink": "res://New project 2.mp3",
	"victory": "res://audio_menu_theme.mp3",
	"ui": "res://audiomass-output.mp3"
}

var audio_pool: Array[AudioStreamPlayer3D] = []
var audio_index: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for index in range(6):
		var player := AudioStreamPlayer3D.new()
		player.name = "PremiumSfx%d" % index
		player.bus = _get_sfx_bus_name()
		player.max_distance = 42.0
		player.unit_size = 1.0
		add_child(player)
		audio_pool.append(player)


func play_ui_sound() -> void:
	_play_sound("ui", global_position, -12.0, randf_range(1.35, 1.55))


func spawn_hit_sparks(position: Vector3, intensity: float = 1.0, accent: Color = Color(1.0, 0.72, 0.18, 1.0)) -> void:
	var strength: float = clampf(intensity, 0.35, 2.0)
	_spawn_burst(position, accent, Color(1.0, 0.94, 0.64, 1.0), int(18.0 * strength), 0.36, 0.07, 2.8 * strength)
	_spawn_flash(position, accent, 0.42 * strength, 0.18)
	_play_sound("hit", position, lerpf(-8.0, 2.0, clampf(strength / 2.0, 0.0, 1.0)), randf_range(1.42, 1.72))


func spawn_hole_sink(position: Vector3, accent: Color = Color(0.42, 0.92, 1.0, 1.0)) -> void:
	_spawn_burst(position + Vector3.UP * 0.08, accent, Color(0.92, 1.0, 1.0, 1.0), 30, 0.72, 0.11, 1.8)
	_spawn_ring(position + Vector3.UP * 0.04, accent, 0.32, 1.7, 0.42)
	_play_sound("sink", position, -2.0, randf_range(0.72, 0.86))


func spawn_victory(position: Vector3, accent: Color = Color(1.0, 0.82, 0.22, 1.0)) -> void:
	for offset_index in range(5):
		var angle: float = TAU * float(offset_index) / 5.0
		var offset := Vector3(cos(angle), 0.0, sin(angle)) * 0.95
		_spawn_burst(position + offset + Vector3.UP * 0.4, accent.lightened(0.12), Color(1.0, 0.96, 0.72, 1.0), 42, 1.1, 0.09, 3.4)
	_spawn_ring(position + Vector3.UP * 0.16, accent, 0.5, 2.6, 0.7)
	_play_sound("victory", position, -8.5, randf_range(1.04, 1.12))


func _spawn_burst(position: Vector3, color_a: Color, color_b: Color, count: int, lifetime: float, size: float, speed: float) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "RewardBurst"
	particles.one_shot = true
	particles.amount = maxi(count, 1)
	particles.lifetime = lifetime
	particles.explosiveness = 0.92
	particles.randomness = 0.62
	particles.draw_pass_1 = _make_particle_mesh(size)
	particles.process_material = _make_burst_material(color_a, color_b, speed)
	if not _add_effect_node(particles, position):
		particles.queue_free()
		return
	particles.emitting = true
	_cleanup_node_later(particles, lifetime + 0.45)


func _spawn_flash(position: Vector3, color: Color, radius: float, lifetime: float) -> void:
	var flash := MeshInstance3D.new()
	flash.name = "ImpactFlash"
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	flash.mesh = mesh
	flash.material_override = _make_emissive_material(color, 2.2, 0.36)
	if not _add_effect_node(flash, position):
		flash.queue_free()
		return
	var tween := create_tween()
	tween.tween_property(flash, "scale", Vector3.ONE * 0.08, lifetime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, lifetime)
	tween.finished.connect(flash.queue_free)


func _spawn_ring(position: Vector3, color: Color, start_radius: float, end_radius: float, lifetime: float) -> void:
	var ring := MeshInstance3D.new()
	ring.name = "RewardRing"
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.018
	mesh.outer_radius = start_radius
	ring.mesh = mesh
	ring.material_override = _make_emissive_material(color, 1.8, 0.62)
	if not _add_effect_node(ring, position):
		ring.queue_free()
		return
	var tween := create_tween()
	tween.tween_property(ring, "scale", Vector3.ONE * (end_radius / maxf(start_radius, 0.01)), lifetime).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(ring, "modulate:a", 0.0, lifetime)
	tween.finished.connect(ring.queue_free)


func _make_particle_mesh(size: float) -> Mesh:
	var mesh := SphereMesh.new()
	mesh.radius = size
	mesh.height = size * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	return mesh


func _make_burst_material(color_a: Color, color_b: Color, speed: float) -> ParticleProcessMaterial:
	var material := ParticleProcessMaterial.new()
	material.direction = Vector3.UP
	material.spread = 180.0
	material.initial_velocity_min = speed * 0.45
	material.initial_velocity_max = speed
	material.gravity = Vector3(0.0, -3.8, 0.0)
	material.damping_min = 0.8
	material.damping_max = 1.8
	material.scale_min = 0.7
	material.scale_max = 1.35
	var gradient := Gradient.new()
	gradient.set_color(0, color_a)
	var faded := color_b
	faded.a = 0.0
	gradient.set_color(1, faded)
	var gradient_texture := GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
	return material


func _make_emissive_material(color: Color, energy: float, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var albedo := color
	albedo.a = alpha
	material.albedo_color = albedo
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


func _play_sound(kind: String, position: Vector3, volume_db: float, pitch: float) -> void:
	if audio_pool.is_empty():
		return
	var path: String = str(SFX_PATHS.get(kind, ""))
	var stream := load(path) as AudioStream
	if stream == null:
		return
	var player := audio_pool[audio_index % audio_pool.size()]
	audio_index += 1
	player.stop()
	player.stream = stream
	player.global_position = position
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()


func _cleanup_node_later(node: Node, seconds: float) -> void:
	var tree := _get_tree_safe()
	if tree == null:
		if node != null and is_instance_valid(node):
			node.queue_free()
		return
	var timer := tree.create_timer(seconds)
	timer.timeout.connect(func() -> void:
		if node != null and is_instance_valid(node):
			node.queue_free()
	)


func _add_effect_node(node: Node3D, position: Vector3) -> bool:
	var parent := _get_effect_parent()
	if parent == null:
		return false
	parent.add_child(node)
	node.global_position = position
	return true


func _get_effect_parent() -> Node:
	var tree := _get_tree_safe()
	if tree != null and tree.current_scene != null:
		return tree.current_scene
	return self if is_inside_tree() else null


func _get_tree_safe() -> SceneTree:
	if not is_inside_tree():
		return null
	return get_tree()


func _get_sfx_bus_name() -> String:
	return "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"
