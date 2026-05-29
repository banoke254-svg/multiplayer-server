extends Node3D

signal turn_changed(active_name: String, active_index: int)
signal scoreboard_updated(entries: Array)
signal marble_eliminated(player_name: String)
signal retry_awarded(player_name: String)
signal game_finished(winner_name: String)
signal player_disqualified(attacker_name: String)
signal player_won(coin_reward: int)

const IMPACT_SOUND_PATHS: Array[String] = [
	"res://audiomass-output.mp3",
	"res://New project 2.mp3"
]
const SHOT_SOUND_PATHS: Array[String] = [
	"res://New project 2.mp3"
]
const THUMP_SOUND_PATHS: Array[String] = [
	"res://audiomass-output.mp3"
]
const GPU_TRAIL_SCRIPT: Script = preload("res://addons/GPUTrail/GPUTrail3D.gd")
const FEEDBACK_FX_SCENE_PATH: String = "res://feedback/marble_feedback_fx.tscn"
const TRAIL_PARTICLE_SCENE_PATH: String = "res://looping_particle_trail_fbx_0.9mb.glb"
const MARBLE_TRAIL_RADIUS: float = 0.2
const MARBLE_TRAIL_SURFACE_GAP: float = 0.035
const MARBLE_TRAIL_VERTICAL_OFFSET: float = 0.045
const SHOOTING_MECHANIC_DRAG_IMAGE_PATH: String = "res://ui/shoot_mechanic_drag.png"
const SHOOTING_MECHANIC_SPLIT_IMAGE_PATH: String = "res://ui/shoot_mechanic_split.png"
const SHOOTING_MECHANIC_HOLD_IMAGE_PATH: String = "res://ui/shoot_mechanic_hold.png"
const MATCH_MECHANIC_GUIDE_SECONDS: float = 3.25
const IMPACT_AUDIO_POOL_SIZE: int = 4
const IMPACT_AUDIO_COOLDOWN: float = 0.08
const SHOT_AUDIO_COOLDOWN: float = 0.05
const THUMP_AUDIO_COOLDOWN: float = 0.08
const PHYSICS_IMPACT_COOLDOWN: float = 0.05
const PHYSICS_IMPACT_MIN_SPEED: float = 0.18
const PHYSICS_IMPACT_MAX_SPEED: float = 16.0
const LINEUP_DISTANCE_TIE_EPSILON: float = 0.035
const ONLINE_REMOTE_DISCOVERY_GRACE_SECONDS: float = 0.85
const ONLINE_REMOTE_READY_WAIT_SECONDS: float = 8.0
const ONLINE_CLIENT_SYNC_REQUEST_INTERVAL: float = 0.7
const ONLINE_CLIENT_SYNC_REQUEST_SECONDS: float = 12.0
const ONLINE_TOTAL_MATCH_SLOTS: int = 5
const ONLINE_PREDICTION_PRE_SHOT_GRACE_SECONDS: float = 0.04
const LAN_CLIENT_STATE_SNAP_DISTANCE: float = 2.4
const ONLINE_CLIENT_STATE_SNAP_DISTANCE: float = 8.0
const LAN_CLIENT_STATE_POSITION_DEADZONE: float = 0.015
const LAN_STATE_POSITION_CHANGE_EPSILON: float = 0.012
const LAN_STATE_VELOCITY_CHANGE_EPSILON: float = 0.035
const LAN_CLIENT_STATE_BUFFER_MAX_SAMPLES: int = 8
const LAN_CLIENT_STATE_BUFFER_MAX_AGE: float = 0.85
const LAN_STATE_MOVING_SYNC_THRESHOLD: float = 0.045
const ONLINE_LOCAL_PREDICTION_RECONCILE_DELAY: float = 0.28
const ONLINE_LOCAL_PREDICTION_MAX_SECONDS: float = 6.0
const ONLINE_LOCAL_PREDICTION_RECONCILE_SPEED: float = 5.0
const ONLINE_LOCAL_PREDICTION_SOFT_RECONCILE_SPEED: float = 2.6
const ONLINE_LOCAL_PREDICTION_POSITION_DEADZONE: float = 0.18
const AI_PLAYER_NAME_POOL: Array[String] = [
	"Oliver",
	"George",
	"Harry",
	"Jack",
	"Charlie",
	"Thomas",
	"Leo",
	"Henry",
	"Arthur",
	"James",
	"William",
	"Daniel",
	"Lucas",
	"Mason",
	"Ethan",
	"Noah"
]

const GAME_PHASE_LINEUP: int = 0
const GAME_PHASE_MATCH: int = 1
const GAME_PHASE_FINISHED: int = 2

const ACTION_MODE_NONE: int = 0
const ACTION_MODE_LINEUP: int = 1
const ACTION_MODE_APPROACH: int = 2
const ACTION_MODE_ATTACK: int = 3

@export var marbles: Array[Node3D]
@export var player_marble: Node3D
@export var hole: Node3D
@export var turn_delay: float = 0.0
@export var max_turn_time: float = 10.0
@export var max_settle_time: float = 5.0
@export var idle_player_warning_time: float = 3.0
@export var settle_velocity_threshold: float = 0.34
@export var settle_time: float = 0.0
@export var snap_settled_marbles_to_rest: bool = true
@export var camera_transition_timeout: float = 2.0
@export var camera_ready_delay: float = 0.0
@export var wait_for_camera_transition_before_turn: bool = false
@export var ai_aim_preview_time: float = 0.55
@export var instant_player_extra_turn_resolution: bool = false
@export var instant_player_resolution_grace_time: float = 0.04
@export var marble_collision_restitution: float = 0.98
@export var marble_collision_transfer_strength: float = 0.82
@export var marble_collision_spin_transfer: float = 0.32
@export var marble_collision_equal_deflect_strength: float = 1.0
@export var marble_max_upward_velocity: float = 2.2
@export var hole_capture_assist_force: float = 2.8
@export var hole_capture_centering_force: float = 1.35
@export var lan_state_send_rate: float = 24.0
@export var online_state_send_rate: float = 36.0
@export var online_full_snapshot_interval: float = 1.25
@export var lan_state_lerp_speed: float = 30.0
@export var online_interpolation_delay: float = 0.14
@export var online_extrapolation_limit: float = 0.08
@export var online_aim_send_rate: float = 30.0
@export var online_local_aim_smoothing: float = 0.58
@export var lan_remote_player_marble_name: String = "AI MARBLE1"
@export var ai_goal_base_score: float = 1.32
@export var ai_attack_base_score: float = 1.08
@export var ai_goal_distance_weight: float = 0.042
@export var ai_attack_distance_weight: float = 0.05
@export var ai_preferred_attack_distance: float = 7.5
@export var ai_goal_impulse_bias: float = 0.5
@export var ai_goal_impulse_per_meter: float = 0.72
@export var ai_attack_impulse_bias: float = 0.42
@export var ai_attack_impulse_per_meter: float = 0.64
@export var ai_line_penalty_radius: float = 0.9
@export var ai_jitter_degrees_goal: float = 0.9
@export var ai_jitter_degrees_attack: float = 1.55
@export var ai_lineup_jitter_degrees: float = 3.2
@export var ai_skill_spread: float = 0.18
@export var ai_lineup_mistake_chance: float = 0.12
@export var ai_power_variation: float = 0.07
@export var ai_attack_escape_alignment_weight: float = 0.34
@export var ai_attack_clear_lane_bonus: float = 0.12
@export var ai_attack_score_margin: float = 0.14
@export var ai_attack_min_hole_advantage: float = 1.4
@export var ai_attack_close_hole_threshold: float = 4.2
@export var ai_touch_then_hole_bonus: float = 0.52
@export var ai_touch_then_hole_alignment_tolerance: float = 1.25
@export var ai_touch_then_hole_hole_weight: float = 0.085
@export var ai_hole_exit_force_multiplier: float = 1.38
@export var ai_hole_exit_force_step: float = 0.14
@export var ai_hole_exit_force_max: float = 1.78
@export var ai_hole_exit_min_force_ratio: float = 0.74
@export var out_of_bounds_fall_y: float = -1.8
@export var respawn_edge_margin: float = 2.4
@export var respawn_height_above_ground: float = 0.26
@export var respawn_marble_clearance: float = 1.0
@export var hole_occupant_respawn_clearance: float = 1.25
@export var lineup_side_spacing: float = 0.75
@export var elimination_coin_reward: int = 10
@export var win_coin_reward: int = 100

var active_marbles: Array[Node3D] = []
var turn_order: Array[Node3D] = []
var current_marble_index: int = 0
var player_has_shot: bool = false
var _game_loop_started: bool = false
var lineup_starter_decided: bool = false
var game_phase: int = GAME_PHASE_LINEUP
var current_action_mode: int = ACTION_MODE_NONE
var current_actor: Node3D = null
var pending_approach_victim: Node3D = null
var pending_attack_victim: Node3D = null
var stored_approach_victim: Node3D = null
var stored_approach_owner: Node3D = null
var current_shot_entered_hole: bool = false
var current_shot_started_in_hole: bool = false
var current_shot_left_hole: bool = false
var current_hole_owner: Node3D = null
var hole_entry_order_this_shot: Array[Node3D] = []
var lineup_hole_entrants_this_round: Array[Node3D] = []
var pending_hole_turn_marble: Node3D = null
var hole_attack_level_active: bool = false
var ai_hole_attack_attempts: Dictionary = {}
var stroke_counts: Dictionary = {}
var elimination_counts_by_marble_name: Dictionary = {}
var respawn_surfaces: Array[CollisionShape3D] = []
var lineup_anchor: Vector3 = Vector3.ZERO
var player_eliminations_this_match: int = 0
var player_entered_hole_this_match: bool = false
var impact_audio_players: Array[AudioStreamPlayer3D] = []
var impact_audio_index: int = 0
var last_impact_timestamp_by_pair: Dictionary = {}
var previous_marble_velocities: Dictionary = {}
var impact_sound_streams: Array[AudioStream] = []
var shot_sound_streams: Array[AudioStream] = []
var thump_sound_streams: Array[AudioStream] = []
var marble_trail_roots: Dictionary = {}
var marble_trail_points: Dictionary = {}
var marble_trail_last_samples: Dictionary = {}
var marble_trail_last_directions: Dictionary = {}
var gpu_trail_resource_cache: Dictionary = {}
var banner_material_cache: Dictionary = {}
var speed_streak_shader_cache: Shader = null
var trail_aura_shader_cache: Shader = null
var ai_profiles: Dictionary = {}
var lan: Node = null
var lan_enabled: bool = false
var lan_is_host: bool = false
var lan_remote_player_marble: Node3D = null
var lan_remote_player_connected: bool = false
var lan_remote_player_name: String = "Friend"
var lan_client_active_marble_name: String = ""
var lan_client_active_display_name: String = "Waiting"
var lan_client_game_phase: int = GAME_PHASE_LINEUP
var lan_client_remote_turn_input_enabled: bool = false
var lan_client_targets: Dictionary = {}
var lan_client_state_buffers: Dictionary = {}
var lan_client_remote_time_offset: float = 0.0
var lan_client_remote_time_offset_ready: bool = false
var lan_state_send_accumulator: float = 0.0
var online_full_snapshot_accumulator: float = 0.0
var lan_last_sent_state_by_marble_name: Dictionary = {}
var lan_waiting_remote_player_shot: bool = false
var lan_remote_player_shot_ready: bool = false
var lan_remote_player_shot_data: Dictionary = {}
var lan_dragging: bool = false
var lan_drag_start: Vector2 = Vector2.ZERO
var lan_drag_touch_index: int = -1
var lan_drag_aim: Vector3 = Vector3.ZERO
var lan_drag_force: float = 0.0
var lan_drag_power_ratio: float = 0.0
var lan_drag_smoothed_vector: Vector2 = Vector2.ZERO
var lan_drag_has_smoothed_vector: bool = false
var lan_drag_reference_forward: Vector3 = Vector3.ZERO
var lan_drag_reference_right: Vector3 = Vector3.ZERO
var lan_last_aim_send_msec: int = 0
var lan_client_predicted_marble_name: String = ""
var lan_client_prediction_started_msec: int = 0
var lan_client_prediction_started_remote_seconds: float = -1.0
var lan_power_glass: Control = null
var lan_power_bar: ProgressBar = null
var lan_power_label: Label = null
var online: Node = null
var online_enabled: bool = false
var online_local_client_id: String = ""
var online_local_player_marble: Node3D = null
var online_client_id_by_marble_name: Dictionary = {}
var online_marble_name_by_client_id: Dictionary = {}
var online_fallback_marble_name_by_client_id: Dictionary = {}
var online_ready_client_ids: Dictionary = {}
var online_display_name_by_client_id: Dictionary = {}
var online_remote_trail_presets_by_marble_name: Dictionary = {}
var online_waiting_for_match_start: bool = false
var online_client_sync_elapsed: float = 0.0
var online_client_sync_request_timer: float = 0.0
var online_client_received_turn_state: bool = false
var match_mechanic_guide_shown: bool = false
var ai_display_names: Dictionary = {}
var marble_name_tags: Dictionary = {}
var marble_name_banners: Dictionary = {}
var feedback_fx: Node = null


func _ready() -> void:
	if player_marble == null:
		push_error("Player marble is not assigned.")
		return

	_normalize_marble_lists()
	if active_marbles.is_empty():
		push_error("No marbles were assigned to the turn manager.")
		return

	_assign_ai_player_names()
	_assign_ai_profiles()
	_ensure_marble_name_tags()
	_connect_marble_signals()
	_connect_hole_signals()
	_initialize_scoreboard()
	_cache_respawn_surfaces()
	call_deferred("_cache_respawn_surfaces")
	_setup_impact_audio()
	_setup_feedback_fx()
	_setup_lan_multiplayer()
	lineup_anchor = _get_lineup_anchor()
	set_physics_process(true)

	if online_waiting_for_match_start:
		call_deferred("_online_waiting_room_ready")
		return

	if lan_enabled and not lan_is_host:
		call_deferred("_lan_client_ready")
		return

	call_deferred("_post_ready_init")


func _get_current_scene_safe() -> Node:
	if not is_inside_tree():
		return null
	var tree: SceneTree = get_tree()
	if tree == null:
		return null
	return tree.current_scene


func _physics_process(delta: float) -> void:
	if online_waiting_for_match_start:
		_refresh_marble_name_tags()
		_update_marble_trails(delta)
		return
	if lan_enabled and not lan_is_host:
		_refresh_marble_name_tags()
		_smooth_lan_client_marbles(delta)
		_update_marble_trails(delta)
		_process_online_client_sync_request(delta)
		return

	_refresh_marble_name_tags()
	_update_marble_trails(delta)
	for marble in active_marbles:
		_clamp_marble_upward_velocity(marble)
		_assist_marble_into_hole(marble)
		_keep_marble_above_hole_floor(marble)
		if _should_respawn_marble(marble):
			_respawn_marble(marble)
	_cache_previous_marble_velocities()
	if lan_enabled and lan_is_host:
		_lan_broadcast_marble_state(delta)


func _setup_lan_multiplayer() -> void:
	online = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("is_online_game") and bool(online.call("is_online_game")):
		_setup_online_multiplayer(online)
		return

	lan = get_node_or_null("/root/LanMultiplayer")
	if lan == null or not lan.has_method("is_lan_game") or not bool(lan.call("is_lan_game")):
		return

	lan_enabled = true
	lan_is_host = bool(lan.call("is_host")) if lan.has_method("is_host") else multiplayer.is_server()
	var authority_peer_id: int = _get_lan_host_peer_id()
	if authority_peer_id > 0:
		set_multiplayer_authority(authority_peer_id, true)
	lan_remote_player_marble = _find_marble_by_name(lan_remote_player_marble_name)
	if lan_remote_player_marble == null:
		lan_remote_player_marble = _find_marble_by_name("AI MARBLE2")
	lan_remote_player_connected = bool(lan.call("has_remote_player")) if lan.has_method("has_remote_player") else false
	if lan.has_method("get_client_player_name"):
		lan_remote_player_name = str(lan.call("get_client_player_name"))

	if lan.has_signal("peer_joined") and not lan.peer_joined.is_connected(_on_lan_peer_joined):
		lan.peer_joined.connect(_on_lan_peer_joined)
	if lan.has_signal("peer_left") and not lan.peer_left.is_connected(_on_lan_peer_left):
		lan.peer_left.connect(_on_lan_peer_left)
	if lan.has_signal("player_names_changed") and not lan.player_names_changed.is_connected(_on_lan_player_names_changed):
		lan.player_names_changed.connect(_on_lan_player_names_changed)

	if not lan_is_host:
		_configure_lan_client_bodies()


func _setup_online_multiplayer(online_node: Node) -> void:
	lan = online_node
	online_enabled = true
	lan_enabled = true
	lan_is_host = bool(online_node.call("is_host")) if online_node.has_method("is_host") else false
	online_waiting_for_match_start = online_node.has_method("is_in_match") and not bool(online_node.call("is_in_match"))
	online_local_client_id = str(online_node.call("get_local_client_id")) if online_node.has_method("get_local_client_id") else ""
	_build_online_player_assignments()
	_apply_online_active_marble_roster()

	if lan_is_host:
		lan_remote_player_marble = _get_first_online_remote_player_marble()
	else:
		online_local_player_marble = _resolve_online_local_player_marble()
		lan_remote_player_marble = online_local_player_marble

	lan_remote_player_connected = _has_online_remote_players() if lan_is_host else true
	_update_lan_remote_player_name()

	if online_node.has_signal("game_message_received") and not online_node.game_message_received.is_connected(_on_online_game_message):
		online_node.game_message_received.connect(_on_online_game_message)
	if online_node.has_signal("game_started") and not online_node.game_started.is_connected(_on_online_match_started):
		online_node.game_started.connect(_on_online_match_started)

	if not online_waiting_for_match_start and not lan_is_host:
		_apply_local_online_marble_customization()
		_configure_lan_client_bodies()


func _build_online_player_assignments() -> void:
	online_client_id_by_marble_name.clear()
	online_marble_name_by_client_id.clear()
	if online == null:
		return

	var used_marbles: Dictionary = {}
	var players: Array = _get_online_human_players_snapshot()
	var human_index: int = 0
	for player in players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = player as Dictionary
		if bool(player_data.get("is_ai", false)):
			continue
		var client_id: String = str(player_data.get("id", ""))
		if client_id == "":
			continue
		var player_name: String = str(player_data.get("name", "")).strip_edges()
		if player_name != "":
			online_display_name_by_client_id[client_id] = player_name
		var marble_name: String = _get_online_marble_name_for_player_index(human_index)
		if marble_name == "" and online.has_method("get_assigned_marble_name"):
			marble_name = str(online.call("get_assigned_marble_name", client_id))
		human_index += 1
		if marble_name == "":
			continue
		online_marble_name_by_client_id[client_id] = marble_name
		used_marbles[marble_name] = true
		if client_id != online_local_client_id:
			online_client_id_by_marble_name[marble_name] = client_id

	for client_id_variant in online_fallback_marble_name_by_client_id.keys():
		var fallback_client_id: String = str(client_id_variant)
		if fallback_client_id == "" or fallback_client_id == online_local_client_id:
			continue
		if online_marble_name_by_client_id.has(fallback_client_id):
			continue
		var fallback_marble_name: String = str(online_fallback_marble_name_by_client_id.get(fallback_client_id, ""))
		if fallback_marble_name == "" or used_marbles.has(fallback_marble_name):
			fallback_marble_name = _get_next_free_online_remote_marble_name()
		if fallback_marble_name == "":
			continue
		online_marble_name_by_client_id[fallback_client_id] = fallback_marble_name
		online_client_id_by_marble_name[fallback_marble_name] = fallback_client_id
		used_marbles[fallback_marble_name] = true


func _get_online_human_players_snapshot() -> Array:
	var players: Array = []
	var seen_ids: Dictionary = {}
	if online == null:
		return players

	if online.has_method("get_players"):
		_append_online_player_source(online.call("get_players"), players, seen_ids)

	if online.has_method("get_room"):
		var room_value = online.call("get_room")
		if typeof(room_value) == TYPE_DICTIONARY:
			var room_data: Dictionary = room_value as Dictionary
			_append_online_player_source(room_data.get("players", []), players, seen_ids)
			_append_online_player_source(room_data.get("slots", []), players, seen_ids)

	var host_id: String = str(online.call("get_host_client_id")) if online.has_method("get_host_client_id") else ""
	if host_id != "":
		for index in range(players.size()):
			var player_data: Dictionary = players[index] as Dictionary
			if str(player_data.get("id", "")) != host_id:
				continue
			player_data["is_host"] = true
			if index > 0:
				players.remove_at(index)
				players.push_front(player_data)
			break

	return players


func _apply_online_active_marble_roster() -> void:
	if not online_enabled:
		return

	var online_players: Array = _get_online_human_players_snapshot()
	var roster_names: Dictionary = {}
	for client_id_variant in online_marble_name_by_client_id.keys():
		var marble_name: String = str(online_marble_name_by_client_id.get(client_id_variant, ""))
		if marble_name != "":
			roster_names[marble_name] = true

	var human_slot_count: int = _get_online_human_slot_count(online_players.size())
	for player_index in range(human_slot_count):
		var human_marble_name: String = _get_online_marble_name_for_player_index(player_index)
		if human_marble_name != "":
			roster_names[human_marble_name] = true

	var online_ai_marble_names: PackedStringArray = _get_online_ai_marble_names(online_players.size())
	for marble_name in online_ai_marble_names:
		roster_names[marble_name] = true

	if roster_names.is_empty():
		return
	if _online_match_state_locked():
		return

	var all_marbles: Array[Node3D] = []
	for marble in _discover_scene_marbles():
		if marble != null and not all_marbles.has(marble):
			all_marbles.append(marble)
	for marble in marbles:
		if marble != null and not all_marbles.has(marble):
			all_marbles.append(marble)
	if player_marble != null and not all_marbles.has(player_marble):
		all_marbles.append(player_marble)

	var marble_by_name: Dictionary = {}
	for marble in all_marbles:
		marble_by_name[String(marble.name)] = marble
		var should_play: bool = roster_names.has(String(marble.name))
		_set_online_marble_roster_enabled(marble, should_play)

	var online_marbles: Array[Node3D] = []
	for player in online_players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var client_id: String = str((player as Dictionary).get("id", ""))
		var marble_name: String = str(online_marble_name_by_client_id.get(client_id, ""))
		var assigned_marble: Node3D = marble_by_name.get(marble_name, null) as Node3D
		if assigned_marble != null and not online_marbles.has(assigned_marble):
			online_marbles.append(assigned_marble)

	for marble_name in online_ai_marble_names:
		var ai_marble: Node3D = marble_by_name.get(marble_name, null) as Node3D
		if ai_marble != null and not online_marbles.has(ai_marble):
			online_marbles.append(ai_marble)

	for marble in all_marbles:
		var should_play: bool = roster_names.has(String(marble.name))
		if should_play:
			if not online_marbles.has(marble):
				online_marbles.append(marble)

	if online_marbles.is_empty():
		return

	marbles = online_marbles
	active_marbles = online_marbles.duplicate()
	turn_order = active_marbles.duplicate()


func _set_online_marble_roster_enabled(marble: Node3D, enabled: bool) -> void:
	if marble == null:
		return
	var was_configured: bool = marble.has_meta("bano_online_roster_enabled")
	var was_enabled: bool = bool(marble.get_meta("bano_online_roster_enabled", enabled))
	marble.set_meta("bano_online_roster_enabled", enabled)

	marble.visible = enabled
	if enabled:
		_restore_online_marble_visual(marble)
	marble.set_process(enabled)
	marble.set_physics_process(enabled)
	var body: RigidBody3D = marble as RigidBody3D
	if body != null:
		if not body.has_meta("bano_online_roster_collision_layer"):
			body.set_meta("bano_online_roster_collision_layer", body.collision_layer)
			body.set_meta("bano_online_roster_collision_mask", body.collision_mask)
		body.freeze = not enabled
		if enabled:
			_ensure_marble_collision_reporting(body)
			if not was_configured or not was_enabled:
				body.sleeping = false
		else:
			body.sleeping = true
			body.linear_velocity = Vector3.ZERO
			body.angular_velocity = Vector3.ZERO
		var restored_layer: int = int(body.get_meta("bano_online_roster_collision_layer", body.collision_layer))
		var restored_mask: int = int(body.get_meta("bano_online_roster_collision_mask", body.collision_mask))
		body.collision_layer = maxi(restored_layer, 1) if enabled else 0
		body.collision_mask = maxi(restored_mask, 1) if enabled else 0


func _online_match_state_locked() -> bool:
	return online_enabled and _game_loop_started


func _restore_online_marble_visual(marble: Node3D) -> void:
	var glass_model: Node3D = marble.get_node_or_null("GlassBallModel") as Node3D
	if glass_model != null:
		glass_model.visible = true


func _append_online_player_source(source, output: Array, seen_ids: Dictionary) -> void:
	if typeof(source) != TYPE_ARRAY:
		return
	var source_array: Array = source as Array
	for index in range(source_array.size()):
		var value = source_array[index]
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = (value as Dictionary).duplicate(true)
		if bool(player_data.get("is_ai", false)):
			continue
		var client_id: String = str(player_data.get("id", player_data.get("client_id", "")))
		if client_id == "" or seen_ids.has(client_id):
			continue
		player_data["id"] = client_id
		if str(player_data.get("name", "")).strip_edges() == "":
			player_data["name"] = "Player %d" % (output.size() + 1)
		output.append(player_data)
		seen_ids[client_id] = true


func _get_online_ai_marble_names(human_count: int) -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	var ai_count: int = _get_online_ai_count()
	if ai_count <= 0:
		return names

	var effective_human_count: int = _get_online_human_slot_count(human_count, ai_count)
	var start_index: int = clampi(effective_human_count, 0, ONLINE_TOTAL_MATCH_SLOTS - 1)
	for ai_index in range(ai_count):
		var marble_name: String = _get_online_marble_name_for_player_index(start_index + ai_index)
		if marble_name == "":
			continue
		if names.has(marble_name):
			continue
		names.append(marble_name)
	return names


func _get_online_human_slot_count(snapshot_count: int = -1, ai_count: int = -1) -> int:
	var human_count: int = _get_online_human_players_snapshot().size() if snapshot_count < 0 else snapshot_count
	var known_ai_count: int = _get_online_ai_count() if ai_count < 0 else ai_count
	if known_ai_count > 0:
		human_count = maxi(human_count, ONLINE_TOTAL_MATCH_SLOTS - known_ai_count)
	return clampi(human_count, 0, ONLINE_TOTAL_MATCH_SLOTS)


func _get_online_ai_count() -> int:
	if online == null:
		return 0

	if online.has_method("get_ai_count"):
		var method_count: int = int(online.call("get_ai_count"))
		if method_count > 0:
			return method_count

	var room_data: Dictionary = {}
	if online.has_method("get_room"):
		var room_value = online.call("get_room")
		if typeof(room_value) == TYPE_DICTIONARY:
			room_data = room_value as Dictionary

	if room_data.has("ai_count"):
		return max(int(room_data.get("ai_count", 0)), 0)

	var ai_players_value = room_data.get("ai_players", [])
	if typeof(ai_players_value) == TYPE_ARRAY:
		return (ai_players_value as Array).size()

	var slots_value = room_data.get("slots", [])
	if typeof(slots_value) == TYPE_ARRAY:
		var count: int = 0
		var slots: Array = slots_value as Array
		for slot in slots:
			if typeof(slot) == TYPE_DICTIONARY and bool((slot as Dictionary).get("is_ai", false)):
				count += 1
		return count

	return 0


func _has_online_remote_players() -> bool:
	return not online_client_id_by_marble_name.is_empty()


func _get_or_assign_online_player_marble(client_id: String) -> Node3D:
	if client_id == "":
		return null
	_build_online_player_assignments()
	var marble_name: String = str(online_marble_name_by_client_id.get(client_id, ""))
	if marble_name == "" and online != null and online.has_method("get_host_client_id") and client_id == str(online.call("get_host_client_id")):
		marble_name = "PlayerMarble"
		online_marble_name_by_client_id[client_id] = marble_name
	elif marble_name == "" and client_id != online_local_client_id:
		return _assign_online_remote_player_fallback(client_id)
	return _find_marble_by_name(marble_name)


func _assign_online_remote_player_fallback(client_id: String) -> Node3D:
	if client_id == "" or client_id == online_local_client_id:
		return null
	var marble_name: String = str(online_fallback_marble_name_by_client_id.get(client_id, ""))
	if marble_name == "" or online_client_id_by_marble_name.has(marble_name):
		marble_name = _get_next_free_online_remote_marble_name()
	if marble_name == "":
		return null
	online_fallback_marble_name_by_client_id[client_id] = marble_name
	online_marble_name_by_client_id[client_id] = marble_name
	online_client_id_by_marble_name[marble_name] = client_id
	var marble: Node3D = _find_marble_by_name(marble_name)
	if marble != null:
		lan_remote_player_marble = marble
		lan_remote_player_connected = true
	return marble


func _get_next_free_online_remote_marble_name() -> String:
	var local_marble_name: String = str(online_marble_name_by_client_id.get(online_local_client_id, ""))
	for player_index in range(1, 5):
		var marble_name: String = _get_online_marble_name_for_player_index(player_index)
		if marble_name == "":
			continue
		if marble_name == local_marble_name:
			continue
		if online_client_id_by_marble_name.has(marble_name):
			continue
		if _find_marble_by_name(marble_name) == null:
			continue
		return marble_name
	return ""


