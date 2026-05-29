extends Control

@export_node_path("Node") var turn_manager_path: NodePath = NodePath("../../Turnmanager")
@export var hover_world_offset: Vector3 = Vector3(0.0, 1.8, 0.0)
@export var hover_vertical_gap: float = 18.0
@export var hover_follow_speed: float = 12.0
@export var hover_pulse_speed: float = 5.2

const ONLINE_CHAT_BUTTON_DRAG_THRESHOLD: float = 8.0

@onready var top_right: VBoxContainer = $TopRight
@onready var turn_card: Panel = $TopRight/TurnCard
@onready var turn_indicator: Label = $TopRight/TurnCard/TurnIndicator
@onready var score_card: Panel = $TopRight/ScoreCard

var turn_manager: Node = null
var active_marble: Node3D = null
var active_turn_name: String = "Player"
var hover_root: Node2D = null
var hover_glow: Polygon2D = null
var hover_arrow: Polygon2D = null
var hover_label: Label = null
var elimination_popup: Panel = null
var elimination_popup_label: Label = null
var turn_prompt_card: Panel = null
var turn_prompt_label: Label = null
var result_overlay: ColorRect = null
var result_title_label: Label = null
var result_message_label: Label = null
var result_primary_button: Button = null
var result_secondary_button: Button = null
var currency_bar: HBoxContainer = null
var coins_value_label: Label = null
var gold_value_label: Label = null
var lan_status_label: Label = null
var online_status_label: Label = null
var online_chat_panel: Panel = null
var online_chat_bubble_button: Button = null
var online_chat_log_stack: VBoxContainer = null
var online_chat_input: LineEdit = null
var online_chat_send_button: Button = null
var online_chat_toast_panel: Panel = null
var online_chat_toast_sender_label: Label = null
var online_chat_toast_text_label: Label = null
var online_chat_history: Array = []
var online_manager: Node = null
var online_chat_expanded: bool = false
var online_chat_toast_timer: float = 0.0
var online_chat_button_pressing: bool = false
var online_chat_button_dragging: bool = false
var online_chat_button_drag_start_global: Vector2 = Vector2.ZERO
var online_chat_button_drag_start_position: Vector2 = Vector2.ZERO
var online_chat_button_drag_pointer_offset: Vector2 = Vector2.ZERO
var online_chat_button_drag_touch_index: int = -1
var online_chat_button_drag_started_by_touch: bool = false
var online_chat_button_has_custom_position: bool = false
var online_chat_button_custom_position: Vector2 = Vector2.ZERO
var elimination_banner_time_left: float = 0.0
var elimination_banner_duration: float = 0.0
var hover_position_initialized: bool = false
var smoothed_hover_position: Vector2 = Vector2.ZERO
var pulse_time: float = 0.0
var player_is_disqualified: bool = false
var game_is_finished: bool = false
var main_menu_scene_path: String = "res://Start_Menu.tscn"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_hover_indicator()
	_build_turn_prompt()
	_build_elimination_banner()
	_build_result_overlay()
	_build_currency_bar()
	_build_lan_status()
	_build_online_status()
	_build_online_chat()
	_style_hud()

	var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
	if currency_manager != null and currency_manager.has_signal("currency_changed"):
		currency_manager.currency_changed.connect(_on_currency_changed)
	_update_currency_bar()

	turn_manager = get_node_or_null(turn_manager_path)
	if turn_manager:
		if turn_manager.has_signal("turn_changed"):
			turn_manager.turn_changed.connect(_on_turn_changed)
		if turn_manager.has_signal("marble_eliminated"):
			turn_manager.marble_eliminated.connect(_on_marble_eliminated)
		if turn_manager.has_signal("retry_awarded"):
			turn_manager.retry_awarded.connect(_on_retry_awarded)
		if turn_manager.has_signal("player_disqualified"):
			turn_manager.player_disqualified.connect(_on_player_disqualified)
		if turn_manager.has_signal("player_won"):
			turn_manager.player_won.connect(_on_player_won)
		if turn_manager.has_signal("game_finished"):
			turn_manager.game_finished.connect(_on_game_finished)
		if turn_manager.has_method("get_active_display_name"):
			active_turn_name = str(turn_manager.call("get_active_display_name"))
		_refresh_active_marble()
		_on_turn_changed(active_turn_name, 0)

	set_process(true)


func _process(delta: float) -> void:
	pulse_time += delta
	_update_elimination_banner(delta)
	_update_online_chat_toast(delta)
	_update_hover_indicator(delta)


func _input(event: InputEvent) -> void:
	if online_chat_button_pressing:
		_handle_online_chat_button_drag_input(event)


func _on_turn_changed(active_name: String, _active_index: int) -> void:
	active_turn_name = active_name
	turn_indicator.text = "TURN // %s" % active_turn_name.to_upper()
	_refresh_active_marble()
	_update_turn_prompt()


func _style_hud() -> void:
	_style_power_meter()

	top_right.offset_left = -244.0
	top_right.offset_right = -18.0
	top_right.offset_top = 18.0
	top_right.offset_bottom = 238.0
	top_right.add_theme_constant_override("separation", 8)

	turn_card.custom_minimum_size = Vector2(0.0, 48.0)
	turn_card.add_theme_stylebox_override("panel", _make_hud_card_style(Color(0.31, 0.97, 0.85, 1.0), Color(0.03, 0.07, 0.1, 0.88)))
	score_card.visible = false

	turn_indicator.add_theme_font_size_override("font_size", 14)
	turn_indicator.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	turn_indicator.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	turn_indicator.add_theme_constant_override("shadow_offset_x", 0)
	turn_indicator.add_theme_constant_override("shadow_offset_y", 1)
	turn_indicator.add_theme_constant_override("shadow_outline_size", 2)
	turn_indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	turn_indicator.autowrap_mode = TextServer.AUTOWRAP_OFF
	top_right.offset_bottom = turn_card.custom_minimum_size.y + 30.0

	if currency_bar != null:
		currency_bar.position = Vector2(18.0, 74.0)
	if lan_status_label != null:
		lan_status_label.position = Vector2(18.0, 124.0)
	if online_status_label != null:
		online_status_label.position = Vector2(18.0, 124.0 if lan_status_label == null else 164.0)
	var chat_button_y: float = 124.0
	if lan_status_label != null:
		chat_button_y += 40.0
	if online_status_label != null:
		chat_button_y += 40.0
	if online_chat_panel != null:
		online_chat_panel.position = Vector2(18.0, chat_button_y + 52.0)
	if online_chat_bubble_button != null:
		if online_chat_button_has_custom_position:
			online_chat_bubble_button.position = _clamp_online_chat_button_position(online_chat_button_custom_position)
		else:
			online_chat_bubble_button.position = Vector2(18.0, chat_button_y)


