extends Node

@export var override_wall_layout: bool = false
@export var override_hole_position: bool = false
@export var override_marble_positions: bool = true
@export var override_marble_scale: bool = true

const LAYOUTS: Dictionary = {
	"classic": {
		"hole_position": Vector3(0.0, 0.108582, 14.6135),
		"walls": {
			"walls": {"position": Vector3(0.0, 1.02143, -19.47), "rotation": Vector3.ZERO, "scale": Vector3.ONE},
			"walls2": {"position": Vector3(-0.0325832, 0.0, 20.3325), "rotation": Vector3.ZERO, "scale": Vector3.ONE},
			"walls3": {"position": Vector3(0.0, 0.0, 0.111462), "rotation": Vector3(0.0, 89.34, 0.0), "scale": Vector3(2.0, 2.0, 2.0)},
			"walls4": {"position": Vector3(0.0, 0.0, -0.145052), "rotation": Vector3(0.0, -89.82, 0.0), "scale": Vector3(2.0, 2.0, 2.0)}
		},
		"marbles": {
			"PlayerMarble": Vector3(-2.4, 0.62, -8.0),
			"AI MARBLE1": Vector3(-1.2, 0.62, -8.0),
			"AI MARBLE2": Vector3(0.0, 0.62, -8.0),
			"AI MARBLE3": Vector3(1.2, 0.62, -8.0),
			"AI MARBLE4": Vector3(2.4, 0.62, -8.0)
		}
	}
}


func _ready() -> void:
	_apply_selected_field_layout()


func _apply_selected_field_layout() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null or not customization.has_method("get_selected_field_preset"):
		return

	var field_preset: Dictionary = customization.call("get_selected_field_preset")
	var layout_id: String = str(field_preset.get("layout_id", "classic"))
	var layout: Dictionary = LAYOUTS.get(layout_id, LAYOUTS["classic"])
	_apply_layout(layout)


func _apply_layout(layout: Dictionary) -> void:
	if override_wall_layout:
		_apply_wall_layout(layout.get("walls", {}))
	if override_hole_position:
		_apply_hole_position(layout.get("hole_position", Vector3(0.0, 0.108582, 14.6135)))
	if override_marble_positions:
		_apply_marble_positions(layout.get("marbles", {}))
	if override_marble_scale:
		_apply_marble_scale(float(layout.get("marble_scale", 1.0)))


func _apply_wall_layout(walls_layout: Dictionary) -> void:
	for wall_name in walls_layout.keys():
		var wall: Node3D = get_parent().get_node_or_null(str(wall_name)) as Node3D
		if wall == null:
			continue
		var data: Dictionary = walls_layout[wall_name]
		wall.position = data.get("position", wall.position)
		wall.rotation_degrees = data.get("rotation", wall.rotation_degrees)
		wall.scale = data.get("scale", wall.scale)


func _apply_hole_position(hole_position: Vector3) -> void:
	var hole: Node3D = get_parent().get_node_or_null("Hole") as Node3D
	if hole != null:
		hole.position = hole_position


func _apply_marble_positions(positions: Dictionary) -> void:
	var marbles_root: Node3D = get_parent().get_node_or_null("Marbles") as Node3D
	if marbles_root == null:
		return

	for marble_name in positions.keys():
		var marble: RigidBody3D = marbles_root.get_node_or_null(str(marble_name)) as RigidBody3D
		if marble == null:
			continue
		marble.position = positions[marble_name]
		marble.linear_velocity = Vector3.ZERO
		marble.angular_velocity = Vector3.ZERO
		marble.sleeping = false


func _apply_marble_scale(scale_value: float) -> void:
	var marbles_root: Node3D = get_parent().get_node_or_null("Marbles") as Node3D
	if marbles_root == null:
		return

	var final_scale: Vector3 = Vector3.ONE * maxf(scale_value, 0.1)
	for child in marbles_root.get_children():
		var marble: RigidBody3D = child as RigidBody3D
		if marble == null:
			continue
		marble.scale = final_scale
