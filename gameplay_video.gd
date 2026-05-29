extends Node3D

const MENU_SCENE_PATH: String = "res://Start_Menu.tscn"
const MARBLE_SCENE: PackedScene = preload("res://marble.tscn")
const HOLE_SCRIPT: Script = preload("res://hole_bowl.gd")

const SEGMENT_SECONDS: float = 5.2
const FIELD_SIZE: float = 28.0

var camera: Camera3D
var player_marble: Node3D
var target_marble: Node3D
var hole: Node3D
var aim_root: Node3D
var power_root: Node3D
var turn_ring: MeshInstance3D
var target_ring: MeshInstance3D
var lesson_label: Label3D
var detail_label: Label3D
var back_label: Label3D
var hand_pointer: Node3D
var elapsed: float = 0.0
var segment_index: int = -1
var segment_time: float = 0.0


func _ready() -> void:
	_build_world()
	_apply_segment(0)
	set_process(true)


func _process(delta: float) -> void:
	elapsed += delta
	segment_time += delta
	var next_index: int = int(floor(elapsed / SEGMENT_SECONDS)) % 6
	if next_index != segment_index:
		_apply_segment(next_index)
	_update_segment(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_back_to_menu()
	elif event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_ENTER:
		_go_back_to_menu()
	elif event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		if _is_back_corner((event as InputEventScreenTouch).position):
			_go_back_to_menu()
	elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		if _is_back_corner((event as InputEventMouseButton).position):
			_go_back_to_menu()


func _go_back_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)


func _is_back_corner(screen_position: Vector2) -> bool:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	return screen_position.x <= viewport_size.x * 0.22 and screen_position.y <= viewport_size.y * 0.22


func _build_world() -> void:
	_build_environment()
	_build_field()
	_build_hole()
	_build_marbles()
	_build_guides()
	_build_hand_pointer()
	_build_camera()


func _build_environment() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.31, 0.56, 0.84, 1.0)
	sky_material.sky_horizon_color = Color(0.8, 0.9, 0.97, 1.0)
	var sky := Sky.new()
	sky.sky_material = sky_material
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_color = Color(0.74, 0.82, 0.9, 1.0)
	env.ambient_light_energy = 0.8
	env.glow_enabled = true
	env.glow_intensity = 0.035
	environment.environment = env
	add_child(environment)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_energy = 2.1
	sun.rotation_degrees = Vector3(-45.0, -38.0, 0.0)
	add_child(sun)

	var fill := OmniLight3D.new()
	fill.name = "FillLight"
	fill.light_energy = 1.2
	fill.omni_range = 20.0
	fill.position = Vector3(-4.0, 6.0, 5.0)
	add_child(fill)


func _build_field() -> void:
	var ground := StaticBody3D.new()
	ground.name = "VideoField"
	add_child(ground)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(FIELD_SIZE, 0.1, FIELD_SIZE)
	mesh.material = _make_material(Color(0.27, 0.58, 0.26, 1.0), 0.88, 0.0)
	mesh_instance.mesh = mesh
	ground.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(FIELD_SIZE, 0.1, FIELD_SIZE)
	collision.shape = shape
	ground.add_child(collision)

	for offset in [Vector3(0.0, 0.65, -FIELD_SIZE * 0.5), Vector3(0.0, 0.65, FIELD_SIZE * 0.5)]:
		_add_wall(offset, Vector3(FIELD_SIZE, 1.3, 0.55))
	for offset in [Vector3(-FIELD_SIZE * 0.5, 0.65, 0.0), Vector3(FIELD_SIZE * 0.5, 0.65, 0.0)]:
		_add_wall(offset, Vector3(0.55, 1.3, FIELD_SIZE))


func _add_wall(position_value: Vector3, size_value: Vector3) -> void:
	var wall := StaticBody3D.new()
	wall.position = position_value
	add_child(wall)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size_value
	mesh.material = _make_material(Color(0.035, 0.07, 0.075, 1.0), 0.78, 0.0)
	mesh_instance.mesh = mesh
	wall.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size_value
	collision.shape = shape
	wall.add_child(collision)


func _build_hole() -> void:
	hole = StaticBody3D.new()
	hole.name = "Hole"
	hole.set_script(HOLE_SCRIPT)
	hole.position = Vector3(0.0, 0.02, -5.2)
	add_child(hole)
	hole.set("entry_radius", 1.52)
	hole.set("pocket_radius", 1.02)
	hole.set("depth", 1.02)


