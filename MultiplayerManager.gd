extends Node

signal connected_to_server(client_id: String)
signal disconnected_from_server()
signal reconnecting(attempt: int, delay_seconds: float)
signal connection_failed(message: String)
signal connection_status_changed(message: String)
signal rooms_updated(rooms: Array)
signal online_players_updated(players: Array)
signal online_rankings_updated(rankings: Array)
signal game_events_updated(events: Array, payload: Dictionary)
signal room_created(room: Dictionary, code: String)
signal room_joined(room: Dictionary)
signal room_updated(room: Dictionary)
signal room_state_changed(players: int, max_players: int, ai_count: int)
signal start_match(room: Dictionary)
signal game_started(players: Array, ai_count: int)
signal game_message_received(message_type: String, payload: Dictionary, sender_id: String, target_id: String)
signal chat_message_received(message: Dictionary)
signal player_update_received(player_id: String, payload: Dictionary)
signal invite_sent(target_id: String, target_name: String, room_code: String)
signal room_invite_received(invite: Dictionary)
signal room_invite_declined(target_id: String, target_name: String, room_code: String)
signal friends_updated(friends: Array, incoming_requests: Array, outgoing_requests: Array)
signal friend_request_received(request: Dictionary)
signal friend_request_sent(target: Dictionary)
signal friend_request_accepted(friend: Dictionary)

const DEFAULT_SERVER_URL: String = "wss://multiplayer-server-rr9p.onrender.com"
const TOTAL_MATCH_SLOTS: int = 5
const CONNECTION_TIMEOUT_SECONDS: float = 20.0
const MAX_RECONNECT_ATTEMPTS: int = 8

var socket: WebSocketPeer = null
var server_url: String = DEFAULT_SERVER_URL
var client_id: String = ""
var session_token: String = ""
var current_room: Dictionary = {}
var current_players: Array = []
var current_ai_players: Array = []
var current_ai_count: int = 0
var match_started: bool = false
var auto_reconnect: bool = true
var reconnect_attempts: int = 0
var reconnect_timer: float = 0.0
var request_rooms_after_connect: bool = false
var pending_messages: Array[Dictionary] = []
var connection_started_msec: int = 0
var manually_disconnected: bool = false
var socket_was_open: bool = false
var last_status_text: String = "Online is idle."
var local_waiting_client_id: String = ""
var online_player_count: int = 0
var open_party_count: int = 0
var running_party_count: int = 0
var online_players_directory: Array = []
var online_rankings: Array = []
var online_game_events: Array = []
var online_friends: Array = []
var incoming_friend_requests: Array = []
var outgoing_friend_requests: Array = []


func _ready() -> void:
	set_process(true)


func _process(delta: float) -> void:
	if reconnect_timer > 0.0:
		reconnect_timer -= delta
		if reconnect_timer <= 0.0:
			_open_socket()

	if socket == null:
		return

	socket.poll()
	var state: int = socket.get_ready_state()

	match state:
		WebSocketPeer.STATE_OPEN:
			if not socket_was_open:
				_on_socket_opened()
			_read_packets()
		WebSocketPeer.STATE_CONNECTING:
			_check_connection_timeout()
		WebSocketPeer.STATE_CLOSING:
			pass
		WebSocketPeer.STATE_CLOSED:
			_on_socket_closed(socket.get_close_code(), socket.get_close_reason())


# Connect to Render or any public WebSocket URL. Use wss:// for production.
func connect_to_server(custom_url: String = "", should_request_rooms: bool = true) -> Error:
	var resolved_url: String = _resolve_server_url(custom_url)
	if _server_url_is_local_on_mobile(resolved_url):
		_fail("Use a public ws:// or wss:// URL. 127.0.0.1 will not work on phones.")
		return ERR_INVALID_PARAMETER

	if socket != null and server_url == resolved_url:
		var current_state: int = socket.get_ready_state()
		if current_state == WebSocketPeer.STATE_OPEN:
			if should_request_rooms:
				request_rooms_after_connect = false
				request_rooms()
			return OK
		if current_state == WebSocketPeer.STATE_CONNECTING:
			request_rooms_after_connect = request_rooms_after_connect or should_request_rooms
			_set_status("Still connecting to online server...")
			return OK

	server_url = resolved_url
	request_rooms_after_connect = should_request_rooms
	manually_disconnected = false
	reconnect_timer = 0.0
	return _open_socket()


func disconnect_from_server(emit_signal_value: bool = true) -> void:
	manually_disconnected = true
	reconnect_timer = 0.0
	pending_messages.clear()

	if socket != null:
		var state: int = socket.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN or state == WebSocketPeer.STATE_CONNECTING:
			socket.close(1000, "Client disconnected.")

	socket = null
	socket_was_open = false
	_clear_room_state()
	_set_status("Online is idle.")

	if emit_signal_value:
		disconnected_from_server.emit()


func public_match(max_players: int) -> Error:
	return send_or_queue({
		"type": "public_match",
		"max_players": clampi(max_players, 2, TOTAL_MATCH_SLOTS),
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id()
	})


func create_room(max_players: int) -> Error:
	return send_or_queue({
		"type": "create_room",
		"max_players": clampi(max_players, 2, TOTAL_MATCH_SLOTS),
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id()
	})


func join_room(code: String) -> Error:
	var clean_code: String = code.strip_edges().to_upper()
	if clean_code == "":
		_fail("Enter a party code.")
		return ERR_INVALID_PARAMETER
	return send_or_queue({
		"type": "join_room",
		"code": clean_code,
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id()
	})


func request_rooms() -> Error:
	return send_or_queue({
		"type": "list_rooms",
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id()
	})


