extends Node3D

@export var generate_obstacle_colliders: bool = false
@export var collider_parent_name: String = "GeneratedObstacleColliders"
@export var min_obstacle_height: float = 0.28
@export var max_flat_surface_height: float = 0.22
@export var min_flat_surface_span: float = 1.8
@export var collider_padding: Vector3 = Vector3(0.04, 0.04, 0.04)

const AUTO_COLLIDER_NAME: String = "AutoObstacleCollider"


func _ready() -> void:
	if not generate_obstacle_colliders:
		_clear_generated_colliders()
		return
	_rebuild_colliders()


func _rebuild_colliders() -> void:
	if not is_visible_in_tree():
		_clear_generated_colliders()
		return

	var collider_root := get_node_or_null(collider_parent_name) as Node3D
	if collider_root == null:
		collider_root = Node3D.new()
		collider_root.name = collider_parent_name
		add_child(collider_root)

	for child in collider_root.get_children():
		child.queue_free()

	var mesh_nodes: Array[MeshInstance3D] = []
	_collect_mesh_instances(self, mesh_nodes)
	for mesh_instance in mesh_nodes:
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		if mesh_instance.name == collider_parent_name:
			continue
		var existing := mesh_instance.get_node_or_null(AUTO_COLLIDER_NAME)
		if existing:
			existing.queue_free()

		var aabb: AABB = mesh_instance.mesh.get_aabb()
		if aabb.size == Vector3.ZERO:
			continue
		if _should_skip_mesh(aabb.size):
			continue

		var body := StaticBody3D.new()
		body.name = AUTO_COLLIDER_NAME
		mesh_instance.add_child(body)

		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = aabb.size + collider_padding
		collision.shape = shape
		collision.position = aabb.get_center()
		body.add_child(collision)


func _clear_generated_colliders() -> void:
	var collider_root := get_node_or_null(collider_parent_name)
	if collider_root != null:
		collider_root.queue_free()

	var mesh_nodes: Array[MeshInstance3D] = []
	_collect_mesh_instances(self, mesh_nodes)
	for mesh_instance in mesh_nodes:
		var existing := mesh_instance.get_node_or_null(AUTO_COLLIDER_NAME)
		if existing:
			existing.queue_free()


func _collect_mesh_instances(node: Node, output: Array[MeshInstance3D]) -> void:
	for child in node.get_children():
		if child.name == collider_parent_name:
			continue
		if child is MeshInstance3D:
			output.append(child as MeshInstance3D)
		_collect_mesh_instances(child, output)


func _should_skip_mesh(size: Vector3) -> bool:
	var horizontal_span: float = maxf(size.x, size.z)
	if size.y <= max_flat_surface_height and horizontal_span >= min_flat_surface_span:
		return true
	return size.y < min_obstacle_height
