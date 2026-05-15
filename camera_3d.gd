extends Camera3D

@export var target_path: NodePath
var target: RigidBody3D

func _ready():
	target = get_node(target_path)

func _process(delta):
	if target:
		var desired_position = target.global_transform.origin + Vector3(0, 5, -10)
		global_transform.origin = global_transform.origin.lerp(desired_position, 5 * delta)
		look_at(target.global_transform.origin, Vector3.UP)