func _get_online_player_index_from_snapshot(target_client_id: String) -> int:
	if target_client_id == "":
		return -1
	var players: Array = _get_online_human_players_snapshot()
	for index in range(players.size()):
		var player_data: Dictionary = players[index] as Dictionary
		if str(player_data.get("id", "")) == target_client_id:
			return index
	return -1


func _resolve_online_local_player_marble() -> Node3D:
	if online == null:
		return null
	var snapshot_index: int = _get_online_player_index_from_snapshot(online_local_client_id)
	var local_marble_name: String = _get_online_marble_name_for_player_index(snapshot_index)
	if local_marble_name == "" and online.has_method("get_assigned_marble_name"):
		local_marble_name = str(online.call("get_assigned_marble_name", online_local_client_id))
	if not lan_is_host and local_marble_name == "PlayerMarble":
		local_marble_name = ""
	if local_marble_name == "" and online.has_method("get_player_index"):
		var player_index: int = int(online.call("get_player_index", online_local_client_id))
		if player_index <= 0 and not lan_is_host:
			player_index = 1
		local_marble_name = _get_online_marble_name_for_player_index(player_index)
	if local_marble_name == "" and not lan_is_host:
		local_marble_name = "AI MARBLE1"
	return _find_marble_by_name(local_marble_name)


func _get_online_marble_name_for_player_index(player_index: int) -> String:
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


func _get_online_player_index_for_marble_name(marble_name: String) -> int:
	match marble_name:
		"PlayerMarble":
			return 0
		"AI MARBLE1":
			return 1
		"AI MARBLE2":
			return 2
		"AI MARBLE3":
			return 3
		"AI MARBLE4":
			return 4
		_:
			return -1


func _apply_local_online_marble_customization() -> void:
	if not online_enabled or lan_is_host or online_local_player_marble == null:
		return
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null or not customization.has_method("get_selected_palette"):
		return
	var visual: Node = online_local_player_marble.get_node_or_null("GlassBallModel")
	if visual != null and visual.has_method("set_palette"):
		visual.call("set_palette", customization.call("get_selected_palette"))


func _get_first_online_remote_player_marble() -> Node3D:
	for marble_name in online_client_id_by_marble_name.keys():
		var marble: Node3D = _find_marble_by_name(str(marble_name))
		if marble != null:
			return marble
	return null


func _configure_lan_client_bodies() -> void:
	for marble in active_marbles:
		var body: RigidBody3D = marble as RigidBody3D
		if body == null:
			continue
		_ensure_marble_collision_reporting(body)
		body.freeze = true
		body.sleeping = true
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO


func _lan_client_ready() -> void:
	online_client_sync_elapsed = 0.0
	online_client_sync_request_timer = 0.0
	online_client_received_turn_state = false
	lan_client_targets.clear()
	lan_client_state_buffers.clear()
	lan_client_remote_time_offset_ready = false
	lan_client_remote_time_offset = 0.0
	lan_client_remote_turn_input_enabled = false
	_stop_online_local_prediction()
	_update_lan_power_meter(0.0, false)
	if not online_enabled:
		_place_marbles_on_lineup(active_marbles)
	_configure_lan_client_bodies()
	var local_marble: Node3D = _get_lan_local_player_marble()
	if local_marble != null:
		_activate_camera_for_client(local_marble)
	lan_client_active_display_name = "Waiting for host"
	turn_changed.emit(lan_client_active_display_name, 0)
	_emit_scoreboard()
	if online_enabled:
		_apply_local_online_marble_customization()
		var customization_payload: Dictionary = _get_local_online_customization_payload()
		_send_online_game_message("player_customization", customization_payload)
		_send_online_game_message("client_scene_ready", customization_payload)
		_send_online_sync_request()
		call_deferred("_show_match_shooting_mechanic_guide")
		return
	var host_peer_id: int = _get_lan_host_peer_id()
	if host_peer_id > 0:
		_lan_client_scene_ready.rpc_id(host_peer_id)


func _process_online_client_sync_request(delta: float) -> void:
	if not online_enabled or lan_is_host or online_waiting_for_match_start:
		return
	if online_client_received_turn_state and lan_client_active_marble_name != "":
		return

	online_client_sync_elapsed += delta
	if online_client_sync_elapsed > ONLINE_CLIENT_SYNC_REQUEST_SECONDS:
		return

	online_client_sync_request_timer -= delta
	if online_client_sync_request_timer > 0.0:
		return

	online_client_sync_request_timer = ONLINE_CLIENT_SYNC_REQUEST_INTERVAL
	_send_online_sync_request()


func _send_online_sync_request() -> void:
	if not online_enabled or lan_is_host:
		return
	var payload: Dictionary = _get_local_online_customization_payload()
	var local_marble: Node3D = _get_lan_local_player_marble()
	if local_marble != null:
		payload["active_marble_name"] = String(local_marble.name)
	_send_online_game_message("sync_request", payload)


func _online_waiting_room_ready() -> void:
	_place_marbles_on_lineup(active_marbles)
	_configure_lan_client_bodies()
	var local_marble: Node3D = _get_lan_local_player_marble()
	if local_marble != null:
		_activate_camera_for_client(local_marble)
	var players_found: int = 0
	var capacity: int = 0
	if online != null and online.has_method("get_room"):
		var room_data: Dictionary = online.call("get_room")
		var players: Array = room_data.get("players", [])
		players_found = players.size()
		capacity = int(room_data.get("human_capacity", room_data.get("max_players", 2)))
	lan_client_active_display_name = "WAITING FOR PLAYERS %d/%d" % [players_found, capacity]
	turn_changed.emit(lan_client_active_display_name, 0)
	_emit_scoreboard()


func _on_online_match_started(_players: Array, _ai_count: int) -> void:
	if not online_enabled or not online_waiting_for_match_start:
		return
	online_waiting_for_match_start = false
	online_client_sync_elapsed = 0.0
	online_client_sync_request_timer = 0.0
	online_client_received_turn_state = false
	online_local_client_id = str(online.call("get_local_client_id")) if online != null and online.has_method("get_local_client_id") else online_local_client_id
	lan_is_host = bool(online.call("is_host")) if online != null and online.has_method("is_host") else false
	_build_online_player_assignments()
	_apply_online_active_marble_roster()
	if lan_is_host:
		lan_remote_player_marble = _get_first_online_remote_player_marble()
	else:
		online_local_player_marble = _resolve_online_local_player_marble()
		lan_remote_player_marble = online_local_player_marble
	lan_remote_player_connected = _has_online_remote_players() if lan_is_host else true
	_update_lan_remote_player_name()
	if lan_is_host:
		for marble in active_marbles:
			var body: RigidBody3D = marble as RigidBody3D
			if body != null:
				body.freeze = false
				body.sleeping = false
		call_deferred("_post_ready_init")
	else:
		_apply_local_online_marble_customization()
		call_deferred("_lan_client_ready")


func _activate_camera_for_client(marble: Node3D) -> void:
	_disable_all_cameras()
	var cam: Camera3D = _get_marble_camera(marble)
	if cam == null:
		return
	cam.current = true
	cam.make_current()


func _on_lan_peer_joined(_peer_id: int) -> void:
	lan_remote_player_connected = true
	_update_lan_remote_player_name()
	if lan_is_host:
		_emit_turn_state()
		_emit_scoreboard()
		_lan_send_marble_state_to_peer(_peer_id)


func _on_lan_peer_left(_peer_id: int) -> void:
	lan_remote_player_connected = false
	lan_remote_player_name = "Friend"


func _on_lan_player_names_changed() -> void:
	_update_lan_remote_player_name()


func _on_online_game_message(message_type: String, payload: Dictionary, sender_id: String, target_id: String) -> void:
	if not online_enabled:
		return
	if target_id != "" and target_id != online_local_client_id:
		return

	match message_type:
		"marble_states":
			_lan_receive_marble_states(payload.get("states", []), _online_payload_server_time_seconds(payload))
		"turn_state":
			online_client_received_turn_state = true
			_lan_receive_turn_state(
				str(payload.get("display_name", "Waiting")),
				int(payload.get("active_index", 0)),
				str(payload.get("active_marble_name", "")),
				int(payload.get("phase", GAME_PHASE_LINEUP))
			)
		"scoreboard":
			_lan_receive_scoreboard(payload.get("entries", []))
		"marble_eliminated":
			_receive_online_marble_eliminated(payload)
		"player_disqualified":
			_receive_online_player_disqualified(payload)
		"match_finished":
			_receive_online_match_finished(payload)
		"remote_turn_started":
			if not _online_remote_turn_message_is_for_local_client(payload, target_id):
				return
			online_client_received_turn_state = true
			var active_marble_name: String = str(payload.get("active_marble_name", ""))
			if active_marble_name != "":
				lan_client_active_marble_name = active_marble_name
				var active_marble: Node3D = _find_marble_by_name(active_marble_name)
				if active_marble != null:
					if not lan_is_host:
						online_local_player_marble = active_marble
					lan_remote_player_marble = active_marble
			var active_display_name: String = str(payload.get("display_name", "")).strip_edges()
			if active_display_name != "":
				lan_client_active_display_name = active_display_name
			var active_phase: int = int(payload.get("phase", game_phase))
			lan_client_game_phase = active_phase
			game_phase = active_phase
			_lan_remote_turn_started(int(payload.get("action_mode", ACTION_MODE_NONE)))
		"remote_player_aim":
			_receive_network_remote_player_aim(
				payload.get("aim", Vector3.ZERO),
				float(payload.get("force", 0.0)),
				bool(payload.get("aiming", false)),
				sender_id,
				str(payload.get("marble_name", ""))
			)
		"broadcast_remote_player_aim":
			var marble_name: String = str(payload.get("marble_name", ""))
			var marble: Node3D = _find_marble_by_name(marble_name)
			if online_enabled and not lan_is_host and marble != null and marble == _get_network_input_marble():
				return
			_apply_lan_remote_aim_preview(
				marble,
				payload.get("aim", Vector3.ZERO),
				float(payload.get("force", 0.0)),
				bool(payload.get("aiming", false))
			)
		"remote_player_shot":
			_receive_network_remote_player_shot(
				payload.get("aim", Vector3.ZERO),
				float(payload.get("force", 0.0)),
				sender_id,
				str(payload.get("marble_name", ""))
			)
		"player_customization":
			_receive_network_player_customization(payload, sender_id)
		"client_scene_ready":
			_receive_network_client_scene_ready(sender_id, payload)
		"sync_request":
			_receive_online_sync_request(sender_id, payload)
		_:
			pass


func _receive_online_match_finished(payload: Dictionary) -> void:
	if lan_is_host:
		return

	_clear_online_local_turn_input()
	game_phase = GAME_PHASE_FINISHED
	lan_client_game_phase = GAME_PHASE_FINISHED

	var winner_name: String = str(payload.get("winner_name", "")).strip_edges()
	var winner_marble_name: String = str(payload.get("winner_marble_name", "")).strip_edges()
	if winner_marble_name == "":
		for player in payload.get("players", []):
			if typeof(player) != TYPE_DICTIONARY:
				continue
			var player_data: Dictionary = player as Dictionary
			if bool(player_data.get("won", false)):
				winner_marble_name = str(player_data.get("marble_name", "")).strip_edges()
				break

	var winner_marble: Node3D = _find_marble_by_name(winner_marble_name)
	if winner_marble != null:
		_activate_camera_for_client(winner_marble)
		_spawn_victory_reward(winner_marble)

	game_finished.emit(winner_name)


func _receive_online_marble_eliminated(payload: Dictionary) -> void:
	if lan_is_host:
		return

	var target_name: String = str(payload.get("target_name", payload.get("player_name", ""))).strip_edges()
	var target_marble_name: String = str(payload.get("target_marble_name", "")).strip_edges()
	var target: Node3D = _find_marble_by_name(target_marble_name)
	if target != null:
		_remove_online_marble_from_local_match(target)
		_disable_marble(target)
	if target_name != "":
		marble_eliminated.emit(target_name)


func _receive_online_player_disqualified(payload: Dictionary) -> void:
	if lan_is_host:
		return

	var target_marble_name: String = str(payload.get("target_marble_name", "")).strip_edges()
	var target: Node3D = _find_marble_by_name(target_marble_name)
	if target == null:
		target = _get_network_input_marble()
	if target != null:
		_remove_online_marble_from_local_match(target)
		_disable_marble(target)
		if target == online_local_player_marble:
			online_local_player_marble = null

	_clear_online_local_turn_input()
	var watch_marble: Node3D = _get_current_turn_marble()
	if watch_marble == null and not active_marbles.is_empty():
		watch_marble = active_marbles[0]
	if watch_marble != null:
		_activate_camera_for_client(watch_marble)

	var attacker_name: String = str(payload.get("attacker_name", "Another player")).strip_edges()
	if attacker_name == "":
		attacker_name = "Another player"
	player_disqualified.emit(attacker_name)


func _remove_online_marble_from_local_match(marble: Node3D) -> void:
	if marble == null:
		return

	var removed_index: int = turn_order.find(marble)
	if removed_index != -1:
		turn_order.remove_at(removed_index)
		if removed_index < current_marble_index:
			current_marble_index -= 1
		elif current_marble_index >= turn_order.size():
			current_marble_index = 0

	active_marbles.erase(marble)
	marbles.erase(marble)
	ai_hole_attack_attempts.erase(marble.name)
	if current_hole_owner == marble:
		current_hole_owner = null
	if pending_hole_turn_marble == marble:
		pending_hole_turn_marble = null


func _clear_online_local_turn_input() -> void:
	var input_marble: Node3D = _get_network_input_marble()
	if input_marble != null:
		_apply_lan_remote_aim_preview(input_marble, Vector3.ZERO, 0.0, false)
	lan_client_remote_turn_input_enabled = false
	lan_dragging = false
	lan_drag_touch_index = -1
	lan_drag_aim = Vector3.ZERO
	lan_drag_force = 0.0
	lan_drag_power_ratio = 0.0
	lan_drag_smoothed_vector = Vector2.ZERO
	lan_drag_has_smoothed_vector = false
	_stop_online_local_prediction()
	_update_lan_power_meter(0.0, false)


func _update_lan_remote_player_name() -> void:
	if online_enabled and online != null:
		var client_id: String = ""
		if lan_remote_player_marble != null:
			client_id = str(online_client_id_by_marble_name.get(String(lan_remote_player_marble.name), ""))
			if client_id == "" and String(lan_remote_player_marble.name) == str(online_marble_name_by_client_id.get(online_local_client_id, "")):
				client_id = online_local_client_id
		var stored_name: String = str(online_display_name_by_client_id.get(client_id, "")).strip_edges()
		if stored_name != "":
			lan_remote_player_name = stored_name
			return
		if client_id != "" and online.has_method("get_player_name_by_id"):
			lan_remote_player_name = str(online.call("get_player_name_by_id", client_id))
		return
	if lan != null and lan.has_method("get_client_player_name"):
		lan_remote_player_name = str(lan.call("get_client_player_name"))


func _wait_for_online_remote_players_ready() -> void:
	var elapsed: float = 0.0
	while is_inside_tree() and elapsed < ONLINE_REMOTE_READY_WAIT_SECONDS:
		_build_online_player_assignments()
		if not _has_online_remote_players():
			if elapsed >= ONLINE_REMOTE_DISCOVERY_GRACE_SECONDS:
				return
			if not await _await_next_frame():
				return
			elapsed += get_process_delta_time()
			continue

		var all_ready: bool = true
		for client_id_variant in online_marble_name_by_client_id.keys():
			var client_id: String = str(client_id_variant)
			if client_id == "" or client_id == online_local_client_id:
				continue
			if not online_ready_client_ids.has(client_id):
				all_ready = false
				break

		if all_ready:
			lan_remote_player_connected = true
			return

		if not await _await_next_frame():
			return
		elapsed += get_process_delta_time()

	lan_remote_player_connected = _has_online_remote_players()


func _get_local_online_customization_payload() -> Dictionary:
	var payload: Dictionary = {}
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null:
		return payload

	payload["client_id"] = online_local_client_id
	var player_name: String = ""
	if customization.has_method("get_player_name"):
		player_name = str(customization.call("get_player_name")).strip_edges()
	if player_name != "":
		payload["player_name"] = player_name
	if customization.has_method("get_player_login_id"):
		var login_id: String = str(customization.call("get_player_login_id")).strip_edges()
		if login_id != "":
			payload["login_id"] = login_id

	var marble_id: String = str(customization.get("selected_marble_id")).strip_edges()
	if marble_id != "":
		payload["marble_id"] = marble_id
	var trail_id: String = str(customization.get("selected_trail_id")).strip_edges()
	if trail_id != "":
		payload["trail_id"] = trail_id
	return payload


func _send_online_local_customization(target_id: String = "") -> void:
	if not online_enabled:
		return
	var payload: Dictionary = _get_local_online_customization_payload()
	if payload.is_empty():
		return
	_send_online_game_message("player_customization", payload, target_id)


func _receive_network_player_customization(payload: Dictionary, sender_key: String) -> void:
	if not online_enabled or sender_key == "":
		return
	if sender_key == online_local_client_id:
		return
	var player_name: String = str(payload.get("player_name", "")).strip_edges()
	if player_name != "":
		online_display_name_by_client_id[sender_key] = player_name

	var marble: Node3D = _get_or_assign_online_player_marble(sender_key)
	if marble == null:
		return
	_apply_online_customization_payload_to_marble(marble, payload)


func _apply_online_customization_payload_to_marble(marble: Node3D, payload: Dictionary) -> void:
	if marble == null:
		return
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null:
		return

	var marble_id: String = str(payload.get("marble_id", "")).strip_edges()
	if marble_id != "" and customization.has_method("get_marble_preset"):
		var preset: Dictionary = customization.call("get_marble_preset", marble_id)
		var palette: Dictionary = preset.get("palette", {})
		var visual: Node = marble.get_node_or_null("GlassBallModel")
		if visual != null and visual.has_method("set_palette") and not palette.is_empty():
			visual.call("set_palette", palette)

	var trail_id: String = str(payload.get("trail_id", "")).strip_edges()
	if trail_id != "" and customization.has_method("get_trail_preset"):
		var trail_preset: Dictionary = customization.call("get_trail_preset", trail_id)
		if not trail_preset.is_empty():
			online_remote_trail_presets_by_marble_name[String(marble.name)] = trail_preset
			_clear_trail_for_marble(marble)


func _show_match_shooting_mechanic_guide() -> void:
	if match_mechanic_guide_shown or not is_inside_tree():
		return
	match_mechanic_guide_shown = true

	var texture: Texture2D = _load_match_shooting_mechanic_texture()
	if texture == null:
		return

	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "ShootingMechanicGuideLayer"
	layer.layer = 1000
	add_child(layer)

	var blocker: Control = Control.new()
	blocker.name = "ShootingMechanicGuide"
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(blocker)

	var backdrop: ColorRect = ColorRect.new()
	backdrop.name = "GuideBackdrop"
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.92)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blocker.add_child(backdrop)

	var image: TextureRect = TextureRect.new()
	image.name = "GuideImage"
	image.set_anchors_preset(Control.PRESET_FULL_RECT)
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blocker.add_child(image)

	await _wait_seconds(MATCH_MECHANIC_GUIDE_SECONDS)
	if layer != null and is_instance_valid(layer):
		layer.queue_free()


func _load_match_shooting_mechanic_texture() -> Texture2D:
	var texture_path: String = _get_match_shooting_mechanic_image_path()
	if ResourceLoader.exists(texture_path):
		var resource: Resource = ResourceLoader.load(texture_path)
		if resource is Texture2D:
			return resource as Texture2D
	return null


func _get_match_shooting_mechanic_image_path() -> String:
	var mechanic_id: String = "drag"
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shooting_mechanic"):
		mechanic_id = str(customization.call("get_shooting_mechanic"))
	match mechanic_id:
		"split":
			return SHOOTING_MECHANIC_SPLIT_IMAGE_PATH
		"press":
			return SHOOTING_MECHANIC_HOLD_IMAGE_PATH
		_:
			return SHOOTING_MECHANIC_DRAG_IMAGE_PATH


func _post_ready_init() -> void:
	if not await _await_next_frame():
		return
	if not await _await_next_frame():
		return

	if online_enabled and lan_is_host:
		_send_online_local_customization()
		await _wait_for_online_remote_players_ready()

	await _show_match_shooting_mechanic_guide()
	_force_start_camera()
	_emit_turn_state(active_marbles[0] if not active_marbles.is_empty() else null)
	_emit_scoreboard()

	if not _game_loop_started:
		_game_loop_started = true
		call_deferred("_run_game_loop")


func _run_game_loop() -> void:
	await _run_lineup_phase()
	if active_marbles.size() <= 1:
		await _finish_game()
		return

	game_phase = GAME_PHASE_MATCH
	lineup_starter_decided = true
	current_marble_index = 0
	_emit_turn_state()

	while is_inside_tree() and active_marbles.size() > 1:
		var marble: Node3D = _get_current_turn_marble()
		if marble == null:
			break

		await _play_match_turn(marble)
		if active_marbles.size() <= 1:
			break

		_advance_turn_order()
		if turn_delay > 0.0:
			await _wait_seconds(turn_delay)

	await _finish_game()


func _run_lineup_phase() -> void:
	game_phase = GAME_PHASE_LINEUP
	lineup_starter_decided = false
	current_actor = null
	current_action_mode = ACTION_MODE_NONE
	current_hole_owner = null
	pending_hole_turn_marble = null
	hole_entry_order_this_shot.clear()
	lineup_hole_entrants_this_round.clear()
	turn_order = active_marbles.duplicate()
	current_marble_index = 0
	_place_marbles_on_lineup(turn_order)
	await _play_lineup_round(turn_order)

	var first_marble: Node3D = await _resolve_lineup_starter(active_marbles)
	first_marble = await _resolve_remaining_lineup_hole_ties(first_marble)
	lineup_starter_decided = first_marble != null
	_settle_lineup_hole_owner(first_marble)
	pending_hole_turn_marble = null

	turn_order = active_marbles.duplicate()
	turn_order.sort_custom(Callable(self , "_sort_marbles_by_lineup_distance"))
	if first_marble != null and turn_order.has(first_marble):
		turn_order.erase(first_marble)
		turn_order.push_front(first_marble)

	current_marble_index = 0


func _play_lineup_round(shooters: Array[Node3D]) -> void:
	var lineup_shooters: Array[Node3D] = _filter_active_lineup_contenders(shooters)
	lineup_hole_entrants_this_round.clear()
	var shooter_index: int = 0
	for marble in lineup_shooters:
		if not active_marbles.has(marble):
			continue

		_lock_non_lineup_controls(marble)
		var turn_order_index: int = turn_order.find(marble)
		current_marble_index = turn_order_index if turn_order_index >= 0 else shooter_index
		_reset_marble_motion(marble, _get_lineup_position(lineup_shooters, shooter_index))
		_emit_turn_state(marble)
		await _activate_camera_for(marble)
		await _perform_action_shot(marble, ACTION_MODE_LINEUP)
		shooter_index += 1

		if turn_delay > 0.0:
			await _wait_seconds(turn_delay)

	_lock_non_lineup_controls(null)


func _lock_non_lineup_controls(allowed_marble: Node3D) -> void:
	for marble in active_marbles:
		if marble == null or marble == allowed_marble:
			continue
		if marble.has_method("set_turn"):
			marble.call("set_turn", false, self)
		elif marble.has_method("end_turn"):
			marble.call("end_turn")
		if marble.has_method("end_aim_preview"):
			marble.call("end_aim_preview")
	if allowed_marble == null:
		lan_client_remote_turn_input_enabled = false


func _resolve_lineup_starter(candidates: Array, require_single_hole_entry: bool = false) -> Node3D:
	var contenders: Array[Node3D] = _filter_active_lineup_contenders(candidates)
	while contenders.size() > 1:
		var result := _get_lineup_result(contenders, require_single_hole_entry)
		var winner: Node3D = result.get("winner", null) as Node3D
		if winner != null:
			return winner

		contenders = _filter_active_lineup_contenders(result.get("retry", []) as Array)
		if contenders.size() > 1:
			var hole_tie: bool = bool(result.get("hole_tie", false))
			var no_hole_entry: bool = bool(result.get("no_hole_entry", false))
			if hole_tie:
				require_single_hole_entry = true
			current_hole_owner = null
			pending_hole_turn_marble = null
			_place_marbles_on_lineup(contenders)
			await _play_lineup_round(contenders)

	return contenders[0] if not contenders.is_empty() else null


func _resolve_remaining_lineup_hole_ties(first_marble: Node3D) -> Node3D:
	var resolved_marble: Node3D = first_marble
	var tied_entrants: Array[Node3D] = _collect_lineup_hole_entrants(active_marbles)
	while tied_entrants.size() > 1:
		current_hole_owner = null
		pending_hole_turn_marble = null
		_place_marbles_on_lineup(tied_entrants)
		await _play_lineup_round(tied_entrants)
		resolved_marble = await _resolve_lineup_starter(tied_entrants, true)
		tied_entrants = _collect_lineup_hole_entrants(tied_entrants)
	return resolved_marble


func _get_lineup_result(candidates: Array, require_single_hole_entry: bool = false) -> Dictionary:
	var contenders: Array[Node3D] = _filter_active_lineup_contenders(candidates)
	if contenders.size() <= 1:
		return {"winner": contenders[0] if not contenders.is_empty() else null, "retry": []}

	var hole_entrants: Array[Node3D] = _collect_lineup_hole_entrants(contenders)
	if hole_entrants.size() == 1:
		return {"winner": hole_entrants[0], "retry": []}
	if hole_entrants.size() > 1:
		return {"winner": null, "retry": hole_entrants, "hole_tie": true}
	if require_single_hole_entry:
		return {"winner": null, "retry": contenders, "no_hole_entry": true}

	var closest: Array[Node3D] = _collect_closest_lineup_marbles(contenders)
	if closest.size() == 1:
		return {"winner": closest[0], "retry": []}
	return {"winner": null, "retry": closest}


func _settle_lineup_hole_owner(first_marble: Node3D) -> void:
	current_hole_owner = null
	if first_marble != null and _is_marble_in_hole(first_marble):
		current_hole_owner = first_marble
		_enforce_single_hole_occupant(first_marble)
		return

	var in_hole: Array[Node3D] = _collect_in_hole_marbles(active_marbles)
	if in_hole.is_empty():
		return

	current_hole_owner = in_hole[0]
	_enforce_single_hole_occupant(current_hole_owner)


func _filter_active_lineup_contenders(candidates: Array) -> Array[Node3D]:
	var contenders: Array[Node3D] = []
	for candidate in candidates:
		var marble := candidate as Node3D
		if marble != null and active_marbles.has(marble) and not contenders.has(marble):
			contenders.append(marble)
	return contenders


func _collect_closest_lineup_marbles(candidates: Array) -> Array[Node3D]:
	var closest: Array[Node3D] = []
	var best_distance: float = INF
	for candidate in candidates:
		var marble := candidate as Node3D
		if marble == null:
			continue

		var distance: float = _distance_to_hole(marble)
		if distance + LINEUP_DISTANCE_TIE_EPSILON < best_distance:
			best_distance = distance
			closest = [marble]
		elif absf(distance - best_distance) <= LINEUP_DISTANCE_TIE_EPSILON:
			closest.append(marble)
	return closest


func _play_match_turn(marble: Node3D) -> void:
	if not active_marbles.has(marble):
		return

	_clear_stored_approach_victim(marble)
	var active_hole_owner: Node3D = _enforce_single_hole_occupant(marble if _is_marble_in_hole(marble) else current_hole_owner)
	if active_hole_owner != null and active_hole_owner != marble:
		pending_hole_turn_marble = active_hole_owner
		return
	await _activate_camera_for(marble)

	while active_marbles.has(marble) and active_marbles.size() > 1:
		_emit_turn_state(marble)
		var action_mode: int = ACTION_MODE_ATTACK if _is_marble_in_hole(marble) else ACTION_MODE_APPROACH
		var result: Dictionary = await _perform_action_shot(marble, action_mode)
		if not active_marbles.has(marble):
			_clear_stored_approach_victim(marble)
			return

		var success: bool = bool(result.get("success", false))
		if success:
			if action_mode == ACTION_MODE_APPROACH:
				if bool(result.get("eliminated", false)):
					pass
				elif bool(result.get("entered_hole", false)):
					pass
				else:
					retry_awarded.emit(_display_name_for_marble(marble))
			else:
				if bool(result.get("eliminated", false)) or result.has("victim_name"):
					pass
				elif bool(result.get("kept_turn_in_hole", false)):
					pass
			if marble == player_marble:
				_prepare_marble_for_instant_retry(marble)
			if turn_delay > 0.0:
				await _wait_seconds(turn_delay)
			continue

		_clear_stored_approach_victim(marble)
		return

	_clear_stored_approach_victim(marble)


