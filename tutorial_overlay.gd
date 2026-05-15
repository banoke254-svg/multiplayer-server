extends Node3D

@export_file("*.tscn") var main_scene_path: String = "res://main.tscn"
@export_file("*.tscn") var menu_scene_path: String = "res://Start_Menu.tscn"

const PLAYER_START := Vector3(0.0, 1.0, -10.2)
const TARGET_START := Vector3(0.0, 1.0, 2.8)
const TARGET_RESET := Vector3(0.0, 1.0, 2.8)
const HIDDEN_MARBLE_POS := Vector3(0.0, -35.0, 0.0)
const RESET_FALL_Y: float = -4.5
const READY_LINEAR_THRESHOLD: float = 0.08
const READY_ANGULAR_THRESHOLD: float = 0.08
const READY_DELAY: float = 0.45

const STEP_COPY := [
	"Drag backward to aim your marble.",
	"Release to take a shot.",
	"Hit the target marble in front of you.",
	"Now sink your marble into the hole.",
	"Tutorial complete. You are ready for a real match."
]

@onready var marbles_root: Node3D = $Marbles
@onready var player_marble: RigidBody3D = $Marbles/PlayerMarble
@onready var target_marble: RigidBody3D = $"Marbles/AI MARBLE1"
@onready var extra_marbles: Array[Node] = [
	$"Marbles/AI MARBLE2",
	$"Marbles/AI MARBLE3",
	$"Marbles/AI MARBLE4"
]
@onready var hole: Node3D = $Hole
@onready var tutorial_canvas: CanvasLayer = $UI
@onready var power_meter: Control = $UI/PowerMeter
@onready var camera_slider: Control = $UI/CameraControlUI
@onready var pause_ui: Node = $UI/PauseUI
@onready var game_hud: Control = $UI/GameHUD
@onready var turn_manager: Node = $Turnmanager
@onready var fireworks: Node = $FireworksCelebration

var tutorial_panel: Panel = null
var title_label: Label = null
var step_label: Label = null
var hint_label: Label = null
var progress_label: Label = null
var start_button: Button = null
var previous_button: Button = null
var primary_button: Button = null
var secondary_button: Button = null
var ghost_hand: TextureRect = null
var guide_arrow: TextureRect = null
var guide_tween: Tween = null
var arrow_tween: Tween = null

var current_step: int = 0
var aim_step_seen: bool = false
var shot_step_seen: bool = false
var target_hit: bool = false
var tutorial_complete: bool = false
var ready_timer: float = 0.0
var tutorial_started: bool = false


func _ready() -> void:
	_disable_match_systems()
	_prepare_tutorial_course()
	_build_tutorial_ui()
	_connect_tutorial_signals()
	_activate_player_camera()
	_update_step_ui()
	_start_tutorial()


func _physics_process(delta: float) -> void:
	if tutorial_complete:
		return

	_track_step_progress()
	_keep_tutorial_marbles_on_course()
	_restore_player_control_when_ready(delta)


func _disable_match_systems() -> void:
	if turn_manager != null:
		turn_manager.queue_free()

	if pause_ui != null:
		pause_ui.visible = false

	if game_hud != null:
		game_hud.visible = false

	if camera_slider != null:
		camera_slider.visible = true

	if power_meter != null:
		power_meter.visible = true


func _prepare_tutorial_course() -> void:
	_place_marble(player_marble, PLAYER_START)
	_place_marble(target_marble, TARGET_START)

	for marble_node in extra_marbles:
		var marble_body: RigidBody3D = marble_node as RigidBody3D
		if marble_body == null:
			continue
		_hide_unused_marble(marble_body)

	target_marble.freeze = false
	target_marble.sleeping = false
	target_marble.visible = true
	target_marble.collision_layer = 1
	target_marble.collision_mask = 1

	if player_marble.has_method("set_turn"):
		player_marble.call("set_turn", false, null)


