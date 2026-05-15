extends Node3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 2.35, -4.8)
@export var moving_offset: Vector3 = Vector3(0, 3.9, -8.8)
@export var follow_speed: float = 12.0
@export var transition_follow_speed: float = 8.5
@export var transition_duration: float = 0.12
@export var max_follow_speed: float = 30.0
@export var catch_up_distance: float = 4.8
@export var transition_end_distance: float = 0.65
@export var min_world_height: float = 1.3
@export var min_height_above_target: float = 1.55
@export var aim_yaw_follow_speed: float = 4.0
@export var look_follow_speed: float = 7.5
@export var touch_yaw_sensitivity: float = 0.003
@export var transition_position_tolerance: float = 0.14
@export var transition_rotation_tolerance_degrees: float = 3.2
@export var transition_ready_delay: float = 0.0
@export var motion_zoom_in_speed: float = 5.5
@export var motion_speed_start: float = 0.6
@export var motion_speed_full: float = 5.2
@export var look_ahead_distance: float = 2.4
@export var default_target_height: float = 0.22
@export var moving_target_height: float = 0.42
@export var default_fov: float = 74.0
@export var moving_fov: float = 82.0
@export var velocity_position_lead: float = 0.16
@export var max_position_lead: float = 2.8
@export var speed_follow_bonus: float = 1.4
@export var snap_catchup_distance: float = 7.0
@export var motion_vector_smoothing_speed: float = 5.0
@export var motion_yaw_follow_weight: float = 0.72
@export var target_position_smoothing_speed: float = 8.0

var slider: HSlider
var follow_camera: Camera3D
var touch_active := false
var last_touch_pos := Vector2.ZERO
var touch_yaw := 0.0
var smoothed_yaw := 0.0
var smoothed_look_target := Vector3.ZERO
var transition_time_left := 0.0
var turn_transition_active := false
var transition_ready_delay_left := 0.0
var motion_blend := 0.0
var smoothed_planar_velocity := Vector3.ZERO
var smoothed_position_lead := Vector3.ZERO
var smoothed_target_origin := Vector3.ZERO


func _ready() -> void:
	top_level = true
	slider = get_node_or_null("/root/Main/UI/CameraControlUI/CameraSlider") as HSlider
	if slider == null:
		var current_scene: Node = get_tree().current_scene
		if current_scene != null:
			slider = current_scene.get_node_or_null("UI/CameraControlUI/CameraSlider") as HSlider
	follow_camera = get_node_or_null("FollowCamera") as Camera3D
	if slider:
		touch_yaw = deg_to_rad(slider.value)
		smoothed_yaw = touch_yaw

	if target:
		smoothed_target_origin = target.global_transform.origin
		smoothed_look_target = smoothed_target_origin + Vector3.UP * default_target_height
		global_position = smoothed_target_origin + offset.rotated(Vector3.UP, smoothed_yaw)

	if follow_camera:
		follow_camera.fov = default_fov


func begin_turn_transition(from_camera: Camera3D = null) -> void:
	if from_camera != null:
		snap_to_camera(from_camera)
	else:
		transition_time_left = transition_duration

	if target:
		smoothed_target_origin = target.global_transform.origin
		smoothed_look_target = smoothed_target_origin + Vector3.UP * default_target_height

	turn_transition_active = true
	transition_ready_delay_left = transition_ready_delay


func is_turn_transition_finished() -> bool:
	return not turn_transition_active


func snap_to_camera(camera: Camera3D) -> void:
	if camera == null:
		return

	global_transform = camera.global_transform
	var forward: Vector3 = -camera.global_transform.basis.z
	smoothed_yaw = atan2(forward.x, forward.z)
	touch_yaw = smoothed_yaw
	smoothed_look_target = camera.global_transform.origin + forward * 3.0
	transition_time_left = transition_duration
	transition_ready_delay_left = transition_ready_delay


func _unhandled_input(event: InputEvent) -> void:
	if target and target.get("is_turn") == true:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			touch_active = true
			last_touch_pos = event.position
		else:
			touch_active = false
	elif event is InputEventScreenDrag and touch_active:
		var delta: Vector2 = event.position - last_touch_pos
		last_touch_pos = event.position
		touch_yaw += delta.x * touch_yaw_sensitivity


