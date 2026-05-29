extends Node3D

@export var sync_ground_surface_colliders: bool = false
@export var ground_surface_collider_prefix: String = "AutoGroundSurfaceCollider"
@export var ground_surface_name_tokens: PackedStringArray = ["ground", "field"]
@export var ground_surface_excluded_name_tokens: PackedStringArray = ["grass", "clump", "tint", "visual", "collider"]
@export var ground_surface_padding: Vector3 = Vector3(0.0, 0.02, 0.0)
@export var ground_surface_min_thickness: float = 0.1
@export var ground_surface_max_thickness: float = 0.35
@export var ground_surface_min_span: float = 1.0
@export var disable_existing_ground_surface_colliders: bool = true
@export var generate_obstacle_colliders: bool = false
@export var collider_parent_name: String = "GeneratedObstacleColliders"
@export var min_obstacle_height: float = 0.28
@export var max_flat_surface_height: float = 0.22
@export var min_flat_surface_span: float = 1.8
@export var collider_padding: Vector3 = Vector3(0.04, 0.04, 0.04)

const AUTO_COLLIDER_NAME: String = "AutoObstacleCollider"


func _ready() -> void:
	if sync_ground_surface_colliders:
		call_deferred("_sync_ground_surface_colliders_deferred")
	else:
		_clear_ground_surface_colliders()
		_set_existing_ground_surface_colliders_disabled(false)

	if not generate_obstacle_colliders:
		_clear_generated_colliders()
		return
	_rebuild_colliders()


func _sync_ground_surface_colliders_deferred() -> void:
	if not is_inside_tree():
		return
	_rebuild_ground_surface_colliders()


func _rebuild_ground_surface_colliders() -> void:
	_clear_ground_surface_colliders()
	_set_existing_ground_surface_colliders_disabled(disable_existing_ground_surface_colliders)

	if not is_class("CollisionObject3D"):
		return

	var mesh_nodes: Array[MeshInstance3D] = []
	_collect_mesh_instances(self, mesh_nodes)
	for mesh_instance in mesh_nodes:
		if not _should_make_ground_surface_collider(mesh_instance):
			continue

		var shape := _make_ground_surface_shape(mesh_instance)
		if shape == null:
			continue

		var collision := CollisionShape3D.new()
		collision.name = "%s_%s" % [ground_surface_collider_prefix, mesh_instance.name]
		collision.shape = shape
		collision.set_meta("auto_ground_surface_collider", true)
		add_child(collision)
		collision.global_transform = _get_ground_surface_collision_transform(mesh_instance)


func _set_existing_ground_surface_colliders_disabled(disabled: bool) -> void:
	for child in get_children():
		var collision := child as CollisionShape3D
		if collision == null:
			continue
		if str(collision.name).begins_with(ground_surface_collider_prefix):
			continue
		if bool(collision.get_meta("auto_ground_surface_collider", false)):
			continue
		if collision.shape is BoxShape3D:
			collision.disabled = disabled


func _clear_ground_surface_colliders() -> void:
	for child in get_children():
		if child is CollisionShape3D and (
			str(child.name).begins_with(ground_surface_collider_prefix)
			or bool(child.get_meta("auto_ground_surface_collider", false))
		):
			child.queue_free()


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


func _should_make_ground_surface_collider(mesh_instance: MeshInstance3D) -> bool:
	if mesh_instance == null or mesh_instance.mesh == null:
		return false
	if not mesh_instance.visible:
		return false
	if mesh_instance.find_parent(collider_parent_name) != null:
		return false
	if str(mesh_instance.name).begins_with(ground_surface_collider_prefix):
		return false

	var clean_name: String = str(mesh_instance.name).to_lower()
	for token in ground_surface_excluded_name_tokens:
		var clean_excluded_token: String = str(token).strip_edges().to_lower()
		if clean_excluded_token != "" and clean_name.contains(clean_excluded_token):
			return false

	var mesh_size: Vector3 = _get_ground_surface_mesh_size(mesh_instance)
	if mesh_size == Vector3.ZERO:
		return false
	if mesh_size.y > ground_surface_max_thickness:
		return false
	if maxf(mesh_size.x, mesh_size.z) < ground_surface_min_span:
		return false

	var matched_name: bool = false
	for token in ground_surface_name_tokens:
		var clean_token: String = str(token).strip_edges().to_lower()
		if clean_token != "" and clean_name.contains(clean_token):
			matched_name = true
			break

	return matched_name or mesh_instance.get_parent() == self


func _make_ground_surface_shape(mesh_instance: MeshInstance3D) -> Shape3D:
	if mesh_instance.mesh is BoxMesh:
		var box_mesh := mesh_instance.mesh as BoxMesh
		var shape := BoxShape3D.new()
		shape.size = Vector3(
			maxf(box_mesh.size.x + ground_surface_padding.x, 0.01),
			maxf(box_mesh.size.y + ground_surface_padding.y, ground_surface_min_thickness),
			maxf(box_mesh.size.z + ground_surface_padding.z, 0.01)
		)
		return shape

	if mesh_instance.mesh is PlaneMesh:
		var plane_mesh := mesh_instance.mesh as PlaneMesh
		var shape := BoxShape3D.new()
		shape.size = Vector3(
			maxf(plane_mesh.size.x + ground_surface_padding.x, 0.01),
			maxf(ground_surface_min_thickness + ground_surface_padding.y, 0.01),
			maxf(plane_mesh.size.y + ground_surface_padding.z, 0.01)
		)
		return shape

	return null


func _get_ground_surface_mesh_size(mesh_instance: MeshInstance3D) -> Vector3:
	if mesh_instance.mesh is BoxMesh:
		return (mesh_instance.mesh as BoxMesh).size
	if mesh_instance.mesh is PlaneMesh:
		var plane_mesh := mesh_instance.mesh as PlaneMesh
		return Vector3(plane_mesh.size.x, ground_surface_min_thickness, plane_mesh.size.y)
	return Vector3.ZERO


func _get_ground_surface_collision_transform(mesh_instance: MeshInstance3D) -> Transform3D:
	if mesh_instance.mesh is BoxMesh:
		return mesh_instance.global_transform
	if mesh_instance.mesh is PlaneMesh:
		return mesh_instance.global_transform
	return mesh_instance.global_transform
