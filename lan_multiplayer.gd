extends Node

signal host_started(port: int)
signal joined_server()
signal connection_failed(message: String)
signal connection_status_changed(message: String)
signal discovery_status_changed(message: String)
signal host_discovered(address: String, port: int, host_name: String)
signal online_room_created(room_code: String)
signal online_room_ready(room_code: String, host_peer_id: int, guest_peer_id: int)
signal online_room_failed(message: String)
signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)
signal player_names_changed()
signal disconnected_from_server()

const DEFAULT_PORT: int = 24570
const DISCOVERY_PORT: int = 24571
const DEFAULT_ONLINE_RELAY_PORT: int = 24580
const DEFAULT_ONLINE_SERVER_URL: String = "ws://127.0.0.1:24580"
const MAX_CLIENTS: int = 1
const CONNECTION_TIMEOUT_SECONDS: float = 8.0
const DISCOVERY_MAGIC: String = "BANO_LAN_DISCOVERY_V1"
const DISCOVERY_BROADCAST_INTERVAL: float = 0.65
const DISCOVERY_REMINDER_SECONDS: float = 6.0
const RELAY_ROOM_CODE_MIN: int = 1000
const RELAY_ROOM_CODE_MAX: int = 9999
const RELAY_MAX_ROOM_ATTEMPTS: int = 200

enum Mode {
	OFFLINE,
	HOST,
	CLIENT,
	ONLINE_CONNECTING,
	ONLINE_HOST,
	ONLINE_CLIENT
}

var mode: int = Mode.OFFLINE
var peer: MultiplayerPeer = null
var port: int = DEFAULT_PORT
var host_address: String = ""
var player_names: Dictionary = {}
var connected_peer_ids: PackedInt32Array = PackedInt32Array()
var client_connected: bool = false
var connection_attempt_id: int = 0
var last_status_text: String = "LAN is idle."
var online_server_url: String = DEFAULT_ONLINE_SERVER_URL
var online_pending_action: String = ""
var online_pending_room_code: String = ""
var online_room_code: String = ""
var online_host_peer_id: int = 0
var online_guest_peer_id: int = 0
var online_room_is_ready: bool = false
var relay_server_mode: bool = false
var relay_rooms: Dictionary = {}
var relay_peer_to_room: Dictionary = {}
var discovery_sender: PacketPeerUDP = null
var discovery_listener: PacketPeerUDP = null
var discovery_scan_active: bool = false
var discovery_broadcast_active: bool = false
var discovery_broadcast_elapsed: float = 0.0
var discovery_scan_elapsed: float = 0.0
var discovered_hosts: Dictionary = {}


func _ready() -> void:
	randomize()
	_bind_multiplayer_signals()
	set_process(true)


func _process(delta: float) -> void:
	if discovery_broadcast_active:
		_process_discovery_broadcast(delta)
	if discovery_scan_active:
		_process_discovery_scan(delta)


func host_game(host_port: int = DEFAULT_PORT) -> Error:
	stop_network()
	port = _sanitize_port(host_port)
	_set_status("Starting LAN host on UDP port %d..." % port)
	var new_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = new_peer.create_server(port, MAX_CLIENTS)
	if error != OK:
		var message: String = "Could not host LAN game on UDP port %d (%s)." % [port, error_string(error)]
		_set_status(message)
		connection_failed.emit(message)
		return error

	peer = new_peer
	mode = Mode.HOST
	client_connected = false
	host_address = get_lan_address_hint()
	multiplayer.multiplayer_peer = peer
	player_names[1] = get_local_player_name()
	_set_status("Hosting LAN. Friend joins %s" % _format_join_targets())
	_start_host_discovery_broadcast()
	host_started.emit(port)
	player_names_changed.emit()
	return OK


func join_game(address: String, host_port: int = DEFAULT_PORT) -> Error:
	stop_network()
	stop_auto_join_scan()
	var target: Dictionary = _parse_join_target(address, host_port)
	host_address = str(target.get("address", "")).strip_edges()
	port = int(target.get("port", DEFAULT_PORT))
	if host_address == "":
		var missing_message: String = "Enter the host IP address shown on the host screen."
		_set_status(missing_message)
		connection_failed.emit(missing_message)
		return ERR_INVALID_PARAMETER

	_set_status("Connecting to %s:%d..." % [host_address, port])
	var new_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = new_peer.create_client(host_address, port)
	if error != OK:
		var message: String = "Could not start LAN connection to %s:%d (%s)." % [host_address, port, error_string(error)]
		_set_status(message)
		connection_failed.emit(message)
		return error

	peer = new_peer
	mode = Mode.CLIENT
	client_connected = false
	multiplayer.multiplayer_peer = peer
	connection_attempt_id += 1
	call_deferred("_watch_connection_timeout", connection_attempt_id, host_address, port)
	return OK