func _perform_action_shot(marble: Node3D, action_mode: int) -> Dictionary:
	current_actor = marble
	current_action_mode = action_mode
	pending_approach_victim = null
	pending_attack_victim = null
	current_shot_entered_hole = false
	current_shot_started_in_hole = marble != null and _is_marble_in_hole(marble)
	current_shot_left_hole = false
	hole_entry_order_this_shot.clear()
	var leveled_hole_for_attack: bool = action_mode == ACTION_MODE_ATTACK and current_shot_started_in_hole
	if leveled_hole_for_attack:
		_begin_hole_attack_level(marble)

	if marble != null and marble != player_marble:
		if action_mode == ACTION_MODE_ATTACK:
			ai_hole_attack_attempts[marble.name] = int(ai_hole_attack_attempts.get(marble.name, 0)) + 1
		else:
			ai_hole_attack_attempts[marble.name] = 0

	if marble == player_marble:
		await _perform_player_shot(marble, action_mode)
	elif lan_enabled and lan_is_host and _is_network_remote_player_marble(marble):
		await _perform_lan_remote_player_shot(marble, action_mode)
	else:
		await _perform_ai_shot(marble, action_mode)

	_track_current_actor_hole_entry()
	if leveled_hole_for_attack:
		_end_hole_attack_level()
	current_actor = null
	current_action_mode = ACTION_MODE_NONE

	if not active_marbles.has(marble):
		return {"success": false}

	var preferred_hole_owner: Node3D = marble if _is_marble_in_hole(marble) else null
	var shot_hole_owner: Node3D = _enforce_single_hole_occupant(preferred_hole_owner)
	if shot_hole_owner == marble:
		pending_hole_turn_marble = null
	elif shot_hole_owner != null:
		pending_hole_turn_marble = shot_hole_owner

	match action_mode:
		ACTION_MODE_LINEUP:
			return {
				"success": _is_marble_in_hole(marble),
				"distance": _distance_to_hole(marble)
			}
		ACTION_MODE_APPROACH:
			var ended_in_hole: bool = _is_marble_in_hole(marble)
			if ended_in_hole:
				current_shot_entered_hole = true
			var entered_hole_this_shot: bool = current_shot_entered_hole
			var stored_victim: Node3D = _get_stored_approach_victim(marble)
			var victim_hit_this_shot: Node3D = pending_approach_victim if pending_approach_victim != null and active_marbles.has(pending_approach_victim) else null
			if entered_hole_this_shot and victim_hit_this_shot != null:
				var combo_victim_name: String = _display_name_for_marble(victim_hit_this_shot)
				_clear_stored_approach_victim(marble)
				_eliminate_marble(victim_hit_this_shot, marble)
				return {
					"success": true,
					"entered_hole": true,
					"eliminated": true,
					"victim_name": combo_victim_name
				}
			if entered_hole_this_shot and stored_victim != null:
				var entry_victim_name: String = _display_name_for_marble(stored_victim)
				_clear_stored_approach_victim(marble)
				_eliminate_marble(stored_victim, marble)
				return {
					"success": true,
					"entered_hole": true,
					"eliminated": true,
					"victim_name": entry_victim_name
				}
			if victim_hit_this_shot != null and not ended_in_hole:
				stored_approach_owner = marble
				stored_approach_victim = victim_hit_this_shot
				return {
					"success": true,
					"entered_hole": false,
					"earned_retry": true,
					"eliminated": false
				}
			if stored_victim != null:
				_clear_stored_approach_victim(marble)
			var approach_entered_hole: bool = entered_hole_this_shot or ended_in_hole
			return {
				"success": approach_entered_hole,
				"entered_hole": approach_entered_hole,
				"earned_retry": false,
				"eliminated": false
			}
		ACTION_MODE_ATTACK:
			var victim: Node3D = _get_successful_attack_victim(marble)
			if victim != null and active_marbles.has(victim):
				var victim_name: String = _display_name_for_marble(victim)
				_eliminate_marble(victim, marble)
				return {"success": true, "victim_name": victim_name}
			var attack_ended_in_hole: bool = _is_marble_in_hole(marble)
			if attack_ended_in_hole:
				current_hole_owner = marble
				return {"success": true, "entered_hole": true, "kept_turn_in_hole": true}
			if current_hole_owner == marble:
				current_hole_owner = null
			return {"success": false}

	return {"success": false}


func _perform_player_shot(marble: Node3D, action_mode: int) -> void:
	player_has_shot = false

	if marble.has_method("start_turn"):
		marble.start_turn(self )
	elif marble.has_method("set_turn"):
		marble.set_turn(true, self )

	await _wait_for_real_player_shot(action_mode)

	if marble.has_method("end_turn"):
		marble.end_turn()
	elif marble.has_method("set_turn"):
		marble.set_turn(false, self )


func _perform_lan_remote_player_shot(marble: Node3D, action_mode: int) -> void:
	lan_waiting_remote_player_shot = true
	lan_remote_player_shot_ready = false
	lan_remote_player_shot_data = {}
	lan_remote_player_marble = marble
	if online_enabled:
		var target_client_id: String = _get_online_client_id_for_marble(marble)
		_send_online_game_message("remote_turn_started", {
			"action_mode": action_mode,
			"active_marble_name": String(marble.name),
			"client_id": target_client_id,
			"target_client_id": target_client_id,
			"display_name": _turn_display_name_for_marble(marble),
			"phase": game_phase
		}, target_client_id)
	else:
		var remote_peer_id: int = _get_lan_remote_peer_id()
		if remote_peer_id > 0:
			_lan_remote_turn_started.rpc_id(remote_peer_id, action_mode)

	var elapsed: float = 0.0
	var warning_elapsed: float = 0.0
	var warned: bool = false
	var timed_out: bool = false
	while lan_waiting_remote_player_shot and not lan_remote_player_shot_ready:
		if not await _await_next_frame():
			lan_waiting_remote_player_shot = false
			return
		var delta: float = get_process_delta_time()
		elapsed += delta
		warning_elapsed += delta

		if warning_elapsed >= idle_player_warning_time and not warned:
			warned = true
		elif warned and warning_elapsed >= idle_player_warning_time + 5.0:
			warning_elapsed = idle_player_warning_time
			warned = false

		if not online_enabled and elapsed >= max_turn_time:
			timed_out = true
			break

	lan_waiting_remote_player_shot = false
	if lan_remote_player_shot_ready:
		var aim: Vector3 = lan_remote_player_shot_data.get("aim", Vector3.FORWARD)
		var force: float = float(lan_remote_player_shot_data.get("force", 1.5))
		_apply_lan_remote_aim_preview(marble, aim, force, false)
		if marble.has_method("shoot"):
			marble.call("shoot", aim, force)
			_register_shot(marble)
			_send_online_authoritative_snapshot_now()
	else:
		if timed_out:
			push_warning("LAN player %s did not shoot before the turn timer ended. Using AI fallback." % _display_name_for_marble(marble))
		elif online_enabled:
			_apply_lan_remote_aim_preview(marble, Vector3.ZERO, 0.0, false)
			push_warning("Online turn for %s ended before a shot arrived." % _display_name_for_marble(marble))
			return
		await _perform_ai_shot(marble, action_mode)
		return

	await _wait_for_all_marbles_to_stop()


func _perform_ai_shot(marble: Node3D, action_mode: int) -> void:
	var strategy: Dictionary = _choose_ai_strategy_for_mode(marble, action_mode)
	if marble.has_method("begin_aim_preview"):
		marble.begin_aim_preview(strategy)
		if ai_aim_preview_time > 0.0:
			await _wait_seconds(ai_aim_preview_time)

	if marble.has_method("shoot"):
		marble.shoot(strategy.get("aim", Vector3.FORWARD), strategy.get("force", 1.5))
		_register_shot(marble)

	if marble.has_method("end_aim_preview"):
		marble.end_aim_preview()

	await _wait_for_all_marbles_to_stop()


func _choose_ai_strategy_for_mode(marble: Node3D, action_mode: int) -> Dictionary:
	if action_mode == ACTION_MODE_ATTACK:
		return _choose_ai_attack_strategy(marble)
	return _choose_ai_goal_strategy(marble, action_mode)


func _choose_ai_goal_strategy(marble: Node3D, action_mode: int) -> Dictionary:
	var best_goal: Dictionary = _build_ai_goal_candidate(marble, action_mode)
	var profile: Dictionary = _get_ai_profile(marble)
	if action_mode != ACTION_MODE_LINEUP:
		for target in active_marbles:
			if target == null or target == marble:
				continue

			var combo_candidate: Dictionary = _build_ai_touch_then_hole_candidate(marble, target)
			if combo_candidate.is_empty():
				continue
			var combo_score: float = float(combo_candidate.get("score", -INF)) + randf_range(-0.08, 0.08) * float(profile.get("creativity", 1.0))
			var goal_score: float = float(best_goal.get("score", -INF)) + randf_range(-0.05, 0.05)
			if best_goal.is_empty() or combo_score > goal_score:
				best_goal = combo_candidate

	var context: String = "lineup" if action_mode == ACTION_MODE_LINEUP else "goal"
	var selected_force: float = _apply_ai_force_personality(marble, float(best_goal.get("force", 1.5)), context)
	var selected_aim: Vector3 = best_goal.get("aim", Vector3.FORWARD)
	var jittered_aim: Vector3 = _apply_ai_aim_jitter(selected_aim, context, marble)
	return {"force": selected_force, "aim": jittered_aim}


func _choose_ai_attack_strategy(marble: Node3D) -> Dictionary:
	var best_attack: Dictionary = {}
	for target in active_marbles:
		if target == null or target == marble:
			continue

		var attack_candidate: Dictionary = _build_ai_attack_candidate(marble, target)
		if best_attack.is_empty() or float(attack_candidate.get("score", -INF)) > float(best_attack.get("score", -INF)):
			best_attack = attack_candidate

	if best_attack.is_empty():
		return {"force": 1.5, "aim": Vector3.FORWARD}

	var selected_force: float = _scale_force_for_marble(
		marble,
		_apply_ai_force_personality(marble, float(best_attack.get("force", 1.5)), "attack"),
		_get_ai_hole_exit_multiplier(marble)
	)
	selected_force = _ensure_ai_hole_exit_force(marble, selected_force)
	var selected_aim: Vector3 = best_attack.get("aim", Vector3.FORWARD)
	var jittered_aim: Vector3 = _apply_ai_aim_jitter(selected_aim, "attack", marble)
	return {"force": selected_force, "aim": jittered_aim}


func _build_ai_goal_candidate(marble: Node3D, action_mode: int = ACTION_MODE_APPROACH) -> Dictionary:
	var target_position: Vector3 = hole.global_position if hole != null else marble.global_position + Vector3.FORWARD
	var distance: float = _planar_distance(marble.global_position, target_position)
	var aim: Vector3 = _planar_direction_to(marble.global_position, target_position)
	var line_penalty: float = _line_crowding_penalty(marble, target_position, hole)
	var context: String = "lineup" if action_mode == ACTION_MODE_LINEUP else "approach"
	var force: float = _estimate_ai_force_for_distance(marble, distance, false, context, line_penalty)
	var score: float = ai_goal_base_score - distance * ai_goal_distance_weight - line_penalty

	if distance < 6.0:
		score += 0.28
	elif distance < 10.0:
		score += 0.12

	return {
		"type": "goal",
		"target_name": "Hole",
		"aim": aim,
		"force": force,
		"distance": distance,
		"score": score
	}


func _build_ai_touch_then_hole_candidate(marble: Node3D, target: Node3D) -> Dictionary:
	if marble == null or target == null or hole == null:
		return {}

	var marble_2d: Vector2 = Vector2(marble.global_position.x, marble.global_position.z)
	var target_2d: Vector2 = Vector2(target.global_position.x, target.global_position.z)
	var hole_2d: Vector2 = Vector2(hole.global_position.x, hole.global_position.z)
	var hole_path: Vector2 = hole_2d - marble_2d
	if hole_path.length_squared() <= 0.0001:
		return {}

	var target_vector: Vector2 = target_2d - marble_2d
	var progression: float = target_vector.dot(hole_path.normalized())
	if progression <= 0.0:
		return {}

	var line_offset: float = _distance_point_to_segment_2d(target_2d, marble_2d, hole_2d)
	var alignment_ratio: float = clampf(1.0 - line_offset / maxf(ai_touch_then_hole_alignment_tolerance, 0.001), 0.0, 1.0)
	var distance_to_target: float = target_vector.length()
	var target_hole_distance: float = target_2d.distance_to(hole_2d)
	var direct_hole_distance: float = hole_path.length()

	var aim_point: Vector3 = target.global_position + _planar_direction_to(target.global_position, hole.global_position) * clampf(target_hole_distance * 0.08, 0.14, 0.46)
	var aim: Vector3 = _planar_direction_to(marble.global_position, aim_point)
	var effective_distance: float = distance_to_target + target_hole_distance * 0.42
	var line_penalty: float = _line_crowding_penalty(marble, target.global_position, target)
	var force: float = _estimate_ai_force_for_distance(marble, effective_distance, false, "combo", line_penalty)
	var score: float = ai_goal_base_score + ai_touch_then_hole_bonus - distance_to_target * ai_goal_distance_weight * 0.55 - target_hole_distance * ai_touch_then_hole_hole_weight - line_penalty

	score += alignment_ratio * 0.42
	score += clampf(progression / maxf(direct_hole_distance, 0.001), 0.0, 1.0) * 0.22
	if target == player_marble:
		score += 0.12
	if target_hole_distance < 5.0:
		score += 0.24
	if line_offset > ai_touch_then_hole_alignment_tolerance * 1.4:
		score -= 0.4

	return {
		"type": "touch_then_hole",
		"target_name": target.name,
		"aim": aim,
		"force": force,
		"distance": effective_distance,
		"score": score
	}


func _build_ai_attack_candidate(marble: Node3D, target: Node3D) -> Dictionary:
	var target_position: Vector3 = target.global_position
	var distance: float = _planar_distance(marble.global_position, target_position)
	var aim: Vector3 = _planar_direction_to(marble.global_position, target_position)
	var target_hole_distance: float = _distance_to_hole(target)
	var line_penalty: float = _line_crowding_penalty(marble, target_position, target)
	var force: float = _estimate_ai_force_for_distance(marble, distance, true, "attack", line_penalty)
	var distance_preference: float = absf(distance - ai_preferred_attack_distance) * 0.02
	var score: float = ai_attack_base_score - distance * ai_attack_distance_weight - distance_preference - line_penalty
	var exit_alignment: float = _estimate_attack_exit_alignment(marble, aim)

	if target == player_marble:
		score += 0.14
	if distance < 4.0:
		score += 0.18
	elif distance < 7.0:
		score += 0.08
	if target_hole_distance < 4.5:
		score += 0.08
	score += exit_alignment * ai_attack_escape_alignment_weight
	if line_penalty <= 0.05:
		score += ai_attack_clear_lane_bonus

	return {
		"type": "attack",
		"target_name": target.name,
		"target_is_player": target == player_marble,
		"aim": aim,
		"force": force,
		"distance": distance,
		"target_hole_distance": target_hole_distance,
		"exit_alignment": exit_alignment,
		"score": score
	}


func _estimate_ai_force_for_distance(marble: Node3D, distance: float, for_attack: bool, shot_context: String = "approach", line_penalty: float = 0.0) -> float:
	if marble == null:
		return 1.5

	var min_force: float = float(marble.get("min_force_value")) if marble.get("min_force_value") != null else 0.8
	var max_force: float = float(marble.get("max_force_value")) if marble.get("max_force_value") != null else 3.5
	var min_impulse: float = float(marble.get("min_shot_impulse")) if marble.get("min_shot_impulse") != null else 0.08
	var max_impulse: float = float(marble.get("max_shot_impulse")) if marble.get("max_shot_impulse") != null else 10.8
	var exponent: float = float(marble.get("power_response_exponent")) if marble.get("power_response_exponent") != null else 2.35
	var desired_impulse: float = _estimate_ai_desired_impulse(marble, distance, for_attack, shot_context, line_penalty)
	desired_impulse = clampf(desired_impulse, min_impulse, max_impulse)
	if max_impulse <= min_impulse:
		return max_force

	var effective_ratio: float = clampf(inverse_lerp(min_impulse, max_impulse, desired_impulse), 0.0, 1.0)
	var force_ratio: float = pow(effective_ratio, 1.0 / maxf(exponent, 0.01))
	return clampf(lerpf(min_force, max_force, force_ratio), min_force, max_force)


func _estimate_ai_desired_impulse(marble: Node3D, distance: float, for_attack: bool, shot_context: String, line_penalty: float) -> float:
	var clean_distance: float = maxf(distance, 0.0)
	var distance_ratio: float = clampf(clean_distance / 13.5, 0.0, 1.0)
	var root_distance: float = sqrt(clean_distance)
	var desired_impulse: float = 0.0

	match shot_context:
		"lineup":
			desired_impulse = ai_goal_impulse_bias + clean_distance * (ai_goal_impulse_per_meter * 0.94) + root_distance * 0.16
			desired_impulse *= lerpf(0.92, 1.04, distance_ratio)
		"approach":
			desired_impulse = ai_goal_impulse_bias + clean_distance * (ai_goal_impulse_per_meter * 0.96) + root_distance * 0.14
			desired_impulse *= lerpf(0.86, 1.08, distance_ratio)
			if clean_distance < 3.2:
				desired_impulse *= lerpf(0.82, 1.0, clean_distance / 3.2)
		"combo":
			desired_impulse = ai_goal_impulse_bias + clean_distance * (ai_goal_impulse_per_meter * 0.9) + root_distance * 0.22
			desired_impulse *= lerpf(0.96, 1.14, clampf(clean_distance / 15.0, 0.0, 1.0))
		"attack":
			desired_impulse = ai_attack_impulse_bias + clean_distance * (ai_attack_impulse_per_meter * 0.92) + root_distance * 0.16
			desired_impulse *= lerpf(0.82, 1.12, clampf(clean_distance / 10.5, 0.0, 1.0))
			if clean_distance < 2.8:
				desired_impulse *= lerpf(0.72, 0.94, clean_distance / 2.8)
		_:
			desired_impulse = ai_attack_impulse_bias + clean_distance * ai_attack_impulse_per_meter if for_attack else ai_goal_impulse_bias + clean_distance * ai_goal_impulse_per_meter

	if for_attack or shot_context == "combo":
		var contact_floor: float = lerpf(1.08, 2.65, clampf(clean_distance / 4.4, 0.0, 1.0))
		desired_impulse = maxf(desired_impulse, contact_floor)
	else:
		var entry_radius: float = float(hole.get("entry_radius")) if hole != null and hole.get("entry_radius") != null else 1.5
		var capture_floor: float = lerpf(1.32, 2.85, clampf(clean_distance / maxf(entry_radius * 2.6, 1.0), 0.0, 1.0))
		desired_impulse = maxf(desired_impulse, capture_floor)

	if line_penalty > 0.12:
		var penalty_ratio: float = clampf(line_penalty / 0.55, 0.0, 1.0)
		if for_attack:
			desired_impulse *= lerpf(1.0, 1.08, penalty_ratio)
		else:
			desired_impulse *= lerpf(0.96, 0.88, penalty_ratio)

	if _is_marble_in_hole(marble):
		var depth_ratio: float = _get_marble_hole_depth_ratio(marble)
		desired_impulse = desired_impulse * lerpf(1.12, 1.32, depth_ratio) + lerpf(0.42, 0.95, depth_ratio)

	return desired_impulse


func _line_crowding_penalty(marble: Node3D, target_position: Vector3, ignored_target: Node3D = null) -> float:
	var total_penalty: float = 0.0
	var origin_2d: Vector2 = Vector2(marble.global_position.x, marble.global_position.z)
	var target_2d: Vector2 = Vector2(target_position.x, target_position.z)

	for other in active_marbles:
		if other == null or other == marble or other == ignored_target:
			continue

		var other_2d: Vector2 = Vector2(other.global_position.x, other.global_position.z)
		var distance_to_line: float = _distance_point_to_segment_2d(other_2d, origin_2d, target_2d)
		if distance_to_line <= ai_line_penalty_radius:
			total_penalty += lerpf(0.22, 0.06, clampf(distance_to_line / ai_line_penalty_radius, 0.0, 1.0))

	return total_penalty


func _estimate_attack_exit_alignment(marble: Node3D, aim: Vector3) -> float:
	if marble == null or hole == null:
		return 0.0

	var planar_aim: Vector3 = Vector3(aim.x, 0.0, aim.z)
	if planar_aim.length_squared() <= 0.0001:
		return 0.0

	var local_position: Vector3 = hole.to_local(marble.global_position)
	var outward: Vector3 = Vector3(local_position.x, 0.0, local_position.z)
	if outward.length_squared() <= 0.0001:
		return 1.0

	return clampf(outward.normalized().dot(planar_aim.normalized()), 0.0, 1.0)


func _get_ai_hole_exit_multiplier(marble: Node3D) -> float:
	if marble == null:
		return 1.0

	var attempt_count: int = int(ai_hole_attack_attempts.get(marble.name, 0))
	if attempt_count <= 0:
		return 1.0

	var extra_attempts: int = maxi(attempt_count - 1, 0)
	var multiplier: float = ai_hole_exit_force_multiplier + float(extra_attempts) * ai_hole_exit_force_step
	return clampf(multiplier, 1.0, ai_hole_exit_force_max)


func _ensure_ai_hole_exit_force(marble: Node3D, force: float) -> float:
	if marble == null or not _is_marble_in_hole(marble):
		return force

	var min_force: float = float(marble.get("min_force_value")) if marble.get("min_force_value") != null else 0.8
	var max_force: float = float(marble.get("max_force_value")) if marble.get("max_force_value") != null else 3.5
	var attempt_count: int = int(ai_hole_attack_attempts.get(marble.name, 0))
	var depth_ratio: float = _get_marble_hole_depth_ratio(marble)
	var required_ratio: float = clampf(ai_hole_exit_min_force_ratio + depth_ratio * 0.1 + float(maxi(attempt_count - 1, 0)) * 0.035, 0.0, 0.92)
	var required_force: float = lerpf(min_force, max_force, required_ratio)
	return clampf(maxf(force, required_force), min_force, max_force)


func _scale_force_for_marble(marble: Node3D, base_force: float, multiplier: float) -> float:
	if marble == null:
		return base_force

	var min_force: float = float(marble.get("min_force_value")) if marble.get("min_force_value") != null else 0.8
	var max_force: float = float(marble.get("max_force_value")) if marble.get("max_force_value") != null else 3.5
	return clampf(base_force * multiplier, min_force, max_force)


func _apply_ai_aim_jitter(aim: Vector3, strategy_type: String, marble: Node3D = null) -> Vector3:
	var planar_aim: Vector3 = Vector3(aim.x, 0.0, aim.z)
	if planar_aim.length_squared() <= 0.0001:
		return Vector3.FORWARD

	var profile: Dictionary = _get_ai_profile(marble)
	var accuracy: float = float(profile.get("accuracy", 0.78))
	var focus: float = float(profile.get("focus", 0.76))
	var jitter_degrees: float = ai_jitter_degrees_goal
	match strategy_type:
		"attack":
			jitter_degrees = ai_jitter_degrees_attack
		"lineup":
			jitter_degrees = ai_lineup_jitter_degrees
		_:
			jitter_degrees = ai_jitter_degrees_goal
	jitter_degrees *= lerpf(1.65, 0.45, accuracy)
	jitter_degrees *= randf_range(0.75, 1.35)
	if strategy_type == "lineup" and randf() < ai_lineup_mistake_chance * lerpf(1.35, 0.35, focus):
		jitter_degrees += randf_range(2.5, 7.5)
	var jitter_radians: float = deg_to_rad(randf_range(-jitter_degrees, jitter_degrees))
	return planar_aim.normalized().rotated(Vector3.UP, jitter_radians).normalized()


func _apply_ai_force_personality(marble: Node3D, force: float, context: String) -> float:
	var profile: Dictionary = _get_ai_profile(marble)
	var power_control: float = float(profile.get("power_control", 0.78))
	var boldness: float = float(profile.get("boldness", 0.72))
	var min_force: float = float(marble.get("min_force_value")) if marble != null and marble.get("min_force_value") != null else 0.8
	var max_force: float = float(marble.get("max_force_value")) if marble != null and marble.get("max_force_value") != null else 3.5
	var error_span: float = ai_power_variation * lerpf(1.5, 0.45, power_control)
	if context == "lineup":
		error_span *= 1.45
	var adjusted_force: float = force * randf_range(1.0 - error_span, 1.0 + error_span)
	if context == "attack":
		adjusted_force *= lerpf(0.94, 1.08, boldness)
	return clampf(adjusted_force, min_force, max_force)


func _wait_for_real_player_shot(action_mode: int = ACTION_MODE_NONE) -> void:
	var elapsed: float = 0.0
	var warned: bool = false

	while not player_has_shot:
		if not await _await_next_frame():
			return
		elapsed += get_process_delta_time()

		if elapsed >= idle_player_warning_time and not warned:
			warned = true
		elif warned and elapsed >= idle_player_warning_time + 5.0:
			elapsed = idle_player_warning_time
			warned = false

	await _wait_for_player_shot_resolution(action_mode)


func _wait_for_player_shot_resolution(action_mode: int) -> void:
	if not instant_player_extra_turn_resolution:
		await _wait_for_all_marbles_to_stop()
		return

	var elapsed: float = 0.0
	var resolution_elapsed: float = -1.0

	while elapsed < max_settle_time:
		if not await _await_next_frame():
			return

		var delta: float = get_process_delta_time()
		elapsed += delta
		_track_current_actor_hole_entry()

		if _player_action_can_resolve_immediately(action_mode):
			if resolution_elapsed < 0.0:
				resolution_elapsed = 0.0
			else:
				resolution_elapsed += delta

			if resolution_elapsed >= instant_player_resolution_grace_time:
				_prepare_marble_for_instant_retry(player_marble)
				return
			continue

		if _all_marbles_are_still():
			_snap_settled_marbles_to_rest()
			return

	push_warning("Timed out waiting for player shot resolution. Continuing anyway.")
	_snap_settled_marbles_to_rest()


func _player_action_can_resolve_immediately(action_mode: int) -> bool:
	_track_current_actor_hole_entry()
	match action_mode:
		ACTION_MODE_APPROACH:
			if current_shot_entered_hole:
				return true
			return false
		ACTION_MODE_ATTACK:
			return false
		_:
			return false


func _wait_for_all_marbles_to_stop() -> void:
	var elapsed: float = 0.0
	var settled_for: float = 0.0

	while elapsed < max_settle_time:
		if not await _await_next_frame():
			return

		var delta: float = get_process_delta_time()
		elapsed += delta
		_track_current_actor_hole_entry()

		if _all_marbles_are_still():
			settled_for += delta
			if settled_for >= settle_time:
				_snap_settled_marbles_to_rest()
				return
		else:
			settled_for = 0.0

	push_warning("Timed out waiting for marbles to settle. Continuing anyway.")
	_snap_settled_marbles_to_rest()


func _wait_seconds(duration: float) -> void:
	var elapsed: float = 0.0

	while elapsed < duration:
		if not await _await_next_frame():
			return
		elapsed += get_process_delta_time()


func _all_marbles_are_still() -> bool:
	for marble in active_marbles:
		if marble == current_actor and _marble_is_in_hole_entry_area(marble) and not _is_marble_in_hole(marble):
			return false
		if _marble_has_moved(marble):
			return false
	return true


func _marble_has_moved(marble: Node3D) -> bool:
	if marble == null:
		return false

	if marble is RigidBody3D:
		var body: RigidBody3D = marble as RigidBody3D
		return body.linear_velocity.length() > settle_velocity_threshold or body.angular_velocity.length() > settle_velocity_threshold

	if marble.has_method("is_moving"):
		return marble.is_moving()

	return false


func _snap_settled_marbles_to_rest() -> void:
	if not snap_settled_marbles_to_rest:
		return

	for marble in active_marbles:
		var body: RigidBody3D = marble as RigidBody3D
		if body == null:
			continue
		if body.linear_velocity.length() <= settle_velocity_threshold:
			body.linear_velocity = Vector3.ZERO
		if body.angular_velocity.length() <= settle_velocity_threshold:
			body.angular_velocity = Vector3.ZERO
		body.sleeping = false


func _prepare_marble_for_instant_retry(marble: Node3D) -> void:
	var body: RigidBody3D = marble as RigidBody3D
	if body == null:
		return
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	body.sleeping = false


func _force_active_marbles_to_rest() -> void:
	for marble in active_marbles:
		var body: RigidBody3D = marble as RigidBody3D
		if body == null:
			continue
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		body.sleeping = false


func _cache_previous_marble_velocities() -> void:
	for marble in active_marbles:
		var body: RigidBody3D = marble as RigidBody3D
		if body == null:
			continue
		previous_marble_velocities[body.get_instance_id()] = body.linear_velocity


func _lan_broadcast_marble_state(delta: float) -> void:
	if online_enabled:
		if not _has_online_remote_players():
			return
	elif not lan_remote_player_connected:
		return
	lan_state_send_accumulator += delta
	var state_send_rate: float = online_state_send_rate if online_enabled else lan_state_send_rate
	var send_interval: float = 1.0 / maxf(state_send_rate, 1.0)
	if lan_state_send_accumulator < send_interval:
		return
	var elapsed_since_last_send: float = lan_state_send_accumulator
	lan_state_send_accumulator = 0.0

	var force_online_full_snapshot: bool = false
	if online_enabled:
		online_full_snapshot_accumulator += elapsed_since_last_send
		force_online_full_snapshot = online_full_snapshot_accumulator >= maxf(online_full_snapshot_interval, send_interval)
		if force_online_full_snapshot:
			online_full_snapshot_accumulator = 0.0
	var online_delta_only: bool = online_enabled and not force_online_full_snapshot and not _lan_any_marble_moving_for_sync()
	var states: Array = _lan_collect_marble_states(online_enabled, online_delta_only)
	if states.is_empty():
		return
	if online_enabled:
		_send_online_game_message("marble_states", {
			"states": states,
			"server_time": float(Time.get_ticks_msec()) * 0.001
		})
		return
	var remote_peer_id: int = _get_lan_remote_peer_id()
	if remote_peer_id <= 0:
		return
	_lan_receive_marble_states.rpc_id(remote_peer_id, states)


