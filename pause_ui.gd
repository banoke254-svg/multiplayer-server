extends Control

const GLASS_BUTTON_EFFECTS = preload("res://glass_button_effects.gd")
const SHOOTING_MECHANIC_DRAG_IMAGE_PATH: String = "res://ui/shoot_mechanic_drag.png"
const SHOOTING_MECHANIC_SPLIT_IMAGE_PATH: String = "res://ui/shoot_mechanic_split.png"
const SHOOTING_MECHANIC_HOLD_IMAGE_PATH: String = "res://ui/shoot_mechanic_hold.png"

@export_file("*.tscn") var main_menu_scene_path: String = "res://Start_Menu.tscn"

@onready var pause_button: Button = $TopBar/PauseButton
@onready var settings_button: Button = $TopBar/SettingsButton

@onready var pause_overlay: ColorRect = $PauseOverlay
@onready var resume_button: Button = $PauseOverlay/Panel/VBoxContainer/ResumeButton
@onready var open_settings_button: Button = $PauseOverlay/Panel/VBoxContainer/OpenSettingsButton
@onready var pause_menu_button: Button = $PauseOverlay/Panel/VBoxContainer/MainMenuButton

@onready var settings_overlay: ColorRect = $SettingsOverlay
@onready var master_slider: HSlider = $SettingsOverlay/Panel/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $SettingsOverlay/Panel/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $SettingsOverlay/Panel/VBoxContainer/SfxSlider
@onready var shoot_sensitivity_slider: HSlider = $SettingsOverlay/Panel/VBoxContainer/ShootSensitivitySlider
@onready var close_settings_button: Button = $SettingsOverlay/Panel/VBoxContainer/Buttons/CloseSettingsButton
@onready var settings_menu_button: Button = $SettingsOverlay/Panel/VBoxContainer/Buttons/MainMenuButton

var shooting_mechanics_button: Button = null
var shooting_mechanics_popup: ColorRect = null
var settings_scroll: ScrollContainer = null
var settings_touch_scroll_last_positions: Dictionary = {}
var settings_panel: Panel = null
var settings_stack: VBoxContainer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.pressed.connect(_toggle_pause)
	settings_button.pressed.connect(_open_settings_overlay)
	resume_button.pressed.connect(_resume_game)
	open_settings_button.pressed.connect(_open_settings_overlay)
	pause_menu_button.pressed.connect(_go_to_main_menu)
	close_settings_button.pressed.connect(_close_settings_overlay)
	settings_menu_button.pressed.connect(_go_to_main_menu)
	get_viewport().size_changed.connect(_layout_settings_panel)
	_ensure_settings_scroll_area()
	_bind_slider(master_slider, "Master")
	_bind_slider(music_slider, "Music")
	_bind_slider(sfx_slider, "SFX")
	_bind_shoot_sensitivity_slider()
	_ensure_shooting_mechanics_controls()
	_refresh_settings_touch_scroll_bindings()
	_layout_settings_panel()
	_style_settings_overlay()
	_style_buttons()
	_sync_audio_sliders()
	_sync_shoot_sensitivity_slider()
	_refresh_shooting_mechanics_button()
	_sync_pause_state()
	GLASS_BUTTON_EFFECTS.apply_to_tree(self)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if shooting_mechanics_popup != null and shooting_mechanics_popup.visible:
			shooting_mechanics_popup.hide()
		elif settings_overlay.visible:
			_close_settings_overlay()
		else:
			_toggle_pause()


func _toggle_pause() -> void:
	if get_tree().paused and not settings_overlay.visible:
		_resume_game()
	else:
		_pause_game()


func _pause_game() -> void:
	settings_overlay.hide()
	pause_overlay.visible = true
	get_tree().paused = true
	_sync_pause_state()


func _resume_game() -> void:
	get_tree().paused = false
	pause_overlay.visible = false
	settings_overlay.visible = false
	_sync_pause_state()


func _open_settings_overlay() -> void:
	get_tree().paused = true
	pause_overlay.visible = false
	settings_overlay.visible = true
	_layout_settings_panel()
	_refresh_settings_touch_scroll_bindings()
	_sync_audio_sliders()
	_sync_shoot_sensitivity_slider()
	_refresh_shooting_mechanics_button()
	_sync_pause_state()