func _style_power_meter() -> void:
	var ui_root: Node = get_parent()
	var power_meter: Control = null
	if ui_root != null:
		power_meter = ui_root.get_node_or_null("PowerMeter") as Control
	if power_meter == null:
		return

	power_meter.offset_left = 18.0
	power_meter.offset_top = 150.0
	power_meter.offset_right = 82.0
	power_meter.offset_bottom = 472.0
	power_meter.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var power_glass: PanelContainer = power_meter.get_node_or_null("PowerGlass") as PanelContainer
	if power_glass != null:
		power_glass.add_theme_stylebox_override("panel", _make_power_meter_panel_style())

	var power_label: Label = power_meter.get_node_or_null("PowerLabel") as Label
	if power_label != null:
		power_label.offset_left = 0.0
		power_label.offset_top = -25.0
		power_label.offset_right = 64.0
		power_label.offset_bottom = -2.0
		power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		power_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		power_label.add_theme_font_size_override("font_size", 14)
		power_label.add_theme_color_override("font_color", Color(0.94, 0.99, 1.0, 1.0))
		power_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.68))
		power_label.add_theme_constant_override("shadow_offset_x", 0)
		power_label.add_theme_constant_override("shadow_offset_y", 1)
		power_label.add_theme_constant_override("shadow_outline_size", 2)

	var power_bar: ProgressBar = power_meter.get_node_or_null("PowerBar") as ProgressBar
	if power_bar != null:
		power_bar.offset_left = 13.0
		power_bar.offset_top = 15.0
		power_bar.offset_right = 51.0
		power_bar.offset_bottom = 288.0
		power_bar.fill_mode = 3
		power_bar.show_percentage = false
		power_bar.add_theme_stylebox_override("background", _make_power_bar_track_style())
		power_bar.add_theme_stylebox_override("fill", _make_power_bar_fill_style())


func _build_hover_indicator() -> void:
	hover_root = Node2D.new()
	hover_root.name = "ActiveTurnHover"
	hover_root.visible = false
	add_child(hover_root)

	hover_glow = Polygon2D.new()
	hover_glow.polygon = PackedVector2Array([
		Vector2(0.0, -30.0),
		Vector2(-20.0, -10.0),
		Vector2(0.0, 10.0),
		Vector2(20.0, -10.0)
	])
	hover_glow.color = Color(0.1, 0.86, 1.0, 0.28)
	hover_root.add_child(hover_glow)

	hover_arrow = Polygon2D.new()
	hover_arrow.polygon = PackedVector2Array([
		Vector2(0.0, 8.0),
		Vector2(-10.0, -8.0),
		Vector2(-3.0, -8.0),
		Vector2(0.0, -18.0),
		Vector2(3.0, -8.0),
		Vector2(10.0, -8.0)
	])
	hover_arrow.color = Color(1.0, 0.92, 0.36, 1.0)
	hover_root.add_child(hover_arrow)

	hover_label = Label.new()
	hover_label.name = "HoverLabel"
	hover_label.text = "TURN"
	hover_label.position = Vector2(-34.0, -58.0)
	hover_label.size = Vector2(68.0, 20.0)
	hover_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hover_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hover_label.add_theme_font_size_override("font_size", 11)
	hover_label.add_theme_color_override("font_color", Color(0.92, 0.99, 1.0, 1.0))
	hover_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	hover_label.add_theme_constant_override("shadow_offset_x", 0)
	hover_label.add_theme_constant_override("shadow_offset_y", 1)
	hover_label.add_theme_constant_override("shadow_outline_size", 2)
	hover_root.add_child(hover_label)


func _build_turn_prompt() -> void:
	turn_prompt_card = Panel.new()
	turn_prompt_card.name = "TurnPromptCard"
	turn_prompt_card.anchor_left = 0.5
	turn_prompt_card.anchor_top = 0.0
	turn_prompt_card.anchor_right = 0.5
	turn_prompt_card.anchor_bottom = 0.0
	turn_prompt_card.offset_left = -178.0
	turn_prompt_card.offset_top = 18.0
	turn_prompt_card.offset_right = 178.0
	turn_prompt_card.offset_bottom = 66.0
	turn_prompt_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	turn_prompt_card.add_theme_stylebox_override("panel", _make_hud_card_style(Color(0.31, 0.97, 0.85, 1.0), Color(0.03, 0.07, 0.1, 0.88)))
	turn_prompt_card.visible = false
	add_child(turn_prompt_card)

	turn_prompt_label = Label.new()
	turn_prompt_label.name = "TurnPrompt"
	turn_prompt_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	turn_prompt_label.offset_left = 18.0
	turn_prompt_label.offset_top = 12.0
	turn_prompt_label.offset_right = -18.0
	turn_prompt_label.offset_bottom = -12.0
	turn_prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	turn_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	turn_prompt_label.add_theme_font_size_override("font_size", 16)
	turn_prompt_label.add_theme_color_override("font_color", Color(0.88, 0.96, 1.0, 1.0))
	turn_prompt_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	turn_prompt_label.add_theme_constant_override("shadow_offset_x", 0)
	turn_prompt_label.add_theme_constant_override("shadow_offset_y", 1)
	turn_prompt_label.add_theme_constant_override("shadow_outline_size", 2)
	turn_prompt_card.add_child(turn_prompt_label)


