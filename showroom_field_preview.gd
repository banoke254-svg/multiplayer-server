extends Node3D

@export var preview_style: String = "garden"


func _ready() -> void:
	_build_preview()


func set_theme(theme: Dictionary) -> void:
	_apply_theme(theme)


func _build_preview() -> void:
	for child in get_children():
		child.queue_free()

	var turf: MeshInstance3D = MeshInstance3D.new()
	turf.name = "Turf"
	var turf_mesh: BoxMesh = BoxMesh.new()
	turf_mesh.size = Vector3(5.8, 0.18, 10.8)
	turf.mesh = turf_mesh
	turf.position = Vector3(0.0, -0.1, 0.0)
	turf.material_override = _make_standard(Color(0.34, 0.61, 0.31, 1.0), 0.86, 0.04)
	add_child(turf)

	var water_ring: MeshInstance3D = MeshInstance3D.new()
	water_ring.name = "WaterRing"
	var water_mesh: BoxMesh = BoxMesh.new()
	water_mesh.size = Vector3(8.6, 0.08, 13.8)
	water_ring.mesh = water_mesh
	water_ring.position = Vector3(0.0, -0.16, 0.0)
	water_ring.material_override = _make_standard(Color(0.08, 0.34, 0.42, 1.0), 0.12, 0.18, true, Color(0.78, 0.94, 1.0, 1.0), 0.22)
	add_child(water_ring)

	_add_course_edges()
	_add_hole_marker()
	_add_preview_marble()

	match preview_style:
		"harbor":
			_add_arches(6, 4.3, Vector3(0.28, 0.84, 0.54), Color(0.28, 0.18, 0.12, 1.0))
		"aurora":
			_add_shards(7, 4.1, Vector3(0.2, 1.3, 0.12), Color(0.62, 0.94, 1.0, 1.0))
		"ember":
			_add_spires(8, 4.0, Vector3(0.16, 1.15, 0.16), Color(0.46, 0.16, 0.08, 1.0))
			_add_crown_ring(Color(1.0, 0.56, 0.22, 1.0), 0.24)
		"neon":
			_add_panels(8, 4.1, Vector3(0.22, 1.02, 0.06), Color(0.08, 0.22, 0.28, 1.0))
			_add_crown_ring(Color(0.22, 0.94, 0.78, 1.0), 0.18)
		_:
			_add_arches(5, 4.0, Vector3(0.22, 0.72, 0.18), Color(0.14, 0.32, 0.18, 1.0))


func _apply_theme(theme: Dictionary) -> void:
	var turf: MeshInstance3D = get_node_or_null("Turf") as MeshInstance3D
	if turf != null:
		var turf_material: StandardMaterial3D = turf.material_override as StandardMaterial3D
		if turf_material != null:
			turf_material.albedo_color = theme.get("fairway_base", turf_material.albedo_color)
			turf_material.emission_enabled = true
			turf_material.emission = theme.get("fairway_light", turf_material.albedo_color)
			turf_material.emission_energy_multiplier = 0.1

	var water_ring: MeshInstance3D = get_node_or_null("WaterRing") as MeshInstance3D
	if water_ring != null:
		var water_material: StandardMaterial3D = water_ring.material_override as StandardMaterial3D
		if water_material != null:
			water_material.albedo_color = theme.get("lake_shallow", water_material.albedo_color)
			water_material.emission = theme.get("lake_foam", Color(0.78, 0.94, 1.0, 1.0))

	var hole_rim: MeshInstance3D = get_node_or_null("HoleRim") as MeshInstance3D
	if hole_rim != null:
		var hole_rim_material: StandardMaterial3D = hole_rim.material_override as StandardMaterial3D
		if hole_rim_material != null:
			hole_rim_material.emission = theme.get("showroom_rim", hole_rim_material.emission)

	var hole_glow: MeshInstance3D = get_node_or_null("HoleGlow") as MeshInstance3D
	if hole_glow != null:
		var hole_glow_material: StandardMaterial3D = hole_glow.material_override as StandardMaterial3D
		if hole_glow_material != null:
			hole_glow_material.emission = theme.get("showroom_light", hole_glow_material.emission)

	for child in get_children():
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		if mesh_instance == null or mesh_instance.name in ["Turf", "WaterRing", "HoleBowl", "HoleRim", "HoleGlow", "PreviewMarble"]:
			continue
		var material: StandardMaterial3D = mesh_instance.material_override as StandardMaterial3D
		if material == null:
			continue
		match preview_style:
			"aurora":
				material.albedo_color = theme.get("showroom_rim", material.albedo_color)
				material.emission = theme.get("showroom_light", material.albedo_color)
			"ember":
				material.albedo_color = theme.get("showroom_platform", material.albedo_color)
				material.emission = theme.get("showroom_light", Color(1.0, 0.48, 0.18, 1.0))
			"neon":
				material.albedo_color = theme.get("showroom_platform", material.albedo_color)
				material.emission = theme.get("showroom_rim", material.albedo_color)
			_:
				material.albedo_color = theme.get("showroom_platform", material.albedo_color)
				material.emission = theme.get("showroom_light", material.albedo_color)