func _build_tutorial_ui() -> void:
	tutorial_panel = Panel.new()
	tutorial_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	tutorial_panel.offset_left = -360.0
	tutorial_panel.offset_top = 96.0
	tutorial_panel.offset_right = -20.0
	tutorial_panel.offset_bottom = -120.0
	tutorial_panel.add_theme_stylebox_override("panel", _make_panel_style())
	tutorial_canvas.add_child(tutorial_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	tutorial_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)

	title_label = Label.new()
	title_label.text = "Guided Tutorial"
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	layout.add_child(title_label)

	progress_label = Label.new()
	progress_label.add_theme_font_size_override("font_size", 12)
	progress_label.add_theme_color_override("font_color", Color(0.76, 0.9, 1.0, 0.82))
	layout.add_child(progress_label)

	step_label = Label.new()
	step_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	step_label.add_theme_font_size_override("font_size", 15)
	step_label.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
	layout.add_child(step_label)

	hint_label = Label.new()
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.add_theme_font_size_override("font_size", 12)
	hint_label.add_theme_color_override("font_color", Color(0.8, 0.9, 0.98, 0.78))
	layout.add_child(hint_label)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 12)
	layout.add_child(button_row)

	start_button = Button.new()
	start_button.text = "Restart Tutorial"
	start_button.custom_minimum_size = Vector2(0, 42)
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_button.pressed.connect(_on_start_button_pressed)
	button_row.add_child(start_button)

	previous_button = Button.new()
	previous_button.text = "Previous Step"
	previous_button.custom_minimum_size = Vector2(0, 42)
	previous_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	previous_button.pressed.connect(_on_previous_button_pressed)
	button_row.add_child(previous_button)

	var nav_row: HBoxContainer = HBoxContainer.new()
	nav_row.add_theme_constant_override("separation", 12)
	layout.add_child(nav_row)

	primary_button = Button.new()
	primary_button.text = "Skip To Match"
	primary_button.custom_minimum_size = Vector2(0, 42)
	primary_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	primary_button.pressed.connect(_on_primary_button_pressed)
	nav_row.add_child(primary_button)

	secondary_button = Button.new()
	secondary_button.text = "Back To Menu"
	secondary_button.custom_minimum_size = Vector2(0, 42)
	secondary_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	secondary_button.pressed.connect(_on_secondary_button_pressed)
	nav_row.add_child(secondary_button)

	for button in [start_button, previous_button, primary_button, secondary_button]:
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))

	ghost_hand = TextureRect.new()
	ghost_hand.texture = _make_hand_texture()
	ghost_hand.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost_hand.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ghost_hand.custom_minimum_size = Vector2(90, 90)
	ghost_hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost_hand.modulate = Color(1.0, 1.0, 1.0, 0.72)
	tutorial_canvas.add_child(ghost_hand)

	guide_arrow = TextureRect.new()
	guide_arrow.texture = _make_arrow_texture()
	guide_arrow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	guide_arrow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	guide_arrow.custom_minimum_size = Vector2(96, 96)
	guide_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guide_arrow.modulate = Color(1.0, 0.86, 0.36, 0.96)
	tutorial_canvas.add_child(guide_arrow)


func _connect_tutorial_signals() -> void:
	if not player_marble.body_entered.is_connected(_on_player_body_entered):
		player_marble.body_entered.connect(_on_player_body_entered)


func _give_player_control() -> void:
	ready_timer = 0.0
	_activate_player_camera()
	if player_marble.has_method("start_turn"):
		player_marble.call("start_turn", null)
	elif player_marble.has_method("set_turn"):
		player_marble.call("set_turn", true, null)


func _track_step_progress() -> void:
	var dragging: bool = bool(player_marble.get("dragging"))
	var aim_power_ratio: float = float(player_marble.call("get_aim_power_ratio")) if player_marble.has_method("get_aim_power_ratio") else 0.0
	var player_velocity: float = player_marble.linear_velocity.length()

	if current_step == 0 and dragging and aim_power_ratio > 0.08:
		aim_step_seen = true
		_advance_step()
	elif current_step == 1 and not dragging and player_velocity > 0.35:
		shot_step_seen = true
		_advance_step()
	elif current_step == 2 and target_hit:
		_advance_step()
	elif current_step == 3 and _is_marble_in_hole(player_marble):
		_advance_step()


func _keep_tutorial_marbles_on_course() -> void:
	if player_marble.global_position.y < RESET_FALL_Y and not _is_marble_in_hole(player_marble):
		_place_marble(player_marble, PLAYER_START)
		_give_player_control()

	if target_marble.global_position.y < RESET_FALL_Y or target_marble.global_position.distance_to(HIDDEN_MARBLE_POS) < 0.1:
		_place_marble(target_marble, TARGET_RESET)


func _restore_player_control_when_ready(delta: float) -> void:
	if tutorial_complete or _is_marble_in_hole(player_marble):
		return

	var is_turn: bool = bool(player_marble.get("is_turn"))
	if is_turn:
		ready_timer = 0.0
		return

	if player_marble.linear_velocity.length() > READY_LINEAR_THRESHOLD or player_marble.angular_velocity.length() > READY_ANGULAR_THRESHOLD:
		ready_timer = 0.0
		return

	ready_timer += delta
	if ready_timer >= READY_DELAY:
		_give_player_control()


func _advance_step() -> void:
	current_step = mini(current_step + 1, STEP_COPY.size() - 1)
	if current_step >= STEP_COPY.size() - 1:
		_complete_tutorial()
	else:
		_update_step_ui()


