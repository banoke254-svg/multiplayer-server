extends Camera3D

@export var marble_path: NodePath
@export var follow_distance: float = 10.0
@export var follow_height: float = 5.0
@export var follow_speed: float = 5.0

var marble: Node3D

func _ready():
	marble = get_node(marble_path)

func _process(delta):
	if marble:
		# Desired position is behind and above the marble
		var target_position = marble.global_transform.origin
		var direction = -marble.global_transform.basis.z.normalized()
		var desired_position = target_position + direction * follow_distance
		desired_position.y += follow_height

		# Smoothly move the camera
		global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_speed)

		# Look at the marble (but clamp vertical rotation to prevent shaking)
		look_at(target_position, Vector3.UP)
