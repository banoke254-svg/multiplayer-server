extends RigidBody3D

const TRAIL_MODEL_PATH_A: String = "res://looping_particle_trail_fbx_0.9mb.glb"
const TRAIL_MODEL_PATH_B: String = "res://trail.glb"
const SHOOTING_MECHANIC_DRAG: String = "drag"
const SHOOTING_MECHANIC_SPLIT: String = "split"
const SHOOTING_MECHANIC_PRESS: String = "press"

@export var min_drag_length: float = 18.0
@export var max_drag_distance: float = 220.0
@export var min_shot_impulse: float = 0.08
@export var max_shot_impulse: float = 11.2
@export var press_charge_seconds: float = 2.4
@export var split_watermark_seconds: float = 4.0
@export var split_watermark_alpha: float = 0.72
@export var power_response_exponent: float = 2.35
@export var drag_input_smoothing: float = 0.32
@export var min_shot_lift: float = 0.0
@export var max_shot_lift: float = 0.22
@export var max_vertical_shot_impulse: float = 0.34
@export var max_upward_velocity: float = 2.2
@export var curve_start_ratio: float = 0.58
@export var stop_threshold: float = 0.08
@export var input_ready_velocity_threshold: float = 0.18
@export var indicator_segment_count: int = 9

var is_turn := false
var turn_manager: Node = null

var drag_start := Vector2.ZERO
var dragging := false
var active_touch_index := -1
var camera: Camera3D
var camera_rig: Node = null
var current_aim_direction: Vector3 = Vector3.ZERO
var current_shot_ratio: float = 0.0
var current_shot_impulse: float = 0.0
var current_shot_lift: float = 0.0

var indicator_segments: Array[MeshInstance3D] = []
var arrow_tip: MeshInstance3D = null
var _segment_mesh: CylinderMesh = null
var _tip_mesh: CylinderMesh = null
var _glass_material: StandardMaterial3D = null
var power_bar: ProgressBar = null
var power_label: Label = null
var power_glass: Control = null
var trail_settings: Dictionary = {}
var marble_visual: Node = null
var trail_effect_root: Node3D = null
var active_trail_node: Node3D = null
var active_trail_source_path: String = ""
var trail_motion_direction: Vector3 = Vector3.FORWARD
var last_drag_position := Vector2.ZERO
var smoothed_drag_vector := Vector2.ZERO
var drag_reference_forward := Vector3.ZERO
var drag_reference_right := Vector3.ZERO
@export var max_aim_turn_degrees: float = 360.0
var split_aiming: bool = false
var split_shooting: bool = false
var split_aim_touch_index: int = -1
var split_shoot_touch_index: int = -1
var split_aim_start: Vector2 = Vector2.ZERO
var split_shoot_start: Vector2 = Vector2.ZERO
var split_aim_horizontal_offset: float = 0.0
var split_shoot_vertical_offset: float = 0.0
var press_aiming: bool = false
var press_charging: bool = false
var press_aim_touch_index: int = -1
var press_aim_start: Vector2 = Vector2.ZERO
var press_aim_horizontal_offset: float = 0.0
var press_charge_time: float = 0.0
var press_charge_direction: float = 1.0
var hold_shoot_button: Button = null
var hold_shoot_touch_index: int = -1
var hold_shoot_mouse_active: bool = false
var split_watermark_layer: Control = null
var split_watermark_left_label: Label = null
var split_watermark_right_label: Label = null
var split_watermark_timer: float = 0.0
var split_watermark_shown_this_turn: bool = false


func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	camera_rig = get_node_or_null("CameraRig")
	marble_visual = get_node_or_null("GlassBallModel")
	power_glass = get_node_or_null("/root/Main/UI/PowerMeter/PowerGlass") as Control
	power_bar = get_node_or_null("/root/Main/UI/PowerMeter/PowerBar")
	power_label = get_node_or_null("/root/Main/UI/PowerMeter/PowerLabel")
	if power_glass == null or power_bar == null or power_label == null:
		var current_scene: Node = get_tree().current_scene
		if current_scene != null:
			power_glass = current_scene.get_node_or_null("UI/PowerMeter/PowerGlass") as Control
			power_bar = current_scene.get_node_or_null("UI/PowerMeter/PowerBar")
			power_label = current_scene.get_node_or_null("UI/PowerMeter/PowerLabel")
	_create_shot_indicator()
	_ensure_hold_shoot_button()
	_ensure_split_watermark()
	_apply_customization()
	_update_power_meter(0.0, false)


func _process(delta: float) -> void:
	_update_hold_shoot_button_visibility()
	_update_split_watermark(delta)
	if press_charging and _can_receive_input():
		var charge_limit: float = maxf(press_charge_seconds, 0.05)
		press_charge_time += delta * press_charge_direction
		if press_charge_time >= charge_limit:
			press_charge_time = charge_limit
			press_charge_direction = -1.0
		elif press_charge_time <= 0.0:
			press_charge_time = 0.0
			press_charge_direction = 1.0
		_update_press_shot_preview(true)
	elif press_charging:
		_cancel_press_shot()


func _physics_process(_delta: float) -> void:
	_clamp_upward_velocity()