func stop_network() -> void:
	connection_attempt_id += 1
	client_connected = false
	_stop_host_discovery_broadcast()
	stop_auto_join_scan()
	if peer != null:
		peer.close()
	peer = null
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	mode = Mode.OFFLINE
	host_address = ""
	online_pending_action = ""
	online_pending_room_code = ""
	online_room_code = ""
	online_host_peer_id = 0
	online_guest_peer_id = 0
	online_room_is_ready = false
	relay_server_mode = false
	relay_rooms.clear()
	relay_peer_to_room.clear()
	player_names.clear()
	connected_peer_ids = PackedInt32Array()
	_set_status("Multiplayer is idle.")
	player_names_changed.emit()


func start_offline_game() -> void:
	stop_network()


func start_online_relay_server(server_port: int = DEFAULT_ONLINE_RELAY_PORT) -> Error:
	stop_network()
	relay_server_mode = true
	port = _sanitize_port(server_port)
	var new_peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	var error: Error = new_peer.create_server(port, "*")
	if error != OK:
		push_error("Could not start online relay on port %d: %s" % [port, error_string(error)])
		relay_server_mode = false
		return error

	peer = new_peer
	multiplayer.multiplayer_peer = peer
	_set_status("Online relay server running on ws://0.0.0.0:%d" % port)
	print("BANO online relay running on ws://0.0.0.0:%d" % port)
	return OK


func create_online_room(server_url: String = "") -> Error:
	stop_network()
	online_server_url = _resolve_online_server_url(server_url)
	if _online_server_url_is_local_on_mobile(online_server_url):
		var message: String = "Online server URL is still local. Set application/config/online_server_url to your public relay URL before exporting the phone build."
		_set_status(message)
		online_room_failed.emit(message)
		return ERR_INVALID_PARAMETER
	online_pending_action = "create"
	online_pending_room_code = ""
	_set_status("Connecting to online server...")
	return _connect_online_server()


func join_online_room(room_code: String, server_url: String = "") -> Error:
	stop_network()
	var clean_code: String = room_code.strip_edges().to_upper()
	if clean_code == "":
		var message: String = "Enter the room code from your friend."
		_set_status(message)
		online_room_failed.emit(message)
		return ERR_INVALID_PARAMETER

	online_server_url = _resolve_online_server_url(server_url)
	if _online_server_url_is_local_on_mobile(online_server_url):
		var message: String = "Online server URL is still local. Set application/config/online_server_url to your public relay URL before exporting the phone build."
		_set_status(message)
		online_room_failed.emit(message)
		return ERR_INVALID_PARAMETER
	online_pending_action = "join"
	online_pending_room_code = clean_code
	_set_status("Connecting to online server...")
	return _connect_online_server()


func start_auto_join_scan(host_port: int = DEFAULT_PORT) -> Error:
	if is_host() or is_client():
		return ERR_ALREADY_IN_USE

	stop_auto_join_scan()
	port = _sanitize_port(host_port)
	discovery_listener = PacketPeerUDP.new()
	var error: Error = discovery_listener.bind(DISCOVERY_PORT, "*")
	if error != OK:
		var message: String = "Could not search for LAN games (%s). You can still type the host IP manually." % error_string(error)
		_set_discovery_status(message)
		return error

	discovered_hosts.clear()
	discovery_scan_active = true
	discovery_scan_elapsed = 0.0
	_set_discovery_status("Searching for a LAN host on this Wi-Fi...")
	return OK


func stop_auto_join_scan() -> void:
	if discovery_listener != null:
		discovery_listener.close()
	discovery_listener = null
	discovery_scan_active = false
	discovery_scan_elapsed = 0.0
	discovered_hosts.clear()


func is_lan_game() -> bool:
	return mode != Mode.OFFLINE and peer != null