func _build_result_overlay() -> void:
	result_overlay = ColorRect.new()
	result_overlay.name = "ResultOverlay"
	result_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	result_overlay.color = Color(0.0, 0.0, 0.04, 0.72)
	result_overlay.visible = false
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	result_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(result_overlay)

	var panel: Panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -290.0
	panel.offset_top = -170.0
	panel.offset_right = 290.0
	panel.offset_bottom = 170.0
	panel.add_theme_stylebox_override("panel", _make_modal_style(Color(0.02, 0.04, 0.12, 0.96), Color(0.36, 0.92, 1.0, 0.95)))
	result_overlay.add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 34.0
	box.offset_top = 28.0
	box.offset_right = -34.0
	box.offset_bottom = -28.0
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)

	result_title_label = Label.new()
	result_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_title_label.add_theme_font_size_override("font_size", 58)
	result_title_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.36, 1.0))
	result_title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	result_title_label.add_theme_constant_override("shadow_offset_y", 3)
	result_title_label.add_theme_constant_override("shadow_outline_size", 8)
	box.add_child(result_title_label)

	result_message_label = Label.new()
	result_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_message_label.add_theme_font_size_override("font_size", 22)
	result_message_label.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0, 1.0))
	box.add_child(result_message_label)

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	box.add_child(buttons)

	result_primary_button = _make_modal_button("MAIN MENU", Color(0.16, 0.72, 1.0, 1.0))
	result_secondary_button = _make_modal_button("RESTART", Color(0.72, 0.36, 1.0, 1.0))
	buttons.add_child(result_primary_button)
	buttons.add_child(result_secondary_button)


func _build_elimination_banner() -> void:
	elimination_popup = Panel.new()
	elimination_popup.name = "EliminationPopup"
	elimination_popup.set_anchors_preset(Control.PRESET_CENTER)
	elimination_popup.offset_left = -250.0
	elimination_popup.offset_top = -58.0
	elimination_popup.offset_right = 250.0
	elimination_popup.offset_bottom = 58.0
	elimination_popup.pivot_offset = Vector2(250.0, 58.0)
	elimination_popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	elimination_popup.z_index = 560
	elimination_popup.visible = false
	elimination_popup.add_theme_stylebox_override("panel", _make_elimination_popup_style(Color(1.0, 0.86, 0.42, 1.0)))
	add_child(elimination_popup)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 16)
	elimination_popup.add_child(margin)

	elimination_popup_label = Label.new()
	elimination_popup_label.name = "EliminationMessage"
	elimination_popup_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	elimination_popup_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	elimination_popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	elimination_popup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	elimination_popup_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	elimination_popup_label.add_theme_font_size_override("font_size", 24)
	elimination_popup_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42, 0.96))
	elimination_popup_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	elimination_popup_label.add_theme_constant_override("shadow_offset_x", 0)
	elimination_popup_label.add_theme_constant_override("shadow_offset_y", 2)
	elimination_popup_label.add_theme_constant_override("shadow_outline_size", 3)
	margin.add_child(elimination_popup_label)


func _build_currency_bar() -> void:
	currency_bar = HBoxContainer.new()
	currency_bar.name = "CurrencyBar"
	currency_bar.add_theme_constant_override("separation", 10)
	add_child(currency_bar)

	var coin_chip: Panel = _make_currency_chip("S", Color(1.0, 0.84, 0.38, 1.0))
	coins_value_label = coin_chip.get_node("Row/Value") as Label
	currency_bar.add_child(coin_chip)

	var gold_chip: Panel = _make_currency_chip("G", Color(1.0, 0.93, 0.62, 1.0))
	gold_value_label = gold_chip.get_node("Row/Value") as Label
	currency_bar.add_child(gold_chip)


func _build_lan_status() -> void:
	var lan: Node = get_node_or_null("/root/LanMultiplayer")
	if lan == null or not lan.has_method("is_lan_game") or not bool(lan.call("is_lan_game")):
		return

	lan_status_label = Label.new()
	lan_status_label.name = "LanStatus"
	lan_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lan_status_label.custom_minimum_size = Vector2(560.0, 44.0)
	lan_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lan_status_label.add_theme_font_size_override("font_size", 13)
	lan_status_label.add_theme_color_override("font_color", Color(0.82, 0.96, 1.0, 0.95))
	lan_status_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	lan_status_label.add_theme_constant_override("shadow_outline_size", 2)
	if lan.has_method("get_status_text"):
		lan_status_label.text = str(lan.call("get_status_text"))
	else:
		lan_status_label.text = "LAN match"
	add_child(lan_status_label)


func _build_online_status() -> void:
	online_manager = get_node_or_null("/root/MultiplayerManager")
	if online_manager == null or not online_manager.has_method("is_online_game") or not bool(online_manager.call("is_online_game")):
		return

	online_status_label = Label.new()
	online_status_label.name = "OnlineStatus"
	online_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	online_status_label.custom_minimum_size = Vector2(360.0, 34.0)
	online_status_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	online_status_label.add_theme_font_size_override("font_size", 13)
	online_status_label.add_theme_color_override("font_color", Color(0.44, 1.0, 0.72, 0.96))
	online_status_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	online_status_label.add_theme_constant_override("shadow_outline_size", 2)
	online_status_label.text = "ONLINE: CONNECTED"
	add_child(online_status_label)

	if online_manager.has_signal("connection_status_changed") and not online_manager.connection_status_changed.is_connected(_on_online_status_changed):
		online_manager.connection_status_changed.connect(_on_online_status_changed)
	if online_manager.has_signal("reconnecting") and not online_manager.reconnecting.is_connected(_on_online_reconnecting):
		online_manager.reconnecting.connect(_on_online_reconnecting)
	if online_manager.has_signal("connected_to_server") and not online_manager.connected_to_server.is_connected(_on_online_connected):
		online_manager.connected_to_server.connect(_on_online_connected)
	if online_manager.has_signal("disconnected_from_server") and not online_manager.disconnected_from_server.is_connected(_on_online_disconnected):
		online_manager.disconnected_from_server.connect(_on_online_disconnected)
	if online_manager.has_signal("connection_failed") and not online_manager.connection_failed.is_connected(_on_online_connection_failed):
		online_manager.connection_failed.connect(_on_online_connection_failed)


