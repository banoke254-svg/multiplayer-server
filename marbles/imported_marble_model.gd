@tool
extends Node3D

const TARGET_MARBLE_DIAMETER: float = 0.4

@export var preserve_imported_look: bool = false
@export var tint_imported_materials: bool = false
@export var imported_albedo_tint: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var imported_emission_tint: Color = Color(0.0, 0.0, 0.0, 1.0)
@export var imported_emission_energy: float = 0.0

var _source: Node3D = null


func _enter_tree() -> void:
	call_deferred("_configure_model")


func _ready() -> void:
	call_deferred("_configure_model")


func _configure_model() -> void:
	_source = get_node_or_null("Source") as Node3D
	if _source == null:
		return
	_source.visible = true

	if not preserve_imported_look:
		_strip_imported_illumination(_source)

	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(_source, meshes)
	if meshes.is_empty():
		return

	var bounds_ready: bool = false
	var combined_aabb: AABB = AABB()
	for mesh_instance in meshes:
		if mesh_instance.mesh == null:
			continue

		for corner in _aabb_corners(mesh_instance.mesh.get_aabb()):
			var corner_in_wrapper: Vector3 = to_local(mesh_instance.to_global(corner))
			if not bounds_ready:
				combined_aabb = AABB(corner_in_wrapper, Vector3.ZERO)
				bounds_ready = true
			else:
				combined_aabb = combined_aabb.expand(corner_in_wrapper)

	if not bounds_ready:
		return

	var largest_dimension: float = maxf(combined_aabb.size.x, maxf(combined_aabb.size.y, combined_aabb.size.z))
	if largest_dimension <= 0.0001:
		return

	var scale_factor: float = TARGET_MARBLE_DIAMETER / largest_dimension
	_source.position = (_source.position - combined_aabb.get_center()) * scale_factor
	_source.scale *= scale_factor
	if tint_imported_materials:
		_tint_imported_materials(_source)


func _tint_imported_materials(node: Node) -> void:
	for child in node.get_children():
		_tint_imported_materials(child)

	var mesh_instance := node as MeshInstance3D
	if mesh_instance == null:
		return

	if mesh_instance.material_override != null:
		mesh_instance.material_override = _tint_imported_material(mesh_instance.material_override)

	if mesh_instance.mesh == null:
		return
	for surface_index in range(mesh_instance.mesh.get_surface_count()):
		var material := mesh_instance.get_surface_override_material(surface_index)
		if material == null:
			material = mesh_instance.mesh.surface_get_material(surface_index)
		if material != null:
			mesh_instance.set_surface_override_material(surface_index, _tint_imported_material(material))


func _tint_imported_material(source: Material) -> Material:
	var standard := source as StandardMaterial3D
	if standard != null:
		var tinted_standard := standard.duplicate(true) as StandardMaterial3D
		if tinted_standard != null:
			var source_color: Color = tinted_standard.albedo_color
			tinted_standard.albedo_color = Color(
				source_color.r * imported_albedo_tint.r,
				source_color.g * imported_albedo_tint.g,
				source_color.b * imported_albedo_tint.b,
				source_color.a * imported_albedo_tint.a
			)
			if imported_emission_energy > 0.0:
				tinted_standard.emission_enabled = true
				tinted_standard.emission = imported_emission_tint
				tinted_standard.emission_energy_multiplier = imported_emission_energy
			return tinted_standard

	var shader_material := source as ShaderMaterial
	if shader_material != null:
		var tinted_shader := shader_material.duplicate(true) as ShaderMaterial
		if tinted_shader != null:
			for parameter_name in ["albedo", "albedo_color", "base_color", "color", "tint_color"]:
				tinted_shader.set_shader_parameter(parameter_name, imported_albedo_tint)
			if imported_emission_energy > 0.0:
				for parameter_name in ["emission", "emission_color", "glow_color"]:
					tinted_shader.set_shader_parameter(parameter_name, imported_emission_tint)
				for parameter_name in ["emission_strength", "emission_energy", "glow_strength"]:
					tinted_shader.set_shader_parameter(parameter_name, imported_emission_energy)
			return tinted_shader
	return source.duplicate(true) if source != null else source


func _collect_meshes(node: Node, meshes: Array[MeshInstance3D]) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			meshes.append(child as MeshInstance3D)
		_collect_meshes(child, meshes)


func _strip_imported_illumination(node: Node) -> void:
	for child in node.get_children():
		_strip_imported_illumination(child)

		if child is Light3D or child is WorldEnvironment or child is ReflectionProbe:
			child.queue_free()
			continue
		if child is GPUParticles3D or child is CPUParticles3D:
			child.queue_free()
			continue

	var mesh_instance := node as MeshInstance3D
	if mesh_instance == null:
		return

	if mesh_instance.material_override != null:
		mesh_instance.material_override = _clean_imported_material(mesh_instance.material_override)

	if mesh_instance.mesh == null:
		return
	for surface_index in range(mesh_instance.mesh.get_surface_count()):
		var material := mesh_instance.get_surface_override_material(surface_index)
		if material == null:
			material = mesh_instance.mesh.surface_get_material(surface_index)
		if material != null:
			mesh_instance.set_surface_override_material(surface_index, _clean_imported_material(material))


func _clean_imported_material(source: Material) -> Material:
	var shader_material := source as ShaderMaterial
	if shader_material != null:
		var cleaned_shader := shader_material.duplicate(true) as ShaderMaterial
		if cleaned_shader != null:
			cleaned_shader.set_shader_parameter("emission_strength", 0.0)
			cleaned_shader.set_shader_parameter("glow_strength", 0.0)
			cleaned_shader.set_shader_parameter("rim_strength", 0.0)
			cleaned_shader.set_shader_parameter("alpha_strength", 1.0)
			return cleaned_shader
		return source

	var standard := source as StandardMaterial3D
	if standard != null:
		var cleaned_standard := standard.duplicate(true) as StandardMaterial3D
		if cleaned_standard != null:
			_preserve_visible_imported_color(cleaned_standard)
			cleaned_standard.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			cleaned_standard.emission_enabled = false
			cleaned_standard.emission_energy_multiplier = 0.0
			cleaned_standard.albedo_color.a = 1.0
			return cleaned_standard
	return source.duplicate(true) if source != null else source


func _preserve_visible_imported_color(material: StandardMaterial3D) -> void:
	if material == null:
		return
	if material.albedo_texture == null and material.emission_texture != null:
		material.albedo_texture = material.emission_texture
	if not material.emission_enabled:
		return
	var emission_color: Color = material.emission
	if _color_luminance(emission_color) <= _color_luminance(material.albedo_color) + 0.04:
		return
	var alpha: float = material.albedo_color.a
	if _color_luminance(material.albedo_color) < 0.16:
		material.albedo_color = Color(emission_color.r, emission_color.g, emission_color.b, alpha)
	else:
		material.albedo_color = material.albedo_color.lerp(Color(emission_color.r, emission_color.g, emission_color.b, alpha), 0.35)


func _color_luminance(color: Color) -> float:
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722


func _aabb_corners(box: AABB) -> Array[Vector3]:
	var position: Vector3 = box.position
	var size: Vector3 = box.size
	return [
		position,
		position + Vector3(size.x, 0.0, 0.0),
		position + Vector3(0.0, size.y, 0.0),
		position + Vector3(0.0, 0.0, size.z),
		position + Vector3(size.x, size.y, 0.0),
		position + Vector3(size.x, 0.0, size.z),
		position + Vector3(0.0, size.y, size.z),
		position + size
	]