func _add_course_edges() -> void:
	_add_edge("NorthEdge", Vector3(0.0, 0.22, -5.15), Vector3(6.1, 0.36, 0.34))
	_add_edge("SouthEdge", Vector3(0.0, 0.22, 5.15), Vector3(6.1, 0.36, 0.34))
	_add_edge("WestEdge", Vector3(-2.9, 0.22, 0.0), Vector3(0.34, 0.36, 10.0))
	_add_edge("EastEdge", Vector3(2.9, 0.22, 0.0), Vector3(0.34, 0.36, 10.0))


func _add_edge(node_name: String, position: Vector3, size: Vector3) -> void:
	var edge: MeshInstance3D = MeshInstance3D.new()
	edge.name = node_name
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	edge.mesh = mesh
	edge.position = position
	edge.material_override = _make_standard(Color(0.84, 0.9, 0.98, 1.0), 0.18, 0.32, true, Color(0.76, 0.88, 1.0, 1.0), 0.08)
	add_child(edge)


func _add_hole_marker() -> void:
	var hole_bowl: MeshInstance3D = MeshInstance3D.new()
	hole_bowl.name = "HoleBowl"
	var hole_bowl_mesh: CylinderMesh = CylinderMesh.new()
	hole_bowl_mesh.top_radius = 0.24
	hole_bowl_mesh.bottom_radius = 0.18
	hole_bowl_mesh.height = 0.18
	hole_bowl.mesh = hole_bowl_mesh
	hole_bowl.position = Vector3(0.0, -0.09, 3.95)
	hole_bowl.material_override = _make_standard(Color(0.03, 0.05, 0.07, 1.0), 0.96, 0.0)
	add_child(hole_bowl)

	var hole_rim: MeshInstance3D = MeshInstance3D.new()
	hole_rim.name = "HoleRim"
	var hole_rim_mesh: TorusMesh = TorusMesh.new()
	hole_rim_mesh.inner_radius = 0.26
	hole_rim_mesh.outer_radius = 0.34
	hole_rim.mesh = hole_rim_mesh
	hole_rim.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	hole_rim.position = Vector3(0.0, -0.005, 3.95)
	hole_rim.material_override = _make_standard(Color(0.86, 0.92, 1.0, 1.0), 0.08, 0.12, true, Color(0.76, 0.9, 1.0, 1.0), 0.16)
	add_child(hole_rim)

	var hole_glow: MeshInstance3D = MeshInstance3D.new()
	hole_glow.name = "HoleGlow"
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.48
	mesh.bottom_radius = 0.58
	mesh.height = 0.08
	hole_glow.mesh = mesh
	hole_glow.position = Vector3(0.0, -0.06, 3.95)
	hole_glow.material_override = _make_standard(Color(0.06, 0.1, 0.14, 0.0), 0.12, 0.1, true, Color(0.72, 0.9, 1.0, 1.0), 0.14)
	add_child(hole_glow)


