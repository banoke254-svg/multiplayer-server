extends Node3D

@export_file("*.tscn") var main_scene_path: String = "res://main.tscn"
@export_file("*.tscn") var menu_scene_path: String = "res://Start_Menu.tscn"

const TUTORIAL_HAND_TEXTURE_PATH: String = "res://ui/tutorial_hand.png"
const GUIDE_HAND_SIZE := Vector2(170.0, 220.0)
const GUIDE_HAND_TOUCH_OFFSET := Vector2(39.0, 33.0)
const SHOOTING_MECHANIC_DRAG: String = "drag"
const SHOOTING_MECHANIC_SPLIT: String = "split"
const SHOOTING_MECHANIC_PRESS: String = "press"
const PLAYER_START := Vector3(0.0, 1.0, -10.2)
const TARGET_START := Vector3(0.0, 1.0, 2.8)
const TARGET_RESET := Vector3(0.0, 1.0, 2.8)
const HIDDEN_MARBLE_POS := Vector3(0.0, -35.0, 0.0)
const HOLE_COVER_SIZE := Vector3(4.7, 0.08, 4.7)
const RESET_FALL_Y: float = -4.5
const READY_LINEAR_THRESHOLD: float = 0.08
const READY_ANGULAR_THRESHOLD: float = 0.08
const READY_DELAY: float = 0.45

const COMMON_STEP_TARGET: String = "Hit the target marble in front of you."
const COMMON_STEP_HOLE: String = "Now sink your marble into the hole."
const COMMON_STEP_DONE: String = "Tutorial complete. You are ready for a real match."

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
var second_ghost_hand: TextureRect = null
var guide_arrow: TextureRect = null
var guide_tween: Tween = null
var second_guide_tween: Tween = null
var arrow_tween: Tween = null
var shooting_mechanic: String = SHOOTING_MECHANIC_DRAG
var hole_cover: StaticBody3D = null
var completion_panel: Panel = null
var completion_label: Label = null
var completion_tween: Tween = null

var current_step: int = 0
var aim_step_seen: bool = false
var shot_step_seen: bool = false
var target_hit: bool = false
var tutorial_complete: bool = false
var ready_timer: float = 0.0
var tutorial_started: bool = false
var step_transitioning: bool = false
var tutorial_hole_capture_active: bool = false


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
	if step_transitioning:
		_update_live_guide()
		_hide_split_control_names()
		_remove_tutorial_name_tags()
		return

	_track_step_progress()
	_update_live_guide()
	_hide_split_control_names()
	_remove_tutorial_name_tags()
	_keep_tutorial_marbles_on_course()
	_assist_player_into_tutorial_hole(delta)
	_restore_player_control_when_ready(delta)