func _ensure_hold_shoot_button() -> void:
	if hold_shoot_button != null and is_instance_valid(hold_shoot_button):
		return

	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		return
	var ui_root: Node = current_scene.get_node_or_null("UI")
	if ui_root == null:
		return

	hold_shoot_button = ui_root.get_node_or_null("HoldShootButton") as Button
	if hold_shoot_button == null:
		hold_shoot_button = Button.new()
		hold_shoot_button.name = "HoldShootButton"
		ui_root.add_child(hold_shoot_button)
	var pause_ui: Node = ui_root.get_node_or_null("PauseUI")
	if pause_ui != null and hold_shoot_button.get_parent() == ui_root:
		ui_root.move_child(hold_shoot_button, pause_ui.get_index())

	hold_shoot_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	hold_shoot_button.offset_left = -156.0
	hold_shoot_button.offset_top = -156.0
	hold_shoot_button.offset_right = -30.0
	hold_shoot_button.offset_bottom = -30.0
	hold_shoot_button.focus_mode = Control.FOCUS_NONE
	hold_shoot_button.mouse_filter = Control.MOUSE_FILTER_STOP
	hold_shoot_button.text = "HOLD\nSHOOT"
	hold_shoot_button.add_theme_font_size_override("font_size", 16)
	hold_shoot_button.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	hold_shoot_button.add_theme_stylebox_override("normal", _make_hold_button_style(Color(0.72, 0.36, 1.0, 1.0), Color(0.03, 0.05, 0.12, 0.84)))
	hold_shoot_button.add_theme_stylebox_override("hover", _make_hold_button_style(Color(0.96, 0.47, 1.0, 1.0), Color(0.06, 0.08, 0.18, 0.9)))
	hold_shoot_button.add_theme_stylebox_override("pressed", _make_hold_button_style(Color(1.0, 0.82, 0.2, 1.0), Color(0.09, 0.04, 0.14, 0.96)))
	if hold_shoot_button.button_down.is_connected(_begin_press_shot_from_button):
		hold_shoot_button.button_down.disconnect(_begin_press_shot_from_button)
	if hold_shoot_button.button_up.is_connected(_finish_press_shot_from_button):
		hold_shoot_button.button_up.disconnect(_finish_press_shot_from_button)
	if not hold_shoot_button.gui_input.is_connected(_on_hold_shoot_button_gui_input):
		hold_shoot_button.gui_input.connect(_on_hold_shoot_button_gui_input)
	_update_hold_shoot_button_visibility()


func _on_hold_shoot_button_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			_begin_hold_shoot_pointer(touch.index)
		else:
			_finish_hold_shoot_pointer(touch.index)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index == hold_shoot_touch_index:
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_button.pressed:
			_begin_hold_shoot_pointer(-1)
		else:
			_finish_hold_shoot_pointer(-1)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and hold_shoot_mouse_active:
		get_viewport().set_input_as_handled()


func _ensure_split_watermark() -> void:
	if split_watermark_layer != null and is_instance_valid(split_watermark_layer):
		return

	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		return
	var ui_root: Node = current_scene.get_node_or_null("UI")
	if ui_root == null:
		return

	split_watermark_layer = ui_root.get_node_or_null("SplitControlWatermark") as Control
	if split_watermark_layer == null:
		split_watermark_layer = Control.new()
		split_watermark_layer.name = "SplitControlWatermark"
		ui_root.add_child(split_watermark_layer)

	split_watermark_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	split_watermark_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	split_watermark_layer.visible = false
	split_watermark_layer.modulate = Color(1.0, 1.0, 1.0, 0.0)
	ui_root.move_child(split_watermark_layer, ui_root.get_child_count() - 1)

	if split_watermark_left_label == null or not is_instance_valid(split_watermark_left_label):
		split_watermark_left_label = _create_split_watermark_label("AIM")
		split_watermark_left_label.name = "AimWatermark"
		split_watermark_left_label.set_anchors_preset(Control.PRESET_LEFT_WIDE)
		split_watermark_left_label.offset_left = 24.0
		split_watermark_left_label.offset_top = 0.0
		split_watermark_left_label.offset_right = 360.0
		split_watermark_left_label.offset_bottom = 0.0
		split_watermark_layer.add_child(split_watermark_left_label)

	if split_watermark_right_label == null or not is_instance_valid(split_watermark_right_label):
		split_watermark_right_label = _create_split_watermark_label("SHOOT")
		split_watermark_right_label.name = "ShootWatermark"
		split_watermark_right_label.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
		split_watermark_right_label.offset_left = -360.0
		split_watermark_right_label.offset_top = 0.0
		split_watermark_right_label.offset_right = -24.0
		split_watermark_right_label.offset_bottom = 0.0
		split_watermark_layer.add_child(split_watermark_right_label)


func _create_split_watermark_label(text_value: String) -> Label:
	var label := Label.new()
	label.text = text_value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 46)
	label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.82))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_constant_override("shadow_outline_size", 8)
	return label