func _close_settings_overlay() -> void:
	if shooting_mechanics_popup != null:
		shooting_mechanics_popup.hide()
	settings_overlay.visible = false
	if get_tree().paused:
		pause_overlay.visible = true
	_sync_pause_state()


func _go_to_main_menu() -> void:
	get_tree().paused = false
	var target_scene: String = main_menu_scene_path
	if target_scene == "" or not ResourceLoader.exists(target_scene):
		target_scene = "res://Start_Menu.tscn"
	if target_scene != "" and ResourceLoader.exists(target_scene):
		get_tree().change_scene_to_file(target_scene)


func _sync_pause_state() -> void:
	pause_button.text = "Resume" if get_tree().paused and not settings_overlay.visible else "Pause"


func _get_settings_stack() -> VBoxContainer:
	var stack: VBoxContainer = settings_overlay.get_node_or_null("Panel/SettingsScroll/VBoxContainer") as VBoxContainer
	if stack != null:
		return stack
	return settings_overlay.get_node_or_null("Panel/VBoxContainer") as VBoxContainer


func _ensure_settings_scroll_area() -> void:
	var panel: Panel = settings_overlay.get_node_or_null("Panel") as Panel
	var stack: VBoxContainer = _get_settings_stack()
	if panel == null or stack == null:
		return
	settings_panel = panel
	settings_stack = stack

	settings_scroll = panel.get_node_or_null("SettingsScroll") as ScrollContainer
	if settings_scroll == null:
		settings_scroll = ScrollContainer.new()
		settings_scroll.name = "SettingsScroll"
		settings_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
		settings_scroll.offset_left = 30.0
		settings_scroll.offset_top = 24.0
		settings_scroll.offset_right = -30.0
		settings_scroll.offset_bottom = -24.0
		settings_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		settings_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		settings_scroll.follow_focus = true
		settings_scroll.scroll_deadzone = 4
		settings_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.add_child(settings_scroll)

		var old_parent: Node = stack.get_parent()
		if old_parent != null:
			old_parent.remove_child(stack)
		settings_scroll.add_child(stack)
		stack.set_anchors_preset(Control.PRESET_TOP_LEFT)
		stack.offset_left = 0.0
		stack.offset_top = 0.0
		stack.offset_right = 0.0
		stack.offset_bottom = 0.0
		stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stack.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	else:
		settings_scroll.offset_left = 30.0
		settings_scroll.offset_top = 24.0
		settings_scroll.offset_right = -30.0
		settings_scroll.offset_bottom = -24.0
		settings_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		settings_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		settings_scroll.follow_focus = true
		settings_scroll.scroll_deadzone = 4
		settings_scroll.mouse_filter = Control.MOUSE_FILTER_STOP

	var scroll_input_callable: Callable = Callable(self, "_on_settings_touch_scroll_gui_input").bind(settings_scroll, settings_scroll)
	if not settings_scroll.gui_input.is_connected(scroll_input_callable):
		settings_scroll.gui_input.connect(scroll_input_callable)


func _layout_settings_panel() -> void:
	if settings_overlay == null:
		return
	var panel: Panel = settings_overlay.get_node_or_null("Panel") as Panel
	if panel == null:
		return
	settings_panel = panel
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_width: float = clampf(viewport_size.x - 32.0, 460.0, 660.0)
	var panel_height: float = clampf(viewport_size.y - 34.0, 420.0, 540.0)
	if viewport_size.x < 500.0:
		panel_width = maxf(viewport_size.x - 20.0, 320.0)
	if viewport_size.y < 450.0:
		panel_height = maxf(viewport_size.y - 20.0, 360.0)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -panel_width * 0.5
	panel.offset_right = panel_width * 0.5
	panel.offset_top = -panel_height * 0.5
	panel.offset_bottom = panel_height * 0.5

	if settings_scroll != null:
		var horizontal_margin: float = 32.0 if panel_width >= 520.0 else 22.0
		settings_scroll.offset_left = horizontal_margin
		settings_scroll.offset_top = 24.0
		settings_scroll.offset_right = -horizontal_margin
		settings_scroll.offset_bottom = -24.0


func _refresh_settings_touch_scroll_bindings() -> void:
	_ensure_settings_scroll_area()
	var stack: VBoxContainer = _get_settings_stack()
	if stack == null or settings_scroll == null:
		return
	_bind_settings_touch_scroll_control(stack, settings_scroll)
	for child in stack.get_children():
		_bind_settings_touch_scroll_descendants(child, settings_scroll)


