extends Node3D

@export_node_path("Node") var turn_manager_path: NodePath = NodePath("../Turnmanager")
@export var launch_radius_min: float = 46.0
@export var launch_radius_max: float = 70.0
@export var launch_height: float = 0.35
@export var burst_height_min: float = 13.0
@export var burst_height_max: float = 22.0
@export var launch_interval: float = 0.2
@export var rockets_per_wave: int = 3
@export var default_duration: float = 6.0
@export var rocket_speed: float = 14.5
@export var rocket_acceleration: float = 11.0
@export var burst_particle_count: int = 22
@export var burst_speed_min: float = 3.6
@export var burst_speed_max: float = 8.6
@export var burst_gravity: float = 8.8
@export var drag: float = 0.82

const FIREWORK_COLORS := [
	Color(1.0, 0.56, 0.22, 1.0),
	Color(0.28, 0.72, 1.0, 1.0),
	Color(1.0, 0.34, 0.74, 1.0),
	Color(0.56, 1.0, 0.42, 1.0),
	Color(1.0, 0.88, 0.34, 1.0),
	Color(0.84, 0.58, 1.0, 1.0)
]

var celebration_active: bool = false
var celebration_time_left: float = 0.0
var launch_time_left: float = 0.0
var active_rockets: Array[Dictionary] = []
var active_particles: Array[Dictionary] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	var turn_manager: Node = get_node_or_null(turn_manager_path)
	if turn_manager != null and turn_manager.has_signal("game_finished"):
		turn_manager.game_finished.connect(_on_game_finished)
	set_process(true)


func _process(delta: float) -> void:
	_update_rockets(delta)
	_update_burst_particles(delta)

	if not celebration_active:
		return

	celebration_time_left = maxf(celebration_time_left - delta, 0.0)
	launch_time_left -= delta
	if launch_time_left <= 0.0:
		launch_time_left = launch_interval
		for _rocket_index in range(rockets_per_wave):
			_spawn_rocket()

	if celebration_time_left <= 0.0 and active_rockets.is_empty() and active_particles.is_empty():
		celebration_active = false


func play_celebration(duration: float = -1.0) -> void:
	celebration_active = true
	celebration_time_left = default_duration if duration <= 0.0 else duration
	launch_time_left = 0.0


func _on_game_finished(_winner_name: String) -> void:
	play_celebration()


func _spawn_rocket() -> void:
	var angle: float = rng.randf_range(0.0, TAU)
	var radius: float = rng.randf_range(launch_radius_min, launch_radius_max)
	var start_position := Vector3(cos(angle) * radius, launch_height, sin(angle) * radius)
	var burst_height: float = rng.randf_range(burst_height_min, burst_height_max)
	var burst_offset := Vector3(rng.randf_range(-10.0, 10.0), burst_height, rng.randf_range(-10.0, 10.0))
	var target_position := start_position + burst_offset
	var color: Color = FIREWORK_COLORS[rng.randi_range(0, FIREWORK_COLORS.size() - 1)]

	var rocket_root := Node3D.new()
	rocket_root.name = "FireworkRocket"
	rocket_root.position = start_position
	add_child(rocket_root)

	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.12
	core_mesh.height = 0.24
	core.mesh = core_mesh
	core.material_override = _make_unshaded_material(color, 2.2, 1.0)
	rocket_root.add_child(core)

	var trail := MeshInstance3D.new()
	trail.name = "Trail"
	var trail_mesh := CylinderMesh.new()
	trail_mesh.top_radius = 0.02
	trail_mesh.bottom_radius = 0.08
	trail_mesh.height = 1.6
	trail.mesh = trail_mesh
	trail.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	trail.position = Vector3(0.0, -0.7, 0.0)
	trail.material_override = _make_unshaded_material(Color(color.r, color.g, color.b, 0.48), 1.4, 0.46)
	rocket_root.add_child(trail)

	active_rockets.append({
		"node": rocket_root,
		"trail": trail,
		"velocity": (target_position - start_position).normalized() * rocket_speed,
		"target_position": target_position,
		"color": color
	})