func invite_player(target_client_id: String, max_players: int = TOTAL_MATCH_SLOTS) -> Error:
	var clean_id: String = target_client_id.strip_edges()
	if clean_id == "":
		_fail("Choose a player to invite.")
		return ERR_INVALID_PARAMETER
	if clean_id == client_id:
		_fail("You are already in your own party.")
		return ERR_INVALID_PARAMETER
	return send_or_queue({
		"type": "invite_player",
		"target_id": clean_id,
		"max_players": clampi(max_players, 2, TOTAL_MATCH_SLOTS),
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id()
	})


func decline_room_invite(inviter_client_id: String, room_code: String = "") -> Error:
	var clean_id: String = inviter_client_id.strip_edges()
	if clean_id == "":
		return ERR_INVALID_PARAMETER
	return send_or_queue({
		"type": "decline_room_invite",
		"from_id": clean_id,
		"code": room_code.strip_edges().to_upper(),
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id()
	})


func request_friend(target_client_id: String) -> Error:
	var clean_id: String = target_client_id.strip_edges()
	if clean_id == "":
		_fail("Choose a player to add.")
		return ERR_INVALID_PARAMETER
	if clean_id == client_id:
		_fail("You cannot add yourself.")
		return ERR_INVALID_PARAMETER
	return send_or_queue({
		"type": "friend_request",
		"target_id": clean_id,
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id()
	})


func accept_friend_request(requester_client_id: String) -> Error:
	var clean_id: String = requester_client_id.strip_edges()
	if clean_id == "":
		_fail("Choose a friend request.")
		return ERR_INVALID_PARAMETER
	return send_or_queue({
		"type": "accept_friend_request",
		"from_id": clean_id,
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id()
	})


func decline_friend_request(requester_client_id: String) -> Error:
	var clean_id: String = requester_client_id.strip_edges()
	if clean_id == "":
		return ERR_INVALID_PARAMETER
	return send_or_queue({
		"type": "decline_friend_request",
		"from_id": clean_id,
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id()
	})


func start_match_now() -> Error:
	return send_or_queue({
		"type": "start_match"
	})


func send_player_update(payload: Dictionary) -> Error:
	var message: Dictionary = payload.duplicate(true)
	message["type"] = "player_update"
	return send_or_queue(_encode_value(message))


func send_game_message(message_type: String, payload: Dictionary = {}, target_id: String = "") -> Error:
	if message_type.strip_edges() == "":
		return ERR_INVALID_PARAMETER
	return send_or_queue({
		"type": "game_message",
		"message_type": message_type,
		"target_id": target_id,
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id(),
		"payload": _encode_value(payload)
	})


func send_chat_message(text: String, target_id: String = "") -> Error:
	var clean_text: String = _sanitize_chat_text(text)
	if clean_text == "":
		_fail("Enter a chat message.")
		return ERR_INVALID_PARAMETER
	var clean_target_id: String = target_id.strip_edges()
	if clean_target_id != "":
		if not _player_id_in_list(clean_target_id, online_friends):
			_fail("Add this player as a friend before messaging.")
			return ERR_INVALID_PARAMETER
		var error: Error = send_or_queue({
			"type": "direct_chat_message",
			"target_id": clean_target_id,
			"text": clean_text,
			"name": get_local_player_name(),
			"login_id": get_local_player_login_id()
		})
		if error == OK:
			chat_message_received.emit({
				"text": clean_text,
				"sender_id": get_local_client_id(),
				"sender_name": get_local_player_name(),
				"target_id": clean_target_id,
				"is_local": true,
				"is_direct": true,
				"sent_at": Time.get_unix_time_from_system()
			})
		return error
	if current_room.is_empty():
		_fail("Join a party to chat.")
		return ERR_UNCONFIGURED

	var payload: Dictionary = {
		"text": clean_text,
		"sender_name": get_local_player_name(),
		"sent_at": Time.get_unix_time_from_system()
	}
	var error: Error = send_game_message("chat_message", payload, target_id)
	if error == OK:
		chat_message_received.emit({
			"text": clean_text,
			"sender_id": get_local_client_id(),
			"sender_name": get_local_player_name(),
			"target_id": target_id,
			"is_local": true,
			"sent_at": payload["sent_at"]
		})
	return error


# Backward-compatible names used by the current menu/game scripts.
func join_public_room(max_players: int) -> Error:
	return public_match(max_players)


func begin_local_public_waiting_room(max_players: int) -> void:
	var capacity: int = clampi(max_players, 2, TOTAL_MATCH_SLOTS)
	var local_id: String = get_local_client_id()
	if local_id == "":
		local_waiting_client_id = "local_%d" % Time.get_ticks_msec()
		local_id = local_waiting_client_id

	current_players = [{
		"id": local_id,
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id(),
		"is_host": true,
		"is_ai": false,
		"connected": true
	}]
	current_ai_players.clear()
	current_ai_count = 0
	current_room = {
		"id": "local_waiting_%d" % Time.get_ticks_msec(),
		"code": "MATCH",
		"room_code": "MATCH",
		"max_players": capacity,
		"human_capacity": capacity,
		"player_count": current_players.size(),
		"players": current_players.duplicate(true),
		"ai_count": current_ai_count,
		"ai_players": current_ai_players.duplicate(true),
		"slots": current_players.duplicate(true),
		"host_id": local_id,
		"is_private": false,
		"started": false,
		"local_waiting": true
	}
	match_started = false
	_set_status("Entered %d-player quick party. Waiting for players." % capacity)


func create_private_room(max_players: int) -> Error:
	return create_room(max_players)


func join_private_room(code: String) -> Error:
	return join_room(code)


func start_game() -> void:
	start_match_now()