func _bind_settings_touch_scroll_descendants(node: Node, scroll: ScrollContainer) -> void:
	var control: Control = node as Control
	if control != null:
		_bind_settings_touch_scroll_control(control, scroll)
	for child in node.get_children():
		_bind_settings_touch_scroll_descendants(child, scroll)


func _bind_settings_touch_scroll_control(control: Control, scroll: ScrollContainer) -> void:
	if control == null or scroll == null:
		return
	if control.mouse_filter == Control.MOUSE_FILTER_STOP and not (control is Button) and not (control is LineEdit) and not (control is HSlider):
		control.mouse_filter = Control.MOUSE_FILTER_PASS
	var scroll_input_callable: Callable = Callable(self, "_on_settings_touch_scroll_gui_input").bind(scroll, control)
	if not control.gui_input.is_connected(scroll_input_callable):
		control.gui_input.connect(scroll_input_callable)


func _on_settings_touch_scroll_gui_input(event: InputEvent, scroll: ScrollContainer, source_control: Control) -> void:
	if scroll == null:
		return
	var scroll_key: int = scroll.get_instance_id()
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			settings_touch_scroll_last_positions[scroll_key] = touch_event.position
		else:
			settings_touch_scroll_last_positions.erase(scroll_key)
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if source_control is HSlider and absf(drag_event.relative.x) > absf(drag_event.relative.y):
			return
		if absf(drag_event.relative.y) < 1.0:
			return
		scroll.scroll_vertical = maxi(0, scroll.scroll_vertical - int(round(drag_event.relative.y)))
		settings_touch_scroll_last_positions[scroll_key] = drag_event.position
		scroll.accept_event()
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_button.pressed:
			settings_touch_scroll_last_positions[scroll_key] = mouse_button.position
		else:
			settings_touch_scroll_last_positions.erase(scroll_key)
	elif event is InputEventMouseMotion and settings_touch_scroll_last_positions.has(scroll_key) and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		var last_position: Vector2 = settings_touch_scroll_last_positions.get(scroll_key, mouse_motion.position)
		var motion_delta: Vector2 = mouse_motion.position - last_position
		settings_touch_scroll_last_positions[scroll_key] = mouse_motion.position
		if source_control is HSlider and absf(motion_delta.x) > absf(motion_delta.y):
			return
		if absf(motion_delta.y) >= 1.0:
			scroll.scroll_vertical = maxi(0, scroll.scroll_vertical - int(round(motion_delta.y)))
			scroll.accept_event()


func _bind_slider(slider: HSlider, bus_name: String) -> void:
	if slider == null:
		return
	slider.value = _get_bus_slider_value(bus_name)
	if not slider.value_changed.is_connected(_on_slider_changed.bind(bus_name)):
		slider.value_changed.connect(_on_slider_changed.bind(bus_name))


func _sync_audio_sliders() -> void:
	if master_slider:
		master_slider.value = _get_bus_slider_value("Master")
	if music_slider:
		music_slider.value = _get_bus_slider_value("Music")
	if sfx_slider:
		sfx_slider.value = _get_bus_slider_value("SFX")


func _bind_shoot_sensitivity_slider() -> void:
	if shoot_sensitivity_slider == null:
		return

	shoot_sensitivity_slider.value = _get_shoot_sensitivity_value()
	if not shoot_sensitivity_slider.value_changed.is_connected(_on_shoot_sensitivity_changed):
		shoot_sensitivity_slider.value_changed.connect(_on_shoot_sensitivity_changed)


func _sync_shoot_sensitivity_slider() -> void:
	if shoot_sensitivity_slider:
		shoot_sensitivity_slider.value = _get_shoot_sensitivity_value()


func _ensure_shooting_mechanics_controls() -> void:
	var stack: VBoxContainer = _get_settings_stack()
	if stack == null:
		return

	settings_stack = stack
	_layout_settings_panel()

	var buttons_row: Node = stack.get_node_or_null("Buttons")
	if shooting_mechanics_button == null:
		var label: Label = Label.new()
		label.name = "ShootingMechanicsLabel"
		label.text = "Shooting Mechanics"
		stack.add_child(label)
		if buttons_row != null:
			stack.move_child(label, buttons_row.get_index())

		shooting_mechanics_button = Button.new()
		shooting_mechanics_button.name = "ShootingMechanicsButton"
		shooting_mechanics_button.custom_minimum_size = Vector2(0, 44)
		stack.add_child(shooting_mechanics_button)
		if buttons_row != null:
			stack.move_child(shooting_mechanics_button, buttons_row.get_index())
		shooting_mechanics_button.pressed.connect(_open_shooting_mechanics_popup)

	_ensure_shooting_mechanics_popup()
	_style_settings_overlay()