func _update_rockets(delta: float) -> void:
	var survivors: Array[Dictionary] = []
	for rocket in active_rockets:
		var rocket_node: Node3D = rocket.get("node") as Node3D
		if rocket_node == null or not is_instance_valid(rocket_node):
			continue

		var velocity: Vector3 = rocket.get("velocity", Vector3.UP * rocket_speed)
		var target_position: Vector3 = rocket.get("target_position", rocket_node.position)
		var color: Color = rocket.get("color", Color.WHITE)

		velocity += Vector3.UP * rocket_acceleration * delta
		rocket_node.position += velocity * delta
		rocket["velocity"] = velocity

		var move_direction: Vector3 = velocity.normalized()
		if move_direction.length_squared() > 0.0001:
			rocket_node.look_at(rocket_node.position + move_direction, Vector3.UP)

		var trail: MeshInstance3D = rocket.get("trail") as MeshInstance3D
		if trail != null and is_instance_valid(trail):
			var trail_length: float = clampf(velocity.length() * 0.08, 1.2, 3.4)
			trail.scale = Vector3(1.0, trail_length / 1.6, 1.0)
			trail.position = Vector3(0.0, -trail_length * 0.44, 0.0)

		if rocket_node.position.y >= target_position.y or rocket_node.position.distance_to(target_position) < 1.2:
			_create_burst(target_position, color)
			rocket_node.queue_free()
			continue

		survivors.append(rocket)

	active_rockets = survivors


func _create_burst(origin: Vector3, color: Color) -> void:
	for particle_index in range(burst_particle_count):
		var direction := Vector3(
			rng.randf_range(-1.0, 1.0),
			rng.randf_range(-0.22, 1.0),
			rng.randf_range(-1.0, 1.0)
		).normalized()
		if direction.length_squared() <= 0.0001:
			direction = Vector3.UP

		var particle := MeshInstance3D.new()
		var particle_mesh := SphereMesh.new()
		particle_mesh.radius = 0.07 if particle_index % 4 != 0 else 0.11
		particle_mesh.height = particle_mesh.radius * 2.0
		particle.mesh = particle_mesh
		particle.position = origin
		var particle_color: Color = color.lerp(Color.WHITE, rng.randf_range(0.12, 0.35))
		particle.material_override = _make_unshaded_material(particle_color, rng.randf_range(1.6, 2.7), 1.0)
		add_child(particle)

		active_particles.append({
			"node": particle,
			"velocity": direction * rng.randf_range(burst_speed_min, burst_speed_max),
			"life": rng.randf_range(0.8, 1.35),
			"max_life": 1.35
		})


func _update_burst_particles(delta: float) -> void:
	var survivors: Array[Dictionary] = []
	for particle in active_particles:
		var node: MeshInstance3D = particle.get("node") as MeshInstance3D
		if node == null or not is_instance_valid(node):
			continue

		var velocity: Vector3 = particle.get("velocity", Vector3.ZERO)
		var life: float = float(particle.get("life", 0.0)) - delta
		var max_life: float = float(particle.get("max_life", 1.0))
		if life <= 0.0:
			node.queue_free()
			continue

		velocity.y -= burst_gravity * delta
		velocity *= pow(drag, delta * 8.0)
		node.position += velocity * delta
		particle["velocity"] = velocity
		particle["life"] = life

		var fade_ratio: float = clampf(life / max_life, 0.0, 1.0)
		node.scale = Vector3.ONE * lerpf(0.4, 1.0, fade_ratio)
		var material: StandardMaterial3D = node.material_override as StandardMaterial3D
		if material != null:
			var updated_material: StandardMaterial3D = material.duplicate() as StandardMaterial3D
			if updated_material != null:
				updated_material.albedo_color.a = fade_ratio
				updated_material.emission_energy_multiplier *= lerpf(0.35, 1.0, fade_ratio)
				node.material_override = updated_material

		survivors.append(particle)

	active_particles = survivors


func _make_unshaded_material(color: Color, emission_energy: float, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission_energy
	return material