func force_start_match_locally() -> void:
	if current_room.is_empty():
		return
	_ensure_local_player_in_current_room()
	if current_players.size() < 1:
		_fail("At least 1 player is needed to start.")
		return
	var local_id: String = get_local_client_id()
	current_room["host_id"] = local_id
	current_room["started"] = true
	current_room["allow_ai"] = true
	match_started = true
	for index in range(current_players.size()):
		if typeof(current_players[index]) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = current_players[index] as Dictionary
		player_data["is_host"] = str(player_data.get("id", "")) == local_id
		current_players[index] = player_data
	_ensure_ai_players_for_current_room()
	current_room["players"] = current_players.duplicate(true)
	current_room["ai_count"] = current_ai_count
	current_room["ai_players"] = current_ai_players.duplicate(true)
	var slots: Array = current_players.duplicate(true)
	slots.append_array(current_ai_players)
	current_room["slots"] = slots
	_set_status("Starting match locally.")
	start_match.emit(get_room())
	game_started.emit(get_players(), current_ai_count)


func send_json(payload: Dictionary) -> Error:
	return send_or_queue(payload)


func send_or_queue(payload: Dictionary) -> Error:
	payload = _with_local_player_profile(payload)
	if socket != null and socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		return _send_now(payload)

	pending_messages.append(payload)
	if socket != null and socket.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		_set_status("Action queued. Waiting for online server...")
		return OK
	return connect_to_server(server_url, false)


func is_online_game() -> bool:
	return not current_room.is_empty()


func is_in_match() -> bool:
	return is_online_game() and match_started


func is_host() -> bool:
	return client_id != "" and get_host_client_id() == client_id


func get_status_text() -> String:
	return last_status_text


func get_room() -> Dictionary:
	return current_room.duplicate(true)


func get_players() -> Array:
	return _get_human_players_snapshot()


func get_ai_players() -> Array:
	return current_ai_players.duplicate(true)


func get_ai_count() -> int:
	return current_ai_count


func get_online_player_count() -> int:
	return online_player_count


func get_open_party_count() -> int:
	return open_party_count


func get_running_party_count() -> int:
	return running_party_count


func get_online_players() -> Array:
	return online_players_directory.duplicate(true)


func get_online_rankings() -> Array:
	return online_rankings.duplicate(true)


func get_online_game_events() -> Array:
	return online_game_events.duplicate(true)


func get_online_friends() -> Array:
	return online_friends.duplicate(true)


func get_incoming_friend_requests() -> Array:
	return incoming_friend_requests.duplicate(true)


func get_outgoing_friend_requests() -> Array:
	return outgoing_friend_requests.duplicate(true)


func get_local_client_id() -> String:
	return client_id if client_id != "" else local_waiting_client_id


func get_host_client_id() -> String:
	var host_id: String = str(current_room.get("host_id", current_room.get("host_client_id", current_room.get("simulation_host_id", ""))))
	if host_id != "":
		return host_id
	var human_players: Array = _get_human_players_snapshot()
	for player in human_players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = player as Dictionary
		if bool(player_data.get("is_host", false)):
			return str(player_data.get("id", ""))
	if not human_players.is_empty() and typeof(human_players[0]) == TYPE_DICTIONARY:
		return str((human_players[0] as Dictionary).get("id", ""))
	return ""


func get_remote_player_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for player in _get_human_players_snapshot():
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var player_id: String = str((player as Dictionary).get("id", ""))
		if player_id != "" and player_id != client_id:
			ids.append(player_id)
	return ids


func get_player_index(target_client_id: String) -> int:
	var human_players: Array = _get_human_players_snapshot()
	for index in range(human_players.size()):
		var player: Dictionary = human_players[index] as Dictionary
		if str(player.get("id", "")) == target_client_id:
			return index
	return -1


func get_assigned_marble_name(target_client_id: String) -> String:
	return _get_marble_name_for_player_slot(get_player_index(target_client_id))


func get_player_name_by_id(target_client_id: String) -> String:
	for player in _get_human_players_snapshot():
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = player as Dictionary
		if str(data.get("id", "")) == target_client_id:
			var player_name: String = str(data.get("name", "")).strip_edges()
			return player_name if player_name != "" else "Player"
	return "Player"


func get_local_player_name() -> String:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_player_name"):
		var saved_name: String = str(customization.call("get_player_name")).strip_edges()
		if saved_name != "":
			return saved_name
	return "Player"


func get_local_player_login_id() -> String:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_player_login_id"):
		var saved_id: String = str(customization.call("get_player_login_id")).strip_edges()
		if saved_id != "":
			return saved_id
	return get_local_player_name()


func get_local_player_age() -> int:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_player_age"):
		return int(customization.call("get_player_age"))
	return 0


func get_local_coin_balance() -> int:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_coin_balance"):
		return int(customization.call("get_coin_balance"))
	return 0


func get_local_gold_balance() -> int:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_gold_balance"):
		return int(customization.call("get_gold_balance"))
	return 0


func get_local_country() -> String:
	var locale: String = OS.get_locale()
	var parts: PackedStringArray = locale.replace("-", "_").split("_")
	if parts.size() >= 2:
		var country: String = str(parts[parts.size() - 1]).strip_edges().to_upper()
		if country.length() >= 2 and country.length() <= 3:
			return country
	return "Unknown"


func _with_local_player_profile(payload: Dictionary) -> Dictionary:
	var message: Dictionary = payload.duplicate(true)
	if not message.has("name"):
		message["name"] = get_local_player_name()
	if not message.has("login_id"):
		message["login_id"] = get_local_player_login_id()
	if not message.has("country"):
		message["country"] = get_local_country()
	message["age"] = get_local_player_age()
	message["coin_balance"] = get_local_coin_balance()
	message["gold_balance"] = get_local_gold_balance()
	return message


func _open_socket() -> Error:
	if socket != null:
		var old_state: int = socket.get_ready_state()
		if old_state == WebSocketPeer.STATE_OPEN or old_state == WebSocketPeer.STATE_CONNECTING:
			socket.close()

	socket = WebSocketPeer.new()
	socket_was_open = false
	connection_started_msec = Time.get_ticks_msec()
	var error: Error = socket.connect_to_url(server_url)

	if error != OK:
		socket = null
		_fail("Could not connect to %s (%s)." % [server_url, error_string(error)])
		_schedule_reconnect()
		return error

	_set_status("Connecting to %s..." % server_url)
	return OK


