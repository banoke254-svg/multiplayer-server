@tool
extends Node3D

var _source: Node3D


func _enter_tree() -> void:
	call_deferred("_configure_model")


func _ready() -> void:
	call_deferred("_configure_model")


func _configure_model() -> void:
	_source = get_node_or_null("Source") as Node3D
	if _source == null:
		return

	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(_source, meshes)
	if meshes.is_empty():
		return

	var primary_mesh: MeshInstance3D = meshes[0]
	for mesh_instance in meshes:
		mesh_instance.visible = mesh_instance == primary_mesh

	var mesh_center_local: Vector3 = _get_mesh_center_local(primary_mesh)
	var mesh_center_in_wrapper: Vector3 = to_local(primary_mesh.to_global(mesh_center_local))
	_source.position = -mesh_center_in_wrapper


func _collect_meshes(node: Node, meshes: Array[MeshInstance3D]) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			meshes.append(child as MeshInstance3D)
		_collect_meshes(child, meshes)


func _get_mesh_center_local(mesh_instance: MeshInstance3D) -> Vector3:
	if mesh_instance.mesh == null:
		return Vector3.ZERO
	return mesh_instance.mesh.get_aabb().get_center()