func _ensure_shooting_mechanics_popup() -> void:
	if shooting_mechanics_popup != null:
		return

	shooting_mechanics_popup = ColorRect.new()
	shooting_mechanics_popup.name = "ShootingMechanicsPopup"
	shooting_mechanics_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	shooting_mechanics_popup.color = Color(0.0, 0.0, 0.0, 0.62)
	shooting_mechanics_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	shooting_mechanics_popup.z_index = 40
	shooting_mechanics_popup.hide()
	add_child(shooting_mechanics_popup)

	var panel: Panel = Panel.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -430.0
	panel.offset_top = -220.0
	panel.offset_right = 430.0
	panel.offset_bottom = 220.0
	panel.add_theme_stylebox_override("panel", _make_settings_panel_style(Color(0.03, 0.05, 0.12, 0.96), Color(0.72, 0.36, 1.0, 1.0)))
	shooting_mechanics_popup.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.name = "MarginContainer"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.name = "VBoxContainer"
	stack.add_theme_constant_override("separation", 14)
	margin.add_child(stack)

	var title: Label = Label.new()
	title.text = "SHOOTING MECHANICS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	stack.add_child(title)

	var cards: HBoxContainer = HBoxContainer.new()
	cards.name = "Cards"
	cards.add_theme_constant_override("separation", 12)
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(cards)

	var close_button: Button = Button.new()
	close_button.text = "CLOSE"
	close_button.custom_minimum_size = Vector2(0, 46)
	_style_overlay_button(close_button)
	stack.add_child(close_button)
	close_button.pressed.connect(func(): shooting_mechanics_popup.hide())


func _open_shooting_mechanics_popup() -> void:
	_ensure_shooting_mechanics_popup()
	_rebuild_shooting_mechanics_cards()
	shooting_mechanics_popup.show()


func _rebuild_shooting_mechanics_cards() -> void:
	if shooting_mechanics_popup == null:
		return
	var cards: HBoxContainer = shooting_mechanics_popup.get_node_or_null("Panel/MarginContainer/VBoxContainer/Cards") as HBoxContainer
	if cards == null:
		return
	for child in cards.get_children():
		child.queue_free()

	var selected_id: String = _get_selected_shooting_mechanic_id()
	for option in _get_shooting_mechanic_options():
		var option_dict: Dictionary = option if typeof(option) == TYPE_DICTIONARY else {}
		var option_id: String = str(option_dict.get("id", "drag"))
		var card: Button = _create_shooting_mechanic_card(option_dict, option_id == selected_id)
		cards.add_child(card)
		card.pressed.connect(_on_shooting_mechanic_option_pressed.bind(option_id))


func _create_shooting_mechanic_card(option: Dictionary, selected: bool) -> Button:
	var card: Button = Button.new()
	card.text = ""
	card.focus_mode = Control.FOCUS_NONE
	card.custom_minimum_size = Vector2(0, 220)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var accent: Color = Color(1.0, 0.82, 0.2, 1.0) if selected else Color(0.34, 0.95, 1.0, 1.0)
	card.add_theme_stylebox_override("normal", _make_settings_panel_style(Color(0.025, 0.04, 0.09, 0.92), accent))
	card.add_theme_stylebox_override("hover", _make_settings_panel_style(Color(0.05, 0.075, 0.15, 0.96), accent.lightened(0.12)))
	card.add_theme_stylebox_override("pressed", _make_settings_panel_style(Color(0.015, 0.025, 0.065, 0.98), accent.darkened(0.1)))

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)

	var preview: TextureRect = TextureRect.new()
	preview.custom_minimum_size = Vector2(0, 112)
	preview.texture = _get_shooting_mechanic_preview_texture(str(option.get("id", "drag")))
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stack.add_child(preview)

	var name_label: Label = Label.new()
	name_label.text = str(option.get("name", "Classic Drag")).to_upper()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	stack.add_child(name_label)

	var description: Label = Label.new()
	description.text = str(option.get("description", ""))
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 12)
	description.add_theme_color_override("font_color", Color(0.8, 0.88, 1.0, 0.9))
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(description)

	var status: Label = Label.new()
	status.text = "SELECTED" if selected else "TAP TO USE"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 12)
	status.add_theme_color_override("font_color", Color(1.0, 0.86, 0.28, 1.0) if selected else Color(0.66, 0.86, 1.0, 0.9))
	stack.add_child(status)
	return card


