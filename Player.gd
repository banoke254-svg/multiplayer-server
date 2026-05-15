extends Node3D

@export var move_speed: float = 8.0
@export var turn_speed: float = 3.5
@export var roll_speed: float = 10.0
@export var sync_rate: float = 1.0 / 20.0
@export var remote_lerp_speed: float = 14.0
@export var marble_visual_path: NodePath

var _sync_timer: float = 0.0
var _has_remote_target: bool = false
var _remote_target_transform: Transform3D

@onready var marble_visual: Node3D = get_node_or_null(marble_visual_path) as Node3D


func _ready() -> void:
	_remote_target_transform = global_transform
	print("Player: %s ready. Authority: %d" % [name, get_multiplayer_authority()])


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		_handle_authority_movement(delta)
		_send_transform_sync(delta)
	else:
		_apply_remote_transform(delta)


func _handle_authority_movement(delta: float) -> void:
	var turn_input: float = Input.get_axis("ui_left", "ui_right")
	var move_input: float = Input.get_axis("ui_down", "ui_up")

	if not is_zero_approx(turn_input):
		rotate_y(-turn_input * turn_speed * delta)

	if not is_zero_approx(move_input):
		var forward: Vector3 = -global_transform.basis.z.normalized()
		global_position += forward * move_input * move_speed * delta
		if marble_visual != null:
			marble_visual.rotate_x(move_input * roll_speed * delta)


func _send_transform_sync(delta: float) -> void:
	_sync_timer -= delta
	if _sync_timer > 0.0:
		return

	_sync_timer = sync_rate
	sync_transform.rpc(global_transform)


func _apply_remote_transform(delta: float) -> void:
	if not _has_remote_target:
		return

	var weight: float = clampf(delta * remote_lerp_speed, 0.0, 1.0)
	global_transform = global_transform.interpolate_with(_remote_target_transform, weight)


@rpc("any_peer", "unreliable")
func sync_transform(new_transform: Transform3D) -> void:
	if is_multiplayer_authority():
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	if sender_id != 0 and sender_id != get_multiplayer_authority():
		return

	_remote_target_transform = new_transform
	_has_remote_target = true