func _physics_process(delta: float) -> void:
	if not target:
		return

	var raw_target_origin: Vector3 = target.global_transform.origin
	var motion_ratio: float = _get_motion_ratio()
	motion_blend = move_toward(motion_blend, motion_ratio, delta * motion_zoom_in_speed)
	_update_motion_smoothing(delta)
	smoothed_target_origin = smoothed_target_origin.lerp(raw_target_origin, clampf(delta * target_position_smoothing_speed, 0.0, 1.0))
	var target_origin: Vector3 = smoothed_target_origin
	var desired_yaw: float = touch_yaw if touch_active else _get_slider_yaw()
	var desired_look_target: Vector3 = target_origin + Vector3.UP * lerpf(default_target_height, moving_target_height, motion_blend)
	var look_ahead: Vector3 = _get_motion_look_ahead(motion_blend)
	if look_ahead != Vector3.ZERO:
		desired_look_target += look_ahead

	if target.has_method("is_aiming") and target.is_aiming():
		var aim_direction: Vector3 = target.get_aim_direction()
		if aim_direction != Vector3.ZERO:
			desired_yaw = atan2(aim_direction.x, aim_direction.z)
			var power_ratio: float = target.get_aim_power_ratio() if target.has_method("get_aim_power_ratio") else 0.0
			desired_look_target = target_origin + Vector3.UP * default_target_height + aim_direction * lerpf(1.0, 2.1, power_ratio)
	elif not touch_active and motion_blend > 0.08:
		var motion_direction := _get_smoothed_motion_direction()
		if motion_direction != Vector3.ZERO:
			var motion_yaw := atan2(motion_direction.x, motion_direction.z)
			desired_yaw = motion_yaw

	smoothed_yaw = lerp_angle(smoothed_yaw, desired_yaw, clampf(delta * aim_yaw_follow_speed, 0.0, 1.0))
	smoothed_look_target = smoothed_look_target.lerp(desired_look_target, clampf(delta * look_follow_speed, 0.0, 1.0))
	var active_offset: Vector3 = offset.lerp(moving_offset, motion_blend)
	var rotated_offset: Vector3 = active_offset.rotated(Vector3.UP, smoothed_yaw)
	var position_lead: Vector3 = _get_position_lead()
	var desired_position: Vector3 = _clamped_desired_position(target_origin + position_lead + rotated_offset, target_origin)
	var distance_to_desired: float = global_transform.origin.distance_to(desired_position)
	var active_follow_speed: float = _get_dynamic_follow_speed(distance_to_desired, false)
	if transition_time_left > 0.0:
		transition_time_left = maxf(transition_time_left - delta, 0.0)
		active_follow_speed = _get_dynamic_follow_speed(distance_to_desired, true)
		if distance_to_desired <= transition_end_distance:
			transition_time_left = 0.0

	global_transform.origin = _move_towards_position(desired_position, delta, active_follow_speed)
	look_at(smoothed_look_target, Vector3.UP)
	_update_camera_fov(delta)
	_update_turn_transition_state(delta, desired_position)


func _get_slider_yaw() -> float:
	if slider:
		return deg_to_rad(slider.value)
	return touch_yaw


func _update_turn_transition_state(delta: float, desired_position: Vector3) -> void:
	if not turn_transition_active:
		return

	var position_error: float = global_transform.origin.distance_to(desired_position)
	var rotation_error: float = _get_look_angle_error()
	var still_transitioning := transition_time_left > 0.0
	still_transitioning = still_transitioning or position_error > transition_position_tolerance
	still_transitioning = still_transitioning or rotation_error > deg_to_rad(transition_rotation_tolerance_degrees)

	if still_transitioning:
		transition_ready_delay_left = transition_ready_delay
		return

	transition_ready_delay_left = maxf(transition_ready_delay_left - delta, 0.0)
	if transition_ready_delay_left <= 0.0:
		turn_transition_active = false