func _build_online_chat() -> void:
	if online_manager == null:
		online_manager = get_node_or_null("/root/MultiplayerManager")
	if online_manager == null or not online_manager.has_method("is_online_game") or not bool(online_manager.call("is_online_game")):
		return

	if online_manager.has_signal("chat_message_received") and not online_manager.chat_message_received.is_connected(_on_online_chat_message_received):
		online_manager.chat_message_received.connect(_on_online_chat_message_received)

	online_chat_panel = Panel.new()
	online_chat_panel.name = "OnlineChatPanel"
	online_chat_panel.custom_minimum_size = Vector2(380.0, 230.0)
	online_chat_panel.size = online_chat_panel.custom_minimum_size
	online_chat_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	online_chat_panel.visible = online_chat_expanded
	online_chat_panel.add_theme_stylebox_override("panel", _make_hud_card_style(Color(0.72, 0.36, 1.0, 0.92), Color(0.02, 0.04, 0.09, 0.82)))
	add_child(online_chat_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	online_chat_panel.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 7)
	margin.add_child(stack)

	var title: Label = Label.new()
	title.text = "PARTY CHAT"
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color(0.86, 0.72, 1.0, 0.96))
	title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	title.add_theme_constant_override("shadow_outline_size", 2)
	stack.add_child(title)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	stack.add_child(scroll)

	online_chat_log_stack = VBoxContainer.new()
	online_chat_log_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_chat_log_stack.add_theme_constant_override("separation", 5)
	scroll.add_child(online_chat_log_stack)

	var input_row: HBoxContainer = HBoxContainer.new()
	input_row.add_theme_constant_override("separation", 7)
	stack.add_child(input_row)

	online_chat_input = LineEdit.new()
	online_chat_input.placeholder_text = "MESSAGE"
	online_chat_input.max_length = 160
	online_chat_input.custom_minimum_size = Vector2(0.0, 34.0)
	online_chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_chat_input.focus_mode = Control.FOCUS_CLICK
	online_chat_input.add_theme_font_size_override("font_size", 13)
	online_chat_input.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	online_chat_input.add_theme_color_override("font_placeholder_color", Color(0.68, 0.76, 0.9, 0.72))
	online_chat_input.add_theme_stylebox_override("normal", _make_modal_style(Color(0.015, 0.03, 0.07, 0.92), Color(0.72, 0.36, 1.0, 0.74)))
	online_chat_input.add_theme_stylebox_override("focus", _make_modal_style(Color(0.02, 0.05, 0.1, 0.96), Color(0.31, 0.97, 0.85, 0.94)))
	input_row.add_child(online_chat_input)

	online_chat_send_button = Button.new()
	online_chat_send_button.text = "SEND"
	online_chat_send_button.custom_minimum_size = Vector2(66.0, 34.0)
	online_chat_send_button.focus_mode = Control.FOCUS_NONE
	online_chat_send_button.add_theme_font_size_override("font_size", 12)
	online_chat_send_button.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	online_chat_send_button.add_theme_stylebox_override("normal", _make_modal_style(Color(0.02, 0.07, 0.08, 0.88), Color(0.31, 0.97, 0.85, 0.92)))
	online_chat_send_button.add_theme_stylebox_override("hover", _make_modal_style(Color(0.04, 0.1, 0.12, 0.94), Color(0.52, 1.0, 0.9, 1.0)))
	online_chat_send_button.add_theme_stylebox_override("pressed", _make_modal_style(Color(0.01, 0.04, 0.05, 0.98), Color(0.18, 0.74, 0.68, 1.0)))
	input_row.add_child(online_chat_send_button)

	if not online_chat_send_button.pressed.is_connected(_on_online_chat_send_pressed):
		online_chat_send_button.pressed.connect(_on_online_chat_send_pressed)
	if not online_chat_input.text_submitted.is_connected(_on_online_chat_submitted):
		online_chat_input.text_submitted.connect(_on_online_chat_submitted)

	online_chat_bubble_button = Button.new()
	online_chat_bubble_button.name = "OnlineChatBubbleButton"
	online_chat_bubble_button.text = "CHAT"
	online_chat_bubble_button.custom_minimum_size = Vector2(96.0, 44.0)
	online_chat_bubble_button.size = online_chat_bubble_button.custom_minimum_size
	online_chat_bubble_button.focus_mode = Control.FOCUS_NONE
	online_chat_bubble_button.mouse_filter = Control.MOUSE_FILTER_STOP
	online_chat_bubble_button.add_theme_font_size_override("font_size", 13)
	online_chat_bubble_button.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	online_chat_bubble_button.add_theme_stylebox_override("normal", _make_modal_style(Color(0.02, 0.07, 0.08, 0.88), Color(0.31, 0.97, 0.85, 0.92)))
	online_chat_bubble_button.add_theme_stylebox_override("hover", _make_modal_style(Color(0.04, 0.1, 0.12, 0.94), Color(0.52, 1.0, 0.9, 1.0)))
	online_chat_bubble_button.add_theme_stylebox_override("pressed", _make_modal_style(Color(0.01, 0.04, 0.05, 0.98), Color(0.18, 0.74, 0.68, 1.0)))
	add_child(online_chat_bubble_button)
	online_chat_bubble_button.gui_input.connect(_on_online_chat_bubble_gui_input)
	_build_online_chat_toast()
	_sync_online_chat_visibility()
	_refresh_online_chat_log()