func _complete_tutorial() -> void:
	tutorial_complete = true
	tutorial_started = false
	if player_marble.has_method("set_turn"):
		player_marble.call("set_turn", false, null)
	if fireworks != null and fireworks.has_method("play_celebration"):
		fireworks.call("play_celebration", 6.2)
	_stop_guide_tweens()
	if ghost_hand != null:
		ghost_hand.visible = false
	if guide_arrow != null:
		guide_arrow.visible = false
	_update_step_ui()
	primary_button.text = "Play Match"


func _update_step_ui() -> void:
	_stop_guide_tweens()
	var display_step: int = mini(current_step + 1, STEP_COPY.size())
	progress_label.text = "Step %d / %d" % [display_step, STEP_COPY.size()]
	step_label.text = STEP_COPY[current_step]
	if previous_button != null:
		previous_button.disabled = current_step <= 0
	if start_button != null:
		start_button.text = "Restart Tutorial" if tutorial_started or tutorial_complete else "Start Tutorial"

	match current_step:
		0:
			hint_label.text = "Pull downward on the screen to line up your shot."
			_show_drag_guide()
		1:
			hint_label.text = "Let go once you are aimed. Your marble will fire immediately."
			_show_release_guide()
		2:
			hint_label.text = "Hit the marble in the lane ahead of you. You can keep trying."
			_show_target_guide()
		3:
			hint_label.text = "Guide your next shot into the bowl at the far end of the course."
			_show_hole_guide()
		_:
			hint_label.text = "The course, camera, and shot controls now match the full game."
			if ghost_hand != null:
				ghost_hand.visible = false
			if guide_arrow != null:
				guide_arrow.visible = false


func _start_tutorial() -> void:
	tutorial_started = true
	tutorial_complete = false
	current_step = 0
	aim_step_seen = false
	shot_step_seen = false
	target_hit = false
	_prepare_tutorial_course()
	_give_player_control()
	_update_step_ui()


func _on_start_button_pressed() -> void:
	_start_tutorial()


func _on_previous_button_pressed() -> void:
	if current_step <= 0:
		return
	tutorial_complete = false
	current_step -= 1
	_prepare_tutorial_course()
	_give_player_control()
	_update_step_ui()


func _on_player_body_entered(body: Node) -> void:
	if tutorial_complete:
		return
	if body == target_marble:
		target_hit = true


func _on_primary_button_pressed() -> void:
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("stop_menu_music"):
		game_manager.call("stop_menu_music")
	if main_scene_path != "" and ResourceLoader.exists(main_scene_path):
		get_tree().change_scene_to_file(main_scene_path)


func _on_secondary_button_pressed() -> void:
	if menu_scene_path != "" and ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)


func _place_marble(marble: RigidBody3D, target_position: Vector3) -> void:
	marble.freeze = false
	marble.sleeping = false
	marble.visible = true
	marble.collision_layer = 1
	marble.collision_mask = 1
	marble.linear_velocity = Vector3.ZERO
	marble.angular_velocity = Vector3.ZERO
	marble.global_position = target_position
	marble.global_basis = Basis.IDENTITY


func _activate_player_camera() -> void:
	var follow_camera: Camera3D = player_marble.get_node_or_null("CameraRig/FollowCamera") as Camera3D
	if follow_camera != null:
		follow_camera.current = true
		follow_camera.make_current()


func _show_drag_guide() -> void:
	if ghost_hand == null or guide_arrow == null:
		return
	ghost_hand.visible = true
	guide_arrow.visible = true
	guide_arrow.rotation_degrees = 180.0
	guide_arrow.position = Vector2(760.0, 290.0)
	ghost_hand.position = Vector2(820.0, 330.0)

	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(ghost_hand, "position", Vector2(720.0, 430.0), 0.95)
	guide_tween.tween_property(ghost_hand, "position", Vector2(820.0, 330.0), 0.45)

	arrow_tween = create_tween()
	arrow_tween.set_loops()
	arrow_tween.tween_property(guide_arrow, "position:y", 320.0, 0.5)
	arrow_tween.tween_property(guide_arrow, "position:y", 290.0, 0.5)


func _show_release_guide() -> void:
	if ghost_hand == null or guide_arrow == null:
		return
	ghost_hand.visible = true
	guide_arrow.visible = true
	guide_arrow.rotation_degrees = 0.0
	guide_arrow.position = Vector2(720.0, 215.0)
	ghost_hand.position = Vector2(720.0, 430.0)

	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(ghost_hand, "modulate:a", 0.18, 0.26)
	guide_tween.tween_property(ghost_hand, "modulate:a", 0.72, 0.26)

	arrow_tween = create_tween()
	arrow_tween.set_loops()
	arrow_tween.tween_property(guide_arrow, "position:y", 180.0, 0.52)
	arrow_tween.tween_property(guide_arrow, "position:y", 215.0, 0.52)