func is_online_game() -> bool:
	return mode == Mode.ONLINE_CONNECTING or mode == Mode.ONLINE_HOST or mode == Mode.ONLINE_CLIENT


func is_host() -> bool:
	return mode == Mode.HOST or mode == Mode.ONLINE_HOST


func is_client() -> bool:
	return mode == Mode.CLIENT or mode == Mode.ONLINE_CLIENT


func has_remote_player() -> bool:
	if is_online_game():
		return online_room_is_ready and get_remote_game_peer_id() > 0
	return not connected_peer_ids.is_empty()


func get_local_player_slot() -> int:
	return 1 if is_host() else 2


func get_local_player_name() -> String:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_player_name"):
		var saved_name: String = str(customization.call("get_player_name")).strip_edges()
		if saved_name != "":
			return saved_name
	return "Player"


func get_host_player_name() -> String:
	if is_online_game() and online_host_peer_id > 0:
		return str(player_names.get(online_host_peer_id, "Host"))
	return str(player_names.get(1, "Host"))


func get_client_player_name() -> String:
	if is_online_game() and online_guest_peer_id > 0:
		return str(player_names.get(online_guest_peer_id, "Friend"))
	for peer_id in connected_peer_ids:
		if int(peer_id) != 1 and player_names.has(int(peer_id)):
			return str(player_names[int(peer_id)])
	return str(player_names.get(2, "Friend"))


func get_status_text() -> String:
	match mode:
		Mode.HOST:
			if has_remote_player():
				return "Hosting LAN on %s. Friend connected." % _format_join_targets()
			return "Hosting LAN. Friend joins %s" % _format_join_targets()
		Mode.CLIENT:
			return "Connected to %s:%d" % [host_address, port] if client_connected else "Connecting to %s:%d..." % [host_address, port]
		Mode.ONLINE_CONNECTING:
			return "Connecting to online server..."
		Mode.ONLINE_HOST:
			return "Online room %s. Friend connected." % online_room_code if online_room_is_ready else "Online room %s. Waiting for friend..." % online_room_code
		Mode.ONLINE_CLIENT:
			return "Online room %s. Connected." % online_room_code if online_room_is_ready else "Joining online room %s..." % online_room_code
		_:
			return last_status_text


func get_room_host_peer_id() -> int:
	if is_online_game() and online_host_peer_id > 0:
		return online_host_peer_id
	return 1


func get_remote_game_peer_id() -> int:
	if mode == Mode.ONLINE_HOST:
		return online_guest_peer_id
	if mode == Mode.ONLINE_CLIENT:
		return online_host_peer_id
	for peer_id in connected_peer_ids:
		if int(peer_id) != 1:
			return int(peer_id)
	return 0


func get_online_room_code() -> String:
	return online_room_code


func get_lan_address_hint() -> String:
	var options: PackedStringArray = get_lan_address_options()
	if not options.is_empty():
		return options[0]
	return "127.0.0.1"


func get_lan_address_options() -> PackedStringArray:
	var addresses: PackedStringArray = IP.get_local_addresses()
	var options: PackedStringArray = PackedStringArray()
	for address in addresses:
		if address.begins_with("192.168.") or address.begins_with("10.") or _is_private_172_address(address):
			if not options.has(address):
				options.append(address)
	for address in addresses:
		if address.find(":") == -1 and not address.begins_with("127."):
			if not options.has(address):
				options.append(address)
	if options.is_empty():
		options.append("127.0.0.1")
	return options


func _is_private_172_address(address: String) -> bool:
	if not address.begins_with("172."):
		return false
	var parts: PackedStringArray = address.split(".")
	if parts.size() < 2:
		return false
	var second_octet: int = int(parts[1])
	return second_octet >= 16 and second_octet <= 31


func _bind_multiplayer_signals() -> void:
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.connect(_on_connected_to_server)
	if not multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.connect(_on_connection_failed)
	if not multiplayer.server_disconnected.is_connected(_on_server_disconnected):
		multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_peer_connected(peer_id: int) -> void:
	if is_online_game():
		if peer_id != 1 and not connected_peer_ids.has(peer_id):
			connected_peer_ids.append(peer_id)
			peer_joined.emit(peer_id)
			player_names_changed.emit()
		return

	if not connected_peer_ids.has(peer_id):
		connected_peer_ids.append(peer_id)
	peer_joined.emit(peer_id)
	if is_host():
		_stop_host_discovery_broadcast()
		_set_status("Friend connected. LAN is running on %s." % _format_join_targets())
		_send_existing_player_names(peer_id)
		_register_player_name.rpc_id(peer_id, 1, get_local_player_name())
	player_names_changed.emit()