func _disable_match_systems() -> void:
	if turn_manager != null:
		turn_manager.queue_free()
		call_deferred("_remove_tutorial_name_tags")

	_remove_tutorial_name_tags()

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
	tutorial_panel.name = "TutorialPanel"
	tutorial_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	tutorial_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	tutorial_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	tutorial_panel.offset_left = -292.0
	tutorial_panel.offset_top = 46.0
	tutorial_panel.offset_right = -18.0
	tutorial_panel.offset_bottom = -302.0
	tutorial_panel.add_theme_stylebox_override("panel", _make_panel_style())
	tutorial_canvas.add_child(tutorial_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	tutorial_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.mouse_filter = Control.MOUSE_FILTER_PASS
	layout.add_theme_constant_override("separation", 5)
	margin.add_child(layout)

	title_label = Label.new()
	title_label.text = "Guided Tutorial"
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	layout.add_child(title_label)

	progress_label = Label.new()
	progress_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_label.add_theme_font_size_override("font_size", 11)
	progress_label.add_theme_color_override("font_color", Color(0.76, 0.9, 1.0, 0.82))
	layout.add_child(progress_label)

	step_label = Label.new()
	step_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	step_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	step_label.add_theme_font_size_override("font_size", 13)
	step_label.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
	layout.add_child(step_label)

	hint_label = Label.new()
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.add_theme_font_size_override("font_size", 11)
	hint_label.add_theme_color_override("font_color", Color(0.8, 0.9, 0.98, 0.78))
	layout.add_child(hint_label)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.mouse_filter = Control.MOUSE_FILTER_PASS
	button_row.add_theme_constant_override("separation", 8)
	layout.add_child(button_row)

	start_button = Button.new()
	start_button.process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.text = "Restart"
	start_button.mouse_filter = Control.MOUSE_FILTER_STOP
	start_button.custom_minimum_size = Vector2(0, 34)
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_button.pressed.connect(_on_start_button_pressed)
	button_row.add_child(start_button)

	previous_button = Button.new()
	previous_button.process_mode = Node.PROCESS_MODE_ALWAYS
	previous_button.text = "Previous"
	previous_button.mouse_filter = Control.MOUSE_FILTER_STOP
	previous_button.custom_minimum_size = Vector2(0, 34)
	previous_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	previous_button.pressed.connect(_on_previous_button_pressed)
	button_row.add_child(previous_button)

	var nav_row: HBoxContainer = HBoxContainer.new()
	nav_row.mouse_filter = Control.MOUSE_FILTER_PASS
	nav_row.add_theme_constant_override("separation", 8)
	layout.add_child(nav_row)

	primary_button = Button.new()
	primary_button.process_mode = Node.PROCESS_MODE_ALWAYS
	primary_button.text = "Match"
	primary_button.mouse_filter = Control.MOUSE_FILTER_STOP
	primary_button.custom_minimum_size = Vector2(0, 34)
	primary_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	primary_button.pressed.connect(_on_primary_button_pressed)
	nav_row.add_child(primary_button)

	secondary_button = Button.new()
	secondary_button.process_mode = Node.PROCESS_MODE_ALWAYS
	secondary_button.text = "Menu"
	secondary_button.mouse_filter = Control.MOUSE_FILTER_STOP
	secondary_button.custom_minimum_size = Vector2(0, 34)
	secondary_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	secondary_button.pressed.connect(_on_secondary_button_pressed)
	nav_row.add_child(secondary_button)

	for button in [start_button, previous_button, primary_button, secondary_button]:
		button.add_theme_font_size_override("font_size", 12)
		button.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))

	ghost_hand = TextureRect.new()
	ghost_hand.texture = _load_tutorial_hand_texture()
	ghost_hand.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost_hand.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ghost_hand.custom_minimum_size = GUIDE_HAND_SIZE
	ghost_hand.size = GUIDE_HAND_SIZE
	ghost_hand.pivot_offset = GUIDE_HAND_TOUCH_OFFSET
	ghost_hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost_hand.modulate = Color(1.0, 1.0, 1.0, 0.86)
	tutorial_canvas.add_child(ghost_hand)

	second_ghost_hand = TextureRect.new()
	second_ghost_hand.texture = ghost_hand.texture
	second_ghost_hand.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	second_ghost_hand.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	second_ghost_hand.custom_minimum_size = GUIDE_HAND_SIZE
	second_ghost_hand.size = GUIDE_HAND_SIZE
	second_ghost_hand.pivot_offset = GUIDE_HAND_TOUCH_OFFSET
	second_ghost_hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	second_ghost_hand.modulate = Color(1.0, 1.0, 1.0, 0.78)
	second_ghost_hand.visible = false
	tutorial_canvas.add_child(second_ghost_hand)

	guide_arrow = TextureRect.new()
	guide_arrow.texture = _make_arrow_texture()
	guide_arrow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	guide_arrow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	guide_arrow.custom_minimum_size = Vector2(96, 96)
	guide_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guide_arrow.modulate = Color(1.0, 0.86, 0.36, 0.96)
	guide_arrow.visible = false
	tutorial_canvas.add_child(guide_arrow)

	completion_panel = Panel.new()
	completion_panel.name = "TutorialCompletionMessage"
	completion_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	completion_panel.set_anchors_preset(Control.PRESET_CENTER)
	completion_panel.offset_left = -145.0
	completion_panel.offset_top = -44.0
	completion_panel.offset_right = 145.0
	completion_panel.offset_bottom = 44.0
	completion_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	completion_panel.visible = false
	completion_panel.add_theme_stylebox_override("panel", _make_completion_style())
	tutorial_canvas.add_child(completion_panel)

	var completion_margin: MarginContainer = MarginContainer.new()
	completion_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	completion_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	completion_margin.add_theme_constant_override("margin_left", 18)
	completion_margin.add_theme_constant_override("margin_top", 14)
	completion_margin.add_theme_constant_override("margin_right", 18)
	completion_margin.add_theme_constant_override("margin_bottom", 14)
	completion_panel.add_child(completion_margin)

	completion_label = Label.new()
	completion_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	completion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	completion_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	completion_label.add_theme_font_size_override("font_size", 18)
	completion_label.add_theme_color_override("font_color", Color(0.98, 1.0, 0.9, 1.0))
	completion_margin.add_child(completion_label)


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
	var mechanic: String = _get_selected_shooting_mechanic()
	var dragging: bool = bool(player_marble.get("dragging"))
	var split_aiming: bool = bool(player_marble.get("split_aiming"))
	var split_shooting: bool = bool(player_marble.get("split_shooting"))
	var press_aiming: bool = bool(player_marble.get("press_aiming"))
	var press_charging: bool = bool(player_marble.get("press_charging"))
	var aim_power_ratio: float = float(player_marble.call("get_aim_power_ratio")) if player_marble.has_method("get_aim_power_ratio") else 0.0
	var player_velocity: float = player_marble.linear_velocity.length()

	if current_step == 0:
		match mechanic:
			SHOOTING_MECHANIC_SPLIT:
				if split_aiming:
					aim_step_seen = true
					_advance_step()
			SHOOTING_MECHANIC_PRESS:
				if press_aiming:
					aim_step_seen = true
					_advance_step()
			_:
				if dragging and aim_power_ratio > 0.08:
					aim_step_seen = true
					_advance_step()
	elif current_step == 1:
		match mechanic:
			SHOOTING_MECHANIC_SPLIT:
				if split_shooting and aim_power_ratio > 0.08:
					shot_step_seen = true
				elif shot_step_seen and not split_shooting:
					_advance_step()
			SHOOTING_MECHANIC_PRESS:
				if press_charging and aim_power_ratio > 0.08:
					shot_step_seen = true
				elif shot_step_seen and not press_charging:
					_advance_step()
			_:
				if not dragging and player_velocity > 0.35:
					shot_step_seen = true
					_advance_step()
	elif current_step == 2 and _is_target_step_complete():
		_advance_step()
	elif current_step == 3 and _is_hole_step_complete():
		_advance_step()