func _build_marbles() -> void:
	player_marble = _make_marble("PlayerMarble", Vector3(-5.4, 0.48, 5.2), Color(0.22, 0.88, 1.0, 1.0))
	target_marble = _make_marble("OpponentMarble", Vector3(2.8, 0.48, 0.4), Color(1.0, 0.62, 0.18, 1.0))


func _make_marble(node_name: String, position_value: Vector3, accent: Color) -> Node3D:
	var marble: Node3D = MARBLE_SCENE.instantiate() as Node3D
	marble.name = node_name
	marble.position = position_value
	add_child(marble)
	if marble is RigidBody3D:
		var body := marble as RigidBody3D
		body.freeze = true
		body.sleeping = true
	var visual := marble.get_node_or_null("GlassBallModel")
	if visual != null and visual.has_method("set_palette"):
		visual.call("set_palette", {
			"shell_base_color": Color(accent.r, accent.g, accent.b, 0.25),
			"shell_swirl_blue": accent,
			"shell_swirl_orange": accent.lightened(0.28),
			"core_color": accent
		})
	return marble


func _build_guides() -> void:
	aim_root = Node3D.new()
	aim_root.name = "AimGuide"
	add_child(aim_root)
	for index in range(8):
		var segment := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.09
		mesh.bottom_radius = 0.09
		mesh.height = 0.68
		mesh.radial_segments = 16
		mesh.material = _make_emissive_material(Color(0.26, 1.0, 0.82, 0.78), 1.7)
		segment.mesh = mesh
		aim_root.add_child(segment)

	power_root = Node3D.new()
	power_root.name = "PowerGuide"
	add_child(power_root)
	for index in range(7):
		var bar := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.24, 0.24, 0.24)
		mesh.material = _make_emissive_material(Color(1.0, 0.75, 0.22, 1.0), 1.25)
		bar.mesh = mesh
		power_root.add_child(bar)

	turn_ring = _make_ring(Color(0.34, 1.0, 0.66, 1.0))
	target_ring = _make_ring(Color(1.0, 0.38, 0.2, 1.0))
	add_child(turn_ring)
	add_child(target_ring)

	lesson_label = _make_label("AIM", Vector3(0.0, 3.2, 4.0), 44)
	detail_label = _make_label("Hold, pull, release.", Vector3(0.0, 2.45, 4.0), 22)
	back_label = _make_label("TAP TOP LEFT / ESC: MENU", Vector3(-6.6, 2.3, 7.0), 16)
	add_child(lesson_label)
	add_child(detail_label)
	add_child(back_label)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "VideoCamera"
	camera.fov = 48.0
	add_child(camera)
	camera.current = true


func _build_hand_pointer() -> void:
	hand_pointer = Node3D.new()
	hand_pointer.name = "HandPointer"
	add_child(hand_pointer)

	var palm := MeshInstance3D.new()
	var palm_mesh := SphereMesh.new()
	palm_mesh.radius = 0.24
	palm_mesh.height = 0.28
	palm_mesh.material = _make_emissive_material(Color(0.97, 0.9, 0.74, 1.0), 0.45)
	palm.mesh = palm_mesh
	hand_pointer.add_child(palm)

	var finger := MeshInstance3D.new()
	var finger_mesh := CylinderMesh.new()
	finger_mesh.top_radius = 0.07
	finger_mesh.bottom_radius = 0.09
	finger_mesh.height = 0.62
	finger_mesh.radial_segments = 16
	finger_mesh.material = _make_emissive_material(Color(1.0, 0.95, 0.8, 1.0), 0.5)
	finger.mesh = finger_mesh
	finger.position = Vector3(0.0, -0.38, 0.0)
	hand_pointer.add_child(finger)


