extends Node3D

@export var player_marble_path: NodePath
@export var indicator_mesh: MeshInstance3D
@export var max_indicator_length: float = 5.0
@export var aim_sensitivity: float = 0.005

var player_marble: Node3D
var aiming := false
var aim_yaw := 0.0
var last_touch_pos := Vector2.ZERO
var start_touch_pos := Vector2.ZERO
var player_turn := true

func _ready():
	if player_marble_path != NodePath(""):
		player_marble = get_node(player_marble_path)

	if indicator_mesh:
		var mat := StandardMaterial3D.new()
		mat.flags_unshaded = true
		mat.emission_enabled = true
		mat.emission_energy = 5.0  # Bright

		# Kenyan flag stripes (solid, clean separation)
		var gradient := Gradient.new()
		gradient.add_point(0.0, Color.BLACK)         # Black
		gradient.add_point(0.20, Color.BLACK)
		gradient.add_point(0.21, Color.WHITE)        # White
		gradient.add_point(0.30, Color.WHITE)
		gradient.add_point(0.31, Color.RED)          # Red
		gradient.add_point(0.70, Color.RED)
		gradient.add_point(0.71, Color.WHITE)        # White
		gradient.add_point(0.80, Color.WHITE)
		gradient.add_point(0.81, Color(0, 0.5, 0))   # Green
		gradient.add_point(1.0, Color(0, 0.5, 0))

		var tex := GradientTexture1D.new()
		tex.gradient = gradient

		# Apply texture so it maps cleanly along Z axis only
		mat.albedo_texture = tex
		mat.emission_texture = tex
		mat.uv1_offset = Vector3(0, 0, 0)
		mat.uv1_scale = Vector3(1, 1, 1)  # No repetition, no mixing

		indicator_mesh.material_override = mat

	hide()

func _unhandled_input(event):
	if not player_turn:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			aiming = true
			last_touch_pos = event.position
			start_touch_pos = event.position
			show()
		else:
			aiming = false
			hide()
	elif event is InputEventScreenDrag and aiming:
		var delta = event.position - last_touch_pos
		last_touch_pos = event.position
		aim_yaw += delta.x * aim_sensitivity

func _process(delta):
	if aiming and player_turn and player_marble:
		var aim_dir = Vector3.FORWARD.rotated(Vector3.UP, aim_yaw).normalized()
		var drag_distance = start_touch_pos.distance_to(last_touch_pos)
		var length = clamp(drag_distance / 100.0, 0.1, max_indicator_length)

		# Place indicator ahead of marble
		global_transform.origin = player_marble.global_transform.origin - (aim_dir * (length * 0.5))
		look_at(global_transform.origin + aim_dir, Vector3.UP)

		if indicator_mesh:
			indicator_mesh.scale = Vector3(0.1, 0.1, length)

func on_player_shot():
	player_turn = false
	aiming = false
	hide()

func on_player_turn_start():
	player_turn = true