func _keep_tutorial_marbles_on_course() -> void:
	if player_marble.global_position.y < RESET_FALL_Y and not _is_marble_in_hole(player_marble):
		_place_marble(player_marble, PLAYER_START)
		_give_player_control()

	if _is_target_marble_needed() and (target_marble.global_position.y < RESET_FALL_Y or target_marble.global_position.distance_to(HIDDEN_MARBLE_POS) < 0.1):
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
	if step_transitioning:
		return
	step_transitioning = true
	_show_completion_message("Step Complete", 0.52)
	await get_tree().create_timer(0.48).timeout
	var step_copy: Array[String] = _get_step_copy_for_mechanic(_get_selected_shooting_mechanic())
	current_step = mini(current_step + 1, step_copy.size() - 1)
	_reset_progress_for_current_step()
	if current_step >= step_copy.size() - 1:
		_complete_tutorial()
	else:
		_update_step_ui()
		_animate_tutorial_panel_in()
	step_transitioning = false


func _complete_tutorial() -> void:
	tutorial_complete = true
	tutorial_started = false
	step_transitioning = false
	if player_marble.has_method("set_turn"):
		player_marble.call("set_turn", false, null)
	if fireworks != null and fireworks.has_method("play_celebration"):
		fireworks.call("play_celebration", 6.2)
	_stop_guide_tweens()
	if ghost_hand != null:
		ghost_hand.visible = false
	if second_ghost_hand != null:
		second_ghost_hand.visible = false
	if guide_arrow != null:
		guide_arrow.visible = false
	_update_step_ui()
	primary_button.text = "Play Match"
	_show_completion_message("Tutorial Complete", 1.6)


func _update_step_ui() -> void:
	_stop_guide_tweens()
	shooting_mechanic = _get_selected_shooting_mechanic()
	var step_copy: Array[String] = _get_step_copy_for_mechanic(shooting_mechanic)
	var display_step: int = mini(current_step + 1, step_copy.size())
	progress_label.text = "Step %d / %d" % [display_step, step_copy.size()]
	step_label.text = step_copy[current_step]
	_apply_step_scene_state()
	if previous_button != null:
		previous_button.disabled = current_step <= 0
	if start_button != null:
		start_button.text = "Restart" if tutorial_started or tutorial_complete else "Start"

	match current_step:
		0:
			hint_label.text = _get_aim_hint_for_mechanic(shooting_mechanic)
			_show_aim_guide()
		1:
			hint_label.text = _get_shoot_hint_for_mechanic(shooting_mechanic)
			_show_shoot_guide()
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
			if second_ghost_hand != null:
				second_ghost_hand.visible = false
			if guide_arrow != null:
				guide_arrow.visible = false


func _start_tutorial() -> void:
	step_transitioning = false
	tutorial_started = true
	tutorial_complete = false
	_hide_completion_message()
	shooting_mechanic = _get_selected_shooting_mechanic()
	current_step = 0
	_reset_progress_for_current_step()
	_prepare_tutorial_course()
	_give_player_control()
	_update_step_ui()


func _on_start_button_pressed() -> void:
	_start_tutorial()


func _on_previous_button_pressed() -> void:
	if current_step <= 0:
		return
	step_transitioning = false
	tutorial_complete = false
	_hide_completion_message()
	current_step -= 1
	_reset_progress_for_current_step()
	_prepare_tutorial_course()
	_give_player_control()
	_update_step_ui()


func _on_player_body_entered(body: Node) -> void:
	if tutorial_complete:
		return
	if body == target_marble:
		target_hit = true