func _on_peer_disconnected(peer_id: int) -> void:
	if relay_server_mode:
		_close_relay_room_for_peer(peer_id)
		return

	var index: int = connected_peer_ids.find(peer_id)
	if index != -1:
		connected_peer_ids.remove_at(index)
	player_names.erase(peer_id)
	if is_online_game() and peer_id == get_remote_game_peer_id():
		var message: String = "Friend disconnected from the online room."
		online_room_is_ready = false
		_set_status(message)
		online_room_failed.emit(message)
	if mode == Mode.HOST and connected_peer_ids.is_empty():
		_start_host_discovery_broadcast()
	peer_left.emit(peer_id)
	player_names_changed.emit()


func _on_connected_to_server() -> void:
	client_connected = true
	connection_attempt_id += 1
	stop_auto_join_scan()
	if mode == Mode.ONLINE_CONNECTING:
		_send_online_pending_request()
		return

	player_names[multiplayer.get_unique_id()] = get_local_player_name()
	_register_player_name.rpc_id(1, multiplayer.get_unique_id(), get_local_player_name())
	_set_status("Connected to %s:%d. Loading match..." % [host_address, port])
	joined_server.emit()
	player_names_changed.emit()


func _on_connection_failed() -> void:
	var failed_address: String = host_address
	var failed_port: int = port
	stop_network()
	var message: String = _make_connection_failed_message(failed_address, failed_port)
	_set_status(message)
	connection_failed.emit(message)


func _on_server_disconnected() -> void:
	var was_online: bool = is_online_game()
	stop_network()
	_set_status("Disconnected from online server." if was_online else "Disconnected from LAN host.")
	disconnected_from_server.emit()


func _send_existing_player_names(peer_id: int) -> void:
	for id in player_names.keys():
		_register_player_name.rpc_id(peer_id, int(id), str(player_names[id]))


func _connect_online_server() -> Error:
	var new_peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	var error: Error = new_peer.create_client(online_server_url)
	if error != OK:
		var message: String = "Could not connect to online server %s (%s)." % [online_server_url, error_string(error)]
		stop_network()
		_set_status(message)
		online_room_failed.emit(message)
		connection_failed.emit(message)
		return error

	peer = new_peer
	mode = Mode.ONLINE_CONNECTING
	client_connected = false
	multiplayer.multiplayer_peer = peer
	connection_attempt_id += 1
	call_deferred("_watch_online_connection_timeout", connection_attempt_id)
	return OK


func _send_online_pending_request() -> void:
	player_names[multiplayer.get_unique_id()] = get_local_player_name()
	match online_pending_action:
		"create":
			_set_status("Creating online room...")
			_server_create_online_room.rpc_id(1, get_local_player_name())
		"join":
			_set_status("Joining online room %s..." % online_pending_room_code)
			_server_join_online_room.rpc_id(1, online_pending_room_code, get_local_player_name())
		_:
			var message: String = "Online room request was missing."
			_set_status(message)
			online_room_failed.emit(message)


@rpc("any_peer", "call_local", "reliable")
func _register_player_name(peer_id: int, player_name: String) -> void:
	var clean_name: String = player_name.strip_edges()
	if clean_name == "":
		clean_name = "Player"
	player_names[peer_id] = clean_name.left(18)
	if is_host() and multiplayer.get_remote_sender_id() != 0:
		_register_player_name.rpc(peer_id, clean_name.left(18))
	player_names_changed.emit()


@rpc("any_peer", "call_remote", "reliable")
func _server_create_online_room(player_name: String) -> void:
	if not relay_server_mode:
		return
	var peer_id: int = multiplayer.get_remote_sender_id()
	if peer_id <= 0:
		return
	if relay_peer_to_room.has(peer_id):
		_online_room_failed.rpc_id(peer_id, "You are already in an online room.")
		return

	var room_code: String = _make_relay_room_code()
	if room_code == "":
		_online_room_failed.rpc_id(peer_id, "Server is full. Try again in a moment.")
		return

	relay_rooms[room_code] = {
		"host": peer_id,
		"guest": 0,
		"host_name": _clean_player_name(player_name, "Host"),
		"guest_name": ""
	}
	relay_peer_to_room[peer_id] = room_code
	_online_room_created.rpc_id(peer_id, room_code, peer_id)
	print("Room %s created by peer %d." % [room_code, peer_id])