func _apply_segment(index: int) -> void:
	segment_index = index
	segment_time = 0.0
	player_marble.visible = true
	target_marble.visible = true
	turn_ring.visible = true
	target_ring.visible = true
	aim_root.visible = true
	power_root.visible = true
	if hand_pointer != null:
		hand_pointer.visible = true

	match index:
		0:
			_set_title("TURN + AIMING", "The green ring shows whose turn it is. Drag left or right to choose the line.")
			_reset_positions(Vector3(-5.4, 0.48, 5.2), Vector3(2.8, 0.48, 0.4))
		1:
			_set_title("POWER", "Small pull means soft touch. Bigger pull means stronger shot.")
			_reset_positions(Vector3(-5.4, 0.48, 5.2), Vector3(2.8, 0.48, 0.4))
		2:
			_set_title("SHOOTING", "Release when the line and power are right.")
			_reset_positions(Vector3(-5.4, 0.48, 5.2), Vector3(2.8, 0.48, 0.4))
		3:
			_set_title("THE HOLE", "Sink your marble to earn the attack turn from the pocket.")
			_reset_positions(Vector3(-3.8, 0.48, 2.5), Vector3(3.1, 0.48, 0.4))
		4:
			_set_title("ELIMINATION", "Hit an opponent, then finish the hole play to knock them out.")
			_reset_positions(Vector3(-4.2, 0.48, 3.4), Vector3(-0.3, 0.48, -1.1))
		_:
			_set_title("WIN OR LOSE", "The last marble standing wins. Disqualified players can watch or leave.")
			_reset_positions(Vector3(-0.9, 0.48, -4.9), Vector3(4.5, 0.48, 2.0))


func _update_segment(delta: float) -> void:
	var t: float = clampf(segment_time / SEGMENT_SECONDS, 0.0, 1.0)
	var pulse: float = 0.5 + 0.5 * sin(elapsed * 5.5)
	match segment_index:
		0:
			var yaw := sin(t * TAU) * 0.58
			_update_aim_line(player_marble.global_position, Vector3.FORWARD.rotated(Vector3.UP, yaw), 4.8)
			_update_power_bars(0.35 + pulse * 0.1)
			_update_hand_pointer(player_marble.global_position + Vector3(sin(t * TAU) * 1.35, 1.35, 1.0), Vector3(0.0, 0.0, -1.0), 0.92 + pulse * 0.12)
		1:
			_update_aim_line(player_marble.global_position, Vector3(0.42, 0.0, -1.0).normalized(), 4.8)
			_update_power_bars(absf(sin(t * PI)))
			_update_hand_pointer(player_marble.global_position + Vector3(-1.8, 0.9 + sin(t * TAU) * 1.15, 0.1), Vector3.DOWN, 0.95)
		2:
			_animate_marble(player_marble, Vector3(-5.4, 0.48, 5.2), Vector3(0.6, 0.48, -0.6), smoothstep(0.18, 0.82, t))
			_update_aim_line(player_marble.global_position, Vector3(0.58, 0.0, -1.0).normalized(), 4.8)
			_update_power_bars(0.72)
			_update_hand_pointer(player_marble.global_position + Vector3(-0.8 + t * 2.0, 1.1, 0.6 - t * 1.8), Vector3(0.58, 0.0, -1.0), 0.9)
		3:
			_animate_marble(player_marble, Vector3(-3.8, 0.48, 2.5), Vector3(0.0, -0.72, -5.2), smoothstep(0.12, 0.86, t))
			_update_aim_line(player_marble.global_position, Vector3(0.42, 0.0, -1.0).normalized(), 3.6)
			_update_power_bars(0.55)
			_update_hand_pointer(player_marble.global_position + Vector3(-0.7, 1.1, 0.6), Vector3(0.42, 0.0, -1.0), 0.84)
		4:
			var hit_t: float = smoothstep(0.05, 0.48, t)
			_animate_marble(player_marble, Vector3(-4.2, 0.48, 3.4), Vector3(-0.3, 0.48, -1.1), hit_t)
			if t > 0.45:
				_animate_marble(target_marble, Vector3(-0.3, 0.48, -1.1), Vector3(5.8, 0.48, -3.2), smoothstep(0.45, 0.86, t))
				target_ring.visible = t < 0.82
				target_marble.visible = t < 0.9
			_update_aim_line(player_marble.global_position, Vector3(0.58, 0.0, -1.0).normalized(), 4.4)
			_update_power_bars(0.84)
			_update_hand_pointer(player_marble.global_position + Vector3(-0.4, 1.2, 0.45), Vector3(0.58, 0.0, -1.0), 0.86)
		_:
			target_marble.visible = t < 0.38
			target_ring.visible = false
			turn_ring.visible = true
			player_marble.rotation.y += delta * 1.4
			_update_aim_line(player_marble.global_position, Vector3.ZERO, 0.0)
			_update_power_bars(0.0)
			if hand_pointer != null:
				hand_pointer.visible = false
	_update_rings()
	_update_camera(t)


func _reset_positions(player_pos: Vector3, target_pos: Vector3) -> void:
	player_marble.global_position = player_pos
	target_marble.global_position = target_pos
	player_marble.rotation = Vector3.ZERO
	target_marble.rotation = Vector3.ZERO