func _on_slider_changed(value: float, bus_name: String) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(maxf(value, 0.001)))


func _on_shoot_sensitivity_changed(value: float) -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("set_shoot_sensitivity"):
		customization.call("set_shoot_sensitivity", value)


func _on_shooting_mechanic_option_pressed(mechanic_id: String) -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("set_shooting_mechanic"):
		customization.call("set_shooting_mechanic", mechanic_id)
	_refresh_shooting_mechanics_button()
	_rebuild_shooting_mechanics_cards()


func _refresh_shooting_mechanics_button() -> void:
	if shooting_mechanics_button != null:
		shooting_mechanics_button.text = _get_selected_shooting_mechanic_name().to_upper()


func _get_selected_shooting_mechanic_id() -> String:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shooting_mechanic"):
		return str(customization.call("get_shooting_mechanic"))
	return "drag"


func _get_selected_shooting_mechanic_name() -> String:
	var selected_id: String = _get_selected_shooting_mechanic_id()
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shooting_mechanic_name"):
		return str(customization.call("get_shooting_mechanic_name", selected_id))
	for option in _get_shooting_mechanic_options():
		var option_dict: Dictionary = option if typeof(option) == TYPE_DICTIONARY else {}
		if str(option_dict.get("id", "")) == selected_id:
			return str(option_dict.get("name", "Classic Drag"))
	return "Classic Drag"


func _get_shooting_mechanic_options() -> Array:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shooting_mechanic_options"):
		var options: Variant = customization.call("get_shooting_mechanic_options")
		if typeof(options) == TYPE_ARRAY:
			return options
	return [
		{"id": "drag", "name": "Classic Drag", "description": "Drag from the marble to aim and set power."},
		{"id": "split", "name": "Split Control", "description": "Left side aims. Right side controls shot power."},
		{"id": "press", "name": "Hold Button", "description": "Aim freely, then release as the power bar cycles."}
	]


func _get_bus_slider_value(bus_name: String) -> float:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return 0.5
	return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))


func _get_shoot_sensitivity_value() -> float:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shoot_sensitivity"):
		return float(customization.call("get_shoot_sensitivity"))
	return 1.0


func _get_shooting_mechanic_preview_texture(mechanic_id: String) -> Texture2D:
	var texture_path: String = SHOOTING_MECHANIC_DRAG_IMAGE_PATH
	match mechanic_id:
		"split":
			texture_path = SHOOTING_MECHANIC_SPLIT_IMAGE_PATH
		"press":
			texture_path = SHOOTING_MECHANIC_HOLD_IMAGE_PATH
		_:
			texture_path = SHOOTING_MECHANIC_DRAG_IMAGE_PATH
	var texture := load(texture_path)
	if texture is Texture2D:
		return texture as Texture2D
	return _create_shooting_mechanic_preview_texture(mechanic_id)