func _clamp_online_chat_button_position(candidate_position: Vector2) -> Vector2:
	var parent_size: Vector2 = get_viewport().get_visible_rect().size
	var button_size: Vector2 = online_chat_bubble_button.size if online_chat_bubble_button != null else Vector2(96.0, 44.0)
	return Vector2(
		clampf(candidate_position.x, 0.0, maxf(parent_size.x - button_size.x, 0.0)),
		clampf(candidate_position.y, 0.0, maxf(parent_size.y - button_size.y, 0.0))
	)


func _clamp_online_chat_button_global_position(candidate_position: Vector2) -> Vector2:
	var visible_rect: Rect2 = get_viewport().get_visible_rect()
	var button_size: Vector2 = online_chat_bubble_button.size if online_chat_bubble_button != null else Vector2(96.0, 44.0)
	return Vector2(
		clampf(candidate_position.x, visible_rect.position.x, maxf(visible_rect.end.x - button_size.x, visible_rect.position.x)),
		clampf(candidate_position.y, visible_rect.position.y, maxf(visible_rect.end.y - button_size.y, visible_rect.position.y))
	)


func _on_online_chat_bubble_gui_input(event: InputEvent) -> void:
	if online_chat_bubble_button == null:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_event.pressed:
			_begin_online_chat_button_drag(get_global_mouse_position())
		else:
			_finish_online_chat_button_drag()
		online_chat_bubble_button.accept_event()
	elif event is InputEventMouseMotion and online_chat_button_pressing:
		_update_online_chat_button_drag(get_global_mouse_position())
		online_chat_bubble_button.accept_event()
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_begin_online_chat_button_drag(touch_event.position, touch_event.index, true)
		elif touch_event.index == online_chat_button_drag_touch_index:
			_finish_online_chat_button_drag()
		online_chat_bubble_button.accept_event()
	elif event is InputEventScreenDrag and online_chat_button_pressing:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if drag_event.index != online_chat_button_drag_touch_index:
			return
		_update_online_chat_button_drag(drag_event.position)
		online_chat_bubble_button.accept_event()


func _handle_online_chat_button_drag_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if not mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_finish_online_chat_button_drag()
			accept_event()
	elif event is InputEventMouseMotion:
		_update_online_chat_button_drag(get_global_mouse_position())
		accept_event()
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if not touch_event.pressed and touch_event.index == online_chat_button_drag_touch_index:
			_finish_online_chat_button_drag()
			accept_event()
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if drag_event.index != online_chat_button_drag_touch_index:
			return
		_update_online_chat_button_drag(drag_event.position)
		accept_event()


func _begin_online_chat_button_drag(pointer_position: Vector2, touch_index: int = -1, started_by_touch: bool = false) -> void:
	online_chat_button_pressing = true
	online_chat_button_dragging = false
	online_chat_button_drag_start_global = pointer_position
	online_chat_button_drag_start_position = online_chat_bubble_button.position
	online_chat_button_drag_pointer_offset = pointer_position - online_chat_bubble_button.global_position
	online_chat_button_drag_touch_index = touch_index
	online_chat_button_drag_started_by_touch = started_by_touch


func _update_online_chat_button_drag(pointer_position: Vector2) -> void:
	var drag_delta: Vector2 = pointer_position - online_chat_button_drag_start_global
	if not online_chat_button_dragging and not online_chat_button_drag_started_by_touch and drag_delta.length() < ONLINE_CHAT_BUTTON_DRAG_THRESHOLD:
		return
	online_chat_button_dragging = true
	online_chat_bubble_button.global_position = _clamp_online_chat_button_global_position(pointer_position - online_chat_button_drag_pointer_offset)
	online_chat_button_custom_position = online_chat_bubble_button.position
	online_chat_button_has_custom_position = true


func _finish_online_chat_button_drag() -> void:
	if not online_chat_button_pressing:
		return
	var opened_by_click: bool = not online_chat_button_dragging
	if online_chat_button_dragging and online_chat_bubble_button != null:
		online_chat_button_custom_position = online_chat_bubble_button.position
		online_chat_button_has_custom_position = true
	online_chat_button_pressing = false
	online_chat_button_dragging = false
	online_chat_button_drag_touch_index = -1
	online_chat_button_drag_started_by_touch = false
	if opened_by_click:
		_toggle_online_chat()


func _set_online_status(text_value: String, color: Color) -> void:
	if online_status_label == null:
		return
	online_status_label.text = text_value
	online_status_label.add_theme_color_override("font_color", color)


func _on_online_connected(_client_id: String) -> void:
	_set_online_status("ONLINE: CONNECTED", Color(0.44, 1.0, 0.72, 0.96))


func _on_online_status_changed(message: String) -> void:
	var clean_message: String = message.strip_edges()
	if clean_message == "":
		clean_message = "Online match active"
	_set_online_status("ONLINE: %s" % clean_message.to_upper(), Color(0.72, 0.94, 1.0, 0.96))


func _on_online_reconnecting(attempt: int, delay_seconds: float) -> void:
	_set_online_status("ONLINE: RECONNECTING %d (%.1fs)" % [attempt, delay_seconds], Color(1.0, 0.86, 0.42, 0.98))


func _on_online_disconnected() -> void:
	_set_online_status("ONLINE: DISCONNECTED - RECONNECTING", Color(1.0, 0.55, 0.48, 0.98))


func _on_online_connection_failed(message: String) -> void:
	var clean_message: String = message.strip_edges()
	if clean_message == "":
		clean_message = "Connection failed"
	_set_online_status("ONLINE: %s" % clean_message.to_upper(), Color(1.0, 0.55, 0.48, 0.98))


