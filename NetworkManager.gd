extends Node

signal connected_to_server(client_id: String)
signal connection_failed(message: String)
signal connection_status_changed(message: String)

signal room_created(room: Dictionary, code: String)
signal room_joined(room: Dictionary)
signal room_updated(room: Dictionary)
signal start_match(room: Dictionary)

var websocket := WebSocketPeer.new()

var server_url: String = ""
var connected := false
var reconnect_enabled := false

var current_room: Dictionary = {}
var local_client_id: String = ""
var is_room_host := false


func _process(_delta: float) -> void:
	if websocket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		websocket.poll()

		var state := websocket.get_ready_state()

		if state == WebSocketPeer.STATE_OPEN:
			while websocket.get_available_packet_count() > 0:
				var packet := websocket.get_packet()
				var text := packet.get_string_from_utf8()

				print("SERVER:", text)

				var data = JSON.parse_string(text)

				if typeof(data) == TYPE_DICTIONARY:
					_handle_server_message(data)

		elif state == WebSocketPeer.STATE_CLOSING:
			connection_status_changed.emit("Disconnecting...")

		elif state == WebSocketPeer.STATE_CLOSED:
			if connected:
				connected = false
				connection_status_changed.emit("Disconnected from server")


func connect_to_server(url: String, allow_reconnect := true) -> void:
	server_url = url
	reconnect_enabled = allow_reconnect

	connection_status_changed.emit("Connecting to server...")

	var err := websocket.connect_to_url(server_url)

	if err != OK:
		connection_failed.emit("Failed to connect")
		print("WebSocket Error:", err)
		return

	print("Connecting to:", server_url)


func public_match(max_players: int) -> void:
	if websocket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		connection_status_changed.emit("Not connected")
		return

	var data := {
		"type": "public_match",
		"max_players": max_players
	}

	send_json(data)

	connection_status_changed.emit("Waiting for server to place you in room...")


func create_room(max_players: int) -> void:
	var data := {
		"type": "create_room",
		"max_players": max_players
	}

	send_json(data)

	connection_status_changed.emit("Creating private room...")


func join_room(code: String) -> void:
	var data := {
		"type": "join_room",
		"code": code.strip_edges().to_upper()
	}

	send_json(data)

	connection_status_changed.emit("Joining room...")


func start_match_now() -> void:
	send_json({
		"type": "start_match"
	})


func send_json(data: Dictionary) -> void:
	if websocket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("Cannot send packet. Socket not open.")
		return

	var json := JSON.stringify(data)

	websocket.send_text(json)

	print("SENT:", json)


func _handle_server_message(data: Dictionary) -> void:
	var msg_type := str(data.get("type", ""))

	match msg_type:
		"connected":
			connected = true

			local_client_id = str(data.get("client_id", ""))

			connection_status_changed.emit("Connected to server")
			connected_to_server.emit(local_client_id)

			print("Connected with client id:", local_client_id)

		"room_created":
			current_room = data.get("room", {})
			is_room_host = true

			room_created.emit(current_room, str(data.get("code", "")))

			print("Private room created")

		"room_joined":
			current_room = data.get("room", {})

			room_joined.emit(current_room)

			print("Joined room")

		"room_update":
			current_room = data.get("room", {})

			room_updated.emit(current_room)

			print("Room updated")

		"start_match":
			start_match.emit(current_room)

			print("Match starting")

		"error":
			var msg := str(data.get("message", "Unknown error"))

			connection_status_changed.emit(msg)

			print("SERVER ERROR:", msg)


func disconnect_from_server() -> void:
	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		websocket.close()

	connected = false

	connection_status_changed.emit("Disconnected")


func is_host() -> bool:
	return is_room_host