func _animate_marble(marble: Node3D, from_pos: Vector3, to_pos: Vector3, amount: float) -> void:
	var eased: float = clampf(amount, 0.0, 1.0)
	marble.global_position = from_pos.lerp(to_pos, eased)
	marble.rotate_x(0.08 + eased * 0.08)


func _update_aim_line(origin: Vector3, direction: Vector3, length_value: float) -> void:
	if direction.length_squared() <= 0.0001 or length_value <= 0.01:
		aim_root.visible = false
		return
	aim_root.visible = true
	var normalized_direction := direction.normalized()
	for index in range(aim_root.get_child_count()):
		var segment := aim_root.get_child(index) as MeshInstance3D
		var segment_pos := origin + normalized_direction * (0.8 + float(index) * length_value / 8.0) + Vector3.UP * 0.16
		segment.global_position = segment_pos
		segment.global_transform.basis = _basis_from_y(normalized_direction)


func _update_power_bars(power: float) -> void:
	power_root.visible = power > 0.02
	for index in range(power_root.get_child_count()):
		var bar := power_root.get_child(index) as MeshInstance3D
		var active: bool = float(index + 1) / float(power_root.get_child_count()) <= power
		bar.visible = active
		bar.global_position = player_marble.global_position + Vector3(-1.25, 0.24 + float(index) * 0.32, 0.0)
		bar.scale = Vector3(1.0, 1.0 + power * 0.8, 1.0)


func _update_hand_pointer(position_value: Vector3, direction: Vector3, scale_value: float) -> void:
	if hand_pointer == null:
		return
	hand_pointer.visible = true
	hand_pointer.global_position = position_value
	var clean_direction: Vector3 = direction
	if clean_direction.length_squared() <= 0.001:
		clean_direction = Vector3.DOWN
	hand_pointer.global_transform.basis = _basis_from_y(clean_direction.normalized())
	hand_pointer.scale = Vector3.ONE * scale_value


func _update_rings() -> void:
	turn_ring.global_position = player_marble.global_position + Vector3(0.0, 0.03, 0.0)
	target_ring.global_position = target_marble.global_position + Vector3(0.0, 0.03, 0.0)
	turn_ring.rotation.y = elapsed * 1.8
	target_ring.rotation.y = -elapsed * 1.5


func _update_camera(t: float) -> void:
	var target_pos: Vector3 = player_marble.global_position.lerp(hole.global_position, 0.28)
	var angle: float = -0.46 + sin(elapsed * 0.18) * 0.08
	var distance: float = 11.5
	var height: float = 6.2
	var desired_pos := target_pos + Vector3(sin(angle) * distance, height, cos(angle) * distance)
	camera.global_position = camera.global_position.lerp(desired_pos, 0.08 if t > 0.02 else 1.0)
	camera.look_at(target_pos + Vector3.UP * 0.55, Vector3.UP)


func _set_title(title: String, detail: String) -> void:
	lesson_label.text = title
	detail_label.text = detail


func _make_label(text_value: String, position_value: Vector3, size_value: int) -> Label3D:
	var label := Label3D.new()
	label.text = text_value
	label.position = position_value
	label.font_size = size_value
	label.outline_size = 8
	label.modulate = Color(0.95, 1.0, 0.98, 1.0)
	label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	return label


func _make_ring(color_value: Color) -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.48
	torus.outer_radius = 0.54
	torus.ring_segments = 48
	torus.sides = 8
	torus.material = _make_emissive_material(color_value, 1.3)
	ring.mesh = torus
	return ring


func _make_material(color_value: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color_value
	material.roughness = roughness
	material.metallic = metallic
	return material


func _make_emissive_material(color_value: Color, energy: float) -> StandardMaterial3D:
	var material := _make_material(color_value, 0.22, 0.0)
	material.emission_enabled = true
	material.emission = Color(color_value.r, color_value.g, color_value.b, 1.0)
	material.emission_energy_multiplier = energy
	return material


func _basis_from_y(direction: Vector3) -> Basis:
	var y_axis := direction.normalized()
	var x_axis := Vector3.UP.cross(y_axis)
	if x_axis.length_squared() <= 0.0001:
		x_axis = Vector3.RIGHT
	x_axis = x_axis.normalized()
	var z_axis := x_axis.cross(y_axis).normalized()
	return Basis(x_axis, y_axis, z_axis)
