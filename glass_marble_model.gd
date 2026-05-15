extends Node3D

var active_palette: Dictionary = {}
var active_type: String = "default"
var active_marble_instance: Node3D


func _ready() -> void:
	if not is_in_group("marbles"):
		add_to_group("marbles")
	_spawn_marble_scene()


func set_palette(palette: Dictionary) -> void:
	active_palette = palette.duplicate(true)
	active_type = _resolve_marble_type(active_palette)
	_spawn_marble_scene()


func _spawn_marble_scene() -> void:
	if active_marble_instance != null and is_instance_valid(active_marble_instance):
		active_marble_instance.queue_free()
	active_marble_instance = null

	var scene_path: String = str(active_palette.get("marble_scene_path", ""))
	if scene_path == "":
		var game_manager: Node = get_node("/root/GameManager") if is_inside_tree() and has_node("/root/GameManager") else null
		if game_manager == null or not game_manager.has_method("get_marble_scene_path"):
			return
		scene_path = str(game_manager.call("get_marble_scene_path", active_type))
	if scene_path == "" or not ResourceLoader.exists(scene_path):
		return

	var resource: Resource = load(scene_path)
	var packed_scene: PackedScene = resource as PackedScene
	if packed_scene == null:
		return

	var instance: Node = packed_scene.instantiate()
	active_marble_instance = instance as Node3D
	if active_marble_instance == null:
		if instance != null:
			instance.queue_free()
		return

	active_marble_instance.name = "MarbleVisual"
	_prepare_marble_visual(active_marble_instance)
	add_child(active_marble_instance)
	_force_configure_imported_marble_models(active_marble_instance)


func _resolve_marble_type(palette: Dictionary) -> String:
	if palette.has("marble_type"):
		return str(palette.get("marble_type"))
	var game_manager: Node = get_node("/root/GameManager") if is_inside_tree() and has_node("/root/GameManager") else null
	if game_manager != null and game_manager.has_method("resolve_marble_type"):
		return str(game_manager.call("resolve_marble_type", palette))
	return "default"


func _prepare_marble_visual(root: Node3D) -> void:
	_make_materials_unique(root)
	var allow_flame_effects := _uses_flame_marble_scene()
	_strip_visual_illumination(root, allow_flame_effects)
	if _uses_imported_model_scene():
		return
	_apply_visual_material_tweaks(root)
	_strip_visual_illumination(root, allow_flame_effects)


func _force_configure_imported_marble_models(root: Node) -> void:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		if current.has_method("_configure_model"):
			current.call("_configure_model")
		for child in current.get_children():
			stack.append(child)


func _make_materials_unique(root: Node) -> void:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		for child in current.get_children():
			stack.append(child)

		var mesh_instance := current as MeshInstance3D
		if mesh_instance == null:
			continue

		if mesh_instance.material_override != null:
			mesh_instance.material_override = mesh_instance.material_override.duplicate(true)

		var mesh := mesh_instance.mesh
		if mesh == null:
			continue

		for surface_index in range(mesh.get_surface_count()):
			var override_material := mesh_instance.get_surface_override_material(surface_index)
			if override_material != null:
				mesh_instance.set_surface_override_material(surface_index, override_material.duplicate(true))
				continue

			var surface_material := mesh.surface_get_material(surface_index)
			if surface_material != null:
				mesh_instance.set_surface_override_material(surface_index, surface_material.duplicate(true))


func _apply_visual_material_tweaks(root: Node) -> void:
	var finish: String = str(active_palette.get("finish", "")).to_lower()
	var glass_like: bool = finish in ["glass", "metal"] or bool(active_palette.get("shell_is_solid", false))

	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		for child in current.get_children():
			stack.append(child)

		var mesh_instance := current as MeshInstance3D
		if mesh_instance == null:
			continue
		mesh_instance.extra_cull_margin = maxf(mesh_instance.extra_cull_margin, 1.5)

		var materials: Array[Material] = []
		if mesh_instance.material_override != null:
			materials.append(mesh_instance.material_override)
		for surface_index in range(mesh_instance.get_surface_override_material_count()):
			var override_material := mesh_instance.get_surface_override_material(surface_index)
			if override_material != null:
				materials.append(override_material)

		for material in materials:
			var standard := material as StandardMaterial3D
			if standard == null:
				continue
			var has_imported_textures: bool = standard.albedo_texture != null or standard.normal_texture != null or standard.orm_texture != null
			if has_imported_textures:
				# Imported textured marbles should keep their authored look.
				continue

			if glass_like:
				standard.roughness = minf(standard.roughness, 0.16)
				standard.metallic = 0.0
				standard.set("metallic_specular", 0.82)
			standard.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			standard.emission_enabled = false
			standard.emission_energy_multiplier = 0.0
			standard.albedo_color.a = clampf(standard.albedo_color.a, 0.9, 0.96)


func _strip_visual_illumination(root: Node, allow_flame_effects: bool = false) -> void:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		for child in current.get_children():
			stack.append(child)

		if current != root and _is_illumination_node(current, allow_flame_effects):
			current.queue_free()
			continue

		var mesh_instance := current as MeshInstance3D
		if mesh_instance == null:
			continue

		if mesh_instance.material_override != null:
			mesh_instance.material_override = _make_non_illuminated_material(mesh_instance.material_override)

		if mesh_instance.mesh == null:
			continue
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var material := mesh_instance.get_surface_override_material(surface_index)
			if material == null:
				material = mesh_instance.mesh.surface_get_material(surface_index)
			if material != null:
				mesh_instance.set_surface_override_material(surface_index, _make_non_illuminated_material(material))


func _is_illumination_node(node: Node, allow_flame_effects: bool) -> bool:
	var lowered_name := str(node.name).to_lower()
	if node is Light3D or node is WorldEnvironment or node is ReflectionProbe:
		return true
	if node is GPUParticles3D or node is CPUParticles3D:
		return not (allow_flame_effects and lowered_name.find("flame") != -1)
	if lowered_name.find("flamecrown") != -1:
		return not allow_flame_effects
	return false


func _make_non_illuminated_material(source: Material) -> Material:
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


func _uses_imported_model_scene() -> bool:
	var scene_path: String = str(active_palette.get("marble_scene_path", "")).to_lower()
	if scene_path == "":
		return false
	return scene_path.ends_with("_model.tscn") or scene_path.ends_with("marble_glass_ball_ii.tscn") or scene_path.ends_with("marble_aura.tscn")


func _uses_flame_marble_scene() -> bool:
	var scene_path: String = str(active_palette.get("marble_scene_path", "")).to_lower()
	var marble_type: String = str(active_palette.get("marble_type", "")).to_lower()
	var pattern_name: String = str(active_palette.get("pattern_name", "")).to_lower()
	return scene_path.find("flame") != -1 or marble_type == "flame" or pattern_name == "flame"
