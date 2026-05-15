extends Node

@export var override_light_appearance: bool = false
@export var override_light_direction: bool = false


func _ready() -> void:
	_apply_selected_field_theme()


func _apply_selected_field_theme() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null or not customization.has_method("get_selected_field_preset"):
		return

	var preset: Dictionary = customization.call("get_selected_field_preset")
	var theme: Dictionary = preset.get("theme", {})
	if theme.is_empty():
		return

	_apply_ground_theme(theme)
	_apply_environment_theme(theme)
	_apply_lake_theme(theme)
	_apply_backdrop_visibility()


func _apply_ground_theme(theme: Dictionary) -> void:
	var ground: Node = get_parent().get_node_or_null("Ground")
	if ground == null:
		return

	var fairway_base: Color = theme.get("fairway_base", Color(0.34, 0.61, 0.31, 1.0))
	var fairway_light: Color = theme.get("fairway_light", Color(0.51, 0.72, 0.43, 1.0))
	var fairway_dark: Color = theme.get("fairway_dark", Color(0.24, 0.46, 0.25, 1.0))
	var dry_patch: Color = theme.get("dry_patch", Color(0.47, 0.58, 0.39, 1.0))

	for mesh_name in ["GroundNorth", "GroundSouth", "GroundLeft", "GroundRight"]:
		var mesh_instance: MeshInstance3D = ground.get_node_or_null(mesh_name) as MeshInstance3D
		if mesh_instance == null:
			continue
		var shader_material: ShaderMaterial = _get_or_make_shader_material(mesh_instance)
		if shader_material == null:
			continue
		shader_material.set_shader_parameter("fairway_base", fairway_base)
		shader_material.set_shader_parameter("fairway_light", fairway_light)
		shader_material.set_shader_parameter("fairway_dark", fairway_dark)
		shader_material.set_shader_parameter("dry_patch", dry_patch)
		shader_material.set_shader_parameter("stripe_scale", float(theme.get("stripe_scale", 13.5)))
		shader_material.set_shader_parameter("noise_scale", float(theme.get("noise_scale", 18.0)))

	var hole: Node = get_parent().get_node_or_null("Hole")
	if hole != null:
		hole.set("ground_blend_color", fairway_base.lerp(fairway_light, 0.22))


func _apply_environment_theme(theme: Dictionary) -> void:
	var world_environment: WorldEnvironment = get_parent().get_node_or_null("Ground/WorldEnvironment") as WorldEnvironment
	if world_environment != null and world_environment.environment != null:
		var environment: Environment = world_environment.environment
		var sky: Sky = environment.sky
		if sky != null and sky.sky_material is ProceduralSkyMaterial:
			var sky_material: ProceduralSkyMaterial = sky.sky_material.duplicate() as ProceduralSkyMaterial
			if sky_material != null:
				sky_material.sky_top_color = theme.get("sky_top", sky_material.sky_top_color)
				sky_material.sky_horizon_color = theme.get("sky_horizon", sky_material.sky_horizon_color)
				sky_material.ground_bottom_color = theme.get("ground_bottom", sky_material.ground_bottom_color)
				sky_material.ground_horizon_color = theme.get("ground_horizon", sky_material.ground_horizon_color)
				sky.sky_material = sky_material
		environment.ambient_light_color = theme.get("ambient_color", environment.ambient_light_color)
		environment.ambient_light_energy = float(theme.get("ambient_energy", environment.ambient_light_energy))
		environment.fog_enabled = false
		environment.glow_enabled = true
		environment.glow_intensity = minf(maxf(environment.glow_intensity, 0.02), 0.03)
		environment.glow_bloom = minf(maxf(environment.glow_bloom, 0.01), 0.02)
		environment.tonemap_mode = Environment.TONE_MAPPER_ACES

	var light: DirectionalLight3D = get_parent().get_node_or_null("Ground/WorldEnvironment/DirectionalLight3D") as DirectionalLight3D
	if light != null:
		if override_light_appearance:
			light.light_color = theme.get("sun_color", light.light_color)
			light.light_energy = float(theme.get("sun_energy", light.light_energy))
		if override_light_direction:
			var light_rotation: Variant = theme.get("sun_rotation_degrees", null)
			if light_rotation is Vector3:
				light.rotation_degrees = light_rotation


func _apply_lake_theme(theme: Dictionary) -> void:
	var lake_ring: Node3D = get_parent().get_node_or_null("Backdrop/LakeRing") as Node3D
	if lake_ring == null:
		return
	# The lake ring reads like a solid wall from low gameplay angles,
	# so keep it disabled for the playable field.
	lake_ring.visible = false

	var water: MeshInstance3D = lake_ring.get_node_or_null("Water") as MeshInstance3D
	if water == null:
		return

	var shader_material: ShaderMaterial = _get_or_make_shader_material(water)
	if shader_material == null:
		return
	shader_material.set_shader_parameter("shallow_color", theme.get("lake_shallow", Color(0.08, 0.34, 0.42, 1.0)))
	shader_material.set_shader_parameter("deep_color", theme.get("lake_deep", Color(0.03, 0.12, 0.18, 1.0)))
	shader_material.set_shader_parameter("foam_color", theme.get("lake_foam", Color(0.78, 0.94, 1.0, 1.0)))


func _apply_backdrop_visibility() -> void:
	var backdrop: Node = get_parent().get_node_or_null("Backdrop")
	if backdrop == null:
		return

	for child in backdrop.get_children():
		if not str(child.name).begins_with("Sketchfab_Scene"):
			continue
		var node_3d: Node3D = child as Node3D
		if node_3d != null:
			node_3d.visible = true


func _get_or_make_shader_material(mesh_instance: MeshInstance3D) -> ShaderMaterial:
	var material: Material = mesh_instance.material_override
	if material == null and mesh_instance.mesh != null and mesh_instance.mesh.get_surface_count() > 0:
		material = mesh_instance.mesh.surface_get_material(0)

	var shader_material: ShaderMaterial = material as ShaderMaterial
	if shader_material == null:
		return null

	var duplicated: ShaderMaterial = shader_material.duplicate() as ShaderMaterial
	mesh_instance.material_override = duplicated
	return duplicated