@rpc("any_peer", "call_remote", "reliable")
func _server_join_online_room(room_code: String, player_name: String) -> void:
	if not relay_server_mode:
		return
	var peer_id: int = multiplayer.get_remote_sender_id()
	if peer_id <= 0:
		return
	if relay_peer_to_room.has(peer_id):
		_online_room_failed.rpc_id(peer_id, "You are already in an online room.")
		return

	var clean_code: String = room_code.strip_edges().to_upper()
	if not relay_rooms.has(clean_code):
		_online_room_failed.rpc_id(peer_id, "Room code not found.")
		return

	var room: Dictionary = relay_rooms[clean_code]
	var host_peer_id: int = int(room.get("host", 0))
	if host_peer_id <= 0 or not multiplayer.get_peers().has(host_peer_id):
		relay_rooms.erase(clean_code)
		_online_room_failed.rpc_id(peer_id, "That room is no longer available.")
		return
	if int(room.get("guest", 0)) != 0:
		_online_room_failed.rpc_id(peer_id, "That room is already full.")
		return

	room["guest"] = peer_id
	room["guest_name"] = _clean_player_name(player_name, "Friend")
	relay_rooms[clean_code] = room
	relay_peer_to_room[peer_id] = clean_code

	var host_name: String = str(room.get("host_name", "Host"))
	var guest_name: String = str(room.get("guest_name", "Friend"))
	_online_room_ready.rpc_id(host_peer_id, clean_code, host_peer_id, peer_id, host_name, guest_name)
	_online_room_ready.rpc_id(peer_id, clean_code, host_peer_id, peer_id, host_name, guest_name)
	print("Room %s ready: host %d guest %d." % [clean_code, host_peer_id, peer_id])


@rpc("authority", "call_remote", "reliable")
func _online_room_created(room_code: String, host_peer_id: int) -> void:
	online_room_code = room_code
	online_host_peer_id = host_peer_id
	online_guest_peer_id = 0
	online_room_is_ready = false
	mode = Mode.ONLINE_HOST
	connected_peer_ids = PackedInt32Array()
	player_names[host_peer_id] = get_local_player_name()
	_set_status("Online room %s created. Share this code with your friend." % online_room_code)
	online_room_created.emit(online_room_code)
	player_names_changed.emit()


@rpc("authority", "call_remote", "reliable")
func _online_room_ready(room_code: String, host_peer_id: int, guest_peer_id: int, host_name: String, guest_name: String) -> void:
	online_room_code = room_code
	online_host_peer_id = host_peer_id
	online_guest_peer_id = guest_peer_id
	online_room_is_ready = true
	mode = Mode.ONLINE_HOST if multiplayer.get_unique_id() == online_host_peer_id else Mode.ONLINE_CLIENT
	connected_peer_ids = PackedInt32Array()
	var remote_peer_id: int = get_remote_game_peer_id()
	if remote_peer_id > 0:
		connected_peer_ids.append(remote_peer_id)
	player_names[online_host_peer_id] = _clean_player_name(host_name, "Host")
	player_names[online_guest_peer_id] = _clean_player_name(guest_name, "Friend")
	_set_status("Online room %s is ready." % online_room_code)
	online_room_ready.emit(online_room_code, online_host_peer_id, online_guest_peer_id)
	if remote_peer_id > 0:
		peer_joined.emit(remote_peer_id)
	player_names_changed.emit()


@rpc("authority", "call_remote", "reliable")
func _online_room_failed(message: String) -> void:
	var clean_message: String = message.strip_edges()
	if clean_message == "":
		clean_message = "Online room failed."
	stop_network()
	_set_status(clean_message)
	online_room_failed.emit(clean_message)
	connection_failed.emit(clean_message)


