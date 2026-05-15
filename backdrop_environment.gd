extends Node3D


func _ready() -> void:
	_disable_backdrop_shadows(self)


func _disable_backdrop_shadows(node: Node) -> void:
	for child in node.get_children():
		_disable_backdrop_shadows(child)

	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance == null:
		return

	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	mesh_instance.extra_cull_margin = maxf(mesh_instance.extra_cull_margin, 6.0)

	# Imported skyline scenes can include large transparent helper planes that
	# read like an invisible wall across the course. Hide obvious backdrop-only
	# panels while keeping the city silhouettes visible.
	if _looks_like_backdrop_panel(mesh_instance):
		mesh_instance.visible = false


func _looks_like_backdrop_panel(mesh_instance: MeshInstance3D) -> bool:
	if mesh_instance.mesh == null:
		return false

	var lowered_name := mesh_instance.name.to_lower()
	if "shadow" in lowered_name or "catcher" in lowered_name or "helper" in lowered_name:
		return true

	var aabb := mesh_instance.mesh.get_aabb()
	var size := aabb.size
	var largest := maxf(size.x, maxf(size.y, size.z))
	var smallest := minf(size.x, minf(size.y, size.z))
	if smallest <= 0.0:
		return false

	var flatness := largest / smallest
	if largest < 4.0 or flatness < 12.0:
		return _material_looks_like_backdrop_panel(mesh_instance)

	if _material_looks_like_backdrop_panel(mesh_instance):
		return true

	if "plane" in lowered_name or "glass" in lowered_name or "window" in lowered_name:
		return true

	# Some imported skyline helper quads are just giant thin strips with opaque materials.
	# Treat very flat meshes as backdrop panels even without transparent materials.
	return smallest < 0.35 and largest > 8.0


func _material_looks_like_backdrop_panel(mesh_instance: MeshInstance3D) -> bool:
	for material in _get_mesh_materials(mesh_instance):
		if material == null:
			continue

		var lowered_name := str(material.resource_name).to_lower()
		if "shadow" in lowered_name or "glass" in lowered_name or "window" in lowered_name:
			return true

		var standard_material := material as StandardMaterial3D
		if standard_material == null:
			continue

		if standard_material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
			return true

		if standard_material.albedo_color.a < 0.98:
			return true

	return false


func _get_mesh_materials(mesh_instance: MeshInstance3D) -> Array[Material]:
	var materials: Array[Material] = []
	if mesh_instance.material_override != null:
		materials.append(mesh_instance.material_override)

	for surface_index in range(mesh_instance.get_surface_override_material_count()):
		var override_material := mesh_instance.get_surface_override_material(surface_index)
		if override_material != null:
			materials.append(override_material)

	if mesh_instance.mesh != null:
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var surface_material := mesh_instance.mesh.surface_get_material(surface_index)
			if surface_material != null:
				materials.append(surface_material)

	return materials