func _get_look_angle_error() -> float:
	var desired_forward: Vector3 = smoothed_look_target - global_transform.origin
	if desired_forward.length_squared() <= 0.0001:
		return 0.0

	desired_forward = desired_forward.normalized()
	var current_forward: Vector3 = -global_transform.basis.z.normalized()
	return acos(clampf(current_forward.dot(desired_forward), -1.0, 1.0))


func _clamped_desired_position(desired_position: Vector3, target_origin: Vector3) -> Vector3:
	var min_height: float = maxf(min_world_height, target_origin.y + min_height_above_target)
	desired_position.y = maxf(desired_position.y, min_height)
	return desired_position


func _move_towards_position(desired_position: Vector3, delta: float, speed: float) -> Vector3:
	var distance_to_desired: float = global_transform.origin.distance_to(desired_position)
	var move_step: float = speed * delta
	if distance_to_desired >= snap_catchup_distance:
		move_step *= 2.8

	var smoothed_position: Vector3 = global_transform.origin.move_toward(desired_position, move_step)
	smoothed_position.y = maxf(smoothed_position.y, desired_position.y)
	return smoothed_position


func _get_dynamic_follow_speed(distance_to_desired: float, transitioning: bool) -> float:
	var base_speed: float = transition_follow_speed if transitioning else follow_speed
	base_speed += _get_target_speed() * speed_follow_bonus
	if catch_up_distance <= 0.0:
		return minf(base_speed, max_follow_speed)

	var catch_up_ratio: float = clampf(distance_to_desired / catch_up_distance, 0.0, 1.0)
	return lerpf(base_speed, max_follow_speed, catch_up_ratio)


func _get_motion_ratio() -> float:
	if target is RigidBody3D:
		var body := target as RigidBody3D
		var speed: float = body.linear_velocity.length()
		if motion_speed_full <= motion_speed_start:
			return 1.0 if speed >= motion_speed_start else 0.0
		return clampf(inverse_lerp(motion_speed_start, motion_speed_full, speed), 0.0, 1.0)

	if target.has_method("is_moving") and target.is_moving():
		return 1.0

	return 0.0


func _get_motion_look_ahead(ratio: float) -> Vector3:
	if ratio <= 0.0:
		return Vector3.ZERO

	if smoothed_planar_velocity.length_squared() <= 0.0001:
		return Vector3.ZERO

	return smoothed_planar_velocity.normalized() * look_ahead_distance * ratio


func _get_position_lead() -> Vector3:
	return smoothed_position_lead


func _get_target_speed() -> float:
	if target is RigidBody3D:
		return (target as RigidBody3D).linear_velocity.length()
	return 0.0


func _update_motion_smoothing(delta: float) -> void:
	if not (target is RigidBody3D):
		smoothed_planar_velocity = smoothed_planar_velocity.lerp(Vector3.ZERO, clampf(delta * motion_vector_smoothing_speed, 0.0, 1.0))
		smoothed_position_lead = smoothed_position_lead.lerp(Vector3.ZERO, clampf(delta * motion_vector_smoothing_speed, 0.0, 1.0))
		return

	var body := target as RigidBody3D
	var planar_velocity := Vector3(body.linear_velocity.x, 0.0, body.linear_velocity.z)
	var smoothing := clampf(delta * motion_vector_smoothing_speed, 0.0, 1.0)
	smoothed_planar_velocity = smoothed_planar_velocity.lerp(planar_velocity, smoothing)

	var desired_lead := smoothed_planar_velocity * velocity_position_lead
	if desired_lead.length() > max_position_lead:
		desired_lead = desired_lead.normalized() * max_position_lead
	smoothed_position_lead = smoothed_position_lead.lerp(desired_lead, smoothing)


func _get_smoothed_motion_direction() -> Vector3:
	if smoothed_planar_velocity.length_squared() <= 0.0001:
		return Vector3.ZERO
	return smoothed_planar_velocity.normalized()


func _update_camera_fov(delta: float) -> void:
	if follow_camera == null:
		return

	var desired_fov: float = lerpf(default_fov, moving_fov, motion_blend)
	follow_camera.fov = lerpf(follow_camera.fov, desired_fov, clampf(delta * motion_zoom_in_speed, 0.0, 1.0))