func _show_target_guide() -> void:
	if ghost_hand != null:
		ghost_hand.visible = false
	if guide_arrow == null:
		return
	guide_arrow.visible = true
	guide_arrow.rotation_degrees = -28.0
	guide_arrow.position = Vector2(920.0, 280.0)

	arrow_tween = create_tween()
	arrow_tween.set_loops()
	arrow_tween.tween_property(guide_arrow, "position:y", 325.0, 0.55)
	arrow_tween.tween_property(guide_arrow, "position:y", 280.0, 0.55)


func _show_hole_guide() -> void:
	if ghost_hand != null:
		ghost_hand.visible = false
	if guide_arrow == null:
		return
	guide_arrow.visible = true
	guide_arrow.rotation_degrees = -8.0
	guide_arrow.position = Vector2(905.0, 210.0)

	arrow_tween = create_tween()
	arrow_tween.set_loops()
	arrow_tween.tween_property(guide_arrow, "position:y", 248.0, 0.55)
	arrow_tween.tween_property(guide_arrow, "position:y", 210.0, 0.55)


func _stop_guide_tweens() -> void:
	if guide_tween != null:
		guide_tween.kill()
		guide_tween = null
	if arrow_tween != null:
		arrow_tween.kill()
		arrow_tween = null


func _make_hand_texture() -> ImageTexture:
	var image: Image = Image.create(72, 72, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in range(72):
		for x in range(72):
			var uv: Vector2 = Vector2(x, y) / 71.0
			var palm: float = 1.0 if Vector2((uv.x - 0.5) / 0.18, (uv.y - 0.68) / 0.18).length() <= 1.0 else 0.0
			var finger: float = 1.0 if abs(uv.x - 0.5) < 0.06 and uv.y > 0.18 and uv.y < 0.68 else 0.0
			var thumb: float = 1.0 if Vector2((uv.x - 0.34) / 0.12, (uv.y - 0.54) / 0.08).length() <= 1.0 else 0.0
			var alpha: float = maxf(palm, maxf(finger, thumb))
			if alpha > 0.0:
				image.set_pixel(x, y, Color(0.92, 0.96, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _make_arrow_texture() -> ImageTexture:
	var image: Image = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in range(96):
		for x in range(96):
			var uv: Vector2 = Vector2(x, y) / 95.0
			var shaft: bool = abs(uv.x - 0.5) < 0.09 and uv.y > 0.28 and uv.y < 0.82
			var head: bool = uv.y <= 0.34 and abs(uv.x - 0.5) < (0.26 - uv.y * 0.55)
			if shaft or head:
				image.set_pixel(x, y, Color(1, 1, 1, 1))
	return ImageTexture.create_from_image(image)


func _hide_unused_marble(marble: RigidBody3D) -> void:
	marble.visible = false
	marble.freeze = true
	marble.sleeping = true
	marble.linear_velocity = Vector3.ZERO
	marble.angular_velocity = Vector3.ZERO
	marble.collision_layer = 0
	marble.collision_mask = 0
	marble.global_position = HIDDEN_MARBLE_POS


func _is_marble_in_hole(marble: Node3D) -> bool:
	if marble == null or hole == null:
		return false
	var local_position: Vector3 = hole.to_local(marble.global_position)
	var pocket_radius: float = float(hole.get("pocket_radius")) if hole.get("pocket_radius") != null else 1.0
	var depth: float = float(hole.get("depth")) if hole.get("depth") != null else 1.0
	var bottom_stop_lift: float = float(hole.get("bottom_stop_lift")) if hole.get("bottom_stop_lift") != null else 0.08
	var bottom_stop_height: float = float(hole.get("bottom_stop_height")) if hole.get("bottom_stop_height") != null else 0.18
	var bottom_touch_y: float = -depth + bottom_stop_lift + bottom_stop_height + 0.23
	var planar_distance: float = Vector2(local_position.x, local_position.z).length()
	return planar_distance <= pocket_radius * 0.88 and local_position.y <= bottom_touch_y


func _make_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.14, 0.2, 0.58)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.9, 0.98, 1.0, 0.24)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_right = 20
	style.corner_radius_bottom_left = 20
	style.shadow_color = Color(0.24, 0.72, 1.0, 0.18)
	style.shadow_size = 24
	style.anti_aliasing = true
	style.anti_aliasing_size = 1.4
	return style