func _create_shooting_mechanic_preview_texture(mechanic_id: String) -> Texture2D:
	var width: int = 220
	var height: int = 110
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.015, 0.02, 0.055, 1.0))
	_preview_draw_rect(image, Rect2i(8, 8, width - 16, height - 16), Color(0.035, 0.06, 0.13, 1.0))
	_preview_draw_line(image, Vector2(16, height - 16), Vector2(width - 16, height - 16), Color(0.42, 0.25, 0.9, 0.72), 2)
	var half_width: int = int(width * 0.5)

	if mechanic_id == "split":
		_preview_draw_rect(image, Rect2i(10, 10, half_width - 10, height - 20), Color(0.02, 0.16, 0.17, 0.62))
		_preview_draw_rect(image, Rect2i(half_width, 10, half_width - 10, height - 20), Color(0.13, 0.04, 0.18, 0.62))
		_preview_draw_line(image, Vector2(half_width, 12), Vector2(half_width, height - 14), Color(0.92, 0.95, 1.0, 0.42), 2)
		_preview_draw_circle(image, Vector2(54, 70), 12, Color(0.35, 0.96, 0.92, 1.0))
		_preview_draw_line(image, Vector2(54, 70), Vector2(92, 40), Color(0.35, 0.96, 0.92, 1.0), 4)
		_preview_draw_circle(image, Vector2(166, 72), 12, Color(1.0, 0.82, 0.2, 1.0))
		_preview_draw_line(image, Vector2(166, 72), Vector2(166, 34), Color(1.0, 0.82, 0.2, 1.0), 5)
	elif mechanic_id == "press":
		_preview_draw_circle(image, Vector2(54, 70), 12, Color(0.35, 0.96, 0.92, 1.0))
		_preview_draw_line(image, Vector2(54, 70), Vector2(126, 38), Color(0.35, 0.96, 0.92, 1.0), 4)
		_preview_draw_ring(image, Vector2(174, 72), 30, Color(0.75, 0.34, 1.0, 0.9), 6)
		_preview_draw_ring(image, Vector2(174, 72), 18, Color(1.0, 0.82, 0.2, 0.95), 5)
	else:
		_preview_draw_circle(image, Vector2(58, 72), 12, Color(0.35, 0.96, 0.92, 1.0))
		_preview_draw_line(image, Vector2(58, 72), Vector2(146, 36), Color(0.35, 0.96, 0.92, 1.0), 4)
		_preview_draw_line(image, Vector2(58, 72), Vector2(108, 94), Color(1.0, 0.82, 0.2, 1.0), 5)
		_preview_draw_ring(image, Vector2(146, 36), 18, Color(0.75, 0.34, 1.0, 0.8), 3)

	return ImageTexture.create_from_image(image)


func _preview_draw_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(maxi(rect.position.y, 0), mini(rect.position.y + rect.size.y, image.get_height())):
		for x in range(maxi(rect.position.x, 0), mini(rect.position.x + rect.size.x, image.get_width())):
			image.set_pixel(x, y, color)


func _preview_draw_line(image: Image, start: Vector2, end: Vector2, color: Color, thickness: int) -> void:
	var steps: int = maxi(int(ceil(start.distance_to(end))), 1)
	for index in range(steps + 1):
		var point: Vector2 = start.lerp(end, float(index) / float(steps))
		_preview_draw_circle(image, point, thickness, color)


func _preview_draw_circle(image: Image, center: Vector2, radius: int, color: Color) -> void:
	var radius_squared: int = radius * radius
	for y in range(int(center.y) - radius, int(center.y) + radius + 1):
		for x in range(int(center.x) - radius, int(center.x) + radius + 1):
			var dx: int = x - int(center.x)
			var dy: int = y - int(center.y)
			if dx * dx + dy * dy <= radius_squared and x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
				image.set_pixel(x, y, color)


func _preview_draw_ring(image: Image, center: Vector2, radius: int, color: Color, thickness: int) -> void:
	var inner_radius: int = maxi(radius - thickness, 0)
	var outer_squared: int = radius * radius
	var inner_squared: int = inner_radius * inner_radius
	for y in range(int(center.y) - radius, int(center.y) + radius + 1):
		for x in range(int(center.x) - radius, int(center.x) + radius + 1):
			var dx: int = x - int(center.x)
			var dy: int = y - int(center.y)
			var dist_squared: int = dx * dx + dy * dy
			if dist_squared <= outer_squared and dist_squared >= inner_squared and x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
				image.set_pixel(x, y, color)