func _build_online_chat_toast() -> void:
	online_chat_toast_panel = Panel.new()
	online_chat_toast_panel.name = "OnlineChatToast"
	online_chat_toast_panel.set_anchors_preset(Control.PRESET_CENTER)
	online_chat_toast_panel.offset_left = -200.0
	online_chat_toast_panel.offset_top = -52.0
	online_chat_toast_panel.offset_right = 200.0
	online_chat_toast_panel.offset_bottom = 52.0
	online_chat_toast_panel.z_index = 600
	online_chat_toast_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	online_chat_toast_panel.hide()
	online_chat_toast_panel.add_theme_stylebox_override("panel", _make_modal_style(Color(0.015, 0.025, 0.055, 0.94), Color(0.31, 0.97, 0.85, 0.92)))
	add_child(online_chat_toast_panel)
	if not online_chat_toast_panel.gui_input.is_connected(_on_online_chat_toast_gui_input):
		online_chat_toast_panel.gui_input.connect(_on_online_chat_toast_gui_input)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	online_chat_toast_panel.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 4)
	margin.add_child(stack)

	online_chat_toast_sender_label = Label.new()
	online_chat_toast_sender_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_chat_toast_sender_label.clip_text = true
	online_chat_toast_sender_label.add_theme_font_size_override("font_size", 12)
	online_chat_toast_sender_label.add_theme_color_override("font_color", Color(0.31, 0.97, 0.85, 1.0))
	online_chat_toast_sender_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	online_chat_toast_sender_label.add_theme_constant_override("shadow_outline_size", 2)
	stack.add_child(online_chat_toast_sender_label)

	online_chat_toast_text_label = Label.new()
	online_chat_toast_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_chat_toast_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_chat_toast_text_label.max_lines_visible = 2
	online_chat_toast_text_label.add_theme_font_size_override("font_size", 15)
	online_chat_toast_text_label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	online_chat_toast_text_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	online_chat_toast_text_label.add_theme_constant_override("shadow_outline_size", 2)
	stack.add_child(online_chat_toast_text_label)


func _make_currency_chip(icon_text: String, accent: Color) -> Panel:
	var chip: Panel = Panel.new()
	chip.custom_minimum_size = Vector2(96.0, 34.0)
	chip.add_theme_stylebox_override("panel", _make_hud_card_style(accent, Color(0.03, 0.07, 0.1, 0.88)))

	var row: HBoxContainer = HBoxContainer.new()
	row.name = "Row"
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 10.0
	row.offset_top = 6.0
	row.offset_right = -10.0
	row.offset_bottom = -6.0
	row.add_theme_constant_override("separation", 8)
	chip.add_child(row)

	var icon: Label = Label.new()
	icon.text = icon_text
	icon.add_theme_font_size_override("font_size", 15)
	icon.add_theme_color_override("font_color", accent)
	row.add_child(icon)

	var value: Label = Label.new()
	value.name = "Value"
	value.text = "0"
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.add_theme_font_size_override("font_size", 14)
	value.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	row.add_child(value)

	return chip


func _make_modal_button(text_value: String, accent: Color) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(170.0, 52.0)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_stylebox_override("normal", _make_modal_style(Color(0.04, 0.07, 0.16, 0.94), accent))
	button.add_theme_stylebox_override("hover", _make_modal_style(Color(0.08, 0.12, 0.24, 0.98), accent.lightened(0.15)))
	button.add_theme_stylebox_override("pressed", _make_modal_style(Color(0.02, 0.04, 0.1, 0.98), accent.darkened(0.1)))
	return button


func _make_modal_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.shadow_size = 22
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	return style


func _make_elimination_popup_style(accent: Color) -> StyleBoxFlat:
	var border_color := Color(accent.r, accent.g, accent.b, 0.66)
	var style: StyleBoxFlat = _make_modal_style(Color(0.02, 0.04, 0.12, 0.46), border_color)
	style.shadow_size = 12
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	return style


func _on_marble_eliminated(player_name: String) -> void:
	_show_banner("%s HAS BEEN ELIMINATED" % player_name.to_upper(), Color(1.0, 0.86, 0.42, 1.0), 2.6)


func _on_retry_awarded(player_name: String) -> void:
	_show_banner("%s GETS ANOTHER TURN TO THE HOLE" % player_name.to_upper(), Color(0.42, 0.92, 1.0, 1.0), 2.1)


func _on_player_disqualified(attacker_name: String) -> void:
	player_is_disqualified = true
	_update_turn_prompt()
	_show_decision_overlay(
		"DISQUALIFIED",
		"%s knocked you out. You are out of the field now, but you can keep watching or return to the lobby/menu." % attacker_name,
		"LOBBY / MENU",
		"WATCH",
		_go_to_main_menu,
		_continue_watching
	)


func _on_player_won(coin_reward: int) -> void:
	game_is_finished = true
	_update_turn_prompt()
	var secondary_text: String = "" if _is_online_match() else "RESTART"
	var secondary_action: Callable = Callable() if _is_online_match() else _restart_match
	_show_decision_overlay(
		"WINNER",
		"You won the match and earned %d S coins." % coin_reward,
		"LOBBY / MENU" if _is_online_match() else "MAIN MENU",
		secondary_text,
		_go_to_main_menu,
		secondary_action
	)


func _on_game_finished(winner_name: String) -> void:
	game_is_finished = true
	_update_turn_prompt()
	if winner_name == "" or result_overlay == null or result_overlay.visible:
		return
	var local_player_won: bool = false
	if turn_manager != null and turn_manager.has_method("did_local_player_win"):
		local_player_won = bool(turn_manager.call("did_local_player_win", winner_name))
	if not local_player_won:
		_show_decision_overlay(
			"%s WON" % winner_name.to_upper(),
			"%s won this match. Your result has been recorded." % winner_name,
			"LOBBY / MENU" if _is_online_match() else "MAIN MENU",
			"",
			_go_to_main_menu,
			Callable()
		)
		return
	_show_decision_overlay(
		"%s WINS" % winner_name.to_upper(),
		"You won the match. Your result has been recorded.",
		"LOBBY / MENU" if _is_online_match() else "MAIN MENU",
		"" if _is_online_match() else "RESTART",
		_go_to_main_menu,
		Callable() if _is_online_match() else _restart_match
	)


func _on_currency_changed(_coins: int, _gold: int) -> void:
	_update_currency_bar()


func _update_currency_bar() -> void:
	var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
	if currency_manager == null:
		return
	if coins_value_label != null and currency_manager.has_method("get_coins"):
		coins_value_label.text = str(currency_manager.call("get_coins"))
	if gold_value_label != null and currency_manager.has_method("get_gold"):
		gold_value_label.text = str(currency_manager.call("get_gold"))


