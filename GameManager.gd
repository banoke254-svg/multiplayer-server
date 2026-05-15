extends Node

const PLAYER_SCENE_PATH: String = "res://Player.tscn"
const SPAWN_SPACING: float = 4.0
const MENU_MUSIC_PLAYER_PATH: NodePath = NodePath("/root/MenuMusicPlayer")
const MENU_MUSIC_PATH: String = "res://audio_menu_theme.mp3"
const MENU_MUSIC_BUS_NAME: String = "Music"

@export var player_scene: PackedScene
@export var spawn_parent_path: NodePath

var selected_marble: String = "default"
var tutorial_done: bool = false
var menu_music_enabled: bool = true
var players: Dictionary = {}


func _ready() -> void:
	sync_from_customization()
	_bind_network_manager()
	call_deferred("start_menu_music")


func _bind_network_manager() -> void:
	var network_manager: Node = get_node_or_null("/root/NetworkManager")
	if network_manager == null:
		return

	if network_manager.has_signal("server_started") and not network_manager.server_started.is_connected(_on_server_started):
		network_manager.server_started.connect(_on_server_started)
	if network_manager.has_signal("connected_to_server") and not network_manager.connected_to_server.is_connected(_on_connected_to_server):
		network_manager.connected_to_server.connect(_on_connected_to_server)
	if network_manager.has_signal("peer_joined") and not network_manager.peer_joined.is_connected(_on_peer_connected):
		network_manager.peer_joined.connect(_on_peer_connected)
	if network_manager.has_signal("peer_left") and not network_manager.peer_left.is_connected(_on_peer_disconnected):
		network_manager.peer_left.connect(_on_peer_disconnected)


func _on_server_started() -> void:
	if not multiplayer.is_server():
		return
	_spawn_player_networked(multiplayer.get_unique_id())


func _on_connected_to_server() -> void:
	print("GameManager: Waiting for server to spawn local player.")


func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return

	for existing_id in players.keys():
		var existing_player: Node3D = players[existing_id] as Node3D
		if existing_player != null:
			spawn_player.rpc_id(id, int(existing_id), existing_player.global_position)

	_spawn_player_networked(id)


func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		despawn_player.rpc(id)


func _spawn_player_networked(peer_id: int) -> void:
	if players.has(peer_id):
		print("GameManager: Player already spawned for peer %d." % peer_id)
		return

	spawn_player.rpc(peer_id, _get_spawn_position(peer_id))


@rpc("authority", "call_local", "reliable")
func spawn_player(peer_id: int, spawn_position: Vector3) -> void:
	if players.has(peer_id):
		print("GameManager: Duplicate spawn ignored for peer %d." % peer_id)
		return

	var scene: PackedScene = _get_player_scene()
	if scene == null:
		push_error("GameManager: Player scene missing. Assign player_scene or create %s." % PLAYER_SCENE_PATH)
		return

	var player: Node3D = scene.instantiate() as Node3D
	if player == null:
		push_error("GameManager: Player scene root must be Node3D.")
		return

	player.name = "Player_%d" % peer_id
	player.set_multiplayer_authority(peer_id)
	_get_spawn_parent().add_child(player)
	player.global_position = spawn_position
	players[peer_id] = player
	print("GameManager: Spawned %s with authority %d." % [player.name, peer_id])


@rpc("authority", "call_local", "reliable")
func despawn_player(peer_id: int) -> void:
	if not players.has(peer_id):
		return

	var player: Node = players[peer_id] as Node
	players.erase(peer_id)
	if player != null and is_instance_valid(player):
		player.queue_free()
	print("GameManager: Despawned player for peer %d." % peer_id)


func _get_player_scene() -> PackedScene:
	if player_scene != null:
		return player_scene
	if ResourceLoader.exists(PLAYER_SCENE_PATH):
		return load(PLAYER_SCENE_PATH) as PackedScene
	return null


func _get_spawn_parent() -> Node:
	if spawn_parent_path != NodePath():
		var spawn_parent: Node = get_node_or_null(spawn_parent_path)
		if spawn_parent != null:
			return spawn_parent

	var current_scene: Node = get_tree().current_scene
	return current_scene if current_scene != null else self


func _get_spawn_position(peer_id: int) -> Vector3:
	var index: int = maxi(players.size(), 0)
	return Vector3(float(index) * SPAWN_SPACING, 1.0, 0.0)


func sync_from_customization() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null:
		selected_marble = "default"
		return
	if customization.has_method("get_selected_marble_type"):
		selected_marble = _sanitize_marble_type(str(customization.call("get_selected_marble_type")))
		return
	if customization.has_method("get_selected_palette"):
		selected_marble = resolve_marble_type(customization.call("get_selected_palette"))


func resolve_marble_type(palette: Dictionary) -> String:
	var raw_type: String = str(palette.get("marble_type", palette.get("pattern_name", "default")))
	return _sanitize_marble_type(raw_type)