func _on_socket_opened() -> void:
	socket_was_open = true
	reconnect_attempts = 0
	_set_status("Connected to online server.")

	if session_token != "":
		_send_now({
			"type": "resume_session",
			"session_token": session_token,
			"name": get_local_player_name(),
			"login_id": get_local_player_login_id()
		})

	if request_rooms_after_connect:
		request_rooms_after_connect = false
		_send_now({
			"type": "list_rooms",
			"name": get_local_player_name(),
			"login_id": get_local_player_login_id()
		})

	_flush_pending_messages()


func _on_socket_closed(code: int, reason: String) -> void:
	socket = null
	socket_was_open = false
	var clean_reason: String = reason.strip_edges()

	if manually_disconnected:
		return

	disconnected_from_server.emit()
	if clean_reason != "":
		_set_status("Disconnected: %s" % clean_reason)
	else:
		_set_status("Disconnected from online server.")

	_schedule_reconnect()


func _check_connection_timeout() -> void:
	var elapsed: float = float(Time.get_ticks_msec() - connection_started_msec) / 1000.0
	if elapsed < CONNECTION_TIMEOUT_SECONDS:
		return

	socket = null
	_fail("Connection timed out.")
	_schedule_reconnect()


func _schedule_reconnect() -> void:
	if manually_disconnected or not auto_reconnect:
		return
	if reconnect_attempts >= MAX_RECONNECT_ATTEMPTS:
		_fail("Could not reconnect to online server.")
		return

	reconnect_attempts += 1
	reconnect_timer = minf(pow(1.55, reconnect_attempts), 10.0)
	reconnecting.emit(reconnect_attempts, reconnect_timer)
	_set_status("Reconnecting in %.1f seconds..." % reconnect_timer)


func _flush_pending_messages() -> void:
	var queued: Array[Dictionary] = pending_messages.duplicate()
	pending_messages.clear()

	for message in queued:
		_send_now(message)


func _send_now(payload: Dictionary) -> Error:
	if socket == null or socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return ERR_UNAVAILABLE

	var error: Error = socket.send_text(JSON.stringify(payload))
	if error != OK:
		_fail("Could not send online message (%s)." % error_string(error))
	return error


func _read_packets() -> void:
	var latest_marble_state_message: Dictionary = {}
	while socket != null and socket.get_available_packet_count() > 0:
		var text: String = socket.get_packet().get_string_from_utf8()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) != TYPE_DICTIONARY:
			continue
		var message: Dictionary = parsed as Dictionary
		if str(message.get("type", "")) == "game_message" and str(message.get("message_type", "")) == "marble_states":
			latest_marble_state_message = message
			continue
		_handle_message(message)
	if not latest_marble_state_message.is_empty():
		_handle_message(latest_marble_state_message)


