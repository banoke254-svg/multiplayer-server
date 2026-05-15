extends Node3D

@export var generate_mesh_collisions: bool = false
@export var add_ground_collision_box: bool = false
@export var ground_collision_height: float = 1.2
@export var ground_collision_y_offset: float = 0.0
@export var use_custom_ground_collision_box: bool = false
@export var ground_collision_center: Vector3 = Vector3.ZERO
@export var ground_collision_size: Vector3 = Vector3(20.0, 1.0, 40.0)
@export var remove_source_collisions: bool = true
@export var disable_mesh_shadows: bool = true

var collision_root: StaticBody3D


func _ready() -> void:
	call_deferred("_rebuild_collisions")


func _rebuild_collisions() -> void:
	_clear_collision_root()

	if remove_source_collisions:
		_strip_source_collision_nodes(self)

	if disable_mesh_shadows:
		_disable_mesh_shadows(self)

	if not generate_mesh_collisions and not add_ground_collision_box:
		return

	collision_root = StaticBody3D.new()
	collision_root.name = "TerrainCollision"
	add_child(collision_root)

	if generate_mesh_collisions:
		var stack: Array[Node] = [self]
		while not stack.is_empty():
			var current: Node = stack.pop_back()
			for child in current.get_children():
				if child == collision_root:
					continue
				stack.append(child)

			var mesh_instance: MeshInstance3D = current as MeshInstance3D
			if mesh_instance == null or mesh_instance.mesh == null:
				continue

			var collision_shape: ConcavePolygonShape3D = mesh_instance.mesh.create_trimesh_shape()
			if collision_shape == null:
				continue

			var collision_node: CollisionShape3D = CollisionShape3D.new()
			collision_node.shape = collision_shape
			collision_node.transform = global_transform.affine_inverse() * mesh_instance.global_transform
			collision_root.add_child(collision_node)

	if add_ground_collision_box:
		_add_ground_collision_box()


func _add_ground_collision_box() -> void:
	if collision_root == null:
		return

	if use_custom_ground_collision_box:
		var custom_shape: BoxShape3D = BoxShape3D.new()
		custom_shape.size = Vector3(
			maxf(ground_collision_size.x, 0.1),
			maxf(ground_collision_size.y, 0.1),
			maxf(ground_collision_size.z, 0.1)
		)
		var custom_collision: CollisionShape3D = CollisionShape3D.new()
		custom_collision.name = "GeneratedGroundCollision"
		custom_collision.shape = custom_shape
		custom_collision.position = ground_collision_center
		collision_root.add_child(custom_collision)
		return

	var bounds: AABB = _get_node_bounds(self)
	if bounds.size.x <= 0.001 or bounds.size.z <= 0.001:
		return

	var floor_shape: BoxShape3D = BoxShape3D.new()
	floor_shape.size = Vector3(bounds.size.x, maxf(ground_collision_height, 0.1), bounds.size.z)

	var floor_collision: CollisionShape3D = CollisionShape3D.new()
	floor_collision.name = "GeneratedGroundCollision"
	floor_collision.shape = floor_shape
	floor_collision.position = Vector3(
		bounds.get_center().x,
		bounds.position.y - (floor_shape.size.y * 0.5) + ground_collision_y_offset,
		bounds.get_center().z
	)
	collision_root.add_child(floor_collision)


func _disable_mesh_shadows(root: Node3D) -> void:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		for child in current.get_children():
			if child == collision_root:
				continue
			stack.append(child)
		var mesh_instance: MeshInstance3D = current as MeshInstance3D
		if mesh_instance != null:
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _get_node_bounds(root: Node3D) -> AABB:
	var has_bounds: bool = false
	var combined: AABB = AABB()
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		for child in current.get_children():
			if child == collision_root:
				continue
			stack.append(child)

		var mesh_instance: MeshInstance3D = current as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue

		var local_aabb: AABB = mesh_instance.mesh.get_aabb()
		var corners: Array[Vector3] = [
			local_aabb.position,
			local_aabb.position + Vector3(local_aabb.size.x, 0.0, 0.0),
			local_aabb.position + Vector3(0.0, local_aabb.size.y, 0.0),
			local_aabb.position + Vector3(0.0, 0.0, local_aabb.size.z),
			local_aabb.position + Vector3(local_aabb.size.x, local_aabb.size.y, 0.0),
			local_aabb.position + Vector3(local_aabb.size.x, 0.0, local_aabb.size.z),
			local_aabb.position + Vector3(0.0, local_aabb.size.y, local_aabb.size.z),
			local_aabb.position + local_aabb.size
		]

		for corner in corners:
			var world_corner: Vector3 = mesh_instance.global_transform * corner
			if not has_bounds:
				combined = AABB(world_corner, Vector3.ZERO)
				has_bounds = true
			else:
				combined = combined.expand(world_corner)

	return combined if has_bounds else AABB()


func _clear_collision_root() -> void:
	var existing_collision_root: Node = get_node_or_null("TerrainCollision")
	if existing_collision_root != null:
		existing_collision_root.queue_free()
		await existing_collision_root.tree_exited
	collision_root = null


func _strip_source_collision_nodes(root: Node) -> void:
	for child in root.get_children():
		if child == collision_root:
			continue
		if child is CollisionObject3D or child is CollisionShape3D or child is CollisionPolygon3D:
			child.queue_free()
			continue
		_strip_source_collision_nodes(child)