func _toggle_online_chat() -> void:
	online_chat_expanded = not online_chat_expanded
	_sync_online_chat_visibility()
	if online_chat_expanded and online_chat_input != null:
		online_chat_input.grab_focus()


func _sync_online_chat_visibility() -> void:
	if online_chat_panel != null:
		online_chat_panel.visible = online_chat_expanded
	if online_chat_expanded:
		online_chat_toast_timer = 0.0
		if online_chat_toast_panel != null:
			online_chat_toast_panel.hide()
	if online_chat_bubble_button != null:
		online_chat_bubble_button.text = "HIDE" if online_chat_expanded else "CHAT"


func _on_online_chat_send_pressed() -> void:
	if online_chat_input == null:
		return
	_send_online_chat_message(online_chat_input.text)


func _on_online_chat_submitted(text_value: String) -> void:
	_send_online_chat_message(text_value)


func _send_online_chat_message(raw_text: String) -> void:
	var clean_text: String = _sanitize_online_chat_text(raw_text)
	if clean_text == "":
		return
	if online_manager == null:
		online_manager = get_node_or_null("/root/MultiplayerManager")
	if online_manager == null or not online_manager.has_method("send_chat_message"):
		return
	var error: Error = online_manager.call("send_chat_message", clean_text)
	if error == OK and online_chat_input != null:
		online_chat_input.clear()


func _on_online_chat_message_received(message: Dictionary) -> void:
	_append_online_chat_message(message)


func _append_online_chat_message(message: Dictionary) -> void:
	var clean_text: String = _sanitize_online_chat_text(str(message.get("text", "")))
	if clean_text == "":
		return
	var entry: Dictionary = message.duplicate(true)
	entry["text"] = clean_text
	if str(entry.get("sender_name", "")).strip_edges() == "":
		entry["sender_name"] = "Player"
	online_chat_history.append(entry)
	while online_chat_history.size() > 18:
		online_chat_history.pop_front()
	_refresh_online_chat_log()
	if not bool(entry.get("is_local", false)):
		_show_online_chat_toast(entry)


func _refresh_online_chat_log() -> void:
	if online_chat_log_stack == null:
		return
	for child in online_chat_log_stack.get_children():
		child.queue_free()

	if online_chat_history.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "No messages yet."
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", Color(0.78, 0.88, 1.0, 0.7))
		empty_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
		empty_label.add_theme_constant_override("shadow_outline_size", 2)
		online_chat_log_stack.add_child(empty_label)
		return

	var lines: PackedStringArray = PackedStringArray()
	for entry in online_chat_history:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var message_data: Dictionary = entry as Dictionary
		var sender_text: String = str(message_data.get("sender_name", "Player")).to_upper()
		if bool(message_data.get("is_direct", false)):
			sender_text = "DM // %s" % sender_text
		lines.append("%s: %s" % [sender_text, str(message_data.get("text", ""))])

	var page_label: Label = Label.new()
	page_label.text = "\n".join(lines)
	page_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_label.add_theme_font_size_override("font_size", 13)
	page_label.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0, 0.98))
	page_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	page_label.add_theme_constant_override("shadow_outline_size", 2)
	online_chat_log_stack.add_child(page_label)


func _show_online_chat_toast(message_data: Dictionary) -> void:
	if online_chat_expanded:
		return
	if online_chat_toast_panel == null:
		return
	var sender_name: String = str(message_data.get("sender_name", "Player")).strip_edges()
	if sender_name == "":
		sender_name = "Player"
	if online_chat_toast_sender_label != null:
		online_chat_toast_sender_label.text = "%s FROM %s" % ["DM" if bool(message_data.get("is_direct", false)) else "PARTY", sender_name.to_upper()]
	if online_chat_toast_text_label != null:
		online_chat_toast_text_label.text = _sanitize_online_chat_text(str(message_data.get("text", "")))
	online_chat_toast_timer = 4.0
	online_chat_toast_panel.show()


func _update_online_chat_toast(delta: float) -> void:
	if online_chat_toast_timer <= 0.0:
		return
	online_chat_toast_timer -= delta
	if online_chat_toast_timer <= 0.0:
		online_chat_toast_timer = 0.0
		if online_chat_toast_panel != null:
			online_chat_toast_panel.hide()


func _on_online_chat_toast_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			online_chat_expanded = true
			_sync_online_chat_visibility()
			online_chat_toast_timer = 0.0
			if online_chat_toast_panel != null:
				online_chat_toast_panel.hide()
			if online_chat_input != null:
				online_chat_input.grab_focus()


func _sanitize_online_chat_text(text_value: String) -> String:
	var clean_text: String = text_value.strip_edges()
	clean_text = clean_text.replace("\n", " ").replace("\r", " ").replace("\t", " ")
	while clean_text.contains("  "):
		clean_text = clean_text.replace("  ", " ")
	return clean_text.left(160)


func _show_banner(message: String, color: Color, duration: float) -> void:
	if elimination_popup == null or elimination_popup_label == null:
		return

	elimination_popup_label.text = message
	elimination_popup_label.add_theme_color_override("font_color", Color(color.r, color.g, color.b, 0.96))
	elimination_popup.add_theme_stylebox_override("panel", _make_elimination_popup_style(color))
	elimination_popup.modulate = Color(1.0, 1.0, 1.0, 1.0)
	elimination_popup.scale = Vector2.ONE
	elimination_popup.visible = true
	elimination_banner_time_left = duration
	elimination_banner_duration = duration


