extends Node3D

@export var marble_path: NodePath
@onready var marble = get_node(marble_path)
@onready var follow_target = $FollowTarget

var follow_distance := 5.0
var height := 3.0
var smooth_speed := 6.0

func _process(delta):
	if marble:
		var marble_pos = marble.global_transform.origin
		var direction = (marble.linear_velocity).normalized()
		
		if direction.length() < 0.1:
			direction = -marble.transform.basis.z.normalized()  # fallback to facing forward

		var target_pos = marble_pos - direction * follow_distance
		target_pos.y += height

		global_transform.origin = global_transform.origin.lerp(target_pos, delta * smooth_speed)
		follow_target.look_at(marble_pos, Vector3.UP)