func _handle_message(message: Dictionary) -> void:
	match str(message.get("type", "")):
		"connected":
			client_id = str(message.get("client_id", client_id))
			local_waiting_client_id = ""
			session_token = str(message.get("session_token", session_token))
			connected_to_server.emit(client_id)
		"session_resumed":
			client_id = str(message.get("client_id", client_id))
			local_waiting_client_id = ""
			session_token = str(message.get("session_token", session_token))
			connected_to_server.emit(client_id)
		"session_resume_failed":
			session_token = ""
			_send_now({
				"type": "list_rooms",
				"name": get_local_player_name(),
				"login_id": get_local_player_login_id()
			})
			_set_status("Connected. Loading parties...")
		"rooms_list":
			var listed_rooms: Array = _array_from_message(message.get("rooms", message.get("parties", [])))
			online_player_count = int(message.get("online_players", _estimate_online_players_from_rooms(listed_rooms)))
			open_party_count = int(message.get("open_parties", listed_rooms.size()))
			running_party_count = int(message.get("running_parties", 0))
			online_players_directory = _normalize_online_players(_array_from_message(message.get("online_players_list", message.get("players_online", []))))
			online_rankings = _normalize_online_rankings(_array_from_message(message.get("rankings", message.get("ranking", message.get("leaderboard", [])))))
			rooms_updated.emit(listed_rooms)
			online_players_updated.emit(get_online_players())
			online_rankings_updated.emit(get_online_rankings())
		"online_players_update":
			var updated_rooms: Array = _array_from_message(message.get("rooms", message.get("parties", [])))
			if not updated_rooms.is_empty():
				rooms_updated.emit(updated_rooms)
			online_player_count = int(message.get("online_players", online_player_count))
			open_party_count = int(message.get("open_parties", open_party_count))
			running_party_count = int(message.get("running_parties", running_party_count))
			online_players_directory = _normalize_online_players(_array_from_message(message.get("online_players_list", message.get("players_online", []))))
			online_rankings = _normalize_online_rankings(_array_from_message(message.get("rankings", message.get("ranking", message.get("leaderboard", [])))))
			online_players_updated.emit(get_online_players())
			online_rankings_updated.emit(get_online_rankings())
		"game_events_update":
			online_game_events = _array_from_message(message.get("events", []))
			if online_game_events.is_empty() and typeof(message.get("latest_event", {})) == TYPE_DICTIONARY:
				online_game_events.append((message.get("latest_event", {}) as Dictionary).duplicate(true))
			game_events_updated.emit(online_game_events.duplicate(true), message.duplicate(true))
		"room_created":
			var created_room_payload = message.get("room", {})
			if typeof(created_room_payload) != TYPE_DICTIONARY or (created_room_payload as Dictionary).is_empty():
				created_room_payload = message.get("party", {})
			if typeof(created_room_payload) != TYPE_DICTIONARY or (created_room_payload as Dictionary).is_empty():
				created_room_payload = message
			_apply_room(created_room_payload, true)
			room_created.emit(get_room(), str(message.get("code", message.get("party_code", current_room.get("code", current_room.get("party_code", ""))))))
		"room_joined":
			client_id = str(message.get("client_id", client_id))
			var joined_room_payload = message.get("room", {})
			if typeof(joined_room_payload) != TYPE_DICTIONARY or (joined_room_payload as Dictionary).is_empty():
				joined_room_payload = message.get("party", {})
			if typeof(joined_room_payload) != TYPE_DICTIONARY or (joined_room_payload as Dictionary).is_empty():
				joined_room_payload = message
			_apply_room(joined_room_payload, true)
			room_joined.emit(get_room())
		"room_update":
			if current_room.is_empty():
				return
			var updated_room_payload = message.get("room", {})
			if typeof(updated_room_payload) != TYPE_DICTIONARY or (updated_room_payload as Dictionary).is_empty():
				updated_room_payload = message.get("party", {})
			if typeof(updated_room_payload) != TYPE_DICTIONARY or (updated_room_payload as Dictionary).is_empty():
				updated_room_payload = message
			if not _room_payload_matches_current(updated_room_payload):
				return
			_apply_room(updated_room_payload, true)
			room_updated.emit(get_room())
			room_state_changed.emit(
				_get_message_player_count(message.get("players", current_players.size())),
				int(message.get("max_players", current_room.get("max_players", 2))),
				int(message.get("ai_count", current_ai_count))
			)
		"start_match", "start_game":
			_apply_start_match_message(message)
			match_started = true
			start_match.emit(get_room())
			game_started.emit(get_players(), current_ai_count)
		"player_update":
			var decoded_player_update = _decode_value(message)
			var player_payload: Dictionary = decoded_player_update if typeof(decoded_player_update) == TYPE_DICTIONARY else {}
			player_update_received.emit(str(message.get("player_id", "")), player_payload)
		"invite_sent":
			var invite_room_payload = message.get("room", {})
			if typeof(invite_room_payload) != TYPE_DICTIONARY or (invite_room_payload as Dictionary).is_empty():
				invite_room_payload = message.get("party", {})
			if typeof(invite_room_payload) == TYPE_DICTIONARY and not (invite_room_payload as Dictionary).is_empty():
				_apply_room(invite_room_payload, true)
				room_updated.emit(get_room())
			invite_sent.emit(
				str(message.get("target_id", "")),
				str(message.get("target_name", "Player")),
				str(message.get("code", message.get("party_code", current_room.get("code", current_room.get("party_code", "")))))
			)
		"room_invite":
			var invite_payload: Dictionary = message.duplicate(true)
			room_invite_received.emit(invite_payload)
		"room_invite_declined":
			room_invite_declined.emit(
				str(message.get("target_id", "")),
				str(message.get("target_name", "Player")),
				str(message.get("code", message.get("room_code", message.get("party_code", ""))))
			)
		"friends_update":
			_apply_friends_update(message)
		"friend_request":
			var request_payload: Dictionary = {}
			var request_value = message.get("from", {})
			if typeof(request_value) == TYPE_DICTIONARY:
				request_payload = (request_value as Dictionary).duplicate(true)
			if request_payload.is_empty():
				request_payload = {
					"id": str(message.get("from_id", "")),
					"name": str(message.get("from_name", "Player"))
				}
			friend_request_received.emit(request_payload)
		"friend_request_sent":
			var target_payload: Dictionary = {}
			var target_value = message.get("target", {})
			if typeof(target_value) == TYPE_DICTIONARY:
				target_payload = (target_value as Dictionary).duplicate(true)
			if target_payload.is_empty():
				target_payload = {
					"id": str(message.get("target_id", "")),
					"name": str(message.get("target_name", "Player"))
				}
			friend_request_sent.emit(target_payload)
		"friend_request_accepted":
			var friend_payload: Dictionary = {}
			var friend_value = message.get("friend", {})
			if typeof(friend_value) == TYPE_DICTIONARY:
				friend_payload = (friend_value as Dictionary).duplicate(true)
			if friend_payload.is_empty():
				friend_payload = {
					"id": str(message.get("friend_id", "")),
					"name": str(message.get("friend_name", "Player"))
				}
			friend_request_accepted.emit(friend_payload)
		"direct_chat_message":
			var direct_message: Dictionary = {
				"text": _sanitize_chat_text(str(message.get("text", message.get("message", "")))),
				"sender_id": str(message.get("sender_id", "")),
				"sender_name": str(message.get("sender_name", "Player")),
				"target_id": str(message.get("target_id", "")),
				"target_name": str(message.get("target_name", "")),
				"is_local": false,
				"is_direct": true,
				"sent_at": message.get("sent_at", message.get("server_time", Time.get_unix_time_from_system()))
			}
			if str(direct_message.get("text", "")) != "":
				chat_message_received.emit(direct_message)
		"game_message":
			var decoded_payload = _decode_value(message.get("payload", {}))
			var payload: Dictionary = decoded_payload if typeof(decoded_payload) == TYPE_DICTIONARY else {}
			var message_type: String = str(message.get("message_type", ""))
			var sender_id: String = str(message.get("sender_id", ""))
			var target_id: String = str(message.get("target_id", ""))
			if message_type == "chat_message":
				var chat_message: Dictionary = _build_chat_message(payload, sender_id, target_id, false)
				if str(chat_message.get("text", "")) != "":
					chat_message_received.emit(chat_message)
			game_message_received.emit(
				message_type,
				payload,
				sender_id,
				target_id
			)
		"error":
			var error_message: String = str(message.get("error", "Online request failed."))
			if error_message == "Could not resume session.":
				session_token = ""
				_send_now({
					"type": "list_rooms",
					"name": get_local_player_name(),
					"login_id": get_local_player_login_id()
				})
				_set_status("Connected. Loading parties...")
			else:
				_fail(error_message)
		"server_shutdown":
			_fail("Online server is shutting down.")
		"pong":
			pass
		_:
			pass


