extends Control

# Example UI wiring for a CODM-style online menu.
# Attach this to a Control scene that has these children:
# OnlineButton, OnlinePanel, PublicMatchButton, CreateRoomButton,
# JoinPrivateButton, StartMatchButton, RoomCodeInput, MaxPlayersOption, StatusLabel.

@export var render_server_url: String = "wss://your-render-app.onrender.com"

@onready var online_button: Button = %OnlineButton
@onready var online_panel: Control = %OnlinePanel
@onready var public_match_button: Button = %PublicMatchButton
@onready var create_room_button: Button = %CreateRoomButton
@onready var join_private_button: Button = %JoinPrivateButton
@onready var start_match_button: Button = %StartMatchButton
@onready var room_code_input: LineEdit = %RoomCodeInput
@onready var max_players_option: OptionButton = %MaxPlayersOption
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	online_panel.hide()
	_setup_max_players_options()
	_bind_buttons()
	_bind_multiplayer_signals()


func _setup_max_players_options() -> void:
	max_players_option.clear()
	for max_players in [2, 3, 4, 5]:
		max_players_option.add_item("%d Players" % max_players, max_players)


func _bind_buttons() -> void:
	online_button.pressed.connect(_on_online_pressed)
	public_match_button.pressed.connect(_on_public_match_pressed)
	create_room_button.pressed.connect(_on_create_room_pressed)
	join_private_button.pressed.connect(_on_join_private_pressed)
	start_match_button.pressed.connect(_on_start_match_pressed)


func _bind_multiplayer_signals() -> void:
	MultiplayerManager.connected_to_server.connect(_on_connected_to_server)
	MultiplayerManager.connection_status_changed.connect(_on_status_changed)
	MultiplayerManager.connection_failed.connect(_on_connection_failed)
	MultiplayerManager.room_created.connect(_on_room_created)
	MultiplayerManager.room_joined.connect(_on_room_joined)
	MultiplayerManager.room_updated.connect(_on_room_updated)
	MultiplayerManager.start_match.connect(_on_start_match)


func _on_online_pressed() -> void:
	online_panel.show()
	status_label.text = "Connecting..."
	MultiplayerManager.connect_to_server(render_server_url, true)


func _on_public_match_pressed() -> void:
	status_label.text = "Finding public match..."
	MultiplayerManager.public_match(_get_selected_max_players())


func _on_create_room_pressed() -> void:
	status_label.text = "Creating private room..."
	MultiplayerManager.create_room(_get_selected_max_players())


func _on_join_private_pressed() -> void:
	status_label.text = "Joining private room..."
	MultiplayerManager.join_room(room_code_input.text)


func _on_start_match_pressed() -> void:
	status_label.text = "Starting match..."
	MultiplayerManager.start_match_now()


func _get_selected_max_players() -> int:
	var selected_id: int = max_players_option.get_selected_id()
	if selected_id >= 2:
		return selected_id
	return clampi(max_players_option.get_selected() + 2, 2, 5)


func _on_connected_to_server(_client_id: String) -> void:
	status_label.text = "Connected. Choose Public Match, Private Room, or Create Room."


func _on_status_changed(message: String) -> void:
	status_label.text = message


func _on_connection_failed(message: String) -> void:
	status_label.text = message


func _on_room_created(room: Dictionary, code: String) -> void:
	status_label.text = "Private room created. Code: %s" % code
	_update_start_button(room)


func _on_room_joined(room: Dictionary) -> void:
	status_label.text = _format_room_state(room)
	_update_start_button(room)


func _on_room_updated(room: Dictionary) -> void:
	status_label.text = _format_room_state(room)
	_update_start_button(room)


func _on_start_match(_room: Dictionary) -> void:
	status_label.text = "Match starting..."
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("stop_menu_music"):
		game_manager.call("stop_menu_music")
	get_tree().change_scene_to_file("res://main.tscn")


func _update_start_button(room: Dictionary) -> void:
	start_match_button.visible = not room.is_empty()
	start_match_button.disabled = not MultiplayerManager.is_host()
	start_match_button.text = "Start Match" if MultiplayerManager.is_host() else "Waiting For Host"


func _format_room_state(room: Dictionary) -> String:
	var players: Array = room.get("players", [])
	var max_players: int = int(room.get("max_players", 2))
	var ai_count: int = int(room.get("ai_count", 0))
	var code: String = str(room.get("code", room.get("room_code", "")))
	return "Room %s | Players %d/%d | AI %d" % [code, players.size(), max_players, ai_count]