func _lan_send_marble_state_to_peer(peer_id: int) -> void:
	var states: Array = _lan_collect_marble_states(false, false)
	if states.is_empty() or peer_id <= 0:
		return
	_lan_receive_marble_states.rpc_id(peer_id, states)


func _send_online_marble_state_to_client(client_id: String) -> void:
	if client_id == "":
		return
	var states: Array = _lan_collect_marble_states(true, false)
	if states.is_empty():
		return
	_send_online_game_message("marble_states", {
		"states": states,
		"server_time": float(Time.get_ticks_msec()) * 0.001
	}, client_id)


func _send_online_authoritative_snapshot_now(target_id: String = "") -> void:
	if not online_enabled or online == null:
		return
	var states: Array = _lan_collect_marble_states(true, false)
	if states.is_empty():
		return
	_send_online_game_message("marble_states", {
		"states": states,
		"server_time": float(Time.get_ticks_msec()) * 0.001
	}, target_id)


func _lan_collect_marble_states(compact: bool = false, delta_only: bool = false) -> Array:
	var states: Array = []
	for marble in marbles:
		var body: RigidBody3D = marble as RigidBody3D
		if body == null:
			continue
		if delta_only and not _lan_marble_state_changed_since_last_send(body):
			continue
		if compact:
			states.append(_lan_make_compact_marble_state(body))
		else:
			states.append({
				"name": String(body.name),
				"transform": body.global_transform,
				"linear_velocity": body.linear_velocity,
				"angular_velocity": body.angular_velocity,
				"visible": body.visible,
				"active": active_marbles.has(body)
			})
	return states


func _lan_any_marble_moving_for_sync() -> bool:
	for marble in marbles:
		var body: RigidBody3D = marble as RigidBody3D
		if body == null:
			continue
		if body.linear_velocity.length() > LAN_STATE_MOVING_SYNC_THRESHOLD or body.angular_velocity.length() > LAN_STATE_MOVING_SYNC_THRESHOLD:
			return true
	return false


func _lan_marble_state_changed_since_last_send(body: RigidBody3D) -> bool:
	var marble_name: String = String(body.name)
	var current_state: Dictionary = {
		"position": body.global_position,
		"linear_velocity": body.linear_velocity,
		"angular_velocity": body.angular_velocity,
		"visible": body.visible,
		"active": active_marbles.has(body)
	}
	var previous_state: Dictionary = lan_last_sent_state_by_marble_name.get(marble_name, {}) as Dictionary
	var changed: bool = previous_state.is_empty()
	if not changed:
		changed = (previous_state.get("position", body.global_position) as Vector3).distance_to(body.global_position) > LAN_STATE_POSITION_CHANGE_EPSILON
	if not changed:
		changed = (previous_state.get("linear_velocity", body.linear_velocity) as Vector3).distance_to(body.linear_velocity) > LAN_STATE_VELOCITY_CHANGE_EPSILON
	if not changed:
		changed = (previous_state.get("angular_velocity", body.angular_velocity) as Vector3).distance_to(body.angular_velocity) > LAN_STATE_VELOCITY_CHANGE_EPSILON
	if not changed:
		changed = bool(previous_state.get("visible", body.visible)) != body.visible
	if not changed:
		changed = bool(previous_state.get("active", active_marbles.has(body))) != active_marbles.has(body)
	if changed:
		lan_last_sent_state_by_marble_name[marble_name] = current_state
	return changed


func _lan_make_compact_marble_state(body: RigidBody3D) -> Dictionary:
	var rotation: Quaternion = body.global_transform.basis.get_rotation_quaternion()
	return {
		"n": String(body.name),
		"p": _vector3_to_state_array(body.global_position),
		"q": [_state_float(rotation.x), _state_float(rotation.y), _state_float(rotation.z), _state_float(rotation.w)],
		"lv": _vector3_to_state_array(body.linear_velocity),
		"av": _vector3_to_state_array(body.angular_velocity),
		"v": body.visible,
		"a": active_marbles.has(body)
	}


func _vector3_to_state_array(value: Vector3) -> Array:
	return [_state_float(value.x), _state_float(value.y), _state_float(value.z)]


func _state_float(value: float) -> float:
	return snappedf(value, 0.001)


func _send_online_game_message(message_type: String, payload: Dictionary = {}, target_id: String = "") -> void:
	if online == null or not online.has_method("send_game_message"):
		return
	online.call("send_game_message", message_type, payload, target_id)


@rpc("authority", "call_remote", "unreliable")
func _lan_receive_marble_states(states: Array, remote_time_seconds: float = -1.0) -> void:
	if not lan_enabled or lan_is_host:
		return
	var receive_time: float = float(Time.get_ticks_msec()) * 0.001
	var sample_time: float = receive_time
	if online_enabled and remote_time_seconds > 0.0:
		sample_time = remote_time_seconds
		var measured_offset: float = receive_time - remote_time_seconds
		if not lan_client_remote_time_offset_ready:
			lan_client_remote_time_offset = measured_offset
			lan_client_remote_time_offset_ready = true
		else:
			lan_client_remote_time_offset = lerpf(lan_client_remote_time_offset, measured_offset, 0.08)
	for state in states:
		if typeof(state) != TYPE_DICTIONARY:
			continue
		var sample: Dictionary = (state as Dictionary).duplicate(true)
		var marble_name: String = str(state.get("name", state.get("n", "")))
		if marble_name == "":
			continue
		if _online_client_should_ignore_prediction_sample(marble_name, sample_time):
			continue
		sample["_client_time"] = receive_time
		sample["_sample_time"] = sample_time
		lan_client_targets[marble_name] = sample
		if online_enabled:
			_push_lan_client_state_sample(marble_name, sample, sample_time)


func _push_lan_client_state_sample(marble_name: String, sample: Dictionary, sample_time: float) -> void:
	var buffer: Array = lan_client_state_buffers.get(marble_name, []) as Array
	buffer.append(sample)
	while buffer.size() > LAN_CLIENT_STATE_BUFFER_MAX_SAMPLES:
		buffer.remove_at(0)
	while buffer.size() > 2:
		var oldest: Dictionary = buffer[0] as Dictionary
		var oldest_time: float = float(oldest.get("_sample_time", sample_time))
		if sample_time - oldest_time <= LAN_CLIENT_STATE_BUFFER_MAX_AGE:
			break
		buffer.remove_at(0)
	lan_client_state_buffers[marble_name] = buffer


func _online_client_should_ignore_prediction_sample(marble_name: String, sample_time: float) -> bool:
	if not online_enabled or lan_is_host:
		return false
	if lan_client_predicted_marble_name == "" or marble_name != lan_client_predicted_marble_name:
		return false
	if lan_client_prediction_started_remote_seconds < 0.0:
		return false
	return sample_time < lan_client_prediction_started_remote_seconds - ONLINE_PREDICTION_PRE_SHOT_GRACE_SECONDS


func _smooth_lan_client_marbles(delta: float) -> void:
	var smoothing_speed: float = lan_state_lerp_speed * 0.7 if online_enabled else lan_state_lerp_speed
	var weight: float = clampf(delta * smoothing_speed, 0.0, 1.0)
	var snap_distance: float = ONLINE_CLIENT_STATE_SNAP_DISTANCE if online_enabled else LAN_CLIENT_STATE_SNAP_DISTANCE
	for marble_name in lan_client_targets.keys():
		var marble: Node3D = _find_marble_by_name(str(marble_name))
		var body: RigidBody3D = marble as RigidBody3D
		if body == null:
			continue
		var state: Dictionary = _get_lan_client_render_state(str(marble_name), body.global_transform)
		if state.is_empty():
			continue
		var state_active: bool = bool(state.get("active", state.get("a", true)))
		var state_visible: bool = state_active and bool(state.get("visible", state.get("v", true)))
		if _online_client_should_hold_local_aim_marble(str(marble_name)):
			if not body.freeze:
				body.freeze = true
			body.linear_velocity = Vector3.ZERO
			body.angular_velocity = Vector3.ZERO
			body.visible = state_visible
			continue
		if not state_active:
			if not body.freeze:
				body.freeze = true
			body.linear_velocity = Vector3.ZERO
			body.angular_velocity = Vector3.ZERO
			body.visible = false
			continue
		var target_transform: Transform3D = _transform_from_marble_state(state, body.global_transform)
		if online_enabled and _online_client_is_predicting_marble(str(marble_name)):
			_reconcile_online_local_prediction(body, state, target_transform, delta)
			continue
		var current_transform: Transform3D = body.global_transform
		var distance_to_target: float = current_transform.origin.distance_to(target_transform.origin)
		var target_linear_velocity: Vector3 = _vector3_from_state_value(state.get("linear_velocity", state.get("lv", Vector3.ZERO)), Vector3.ZERO)
		var target_angular_velocity: Vector3 = _vector3_from_state_value(state.get("angular_velocity", state.get("av", Vector3.ZERO)), Vector3.ZERO)
		var target_is_moving: bool = target_linear_velocity.length() > LAN_STATE_MOVING_SYNC_THRESHOLD or target_angular_velocity.length() > LAN_STATE_MOVING_SYNC_THRESHOLD
		if distance_to_target > snap_distance and not target_is_moving:
			body.global_transform = target_transform
		elif distance_to_target <= LAN_CLIENT_STATE_POSITION_DEADZONE:
			body.global_transform = target_transform
		else:
			var smoothed_origin: Vector3 = current_transform.origin.lerp(target_transform.origin, weight)
			var smoothed_basis: Basis = current_transform.basis.slerp(target_transform.basis, weight).orthonormalized()
			body.global_transform = Transform3D(smoothed_basis, smoothed_origin)
		if not body.freeze:
			body.freeze = true
		body.linear_velocity = target_linear_velocity
		body.angular_velocity = target_angular_velocity
		body.visible = state_visible


func _online_client_should_hold_local_aim_marble(marble_name: String) -> bool:
	if not online_enabled or lan_is_host or not lan_dragging:
		return false
	var input_marble: Node3D = _get_network_input_marble()
	if input_marble == null:
		return false
	return marble_name == String(input_marble.name) and lan_client_active_marble_name == marble_name


func _get_lan_client_render_state(marble_name: String, fallback_transform: Transform3D) -> Dictionary:
	if not online_enabled:
		return lan_client_targets.get(marble_name, {}) as Dictionary

	var buffer: Array = lan_client_state_buffers.get(marble_name, []) as Array
	if buffer.is_empty():
		return lan_client_targets.get(marble_name, {}) as Dictionary

	var now_seconds: float = _lan_client_remote_now_seconds()
	var render_time: float = now_seconds - maxf(online_interpolation_delay, 0.0)
	while buffer.size() > 2:
		var next_sample: Dictionary = buffer[1] as Dictionary
		if float(next_sample.get("_sample_time", render_time)) > render_time:
			break
		buffer.remove_at(0)
	lan_client_state_buffers[marble_name] = buffer

	if buffer.size() == 1:
		var only_sample: Dictionary = buffer[0] as Dictionary
		return _extrapolate_lan_client_state(only_sample, fallback_transform, render_time)

	var previous_sample: Dictionary = buffer[0] as Dictionary
	var following_sample: Dictionary = buffer[1] as Dictionary
	var previous_time: float = float(previous_sample.get("_sample_time", render_time))
	var following_time: float = float(following_sample.get("_sample_time", previous_time))
	if render_time <= previous_time:
		return previous_sample
	if following_time > previous_time and render_time <= following_time:
		var blend: float = clampf((render_time - previous_time) / maxf(following_time - previous_time, 0.001), 0.0, 1.0)
		return _interpolate_lan_client_states(previous_sample, following_sample, blend, fallback_transform)
	return _extrapolate_lan_client_state(following_sample, fallback_transform, render_time)


func _lan_client_remote_now_seconds() -> float:
	var now_seconds: float = float(Time.get_ticks_msec()) * 0.001
	if online_enabled and lan_client_remote_time_offset_ready:
		return now_seconds - lan_client_remote_time_offset
	return now_seconds


func _interpolate_lan_client_states(previous_state: Dictionary, following_state: Dictionary, blend: float, fallback_transform: Transform3D) -> Dictionary:
	var previous_transform: Transform3D = _transform_from_marble_state(previous_state, fallback_transform)
	var following_transform: Transform3D = _transform_from_marble_state(following_state, previous_transform)
	var origin: Vector3 = previous_transform.origin.lerp(following_transform.origin, blend)
	var basis: Basis = previous_transform.basis.slerp(following_transform.basis, blend).orthonormalized()
	var previous_linear_velocity: Vector3 = _vector3_from_state_value(previous_state.get("linear_velocity", previous_state.get("lv", Vector3.ZERO)), Vector3.ZERO)
	var following_linear_velocity: Vector3 = _vector3_from_state_value(following_state.get("linear_velocity", following_state.get("lv", Vector3.ZERO)), previous_linear_velocity)
	var previous_angular_velocity: Vector3 = _vector3_from_state_value(previous_state.get("angular_velocity", previous_state.get("av", Vector3.ZERO)), Vector3.ZERO)
	var following_angular_velocity: Vector3 = _vector3_from_state_value(following_state.get("angular_velocity", following_state.get("av", Vector3.ZERO)), previous_angular_velocity)
	return {
		"transform": Transform3D(basis, origin),
		"linear_velocity": previous_linear_velocity.lerp(following_linear_velocity, blend),
		"angular_velocity": previous_angular_velocity.lerp(following_angular_velocity, blend),
		"visible": bool(following_state.get("visible", following_state.get("v", true))),
		"active": bool(following_state.get("active", following_state.get("a", true)))
	}


func _extrapolate_lan_client_state(state: Dictionary, fallback_transform: Transform3D, render_time: float) -> Dictionary:
	var sample_time: float = float(state.get("_sample_time", state.get("_client_time", render_time)))
	var elapsed: float = clampf(render_time - sample_time, 0.0, maxf(online_extrapolation_limit, 0.0))
	if elapsed <= 0.0:
		return state
	var transform: Transform3D = _transform_from_marble_state(state, fallback_transform)
	var linear_velocity: Vector3 = _vector3_from_state_value(state.get("linear_velocity", state.get("lv", Vector3.ZERO)), Vector3.ZERO)
	transform.origin += linear_velocity * elapsed
	return {
		"transform": transform,
		"linear_velocity": linear_velocity,
		"angular_velocity": _vector3_from_state_value(state.get("angular_velocity", state.get("av", Vector3.ZERO)), Vector3.ZERO),
		"visible": bool(state.get("visible", state.get("v", true))),
		"active": bool(state.get("active", state.get("a", true)))
	}


func _start_online_local_prediction(marble: Node3D, aim: Vector3, force: float) -> void:
	if not online_enabled or lan_is_host or marble == null:
		return
	if aim == Vector3.ZERO or force <= 0.0:
		return
	var marble_name: String = String(marble.name)
	lan_client_predicted_marble_name = marble_name
	lan_client_prediction_started_msec = Time.get_ticks_msec()
	lan_client_prediction_started_remote_seconds = _lan_client_remote_now_seconds() if lan_client_remote_time_offset_ready else -1.0
	lan_client_targets.erase(marble_name)
	lan_client_state_buffers.erase(marble_name)
	var body: RigidBody3D = marble as RigidBody3D
	if body != null:
		body.freeze = false
		body.sleeping = false
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
	if marble.has_method("shoot"):
		marble.call("shoot", aim, force)


func _stop_online_local_prediction() -> void:
	lan_client_predicted_marble_name = ""
	lan_client_prediction_started_msec = 0
	lan_client_prediction_started_remote_seconds = -1.0


func _online_client_is_predicting_marble(marble_name: String) -> bool:
	if lan_client_predicted_marble_name == "" or marble_name != lan_client_predicted_marble_name:
		return false
	if _online_local_prediction_age_seconds() > ONLINE_LOCAL_PREDICTION_MAX_SECONDS:
		_stop_online_local_prediction()
		return false
	return true


func _online_local_prediction_age_seconds() -> float:
	if lan_client_prediction_started_msec <= 0:
		return 0.0
	return maxf((float(Time.get_ticks_msec() - lan_client_prediction_started_msec) * 0.001), 0.0)


func _reconcile_online_local_prediction(body: RigidBody3D, state: Dictionary, target_transform: Transform3D, delta: float) -> void:
	body.visible = bool(state.get("visible", state.get("v", true)))
	body.freeze = false
	body.sleeping = false
	var age: float = _online_local_prediction_age_seconds()
	if age < ONLINE_LOCAL_PREDICTION_RECONCILE_DELAY:
		return

	var target_linear_velocity: Vector3 = _vector3_from_state_value(state.get("linear_velocity", state.get("lv", Vector3.ZERO)), Vector3.ZERO)
	var target_angular_velocity: Vector3 = _vector3_from_state_value(state.get("angular_velocity", state.get("av", Vector3.ZERO)), Vector3.ZERO)
	var distance_to_target: float = body.global_position.distance_to(target_transform.origin)
	var target_is_moving: bool = target_linear_velocity.length() > LAN_STATE_MOVING_SYNC_THRESHOLD or target_angular_velocity.length() > LAN_STATE_MOVING_SYNC_THRESHOLD
	var snap_distance: float = ONLINE_CLIENT_STATE_SNAP_DISTANCE if online_enabled else LAN_CLIENT_STATE_SNAP_DISTANCE
	if distance_to_target > snap_distance and not target_is_moving:
		if online_enabled:
			var far_reconcile_weight: float = clampf(delta * ONLINE_LOCAL_PREDICTION_RECONCILE_SPEED, 0.0, 0.2)
			body.global_transform = Transform3D(
				body.global_transform.basis.slerp(target_transform.basis, far_reconcile_weight).orthonormalized(),
				body.global_position.lerp(target_transform.origin, far_reconcile_weight)
			)
			body.linear_velocity = body.linear_velocity.lerp(target_linear_velocity, far_reconcile_weight)
			body.angular_velocity = body.angular_velocity.lerp(target_angular_velocity, far_reconcile_weight)
			return
		body.global_transform = target_transform
		body.linear_velocity = target_linear_velocity
		body.angular_velocity = target_angular_velocity
		return

	var soft_velocity_weight: float = clampf(delta * ONLINE_LOCAL_PREDICTION_SOFT_RECONCILE_SPEED, 0.0, 0.08)
	if online_enabled and target_is_moving and distance_to_target <= ONLINE_LOCAL_PREDICTION_POSITION_DEADZONE:
		body.linear_velocity = body.linear_velocity.lerp(target_linear_velocity, soft_velocity_weight)
		body.angular_velocity = body.angular_velocity.lerp(target_angular_velocity, soft_velocity_weight)
		return

	var reconcile_speed: float = ONLINE_LOCAL_PREDICTION_SOFT_RECONCILE_SPEED if online_enabled else ONLINE_LOCAL_PREDICTION_RECONCILE_SPEED
	var max_reconcile_weight: float = 0.12 if online_enabled else 0.22
	var reconcile_weight: float = clampf(delta * reconcile_speed, 0.0, max_reconcile_weight)
	body.global_transform = Transform3D(
		body.global_transform.basis,
		body.global_position.lerp(target_transform.origin, reconcile_weight)
	)
	body.linear_velocity = body.linear_velocity.lerp(target_linear_velocity, reconcile_weight)
	body.angular_velocity = body.angular_velocity.lerp(target_angular_velocity, reconcile_weight)

	if age > 0.75 and distance_to_target <= ONLINE_LOCAL_PREDICTION_POSITION_DEADZONE and body.linear_velocity.length() <= settle_velocity_threshold and target_linear_velocity.length() <= settle_velocity_threshold:
		_stop_online_local_prediction()


func _transform_from_marble_state(state: Dictionary, fallback: Transform3D) -> Transform3D:
	var transform_value = state.get("transform", null)
	if transform_value is Transform3D:
		return transform_value as Transform3D

	var origin: Vector3 = _vector3_from_state_value(state.get("p", fallback.origin), fallback.origin)
	var basis: Basis = fallback.basis
	var rotation_value = state.get("q", null)
	if typeof(rotation_value) == TYPE_ARRAY:
		var rotation_array: Array = rotation_value as Array
		if rotation_array.size() >= 4:
			var rotation := Quaternion(
				float(rotation_array[0]),
				float(rotation_array[1]),
				float(rotation_array[2]),
				float(rotation_array[3])
			)
			basis = Basis(rotation.normalized()).orthonormalized()
	return Transform3D(basis, origin)


func _vector3_from_state_value(value, fallback: Vector3) -> Vector3:
	if value is Vector3:
		return value as Vector3
	if typeof(value) == TYPE_ARRAY:
		var vector_array: Array = value as Array
		if vector_array.size() >= 3:
			return Vector3(float(vector_array[0]), float(vector_array[1]), float(vector_array[2]))
	if typeof(value) == TYPE_DICTIONARY:
		var vector_dict: Dictionary = value as Dictionary
		if vector_dict.has("x") and vector_dict.has("y") and vector_dict.has("z"):
			return Vector3(float(vector_dict.get("x", fallback.x)), float(vector_dict.get("y", fallback.y)), float(vector_dict.get("z", fallback.z)))
	return fallback


func _online_payload_server_time_seconds(payload: Dictionary) -> float:
	var server_time = payload.get("server_time", 0.0)
	if typeof(server_time) == TYPE_INT or typeof(server_time) == TYPE_FLOAT:
		var numeric_time: float = float(server_time)
		if numeric_time > 1000000.0:
			return numeric_time * 0.001
		return numeric_time
	return -1.0


func notify_player_shot() -> void:
	player_has_shot = true
	_register_shot(player_marble)