func _make_hold_button_style(accent_color: Color, fill_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = accent_color
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 72
	style.corner_radius_top_right = 72
	style.corner_radius_bottom_right = 72
	style.corner_radius_bottom_left = 72
	style.shadow_color = accent_color.darkened(0.5)
	style.shadow_size = 22
	style.shadow_offset = Vector2(0, 7)
	style.content_margin_left = 10.0
	style.content_margin_top = 10.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 10.0
	return style


func _create_shot_indicator() -> void:
	_segment_mesh = CylinderMesh.new()
	_segment_mesh.top_radius = 0.08
	_segment_mesh.bottom_radius = 0.08
	_segment_mesh.height = 1.0
	_segment_mesh.radial_segments = 18

	_tip_mesh = CylinderMesh.new()
	_tip_mesh.top_radius = 0.0
	_tip_mesh.bottom_radius = 0.18
	_tip_mesh.height = 0.55
	_tip_mesh.radial_segments = 18

	arrow_tip = MeshInstance3D.new()
	arrow_tip.mesh = _tip_mesh

	_glass_material = StandardMaterial3D.new()
	_glass_material.albedo_color = Color(0.68, 0.96, 0.92, 0.72)
	_glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_glass_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_glass_material.no_depth_test = true
	_glass_material.roughness = 0.08
	_glass_material.metallic = 0.05
	_glass_material.refraction_enabled = false
	_glass_material.refraction_scale = 0.0
	_glass_material.emission_enabled = true
	_glass_material.emission = Color(0.48, 0.98, 0.9, 1.0)
	_glass_material.emission_energy_multiplier = 1.8

	for index in range(indicator_segment_count):
		var segment := MeshInstance3D.new()
		segment.name = "AimSegment%d" % index
		segment.mesh = _segment_mesh
		segment.material_override = _glass_material
		indicator_segments.append(segment)
		add_child(segment)

	arrow_tip.material_override = _glass_material

	_hide_indicator()
	add_child(arrow_tip)


func start_turn(tm_ref: Node = null) -> void:
	turn_manager = tm_ref
	is_turn = true
	dragging = false
	active_touch_index = -1
	_reset_alternate_input_state()
	split_watermark_shown_this_turn = false
	current_aim_direction = Vector3.ZERO
	current_shot_ratio = 0.0
	current_shot_impulse = 0.0
	current_shot_lift = 0.0
	_prepare_for_turn()
	_hide_indicator()
	_update_power_meter(0.0, false)
	if _get_shooting_mechanic() == SHOOTING_MECHANIC_SPLIT:
		_show_split_watermark()
	print(name, " turn: true")


func set_turn(active: bool, tm_ref: Node = null) -> void:
	if active:
		start_turn(tm_ref)
		return

	is_turn = false
	if tm_ref != null or active == false:
		turn_manager = null
	dragging = false
	active_touch_index = -1
	_reset_alternate_input_state()
	split_watermark_shown_this_turn = false
	current_aim_direction = Vector3.ZERO
	current_shot_ratio = 0.0
	current_shot_impulse = 0.0
	current_shot_lift = 0.0
	_hide_indicator()
	_hide_split_watermark()
	print(name, " turn:", active)


func end_turn() -> void:
	set_turn(false)


func is_moving() -> bool:
	return linear_velocity.length() > stop_threshold or angular_velocity.length() > stop_threshold


func _input(event: InputEvent) -> void:
	if not _can_receive_input():
		return

	var shooting_mechanic: String = _get_shooting_mechanic()
	if shooting_mechanic == SHOOTING_MECHANIC_SPLIT:
		_handle_split_input(event)
		return
	if shooting_mechanic == SHOOTING_MECHANIC_PRESS:
		_handle_press_input(event)
		return

	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_touch_drag(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)


func _handle_split_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			if _is_left_screen_area(touch.position):
				if split_aiming:
					return
				_begin_split_aim(touch.position, touch.index)
			else:
				if split_shooting:
					return
				_begin_split_shot(touch.position, touch.index)
			get_viewport().set_input_as_handled()
		elif split_aiming and touch.index == split_aim_touch_index:
			_end_split_aim()
			get_viewport().set_input_as_handled()
		elif split_shooting and touch.index == split_shoot_touch_index:
			_finish_split_shot(touch.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if split_aiming and drag_event.index == split_aim_touch_index:
			_update_split_aim(drag_event.position)
			get_viewport().set_input_as_handled()
		elif split_shooting and drag_event.index == split_shoot_touch_index:
			_update_split_shot(drag_event.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_button.pressed:
			if _pointer_over_ui():
				return
			if _is_left_screen_area(mouse_button.position):
				_begin_split_aim(mouse_button.position, -1)
			else:
				_begin_split_shot(mouse_button.position, -1)
			get_viewport().set_input_as_handled()
		elif split_shooting and split_shoot_touch_index == -1:
			_finish_split_shot(mouse_button.position)
			get_viewport().set_input_as_handled()
		elif split_aiming and split_aim_touch_index == -1:
			_end_split_aim()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		if split_aiming and split_aim_touch_index == -1:
			_update_split_aim(mouse_motion.position)
			get_viewport().set_input_as_handled()
		elif split_shooting and split_shoot_touch_index == -1:
			_update_split_shot(mouse_motion.position)
			get_viewport().set_input_as_handled()


func _handle_press_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			if _is_inside_hold_shoot_button(touch.position):
				_begin_hold_shoot_pointer(touch.index)
				get_viewport().set_input_as_handled()
				return
			if press_aiming:
				return
			_begin_press_aim(touch.position, touch.index)
			get_viewport().set_input_as_handled()
		elif touch.index == hold_shoot_touch_index:
			_finish_hold_shoot_pointer(touch.index)
			get_viewport().set_input_as_handled()
		elif press_aiming and touch.index == press_aim_touch_index:
			_end_press_aim()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if drag_event.index == hold_shoot_touch_index:
			get_viewport().set_input_as_handled()
		elif press_aiming and drag_event.index == press_aim_touch_index:
			_update_press_aim(drag_event.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_button.pressed:
			if _is_inside_hold_shoot_button(mouse_button.position):
				_begin_hold_shoot_pointer(-1)
				get_viewport().set_input_as_handled()
				return
			if _pointer_over_ui():
				return
			_begin_press_aim(mouse_button.position, -1)
			get_viewport().set_input_as_handled()
		elif hold_shoot_mouse_active:
			_finish_hold_shoot_pointer(-1)
			get_viewport().set_input_as_handled()
		elif press_aiming and press_aim_touch_index == -1:
			_end_press_aim()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		if hold_shoot_mouse_active:
			get_viewport().set_input_as_handled()
		elif press_aiming and press_aim_touch_index == -1:
			_update_press_aim(mouse_motion.position)
			get_viewport().set_input_as_handled()


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if dragging or _pointer_over_ui():
			return
		active_touch_index = event.index
		_begin_drag(event.position)
		get_viewport().set_input_as_handled()
	elif dragging and event.index == active_touch_index:
		_finish_drag(event.position)
		get_viewport().set_input_as_handled()


func _handle_touch_drag(event: InputEventScreenDrag) -> void:
	if dragging and event.index == active_touch_index:
		update_path_indicator(event.position)
		get_viewport().set_input_as_handled()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.pressed:
		if dragging or _pointer_over_ui():
			return
		_begin_drag(event.position)
		get_viewport().set_input_as_handled()
	elif dragging:
		_finish_drag(event.position)
		get_viewport().set_input_as_handled()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if dragging:
		update_path_indicator(event.position)
		get_viewport().set_input_as_handled()


func _begin_split_aim(pointer_position: Vector2, touch_index: int) -> void:
	split_aiming = true
	split_aim_touch_index = touch_index
	split_aim_start = pointer_position
	split_aim_horizontal_offset = 0.0
	_capture_drag_reference_axes()
	_update_split_shot_preview(split_shooting)


func _update_split_aim(pointer_position: Vector2) -> void:
	split_aim_horizontal_offset = pointer_position.x - split_aim_start.x
	_update_split_shot_preview(split_shooting)


func _end_split_aim() -> void:
	split_aiming = false
	split_aim_touch_index = -1
	if split_shooting:
		_update_split_shot_preview(true)
	else:
		_hide_indicator()
		_update_power_meter(0.0, false)


func _begin_split_shot(pointer_position: Vector2, touch_index: int) -> void:
	split_shooting = true
	split_shoot_touch_index = touch_index
	split_shoot_start = pointer_position
	split_shoot_vertical_offset = 0.0
	_capture_drag_reference_axes()
	_update_split_shot_preview(true)


func _update_split_shot(pointer_position: Vector2) -> void:
	split_shoot_vertical_offset = pointer_position.y - split_shoot_start.y
	_update_split_shot_preview(true)


func _finish_split_shot(pointer_position: Vector2) -> void:
	_update_split_shot(pointer_position)
	split_shooting = false
	split_shoot_touch_index = -1
	if current_shot_ratio > 0.015:
		_apply_current_shot()
	elif split_aiming:
		_update_split_shot_preview(false)
	else:
		_hide_indicator()
		_update_power_meter(0.0, false)


func _begin_press_aim(pointer_position: Vector2, touch_index: int) -> void:
	press_aiming = true
	press_aim_touch_index = touch_index
	press_aim_start = pointer_position
	press_aim_horizontal_offset = 0.0
	_capture_drag_reference_axes()
	_update_press_shot_preview(press_charging)


func _update_press_aim(pointer_position: Vector2) -> void:
	press_aim_horizontal_offset = pointer_position.x - press_aim_start.x
	_update_press_shot_preview(press_charging)


func _end_press_aim() -> void:
	press_aiming = false
	press_aim_touch_index = -1
	if not press_charging:
		_hide_indicator()
		_update_power_meter(0.0, false)


func _begin_hold_shoot_pointer(pointer_index: int) -> void:
	if pointer_index >= 0:
		hold_shoot_touch_index = pointer_index
	else:
		hold_shoot_mouse_active = true
	if press_charging:
		return
	_begin_press_shot_from_button()


func _finish_hold_shoot_pointer(pointer_index: int) -> void:
	if pointer_index >= 0:
		if hold_shoot_touch_index != pointer_index:
			return
		hold_shoot_touch_index = -1
	else:
		if not hold_shoot_mouse_active:
			return
		hold_shoot_mouse_active = false
	_finish_press_shot_from_button()


func _begin_press_shot_from_button() -> void:
	if _get_shooting_mechanic() != SHOOTING_MECHANIC_PRESS or not _can_receive_input():
		return
	press_charging = true
	press_charge_time = 0.0
	press_charge_direction = 1.0
	_capture_drag_reference_axes()
	_update_press_shot_preview(true)


func _finish_press_shot_from_button() -> void:
	if not press_charging:
		return
	_update_press_shot_preview(true)
	press_charging = false
	if current_shot_ratio > 0.015:
		_apply_current_shot()
	elif press_aiming:
		_update_press_shot_preview(false)
	else:
		_hide_indicator()
		_update_power_meter(0.0, false)
	press_charge_time = 0.0
	press_charge_direction = 1.0
	_update_hold_shoot_button_label(0.0)
	_update_hold_shoot_button_visibility()


func _cancel_press_shot() -> void:
	press_charging = false
	press_charge_time = 0.0
	press_charge_direction = 1.0
	hold_shoot_touch_index = -1
	hold_shoot_mouse_active = false
	if press_aiming:
		_update_press_shot_preview(false)
	else:
		_hide_indicator()
		_update_power_meter(0.0, false)
	_update_hold_shoot_button_label(0.0)


func _begin_drag(pointer_position: Vector2) -> void:
	drag_start = pointer_position
	last_drag_position = pointer_position
	smoothed_drag_vector = Vector2.ZERO
	dragging = true
	_capture_drag_reference_axes()
	current_aim_direction = Vector3.ZERO
	current_shot_ratio = 0.0
	current_shot_impulse = 0.0
	current_shot_lift = 0.0
	_hide_indicator()
	_update_power_meter(0.0, true)


func _finish_drag(pointer_position: Vector2) -> void:
	update_path_indicator(pointer_position)
	_apply_current_shot()
	dragging = false
	active_touch_index = -1
	drag_reference_forward = Vector3.ZERO
	drag_reference_right = Vector3.ZERO
	_hide_indicator()
	_update_power_meter(0.0, false)


func _can_receive_input() -> bool:
	return is_turn and not get_tree().paused and not _is_input_locked_by_motion()


func _pointer_over_ui() -> bool:
	return get_viewport().gui_get_hovered_control() != null


func _is_left_screen_area(pointer_position: Vector2) -> bool:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	return pointer_position.x <= viewport_size.x * 0.5


func _is_inside_hold_shoot_button(pointer_position: Vector2) -> bool:
	if hold_shoot_button == null or not is_instance_valid(hold_shoot_button) or not hold_shoot_button.visible:
		return false
	return hold_shoot_button.get_global_rect().has_point(pointer_position)


func _reset_alternate_input_state() -> void:
	split_aiming = false
	split_shooting = false
	split_aim_touch_index = -1
	split_shoot_touch_index = -1
	split_aim_horizontal_offset = 0.0
	split_shoot_vertical_offset = 0.0
	press_aiming = false
	press_charging = false
	press_aim_touch_index = -1
	press_aim_horizontal_offset = 0.0
	press_charge_time = 0.0
	press_charge_direction = 1.0
	hold_shoot_touch_index = -1
	hold_shoot_mouse_active = false
	_update_hold_shoot_button_label(0.0)


func _show_split_watermark() -> void:
	_ensure_split_watermark()
	if split_watermark_layer == null:
		return
	split_watermark_timer = maxf(split_watermark_seconds, 0.0)
	split_watermark_shown_this_turn = true
	split_watermark_layer.visible = split_watermark_timer > 0.0
	split_watermark_layer.modulate = Color(1.0, 1.0, 1.0, clampf(split_watermark_alpha, 0.0, 1.0))


func _hide_split_watermark() -> void:
	split_watermark_timer = 0.0
	if split_watermark_layer != null and is_instance_valid(split_watermark_layer):
		split_watermark_layer.visible = false
		split_watermark_layer.modulate = Color(1.0, 1.0, 1.0, 0.0)


func _update_split_watermark(delta: float) -> void:
	if _get_shooting_mechanic() != SHOOTING_MECHANIC_SPLIT or not is_turn or get_tree().paused:
		_hide_split_watermark()
		return

	if not split_watermark_shown_this_turn:
		_show_split_watermark()

	_ensure_split_watermark()
	if split_watermark_layer == null or not split_watermark_layer.visible:
		return

	split_watermark_timer = maxf(split_watermark_timer - delta, 0.0)
	var fade_window: float = minf(1.0, maxf(split_watermark_seconds, 0.0))
	var alpha: float = clampf(split_watermark_alpha, 0.0, 1.0)
	if fade_window > 0.0:
		alpha *= clampf(split_watermark_timer / fade_window, 0.0, 1.0) if split_watermark_timer < fade_window else 1.0
	split_watermark_layer.modulate = Color(1.0, 1.0, 1.0, alpha)
	if split_watermark_timer <= 0.0:
		_hide_split_watermark()


func _hide_indicator() -> void:
	for segment in indicator_segments:
		segment.visible = false
	if arrow_tip:
		arrow_tip.visible = false
	current_aim_direction = Vector3.ZERO
	current_shot_ratio = 0.0
	current_shot_impulse = 0.0
	current_shot_lift = 0.0


func update_path_indicator(current_pos: Vector2) -> void:
	last_drag_position = current_pos
	var raw_drag_vector := current_pos - drag_start
	var aim_response := _get_aim_response_factor()
	if smoothed_drag_vector == Vector2.ZERO:
		smoothed_drag_vector = raw_drag_vector
	else:
		var smoothing_weight := clampf(drag_input_smoothing * aim_response, 0.01, 1.0)
		smoothed_drag_vector = smoothed_drag_vector.lerp(raw_drag_vector, smoothing_weight)
	var drag_vector := smoothed_drag_vector
	if not _cache_shot_from_drag_vector(drag_vector):
		_hide_indicator()
		_update_power_meter(0.0, true)
		return

	_render_current_shot_preview(true)


func _render_current_shot_preview(show_power_meter: bool) -> void:
	if not _is_aim_indicator_allowed() or current_aim_direction == Vector3.ZERO or current_shot_impulse <= 0.0:
		_hide_indicator()
		_update_power_meter(0.0, show_power_meter)
		return

	var preview_impulse := _get_current_preview_impulse()
	var planar_impulse := Vector3(preview_impulse.x, 0.0, preview_impulse.z)
	if planar_impulse.length_squared() <= 0.0001:
		_hide_indicator()
		_update_power_meter(0.0, show_power_meter)
		return

	for segment in indicator_segments:
		segment.visible = true
	if arrow_tip:
		arrow_tip.visible = true

	_update_power_meter(current_shot_ratio, show_power_meter)
	var impulse_ratio: float = clampf(planar_impulse.length() / maxf(max_shot_impulse, 0.001), 0.0, 1.35)
	var path_length: float = clampf(lerpf(1.05, 5.9, current_shot_ratio) * lerpf(0.85, 1.12, impulse_ratio), 0.85, 6.6)
	var curve_ratio: float = _get_curve_ratio(current_shot_ratio)
	var lift_ratio: float = clampf(preview_impulse.y / maxf(max_vertical_shot_impulse, 0.001), 0.0, 1.0)
	var arc_height: float = lerpf(0.02, 0.78, lift_ratio) + lerpf(0.0, 0.18, ease(curve_ratio, 1.2))
	var preview_direction := planar_impulse.normalized()

	var start: Vector3 = global_position + Vector3.UP * 0.12
	var end: Vector3 = start + preview_direction * path_length
	var control: Vector3 = start.lerp(end, 0.5) + Vector3.UP * arc_height

	var points: Array[Vector3] = []
	for index in range(indicator_segment_count + 1):
		var t: float = float(index) / float(indicator_segment_count)
		points.append(_quadratic_bezier(start, control, end, t))

	for index in range(indicator_segment_count):
		var segment := indicator_segments[index]
		var segment_start: Vector3 = points[index]
		var segment_end: Vector3 = points[index + 1]
		var segment_vector: Vector3 = segment_end - segment_start
		var segment_length: float = segment_vector.length()
		if segment_length <= 0.001:
			segment.visible = false
			continue

		segment.visible = true
		segment.mesh = _segment_mesh
		segment.global_transform = Transform3D(
			_basis_from_y(segment_vector.normalized()),
			segment_start.lerp(segment_end, 0.5)
		)

		var thickness: float = lerpf(0.17, 0.06, float(index) / float(max(indicator_segment_count - 1, 1)))
		segment.scale = Vector3(thickness, segment_length, thickness)

	var tip_vector: Vector3 = end - points[indicator_segment_count - 1]
	if tip_vector.length_squared() == 0.0:
		tip_vector = preview_direction
	if arrow_tip:
		arrow_tip.visible = true
		arrow_tip.mesh = _tip_mesh
		arrow_tip.global_transform = Transform3D(
			_basis_from_y(tip_vector.normalized()),
			end
		)
		var tip_scale: float = lerpf(0.18, 0.28, current_shot_ratio)
		arrow_tip.scale = Vector3(tip_scale, _tip_mesh.height, tip_scale)


func handle_shot(start: Vector2, end: Vector2) -> void:
	var drag_vector := end - start
	smoothed_drag_vector = drag_vector
	if not _cache_shot_from_drag_vector(drag_vector):
		return
	_apply_current_shot()


func _get_shot_impulse(vertical_offset: float) -> float:
	var power: float = _get_power_ratio_from_vertical_offset(vertical_offset)
	return lerpf(min_shot_impulse, max_shot_impulse, power)


func _get_shot_ratio(vertical_offset: float) -> float:
	var usable_drag_distance: float = maxf(max_drag_distance - min_drag_length, 1.0)
	var adjusted_drag: float = maxf(absf(vertical_offset) - min_drag_length, 0.0)
	return clampf(adjusted_drag / usable_drag_distance, 0.0, 1.0)


func _get_shoot_sensitivity() -> float:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shoot_sensitivity"):
		return float(customization.call("get_shoot_sensitivity"))
	return 1.0


func _get_shooting_mechanic() -> String:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shooting_mechanic"):
		return str(customization.call("get_shooting_mechanic"))
	return SHOOTING_MECHANIC_DRAG


func _is_aim_inverted() -> bool:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("is_aim_inverted"):
		return bool(customization.call("is_aim_inverted"))
	return false


func _get_sensitivity_ratio() -> float:
	var min_sensitivity: float = 0.5
	var max_sensitivity: float = 1.5
	if is_equal_approx(min_sensitivity, max_sensitivity):
		return 1.0

	return clampf(inverse_lerp(min_sensitivity, max_sensitivity, _get_shoot_sensitivity()), 0.0, 1.0)


func _get_aim_response_factor() -> float:
	var sensitivity_ratio := _get_sensitivity_ratio()
	return lerpf(0.04, 1.0, pow(sensitivity_ratio, 2.6))


func _get_effective_power_ratio(shot_ratio: float) -> float:
	return clampf(pow(clampf(shot_ratio, 0.0, 1.0), power_response_exponent), 0.0, 1.0)


func _get_power_ratio_from_vertical_offset(vertical_offset: float) -> float:
	return _get_effective_power_ratio(_get_shot_ratio(vertical_offset))


func _get_shot_lift(shot_ratio: float) -> float:
	var shaped_ratio := ease(_get_curve_ratio(shot_ratio), 1.15)
	return lerpf(min_shot_lift, max_shot_lift, shaped_ratio)


func _update_split_shot_preview(show_power_meter: bool) -> void:
	if not split_aiming and not split_shooting:
		_hide_indicator()
		_update_power_meter(0.0, show_power_meter)
		return

	var power_ratio: float = 0.28
	if split_shooting:
		power_ratio = _get_power_ratio_from_vertical_offset(split_shoot_vertical_offset)
	if not _cache_shot_from_horizontal_and_power(split_aim_horizontal_offset, power_ratio):
		_hide_indicator()
		_update_power_meter(0.0, show_power_meter)
		return
	_render_current_shot_preview(show_power_meter)


func _update_press_shot_preview(show_power_meter: bool) -> void:
	if not press_aiming and not press_charging:
		_hide_indicator()
		_update_power_meter(0.0, show_power_meter)
		_update_hold_shoot_button_label(0.0)
		return

	var power_ratio: float = 0.32
	if press_charging:
		power_ratio = clampf(press_charge_time / maxf(press_charge_seconds, 0.05), 0.0, 1.0)
	if not _cache_shot_from_horizontal_and_power(press_aim_horizontal_offset, power_ratio):
		_hide_indicator()
		_update_power_meter(0.0, show_power_meter)
		return
	_render_current_shot_preview(show_power_meter)
	_update_hold_shoot_button_label(power_ratio)


func _cache_shot_from_horizontal_and_power(horizontal_offset: float, power_ratio: float) -> bool:
	var target_direction := get_direction_from_drag(Vector2(horizontal_offset, 0.0))
	if target_direction == Vector3.ZERO:
		return false

	if current_aim_direction == Vector3.ZERO:
		current_aim_direction = target_direction
	else:
		current_aim_direction = current_aim_direction.slerp(target_direction, _get_aim_response_factor()).normalized()

	current_shot_ratio = clampf(power_ratio, 0.0, 1.0)
	current_shot_impulse = 0.0 if current_shot_ratio <= 0.0 else lerpf(min_shot_impulse, max_shot_impulse, current_shot_ratio)
	current_shot_lift = _get_shot_lift(current_shot_ratio)
	return true


func _cache_shot_from_drag_vector(drag_vector: Vector2) -> bool:
	var target_direction := get_direction_from_drag(drag_vector)
	if target_direction == Vector3.ZERO:
		return false

	if current_aim_direction == Vector3.ZERO:
		current_aim_direction = target_direction
	else:
		current_aim_direction = current_aim_direction.slerp(target_direction, _get_aim_response_factor()).normalized()

	var vertical_offset: float = drag_vector.y
	current_shot_ratio = _get_power_ratio_from_vertical_offset(vertical_offset)
	current_shot_impulse = _get_shot_impulse(vertical_offset)
	current_shot_lift = _get_shot_lift(current_shot_ratio)
	return true


func _is_aim_indicator_allowed() -> bool:
	match _get_shooting_mechanic():
		SHOOTING_MECHANIC_DRAG:
			return dragging
		SHOOTING_MECHANIC_SPLIT:
			return split_aiming or split_shooting
		SHOOTING_MECHANIC_PRESS:
			return press_aiming or press_charging
		_:
			return false


func _get_current_preview_impulse() -> Vector3:
	var shot_context := _get_hole_shot_context(current_aim_direction)
	var shot_impulse := current_shot_impulse * float(shot_context.get("impulse_multiplier", 1.0))
	var shot_lift := current_shot_lift * float(shot_context.get("lift_multiplier", 1.0))
	var shot_direction: Vector3 = shot_context.get("direction", current_aim_direction)
	return _make_realistic_shot_impulse(shot_direction, shot_impulse, shot_lift)


func _apply_current_shot() -> void:
	if current_aim_direction == Vector3.ZERO or current_shot_impulse <= 0.0:
		return

	var shot_context := _get_hole_shot_context(current_aim_direction)
	var shot_impulse := current_shot_impulse * float(shot_context.get("impulse_multiplier", 1.0))
	var shot_lift := current_shot_lift * float(shot_context.get("lift_multiplier", 1.0))
	var shot_direction: Vector3 = shot_context.get("direction", current_aim_direction)
	sleeping = false
	apply_central_impulse(_make_realistic_shot_impulse(shot_direction, shot_impulse, shot_lift))
	_clamp_upward_velocity()

	is_turn = false
	dragging = false
	active_touch_index = -1
	_reset_alternate_input_state()
	_hide_indicator()
	_update_power_meter(0.0, false)
	_update_hold_shoot_button_visibility()
	if turn_manager and turn_manager.has_method("notify_player_shot"):
		turn_manager.notify_player_shot()


func _make_realistic_shot_impulse(shot_direction: Vector3, shot_impulse: float, shot_lift: float) -> Vector3:
	var planar_direction := Vector3(shot_direction.x, 0.0, shot_direction.z)
	if planar_direction.length_squared() <= 0.0001:
		planar_direction = Vector3(current_aim_direction.x, 0.0, current_aim_direction.z)
	if planar_direction.length_squared() <= 0.0001:
		planar_direction = Vector3.FORWARD
	planar_direction = planar_direction.normalized()

	var directional_lift := maxf(shot_direction.y, 0.0) * shot_impulse
	var vertical_impulse := minf(shot_lift + directional_lift, max_vertical_shot_impulse)
	return planar_direction * shot_impulse + Vector3.UP * vertical_impulse


func _clamp_upward_velocity() -> void:
	if linear_velocity.y > max_upward_velocity:
		var clamped_velocity := linear_velocity
		clamped_velocity.y = max_upward_velocity
		linear_velocity = clamped_velocity


func _get_hole_shot_context(base_direction: Vector3) -> Dictionary:
	var hole: Node3D = _get_hole_node()
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
	var lift_multiplier := lerpf(2.0, 2.65, depth_ratio)
	var impulse_multiplier := lerpf(1.18, 1.32, depth_ratio)
	return {"direction": adjusted_direction, "lift_multiplier": lift_multiplier, "impulse_multiplier": impulse_multiplier}


func _get_hole_node() -> Node3D:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return null
	return scene_root.get_node_or_null("Hole") as Node3D


func _get_curve_ratio(shot_ratio: float) -> float:
	if shot_ratio <= curve_start_ratio:
		return 0.0

	return clampf((shot_ratio - curve_start_ratio) / (1.0 - curve_start_ratio), 0.0, 1.0)


func _update_power_meter(power_ratio: float, visible: bool) -> void:
	if power_bar == null:
		return

	if power_glass:
		power_glass.visible = visible
	power_bar.visible = visible
	if power_label:
		power_label.visible = visible

	power_bar.value = lerpf(power_bar.value, clampf(power_ratio, 0.0, 1.0) * 100.0, 0.28)
	if power_label:
		power_label.text = "%d%%" % int(round(power_bar.value))


func _update_hold_shoot_button_visibility() -> void:
	if hold_shoot_button == null or not is_instance_valid(hold_shoot_button):
		return

	var should_show := _get_shooting_mechanic() == SHOOTING_MECHANIC_PRESS and is_turn and not get_tree().paused and not _is_input_locked_by_motion()
	hold_shoot_button.visible = should_show
	hold_shoot_button.disabled = not should_show
	if not should_show and press_charging:
		_cancel_press_shot()


func _update_hold_shoot_button_label(power_ratio: float) -> void:
	if hold_shoot_button == null or not is_instance_valid(hold_shoot_button):
		return
	if press_charging:
		hold_shoot_button.text = "POWER\n%d%%" % int(round(clampf(power_ratio, 0.0, 1.0) * 100.0))
	else:
		hold_shoot_button.text = "HOLD\nSHOOT"


func _prepare_for_turn() -> void:
	if linear_velocity.length() <= input_ready_velocity_threshold:
		linear_velocity = Vector3.ZERO

	if angular_velocity.length() <= input_ready_velocity_threshold:
		angular_velocity = Vector3.ZERO


func _is_input_locked_by_motion() -> bool:
	return linear_velocity.length() > input_ready_velocity_threshold or angular_velocity.length() > input_ready_velocity_threshold


func is_aiming() -> bool:
	return (dragging or split_aiming or split_shooting or press_aiming or press_charging) and current_aim_direction != Vector3.ZERO


func get_aim_direction() -> Vector3:
	return current_aim_direction


func get_aim_power_ratio() -> float:
	return current_shot_ratio


func _apply_customization() -> void:
	if _is_online_remote_host_proxy():
		return

	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null:
		return

	if marble_visual and marble_visual.has_method("set_palette"):
		marble_visual.set_palette(customization.get_selected_palette())

	if customization.has_method("get_selected_trail_preset"):
		trail_settings = customization.get_selected_trail_preset()
		active_trail_source_path = _get_trail_scene_path()


func _is_online_remote_host_proxy() -> bool:
	if String(name) != "PlayerMarble":
		return false
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("is_online_game") or not bool(online.call("is_online_game")):
		return false
	if online.has_method("is_host") and bool(online.call("is_host")):
		return false
	return true


func _setup_trail_effect_root() -> void:
	if trail_effect_root != null:
		return
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		return
	trail_effect_root = Node3D.new()
	trail_effect_root.name = "%sTrailEffectRoot" % name
	current_scene.add_child(trail_effect_root)


func _update_trail(delta: float) -> void:
	if trail_effect_root == null:
		_setup_trail_effect_root()
	if trail_effect_root == null:
		return

	_sync_trail_settings()
	if not bool(trail_settings.get("enabled", false)):
		_clear_active_trail()
		return

	var speed: float = linear_velocity.length()
	var is_moving_now: bool = speed > 0.42
	if is_moving_now:
		_update_active_trail(speed, delta)
	else:
		_clear_active_trail()


func _sync_trail_settings() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null or not customization.has_method("get_selected_trail_preset"):
		return

	var selected_preset: Dictionary = customization.get_selected_trail_preset()
	var selected_path: String = _get_trail_scene_path_from_preset(selected_preset)
	if selected_path == active_trail_source_path and selected_preset == trail_settings:
		return

	_clear_active_trail()
	active_trail_source_path = selected_path
	trail_settings = selected_preset


func _update_active_trail(speed: float, delta: float) -> void:
	if active_trail_node == null or not is_instance_valid(active_trail_node):
		active_trail_node = _instantiate_trail_segment()
		if active_trail_node == null:
			return
		trail_effect_root.add_child(active_trail_node)

	var move_direction: Vector3 = linear_velocity.normalized()
	if move_direction.length_squared() > 0.0001:
		var blend_weight: float = clampf(delta * 10.0, 0.0, 1.0)
		trail_motion_direction = trail_motion_direction.slerp(move_direction, blend_weight).normalized()
	elif trail_motion_direction.length_squared() <= 0.0001:
		trail_motion_direction = Vector3.FORWARD

	var preset_scale: float = float(trail_settings.get("scale", 0.14))
	var display_scale: float = lerpf(0.72, 1.08, clampf(speed / 8.0, 0.0, 1.0))
	var distance_behind: float = lerpf(0.22, 0.34, clampf(speed / 8.0, 0.0, 1.0))
	active_trail_node.visible = true
	active_trail_node.scale = Vector3.ONE * maxf(preset_scale * display_scale * 4.8, 0.18)
	active_trail_node.global_position = global_position + Vector3.UP * 0.03 - trail_motion_direction * distance_behind
	active_trail_node.look_at(active_trail_node.global_position - trail_motion_direction, Vector3.UP)
	_set_trail_node_alpha(active_trail_node, 1.0, 1.0)


func _clear_active_trail() -> void:
	if active_trail_node != null and is_instance_valid(active_trail_node):
		active_trail_node.queue_free()
	active_trail_node = null


func _instantiate_trail_segment() -> Node3D:
	return _build_procedural_trail()


func _set_trail_node_alpha(root: Node, alpha: float, emission_scale: float) -> void:
	if root is MeshInstance3D:
		var mesh_instance: MeshInstance3D = root as MeshInstance3D
		if mesh_instance.material_override is StandardMaterial3D:
			var override_material: StandardMaterial3D = (mesh_instance.material_override as StandardMaterial3D).duplicate()
			override_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			override_material.albedo_color.a = alpha
			if override_material.emission_enabled:
				override_material.emission_energy_multiplier *= emission_scale
			mesh_instance.material_override = override_material
		elif mesh_instance.mesh != null:
			for surface_index in range(mesh_instance.mesh.get_surface_count()):
				var surface_material: Material = mesh_instance.get_active_material(surface_index)
				if surface_material is StandardMaterial3D:
					var duplicated: StandardMaterial3D = (surface_material as StandardMaterial3D).duplicate()
					duplicated.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					duplicated.albedo_color.a = alpha
					if duplicated.emission_enabled:
						duplicated.emission_energy_multiplier *= emission_scale
					mesh_instance.set_surface_override_material(surface_index, duplicated)

	for child in root.get_children():
		_set_trail_node_alpha(child, alpha, emission_scale)


func _build_procedural_trail() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "ProceduralTrail"

	var primary: Color = trail_settings.get("color", Color(0.42, 0.92, 1.0, 0.34))
	var secondary: Color = trail_settings.get("secondary_color", primary)
	var emission: Color = trail_settings.get("emission", primary)
	var shape: String = str(trail_settings.get("shape", "comet"))

	var body: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.06
	cylinder.bottom_radius = 0.16 if shape == "dust" else 0.12
	cylinder.height = 0.72 if shape == "ribbon" else 0.58
	cylinder.radial_segments = 16
	body.mesh = cylinder
	body.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	body.position = Vector3(0.0, 0.0, 0.2)
	body.material_override = _make_trail_material(primary, emission, 1.5)
	root.add_child(body)

	var tip: MeshInstance3D = MeshInstance3D.new()
	var tip_mesh: SphereMesh = SphereMesh.new()
	tip_mesh.radius = 0.11
	tip_mesh.height = 0.22
	tip.mesh = tip_mesh
	tip.position = Vector3(0.0, 0.0, 0.42)
	tip.material_override = _make_trail_material(primary.lerp(Color.WHITE, 0.18), emission, 1.9)
	root.add_child(tip)

	var glow: MeshInstance3D = MeshInstance3D.new()
	var glow_mesh: SphereMesh = SphereMesh.new()
	glow_mesh.radius = 0.15 if shape == "dust" else 0.13
	glow_mesh.height = glow_mesh.radius * 2.0
	glow.mesh = glow_mesh
	glow.position = Vector3(0.0, 0.0, -0.02)
	glow.material_override = _make_trail_material(secondary, emission, 1.2)
	root.add_child(glow)

	if shape == "spark" or shape == "ribbon":
		var accent: MeshInstance3D = MeshInstance3D.new()
		var accent_mesh: SphereMesh = SphereMesh.new()
		accent_mesh.radius = 0.08
		accent_mesh.height = 0.16
		accent.mesh = accent_mesh
		accent.position = Vector3(0.0, 0.09, 0.12)
		accent.material_override = _make_trail_material(secondary.lerp(emission, 0.4), emission, 2.1)
		root.add_child(accent)

	return root


func _make_trail_material(albedo: Color, emission: Color, energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	material.no_depth_test = false
	material.albedo_color = Color(albedo.r, albedo.g, albedo.b, maxf(albedo.a, 0.24))
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = energy
	return material


func _get_trail_scene_path() -> String:
	return _get_trail_scene_path_from_preset(trail_settings)


func _get_trail_scene_path_from_preset(preset: Dictionary) -> String:
	if not bool(preset.get("enabled", false)):
		return ""

	var shape: String = str(preset.get("shape", "comet"))
	if shape == "dust":
		return TRAIL_MODEL_PATH_B
	return TRAIL_MODEL_PATH_A


func _quadratic_bezier(start: Vector3, control: Vector3, end: Vector3, t: float) -> Vector3:
	var inv_t: float = 1.0 - t
	return inv_t * inv_t * start + 2.0 * inv_t * t * control + t * t * end


func _basis_from_y(direction: Vector3) -> Basis:
	var up_axis: Vector3 = direction.normalized()
	var side_axis: Vector3 = Vector3.FORWARD.cross(up_axis)
	if side_axis.length_squared() == 0.0:
		side_axis = Vector3.RIGHT
	side_axis = side_axis.normalized()
	var forward_axis: Vector3 = up_axis.cross(side_axis).normalized()
	return Basis(side_axis, up_axis, forward_axis)


func get_direction_from_drag(drag: Vector2) -> Vector3:
	var active_camera := get_viewport().get_camera_3d()
	if active_camera:
		camera = active_camera
	if not _ensure_drag_reference_axes():
		return Vector3.ZERO

	var horizontal_drag: float = -drag.x if _is_aim_inverted() else drag.x
	var horizontal_ratio := clampf(horizontal_drag / maxf(max_drag_distance, 1.0), -1.0, 1.0)
	var yaw_offset := horizontal_ratio * _get_aim_turn_range_radians()
	var aimed_direction := drag_reference_forward.rotated(Vector3.UP, yaw_offset)
	aimed_direction.y = 0.0
	if aimed_direction.length_squared() <= 0.0001:
		return drag_reference_forward

	return aimed_direction.normalized()


func _capture_drag_reference_axes() -> void:
	drag_reference_forward = Vector3.ZERO
	drag_reference_right = Vector3.ZERO
	_ensure_drag_reference_axes()


func _ensure_drag_reference_axes() -> bool:
	if drag_reference_forward.length_squared() > 0.0001 and drag_reference_right.length_squared() > 0.0001:
		return true

	if camera == null:
		return false

	var cam_transform := camera.global_transform
	var cam_forward := -cam_transform.basis.z
	var cam_right := cam_transform.basis.x
	cam_forward.y = 0.0
	cam_right.y = 0.0

	if cam_forward.length_squared() <= 0.0001 or cam_right.length_squared() <= 0.0001:
		return false

	drag_reference_forward = cam_forward.normalized()
	drag_reference_right = cam_right.normalized()
	return true


func _get_aim_turn_range_radians() -> float:
	return deg_to_rad(max_aim_turn_degrees * 0.5)