func _style_settings_overlay() -> void:
	var panel: Panel = settings_panel if settings_panel != null else settings_overlay.get_node_or_null("Panel") as Panel
	if panel != null:
		panel.add_theme_stylebox_override("panel", _make_settings_panel_style(Color(0.025, 0.055, 0.065, 0.86), Color(0.33, 1.0, 0.88, 0.95)))

	var stack: VBoxContainer = _get_settings_stack()
	if stack != null:
		settings_stack = stack
		stack.add_theme_constant_override("separation", 16)

	var title: Label = settings_overlay.get_node_or_null("Panel/SettingsScroll/VBoxContainer/Title") as Label
	if title == null:
		title = settings_overlay.get_node_or_null("Panel/VBoxContainer/Title") as Label
	if title != null:
		title.text = "SETTINGS"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 21)
		title.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
		title.add_theme_color_override("font_shadow_color", Color(0.47, 0.25, 0.95, 0.85))
		title.add_theme_constant_override("shadow_offset_x", 2)
		title.add_theme_constant_override("shadow_offset_y", 2)
		title.add_theme_constant_override("shadow_outline_size", 2)

	for label in [
		settings_overlay.get_node_or_null("Panel/SettingsScroll/VBoxContainer/MasterLabel") as Label,
		settings_overlay.get_node_or_null("Panel/SettingsScroll/VBoxContainer/MusicLabel") as Label,
		settings_overlay.get_node_or_null("Panel/SettingsScroll/VBoxContainer/SfxLabel") as Label,
		settings_overlay.get_node_or_null("Panel/SettingsScroll/VBoxContainer/ShootSensitivityLabel") as Label,
		settings_overlay.get_node_or_null("Panel/SettingsScroll/VBoxContainer/ShootingMechanicsLabel") as Label
	]:
		_style_settings_label(label)

	for slider in [master_slider, music_slider, sfx_slider, shoot_sensitivity_slider]:
		_style_settings_slider(slider)

	var buttons_row: HBoxContainer = settings_overlay.get_node_or_null("Panel/SettingsScroll/VBoxContainer/Buttons") as HBoxContainer
	if buttons_row == null:
		buttons_row = settings_overlay.get_node_or_null("Panel/VBoxContainer/Buttons") as HBoxContainer
	if buttons_row != null:
		buttons_row.add_theme_constant_override("separation", 16)
		buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER


func _style_settings_label(label: Label) -> void:
	if label == null:
		return
	label.text = label.text.to_upper()
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.43, 0.22, 0.86, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_constant_override("shadow_outline_size", 1)


func _style_settings_slider(slider: HSlider) -> void:
	if slider == null:
		return
	slider.custom_minimum_size = Vector2(0.0, 26.0)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.add_theme_stylebox_override("slider", _make_slider_track_style(Color(0.72, 0.82, 0.8, 0.72), 4))
	slider.add_theme_stylebox_override("grabber_area", _make_slider_track_style(Color(0.36, 1.0, 0.88, 0.95), 4))
	slider.add_theme_stylebox_override("grabber_area_highlight", _make_slider_track_style(Color(0.95, 0.82, 0.22, 1.0), 4))


func _style_buttons() -> void:
	_style_top_button(pause_button, Color(0.34, 0.95, 1.0, 1.0))
	_style_top_button(settings_button, Color(0.72, 0.8, 0.92, 1.0))

	for button in [
		resume_button,
		open_settings_button,
		pause_menu_button,
		shooting_mechanics_button,
		close_settings_button,
		settings_menu_button
	]:
		if button == null:
			continue
		button.custom_minimum_size = Vector2(maxf(button.custom_minimum_size.x, 120.0), maxf(button.custom_minimum_size.y, 46.0))
		_style_overlay_button(button)


func _style_top_button(button: Button, accent_color: Color) -> void:
	if button == null:
		return
	button.custom_minimum_size = Vector2(maxf(button.custom_minimum_size.x, 108.0), 48.0)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.62))
	button.add_theme_constant_override("shadow_offset_y", 1)
	button.add_theme_constant_override("shadow_outline_size", 2)
	button.add_theme_stylebox_override("normal", _make_button_style(accent_color, Color(0.03, 0.07, 0.1, 0.88)))
	button.add_theme_stylebox_override("hover", _make_button_style(accent_color.lightened(0.16), Color(0.06, 0.11, 0.18, 0.92)))
	button.add_theme_stylebox_override("pressed", _make_button_style(accent_color.darkened(0.12), Color(0.02, 0.04, 0.08, 0.96)))


func _style_overlay_button(button: Button) -> void:
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.31, 0.97, 0.85, 1.0), Color(0.03, 0.07, 0.1, 0.9)))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.48, 1.0, 0.92, 1.0), Color(0.06, 0.11, 0.18, 0.94)))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.22, 0.82, 0.74, 1.0), Color(0.02, 0.04, 0.08, 0.98)))


func _make_button_style(accent_color: Color, fill_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = accent_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 22
	style.shadow_size = 18
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style.expand_margin_left = 2
	style.expand_margin_top = 2
	style.expand_margin_right = 2
	style.expand_margin_bottom = 2
	return style


func _make_slider_track_style(fill_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	return style


func _make_settings_panel_style(fill_color: Color, accent_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = accent_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 24
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	style.shadow_size = 18
	style.shadow_offset = Vector2(0, 8)
	style.content_margin_left = 12.0
	style.content_margin_top = 12.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 12.0
	return style