func _apply_friends_update(message: Dictionary) -> void:
	online_friends = _normalize_online_players(_array_from_message(message.get("friends", [])))
	incoming_friend_requests = _normalize_online_players(_array_from_message(message.get("incoming_requests", [])))
	outgoing_friend_requests = _normalize_online_players(_array_from_message(message.get("outgoing_requests", [])))
	friends_updated.emit(get_online_friends(), get_incoming_friend_requests(), get_outgoing_friend_requests())


func _player_id_in_list(player_id: String, players: Array) -> bool:
	for player in players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = player as Dictionary
		if str(data.get("id", data.get("client_id", ""))).strip_edges() == player_id:
			return true
	return false


func _apply_room(room_value, allow_local_player_fallback: bool = false) -> void:
	if typeof(room_value) != TYPE_DICTIONARY:
		return

	current_room = (room_value as Dictionary).duplicate(true)
	current_players = _normalize_room_players(_array_from_message(current_room.get("players", [])), allow_local_player_fallback)
	if current_players.is_empty():
		var slot_players: Array = _normalize_room_players(_array_from_message(current_room.get("slots", [])), false)
		for player in slot_players:
			if typeof(player) != TYPE_DICTIONARY:
				continue
			var player_data: Dictionary = player as Dictionary
			if bool(player_data.get("is_ai", false)):
				continue
			current_players.append(player_data)
	current_ai_players = _array_from_message(current_room.get("ai_players", []))
	current_ai_count = int(current_room.get("ai_count", 0))
	if str(current_room.get("host_id", "")) == "":
		var inferred_host_id: String = get_host_client_id()
		if inferred_host_id != "":
			current_room["host_id"] = inferred_host_id
	match_started = bool(current_room.get("started", match_started))

	var code: String = str(current_room.get("code", current_room.get("room_code", current_room.get("party_code", ""))))
	var status: String = "Party %s: %d/%d players." % [
		code,
		current_players.size(),
		int(current_room.get("max_players", 2))
	]
	_set_status(status)


func _apply_start_match_message(message: Dictionary) -> void:
	var room_payload: Dictionary = {}
	var room_value = message.get("room", {})
	if typeof(room_value) != TYPE_DICTIONARY or (room_value as Dictionary).is_empty():
		room_value = message.get("party", {})
	if typeof(room_value) == TYPE_DICTIONARY:
		room_payload = (room_value as Dictionary).duplicate(true)
	if room_payload.is_empty():
		room_payload = current_room.duplicate(true)

	for key in ["room_id", "id", "party_id", "code", "room_code", "party_code", "party_name", "max_players", "human_capacity", "host_id", "host_client_id", "simulation_host_id", "server_authoritative", "authority_mode", "party_state"]:
		if message.has(key) and not room_payload.has(key):
			room_payload[key] = message[key]
	if message.has("room_id") and not room_payload.has("id"):
		room_payload["id"] = message["room_id"]
	if message.has("party_id") and not room_payload.has("id"):
		room_payload["id"] = message["party_id"]
	if message.has("party_code") and not room_payload.has("room_code"):
		room_payload["room_code"] = message["party_code"]
	if room_payload.has("human_capacity") and not room_payload.has("max_players"):
		room_payload["max_players"] = room_payload["human_capacity"]

	if message.has("players") and typeof(message.get("players")) == TYPE_ARRAY:
		room_payload["players"] = _array_from_message(message.get("players", []))
	if message.has("ai_players") and typeof(message.get("ai_players")) == TYPE_ARRAY:
		room_payload["ai_players"] = _array_from_message(message.get("ai_players", []))
	if message.has("slots") and typeof(message.get("slots")) == TYPE_ARRAY:
		room_payload["slots"] = _array_from_message(message.get("slots", []))
	if message.has("ai_count"):
		room_payload["ai_count"] = int(message.get("ai_count", 0))
	if message.has("total_slots") and not room_payload.has("total_slots"):
		room_payload["total_slots"] = int(message.get("total_slots", TOTAL_MATCH_SLOTS))
	room_payload["started"] = true

	_apply_room(room_payload, true)


func _ensure_ai_players_for_current_room() -> void:
	_ensure_local_player_in_current_room()
	if not bool(current_room.get("allow_ai", false)):
		current_ai_players.clear()
		current_ai_count = 0
		return
	current_ai_count = max(TOTAL_MATCH_SLOTS - current_players.size(), 0)
	if current_ai_players.size() == current_ai_count:
		return
	current_ai_players.clear()
	for index in range(current_ai_count):
		current_ai_players.append({
			"id": "ai_%d" % (index + 1),
			"name": "AI %d" % (index + 1),
			"is_host": false,
			"is_ai": true,
			"connected": true
		})


func _normalize_room_players(raw_players: Array, allow_local_player_fallback: bool = false) -> Array:
	var normalized: Array = []
	for index in range(raw_players.size()):
		var player = raw_players[index]
		if typeof(player) == TYPE_DICTIONARY:
			var player_data: Dictionary = (player as Dictionary).duplicate(true)
			if str(player_data.get("id", "")) == "" and str(player_data.get("client_id", "")) != "":
				player_data["id"] = str(player_data.get("client_id", ""))
			if str(player_data.get("name", "")) == "":
				player_data["name"] = "Player %d" % (index + 1)
			if str(player_data.get("id", "")) == client_id and str(player_data.get("login_id", "")) == "":
				player_data["login_id"] = get_local_player_login_id()
			if not player_data.has("is_host"):
				player_data["is_host"] = index == 0
			if not player_data.has("is_ai"):
				player_data["is_ai"] = false
			normalized.append(player_data)
		elif typeof(player) == TYPE_STRING or typeof(player) == TYPE_STRING_NAME:
			var player_id: String = str(player)
			normalized.append({
				"id": player_id,
				"name": "Player %d" % (index + 1),
				"is_host": index == 0,
				"is_ai": false,
				"connected": true
			})

	if normalized.is_empty() and allow_local_player_fallback and client_id != "" and not current_room.is_empty():
		normalized.append({
			"id": client_id,
			"name": get_local_player_name(),
			"login_id": get_local_player_login_id(),
			"is_host": true,
			"is_ai": false,
			"connected": true
		})
	return normalized