func _reset_progress_for_current_step() -> void:
	match current_step:
		0:
			aim_step_seen = false
			shot_step_seen = false
			target_hit = false
			tutorial_hole_capture_active = false
		1:
			shot_step_seen = false
			target_hit = false
			tutorial_hole_capture_active = false
		2:
			target_hit = false
			tutorial_hole_capture_active = false
		_:
			pass


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
	if marble == player_marble:
		tutorial_hole_capture_active = false
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


func _show_aim_guide() -> void:
	match _get_selected_shooting_mechanic():
		SHOOTING_MECHANIC_SPLIT:
			_show_split_aim_guide()
		SHOOTING_MECHANIC_PRESS:
			_show_press_aim_guide()
		_:
			_show_drag_guide()


func _show_shoot_guide() -> void:
	match _get_selected_shooting_mechanic():
		SHOOTING_MECHANIC_SPLIT:
			_show_split_shoot_guide()
		SHOOTING_MECHANIC_PRESS:
			_show_press_shoot_guide()
		_:
			_show_release_guide()


func _show_drag_guide() -> void:
	if ghost_hand == null or guide_arrow == null:
		return
	ghost_hand.visible = true
	ghost_hand.size = GUIDE_HAND_SIZE
	ghost_hand.pivot_offset = GUIDE_HAND_TOUCH_OFFSET
	ghost_hand.scale = Vector2.ONE
	ghost_hand.modulate = Color(1.0, 1.0, 1.0, 0.86)
	_hide_guide_arrow()
	_hide_second_ghost_hand()
	_set_ghost_hand_at_touch(Vector2(820.0, 330.0))

	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(ghost_hand, "position", Vector2(720.0, 430.0) - GUIDE_HAND_TOUCH_OFFSET, 0.95)
	guide_tween.tween_property(ghost_hand, "position", Vector2(820.0, 330.0) - GUIDE_HAND_TOUCH_OFFSET, 0.45)


func _show_release_guide() -> void:
	if ghost_hand == null or guide_arrow == null:
		return
	ghost_hand.visible = true
	ghost_hand.size = GUIDE_HAND_SIZE
	ghost_hand.pivot_offset = GUIDE_HAND_TOUCH_OFFSET
	ghost_hand.scale = Vector2.ONE
	ghost_hand.modulate = Color(1.0, 1.0, 1.0, 0.86)
	_hide_guide_arrow()
	_hide_second_ghost_hand()
	_set_ghost_hand_at_touch(Vector2(720.0, 430.0))

	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(ghost_hand, "scale", Vector2(0.92, 0.92), 0.18)
	guide_tween.tween_property(ghost_hand, "scale", Vector2.ONE, 0.18)
	guide_tween.tween_property(ghost_hand, "modulate:a", 0.3, 0.24)
	guide_tween.tween_property(ghost_hand, "modulate:a", 0.86, 0.24)

func _show_split_aim_guide() -> void:
	if ghost_hand == null:
		return
	_hide_guide_arrow()
	_configure_ghost_hand(ghost_hand, 0.86)
	_hide_second_ghost_hand()
	_set_ghost_hand_at_touch(Vector2(250.0, 395.0))

	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(ghost_hand, "position", Vector2(365.0, 395.0) - GUIDE_HAND_TOUCH_OFFSET, 0.82)
	guide_tween.tween_property(ghost_hand, "position", Vector2(250.0, 395.0) - GUIDE_HAND_TOUCH_OFFSET, 0.42)


func _show_split_shoot_guide() -> void:
	if ghost_hand == null or second_ghost_hand == null or guide_arrow == null:
		return
	_configure_ghost_hand(ghost_hand, 0.7)
	_configure_ghost_hand(second_ghost_hand, 0.86)
	_set_ghost_hand_at_touch(Vector2(250.0, 395.0))
	_set_ghost_hand_at_touch_for(second_ghost_hand, Vector2(1030.0, 390.0))

	_hide_guide_arrow()

	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(ghost_hand, "position", Vector2(340.0, 395.0) - GUIDE_HAND_TOUCH_OFFSET, 0.68)
	guide_tween.tween_property(ghost_hand, "position", Vector2(250.0, 395.0) - GUIDE_HAND_TOUCH_OFFSET, 0.34)

	second_guide_tween = create_tween()
	second_guide_tween.set_loops()
	second_guide_tween.tween_interval(0.25)
	second_guide_tween.tween_property(second_ghost_hand, "position", Vector2(1030.0, 530.0) - GUIDE_HAND_TOUCH_OFFSET, 0.95).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	second_guide_tween.tween_interval(0.2)
	second_guide_tween.tween_property(second_ghost_hand, "position", Vector2(1030.0, 390.0) - GUIDE_HAND_TOUCH_OFFSET, 0.48).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	second_guide_tween.tween_interval(0.15)
	second_guide_tween.tween_property(second_ghost_hand, "position", Vector2(1030.0, 250.0) - GUIDE_HAND_TOUCH_OFFSET, 0.95).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	second_guide_tween.tween_interval(0.2)
	second_guide_tween.tween_property(second_ghost_hand, "position", Vector2(1030.0, 390.0) - GUIDE_HAND_TOUCH_OFFSET, 0.48).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)