func _update_turn_prompt() -> void:
	if turn_prompt_label == null or turn_prompt_card == null:
		return
	if game_is_finished:
		turn_prompt_card.visible = false
		return
	if player_is_disqualified:
		turn_prompt_label.text = "CONTINUE WATCHING"
		turn_prompt_label.add_theme_color_override("font_color", Color(0.72, 0.86, 1.0, 0.95))
		turn_prompt_card.visible = result_overlay == null or not result_overlay.visible
		return

	var is_player_turn_now: bool = false
	if turn_manager != null and turn_manager.has_method("is_player_turn"):
		is_player_turn_now = bool(turn_manager.call("is_player_turn"))
	else:
		is_player_turn_now = active_turn_name.strip_edges().to_lower() == "player"

	if is_player_turn_now:
		turn_prompt_label.text = "PLAY NOW"
		turn_prompt_label.add_theme_color_override("font_color", Color(0.44, 1.0, 0.64, 1.0))
	else:
		turn_prompt_label.text = "WAIT FOR YOUR TURN"
		turn_prompt_label.add_theme_color_override("font_color", Color(0.86, 0.93, 1.0, 0.96))
	turn_prompt_card.visible = true


func _show_decision_overlay(title: String, message: String, primary_text: String, secondary_text: String, primary_action: Callable, secondary_action: Callable) -> void:
	if result_overlay == null:
		return

	result_overlay.visible = true
	result_overlay.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if result_title_label != null:
		result_title_label.text = title
	if result_message_label != null:
		result_message_label.text = message

	_configure_modal_button(result_primary_button, primary_text, primary_action)
	_configure_modal_button(result_secondary_button, secondary_text, secondary_action)
	_update_turn_prompt()


func _configure_modal_button(button: Button, text_value: String, action: Callable) -> void:
	if button == null:
		return
	button.text = text_value
	button.visible = text_value.strip_edges() != "" and action.is_valid()
	for connection in button.pressed.get_connections():
		var callable: Callable = connection.get("callable", Callable())
		if callable.is_valid():
			button.pressed.disconnect(callable)
	if action.is_valid():
		button.pressed.connect(action)


func _is_online_match() -> bool:
	return online_manager != null and online_manager.has_method("is_online_game") and bool(online_manager.call("is_online_game"))


func _continue_watching() -> void:
	if result_overlay != null:
		result_overlay.visible = false
	_update_turn_prompt()


func _go_to_main_menu() -> void:
	get_tree().paused = false
	if online_manager != null and online_manager.has_method("leave_room"):
		online_manager.call("leave_room")
	elif online_manager != null and online_manager.has_method("disconnect_from_server"):
		online_manager.call("disconnect_from_server", false)
	var target_scene: String = main_menu_scene_path
	if target_scene == "" or not ResourceLoader.exists(target_scene):
		target_scene = "res://Start_Menu.tscn"
	if ResourceLoader.exists(target_scene):
		get_tree().change_scene_to_file(target_scene)


func _restart_match() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _update_elimination_banner(delta: float) -> void:
	if elimination_popup == null or elimination_banner_time_left <= 0.0:
		return

	elimination_banner_time_left = maxf(elimination_banner_time_left - delta, 0.0)
	var popup_duration: float = maxf(elimination_banner_duration, 0.1)
	var life_ratio: float = clampf(elimination_banner_time_left / popup_duration, 0.0, 1.0)
	var alpha: float = 1.0 if life_ratio > 0.22 else clampf(life_ratio / 0.22, 0.0, 1.0)
	var intro_scale: float = 1.0 + 0.08 * clampf((life_ratio - 0.82) / 0.18, 0.0, 1.0)
	elimination_popup.modulate = Color(1.0, 1.0, 1.0, alpha)
	elimination_popup.scale = Vector2.ONE * intro_scale
	if elimination_banner_time_left <= 0.0:
		elimination_popup.visible = false


func _update_hover_indicator(delta: float) -> void:
	if active_marble == null or not is_instance_valid(active_marble):
		_refresh_active_marble()
	if active_marble == null or not is_instance_valid(active_marble):
		hover_root.visible = false
		hover_position_initialized = false
		return

	var camera := get_viewport().get_camera_3d()
	if camera == null:
		hover_root.visible = false
		hover_position_initialized = false
		return

	var world_point := active_marble.global_position + hover_world_offset
	if camera.is_position_behind(world_point):
		hover_root.visible = false
		hover_position_initialized = false
		return

	var screen_point: Vector2 = camera.unproject_position(world_point)
	var target_position := screen_point + Vector2(0.0, -hover_vertical_gap)
	if not hover_position_initialized:
		smoothed_hover_position = target_position
		hover_position_initialized = true
	else:
		var weight := clampf(delta * hover_follow_speed, 0.0, 1.0)
		smoothed_hover_position = smoothed_hover_position.lerp(target_position, weight)

	hover_root.position = smoothed_hover_position
	hover_root.visible = true

	var pulse := 0.5 + 0.5 * sin(pulse_time * hover_pulse_speed)
	hover_root.scale = Vector2.ONE * lerpf(1.0, 1.12, pulse)
	hover_glow.modulate = Color(1.0, 1.0, 1.0, lerpf(0.22, 0.52, pulse))
	hover_arrow.modulate = Color(1.0, 1.0, 1.0, lerpf(0.88, 1.0, pulse))
	if hover_label != null:
		hover_label.modulate = Color(1.0, 1.0, 1.0, lerpf(0.78, 1.0, pulse))


func _refresh_active_marble() -> void:
	if turn_manager and turn_manager.has_method("get_active_marble"):
		active_marble = turn_manager.call("get_active_marble") as Node3D
	else:
		active_marble = null


func _make_hud_card_style(accent_color: Color, fill_color: Color) -> StyleBoxFlat:
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


func _make_power_meter_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.035, 0.055, 0.84)
	style.border_color = Color(0.31, 0.97, 0.85, 0.94)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 18
	style.shadow_size = 18
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.3)
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style


func _make_power_bar_track_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.005, 0.012, 0.026, 0.88)
	style.border_color = Color(0.18, 0.52, 0.58, 0.72)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 12
	return style


func _make_power_bar_fill_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.82, 0.22, 0.94)
	style.border_color = Color(0.31, 0.97, 0.85, 0.82)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 12
	style.shadow_size = 8
	style.shadow_color = Color(0.31, 0.97, 0.85, 0.35)
	return style