func _normalize_online_players(raw_players: Array) -> Array:
	var normalized: Array = []
	var seen_ids: Dictionary = {}
	for index in range(raw_players.size()):
		var player = raw_players[index]
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = (player as Dictionary).duplicate(true)
		if bool(player_data.get("is_ai", false)):
			continue
		var player_id: String = str(player_data.get("id", player_data.get("client_id", ""))).strip_edges()
		var player_name: String = str(player_data.get("name", "Player")).strip_edges()
		if player_id == "":
			continue
		if seen_ids.has(player_id):
			continue
		if player_name == "":
			player_name = "Player %d" % (normalized.size() + 1)
		player_data["id"] = player_id
		player_data["name"] = player_name
		player_data["connected"] = bool(player_data.get("connected", true))
		player_data["is_local"] = player_id == client_id
		seen_ids[player_id] = true
		normalized.append(player_data)
	return normalized


func _normalize_online_rankings(raw_rankings: Array) -> Array:
	var normalized: Array = []
	for index in range(raw_rankings.size()):
		var entry = raw_rankings[index]
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var entry_data: Dictionary = (entry as Dictionary).duplicate(true)
		var player_name: String = str(entry_data.get("name", "Player")).strip_edges()
		if player_name == "":
			player_name = "Player %d" % (normalized.size() + 1)
		entry_data["rank"] = int(entry_data.get("rank", normalized.size() + 1))
		entry_data["name"] = player_name
		entry_data["country"] = str(entry_data.get("country", "Unknown")).strip_edges()
		if str(entry_data.get("country", "")) == "":
			entry_data["country"] = "Unknown"
		entry_data["points"] = int(entry_data.get("points", 0))
		entry_data["wins"] = int(entry_data.get("wins", 0))
		entry_data["eliminations"] = int(entry_data.get("eliminations", 0))
		normalized.append(entry_data)
	return normalized


func _build_chat_message(payload: Dictionary, sender_id: String, target_id: String, is_local: bool) -> Dictionary:
	var clean_sender_id: String = sender_id.strip_edges()
	var sender_name: String = str(payload.get("sender_name", "")).strip_edges()
	if sender_name == "" and clean_sender_id != "":
		sender_name = get_player_name_by_id(clean_sender_id)
	if sender_name == "":
		sender_name = get_local_player_name() if is_local else "Player"

	return {
		"text": _sanitize_chat_text(str(payload.get("text", payload.get("message", "")))),
		"sender_id": clean_sender_id,
		"sender_name": sender_name,
		"target_id": target_id,
		"is_local": is_local or (clean_sender_id != "" and clean_sender_id == get_local_client_id()),
		"sent_at": payload.get("sent_at", payload.get("server_time", Time.get_unix_time_from_system()))
	}


func _sanitize_chat_text(text: String) -> String:
	var clean_text: String = text.strip_edges()
	clean_text = clean_text.replace("\n", " ").replace("\r", " ").replace("\t", " ")
	while clean_text.contains("  "):
		clean_text = clean_text.replace("  ", " ")
	return clean_text.left(160)


func _ensure_local_player_in_current_room() -> void:
	var local_id: String = get_local_client_id()
	if local_id == "":
		return
	for player in current_players:
		if typeof(player) == TYPE_DICTIONARY and str((player as Dictionary).get("id", "")) == local_id:
			return
	current_players.insert(0, {
		"id": local_id,
		"name": get_local_player_name(),
		"login_id": get_local_player_login_id(),
		"is_host": current_players.is_empty(),
		"is_ai": false,
		"connected": true
	})
	current_room["players"] = current_players.duplicate(true)


func _get_human_players_snapshot() -> Array:
	var normalized: Array = []
	var seen_ids: Dictionary = {}
	var player_sources: Array = [
		current_players,
		_array_from_message(current_room.get("players", [])),
		_array_from_message(current_room.get("slots", []))
	]

	for source in player_sources:
		if typeof(source) != TYPE_ARRAY:
			continue
		var source_players: Array = source as Array
		for index in range(source_players.size()):
			var player = source_players[index]
			if typeof(player) != TYPE_DICTIONARY:
				continue
			var player_data: Dictionary = (player as Dictionary).duplicate(true)
			if bool(player_data.get("is_ai", false)):
				continue
			var player_id: String = str(player_data.get("id", player_data.get("client_id", "")))
			if player_id == "" or seen_ids.has(player_id):
				continue
			player_data["id"] = player_id
			if str(player_data.get("name", "")).strip_edges() == "":
				player_data["name"] = "Player %d" % (normalized.size() + 1)
			normalized.append(player_data)
			seen_ids[player_id] = true

	var host_id: String = str(current_room.get("host_id", current_room.get("host_client_id", "")))
	if host_id != "":
		for index in range(normalized.size()):
			var player_data: Dictionary = normalized[index] as Dictionary
			if str(player_data.get("id", "")) != host_id:
				continue
			player_data["is_host"] = true
			if index > 0:
				normalized.remove_at(index)
				normalized.push_front(player_data)
			break

	return normalized


func _get_marble_name_for_player_slot(player_index: int) -> String:
	match player_index:
		0:
			return "PlayerMarble"
		1:
			return "AI MARBLE1"
		2:
			return "AI MARBLE2"
		3:
			return "AI MARBLE3"
		4:
			return "AI MARBLE4"
		_:
			return ""