func get_marble_scene_path(marble_type: String = "") -> String:
	match _sanitize_marble_type(marble_type if marble_type != "" else selected_marble):
		"stripe":
			return "res://marbles/marble_stripe.tscn"
		"gradient":
			return "res://marbles/marble_gradient.tscn"
		"glow":
			return "res://marbles/marble_glow.tscn"
		"flame":
			return "res://marbles/marble_flame.tscn"
		_:
			return "res://marbles/marble_default.tscn"


func _sanitize_marble_type(raw_type: String) -> String:
	match raw_type.to_lower():
		"stripe", "stripes":
			return "stripe"
		"gradient":
			return "gradient"
		"glow", "premium", "neon":
			return "glow"
		"flame", "fire":
			return "flame"
		"default", "classic", "standard", "swirl", "metal", "dark":
			return "default"
		_:
			return "default"


func mark_tutorial_done() -> void:
	tutorial_done = true


func start_menu_music() -> void:
	if not menu_music_enabled:
		return

	_ensure_audio_bus(MENU_MUSIC_BUS_NAME)
	var root: Window = get_tree().root
	if root == null:
		return

	var menu_music_player: AudioStreamPlayer = _get_or_create_menu_music_player(root)
	menu_music_player.bus = MENU_MUSIC_BUS_NAME if AudioServer.get_bus_index(MENU_MUSIC_BUS_NAME) != -1 else "Master"
	menu_music_player.max_polyphony = 1
	if menu_music_player.stream == null:
		menu_music_player.stream = _load_menu_music_stream()
	if menu_music_player.stream != null and not menu_music_player.playing:
		menu_music_player.play()


func _get_or_create_menu_music_player(root: Window) -> AudioStreamPlayer:
	var primary_player: AudioStreamPlayer = null
	for child in root.get_children():
		var player: AudioStreamPlayer = child as AudioStreamPlayer
		if player == null or not str(player.name).begins_with("MenuMusicPlayer"):
			continue
		if primary_player == null:
			primary_player = player
			primary_player.name = "MenuMusicPlayer"
			continue
		player.stop()
		player.queue_free()

	if primary_player == null:
		primary_player = AudioStreamPlayer.new()
		primary_player.name = "MenuMusicPlayer"
		primary_player.process_mode = Node.PROCESS_MODE_ALWAYS
		root.add_child(primary_player)
	return primary_player


func _play_menu_music_when_ready() -> void:
	if not menu_music_enabled:
		return
	var root: Window = get_tree().root
	if root == null:
		return
	var menu_music_player: AudioStreamPlayer = _get_or_create_menu_music_player(root)
	if menu_music_player == null or not menu_music_player.is_inside_tree():
		call_deferred("_play_menu_music_when_ready")
		return
	if menu_music_player.bus == "":
		menu_music_player.bus = MENU_MUSIC_BUS_NAME if AudioServer.get_bus_index(MENU_MUSIC_BUS_NAME) != -1 else "Master"
	if menu_music_player.stream == null:
		menu_music_player.stream = _load_menu_music_stream()
	if menu_music_player.stream != null and not menu_music_player.playing:
		menu_music_player.play()


func allow_menu_music() -> void:
	menu_music_enabled = true
	start_menu_music()


func stop_menu_music() -> void:
	menu_music_enabled = false
	var root: Window = get_tree().root
	if root == null:
		return
	for child in root.get_children():
		var menu_music_player: AudioStreamPlayer = child as AudioStreamPlayer
		if menu_music_player != null and str(menu_music_player.name).begins_with("MenuMusicPlayer"):
			menu_music_player.stop()


func _ensure_audio_bus(bus_name: String, send_bus_name: String = "Master") -> void:
	if bus_name == "" or AudioServer.get_bus_index(bus_name) != -1:
		return

	var bus_index: int = AudioServer.bus_count
	AudioServer.add_bus(bus_index)
	AudioServer.set_bus_name(bus_index, bus_name)
	if AudioServer.get_bus_index(send_bus_name) != -1:
		AudioServer.set_bus_send(bus_index, send_bus_name)


func _load_menu_music_stream() -> AudioStream:
	if ResourceLoader.exists(MENU_MUSIC_PATH):
		var stream_resource: Resource = ResourceLoader.load(MENU_MUSIC_PATH)
		if stream_resource is AudioStream:
			return _make_looping_audio_stream(stream_resource as AudioStream)

	var global_path: String = ProjectSettings.globalize_path(MENU_MUSIC_PATH)
	if FileAccess.file_exists(global_path):
		var file_bytes: PackedByteArray = FileAccess.get_file_as_bytes(global_path)
		if not file_bytes.is_empty():
			var mp3_stream: AudioStreamMP3 = AudioStreamMP3.new()
			mp3_stream.data = file_bytes
			mp3_stream.loop = true
			return mp3_stream
	return null


func _make_looping_audio_stream(source_stream: AudioStream) -> AudioStream:
	var music_stream: AudioStream = source_stream.duplicate(true) as AudioStream
	if music_stream == null:
		music_stream = source_stream
	if music_stream is AudioStreamMP3:
		(music_stream as AudioStreamMP3).loop = true
	elif music_stream is AudioStreamOggVorbis:
		(music_stream as AudioStreamOggVorbis).loop = true
	elif music_stream is AudioStreamWAV:
		(music_stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	return music_stream