func _watch_connection_timeout(attempt_id: int, target_address: String, target_port: int) -> void:
	if get_tree() == null:
		return

	await get_tree().create_timer(CONNECTION_TIMEOUT_SECONDS).timeout
	if attempt_id != connection_attempt_id or mode != Mode.CLIENT or client_connected:
		return

	stop_network()
	var message: String = _make_connection_failed_message(target_address, target_port)
	_set_status(message)
	connection_failed.emit(message)


func _watch_online_connection_timeout(attempt_id: int) -> void:
	if get_tree() == null:
		return

	await get_tree().create_timer(CONNECTION_TIMEOUT_SECONDS).timeout
	if attempt_id != connection_attempt_id or mode != Mode.ONLINE_CONNECTING:
		return

	var failed_url: String = online_server_url
	stop_network()
	var message: String = "Could not reach online server %s. Check your internet connection or server URL." % failed_url
	_set_status(message)
	online_room_failed.emit(message)
	connection_failed.emit(message)


func _parse_join_target(address: String, host_port: int) -> Dictionary:
	var parsed_address: String = address.strip_edges().replace(" ", "")
	var parsed_port: int = _sanitize_port(host_port)

	if parsed_address.begins_with("http://"):
		parsed_address = parsed_address.substr(7)
	elif parsed_address.begins_with("https://"):
		parsed_address = parsed_address.substr(8)

	var slash_index: int = parsed_address.find("/")
	if slash_index != -1:
		parsed_address = parsed_address.substr(0, slash_index)

	var colon_parts: PackedStringArray = parsed_address.split(":", false)
	if colon_parts.size() == 2 and colon_parts[1].is_valid_int():
		parsed_address = colon_parts[0]
		parsed_port = _sanitize_port(int(colon_parts[1]))

	if parsed_address.to_lower() == "localhost":
		parsed_address = "127.0.0.1"

	return {
		"address": parsed_address,
		"port": parsed_port
	}


func _sanitize_port(port_value: int) -> int:
	return clampi(port_value, 1024, 65535)


func _resolve_online_server_url(server_url: String) -> String:
	var configured_url: String = server_url.strip_edges()
	if configured_url == "":
		var customization: Node = get_node_or_null("/root/CustomizationState")
		if customization != null and customization.has_method("get_online_server_url"):
			configured_url = str(customization.call("get_online_server_url")).strip_edges()
	if configured_url == "":
		configured_url = str(ProjectSettings.get_setting("application/config/online_server_url", DEFAULT_ONLINE_SERVER_URL)).strip_edges()
	if configured_url == "":
		configured_url = DEFAULT_ONLINE_SERVER_URL
	if not configured_url.begins_with("ws://") and not configured_url.begins_with("wss://"):
		configured_url = "wss://%s" % configured_url
	return configured_url


func _online_server_url_is_local_on_mobile(server_url: String) -> bool:
	if not OS.has_feature("mobile"):
		return false
	var lower_url: String = server_url.to_lower()
	return lower_url.contains("127.0.0.1") or lower_url.contains("localhost")


func _clean_player_name(player_name: String, fallback: String) -> String:
	var clean_name: String = player_name.strip_edges()
	if clean_name == "":
		clean_name = fallback
	return clean_name.left(18)


func _make_relay_room_code() -> String:
	for _attempt in range(RELAY_MAX_ROOM_ATTEMPTS):
		var code: String = str(randi_range(RELAY_ROOM_CODE_MIN, RELAY_ROOM_CODE_MAX))
		if not relay_rooms.has(code):
			return code
	return ""


func _close_relay_room_for_peer(peer_id: int) -> void:
	if not relay_peer_to_room.has(peer_id):
		return

	var room_code: String = str(relay_peer_to_room.get(peer_id, ""))
	var room: Dictionary = relay_rooms.get(room_code, {})
	var host_peer_id: int = int(room.get("host", 0))
	var guest_peer_id: int = int(room.get("guest", 0))
	var other_peer_id: int = guest_peer_id if peer_id == host_peer_id else host_peer_id
	if other_peer_id > 0 and multiplayer.get_peers().has(other_peer_id):
		_online_room_failed.rpc_id(other_peer_id, "Friend disconnected from the online room.")

	relay_peer_to_room.erase(host_peer_id)
	relay_peer_to_room.erase(guest_peer_id)
	relay_rooms.erase(room_code)
	print("Room %s closed after peer %d disconnected." % [room_code, peer_id])