func _room_payload_matches_current(room_payload) -> bool:
	if typeof(room_payload) != TYPE_DICTIONARY:
		return false
	var payload: Dictionary = room_payload as Dictionary
	var current_id: String = str(current_room.get("id", current_room.get("party_id", "")))
	var payload_id: String = str(payload.get("id", payload.get("room_id", payload.get("party_id", ""))))
	if current_id != "" and payload_id != "" and current_id == payload_id:
		return true
	var current_code: String = str(current_room.get("code", current_room.get("room_code", current_room.get("party_code", ""))))
	var payload_code: String = str(payload.get("code", payload.get("room_code", payload.get("party_code", ""))))
	if current_code != "" and payload_code != "" and current_code == payload_code:
		return true
	return payload_id == "" and payload_code == "" and (payload.has("players") or payload.has("player_count") or payload.has("ai_count"))


func _clear_room_state() -> void:
	current_room.clear()
	current_players.clear()
	current_ai_players.clear()
	current_ai_count = 0
	match_started = false
	local_waiting_client_id = ""
	online_player_count = 0
	open_party_count = 0
	running_party_count = 0
	online_players_directory.clear()
	online_game_events.clear()


func _array_from_message(value) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return (value as Array).duplicate(true)
	return []


func _get_message_player_count(value) -> int:
	if typeof(value) == TYPE_ARRAY:
		return (value as Array).size()
	return int(value)


func _estimate_online_players_from_rooms(rooms: Array) -> int:
	var total_players: int = 0
	for room in rooms:
		if typeof(room) != TYPE_DICTIONARY:
			continue
		var room_data: Dictionary = room as Dictionary
		if room_data.has("connected_count"):
			total_players += int(room_data.get("connected_count", 0))
		elif room_data.has("player_count"):
			total_players += int(room_data.get("player_count", 0))
		else:
			total_players += _array_from_message(room_data.get("players", [])).size()
	return total_players


func _resolve_server_url(custom_url: String) -> String:
	var resolved: String = custom_url.strip_edges()
	if resolved == "":
		var customization: Node = get_node_or_null("/root/CustomizationState")
		if customization != null and customization.has_method("get_online_server_url"):
			resolved = str(customization.call("get_online_server_url")).strip_edges()
			if OS.has_feature("mobile") and _is_local_development_url(resolved):
				resolved = ""
	if resolved == "":
		resolved = str(ProjectSettings.get_setting("application/config/online_server_url", DEFAULT_SERVER_URL)).strip_edges()
	if resolved == "":
		resolved = DEFAULT_SERVER_URL
	resolved = resolved.replace(" ", "")
	if resolved.begins_with("https://"):
		resolved = "wss://%s" % resolved.substr(8)
	elif resolved.begins_with("http://"):
		resolved = "ws://%s" % resolved.substr(7)
	if resolved.ends_with("/"):
		resolved = resolved.substr(0, resolved.length() - 1)
	if not resolved.begins_with("ws://") and not resolved.begins_with("wss://"):
		resolved = "wss://%s" % resolved
	return resolved


func _server_url_is_local_on_mobile(url: String) -> bool:
	if not OS.has_feature("mobile"):
		return false
	var lower_url: String = url.to_lower()
	return lower_url.contains("127.0.0.1") or lower_url.contains("localhost")


func _is_local_development_url(url: String) -> bool:
	var lower_url: String = url.to_lower()
	return lower_url.contains("127.0.0.1") or lower_url.contains("localhost") or lower_url.contains(":24580")


func _fail(message: String) -> void:
	var clean_message: String = message.strip_edges()
	if clean_message == "":
		clean_message = "Online request failed."
	_set_status(clean_message)
	connection_failed.emit(clean_message)


func _set_status(message: String) -> void:
	last_status_text = message
	connection_status_changed.emit(message)


func _encode_value(value):
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return value
		TYPE_STRING_NAME:
			return str(value)
		TYPE_VECTOR2:
			var vector2_value: Vector2 = value
			return {"__type": "Vector2", "x": vector2_value.x, "y": vector2_value.y}
		TYPE_VECTOR3:
			var vector3_value: Vector3 = value
			return {"__type": "Vector3", "x": vector3_value.x, "y": vector3_value.y, "z": vector3_value.z}
		TYPE_TRANSFORM3D:
			var transform_value: Transform3D = value
			return {
				"__type": "Transform3D",
				"basis_x": _encode_value(transform_value.basis.x),
				"basis_y": _encode_value(transform_value.basis.y),
				"basis_z": _encode_value(transform_value.basis.z),
				"origin": _encode_value(transform_value.origin)
			}
		TYPE_ARRAY:
			var encoded_array: Array = []
			for item in value:
				encoded_array.append(_encode_value(item))
			return encoded_array
		TYPE_DICTIONARY:
			var encoded_dictionary: Dictionary = {}
			for key in value.keys():
				encoded_dictionary[str(key)] = _encode_value(value[key])
			return encoded_dictionary
		_:
			return str(value)


func _decode_value(value):
	match typeof(value):
		TYPE_ARRAY:
			var decoded_array: Array = []
			for item in value:
				decoded_array.append(_decode_value(item))
			return decoded_array
		TYPE_DICTIONARY:
			var dictionary: Dictionary = value
			var encoded_type: String = str(dictionary.get("__type", ""))
			match encoded_type:
				"Vector2":
					return Vector2(float(dictionary.get("x", 0.0)), float(dictionary.get("y", 0.0)))
				"Vector3":
					return Vector3(float(dictionary.get("x", 0.0)), float(dictionary.get("y", 0.0)), float(dictionary.get("z", 0.0)))
				"Transform3D":
					return Transform3D(
						Basis(
							_decode_value(dictionary.get("basis_x", {})),
							_decode_value(dictionary.get("basis_y", {})),
							_decode_value(dictionary.get("basis_z", {}))
						),
						_decode_value(dictionary.get("origin", {}))
					)
				_:
					var decoded_dictionary: Dictionary = {}
					for key in dictionary.keys():
						decoded_dictionary[key] = _decode_value(dictionary[key])
					return decoded_dictionary
		_:
			return value