func _show_press_aim_guide() -> void:
	if ghost_hand == null:
		return
	_hide_guide_arrow()
	_configure_ghost_hand(ghost_hand, 0.86)
	_hide_second_ghost_hand()
	_set_ghost_hand_at_touch(Vector2(820.0, 390.0))

	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(ghost_hand, "position", Vector2(690.0, 390.0) - GUIDE_HAND_TOUCH_OFFSET, 0.82)
	guide_tween.tween_property(ghost_hand, "position", Vector2(820.0, 390.0) - GUIDE_HAND_TOUCH_OFFSET, 0.42)


func _show_press_shoot_guide() -> void:
	if ghost_hand == null:
		return
	_hide_guide_arrow()
	_configure_ghost_hand(ghost_hand, 0.88)
	_hide_second_ghost_hand()
	_set_ghost_hand_at_touch(Vector2(1110.0, 575.0))

	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(ghost_hand, "scale", Vector2(0.88, 0.88), 0.22)
	guide_tween.tween_property(ghost_hand, "scale", Vector2.ONE, 0.22)
	guide_tween.tween_property(ghost_hand, "modulate:a", 0.46, 0.24)
	guide_tween.tween_property(ghost_hand, "modulate:a", 0.88, 0.24)


func _show_target_guide() -> void:
	if ghost_hand != null:
		ghost_hand.visible = false
	_hide_second_ghost_hand()
	if guide_arrow == null:
		return
	_hide_guide_arrow()


func _show_hole_guide() -> void:
	if ghost_hand != null:
		ghost_hand.visible = false
	_hide_second_ghost_hand()
	if guide_arrow == null:
		return
	_hide_guide_arrow()


func _stop_guide_tweens() -> void:
	if guide_tween != null:
		guide_tween.kill()
		guide_tween = null
	if second_guide_tween != null:
		second_guide_tween.kill()
		second_guide_tween = null
	if arrow_tween != null:
		arrow_tween.kill()
		arrow_tween = null