func _add_preview_marble() -> void:
	var marble: MeshInstance3D = MeshInstance3D.new()
	marble.name = "PreviewMarble"
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.24
	mesh.height = 0.48
	marble.mesh = mesh
	marble.position = Vector3(0.0, 0.08, -3.7)
	marble.material_override = _make_standard(Color(0.96, 0.98, 1.0, 1.0), 0.08, 0.12, true, Color(1.0, 1.0, 1.0, 1.0), 0.1)
	add_child(marble)


func _add_arches(count: int, radius: float, size: Vector3, color: Color) -> void:
	for index in range(count):
		var angle: float = TAU * float(index) / float(count)
		var arch: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = size
		arch.mesh = mesh
		arch.position = Vector3(cos(angle) * radius, size.y * 0.5 - 0.05, sin(angle) * radius)
		arch.rotation_degrees.y = rad_to_deg(-angle)
		arch.material_override = _make_standard(color, 0.54, 0.08, true, color.lightened(0.25), 0.1)
		add_child(arch)


func _add_shards(count: int, radius: float, size: Vector3, color: Color) -> void:
	for index in range(count):
		var angle: float = TAU * float(index) / float(count)
		var shard: MeshInstance3D = MeshInstance3D.new()
		var mesh: PrismMesh = PrismMesh.new()
		mesh.size = size
		shard.mesh = mesh
		shard.position = Vector3(cos(angle) * radius, size.y * 0.5 - 0.12, sin(angle) * radius)
		shard.rotation_degrees = Vector3(-12.0, rad_to_deg(-angle), 0.0)
		shard.material_override = _make_standard(color, 0.18, 0.02, true, color, 0.32)
		add_child(shard)


func _add_spires(count: int, radius: float, size: Vector3, color: Color) -> void:
	for index in range(count):
		var angle: float = TAU * float(index) / float(count)
		var spire: MeshInstance3D = MeshInstance3D.new()
		var mesh: CylinderMesh = CylinderMesh.new()
		mesh.top_radius = size.x * 0.18
		mesh.bottom_radius = size.x * 0.52
		mesh.height = size.y
		spire.mesh = mesh
		spire.position = Vector3(cos(angle) * radius, size.y * 0.5 - 0.08, sin(angle) * radius)
		spire.material_override = _make_standard(color, 0.42, 0.06, true, color.lightened(0.4), 0.18)
		add_child(spire)


func _add_panels(count: int, radius: float, size: Vector3, color: Color) -> void:
	for index in range(count):
		var angle: float = TAU * float(index) / float(count)
		var panel: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = size
		panel.mesh = mesh
		panel.position = Vector3(cos(angle) * radius, size.y * 0.5 - 0.05, sin(angle) * radius)
		panel.rotation_degrees.y = rad_to_deg(-angle)
		panel.material_override = _make_standard(color, 0.14, 0.4, true, Color(0.26, 0.98, 0.82, 1.0), 0.26)
		add_child(panel)


func _add_crown_ring(color: Color, y: float) -> void:
	var ring: MeshInstance3D = MeshInstance3D.new()
	var mesh: TorusMesh = TorusMesh.new()
	mesh.inner_radius = 2.5
	mesh.outer_radius = 2.62
	ring.mesh = mesh
	ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	ring.position = Vector3(0.0, y, 0.0)
	ring.material_override = _make_standard(color, 0.06, 0.2, true, color, 0.42)
	add_child(ring)


func _make_standard(color: Color, roughness: float, metallic: float, emission_enabled: bool = false, emission: Color = Color(0, 0, 0, 1), emission_energy: float = 0.0) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	material.emission_enabled = emission_enabled
	material.emission = emission
	material.emission_energy_multiplier = emission_energy
	return material