func _input(event: InputEvent) -> void:
	if not _lan_can_local_player_input():
		return

	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			if _pointer_over_ui():
				return
			_begin_lan_drag(touch.position, touch.index)
			get_viewport().set_input_as_handled()
		elif lan_dragging and touch.index == lan_drag_touch_index:
			_finish_lan_drag(touch.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if lan_dragging and drag.index == lan_drag_touch_index:
			_update_lan_drag(drag.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_button.pressed:
			if _pointer_over_ui():
				return
			_begin_lan_drag(mouse_button.position, -1)
			get_viewport().set_input_as_handled()
		elif lan_dragging:
			_finish_lan_drag(mouse_button.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and lan_dragging:
		_update_lan_drag((event as InputEventMouseMotion).position)
		get_viewport().set_input_as_handled()


func _lan_can_local_player_input() -> bool:
	if not lan_enabled or lan_is_host or get_tree().paused:
		return false
	if not lan_client_remote_turn_input_enabled:
		return false
	var input_marble: Node3D = _get_network_input_marble()
	if input_marble == null:
		return false
	if lan_client_active_marble_name != String(input_marble.name):
		return false
	return active_marbles.has(input_marble)


func _get_network_input_marble() -> Node3D:
	if online_enabled:
		return online_local_player_marble
	return lan_remote_player_marble


func _begin_lan_drag(pointer_position: Vector2, touch_index: int) -> void:
	lan_dragging = true
	lan_drag_touch_index = touch_index
	lan_drag_start = pointer_position
	lan_drag_aim = Vector3.ZERO
	lan_drag_force = 0.0
	lan_drag_power_ratio = 0.0
	lan_drag_smoothed_vector = Vector2.ZERO
	lan_drag_has_smoothed_vector = false
	lan_last_aim_send_msec = 0
	_capture_lan_drag_reference_axes()
	_update_lan_drag(pointer_position, true)


func _update_lan_drag(pointer_position: Vector2, force_send: bool = false, use_raw_drag: bool = false) -> void:
	var raw_drag: Vector2 = pointer_position - lan_drag_start
	var shot: Dictionary = _get_lan_shot_from_drag(_get_lan_drag_vector_for_preview(raw_drag, use_raw_drag))
	var host_peer_id: int = _get_lan_host_peer_id()
	if not online_enabled and host_peer_id <= 0:
		return
	var input_marble: Node3D = _get_network_input_marble()
	if input_marble == null:
		return
	if shot.is_empty():
		lan_drag_aim = Vector3.ZERO
		lan_drag_force = 0.0
		_apply_lan_remote_aim_preview(input_marble, Vector3.ZERO, 0.0, false)
		lan_drag_power_ratio = 0.0
		_update_lan_power_meter(0.0, lan_dragging)
		if online_enabled:
			if _should_send_online_aim_update(force_send):
				_send_online_game_message("remote_player_aim", {"aim": Vector3.ZERO, "force": 0.0, "aiming": false, "marble_name": String(input_marble.name)})
		else:
			_lan_receive_remote_player_aim.rpc_id(host_peer_id, Vector3.ZERO, 0.0, false)
		return

	lan_drag_aim = shot.get("aim", Vector3.ZERO)
	lan_drag_force = float(shot.get("force", 0.0))
	lan_drag_power_ratio = float(shot.get("power_ratio", 0.0))
	_apply_lan_remote_aim_preview(input_marble, lan_drag_aim, lan_drag_force, true)
	_update_lan_power_meter(lan_drag_power_ratio, true)
	if online_enabled:
		if _should_send_online_aim_update(force_send):
			_send_online_game_message("remote_player_aim", {"aim": lan_drag_aim, "force": lan_drag_force, "aiming": true, "marble_name": String(input_marble.name)})
	else:
		_lan_receive_remote_player_aim.rpc_id(host_peer_id, lan_drag_aim, lan_drag_force, true)


func _finish_lan_drag(pointer_position: Vector2) -> void:
	_update_lan_drag(pointer_position, true, true)
	lan_dragging = false
	lan_drag_touch_index = -1
	lan_drag_smoothed_vector = Vector2.ZERO
	lan_drag_has_smoothed_vector = false
	_reset_lan_drag_reference_axes()
	_update_lan_power_meter(0.0, false)
	var input_marble: Node3D = _get_network_input_marble()
	if input_marble == null:
		return
	_apply_lan_remote_aim_preview(input_marble, lan_drag_aim, lan_drag_force, false)
	var host_peer_id: int = _get_lan_host_peer_id()
	if not online_enabled and host_peer_id <= 0:
		return
	if online_enabled:
		_send_online_game_message("remote_player_aim", {"aim": lan_drag_aim, "force": lan_drag_force, "aiming": false, "marble_name": String(input_marble.name)})
	else:
		_lan_receive_remote_player_aim.rpc_id(host_peer_id, lan_drag_aim, lan_drag_force, false)
	if lan_drag_aim != Vector3.ZERO and lan_drag_force > 0.0:
		lan_client_remote_turn_input_enabled = false
		if online_enabled:
			_send_online_game_message("remote_player_shot", {"aim": lan_drag_aim, "force": lan_drag_force, "marble_name": String(input_marble.name)})
			_start_online_local_prediction(input_marble, lan_drag_aim, lan_drag_force)
		else:
			_lan_receive_remote_player_shot.rpc_id(host_peer_id, lan_drag_aim, lan_drag_force)


func _cache_lan_power_meter() -> void:
	if lan_power_bar != null and is_instance_valid(lan_power_bar):
		return
	lan_power_glass = get_node_or_null("/root/Main/UI/PowerMeter/PowerGlass") as Control
	lan_power_bar = get_node_or_null("/root/Main/UI/PowerMeter/PowerBar") as ProgressBar
	lan_power_label = get_node_or_null("/root/Main/UI/PowerMeter/PowerLabel") as Label
	if lan_power_bar == null or lan_power_glass == null or lan_power_label == null:
		var current_scene: Node = _get_current_scene_safe()
		if current_scene != null:
			lan_power_glass = current_scene.get_node_or_null("UI/PowerMeter/PowerGlass") as Control
			lan_power_bar = current_scene.get_node_or_null("UI/PowerMeter/PowerBar") as ProgressBar
			lan_power_label = current_scene.get_node_or_null("UI/PowerMeter/PowerLabel") as Label


func _update_lan_power_meter(power_ratio: float, visible: bool) -> void:
	_cache_lan_power_meter()
	if lan_power_bar == null:
		return
	var clean_ratio: float = clampf(power_ratio, 0.0, 1.0)
	if lan_power_glass != null:
		lan_power_glass.visible = visible
	lan_power_bar.visible = visible
	if lan_power_label != null:
		lan_power_label.visible = visible
		lan_power_label.text = "%d%%" % int(round(clean_ratio * 100.0)) if visible else "POWER"
	if visible:
		lan_power_bar.value = lerpf(lan_power_bar.value, clean_ratio * 100.0, 0.35)
	else:
		lan_power_bar.value = 0.0


func _should_send_online_aim_update(force_send: bool = false) -> bool:
	if not online_enabled:
		return true
	if force_send:
		lan_last_aim_send_msec = Time.get_ticks_msec()
		return true
	var interval_msec: int = int(round(1000.0 / maxf(online_aim_send_rate, 1.0)))
	var now_msec: int = Time.get_ticks_msec()
	if lan_last_aim_send_msec > 0 and now_msec - lan_last_aim_send_msec < interval_msec:
		return false
	lan_last_aim_send_msec = now_msec
	return true


func _get_lan_drag_vector_for_preview(raw_drag: Vector2, use_raw_drag: bool = false) -> Vector2:
	if use_raw_drag or not online_enabled:
		lan_drag_smoothed_vector = raw_drag
		lan_drag_has_smoothed_vector = true
		return raw_drag

	if not lan_drag_has_smoothed_vector:
		lan_drag_smoothed_vector = raw_drag
		lan_drag_has_smoothed_vector = true
		return raw_drag

	var smoothing_weight: float = clampf(online_local_aim_smoothing, 0.01, 1.0)
	lan_drag_smoothed_vector = lan_drag_smoothed_vector.lerp(raw_drag, smoothing_weight)
	return lan_drag_smoothed_vector


func _get_lan_shot_from_drag(drag: Vector2) -> Dictionary:
	var input_marble: Node3D = _get_network_input_marble()
	if input_marble == null:
		return {}
	var min_drag_length: float = _get_network_input_float(input_marble, "min_drag_length", 18.0)
	var max_drag_distance: float = _get_network_input_float(input_marble, "max_drag_distance", 220.0)
	if absf(drag.y) < min_drag_length and drag.length() < min_drag_length:
		return {}

	if not _ensure_lan_drag_reference_axes():
		return {}

	var horizontal_drag: float = -drag.x if _is_network_aim_inverted() else drag.x
	var horizontal_ratio: float = clampf(horizontal_drag / maxf(max_drag_distance, 1.0), -1.0, 1.0)
	var max_aim_turn_degrees: float = _get_network_input_float(input_marble, "max_aim_turn_degrees", 360.0)
	var aim: Vector3 = lan_drag_reference_forward.rotated(Vector3.UP, horizontal_ratio * deg_to_rad(max_aim_turn_degrees * 0.5))
	aim.y = 0.0
	if aim.length_squared() <= 0.0001:
		return {}
	var usable_drag_distance: float = maxf(max_drag_distance - min_drag_length, 1.0)
	var power_ratio: float = clampf(maxf(absf(drag.y) - min_drag_length, 0.0) / usable_drag_distance, 0.0, 1.0)
	var min_force: float = _get_network_input_float(input_marble, "min_force_value", 0.8)
	var max_force: float = _get_network_input_float(input_marble, "max_force_value", 3.5)
	var force: float = lerpf(min_force, max_force, power_ratio)
	return {"aim": aim.normalized(), "force": force, "power_ratio": power_ratio}


func _get_network_input_float(marble: Node3D, property_name: String, fallback: float) -> float:
	if marble == null:
		return fallback
	var value = marble.get(property_name)
	return float(value) if value != null else fallback


func _is_network_aim_inverted() -> bool:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("is_aim_inverted"):
		return bool(customization.call("is_aim_inverted"))
	return false


func _capture_lan_drag_reference_axes() -> void:
	lan_drag_reference_forward = Vector3.ZERO
	lan_drag_reference_right = Vector3.ZERO
	_ensure_lan_drag_reference_axes()


func _reset_lan_drag_reference_axes() -> void:
	lan_drag_reference_forward = Vector3.ZERO
	lan_drag_reference_right = Vector3.ZERO


func _ensure_lan_drag_reference_axes() -> bool:
	if lan_drag_reference_forward.length_squared() > 0.0001 and lan_drag_reference_right.length_squared() > 0.0001:
		return true

	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return false

	var camera_forward: Vector3 = -camera.global_transform.basis.z
	var camera_right: Vector3 = camera.global_transform.basis.x
	camera_forward.y = 0.0
	camera_right.y = 0.0
	if camera_forward.length_squared() <= 0.0001 or camera_right.length_squared() <= 0.0001:
		return false

	lan_drag_reference_forward = camera_forward.normalized()
	lan_drag_reference_right = camera_right.normalized()
	return true


func _pointer_over_ui() -> bool:
	return get_viewport().gui_get_hovered_control() != null


@rpc("authority", "call_remote", "reliable")
func _lan_remote_turn_started(action_mode: int) -> void:
	_stop_online_local_prediction()
	_end_hole_attack_level()
	lan_dragging = false
	lan_drag_touch_index = -1
	lan_drag_aim = Vector3.ZERO
	lan_drag_force = 0.0
	lan_drag_power_ratio = 0.0
	lan_drag_smoothed_vector = Vector2.ZERO
	lan_drag_has_smoothed_vector = false
	lan_last_aim_send_msec = 0
	_update_lan_power_meter(0.0, false)
	_reset_lan_drag_reference_axes()
	lan_client_game_phase = game_phase
	current_action_mode = action_mode
	lan_client_remote_turn_input_enabled = action_mode != ACTION_MODE_NONE
	if lan_client_active_marble_name == "" and lan_remote_player_marble != null:
		lan_client_active_marble_name = String(lan_remote_player_marble.name)
	if lan_client_active_display_name == "":
		lan_client_active_display_name = "PLAY NOW"
	var active_index: int = turn_order.find(lan_remote_player_marble)
	if active_index < 0:
		active_index = 0
	if lan_remote_player_marble != null:
		if action_mode == ACTION_MODE_ATTACK:
			_begin_hole_attack_level(lan_remote_player_marble)
		_activate_camera_for_client(lan_remote_player_marble)
	turn_changed.emit(lan_client_active_display_name, active_index)
	if action_mode == ACTION_MODE_ATTACK:
		pass


@rpc("any_peer", "call_remote", "unreliable")
func _lan_receive_remote_player_aim(aim: Vector3, force: float, aiming: bool) -> void:
	_receive_network_remote_player_aim(aim, force, aiming, str(multiplayer.get_remote_sender_id()))


@rpc("authority", "call_remote", "unreliable")
func _lan_broadcast_remote_player_aim(aim: Vector3, force: float, aiming: bool) -> void:
	if lan_is_host:
		return
	if lan_remote_player_marble != null and lan_remote_player_marble == _get_network_input_marble():
		return
	_apply_lan_remote_aim_preview(lan_remote_player_marble, aim, force, aiming)


@rpc("any_peer", "call_remote", "reliable")
func _lan_receive_remote_player_shot(aim: Vector3, force: float) -> void:
	_receive_network_remote_player_shot(aim, force, str(multiplayer.get_remote_sender_id()))


func _receive_network_remote_player_aim(aim: Vector3, force: float, aiming: bool, sender_key: String, claimed_marble_name: String = "") -> void:
	if not lan_enabled or not lan_is_host:
		return
	var marble: Node3D = lan_remote_player_marble
	if online_enabled:
		marble = _resolve_online_sender_marble(sender_key, claimed_marble_name)
		if marble == null:
			return
		lan_remote_player_marble = marble
	elif not _is_lan_remote_sender(int(sender_key)):
		return
	if not lan_waiting_remote_player_shot or current_actor != marble:
		if not aiming:
			_apply_lan_remote_aim_preview(marble, Vector3.ZERO, 0.0, false)
		return

	_apply_lan_remote_aim_preview(marble, aim, force, aiming)
	if online_enabled:
		_send_online_game_message("broadcast_remote_player_aim", {
			"marble_name": String(marble.name),
			"aim": aim,
			"force": force,
			"aiming": aiming
		})
	else:
		var remote_peer_id: int = _get_lan_remote_peer_id()
		if remote_peer_id > 0:
			_lan_broadcast_remote_player_aim.rpc_id(remote_peer_id, aim, force, aiming)


func _receive_network_remote_player_shot(aim: Vector3, force: float, sender_key: String, claimed_marble_name: String = "") -> void:
	if not lan_enabled or not lan_is_host:
		return
	if not lan_waiting_remote_player_shot:
		return
	var marble: Node3D = lan_remote_player_marble
	if online_enabled:
		marble = _resolve_online_sender_marble(sender_key, claimed_marble_name)
		if marble == null:
			return
		lan_remote_player_marble = marble
	elif not _is_lan_remote_sender(int(sender_key)):
		return
	if marble == null or current_actor != marble:
		return

	var clean_aim: Vector3 = Vector3(aim.x, 0.0, aim.z)
	if clean_aim.length_squared() <= 0.0001:
		return

	lan_remote_player_shot_data = {
		"aim": clean_aim.normalized(),
		"force": clampf(force, 0.0, 10.0)
	}
	lan_remote_player_shot_ready = true


@rpc("any_peer", "call_remote", "reliable")
func _lan_client_scene_ready() -> void:
	_receive_network_client_scene_ready(str(multiplayer.get_remote_sender_id()), {})


func _receive_network_client_scene_ready(sender_key: String, payload: Dictionary) -> void:
	if not lan_enabled or not lan_is_host:
		return
	if online_enabled:
		var marble: Node3D = _get_or_assign_online_player_marble(sender_key)
		if marble == null:
			return
		_apply_online_active_marble_roster()
		online_ready_client_ids[sender_key] = true
		lan_remote_player_marble = marble
		lan_remote_player_connected = true
		_receive_network_player_customization(payload, sender_key)
		_update_lan_remote_player_name()
		_emit_turn_state()
		_send_online_state_snapshot_to_client(sender_key)
		return
	var peer_id: int = int(sender_key)
	if not _is_lan_remote_sender(peer_id):
		return
	lan_remote_player_connected = true
	_update_lan_remote_player_name()
	_emit_turn_state()
	_emit_scoreboard()
	_lan_send_marble_state_to_peer(peer_id)


func _receive_online_sync_request(sender_key: String, payload: Dictionary) -> void:
	if not online_enabled or not lan_is_host or sender_key == "":
		return
	var marble: Node3D = _resolve_online_sender_marble(sender_key, str(payload.get("active_marble_name", "")))
	if marble == null:
		return
	_apply_online_active_marble_roster()
	online_ready_client_ids[sender_key] = true
	lan_remote_player_connected = true
	_receive_network_player_customization(payload, sender_key)
	_send_online_state_snapshot_to_client(sender_key)


func _send_online_state_snapshot_to_client(client_id: String) -> void:
	if not online_enabled or not lan_is_host or client_id == "":
		return
	_send_online_turn_state_to_client(client_id)
	_send_online_scoreboard_to_client(client_id)
	_send_online_local_customization(client_id)
	_send_online_marble_state_to_client(client_id)
	_send_online_remote_turn_snapshot_to_client(client_id)


func _send_online_turn_state_to_client(client_id: String) -> void:
	var marble: Node3D = _get_current_turn_marble()
	if marble == null and not active_marbles.is_empty():
		marble = active_marbles[0]
	if marble == null:
		return
	var active_index: int = turn_order.find(marble)
	if active_index < 0:
		active_index = 0
	_send_online_game_message("turn_state", {
		"display_name": _turn_display_name_for_marble(marble),
		"active_index": active_index,
		"active_marble_name": String(marble.name),
		"phase": game_phase
	}, client_id)


func _send_online_scoreboard_to_client(client_id: String) -> void:
	var entries: Array = []
	for marble in turn_order:
		if marble == null or not active_marbles.has(marble):
			continue
		entries.append({
			"name": _display_name_for_marble(marble),
			"strokes": int(stroke_counts.get(marble.name, 0)),
			"is_active": marble == _get_current_turn_marble()
		})
	_send_online_game_message("scoreboard", {"entries": entries}, client_id)


func _send_online_remote_turn_snapshot_to_client(client_id: String) -> void:
	if not lan_waiting_remote_player_shot or current_actor == null:
		return
	if _get_online_client_id_for_marble(current_actor) != client_id:
		return
	_send_online_game_message("remote_turn_started", {
		"action_mode": current_action_mode,
		"active_marble_name": String(current_actor.name),
		"client_id": client_id,
		"target_client_id": client_id,
		"display_name": _turn_display_name_for_marble(current_actor),
		"phase": game_phase
	}, client_id)


func _apply_lan_remote_aim_preview(marble: Node3D, aim: Vector3, force: float, aiming: bool) -> void:
	if marble == null:
		return
	if aiming and aim != Vector3.ZERO and marble.has_method("begin_aim_preview"):
		marble.call("begin_aim_preview", {"aim": aim, "force": force})
	elif marble.has_method("end_aim_preview"):
		marble.call("end_aim_preview")


func _on_marble_body_entered(other_body: Node, source_body: RigidBody3D) -> void:
	if other_body == null or not (other_body is Node3D):
		return
	if source_body == null:
		return

	var source_marble: Node3D = source_body
	var other_marble: Node3D = other_body as Node3D
	var hit_marble: Node3D = null

	if other_body is RigidBody3D and active_marbles.has(other_body):
		_apply_power_impact_response(source_body, other_body as RigidBody3D)
		_play_marble_impact_sound(source_body, other_body as RigidBody3D)
		_spawn_hit_reward(source_body, other_body as RigidBody3D)
	else:
		_play_surface_contact_sound(source_body, other_body)

	if current_actor == null:
		return

	if source_marble == current_actor and active_marbles.has(other_marble):
		hit_marble = other_marble
	elif other_marble == current_actor and active_marbles.has(source_marble):
		hit_marble = source_marble

	if hit_marble == null or hit_marble == current_actor:
		return

	if current_action_mode == ACTION_MODE_APPROACH:
		if pending_approach_victim == null:
			pending_approach_victim = hit_marble
		return

	if current_action_mode != ACTION_MODE_ATTACK:
		return
	if pending_attack_victim != null:
		return

	pending_attack_victim = hit_marble


func _get_successful_attack_victim(attacker: Node3D) -> Node3D:
	if attacker == null:
		return null

	if pending_attack_victim != null and active_marbles.has(pending_attack_victim):
		return pending_attack_victim

	return null


func _get_stored_approach_victim(owner: Node3D) -> Node3D:
	if owner == null:
		return null
	if stored_approach_owner != owner:
		return null
	if stored_approach_victim == null or not active_marbles.has(stored_approach_victim):
		_clear_stored_approach_victim(owner)
		return null
	return stored_approach_victim


func _clear_stored_approach_victim(owner: Node3D = null) -> void:
	if owner != null and stored_approach_owner != owner:
		return
	stored_approach_victim = null
	stored_approach_owner = null


func _normalize_marble_lists() -> void:
	var unique_marbles: Array[Node3D] = []
	for marble in marbles:
		if marble == null or unique_marbles.has(marble):
			continue
		unique_marbles.append(marble)

	if unique_marbles.is_empty():
		for marble in _discover_scene_marbles():
			if marble == null or unique_marbles.has(marble):
				continue
			unique_marbles.append(marble)

	if player_marble != null and not unique_marbles.has(player_marble):
		unique_marbles.append(player_marble)

	marbles = unique_marbles
	active_marbles = marbles.duplicate()
	turn_order = active_marbles.duplicate()


func _assign_ai_player_names() -> void:
	ai_display_names.clear()
	var available_names: Array = AI_PLAYER_NAME_POOL.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for marble in marbles:
		if marble == null or not String(marble.name).begins_with("AI MARBLE"):
			continue
		if available_names.is_empty():
			available_names = AI_PLAYER_NAME_POOL.duplicate()
		var index: int = rng.randi_range(0, available_names.size() - 1)
		ai_display_names[String(marble.name)] = available_names[index]
		available_names.remove_at(index)


func _assign_ai_profiles() -> void:
	ai_profiles.clear()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for marble in marbles:
		if marble == null or not String(marble.name).begins_with("AI MARBLE"):
			continue

		var base_skill: float = rng.randf_range(0.66, 0.94)
		ai_profiles[String(marble.name)] = {
			"accuracy": clampf(base_skill + rng.randf_range(-ai_skill_spread, ai_skill_spread) * 0.45, 0.55, 0.98),
			"power_control": clampf(base_skill + rng.randf_range(-ai_skill_spread, ai_skill_spread) * 0.5, 0.54, 0.98),
			"boldness": rng.randf_range(0.42, 0.96),
			"focus": clampf(base_skill + rng.randf_range(-0.14, 0.12), 0.52, 0.98),
			"creativity": rng.randf_range(0.45, 1.0)
		}


func _get_ai_profile(marble: Node3D) -> Dictionary:
	if marble == null:
		return {
			"accuracy": 0.72,
			"power_control": 0.72,
			"boldness": 0.7,
			"focus": 0.72,
			"creativity": 0.7
		}
	var marble_name := String(marble.name)
	if not ai_profiles.has(marble_name):
		ai_profiles[marble_name] = {
			"accuracy": 0.7,
			"power_control": 0.7,
			"boldness": 0.68,
			"focus": 0.7,
			"creativity": 0.65
		}
	return ai_profiles[marble_name] as Dictionary


func _ensure_marble_name_tags() -> void:
	for marble in marbles:
		if marble == null:
			continue
		_ensure_marble_name_tag(marble)
	_refresh_marble_name_tags()


func _ensure_marble_name_tag(marble: Node3D) -> Label3D:
	if marble == null:
		return null
	var existing: Label3D = marble.get_node_or_null("NameTag") as Label3D
	if existing != null:
		marble_name_tags[marble.get_instance_id()] = existing
		return existing

	var label := Label3D.new()
	label.name = "NameTag"
	label.top_level = true
	label.global_position = marble.global_position + Vector3.UP * 0.52
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.fixed_size = true
	label.pixel_size = 0.0026
	label.font_size = 18
	label.outline_size = 5
	label.modulate = Color(0.96, 0.99, 1.0, 0.92)
	label.outline_modulate = Color(0.02, 0.03, 0.08, 0.88)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marble.add_child(label)
	marble_name_tags[marble.get_instance_id()] = label
	return label


func _ensure_marble_name_banner(marble: Node3D) -> MeshInstance3D:
	if marble == null:
		return null
	var existing: MeshInstance3D = marble.get_node_or_null("NameTagBanner") as MeshInstance3D
	if existing != null:
		marble_name_banners[marble.get_instance_id()] = existing
		return existing

	var banner := MeshInstance3D.new()
	banner.name = "NameTagBanner"
	banner.top_level = true
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(1.35, 0.34)
	banner.mesh = mesh
	banner.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	marble.add_child(banner)
	marble_name_banners[marble.get_instance_id()] = banner
	return banner


func _refresh_marble_name_tags() -> void:
	for marble in marbles:
		if marble == null:
			continue
		var label: Label3D = _ensure_marble_name_tag(marble)
		if label == null:
			continue
		var banner: MeshInstance3D = _ensure_marble_name_banner(marble)
		var display_text: String = _display_name_for_marble(marble)
		if online_enabled and online_local_player_marble == marble:
			display_text += " (YOU)"
		var is_active_turn: bool = false
		if online_enabled and not lan_is_host:
			is_active_turn = lan_client_active_marble_name == String(marble.name)
		else:
			is_active_turn = get_active_marble() == marble
		label.text = display_text
		label.global_position = marble.global_position + Vector3.UP * 0.52
		label.visible = marble.visible and active_marbles.has(marble)
		_apply_name_tag_banner_style(marble, label, banner)


func _apply_name_tag_banner_style(marble: Node3D, label: Label3D, banner: MeshInstance3D) -> void:
	var preset := _get_banner_preset_for_marble(marble)
	label.modulate = preset.get("text", Color(0.96, 0.99, 1.0, 0.92))
	label.outline_modulate = preset.get("outline", Color(0.02, 0.03, 0.08, 0.88))
	if banner == null:
		return
	var visible := label.visible
	banner.visible = visible
	if not visible:
		return
	banner.global_position = label.global_position + Vector3(0.0, -0.01, -0.012)
	var material: StandardMaterial3D = _get_cached_banner_material(preset)
	if banner.material_override != material:
		banner.material_override = material
	var text_width := clampf(float(label.text.length()) * 0.078 + 0.46, 1.05, 2.15)
	var shape := str(preset.get("shape", "banner"))
	var height := 0.34
	if shape == "bubble":
		height = 0.42
	elif shape == "burner":
		height = 0.38
	var plane := banner.mesh as PlaneMesh
	var size_signature: String = "%.3f|%.3f" % [text_width, height]
	if plane != null and str(banner.get_meta("size_signature", "")) != size_signature:
		plane.size = Vector2(text_width, height)
		banner.set_meta("size_signature", size_signature)


func _get_cached_banner_material(preset: Dictionary) -> StandardMaterial3D:
	var signature: String = _get_banner_material_signature(preset)
	var cached: StandardMaterial3D = banner_material_cache.get(signature, null) as StandardMaterial3D
	if cached != null:
		return cached
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.no_depth_test = true
	material.albedo_color = preset.get("fill", Color(0.02, 0.07, 0.10, 0.58))
	material.emission_enabled = true
	material.emission = preset.get("accent", Color(0.42, 0.92, 1.0, 1.0))
	material.emission_energy_multiplier = 0.22
	banner_material_cache[signature] = material
	return material


func _get_banner_material_signature(preset: Dictionary) -> String:
	return PackedStringArray([
		str(preset.get("fill", Color(0.02, 0.07, 0.10, 0.58))),
		str(preset.get("accent", Color(0.42, 0.92, 1.0, 1.0)))
	]).join("|")


func _get_banner_preset_for_marble(marble: Node3D) -> Dictionary:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_selected_banner_preset"):
		if marble == player_marble or (online_enabled and marble == online_local_player_marble):
			return customization.call("get_selected_banner_preset")
	if customization != null and customization.has_method("get_banner_preset"):
		return customization.call("get_banner_preset", "crystal")
	return {
		"fill": Color(0.02, 0.07, 0.10, 0.58),
		"accent": Color(0.42, 0.92, 1.0, 1.0),
		"text": Color(0.96, 0.99, 1.0, 1.0),
		"outline": Color(0.0, 0.02, 0.06, 0.92),
		"shape": "banner"
	}


func _discover_scene_marbles() -> Array[Node3D]:
	var discovered: Array[Node3D] = []
	var scene_root: Node = get_parent()
	if scene_root == null:
		return discovered

	_collect_scene_marbles_recursive(scene_root, discovered)

	return discovered


func _collect_scene_marbles_recursive(node: Node, discovered: Array[Node3D]) -> void:
	for candidate in node.get_children():
		if candidate == self or candidate == hole:
			continue
		if candidate is RigidBody3D and candidate.is_in_group("marbles") and not discovered.has(candidate):
			discovered.append(candidate as Node3D)
			continue
		_collect_scene_marbles_recursive(candidate, discovered)


func _connect_marble_signals() -> void:
	for marble in marbles:
		if not (marble is RigidBody3D):
			continue

		var body: RigidBody3D = marble as RigidBody3D
		_ensure_marble_collision_reporting(body)
		var callback: Callable = Callable(self , "_on_marble_body_entered").bind(body)
		if not body.body_entered.is_connected(callback):
			body.body_entered.connect(callback)


func _ensure_marble_collision_reporting(body: RigidBody3D) -> void:
	if body == null:
		return
	body.contact_monitor = true
	body.max_contacts_reported = maxi(body.max_contacts_reported, 8)
	if body.collision_layer == 0:
		body.collision_layer = 1
	if body.collision_mask == 0:
		body.collision_mask = 1


func _connect_hole_signals() -> void:
	call_deferred("_connect_hole_signals_deferred")


func _setup_impact_audio() -> void:
	impact_audio_players.clear()
	impact_sound_streams.clear()
	shot_sound_streams.clear()
	thump_sound_streams.clear()

	for path in IMPACT_SOUND_PATHS:
		var stream := _load_audio_stream(path)
		if stream != null:
			impact_sound_streams.append(stream)
	for path in SHOT_SOUND_PATHS:
		var stream := _load_audio_stream(path)
		if stream != null:
			shot_sound_streams.append(stream)
	for path in THUMP_SOUND_PATHS:
		var stream := _load_audio_stream(path)
		if stream != null:
			thump_sound_streams.append(stream)

	if impact_sound_streams.is_empty() and shot_sound_streams.is_empty() and thump_sound_streams.is_empty():
		return

	for index in range(IMPACT_AUDIO_POOL_SIZE):
		var player := AudioStreamPlayer3D.new()
		player.name = "ImpactAudio%d" % index
		player.bus = _get_sfx_bus_name()
		player.unit_size = 1.0
		player.max_distance = 34.0
		player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		player.panning_strength = 1.0
		player.volume_db = 0.0
		add_child(player)
		impact_audio_players.append(player)


func _setup_feedback_fx() -> void:
	if feedback_fx != null and is_instance_valid(feedback_fx):
		return
	var scene := load(FEEDBACK_FX_SCENE_PATH) as PackedScene
	if scene == null:
		return
	var current_scene: Node = _get_current_scene_safe()
	if current_scene == null:
		return
	feedback_fx = scene.instantiate()
	current_scene.add_child(feedback_fx)


func _spawn_hit_reward(source_body: RigidBody3D, other_body: RigidBody3D) -> void:
	if feedback_fx == null or not is_instance_valid(feedback_fx):
		_setup_feedback_fx()
	if feedback_fx == null or not feedback_fx.has_method("spawn_hit_sparks"):
		return
	var relative_speed := (source_body.linear_velocity - other_body.linear_velocity).length()
	if relative_speed < 0.75:
		return
	var pair_key := "fx:%s" % _get_impact_pair_key(source_body, other_body)
	var now_seconds := Time.get_ticks_msec() * 0.001
	var last_played: float = float(last_impact_timestamp_by_pair.get(pair_key, -1.0))
	if last_played >= 0.0 and now_seconds - last_played < 0.08:
		return
	last_impact_timestamp_by_pair[pair_key] = now_seconds
	var intensity := clampf(inverse_lerp(0.75, 12.0, relative_speed), 0.35, 2.0)
	var position := source_body.global_position.lerp(other_body.global_position, 0.5)
	feedback_fx.call("spawn_hit_sparks", position, intensity, _get_feedback_accent_for_marble(source_body))
	if intensity >= 1.05:
		_punch_active_camera(intensity)


func _spawn_hole_sink_reward(marble: Node3D) -> void:
	if feedback_fx == null or not is_instance_valid(feedback_fx):
		_setup_feedback_fx()
	if feedback_fx != null and feedback_fx.has_method("spawn_hole_sink"):
		feedback_fx.call("spawn_hole_sink", marble.global_position, _get_feedback_accent_for_marble(marble))


func _spawn_victory_reward(marble: Node3D) -> void:
	if feedback_fx == null or not is_instance_valid(feedback_fx):
		_setup_feedback_fx()
	if feedback_fx != null and feedback_fx.has_method("spawn_victory"):
		feedback_fx.call("spawn_victory", marble.global_position, _get_feedback_accent_for_marble(marble))


func _get_feedback_accent_for_marble(marble: Node) -> Color:
	if marble == player_marble or (online_enabled and marble == online_local_player_marble):
		var customization: Node = get_node_or_null("/root/CustomizationState")
		if customization != null and customization.has_method("get_selected_banner_preset"):
			var preset: Dictionary = customization.call("get_selected_banner_preset")
			return preset.get("accent", Color(0.42, 0.92, 1.0, 1.0))
	return Color(1.0, 0.76, 0.18, 1.0)


func _punch_active_camera(intensity: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var tween := create_tween()
	var original_fov := camera.fov
	var punch_fov := original_fov + clampf(intensity * 2.4, 1.4, 4.2)
	tween.tween_property(camera, "fov", punch_fov, 0.045).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "fov", original_fov, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _play_marble_impact_sound(source_body: RigidBody3D, other_body: RigidBody3D) -> void:
	if source_body == null or other_body == null:
		return
	if impact_audio_players.is_empty() or impact_sound_streams.is_empty():
		return

	var pair_key := _get_impact_pair_key(source_body, other_body)
	var now_seconds := Time.get_ticks_msec() * 0.001
	var last_played: float = float(last_impact_timestamp_by_pair.get(pair_key, -1.0))
	if last_played >= 0.0 and now_seconds - last_played < IMPACT_AUDIO_COOLDOWN:
		return

	var relative_speed := (source_body.linear_velocity - other_body.linear_velocity).length()
	if relative_speed < 0.55:
		return

	last_impact_timestamp_by_pair[pair_key] = now_seconds

	var player := impact_audio_players[impact_audio_index % impact_audio_players.size()]
	impact_audio_index += 1
	var speed_ratio := clampf(inverse_lerp(0.55, 12.0, relative_speed), 0.0, 1.0)
	player.stop()
	player.stream = impact_sound_streams[randi() % impact_sound_streams.size()]
	player.global_position = source_body.global_position.lerp(other_body.global_position, 0.5)
	player.pitch_scale = randf_range(1.42, 1.62) + speed_ratio * 0.14
	player.bus = _get_sfx_bus_name()
	player.volume_db = lerpf(-6.0, 4.2, speed_ratio)
	player.play()


func _play_surface_contact_sound(source_body: RigidBody3D, other_body: Node) -> void:
	if source_body == null or other_body == null:
		return
	if impact_audio_players.is_empty() or thump_sound_streams.is_empty():
		return

	var contact_speed := source_body.linear_velocity.length()
	if contact_speed < 0.85:
		return

	var pair_key := "surface:%s" % _get_impact_pair_key(source_body, other_body)
	var now_seconds := Time.get_ticks_msec() * 0.001
	var last_played: float = float(last_impact_timestamp_by_pair.get(pair_key, -1.0))
	if last_played >= 0.0 and now_seconds - last_played < THUMP_AUDIO_COOLDOWN:
		return
	last_impact_timestamp_by_pair[pair_key] = now_seconds

	var contact_type := _classify_surface_contact(other_body)
	var speed_ratio := clampf(inverse_lerp(0.85, 10.0, contact_speed), 0.0, 1.0)
	var player := _checkout_impact_audio_player()
	player.stop()
	player.stream = thump_sound_streams[randi() % thump_sound_streams.size()]
	player.global_position = _get_contact_sound_position(source_body, other_body)
	player.bus = _get_sfx_bus_name()
	match contact_type:
		"hole":
			player.pitch_scale = randf_range(0.62, 0.76) - speed_ratio * 0.06
			player.volume_db = lerpf(-10.5, 1.6, speed_ratio)
		"wall":
			player.pitch_scale = randf_range(0.84, 0.98) + speed_ratio * 0.04
			player.volume_db = lerpf(-9.0, 2.2, speed_ratio)
		"grass":
			player.pitch_scale = randf_range(0.78, 0.9) - speed_ratio * 0.02
			player.volume_db = lerpf(-13.0, -2.0, speed_ratio)
		_:
			player.pitch_scale = randf_range(0.68, 0.82) - speed_ratio * 0.03
			player.volume_db = lerpf(-11.0, 1.0, speed_ratio)
	player.play()

	if contact_type == "grass" and not impact_sound_streams.is_empty():
		var glass_tick := _checkout_impact_audio_player()
		glass_tick.stop()
		glass_tick.stream = impact_sound_streams[randi() % impact_sound_streams.size()]
		glass_tick.global_position = player.global_position
		glass_tick.bus = _get_sfx_bus_name()
		glass_tick.pitch_scale = randf_range(1.02, 1.16) + speed_ratio * 0.04
		glass_tick.volume_db = lerpf(-19.0, -9.0, speed_ratio)
		glass_tick.play()


func _play_shot_whoosh(marble: RigidBody3D) -> void:
	if marble == null:
		return
	if impact_audio_players.is_empty() or shot_sound_streams.is_empty():
		return

	var pair_key := "shot:%s" % str(marble.get_instance_id())
	var now_seconds := Time.get_ticks_msec() * 0.001
	var last_played: float = float(last_impact_timestamp_by_pair.get(pair_key, -1.0))
	if last_played >= 0.0 and now_seconds - last_played < SHOT_AUDIO_COOLDOWN:
		return
	last_impact_timestamp_by_pair[pair_key] = now_seconds

	var shot_speed := marble.linear_velocity.length()
	var player := impact_audio_players[impact_audio_index % impact_audio_players.size()]
	impact_audio_index += 1
	player.stop()
	player.stream = shot_sound_streams[randi() % shot_sound_streams.size()]
	player.global_position = marble.global_position
	player.pitch_scale = randf_range(1.08, 1.22)
	player.bus = _get_sfx_bus_name()
	player.volume_db = lerpf(-6.0, 3.0, clampf(inverse_lerp(1.0, 10.0, shot_speed), 0.0, 1.0))
	player.play()


func _apply_power_impact_response(source_body: RigidBody3D, other_body: RigidBody3D) -> void:
	if source_body == null or other_body == null:
		return

	var pair_key := "physics:%s" % _get_impact_pair_key(source_body, other_body)
	var now_seconds := Time.get_ticks_msec() * 0.001
	var last_played: float = float(last_impact_timestamp_by_pair.get(pair_key, -1.0))
	if last_played >= 0.0 and now_seconds - last_played < PHYSICS_IMPACT_COOLDOWN:
		return

	var collision_axis: Vector3 = other_body.global_position - source_body.global_position
	collision_axis.y = 0.0
	if collision_axis.length_squared() <= 0.0001:
		return
	collision_axis = collision_axis.normalized()

	var source_velocity: Vector3 = source_body.linear_velocity
	var other_velocity: Vector3 = other_body.linear_velocity
	var cached_source_velocity: Vector3 = previous_marble_velocities.get(source_body.get_instance_id(), source_velocity)
	var cached_other_velocity: Vector3 = previous_marble_velocities.get(other_body.get_instance_id(), other_velocity)

	var relative_velocity: Vector3 = source_velocity - other_velocity
	var normal_speed: float = relative_velocity.dot(collision_axis)
	var cached_normal_speed: float = (cached_source_velocity - cached_other_velocity).dot(collision_axis)
	if cached_normal_speed > normal_speed:
		source_velocity = cached_source_velocity
		other_velocity = cached_other_velocity
		normal_speed = cached_normal_speed
	if normal_speed <= PHYSICS_IMPACT_MIN_SPEED:
		return

	last_impact_timestamp_by_pair[pair_key] = now_seconds

	var source_planar_velocity: Vector3 = Vector3(source_velocity.x, 0.0, source_velocity.z)
	var other_planar_velocity: Vector3 = Vector3(other_velocity.x, 0.0, other_velocity.z)
	var source_normal_speed: float = source_planar_velocity.dot(collision_axis)
	var other_normal_speed: float = other_planar_velocity.dot(collision_axis)
	var source_tangent_velocity: Vector3 = source_planar_velocity - collision_axis * source_normal_speed
	var other_tangent_velocity: Vector3 = other_planar_velocity - collision_axis * other_normal_speed
	var restitution: float = clampf(marble_collision_restitution, 0.0, 1.15)
	var transfer_weight: float = clampf(marble_collision_transfer_strength, 0.0, 1.4)
	var equal_deflect_weight: float = clampf(marble_collision_equal_deflect_strength, 0.0, 1.0)
	var impact_speed: float = clampf(normal_speed * (1.0 + restitution) * 0.5 * transfer_weight, 0.0, PHYSICS_IMPACT_MAX_SPEED)
	if impact_speed <= 0.0:
		return
	var source_deflected_planar: Vector3 = source_tangent_velocity + collision_axis * (source_normal_speed - impact_speed)
	var other_deflected_planar: Vector3 = other_tangent_velocity + collision_axis * (other_normal_speed + impact_speed)

	var source_after_planar: Vector3 = source_planar_velocity.lerp(source_deflected_planar, equal_deflect_weight)
	var other_after_planar: Vector3 = other_planar_velocity.lerp(other_deflected_planar, equal_deflect_weight)

	source_body.linear_velocity = Vector3(source_after_planar.x, source_body.linear_velocity.y, source_after_planar.z)
	other_body.linear_velocity = Vector3(other_after_planar.x, other_body.linear_velocity.y, other_after_planar.z)
	_clamp_marble_upward_velocity(source_body)
	_clamp_marble_upward_velocity(other_body)
	previous_marble_velocities[source_body.get_instance_id()] = source_body.linear_velocity
	previous_marble_velocities[other_body.get_instance_id()] = other_body.linear_velocity
	source_body.sleeping = false
	other_body.sleeping = false

	var tangent_velocity: Vector3 = source_tangent_velocity - other_tangent_velocity
	if tangent_velocity.length_squared() > 0.0001 and marble_collision_spin_transfer > 0.0:
		var spin_axis: Vector3 = Vector3.UP.cross(collision_axis).normalized()
		var spin_amount: float = tangent_velocity.length() * marble_collision_spin_transfer
		source_body.angular_velocity -= spin_axis * spin_amount
		other_body.angular_velocity += spin_axis * spin_amount


func _clamp_marble_upward_velocity(marble: Node3D) -> void:
	var body := marble as RigidBody3D
	if body == null:
		return
	if body.linear_velocity.y > marble_max_upward_velocity:
		var clamped_velocity := body.linear_velocity
		clamped_velocity.y = marble_max_upward_velocity
		body.linear_velocity = clamped_velocity


func _load_audio_stream(path: String) -> AudioStream:
	var loaded_stream := load(path) as AudioStream
	if loaded_stream != null:
		return loaded_stream

	if path.get_extension().to_lower() == "mp3":
		var audio_bytes := FileAccess.get_file_as_bytes(path)
		if audio_bytes.is_empty():
			return null
		var mp3_stream := AudioStreamMP3.new()
		mp3_stream.data = audio_bytes
		return mp3_stream

	return null


func _get_sfx_bus_name() -> String:
	return "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"


func _classify_surface_contact(other_body: Node) -> String:
	if other_body == null:
		return "surface"

	var node_name := String(other_body.name).to_lower()
	if node_name.contains("hole") or node_name.contains("trap"):
		return "hole"
	if node_name.contains("wall"):
		return "wall"
	if node_name.contains("ground") or node_name.contains("grass") or node_name.contains("field"):
		return "grass"
	if other_body.is_in_group("Walls"):
		return "wall"
	return "surface"


func _get_contact_sound_position(source_body: RigidBody3D, other_body: Node) -> Vector3:
	if other_body is Node3D:
		return source_body.global_position.lerp((other_body as Node3D).global_position, 0.35)
	return source_body.global_position


func _checkout_impact_audio_player() -> AudioStreamPlayer3D:
	var player := impact_audio_players[impact_audio_index % impact_audio_players.size()]
	impact_audio_index += 1
	return player


func _get_impact_pair_key(a: Node, b: Node) -> String:
	var a_id := str(a.get_instance_id())
	var b_id := str(b.get_instance_id())
	return "%s:%s" % [a_id, b_id] if a_id < b_id else "%s:%s" % [b_id, a_id]


func _connect_hole_signals_deferred() -> void:
	if hole == null:
		return

	var trap_area: Area3D = hole.get_node_or_null("TrapArea") as Area3D
	if trap_area == null:
		return

	if not trap_area.body_entered.is_connected(_on_hole_trap_body_entered):
		trap_area.body_entered.connect(_on_hole_trap_body_entered)


func _on_hole_trap_body_entered(body: Node) -> void:
	if body == null or not (body is Node3D):
		return

	var marble: Node3D = body as Node3D
	if not active_marbles.has(marble):
		return
	if not _marble_is_committed_to_hole(marble):
		return

	_mark_marble_hole_entry(marble)


func _mark_marble_hole_entry(marble: Node3D) -> void:
	if marble == null or not active_marbles.has(marble):
		return

	var first_entry_this_shot: bool = not hole_entry_order_this_shot.has(marble)
	if first_entry_this_shot:
		hole_entry_order_this_shot.append(marble)
	if game_phase == GAME_PHASE_LINEUP and current_action_mode == ACTION_MODE_LINEUP and not lineup_hole_entrants_this_round.has(marble):
		lineup_hole_entrants_this_round.append(marble)

	if current_actor == null or marble != current_actor:
		return

	if current_action_mode == ACTION_MODE_ATTACK and current_shot_started_in_hole and not current_shot_left_hole:
		current_hole_owner = marble
		return

	current_shot_entered_hole = true
	current_hole_owner = marble
	if first_entry_this_shot:
		_spawn_hole_sink_reward(marble)
	if marble == player_marble:
		player_entered_hole_this_match = true


func _track_current_actor_hole_entry() -> void:
	if current_actor == null or not active_marbles.has(current_actor):
		return
	var actor_in_hole: bool = _is_marble_in_hole(current_actor)
	if current_action_mode == ACTION_MODE_ATTACK and current_shot_started_in_hole and not current_shot_left_hole:
		if not actor_in_hole and not _marble_is_in_hole_entry_area(current_actor):
			current_shot_left_hole = true
	if actor_in_hole:
		_mark_marble_hole_entry(current_actor)


func _begin_hole_attack_level(marble: Node3D) -> void:
	if marble == null or hole == null:
		return
	if not _is_marble_in_hole(marble):
		return
	_set_hole_attack_level_enabled(true)
	_lift_marble_to_hole_attack_level(marble)


func _end_hole_attack_level() -> void:
	_set_hole_attack_level_enabled(false)


func _set_hole_attack_level_enabled(enabled: bool) -> void:
	hole_attack_level_active = enabled
	if hole != null and hole.has_method("set_attack_exit_level_enabled"):
		hole.call("set_attack_exit_level_enabled", enabled)


func _lift_marble_to_hole_attack_level(marble: Node3D) -> void:
	if marble == null or hole == null:
		return

	var local_position: Vector3 = hole.to_local(marble.global_position)
	var marble_radius: float = _get_marble_collision_radius(marble)
	var pocket_radius_value: float = float(hole.get("pocket_radius")) if hole.get("pocket_radius") != null else 1.0
	var max_planar_radius: float = maxf(pocket_radius_value, marble_radius * 2.5)
	var planar := Vector2(local_position.x, local_position.z)
	if planar.length() > max_planar_radius:
		planar = planar.normalized() * max_planar_radius
	local_position.x = planar.x
	local_position.z = planar.y
	local_position.y = marble_radius + 0.045

	_reset_marble_motion(marble, hole.to_global(local_position))


func _advance_turn_order() -> void:
	if turn_order.is_empty():
		current_marble_index = 0
		return

	var active_hole_owner: Node3D = _enforce_single_hole_occupant(current_hole_owner)
	if active_hole_owner != null and active_marbles.has(active_hole_owner) and _is_marble_in_hole(active_hole_owner):
		var active_hole_owner_index: int = turn_order.find(active_hole_owner)
		if active_hole_owner_index != -1:
			current_marble_index = active_hole_owner_index
			pending_hole_turn_marble = null
			return

	if pending_hole_turn_marble != null and active_marbles.has(pending_hole_turn_marble) and _is_marble_in_hole(pending_hole_turn_marble):
		var pending_index: int = turn_order.find(pending_hole_turn_marble)
		if pending_index != -1:
			current_marble_index = pending_index
			pending_hole_turn_marble = null
			return
	pending_hole_turn_marble = null

	current_marble_index = (current_marble_index + 1) % turn_order.size()
	var attempts: int = 0
	while attempts < turn_order.size() and not active_marbles.has(turn_order[current_marble_index]):
		current_marble_index = (current_marble_index + 1) % turn_order.size()
		attempts += 1


func _get_current_turn_marble() -> Node3D:
	if turn_order.is_empty() or current_marble_index < 0 or current_marble_index >= turn_order.size():
		return null
	return turn_order[current_marble_index]


func _find_marble_by_name(marble_name: String) -> Node3D:
	if marble_name == "":
		return null
	for marble in marbles:
		if marble != null and String(marble.name) == marble_name:
			return marble
	for marble in active_marbles:
		if marble != null and String(marble.name) == marble_name:
			return marble
	for marble in _discover_scene_marbles():
		if marble != null and String(marble.name) == marble_name:
			return marble
	return null


func _is_network_remote_player_marble(marble: Node3D) -> bool:
	if marble == null:
		return false
	if online_enabled:
		if _is_online_ai_marble(marble):
			return false
		if _get_online_client_id_for_marble(marble) != "":
			return true
		return _is_online_reserved_remote_human_marble(marble)
	if not lan_remote_player_connected:
		return false
	return marble == lan_remote_player_marble


func _is_online_ai_marble(marble: Node3D) -> bool:
	if marble == null or not online_enabled:
		return false
	_build_online_player_assignments()
	var marble_name: String = String(marble.name)
	if online_client_id_by_marble_name.has(marble_name):
		return false
	for client_id_variant in online_marble_name_by_client_id.keys():
		if str(online_marble_name_by_client_id.get(client_id_variant, "")) == marble_name:
			return false
	var human_count: int = _get_online_human_players_snapshot().size()
	return _get_online_ai_marble_names(human_count).has(marble_name)


func _is_online_reserved_remote_human_marble(marble: Node3D) -> bool:
	if marble == null or not online_enabled or marble == player_marble:
		return false
	var player_index: int = _get_online_player_index_for_marble_name(String(marble.name))
	return player_index > 0 and player_index < _get_online_human_slot_count()


func _get_online_client_id_for_marble(marble: Node3D) -> String:
	if marble == null:
		return ""
	_build_online_player_assignments()
	var marble_name: String = String(marble.name)
	var direct_client_id: String = str(online_client_id_by_marble_name.get(marble_name, ""))
	if direct_client_id != "":
		return direct_client_id
	for client_id_variant in online_marble_name_by_client_id.keys():
		var client_id: String = str(client_id_variant)
		if client_id == "" or client_id == online_local_client_id:
			continue
		if str(online_marble_name_by_client_id.get(client_id_variant, "")) == marble_name:
			online_client_id_by_marble_name[marble_name] = client_id
			return client_id
	var player_index: int = _get_online_player_index_for_marble_name(marble_name)
	var players: Array = _get_online_human_players_snapshot()
	if player_index >= 0 and player_index < players.size() and typeof(players[player_index]) == TYPE_DICTIONARY:
		var player_data: Dictionary = players[player_index] as Dictionary
		var inferred_client_id: String = str(player_data.get("id", ""))
		if inferred_client_id != "" and inferred_client_id != online_local_client_id:
			_set_online_player_marble_assignment(inferred_client_id, marble_name)
			return inferred_client_id
	return ""


func _online_remote_turn_message_is_for_local_client(payload: Dictionary, target_id: String) -> bool:
	if not online_enabled:
		return true
	if target_id != "":
		return target_id == online_local_client_id
	var intended_client_id: String = str(payload.get("client_id", payload.get("target_client_id", ""))).strip_edges()
	if intended_client_id != "":
		return intended_client_id == online_local_client_id
	var active_marble_name: String = str(payload.get("active_marble_name", "")).strip_edges()
	var local_marble: Node3D = _get_network_input_marble()
	if active_marble_name != "" and local_marble != null:
		return active_marble_name == String(local_marble.name)
	return true


func _resolve_online_sender_marble(sender_key: String, claimed_marble_name: String = "") -> Node3D:
	var marble: Node3D = _get_or_assign_online_player_marble(sender_key)
	var clean_claim: String = claimed_marble_name.strip_edges()
	if clean_claim == "":
		return marble

	var claimed_marble: Node3D = _find_marble_by_name(clean_claim)
	if claimed_marble == null:
		return marble

	var claimed_owner: String = str(online_client_id_by_marble_name.get(clean_claim, ""))
	if claimed_owner != "" and claimed_owner != sender_key:
		return marble

	_set_online_player_marble_assignment(sender_key, clean_claim)
	return claimed_marble


func _set_online_player_marble_assignment(client_id: String, marble_name: String) -> void:
	if client_id == "" or marble_name == "":
		return
	var previous_marble_name: String = str(online_marble_name_by_client_id.get(client_id, ""))
	if previous_marble_name != "" and str(online_client_id_by_marble_name.get(previous_marble_name, "")) == client_id:
		online_client_id_by_marble_name.erase(previous_marble_name)
	online_marble_name_by_client_id[client_id] = marble_name
	if client_id != online_local_client_id:
		online_client_id_by_marble_name[marble_name] = client_id
		online_fallback_marble_name_by_client_id[client_id] = marble_name


func _get_lan_local_player_marble() -> Node3D:
	if online_enabled:
		return player_marble if lan_is_host else online_local_player_marble
	if not lan_enabled:
		return player_marble
	return player_marble if lan_is_host else lan_remote_player_marble


func _is_local_reward_marble(marble: Node3D) -> bool:
	if marble == null:
		return false
	var local_marble: Node3D = _get_lan_local_player_marble()
	return local_marble != null and marble == local_marble


func did_local_player_win(winner_name: String) -> bool:
	var local_marble: Node3D = _get_lan_local_player_marble()
	if local_marble == null:
		return false
	return _display_name_for_marble(local_marble) == winner_name


func _get_lan_remote_peer_id() -> int:
	if lan != null and lan.has_method("get_remote_game_peer_id"):
		return int(lan.call("get_remote_game_peer_id"))
	for peer_id in multiplayer.get_peers():
		if int(peer_id) != 1:
			return int(peer_id)
	return 0


func _get_lan_host_peer_id() -> int:
	if lan != null and lan.has_method("get_room_host_peer_id"):
		return int(lan.call("get_room_host_peer_id"))
	return 1


func _is_lan_remote_sender(peer_id: int) -> bool:
	var expected_peer_id: int = _get_lan_remote_peer_id()
	if expected_peer_id > 0:
		return peer_id == expected_peer_id
	return peer_id != 0 and peer_id != 1


func _eliminate_marble(target: Node3D, attacker: Node3D) -> void:
	if target == null or not active_marbles.has(target):
		return
	var target_is_player: bool = _is_local_reward_marble(target)
	var target_name: String = _display_name_for_marble(target)
	var target_marble_name: String = String(target.name)
	var target_client_id: String = _get_online_client_id_for_result_marble(target)
	var attacker_name: String = _display_name_for_marble(attacker) if attacker != null else "AI"
	var attacker_marble_name: String = String(attacker.name) if attacker != null else ""
	if attacker != null:
		var attacker_key: String = String(attacker.name)
		elimination_counts_by_marble_name[attacker_key] = int(elimination_counts_by_marble_name.get(attacker_key, 0)) + 1
	if _is_local_reward_marble(attacker):
		player_eliminations_this_match += 1
		var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
		if currency_manager != null and currency_manager.has_method("add_coins"):
			currency_manager.call("add_coins", maxi(elimination_coin_reward, 0))

	var removed_index: int = turn_order.find(target)
	if removed_index != -1:
		turn_order.remove_at(removed_index)
		if removed_index < current_marble_index:
			current_marble_index -= 1
		elif current_marble_index >= turn_order.size():
			current_marble_index = 0

	active_marbles.erase(target)
	marbles.erase(target)
	ai_hole_attack_attempts.erase(target.name)
	if current_hole_owner == target:
		current_hole_owner = null
	if pending_hole_turn_marble == target:
		pending_hole_turn_marble = null
	marble_eliminated.emit(target_name)
	if online_enabled and lan_is_host:
		var elimination_payload: Dictionary = {
			"target_name": target_name,
			"target_marble_name": target_marble_name,
			"target_client_id": target_client_id,
			"attacker_name": attacker_name,
			"attacker_marble_name": attacker_marble_name
		}
		_send_online_game_message("marble_eliminated", elimination_payload)
		if target_client_id != "" and target_client_id != online_local_client_id:
			_send_online_game_message("player_disqualified", elimination_payload, target_client_id)
	if target_is_player and not _is_local_reward_marble(attacker):
		player_disqualified.emit(attacker_name)
	_disable_marble(target)
	_emit_scoreboard()


func _disable_marble(marble: Node3D) -> void:
	if marble == null:
		return

	if marble.has_method("end_turn"):
		marble.end_turn()
	elif marble.has_method("set_turn"):
		marble.set_turn(false, null)

	marble.visible = false
	marble.global_position = Vector3(0.0, -50.0, 0.0)

	if marble is RigidBody3D:
		var body: RigidBody3D = marble as RigidBody3D
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		body.sleeping = true
		body.freeze = true
		body.collision_layer = 0
		body.collision_mask = 0

	_clear_trail_for_marble(marble)
	_set_collision_disabled_recursive(marble, true)
	marble.queue_free()


func _set_collision_disabled_recursive(node: Node, disabled: bool) -> void:
	for child in node.get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).disabled = disabled
		_set_collision_disabled_recursive(child, disabled)


func _enforce_single_hole_occupant(preferred_owner: Node3D = null) -> Node3D:
	var in_hole: Array[Node3D] = _collect_in_hole_marbles(active_marbles)
	if in_hole.is_empty():
		current_hole_owner = null
		return null

	var owner: Node3D = null
	if preferred_owner != null and in_hole.has(preferred_owner):
		owner = preferred_owner
	elif current_hole_owner != null and in_hole.has(current_hole_owner):
		owner = current_hole_owner
	else:
		for entrant in hole_entry_order_this_shot:
			if entrant != null and in_hole.has(entrant):
				owner = entrant
				break

	if owner == null:
		owner = in_hole[0]
	current_hole_owner = owner

	for marble in in_hole:
		if marble == null or marble == owner:
			continue
		_move_extra_hole_marble_out(marble, owner)

	return owner


func _move_extra_hole_marble_out(marble: Node3D, owner: Node3D) -> void:
	if marble == null or not active_marbles.has(marble):
		return

	var respawn_position: Vector3 = _find_hole_overflow_respawn_position(marble)
	_reset_marble_motion(marble, respawn_position)
	if pending_hole_turn_marble == marble:
		pending_hole_turn_marble = null


func _find_hole_overflow_respawn_position(marble: Node3D) -> Vector3:
	var respawn_position: Vector3 = _find_respawn_position(marble)
	if hole == null:
		return respawn_position

	var pocket_radius: float = float(hole.get("pocket_radius")) if hole.get("pocket_radius") != null else 1.0
	var minimum_distance: float = pocket_radius + hole_occupant_respawn_clearance
	if _planar_distance(respawn_position, hole.global_position) >= minimum_distance:
		return respawn_position

	var exit_direction: Vector3 = _planar_direction_to(hole.global_position, respawn_position)
	if exit_direction.length_squared() <= 0.0001:
		exit_direction = Vector3.BACK
	return hole.global_position + exit_direction * minimum_distance + Vector3.UP * respawn_height_above_ground


func _collect_in_hole_marbles(candidates: Array[Node3D]) -> Array[Node3D]:
	var in_hole: Array[Node3D] = []
	for marble in candidates:
		if marble != null and _is_marble_in_hole(marble):
			in_hole.append(marble)
	return in_hole


func _collect_lineup_hole_entrants(candidates: Array) -> Array[Node3D]:
	var contenders: Array[Node3D] = _filter_active_lineup_contenders(candidates)
	var entrants: Array[Node3D] = []
	for candidate in lineup_hole_entrants_this_round:
		var marble := candidate as Node3D
		if marble != null and contenders.has(marble) and not entrants.has(marble):
			entrants.append(marble)
	for marble in _collect_in_hole_marbles(contenders):
		if not entrants.has(marble):
			entrants.append(marble)
	return entrants


func _sort_marbles_by_lineup_distance(a: Node3D, b: Node3D) -> bool:
	var a_in_hole: bool = _is_marble_in_hole(a)
	var b_in_hole: bool = _is_marble_in_hole(b)
	if a_in_hole != b_in_hole:
		return a_in_hole and not b_in_hole

	var a_distance: float = _distance_to_hole(a)
	var b_distance: float = _distance_to_hole(b)
	if absf(a_distance - b_distance) > 0.001:
		return a_distance < b_distance

	return marbles.find(a) < marbles.find(b)


func _distance_to_hole(marble: Node3D) -> float:
	if marble == null or hole == null:
		return INF
	if _is_marble_in_hole(marble):
		return 0.0
	return _planar_distance(marble.global_position, hole.global_position)


func _is_marble_in_hole(marble: Node3D) -> bool:
	return _marble_has_reached_hole_bottom(marble) or _marble_is_committed_to_hole(marble)


func _marble_is_committed_to_hole(marble: Node3D) -> bool:
	if marble == null or hole == null:
		return false
	if _marble_has_reached_hole_bottom(marble):
		return true

	var local_position: Vector3 = hole.to_local(marble.global_position)
	var pocket_radius: float = float(hole.get("pocket_radius")) if hole.get("pocket_radius") != null else 1.0
	var entry_radius: float = float(hole.get("entry_radius")) if hole.get("entry_radius") != null else pocket_radius * 1.45
	var depth: float = float(hole.get("depth")) if hole.get("depth") != null else 1.0
	var marble_radius: float = _get_marble_collision_radius(marble)
	var planar_distance: float = Vector2(local_position.x, local_position.z).length()
	var committed_y: float = -depth * 0.18
	var committed_radius: float = minf(entry_radius * 0.78, maxf(pocket_radius * 1.16, marble_radius * 2.8))

	return local_position.y <= committed_y and local_position.y >= -depth - marble_radius * 2.0 and planar_distance <= committed_radius


func _marble_is_in_hole_entry_area(marble: Node3D) -> bool:
	if marble == null or hole == null:
		return false

	var local_position: Vector3 = hole.to_local(marble.global_position)
	var entry_radius: float = float(hole.get("entry_radius")) if hole.get("entry_radius") != null else 1.5
	var depth: float = float(hole.get("depth")) if hole.get("depth") != null else 1.0
	var marble_radius: float = _get_marble_collision_radius(marble)
	var planar_distance: float = Vector2(local_position.x, local_position.z).length()

	return local_position.y <= 0.04 and local_position.y >= -depth - marble_radius * 2.0 and planar_distance <= entry_radius * 0.95


func _marble_has_reached_hole_bottom(marble: Node3D) -> bool:
	if marble == null or hole == null:
		return false

	var local_position: Vector3 = hole.to_local(marble.global_position)
	var pocket_radius: float = float(hole.get("pocket_radius")) if hole.get("pocket_radius") != null else 1.0
	var hole_depth: float = float(hole.get("depth")) if hole.get("depth") != null else 1.0
	var bottom_stop_lift: float = float(hole.get("bottom_stop_lift")) if hole.get("bottom_stop_lift") != null else 0.08
	var bottom_stop_height: float = float(hole.get("bottom_stop_height")) if hole.get("bottom_stop_height") != null else 0.18
	var marble_radius: float = _get_marble_collision_radius(marble)
	var bottom_touch_y: float = -hole_depth + bottom_stop_lift + bottom_stop_height + marble_radius * 1.15
	var lowest_valid_y: float = -hole_depth - marble_radius * 1.2
	var planar_distance: float = Vector2(local_position.x, local_position.z).length()
	return planar_distance <= pocket_radius * 0.88 and local_position.y <= bottom_touch_y and local_position.y >= lowest_valid_y


func _keep_marble_above_hole_floor(marble: Node3D) -> void:
	if marble == null or hole == null:
		return

	var body: RigidBody3D = marble as RigidBody3D
	if body == null:
		return

	var local_position: Vector3 = hole.to_local(marble.global_position)
	var pocket_radius: float = float(hole.get("pocket_radius")) if hole.get("pocket_radius") != null else 1.0
	var hole_depth: float = float(hole.get("depth")) if hole.get("depth") != null else 1.0
	var bottom_stop_lift: float = float(hole.get("bottom_stop_lift")) if hole.get("bottom_stop_lift") != null else 0.08
	var bottom_stop_height: float = float(hole.get("bottom_stop_height")) if hole.get("bottom_stop_height") != null else 0.18
	var marble_radius: float = _get_marble_collision_radius(marble)
	var planar_distance: float = Vector2(local_position.x, local_position.z).length()
	var floor_y: float = -hole_depth + bottom_stop_lift + bottom_stop_height * 0.5 + marble_radius + 0.035

	if planar_distance > pocket_radius * 1.05 or local_position.y >= floor_y:
		return

	local_position.y = floor_y
	body.global_transform = Transform3D(body.global_transform.basis, hole.to_global(local_position))
	if body.linear_velocity.y < 0.0:
		var velocity: Vector3 = body.linear_velocity
		velocity.y = 0.0
		body.linear_velocity = velocity
	body.sleeping = false


func _assist_marble_into_hole(marble: Node3D) -> void:
	if marble == null or hole == null or hole_attack_level_active:
		return

	var body: RigidBody3D = marble as RigidBody3D
	if body == null:
		return

	if _marble_has_reached_hole_bottom(marble):
		return

	var local_position: Vector3 = hole.to_local(marble.global_position)
	var pocket_radius: float = float(hole.get("pocket_radius")) if hole.get("pocket_radius") != null else 1.0
	var hole_depth: float = float(hole.get("depth")) if hole.get("depth") != null else 1.0
	var bottom_stop_lift: float = float(hole.get("bottom_stop_lift")) if hole.get("bottom_stop_lift") != null else 0.08
	var bottom_stop_height: float = float(hole.get("bottom_stop_height")) if hole.get("bottom_stop_height") != null else 0.18
	var marble_radius: float = _get_marble_collision_radius(marble)
	var bottom_touch_y: float = -hole_depth + bottom_stop_lift + bottom_stop_height + marble_radius * 1.15
	var planar := Vector2(local_position.x, local_position.z)
	var planar_distance: float = planar.length()
	if planar_distance > pocket_radius * 0.96 or local_position.y > 0.12 or local_position.y <= bottom_touch_y:
		return

	var planar_velocity := Vector2(body.linear_velocity.x, body.linear_velocity.z)
	if planar_velocity.length() > 1.35 or body.linear_velocity.y > 0.7:
		return

	var depth_ratio: float = clampf(inverse_lerp(0.12, bottom_touch_y, local_position.y), 0.0, 1.0)
	var center_force: Vector3 = Vector3.ZERO
	if planar_distance > 0.025:
		var center_direction_local := Vector3(-local_position.x, 0.0, -local_position.z).normalized()
		center_force = (hole.global_transform.basis * center_direction_local).normalized() * hole_capture_centering_force
	var down_force: Vector3 = Vector3.DOWN * lerpf(hole_capture_assist_force * 0.45, hole_capture_assist_force, depth_ratio)
	body.apply_central_force((center_force + down_force) * body.mass)
	body.sleeping = false


func _get_marble_hole_depth_ratio(marble: Node3D) -> float:
	if marble == null or hole == null:
		return 0.0

	var local_position: Vector3 = hole.to_local(marble.global_position)
	var hole_depth: float = float(hole.get("depth")) if hole.get("depth") != null else 1.0
	var bottom_stop_lift: float = float(hole.get("bottom_stop_lift")) if hole.get("bottom_stop_lift") != null else 0.08
	var bottom_stop_height: float = float(hole.get("bottom_stop_height")) if hole.get("bottom_stop_height") != null else 0.18
	var marble_radius: float = _get_marble_collision_radius(marble)
	var bottom_touch_y: float = -hole_depth + bottom_stop_lift + bottom_stop_height + marble_radius * 1.15
	var deepest_playable_y: float = -hole_depth + bottom_stop_lift + bottom_stop_height * 0.45 + marble_radius * 0.75
	return clampf(inverse_lerp(bottom_touch_y, deepest_playable_y, local_position.y), 0.0, 1.0)


func _get_marble_collision_radius(marble: Node3D) -> float:
	if marble == null:
		return 0.2
	var collision: CollisionShape3D = marble.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision != null and collision.shape is SphereShape3D:
		return maxf((collision.shape as SphereShape3D).radius, 0.05)
	return 0.2


func _place_marbles_on_lineup(candidates: Array[Node3D]) -> void:
	if candidates.is_empty():
		return

	var count: int = candidates.size()
	for index in range(count):
		var marble: Node3D = candidates[index]
		if marble == null:
			continue

		_reset_marble_motion(marble, _get_lineup_position(candidates, index))


func _get_lineup_position(candidates: Array[Node3D], index: int) -> Vector3:
	var lineup_center: Vector3 = _get_lineup_center_anchor()
	var target_position: Vector3 = hole.global_position if hole != null else lineup_center + Vector3.FORWARD
	var hole_direction: Vector3 = _planar_direction_to(lineup_center, target_position)
	var sideways: Vector3 = Vector3(-hole_direction.z, 0.0, hole_direction.x).normalized()
	if sideways.length_squared() <= 0.0001:
		sideways = Vector3.RIGHT

	var centered_index: float = float(index) - float(candidates.size() - 1) * 0.5
	return lineup_center + sideways * centered_index * lineup_side_spacing


func _reset_marble_motion(marble: Node3D, target_position: Vector3) -> void:
	if marble == null:
		return

	if marble is RigidBody3D:
		var body: RigidBody3D = marble as RigidBody3D
		body.freeze = false
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		body.sleeping = false
		body.global_position = target_position
		body.global_basis = Basis.IDENTITY
	else:
		marble.global_position = target_position
		marble.global_basis = Basis.IDENTITY


func _get_lineup_anchor() -> Vector3:
	var candidates: Array[Vector3] = _build_respawn_candidates()
	if candidates.is_empty():
		return _fallback_respawn_position()

	var hole_position: Vector3 = hole.global_position if hole != null else Vector3.ZERO
	var best_candidate: Vector3 = candidates[0]
	var best_distance_sq: float = - INF

	for candidate in candidates:
		var distance_sq: float = candidate.distance_squared_to(hole_position)
		if distance_sq > best_distance_sq:
			best_distance_sq = distance_sq
			best_candidate = candidate

	return best_candidate


func _get_lineup_center_anchor() -> Vector3:
	var center_anchor: Vector3 = lineup_anchor
	if hole == null:
		return center_anchor

	var hole_offset: Vector3 = hole.global_position - lineup_anchor
	if absf(hole_offset.z) >= absf(hole_offset.x):
		center_anchor.x = hole.global_position.x
	else:
		center_anchor.z = hole.global_position.z

	return center_anchor


func _force_start_camera() -> void:
	var start_marble: Node3D = active_marbles[0] if not active_marbles.is_empty() else player_marble
	_disable_all_cameras()

	var cam: Camera3D = _get_marble_camera(start_marble)
	if cam == null:
		push_warning("Starting marble has no Camera3D child.")
		return

	cam.current = true
	cam.make_current()


func _activate_camera_for(marble: Node) -> void:
	if marble == null:
		return

	var cam: Camera3D = _get_marble_camera(marble)
	if cam == null:
		push_warning("No Camera3D found under %s" % str(marble.name))
		return

	var previous_camera: Camera3D = _get_current_camera()
	var rig: Node = cam.get_parent()
	var transition_origin: Camera3D = previous_camera if previous_camera != cam else null

	if rig and rig.has_method("begin_turn_transition"):
		rig.begin_turn_transition(transition_origin)
	elif transition_origin:
		if rig and rig.has_method("snap_to_camera"):
			rig.snap_to_camera(transition_origin)
		elif rig is Node3D:
			(rig as Node3D).global_transform = transition_origin.global_transform

	_disable_all_cameras()
	cam.current = true
	cam.make_current()

	if wait_for_camera_transition_before_turn and rig and rig.has_method("is_turn_transition_finished"):
		await _wait_for_camera_transition(rig)
	elif wait_for_camera_transition_before_turn and camera_ready_delay > 0.0:
		await _wait_seconds(camera_ready_delay)


func _wait_for_camera_transition(rig: Node) -> void:
	var elapsed: float = 0.0

	while elapsed < camera_transition_timeout:
		if rig.has_method("is_turn_transition_finished") and rig.is_turn_transition_finished():
			if camera_ready_delay > 0.0:
				await _wait_seconds(camera_ready_delay)
			return

		if not await _await_next_frame():
			return
		elapsed += get_process_delta_time()

	push_warning("Camera transition timed out. Continuing turn flow.")
	if camera_ready_delay > 0.0:
		await _wait_seconds(camera_ready_delay)


func _disable_all_cameras() -> void:
	for marble in marbles:
		var cam: Camera3D = _get_marble_camera(marble)
		if cam != null:
			cam.current = false


func _get_current_camera() -> Camera3D:
	for marble in marbles:
		var cam: Camera3D = _get_marble_camera(marble)
		if cam != null and cam.current:
			return cam
	return get_viewport().get_camera_3d()


func _get_marble_camera(marble: Node) -> Camera3D:
	if marble == null:
		return null

	if marble.has_node("CameraRig/FollowCamera"):
		return marble.get_node("CameraRig/FollowCamera") as Camera3D

	if marble.has_node("CameraRig/Camera3D"):
		return marble.get_node("CameraRig/Camera3D") as Camera3D

	return _find_camera_recursive(marble)


func _find_camera_recursive(node: Node) -> Camera3D:
	for child in node.get_children():
		if child is Camera3D:
			return child as Camera3D

		var nested: Camera3D = _find_camera_recursive(child)
		if nested != null:
			return nested

	return null


func _await_next_frame() -> bool:
	if not is_inside_tree():
		return false

	var tree: SceneTree = get_tree()
	if tree == null:
		return false

	await tree.process_frame
	return is_inside_tree() and get_tree() != null


func _should_respawn_marble(marble: Node3D) -> bool:
	if marble == null or not active_marbles.has(marble):
		return false
	if _is_marble_in_hole(marble):
		return false
	return marble.global_position.y < out_of_bounds_fall_y


func _respawn_marble(marble: Node3D) -> void:
	var respawn_position: Vector3 = _find_respawn_position(marble)
	_reset_marble_motion(marble, respawn_position)


func _cache_respawn_surfaces() -> void:
	respawn_surfaces.clear()

	var scene_root: Node = get_parent()
	if scene_root == null:
		return

	var ground: Node = scene_root.get_node_or_null("Ground")
	if ground == null:
		return

	for child in ground.get_children():
		if child is CollisionShape3D and not (child as CollisionShape3D).disabled and (child as CollisionShape3D).shape is BoxShape3D:
			respawn_surfaces.append(child as CollisionShape3D)


func _find_respawn_position(fallen_marble: Node3D) -> Vector3:
	var candidates: Array[Vector3] = _build_respawn_candidates()
	if candidates.is_empty():
		return _fallback_respawn_position()

	var hole_position: Vector3 = hole.global_position if hole != null else Vector3.ZERO
	var best_candidate: Vector3 = candidates[0]
	var best_distance_sq: float = - INF

	for candidate in candidates:
		var distance_sq: float = candidate.distance_squared_to(hole_position)
		if not _candidate_is_clear(candidate, fallen_marble):
			distance_sq -= 1000.0
		if distance_sq > best_distance_sq:
			best_distance_sq = distance_sq
			best_candidate = candidate

	return best_candidate


func _build_respawn_candidates() -> Array[Vector3]:
	var candidates: Array[Vector3] = []

	for surface in respawn_surfaces:
		if surface == null:
			continue

		var shape: BoxShape3D = surface.shape as BoxShape3D
		if shape == null:
			continue

		var half_size: Vector3 = shape.size * 0.5
		var usable_x: float = maxf(half_size.x - respawn_edge_margin, 0.0)
		var usable_z: float = maxf(half_size.z - respawn_edge_margin, 0.0)
		var top_y: float = half_size.y + respawn_height_above_ground
		var local_points: Array[Vector3] = [
			Vector3(-usable_x, top_y, -usable_z),
			Vector3(usable_x, top_y, -usable_z),
			Vector3(-usable_x, top_y, usable_z),
			Vector3(usable_x, top_y, usable_z),
			Vector3(0.0, top_y, -usable_z),
			Vector3(0.0, top_y, usable_z),
			Vector3(-usable_x, top_y, 0.0),
			Vector3(usable_x, top_y, 0.0),
			Vector3(0.0, top_y, 0.0)
		]

		for local_point in local_points:
			candidates.append(surface.global_transform * local_point)

	return candidates


func _candidate_is_clear(candidate: Vector3, fallen_marble: Node3D) -> bool:
	for marble in active_marbles:
		if marble == null or marble == fallen_marble:
			continue

		var planar_distance: float = Vector2(candidate.x, candidate.z).distance_to(Vector2(marble.global_position.x, marble.global_position.z))
		if planar_distance < respawn_marble_clearance:
			return false

	return true


func _fallback_respawn_position() -> Vector3:
	var hole_position: Vector3 = hole.global_position if hole != null else Vector3.ZERO
	return hole_position + Vector3(-8.0, 0.6, -32.0)


func _initialize_scoreboard() -> void:
	stroke_counts.clear()
	elimination_counts_by_marble_name.clear()
	for marble in marbles:
		if marble == null:
			continue
		stroke_counts[marble.name] = 0
		elimination_counts_by_marble_name[marble.name] = 0


func _register_shot(marble: Node3D) -> void:
	if marble == null:
		return
	if not stroke_counts.has(marble.name):
		stroke_counts[marble.name] = 0
	stroke_counts[marble.name] = int(stroke_counts[marble.name]) + 1
	if marble is RigidBody3D:
		_play_shot_whoosh(marble as RigidBody3D)
	_emit_scoreboard()


func _emit_turn_state(override_marble: Node3D = null) -> void:
	var marble: Node3D = override_marble if override_marble != null else _get_current_turn_marble()
	if marble == null:
		return

	var display_name: String = _turn_display_name_for_marble(marble)
	var active_index: int = turn_order.find(marble)
	if active_index < 0:
		active_index = 0
	turn_changed.emit(display_name, active_index)
	if lan_enabled and lan_is_host:
		if online_enabled:
			_send_online_game_message("turn_state", {
				"display_name": display_name,
				"active_index": active_index,
				"active_marble_name": String(marble.name),
				"phase": game_phase
			})
		else:
			var remote_peer_id: int = _get_lan_remote_peer_id()
			if remote_peer_id > 0:
				_lan_receive_turn_state.rpc_id(remote_peer_id, display_name, active_index, String(marble.name), game_phase)
	_emit_scoreboard()


func _turn_display_name_for_marble(marble: Node3D) -> String:
	var display_name: String = _display_name_for_marble(marble)
	if game_phase == GAME_PHASE_LINEUP:
		return "LINEUP %s" % display_name
	if game_phase == GAME_PHASE_FINISHED:
		return "%s WINS" % display_name
	if _is_marble_in_hole(marble):
		return "%s ATTACK" % display_name
	return display_name


func _emit_scoreboard() -> void:
	var entries: Array = []
	for marble in turn_order:
		if marble == null or not active_marbles.has(marble):
			continue
		entries.append({
			"name": _display_name_for_marble(marble),
			"strokes": int(stroke_counts.get(marble.name, 0)),
			"is_active": marble == _get_current_turn_marble()
		})
	scoreboard_updated.emit(entries)
	if lan_enabled and lan_is_host:
		if online_enabled:
			_send_online_game_message("scoreboard", {"entries": entries})
		else:
			var remote_peer_id: int = _get_lan_remote_peer_id()
			if remote_peer_id > 0:
				_lan_receive_scoreboard.rpc_id(remote_peer_id, entries)


@rpc("authority", "call_remote", "reliable")
func _lan_receive_turn_state(display_name: String, active_index: int, active_marble_name: String, phase: int) -> void:
	if not lan_enabled or lan_is_host:
		return
	var local_marble: Node3D = _get_network_input_marble()
	var local_turn_still_active: bool = false
	if online_enabled and lan_client_remote_turn_input_enabled and local_marble != null:
		local_turn_still_active = active_marble_name == String(local_marble.name) and lan_client_active_marble_name == active_marble_name and phase != GAME_PHASE_FINISHED
	if not local_turn_still_active:
		lan_client_remote_turn_input_enabled = false
	if lan_client_active_marble_name != active_marble_name:
		lan_dragging = false
		lan_drag_touch_index = -1
		lan_drag_aim = Vector3.ZERO
		lan_drag_force = 0.0
		lan_drag_power_ratio = 0.0
		lan_drag_smoothed_vector = Vector2.ZERO
		lan_drag_has_smoothed_vector = false
		lan_last_aim_send_msec = 0
		_update_lan_power_meter(0.0, false)
		_reset_lan_drag_reference_axes()
	if phase == GAME_PHASE_FINISHED:
		_stop_online_local_prediction()
	elif lan_client_predicted_marble_name != "" and active_marble_name != lan_client_predicted_marble_name:
		_stop_online_local_prediction()
	lan_client_active_display_name = display_name
	lan_client_active_marble_name = active_marble_name
	lan_client_game_phase = phase
	game_phase = phase
	if phase == GAME_PHASE_MATCH:
		lineup_starter_decided = true
	elif phase == GAME_PHASE_LINEUP:
		lineup_starter_decided = false
	if online_enabled and active_marble_name != "":
		var active_marble: Node3D = _find_marble_by_name(active_marble_name)
		if active_marble != null:
			if phase == GAME_PHASE_MATCH and _is_marble_in_hole(active_marble):
				_begin_hole_attack_level(active_marble)
			else:
				_end_hole_attack_level()
			_activate_camera_for_client(active_marble)
	elif phase != GAME_PHASE_MATCH:
		_end_hole_attack_level()
	turn_changed.emit(display_name, active_index)


@rpc("authority", "call_remote", "reliable")
func _lan_receive_scoreboard(entries: Array) -> void:
	if not lan_enabled or lan_is_host:
		return
	scoreboard_updated.emit(entries)


func get_active_display_name() -> String:
	if lan_enabled and not lan_is_host:
		return lan_client_active_display_name
	var marble: Node3D = _get_current_turn_marble()
	if marble == null:
		return "Player"
	return _display_name_for_marble(marble)


func get_active_marble() -> Node3D:
	if lan_enabled and not lan_is_host:
		return _find_marble_by_name(lan_client_active_marble_name)
	return _get_current_turn_marble()


func is_player_turn() -> bool:
	if lan_enabled and not lan_is_host:
		var local_marble: Node3D = _get_network_input_marble()
		return lan_client_remote_turn_input_enabled and local_marble != null and lan_client_active_marble_name == String(local_marble.name) and _is_play_input_allowed_for_phase()
	if game_phase == GAME_PHASE_LINEUP:
		return current_action_mode == ACTION_MODE_LINEUP and current_actor == player_marble
	return _get_current_turn_marble() == player_marble and _is_play_input_allowed_for_phase()


func _is_play_input_allowed_for_phase() -> bool:
	if game_phase == GAME_PHASE_FINISHED:
		return false
	if game_phase == GAME_PHASE_LINEUP:
		return current_action_mode == ACTION_MODE_LINEUP
	return lineup_starter_decided


func is_player_active() -> bool:
	if lan_enabled and not lan_is_host:
		var local_marble: Node3D = _get_network_input_marble()
		return local_marble != null and active_marbles.has(local_marble)
	return player_marble != null and active_marbles.has(player_marble)


func get_scoreboard_entries() -> Array:
	var entries: Array = []
	for marble in turn_order:
		if marble == null or not active_marbles.has(marble):
			continue
		entries.append({
			"name": _display_name_for_marble(marble),
			"strokes": int(stroke_counts.get(marble.name, 0)),
			"is_active": marble == _get_current_turn_marble()
		})
	return entries


func _display_name_for_marble(marble: Node3D) -> String:
	if online_enabled and online != null:
		var marble_name: String = String(marble.name)
		var client_id: String = ""
		if marble == player_marble:
			client_id = str(online.call("get_host_client_id")) if online.has_method("get_host_client_id") else ""
		else:
			client_id = str(online_client_id_by_marble_name.get(marble_name, ""))
			if client_id == "" and online_marble_name_by_client_id.get(online_local_client_id, "") == marble_name:
				client_id = online_local_client_id
		if client_id != "" and online.has_method("get_player_name_by_id"):
			var stored_online_name: String = str(online_display_name_by_client_id.get(client_id, "")).strip_edges()
			if stored_online_name != "":
				return stored_online_name
			var online_name: String = str(online.call("get_player_name_by_id", client_id)).strip_edges()
			if online_name != "":
				return online_name

	if marble == player_marble:
		if lan_enabled and lan != null and lan.has_method("get_host_player_name"):
			var host_name: String = str(lan.call("get_host_player_name")).strip_edges()
			if host_name != "":
				return host_name
		var customization: Node = get_node_or_null("/root/CustomizationState")
		if customization != null and customization.has_method("get_player_name"):
			var saved_name: String = str(customization.call("get_player_name")).strip_edges()
			if saved_name != "":
				return saved_name
		return "Player"

	if lan_enabled and marble == lan_remote_player_marble:
		_update_lan_remote_player_name()
		return lan_remote_player_name if lan_remote_player_name.strip_edges() != "" else "Friend"

	var internal_name: String = String(marble.name)
	if internal_name.begins_with("AI MARBLE"):
		var ai_name: String = str(ai_display_names.get(internal_name, "")).strip_edges()
		if ai_name != "":
			return ai_name
		return internal_name.replace("AI MARBLE", "Player ")

	return internal_name


func _finish_game() -> void:
	game_phase = GAME_PHASE_FINISHED
	if active_marbles.size() == 1:
		var winner: Node3D = active_marbles[0]
		current_marble_index = turn_order.find(winner)
		if current_marble_index < 0:
			current_marble_index = 0
		await _activate_camera_for(winner)
		_emit_turn_state(winner)
		if _is_local_reward_marble(winner):
			var awarded_coins: int = maxi(win_coin_reward, 0)
			var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
			if awarded_coins > 0 and currency_manager != null and currency_manager.has_method("add_coins"):
				currency_manager.call("add_coins", awarded_coins)
			player_won.emit(awarded_coins)
		var winner_name: String = _display_name_for_marble(winner)
		_spawn_victory_reward(winner)
		var customization: Node = get_node_or_null("/root/CustomizationState")
		if customization != null and customization.has_method("record_match_win"):
			customization.call("record_match_win", winner_name)
		if online_enabled and lan_is_host:
			_send_online_game_message("match_finished", _build_online_match_finished_payload(winner, winner_name))
		game_finished.emit(winner_name)
	else:
		game_finished.emit("")


func _build_online_match_finished_payload(winner: Node3D, winner_name: String) -> Dictionary:
	var winner_client_id: String = _get_online_client_id_for_result_marble(winner)
	var player_entries: Array = []
	var players: Array = _get_online_human_players_snapshot()
	_build_online_player_assignments()

	for player in players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = player as Dictionary
		var client_id: String = str(player_data.get("id", "")).strip_edges()
		if client_id == "":
			continue
		var marble_name: String = str(online_marble_name_by_client_id.get(client_id, "")).strip_edges()
		var eliminations: int = int(elimination_counts_by_marble_name.get(marble_name, 0))
		player_entries.append({
			"client_id": client_id,
			"name": str(player_data.get("name", "Player")),
			"login_id": str(player_data.get("login_id", "")),
			"country": str(player_data.get("country", "Unknown")),
			"marble_name": marble_name,
			"eliminations": eliminations,
			"won": client_id != "" and client_id == winner_client_id
		})

	return {
		"winner_name": winner_name,
		"winner_marble_name": String(winner.name) if winner != null else "",
		"winner_client_id": winner_client_id,
		"players": player_entries
	}


func _get_online_client_id_for_result_marble(marble: Node3D) -> String:
	if marble == null:
		return ""
	_build_online_player_assignments()
	var marble_name: String = String(marble.name)
	for client_id_variant in online_marble_name_by_client_id.keys():
		var client_id: String = str(client_id_variant)
		if str(online_marble_name_by_client_id.get(client_id_variant, "")) == marble_name:
			return client_id
	return _get_online_client_id_for_marble(marble)


func _get_turn_order_names() -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for marble in turn_order:
		if marble == null or not active_marbles.has(marble):
			continue
		names.append(_display_name_for_marble(marble))
	return names


func _get_marble_names(candidates: Array[Node3D]) -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for marble in candidates:
		if marble == null:
			continue
		names.append(_display_name_for_marble(marble))
	return names


func _planar_distance(from: Vector3, to: Vector3) -> float:
	return Vector2(from.x, from.z).distance_to(Vector2(to.x, to.z))


func _planar_direction_to(from: Vector3, to: Vector3) -> Vector3:
	var planar: Vector3 = Vector3(to.x - from.x, 0.0, to.z - from.z)
	if planar.length_squared() <= 0.0001:
		return Vector3.FORWARD
	return planar.normalized()


func _distance_point_to_segment_2d(point: Vector2, segment_start: Vector2, segment_end: Vector2) -> float:
	var segment: Vector2 = segment_end - segment_start
	var segment_length_squared: float = segment.length_squared()
	if segment_length_squared <= 0.0001:
		return point.distance_to(segment_start)

	var t: float = clampf((point - segment_start).dot(segment) / segment_length_squared, 0.0, 1.0)
	var closest_point: Vector2 = segment_start + segment * t
	return point.distance_to(closest_point)


func _update_marble_trails(delta: float) -> void:
	for marble in active_marbles:
		if marble == null or not is_instance_valid(marble):
			continue

		var body: RigidBody3D = marble as RigidBody3D
		var speed: float = body.linear_velocity.length() if body != null else 0.0
		var moving: bool = speed > 0.35
		var root: Node3D = _ensure_trail_root(marble)
		if root == null:
			continue

		var preset: Dictionary = _get_trail_preset_for_marble(marble)
		_update_continuous_trail(root, marble, body, speed, moving, preset, delta)


func _ensure_trail_root(marble: Node3D) -> Node3D:
	var existing: Node3D = marble_trail_roots.get(marble) as Node3D
	if existing != null and is_instance_valid(existing):
		return existing

	var current_scene: Node = _get_current_scene_safe()
	if current_scene == null:
		return null

	var root: Node3D = Node3D.new()
	root.name = "%sWorldTrailRoot" % marble.name
	root.top_level = true
	root.visible = false
	current_scene.add_child(root)
	root.add_child(_build_gpu_world_trail_marker())
	marble_trail_roots[marble] = root
	return root


func _clear_trail_for_marble(marble: Node3D) -> void:
	var root: Node3D = marble_trail_roots.get(marble) as Node3D
	if root != null and is_instance_valid(root):
		root.queue_free()
	marble_trail_roots.erase(marble)
	marble_trail_points.erase(marble)
	marble_trail_last_samples.erase(marble)
	marble_trail_last_directions.erase(marble)


func _get_trail_preset_for_marble(marble: Node3D) -> Dictionary:
	var marble_name: String = String(marble.name)
	if online_enabled and online_remote_trail_presets_by_marble_name.has(marble_name):
		var remote_preset = online_remote_trail_presets_by_marble_name.get(marble_name, {})
		if typeof(remote_preset) == TYPE_DICTIONARY:
			return (remote_preset as Dictionary).duplicate(true)

	if marble == player_marble or (online_enabled and marble == online_local_player_marble):
		var customization: Node = get_node_or_null("/root/CustomizationState")
		if customization != null and customization.has_method("get_selected_trail_preset"):
			return customization.call("get_selected_trail_preset")

	var lower_name: String = marble.name.to_lower()
	if lower_name.contains("1"):
		return {
			"enabled": true,
			"color": Color(1.0, 0.56, 0.2, 0.34),
			"secondary_color": Color(1.0, 0.82, 0.34, 0.22),
			"emission": Color(1.0, 0.42, 0.08, 1.0),
			"scale": 0.14,
			"lifetime": 0.28,
			"interval": 0.026
		}
	if lower_name.contains("2"):
		return {
			"enabled": true,
			"color": Color(0.52, 1.0, 0.72, 0.32),
			"secondary_color": Color(0.8, 1.0, 0.9, 0.18),
			"emission": Color(0.24, 0.88, 0.48, 1.0),
			"scale": 0.14,
			"lifetime": 0.28,
			"interval": 0.026
		}
	if lower_name.contains("3"):
		return {
			"enabled": true,
			"color": Color(0.52, 0.8, 1.0, 0.34),
			"secondary_color": Color(0.82, 0.92, 1.0, 0.22),
			"emission": Color(0.2, 0.64, 1.0, 1.0),
			"scale": 0.14,
			"lifetime": 0.28,
			"interval": 0.026
		}
	return {
		"enabled": true,
		"color": Color(0.9, 0.5, 1.0, 0.34),
		"secondary_color": Color(1.0, 0.84, 1.0, 0.18),
		"emission": Color(0.64, 0.3, 1.0, 1.0),
		"scale": 0.14,
		"lifetime": 0.28,
		"interval": 0.026
	}


func _update_continuous_trail(root: Node3D, marble: Node3D, body: RigidBody3D, speed: float, moving: bool, preset: Dictionary, delta: float) -> void:
	if not bool(preset.get("enabled", false)):
		root.visible = false
		return

	_update_gpu_world_trail(root, marble, body, speed, moving, preset, delta)


func _build_gpu_world_trail_marker() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "GPUTrailMarker"
	root.set_meta("gpu_configured", false)
	root.set_meta("preset_signature", "")

	var trail: GPUParticles3D = GPU_TRAIL_SCRIPT.new() as GPUParticles3D
	if trail == null:
		return _build_world_trail_marker()
	trail.name = "GPUTrail3D"
	trail.emitting = true
	root.add_child(trail)
	return root


func _update_gpu_world_trail(root: Node3D, marble: Node3D, body: RigidBody3D, speed: float, moving: bool, preset: Dictionary, delta: float) -> void:
	var marker: Node3D = root.get_node_or_null("GPUTrailMarker") as Node3D
	if marker == null:
		marker = _build_gpu_world_trail_marker()
		root.add_child(marker)

	var trail: GPUParticles3D = marker.get_node_or_null("GPUTrail3D") as GPUParticles3D
	if trail == null:
		_update_legacy_continuous_trail(root, marble, body, speed, moving, preset, delta)
		return

	if trail.draw_pass_1 == null:
		root.visible = false
		return

	var signature: String = _get_trail_preset_signature(preset)
	if str(marker.get_meta("preset_signature", "")) != signature:
		_configure_gpu_world_trail(trail, preset)
		marker.set_meta("preset_signature", signature)
		marker.set_meta("gpu_configured", true)

	var direction: Vector3 = Vector3.ZERO
	if body != null:
		direction = body.linear_velocity
		direction.y = 0.0
		if direction.length_squared() <= 0.0001:
			direction = body.linear_velocity
	if direction.length_squared() > 0.0001:
		direction = direction.normalized()
		marble_trail_last_directions[marble] = direction
	else:
		var stored_direction: Variant = marble_trail_last_directions.get(marble, Vector3.FORWARD)
		direction = stored_direction if stored_direction is Vector3 else Vector3.FORWARD
		if direction.length_squared() <= 0.0001:
			direction = Vector3.FORWARD

	var speed_ratio: float = clampf(speed / 8.0, 0.0, 1.0)
	var preset_scale: float = maxf(float(preset.get("scale", 0.14)), 0.08)
	var marble_radius: float = maxf(_get_marble_collision_radius(marble), MARBLE_TRAIL_RADIUS)
	var width: float = lerpf(0.11, 0.22, speed_ratio) * maxf(preset_scale / 0.14, 0.72)
	root.visible = moving or bool(marker.get_meta("gpu_configured", false))
	root.global_position = marble.global_position + Vector3.UP * MARBLE_TRAIL_VERTICAL_OFFSET - direction * (marble_radius + MARBLE_TRAIL_SURFACE_GAP)
	root.global_basis = Basis.IDENTITY
	marker.global_basis = Basis.IDENTITY
	trail.scale = trail.scale.lerp(Vector3.ONE * width, clampf(delta * 16.0, 0.0, 1.0))
	trail.emitting = true


func _configure_gpu_world_trail(trail: GPUParticles3D, preset: Dictionary) -> void:
	var lifetime: float = clampf(float(preset.get("lifetime", 0.46)), 0.22, 0.95)
	trail.set("length_seconds", lifetime)
	trail.set("billboard", true)
	trail.set("snap_to_transform", true)
	trail.set("dewiggle", true)
	trail.set("clip_overlaps", true)
	trail.set("scroll", _get_gpu_trail_scroll(preset))
	trail.set("mask", _get_cached_gpu_trail_mask(preset))
	trail.set("mask_strength", 1.0)

	var texture_path: String = str(preset.get("texture_path", "")).strip_edges()
	if texture_path != "":
		var texture: Texture2D = _load_trail_texture(texture_path)
		if texture != null:
			trail.set("texture", texture)

	trail.set("color_ramp", _get_cached_gpu_trail_color_ramp(preset))
	trail.set("curve", _get_cached_gpu_trail_width_curve(preset))


func _get_trail_preset_signature(preset: Dictionary) -> String:
	return PackedStringArray([
		str(preset.get("color", Color.WHITE)),
		str(preset.get("secondary_color", Color.WHITE)),
		str(preset.get("emission", Color.WHITE)),
		str(preset.get("scale", 0.14)),
		str(preset.get("lifetime", 0.46)),
		str(preset.get("texture_path", "")),
		str(preset.get("id", "")),
		str(preset.get("shape", ""))
	]).join("|")


func _make_gpu_world_trail_color_ramp(preset: Dictionary) -> GradientTexture1D:
	var primary: Color = preset.get("color", Color(0.42, 0.92, 1.0, 0.46))
	var secondary: Color = preset.get("secondary_color", primary.lightened(0.22))
	var emission: Color = preset.get("emission", primary)
	var style: String = _get_gpu_trail_style(preset)
	var gradient: Gradient = Gradient.new()
	var tail: Color = secondary
	tail.a = 0.0
	var middle: Color = primary.lerp(secondary, 0.35)
	middle.a = maxf(primary.a, 0.34)
	var head: Color = emission
	head.a = maxf(primary.a, 0.76)
	gradient.set_color(0, tail)
	gradient.set_color(1, head)
	match style:
		"kenya":
			var red: Color = primary
			red.a = maxf(primary.a, 0.56)
			var green: Color = secondary
			green.a = maxf(secondary.a, 0.48)
			gradient.add_point(0.28, green)
			gradient.add_point(0.58, red)
			gradient.add_point(0.82, Color(1.0, 1.0, 1.0, 0.78))
		"aurora":
			gradient.add_point(0.2, Color(primary.r, primary.g, primary.b, 0.42))
			gradient.add_point(0.48, Color(secondary.r, secondary.g, secondary.b, 0.68))
			gradient.add_point(0.76, Color(0.62, 1.0, 0.92, 0.58))
		"dust":
			gradient.add_point(0.32, Color(secondary.r, secondary.g, secondary.b, 0.18))
			gradient.add_point(0.62, Color(primary.r, primary.g, primary.b, 0.5))
		"spark":
			gradient.add_point(0.18, Color(secondary.r, secondary.g, secondary.b, 0.08))
			gradient.add_point(0.42, Color(emission.r, emission.g, emission.b, 0.82))
			gradient.add_point(0.66, Color(primary.r, primary.g, primary.b, 0.18))
		_:
			gradient.add_point(0.45, middle)
	var texture: GradientTexture1D = GradientTexture1D.new()
	texture.gradient = gradient
	return texture


func _get_cached_gpu_trail_color_ramp(preset: Dictionary) -> GradientTexture1D:
	var key: String = "ramp|%s" % _get_trail_preset_signature(preset)
	var cached: GradientTexture1D = gpu_trail_resource_cache.get(key, null) as GradientTexture1D
	if cached != null:
		return cached
	var texture: GradientTexture1D = _make_gpu_world_trail_color_ramp(preset)
	gpu_trail_resource_cache[key] = texture
	return texture


func _make_gpu_world_trail_width_curve(preset: Dictionary) -> CurveTexture:
	var style: String = _get_gpu_trail_style(preset)
	var curve: Curve = Curve.new()
	match style:
		"ribbon", "kenya", "aurora":
			curve.add_point(Vector2(0.0, 0.0))
			curve.add_point(Vector2(0.12, 0.72))
			curve.add_point(Vector2(0.42, 1.0))
			curve.add_point(Vector2(0.78, 0.82))
			curve.add_point(Vector2(1.0, 0.18))
		"dust":
			curve.add_point(Vector2(0.0, 0.0))
			curve.add_point(Vector2(0.18, 0.28))
			curve.add_point(Vector2(0.38, 0.52))
			curve.add_point(Vector2(0.62, 0.28))
			curve.add_point(Vector2(0.82, 0.44))
			curve.add_point(Vector2(1.0, 0.05))
		"spark":
			curve.add_point(Vector2(0.0, 0.0))
			curve.add_point(Vector2(0.12, 0.18))
			curve.add_point(Vector2(0.24, 1.0))
			curve.add_point(Vector2(0.38, 0.26))
			curve.add_point(Vector2(0.54, 0.82))
			curve.add_point(Vector2(0.72, 0.18))
			curve.add_point(Vector2(0.9, 0.66))
			curve.add_point(Vector2(1.0, 0.04))
		_:
			curve.add_point(Vector2(0.0, 0.0))
			curve.add_point(Vector2(0.22, 0.34))
			curve.add_point(Vector2(0.72, 0.88))
			curve.add_point(Vector2(0.94, 1.0))
			curve.add_point(Vector2(1.0, 0.08))
	var texture: CurveTexture = CurveTexture.new()
	texture.curve = curve
	return texture


func _get_cached_gpu_trail_width_curve(preset: Dictionary) -> CurveTexture:
	var key: String = "curve|%s" % _get_trail_preset_signature(preset)
	var cached: CurveTexture = gpu_trail_resource_cache.get(key, null) as CurveTexture
	if cached != null:
		return cached
	var texture: CurveTexture = _make_gpu_world_trail_width_curve(preset)
	gpu_trail_resource_cache[key] = texture
	return texture


func _get_gpu_trail_style(preset: Dictionary) -> String:
	var id: String = str(preset.get("id", "")).to_lower()
	var name: String = str(preset.get("name", "")).to_lower()
	var shape: String = str(preset.get("shape", "comet")).to_lower()
	if id.find("kenya") != -1 or name.find("kenya") != -1:
		return "kenya"
	if id.find("aurora") != -1 or name.find("aurora") != -1:
		return "aurora"
	if shape == "dust" or id.find("dust") != -1 or name.find("dust") != -1:
		return "dust"
	if shape == "spark" or id.find("static") != -1 or name.find("static") != -1:
		return "spark"
	if shape == "ribbon":
		return "ribbon"
	return "comet"


func _get_gpu_trail_scroll(preset: Dictionary) -> Vector2:
	match _get_gpu_trail_style(preset):
		"ribbon", "aurora":
			return Vector2(-0.24, 0.1)
		"kenya":
			return Vector2(-0.55, 0.0)
		"dust":
			return Vector2(-0.18, 0.22)
		"spark":
			return Vector2(-0.72, -0.08)
		_:
			return Vector2(-0.36, 0.0)


func _make_gpu_trail_pattern_mask(preset: Dictionary) -> Texture2D:
	var style: String = _get_gpu_trail_style(preset)
	var image: Image = Image.create(128, 16, false, Image.FORMAT_RGBA8)
	for x in range(128):
		var u: float = float(x) / 127.0
		for y in range(16):
			var v: float = float(y) / 15.0
			var value: float = 1.0
			match style:
				"kenya":
					value = 1.0 if sin(u * TAU * 10.0) >= 0.5 else 0.42
					if absf(v - 0.5) < 0.12:
						value = 1.0
				"aurora":
					value = 0.62 + 0.38 * sin(u * TAU * 2.0 + v * TAU * 2.6)
				"dust":
					var raw_grain: float = sin(float(x * 37 + y * 91)) * 43758.5453
					var grain: float = raw_grain - floor(raw_grain)
					var cluster: float = 1.0 if grain >= 0.44 else 0.34
					value = cluster * (0.45 + 0.55 * smoothstep(0.08, 0.72, u))
				"spark":
					var slash: float = 1.0 if sin((u * 15.0 + v * 4.0) * TAU) >= 0.58 else 0.0
					value = 0.16 + 0.84 * slash
				"ribbon":
					value = 0.68 + 0.32 * sin((v * 3.0 + u * 1.5) * TAU)
				_:
					value = 0.82 + 0.18 * sin(u * TAU * 3.0)
			image.set_pixel(x, y, Color(value, value, value, 1.0))
	return ImageTexture.create_from_image(image)


func _get_cached_gpu_trail_mask(preset: Dictionary) -> Texture2D:
	var key: String = "mask|%s" % _get_trail_preset_signature(preset)
	var cached: Texture2D = gpu_trail_resource_cache.get(key, null) as Texture2D
	if cached != null:
		return cached
	var texture: Texture2D = _make_gpu_trail_pattern_mask(preset)
	gpu_trail_resource_cache[key] = texture
	return texture


func _update_legacy_continuous_trail(root: Node3D, marble: Node3D, body: RigidBody3D, speed: float, moving: bool, preset: Dictionary, delta: float) -> void:
	if str(preset.get("texture_path", "")).strip_edges() != "":
		_update_textured_projectile_trail(root, marble, body, speed, moving, preset, delta)
		return

	var skill_marker: MeshInstance3D = root.get_node_or_null("SkillTrailRibbon") as MeshInstance3D
	if skill_marker != null:
		skill_marker.visible = false

	var marker: Node3D = root.get_node_or_null("TrailMarker") as Node3D
	if marker == null:
		return

	if not moving or body == null:
		root.visible = false
		return

	var direction: Vector3 = body.linear_velocity
	direction.y = 0.0
	if direction.length_squared() > 0.0001:
		direction = direction.normalized()
	else:
		direction = body.linear_velocity.normalized()
	if direction.length_squared() <= 0.0001:
		root.visible = false
		return

	root.visible = true
	var speed_ratio: float = clampf(speed / 8.0, 0.0, 1.0)
	var trail_length: float = lerpf(1.45, 4.0, speed_ratio)
	var trail_width: float = lerpf(0.08, 0.16, speed_ratio) * maxf(float(preset.get("scale", 0.14)) * 3.0, 0.65)
	var marble_radius: float = maxf(_get_marble_collision_radius(marble), MARBLE_TRAIL_RADIUS)
	root.global_position = marble.global_position + Vector3.UP * MARBLE_TRAIL_VERTICAL_OFFSET - direction * (marble_radius + MARBLE_TRAIL_SURFACE_GAP)
	root.look_at(root.global_position - direction, Vector3.UP)

	marker.scale = marker.scale.lerp(Vector3.ONE, clampf(delta * 10.0, 0.0, 1.0))

	var ribbon: MeshInstance3D = root.get_node_or_null("TrailMarker/Ribbon") as MeshInstance3D
	var core: MeshInstance3D = root.get_node_or_null("TrailMarker/Core") as MeshInstance3D
	var head_glow: MeshInstance3D = root.get_node_or_null("TrailMarker/HeadGlow") as MeshInstance3D
	var aura_shell: MeshInstance3D = root.get_node_or_null("TrailMarker/AuraShell") as MeshInstance3D
	if ribbon != null and core != null:
		ribbon.position = Vector3.ZERO
		ribbon.scale = ribbon.scale.lerp(Vector3(trail_width * 2.25, maxf(trail_width * 0.42, 0.04), trail_length), clampf(delta * 16.0, 0.0, 1.0))
		core.position = Vector3(0.0, 0.012, -0.03)
		core.scale = core.scale.lerp(Vector3(maxf(trail_width * 0.74, 0.035), maxf(trail_width * 0.22, 0.025), trail_length * 0.92), clampf(delta * 16.0, 0.0, 1.0))
		if head_glow != null:
			head_glow.position = Vector3(0.0, 0.035, 0.0)
			head_glow.scale = head_glow.scale.lerp(Vector3.ONE * lerpf(0.12, 0.24, speed_ratio), clampf(delta * 16.0, 0.0, 1.0))
		if aura_shell != null:
			aura_shell.position = Vector3(0.0, -MARBLE_TRAIL_VERTICAL_OFFSET, marble_radius + MARBLE_TRAIL_SURFACE_GAP)
			aura_shell.scale = aura_shell.scale.lerp(Vector3.ONE * marble_radius * lerpf(1.16, 1.34, speed_ratio), clampf(delta * 16.0, 0.0, 1.0))
		_apply_trail_materials(ribbon, core, head_glow, aura_shell, preset, lerpf(0.62, 0.94, speed_ratio))


func _build_world_trail_marker() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "TrailMarker"

	var aura_shell: MeshInstance3D = MeshInstance3D.new()
	aura_shell.name = "AuraShell"
	var aura_mesh: SphereMesh = SphereMesh.new()
	aura_mesh.radius = 1.0
	aura_mesh.height = 2.0
	aura_mesh.radial_segments = 32
	aura_mesh.rings = 16
	aura_shell.mesh = aura_mesh
	root.add_child(aura_shell)

	var ribbon: MeshInstance3D = MeshInstance3D.new()
	ribbon.name = "Ribbon"
	ribbon.mesh = _make_pulled_flame_mesh(0.0, 1.0)
	root.add_child(ribbon)

	var core: MeshInstance3D = MeshInstance3D.new()
	core.name = "Core"
	core.mesh = _make_pulled_flame_mesh(0.34, 0.62)
	root.add_child(core)

	var head_glow: MeshInstance3D = MeshInstance3D.new()
	head_glow.name = "HeadGlow"
	var head_mesh: SphereMesh = SphereMesh.new()
	head_mesh.radius = 1.0
	head_mesh.height = 2.0
	head_mesh.radial_segments = 16
	head_mesh.rings = 8
	head_glow.mesh = head_mesh
	root.add_child(head_glow)

	var particle_marker: Node3D = _build_particle_trail_marker()
	if particle_marker != null:
		particle_marker.name = "ParticleTrail"
		particle_marker.position = Vector3(0.0, 0.0, 0.18)
		root.add_child(particle_marker)

	return root


func _make_pulled_flame_mesh(phase: float, width_scale: float) -> ArrayMesh:
	var segments: int = 10
	var vertices: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()
	var indices: PackedInt32Array = PackedInt32Array()

	for index in range(segments + 1):
		var t: float = float(index) / float(segments)
		var taper: float = pow(1.0 - t, 0.72)
		var width: float = lerpf(0.06, 0.5, taper) * width_scale
		var lateral_pull: float = sin(t * PI * 2.6 + phase * PI * 2.0) * 0.1 * taper
		var lift_pull: float = sin(t * PI * 1.8 + phase * PI) * 0.08 * taper
		var z: float = -t
		var alpha: float = clampf(1.0 - pow(t, 1.2), 0.0, 1.0)
		vertices.append(Vector3(lateral_pull - width, lift_pull, z))
		vertices.append(Vector3(lateral_pull + width, lift_pull, z))
		uvs.append(Vector2(t, 0.0))
		uvs.append(Vector2(t, 1.0))
		colors.append(Color(1.0, 1.0, 1.0, alpha))
		colors.append(Color(1.0, 1.0, 1.0, alpha))

	for index in range(segments):
		var base: int = index * 2
		indices.append(base)
		indices.append(base + 1)
		indices.append(base + 2)
		indices.append(base + 1)
		indices.append(base + 3)
		indices.append(base + 2)

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _build_particle_trail_marker() -> Node3D:
	if not ResourceLoader.exists(TRAIL_PARTICLE_SCENE_PATH):
		return null

	var loaded: Resource = load(TRAIL_PARTICLE_SCENE_PATH)
	var packed: PackedScene = loaded as PackedScene
	if packed == null:
		return null

	var instance: Node = packed.instantiate()
	var marker: Node3D = instance as Node3D
	if marker == null:
		if instance != null:
			instance.queue_free()
		return null

	marker.name = "ParticleTrail"
	marker.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	marker.scale = Vector3.ONE * 0.65
	_set_visible_recursive(marker, true)
	_play_first_animation_recursive(marker)
	return marker


func _make_world_trail_material(albedo: Color, emission: Color, energy: float) -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = _get_speed_streak_shader()
	_configure_world_trail_material(material, albedo, emission, energy)
	return material


func _get_speed_streak_shader() -> Shader:
	if speed_streak_shader_cache != null:
		return speed_streak_shader_cache

	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 trail_color : source_color = vec4(0.2, 0.8, 1.0, 0.5);
uniform vec4 emission_color : source_color = vec4(0.2, 0.8, 1.0, 1.0);
uniform float emission_energy = 2.0;

void fragment() {
	float along = clamp(VERTEX.z + 1.0, 0.0, 1.0);
	float tail_fade = smoothstep(0.0, 0.28, along);
	float head_keep = 1.0 - smoothstep(0.94, 1.0, along) * 0.12;
	float side_fade = 1.0 - smoothstep(0.12, 0.56, abs(VERTEX.x));
	float flame_noise = 0.82 + sin(TIME * 7.0 + along * 18.0 + VERTEX.x * 5.0) * 0.18;
	float alpha = trail_color.a * tail_fade * head_keep * side_fade * flame_noise * COLOR.a;
	ALBEDO = trail_color.rgb;
	ALPHA = alpha;
	EMISSION = emission_color.rgb * emission_energy * max(alpha, 0.08);
}
"""
	speed_streak_shader_cache = shader
	return speed_streak_shader_cache


func _apply_trail_materials(ribbon: MeshInstance3D, core: MeshInstance3D, head_glow: MeshInstance3D, aura_shell: MeshInstance3D, preset: Dictionary, alpha_scale: float) -> void:
	var primary: Color = preset.get("color", Color(0.42, 0.92, 1.0, 0.34))
	var emission: Color = preset.get("emission", primary)
	_apply_world_trail_material(
		ribbon,
		Color(primary.r, primary.g, primary.b, maxf(primary.a * alpha_scale, 0.12)),
		emission,
		1.6
	)
	_apply_world_trail_material(
		core,
		Color(emission.r, emission.g, emission.b, maxf(alpha_scale, 0.48)),
		emission,
		3.2
	)
	if head_glow != null:
		_apply_world_trail_material(
			head_glow,
			Color(emission.r, emission.g, emission.b, maxf(alpha_scale * 0.58, 0.24)),
			emission,
			2.8
		)
	if aura_shell != null:
		_apply_world_aura_material(
			aura_shell,
			Color(primary.r, primary.g, primary.b, maxf(primary.a * 0.46 * alpha_scale, 0.08)),
			emission,
			lerpf(1.7, 2.8, alpha_scale)
		)

	var particle: Node3D = ribbon.get_parent().get_node_or_null("ParticleTrail") as Node3D
	if particle != null:
		particle.visible = str(preset.get("scene_path", "")).strip_edges() != ""
		if particle.visible:
			particle.position = Vector3(0.0, 0.0, -MARBLE_TRAIL_SURFACE_GAP)
			particle.scale = Vector3.ONE * maxf(float(preset.get("scale", 0.14)) * 4.0, 0.5)
			_set_visible_recursive(particle, true)


func _apply_world_trail_material(target: MeshInstance3D, albedo: Color, emission: Color, energy: float) -> void:
	if target == null:
		return
	var material: ShaderMaterial = target.material_override as ShaderMaterial
	if material == null or material.shader != _get_speed_streak_shader():
		material = ShaderMaterial.new()
		material.shader = _get_speed_streak_shader()
		target.material_override = material
	_configure_world_trail_material(material, albedo, emission, energy)


func _configure_world_trail_material(material: ShaderMaterial, albedo: Color, emission: Color, energy: float) -> void:
	material.set_shader_parameter("trail_color", Color(albedo.r, albedo.g, albedo.b, maxf(albedo.a, 0.24)))
	material.set_shader_parameter("emission_color", Color(emission.r, emission.g, emission.b, 1.0))
	material.set_shader_parameter("emission_energy", energy)


func _apply_world_aura_material(target: MeshInstance3D, albedo: Color, emission: Color, energy: float) -> void:
	if target == null:
		return
	var material: ShaderMaterial = target.material_override as ShaderMaterial
	if material == null or material.shader != _get_trail_aura_shader():
		material = ShaderMaterial.new()
		material.shader = _get_trail_aura_shader()
		target.material_override = material
	material.set_shader_parameter("aura_color", Color(albedo.r, albedo.g, albedo.b, maxf(albedo.a, 0.06)))
	material.set_shader_parameter("emission_color", Color(emission.r, emission.g, emission.b, 1.0))
	material.set_shader_parameter("emission_energy", energy)


func _get_trail_aura_shader() -> Shader:
	if trail_aura_shader_cache != null:
		return trail_aura_shader_cache

	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 aura_color : source_color = vec4(0.2, 0.8, 1.0, 0.12);
uniform vec4 emission_color : source_color = vec4(0.2, 0.8, 1.0, 1.0);
uniform float emission_energy = 2.2;

void fragment() {
	float rim = pow(1.0 - clamp(abs(dot(normalize(NORMAL), normalize(VIEW))), 0.0, 1.0), 2.2);
	float pulse = 0.82 + sin(TIME * 5.5 + VERTEX.y * 7.0) * 0.18;
	float alpha = aura_color.a * (0.22 + rim * 1.35) * pulse;
	ALBEDO = aura_color.rgb;
	ALPHA = alpha;
	EMISSION = emission_color.rgb * emission_energy * max(alpha, 0.05);
}
"""
	trail_aura_shader_cache = shader
	return trail_aura_shader_cache


func _update_textured_projectile_trail(root: Node3D, marble: Node3D, body: RigidBody3D, speed: float, moving: bool, preset: Dictionary, delta: float) -> void:
	var marker: Node3D = root.get_node_or_null("TrailMarker") as Node3D
	if marker != null:
		marker.visible = false

	var ribbon: MeshInstance3D = root.get_node_or_null("SkillTrailRibbon") as MeshInstance3D
	if ribbon == null:
		ribbon = _build_textured_projectile_marker(preset)
		if ribbon == null:
			root.visible = false
			return
		root.add_child(ribbon)

	root.visible = true
	root.global_transform = Transform3D.IDENTITY

	var lifetime: float = maxf(float(preset.get("lifetime", 0.52)), 0.18)
	var points: Array = marble_trail_points.get(marble, [])
	for index in range(points.size() - 1, -1, -1):
		var point: Dictionary = points[index]
		point["age"] = float(point.get("age", 0.0)) + delta
		if float(point["age"]) > lifetime:
			points.remove_at(index)
		else:
			points[index] = point

	if moving and body != null:
		var sample_position: Vector3 = marble.global_position + Vector3.UP * 0.05
		var last_sample: Vector3 = marble_trail_last_samples.get(marble, Vector3(999999.0, 999999.0, 999999.0))
		if points.is_empty() or sample_position.distance_to(last_sample) >= 0.08:
			points.append({"position": sample_position, "age": 0.0})
			marble_trail_last_samples[marble] = sample_position
			while points.size() > 36:
				points.remove_at(0)

	marble_trail_points[marble] = points
	if points.size() < 2:
		ribbon.visible = false
		ribbon.mesh = ArrayMesh.new()
		return

	ribbon.visible = true
	var camera: Camera3D = get_viewport().get_camera_3d() if is_inside_tree() else null
	var speed_ratio: float = clampf(speed / 8.0, 0.0, 1.0)
	var preset_scale: float = maxf(float(preset.get("scale", 0.2)), 0.08)
	var max_width: float = lerpf(0.38, 0.66, speed_ratio) * maxf(preset_scale * 4.0, 0.85)

	var vertices: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()
	var indices: PackedInt32Array = PackedInt32Array()
	var point_count: int = points.size()

	for index in range(point_count):
		var t: float = float(index) / float(maxi(point_count - 1, 1))
		var point_data: Dictionary = points[index]
		var position: Vector3 = point_data.get("position", marble.global_position)
		var previous_data: Dictionary = points[maxi(index - 1, 0)]
		var next_data: Dictionary = points[mini(index + 1, point_count - 1)]
		var previous_position: Vector3 = previous_data.get("position", position)
		var next_position: Vector3 = next_data.get("position", position)
		var tangent: Vector3 = (next_position - previous_position).normalized()
		if tangent.length_squared() <= 0.0001 and body != null:
			tangent = body.linear_velocity.normalized()
		if tangent.length_squared() <= 0.0001:
			tangent = Vector3.FORWARD

		var view_direction: Vector3 = Vector3.UP
		if camera != null:
			view_direction = (camera.global_position - position).normalized()
		var side: Vector3 = tangent.cross(view_direction).normalized()
		if side.length_squared() <= 0.0001:
			side = Vector3.UP.cross(tangent).normalized()
		if side.length_squared() <= 0.0001:
			side = Vector3.RIGHT

		var width: float = max_width * lerpf(0.22, 1.0, smoothstep(0.0, 1.0, t))
		var age_alpha: float = clampf(1.0 - (float(point_data.get("age", 0.0)) / lifetime), 0.0, 1.0)
		var tail_alpha: float = smoothstep(0.0, 0.18, t)
		var alpha: float = age_alpha * tail_alpha

		vertices.append(position - side * width)
		vertices.append(position + side * width)
		uvs.append(Vector2(t, 0.0))
		uvs.append(Vector2(t, 1.0))
		colors.append(Color(1.0, 1.0, 1.0, alpha))
		colors.append(Color(1.0, 1.0, 1.0, alpha))

	for index in range(point_count - 1):
		var base: int = index * 2
		indices.append(base)
		indices.append(base + 1)
		indices.append(base + 2)
		indices.append(base + 1)
		indices.append(base + 3)
		indices.append(base + 2)

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices

	var ribbon_mesh: ArrayMesh = ArrayMesh.new()
	ribbon_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	ribbon.mesh = ribbon_mesh


func _build_textured_projectile_marker(preset: Dictionary) -> MeshInstance3D:
	var texture_path: String = str(preset.get("texture_path", "")).strip_edges()
	var texture: Texture2D = _load_trail_texture(texture_path)
	if texture == null:
		return null
	var ribbon: MeshInstance3D = MeshInstance3D.new()
	ribbon.name = "SkillTrailRibbon"
	ribbon.mesh = ArrayMesh.new()
	ribbon.material_override = _make_textured_projectile_trail_material(texture)
	return ribbon


func _load_trail_texture(texture_path: String) -> Texture2D:
	if texture_path == "":
		return null
	if ResourceLoader.exists(texture_path):
		var texture_resource: Resource = ResourceLoader.load(texture_path)
		if texture_resource is Texture2D:
			return texture_resource as Texture2D
	var image: Image = Image.new()
	var load_path: String = texture_path
	if texture_path.begins_with("res://"):
		load_path = ProjectSettings.globalize_path(texture_path)
	if image.load(load_path) == OK:
		return ImageTexture.create_from_image(image)
	return null


func _make_textured_projectile_trail_material(texture: Texture2D) -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = _get_textured_projectile_trail_shader()
	material.set_shader_parameter("trail_texture", texture)
	material.set_shader_parameter("alpha_scale", 1.0)
	material.set_shader_parameter("emission_energy", 2.8)
	return material


func _get_textured_projectile_trail_shader() -> Shader:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform sampler2D trail_texture : source_color;
uniform float alpha_scale = 1.0;
uniform float emission_energy = 2.8;

void fragment() {
	vec4 tex = texture(trail_texture, UV);
	float key_distance = distance(tex.rgb, vec3(1.0, 0.0, 1.0));
	float key_alpha = smoothstep(0.08, 0.28, key_distance);
	ALBEDO = tex.rgb * COLOR.rgb;
	ALPHA = tex.a * key_alpha * alpha_scale * COLOR.a;
	EMISSION = tex.rgb * emission_energy;
}
"""
	return shader


func _play_first_animation_recursive(node: Node) -> void:
	if node is AnimationPlayer:
		var player: AnimationPlayer = node as AnimationPlayer
		var animations: PackedStringArray = player.get_animation_list()
		if not animations.is_empty():
			player.play(animations[0])

	for child in node.get_children():
		_play_first_animation_recursive(child)


func _set_visible_recursive(node: Node, visible_state: bool) -> void:
	if node is VisualInstance3D:
		(node as VisualInstance3D).visible = visible_state

	for child in node.get_children():
		_set_visible_recursive(child, visible_state)