func _set_status(message: String) -> void:
	last_status_text = message
	connection_status_changed.emit(message)


func _make_connection_failed_message(target_address: String, target_port: int) -> String:
	if OS.has_feature("mobile"):
		return "Could not reach %s:%d. Keep both phones on the same Wi-Fi, turn off mobile data/VPN for testing, avoid guest Wi-Fi, and make sure the host app is open on HOST LAN." % [target_address, target_port]
	return "Could not reach %s:%d. Make sure the host pressed HOST LAN, both devices are on the same Wi-Fi/LAN, and the firewall allows Godot on UDP %d." % [target_address, target_port, target_port]


func _format_join_targets() -> String:
	var targets: PackedStringArray = PackedStringArray()
	for address in get_lan_address_options():
		targets.append("%s:%d" % [address, port])
	return " / ".join(targets)


func _start_host_discovery_broadcast() -> void:
	_stop_host_discovery_broadcast()
	discovery_sender = PacketPeerUDP.new()
	discovery_sender.set_broadcast_enabled(true)
	discovery_broadcast_active = true
	discovery_broadcast_elapsed = DISCOVERY_BROADCAST_INTERVAL
	_set_discovery_status("Auto-find is on. Waiting for a friend on the same Wi-Fi.")


func _stop_host_discovery_broadcast() -> void:
	if discovery_sender != null:
		discovery_sender.close()
	discovery_sender = null
	discovery_broadcast_active = false
	discovery_broadcast_elapsed = 0.0


func _process_discovery_broadcast(delta: float) -> void:
	if discovery_sender == null or not is_host():
		return
	discovery_broadcast_elapsed += delta
	if discovery_broadcast_elapsed < DISCOVERY_BROADCAST_INTERVAL:
		return
	discovery_broadcast_elapsed = 0.0
	_send_discovery_packet()


func _send_discovery_packet() -> void:
	if discovery_sender == null:
		return

	var payload: Dictionary = {
		"magic": DISCOVERY_MAGIC,
		"port": port,
		"name": get_local_player_name()
	}
	var packet: PackedByteArray = JSON.stringify(payload).to_utf8_buffer()
	for target in _get_discovery_broadcast_targets():
		discovery_sender.set_dest_address(target, DISCOVERY_PORT)
		discovery_sender.put_packet(packet)


func _process_discovery_scan(delta: float) -> void:
	if discovery_listener == null:
		return
	discovery_scan_elapsed += delta
	if discovery_scan_elapsed >= DISCOVERY_REMINDER_SECONDS:
		discovery_scan_elapsed = 0.0
		_set_discovery_status("Still searching. Keep both phones on the same Wi-Fi, with one phone already hosting.")

	while discovery_listener.get_available_packet_count() > 0:
		var packet: PackedByteArray = discovery_listener.get_packet()
		var sender_ip: String = discovery_listener.get_packet_ip()
		var text: String = packet.get_string_from_utf8()
		var data: Variant = JSON.parse_string(text)
		if typeof(data) != TYPE_DICTIONARY:
			continue
		var info: Dictionary = data as Dictionary
		if str(info.get("magic", "")) != DISCOVERY_MAGIC:
			continue

		var host_port: int = _sanitize_port(int(info.get("port", DEFAULT_PORT)))
		var host_name: String = str(info.get("name", "Host")).strip_edges()
		if host_name == "":
			host_name = "Host"
		var key: String = "%s:%d" % [sender_ip, host_port]
		if discovered_hosts.has(key):
			continue
		discovered_hosts[key] = true
		host_discovered.emit(sender_ip, host_port, host_name)
		_set_discovery_status("Found %s. Connecting..." % host_name)
		join_game(sender_ip, host_port)
		return


func _get_discovery_broadcast_targets() -> PackedStringArray:
	var targets: PackedStringArray = PackedStringArray(["255.255.255.255"])
	for address in get_lan_address_options():
		var parts: PackedStringArray = address.split(".")
		if parts.size() != 4:
			continue
		var subnet_broadcast: String = "%s.%s.%s.255" % [parts[0], parts[1], parts[2]]
		if not targets.has(subnet_broadcast):
			targets.append(subnet_broadcast)
	return targets


func _set_discovery_status(message: String) -> void:
	discovery_status_changed.emit(message)