func _animate_tutorial_panel_in() -> void:
	if tutorial_panel == null:
		return
	tutorial_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	tutorial_panel.position.x += 16.0
	var panel_tween: Tween = create_tween()
	panel_tween.set_parallel(true)
	panel_tween.tween_property(tutorial_panel, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	panel_tween.tween_property(tutorial_panel, "position:x", tutorial_panel.position.x - 16.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _show_completion_message(message: String, hold_seconds: float) -> void:
	if completion_panel == null or completion_label == null:
		return
	if completion_tween != null:
		completion_tween.kill()
		completion_tween = null

	completion_label.text = message
	completion_panel.visible = true
	completion_panel.scale = Vector2(0.94, 0.94)
	completion_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)

	completion_tween = create_tween()
	completion_tween.tween_property(completion_panel, "modulate:a", 1.0, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	completion_tween.parallel().tween_property(completion_panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	completion_tween.tween_interval(hold_seconds)
	completion_tween.tween_property(completion_panel, "modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	completion_tween.tween_callback(Callable(self, "_hide_completion_panel_after_tween"))


func _hide_completion_message() -> void:
	if completion_tween != null:
		completion_tween.kill()
		completion_tween = null
	if completion_panel != null:
		completion_panel.visible = false
		completion_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)


func _hide_completion_panel_after_tween() -> void:
	if completion_panel != null:
		completion_panel.visible = false


func _configure_ghost_hand(hand: TextureRect, alpha: float = 0.86) -> void:
	if hand == null:
		return
	hand.visible = true
	hand.size = GUIDE_HAND_SIZE
	hand.pivot_offset = GUIDE_HAND_TOUCH_OFFSET
	hand.scale = Vector2.ONE
	hand.modulate = Color(1.0, 1.0, 1.0, alpha)


func _hide_second_ghost_hand() -> void:
	if second_ghost_hand != null:
		second_ghost_hand.visible = false


func _hide_guide_arrow() -> void:
	if guide_arrow != null:
		guide_arrow.visible = false


func _hide_split_control_names() -> void:
	if tutorial_canvas == null:
		return
	var watermark: Control = tutorial_canvas.get_node_or_null("SplitControlWatermark") as Control
	if watermark == null:
		return
	watermark.visible = false
	watermark.modulate = Color(1.0, 1.0, 1.0, 0.0)
	for child in watermark.get_children():
		var label: Label = child as Label
		if label != null:
			label.text = ""


func _remove_tutorial_name_tags() -> void:
	if marbles_root == null:
		return
	_remove_name_tags_from(marbles_root)


func _remove_name_tags_from(node: Node) -> void:
	for child in node.get_children():
		if child.name == "NameTag" or (child is Label3D):
			var node_3d: Node3D = child as Node3D
			if node_3d != null:
				node_3d.visible = false
			child.queue_free()
			continue
		_remove_name_tags_from(child)


func _set_ghost_hand_at_touch(touch_position: Vector2) -> void:
	if ghost_hand == null:
		return
	ghost_hand.position = touch_position - GUIDE_HAND_TOUCH_OFFSET


func _set_ghost_hand_at_touch_for(hand: TextureRect, touch_position: Vector2) -> void:
	if hand == null:
		return
	hand.position = touch_position - GUIDE_HAND_TOUCH_OFFSET


func _get_player_screen_position(property_name: String, fallback: Vector2) -> Vector2:
	if player_marble == null:
		return fallback
	var value: Variant = player_marble.get(property_name)
	if value is Vector2:
		return value
	return fallback


func _load_tutorial_hand_texture() -> Texture2D:
	if ResourceLoader.exists(TUTORIAL_HAND_TEXTURE_PATH):
		var texture: Texture2D = load(TUTORIAL_HAND_TEXTURE_PATH) as Texture2D
		if texture != null:
			return texture
	return _make_hand_texture()


func _get_selected_shooting_mechanic() -> String:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shooting_mechanic"):
		var mechanic: String = str(customization.call("get_shooting_mechanic"))
		if mechanic == SHOOTING_MECHANIC_SPLIT or mechanic == SHOOTING_MECHANIC_PRESS:
			return mechanic
	return SHOOTING_MECHANIC_DRAG


func _get_step_copy_for_mechanic(mechanic: String) -> Array[String]:
	match mechanic:
		SHOOTING_MECHANIC_SPLIT:
			return [
				"Use the left side to aim your marble.",
				"Use the right side to slide power up or down, then release to shoot.",
				COMMON_STEP_TARGET,
				COMMON_STEP_HOLE,
				COMMON_STEP_DONE
			]
		SHOOTING_MECHANIC_PRESS:
			return [
				"Drag left or right to aim your marble.",
				"Hold the shoot button, then release at the power you want.",
				COMMON_STEP_TARGET,
				COMMON_STEP_HOLE,
				COMMON_STEP_DONE
			]
		_:
			return [
				"Drag backward to aim your marble.",
				"Release to take a shot.",
				COMMON_STEP_TARGET,
				COMMON_STEP_HOLE,
				COMMON_STEP_DONE
			]


func _get_aim_hint_for_mechanic(mechanic: String) -> String:
	match mechanic:
		SHOOTING_MECHANIC_SPLIT:
			return "Touch the left side and slide sideways to steer the aim line."
		SHOOTING_MECHANIC_PRESS:
			return "Touch the play area and slide left or right to move the aim line."
		_:
			return "Pull downward on the screen to line up your shot and build power."


func _get_shoot_hint_for_mechanic(mechanic: String) -> String:
	match mechanic:
		SHOOTING_MECHANIC_SPLIT:
			return "Keep your aim on the left, then slide up or down on the right side for power."
		SHOOTING_MECHANIC_PRESS:
			return "Press and hold the SHOOT button while the power rises, then let go."
		_:
			return "Let go once you are aimed. Your marble will fire immediately."


func _update_live_guide() -> void:
	if ghost_hand == null or guide_arrow == null or player_marble == null:
		return
	if current_step > 1 or tutorial_complete:
		return
	var mechanic: String = _get_selected_shooting_mechanic()
	var is_guiding: bool = bool(player_marble.get("dragging"))
	if mechanic == SHOOTING_MECHANIC_SPLIT:
		is_guiding = bool(player_marble.get("split_aiming")) or bool(player_marble.get("split_shooting"))
	elif mechanic == SHOOTING_MECHANIC_PRESS:
		is_guiding = bool(player_marble.get("press_aiming")) or bool(player_marble.get("press_charging"))
	if not is_guiding:
		return

	var pointer_position: Vector2 = get_viewport().get_mouse_position()
	if mechanic == SHOOTING_MECHANIC_SPLIT:
		if current_step == 1 and not bool(player_marble.get("split_shooting")):
			if guide_tween != null:
				guide_tween.kill()
				guide_tween = null
			_configure_ghost_hand(ghost_hand, 0.92)
			if bool(player_marble.get("split_aiming")):
				var active_aim_position: Vector2 = _get_player_screen_position("split_aim_position", pointer_position)
				_set_ghost_hand_at_touch(active_aim_position)
			if second_ghost_hand != null:
				_configure_ghost_hand(second_ghost_hand, 0.86)
			if guide_arrow != null:
				guide_arrow.visible = true
			return

		_stop_guide_tweens()
		_hide_guide_arrow()
		_configure_ghost_hand(ghost_hand, 0.92)
		var aim_position: Vector2 = _get_player_screen_position("split_aim_position", pointer_position)
		var shoot_position: Vector2 = _get_player_screen_position("split_shoot_position", pointer_position)
		if bool(player_marble.get("split_aiming")):
			_set_ghost_hand_at_touch(aim_position)
		if bool(player_marble.get("split_shooting")) and second_ghost_hand != null:
			_configure_ghost_hand(second_ghost_hand, 0.86)
			_set_ghost_hand_at_touch_for(second_ghost_hand, shoot_position)
		else:
			_hide_second_ghost_hand()
		return
	_stop_guide_tweens()
	_hide_guide_arrow()
	_configure_ghost_hand(ghost_hand, 0.92)
	if mechanic == SHOOTING_MECHANIC_PRESS:
		if bool(player_marble.get("press_charging")):
			pointer_position = _get_player_screen_position("hold_shoot_position", pointer_position)
		elif bool(player_marble.get("press_aiming")):
			pointer_position = _get_player_screen_position("press_aim_position", pointer_position)
	else:
		pointer_position = _get_player_screen_position("last_drag_position", pointer_position)
	_hide_second_ghost_hand()
	_set_ghost_hand_at_touch(pointer_position)

	var marble_screen_position: Vector2 = pointer_position
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera != null:
		marble_screen_position = camera.unproject_position(player_marble.global_position)
	var drag_vector: Vector2 = pointer_position - marble_screen_position
	if drag_vector.length() <= 6.0:
		return


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


func _apply_step_scene_state() -> void:
	_ensure_hole_cover()
	_set_target_marble_available(_is_target_marble_needed())
	_set_hole_available(_is_hole_needed())
	if current_step == 2:
		_place_marble(player_marble, PLAYER_START)
		_place_marble(target_marble, TARGET_RESET)
		target_hit = false
		_give_player_control()
	elif current_step == 3:
		_place_marble(player_marble, PLAYER_START)
		_give_player_control()


func _is_target_marble_needed() -> bool:
	return current_step == 1 or current_step == 2


func _is_hole_needed() -> bool:
	return current_step >= 3


func _set_target_marble_available(available: bool) -> void:
	if target_marble == null:
		return

	if not available:
		_hide_unused_marble(target_marble)
		return

	if not target_marble.visible or target_marble.global_position.distance_to(HIDDEN_MARBLE_POS) < 0.1:
		_place_marble(target_marble, TARGET_RESET)
	else:
		target_marble.freeze = false
		target_marble.sleeping = false
		target_marble.visible = true
		target_marble.collision_layer = 1
		target_marble.collision_mask = 1


func _set_hole_available(available: bool) -> void:
	if hole == null:
		return

	hole.visible = available
	if hole_cover != null:
		hole_cover.visible = not available
		hole_cover.global_position = Vector3(hole.global_position.x, -35.0, hole.global_position.z) if available else Vector3(hole.global_position.x, 0.08, hole.global_position.z)
		hole_cover.collision_layer = 0 if available else 1
		hole_cover.collision_mask = 0 if available else 1
		_set_collision_shapes_disabled(hole_cover, available)
	if hole is CollisionObject3D:
		var collision_object: CollisionObject3D = hole as CollisionObject3D
		collision_object.collision_layer = 1 if available else 0
		collision_object.collision_mask = 1 if available else 0
	_set_collision_shapes_disabled(hole, not available)


func _ensure_hole_cover() -> void:
	if hole == null:
		return
	if hole_cover != null and is_instance_valid(hole_cover):
		return

	hole_cover = StaticBody3D.new()
	hole_cover.name = "TutorialHoleCover"
	hole_cover.collision_layer = 1
	hole_cover.collision_mask = 1
	hole_cover.global_position = Vector3(hole.global_position.x, 0.08, hole.global_position.z)
	add_child(hole_cover)

	var cover_visual: MeshInstance3D = MeshInstance3D.new()
	cover_visual.name = "Visual"
	var cover_mesh: BoxMesh = BoxMesh.new()
	cover_mesh.size = HOLE_COVER_SIZE
	cover_visual.mesh = cover_mesh
	cover_visual.material_override = _get_tutorial_ground_material()
	hole_cover.add_child(cover_visual)

	var cover_collision: CollisionShape3D = CollisionShape3D.new()
	cover_collision.name = "Collision"
	var cover_shape: BoxShape3D = BoxShape3D.new()
	cover_shape.size = HOLE_COVER_SIZE
	cover_collision.shape = cover_shape
	hole_cover.add_child(cover_collision)


func _get_tutorial_ground_material() -> Material:
	var ground_mesh: MeshInstance3D = get_node_or_null("Ground/GroundNorth") as MeshInstance3D
	if ground_mesh != null and ground_mesh.mesh != null and ground_mesh.mesh.surface_get_material(0) != null:
		return ground_mesh.mesh.surface_get_material(0)

	var cover_material: StandardMaterial3D = StandardMaterial3D.new()
	cover_material.albedo_color = Color(0.34, 0.61, 0.31, 1.0)
	cover_material.roughness = 0.92
	return cover_material


func _set_collision_shapes_disabled(root_node: Node, disabled: bool) -> void:
	for child in root_node.get_children():
		if child is CollisionShape3D:
			var shape: CollisionShape3D = child as CollisionShape3D
			shape.disabled = disabled
			shape.set_deferred("disabled", disabled)
		elif child is CollisionPolygon3D:
			var polygon: CollisionPolygon3D = child as CollisionPolygon3D
			polygon.disabled = disabled
			polygon.set_deferred("disabled", disabled)
		_set_collision_shapes_disabled(child, disabled)


func _is_marble_in_hole(marble: Node3D) -> bool:
	if marble == null or hole == null or not _is_hole_needed():
		return false
	var local_position: Vector3 = hole.to_local(marble.global_position)
	var pocket_radius: float = float(hole.get("pocket_radius")) if hole.get("pocket_radius") != null else 1.0
	var depth: float = float(hole.get("depth")) if hole.get("depth") != null else 1.0
	var bottom_stop_lift: float = float(hole.get("bottom_stop_lift")) if hole.get("bottom_stop_lift") != null else 0.08
	var bottom_stop_height: float = float(hole.get("bottom_stop_height")) if hole.get("bottom_stop_height") != null else 0.18
	var bottom_touch_y: float = -depth + bottom_stop_lift + bottom_stop_height + 0.23
	var planar_distance: float = Vector2(local_position.x, local_position.z).length()
	return planar_distance <= pocket_radius * 0.88 and local_position.y <= bottom_touch_y


func _assist_player_into_tutorial_hole(delta: float) -> void:
	if current_step != 3 or player_marble == null or hole == null:
		tutorial_hole_capture_active = false
		return
	if _is_marble_in_hole(player_marble):
		return

	var local_position: Vector3 = hole.to_local(player_marble.global_position)
	var pocket_radius: float = float(hole.get("pocket_radius")) if hole.get("pocket_radius") != null else 1.0
	var depth: float = float(hole.get("depth")) if hole.get("depth") != null else 1.0
	var entry_radius: float = float(hole.get("entry_radius")) if hole.get("entry_radius") != null else pocket_radius * 1.42
	var planar: Vector2 = Vector2(local_position.x, local_position.z)
	var planar_distance: float = planar.length()
	var is_at_hole_mouth: bool = planar_distance <= entry_radius * 1.45 and local_position.y <= 1.25
	if not tutorial_hole_capture_active and not is_at_hole_mouth:
		return

	tutorial_hole_capture_active = true
	player_marble.collision_layer = 0
	player_marble.collision_mask = 0
	player_marble.freeze = false
	player_marble.sleeping = false

	var bottom_stop_lift: float = float(hole.get("bottom_stop_lift")) if hole.get("bottom_stop_lift") != null else 0.08
	var bottom_stop_height: float = float(hole.get("bottom_stop_height")) if hole.get("bottom_stop_height") != null else 0.18
	var target_y: float = -depth + bottom_stop_lift + bottom_stop_height + 0.05
	var pull_weight: float = clampf(delta * 13.0, 0.0, 0.72)
	var drop_weight: float = clampf(delta * 10.0, 0.0, 0.62)
	var assisted_local: Vector3 = local_position
	assisted_local.x = lerpf(assisted_local.x, 0.0, pull_weight)
	assisted_local.z = lerpf(assisted_local.z, 0.0, pull_weight)
	assisted_local.y = lerpf(assisted_local.y, target_y, drop_weight)
	player_marble.global_transform = Transform3D(player_marble.global_transform.basis, hole.to_global(assisted_local))

	var center_direction: Vector3 = (hole.global_position - player_marble.global_position)
	center_direction.y = 0.0
	if center_direction.length_squared() > 0.0001:
		center_direction = center_direction.normalized()
	player_marble.linear_velocity = center_direction * 0.25 + Vector3.DOWN * 2.8
	player_marble.angular_velocity *= 0.45


func _is_target_step_complete() -> bool:
	if target_hit:
		return true
	if player_marble == null or target_marble == null:
		return false
	var target_displacement: float = Vector2(
		target_marble.global_position.x - TARGET_RESET.x,
		target_marble.global_position.z - TARGET_RESET.z
	).length()
	if target_displacement > 0.35:
		target_hit = true
		return true
	return false


func _is_hole_step_complete() -> bool:
	return _is_marble_in_hole(player_marble)


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


func _make_completion_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.14, 0.2, 0.82)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.98, 0.9, 0.42, 0.64)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.shadow_color = Color(0.98, 0.72, 0.18, 0.26)
	style.shadow_size = 26
	style.anti_aliasing = true
	style.anti_aliasing_size = 1.4
	return style
