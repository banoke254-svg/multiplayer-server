@tool
extends StaticBody3D

@export var outer_radius: float = 1.82:
	set(value):
		outer_radius = value
		_rebuild_hole()
@export var entry_radius: float = 1.52:
	set(value):
		entry_radius = value
		_rebuild_hole()
@export var neck_radius: float = 1.28:
	set(value):
		neck_radius = value
		_rebuild_hole()
@export var pocket_radius: float = 1.02:
	set(value):
		pocket_radius = value
		_rebuild_hole()
@export var depth: float = 1.02:
	set(value):
		depth = value
		_rebuild_hole()
@export var lip_width: float = 0.0:
	set(value):
		lip_width = value
		_rebuild_hole()
@export var lip_height: float = 0.0:
	set(value):
		lip_height = value
		_rebuild_hole()
@export var radial_segments: int = 40:
	set(value):
		radial_segments = max(value, 12)
		_rebuild_hole()
@export var hole_color: Color = Color(0.02, 0.045, 0.03, 1.0):
	set(value):
		hole_color = value
		_rebuild_hole()
@export var ground_blend_color: Color = Color(0.34, 0.61, 0.31, 1.0):
	set(value):
		ground_blend_color = value
		_rebuild_hole()
@export var blend_ring_outer_padding: float = 0.34:
	set(value):
		blend_ring_outer_padding = max(value, 0.2)
		_rebuild_hole()
@export var trap_force: float = 3.5
@export var trapped_linear_damp: float = 1.35
@export var trapped_angular_damp: float = 1.1
@export var max_trapped_upward_velocity: float = 0.8
@export var bottom_stop_radius_scale: float = 0.86:
	set(value):
		bottom_stop_radius_scale = value
		_update_bottom_stop_shape()
@export var bottom_stop_height: float = 0.18:
	set(value):
		bottom_stop_height = value
		_update_bottom_stop_shape()
@export var bottom_stop_lift: float = 0.08:
	set(value):
		bottom_stop_lift = value
		_update_bottom_stop_shape()
@export var seam_guard_enabled: bool = true:
	set(value):
		seam_guard_enabled = value
		_update_seam_guards()
@export var seam_guard_segments: int = 20:
	set(value):
		seam_guard_segments = max(value, 8)
		_update_seam_guards()
@export var seam_guard_radial_thickness: float = 0.18:
	set(value):
		seam_guard_radial_thickness = max(value, 0.04)
		_update_seam_guards()
@export var seam_guard_height: float = 0.08:
	set(value):
		seam_guard_height = max(value, 0.02)
		_update_seam_guards()
@export var seam_guard_y_offset: float = -0.035:
	set(value):
		seam_guard_y_offset = value
		_update_seam_guards()
@export var seam_guard_outer_bias: float = 0.05:
	set(value):
		seam_guard_outer_bias = value
		_update_seam_guards()
@export var floor_support_enabled: bool = true:
	set(value):
		floor_support_enabled = value
		_update_floor_supports()
@export var floor_support_outer_radius: float = 2.02:
	set(value):
		floor_support_outer_radius = max(value, outer_radius + 0.02)
		_update_floor_supports()
@export var floor_support_inner_overlap: float = 0.05:
	set(value):
		floor_support_inner_overlap = clampf(value, 0.0, 0.4)
		_update_floor_supports()
@export var floor_support_height: float = 0.12:
	set(value):
		floor_support_height = max(value, 0.04)
		_update_floor_supports()
@export var floor_support_y_offset: float = -0.02:
	set(value):
		floor_support_y_offset = value
		_update_floor_supports()
@export var side_shell_enabled: bool = true:
	set(value):
		side_shell_enabled = value
		_update_side_shell()
@export var side_shell_thickness: float = 0.24:
	set(value):
		side_shell_thickness = max(value, 0.06)
		_update_side_shell()
@export var side_shell_height_padding: float = 0.04:
	set(value):
		side_shell_height_padding = max(value, 0.0)
		_update_side_shell()
@export var side_shell_outer_bias: float = 0.04:
	set(value):
		side_shell_outer_bias = value
		_update_side_shell()
@export var field_skirt_enabled: bool = true:
	set(value):
		field_skirt_enabled = value
		_update_field_skirt()
@export var field_skirt_half_extents: Vector2 = Vector2(1.95, 1.95):
	set(value):
		field_skirt_half_extents = Vector2(
			maxf(value.x, outer_radius + 0.08),
			maxf(value.y, outer_radius + 0.08)
		)
		_update_field_skirt()
@export var field_skirt_thickness: float = 0.12:
	set(value):
		field_skirt_thickness = maxf(value, 0.03)
		_update_field_skirt()
@export var field_skirt_inner_radius_padding: float = 0.04:
	set(value):
		field_skirt_inner_radius_padding = maxf(value, 0.0)
		_update_field_skirt()
@export var field_skirt_top_offset: float = 0.012:
	set(value):
		field_skirt_top_offset = value
		_update_field_skirt()

var bowl_mesh_instance: MeshInstance3D
var aperture_mesh_instance: MeshInstance3D
var side_shell_mesh_instance: MeshInstance3D
var field_skirt_mesh_instance: MeshInstance3D
var bowl_collision: CollisionShape3D
var bottom_stop_collision: CollisionShape3D
var field_skirt_collision: CollisionShape3D
var seam_guard_root: Node3D
var floor_support_root: Node3D
var side_shell_collision_root: Node3D
var trap_area: Area3D
var trap_collision: CollisionShape3D
var trapped_bodies: Array[RigidBody3D] = []
var body_damp_restore := {}


func _enter_tree() -> void:
	_ensure_core_nodes()
	call_deferred("_rebuild_hole")


func _ready() -> void:
	_ensure_core_nodes()
	if not Engine.is_editor_hint():
		_ensure_trap_area()
		set_physics_process(true)
	call_deferred("_rebuild_hole")


func _physics_process(delta: float) -> void:
	if trapped_bodies.is_empty():
		return

	for body in trapped_bodies.duplicate():
		if not is_instance_valid(body):
			trapped_bodies.erase(body)
			continue

		var local_position: Vector3 = to_local(body.global_position)
		var planar_distance: float = Vector2(local_position.x, local_position.z).length()
		var inside_pocket: bool = planar_distance <= entry_radius and local_position.y <= 0.08 and local_position.y >= -depth - 0.25
		if not inside_pocket:
			_restore_body_damp(body)
			trapped_bodies.erase(body)
			continue

		body.apply_central_force(Vector3.DOWN * trap_force * body.mass)
		if body.linear_velocity.y > max_trapped_upward_velocity and local_position.y < -depth * 0.3:
			var limited_velocity: Vector3 = body.linear_velocity
			limited_velocity.y = max_trapped_upward_velocity
			body.linear_velocity = limited_velocity


func _ensure_core_nodes() -> void:
	bowl_mesh_instance = get_node_or_null("MeshInstance3D") as MeshInstance3D
	if bowl_mesh_instance == null:
		bowl_mesh_instance = MeshInstance3D.new()
		bowl_mesh_instance.name = "MeshInstance3D"
		add_child(bowl_mesh_instance)

	aperture_mesh_instance = get_node_or_null("Aperture") as MeshInstance3D
	if aperture_mesh_instance == null:
		aperture_mesh_instance = MeshInstance3D.new()
		aperture_mesh_instance.name = "Aperture"
		add_child(aperture_mesh_instance)

	side_shell_mesh_instance = get_node_or_null("SideShell") as MeshInstance3D
	if side_shell_mesh_instance == null:
		side_shell_mesh_instance = MeshInstance3D.new()
		side_shell_mesh_instance.name = "SideShell"
		add_child(side_shell_mesh_instance)

	field_skirt_mesh_instance = get_node_or_null("FieldSkirt") as MeshInstance3D
	if field_skirt_mesh_instance == null:
		field_skirt_mesh_instance = MeshInstance3D.new()
		field_skirt_mesh_instance.name = "FieldSkirt"
		add_child(field_skirt_mesh_instance)

	bowl_collision = get_node_or_null("CollisionShape3D") as CollisionShape3D
	if bowl_collision == null:
		bowl_collision = CollisionShape3D.new()
		bowl_collision.name = "CollisionShape3D"
		add_child(bowl_collision)

	bottom_stop_collision = get_node_or_null("BottomStopper") as CollisionShape3D
	if bottom_stop_collision == null:
		bottom_stop_collision = CollisionShape3D.new()
		bottom_stop_collision.name = "BottomStopper"
		add_child(bottom_stop_collision)

	field_skirt_collision = get_node_or_null("FieldSkirtCollision") as CollisionShape3D
	if field_skirt_collision == null:
		field_skirt_collision = CollisionShape3D.new()
		field_skirt_collision.name = "FieldSkirtCollision"
		add_child(field_skirt_collision)

	seam_guard_root = get_node_or_null("SeamGuards") as Node3D
	if seam_guard_root == null:
		seam_guard_root = Node3D.new()
		seam_guard_root.name = "SeamGuards"
		add_child(seam_guard_root)

	floor_support_root = get_node_or_null("FloorSupports") as Node3D
	if floor_support_root == null:
		floor_support_root = Node3D.new()
		floor_support_root.name = "FloorSupports"
		add_child(floor_support_root)

	side_shell_collision_root = get_node_or_null("SideShellCollisions") as Node3D
	if side_shell_collision_root == null:
		side_shell_collision_root = Node3D.new()
		side_shell_collision_root.name = "SideShellCollisions"
		add_child(side_shell_collision_root)


func _ensure_trap_area() -> void:
	trap_area = get_node_or_null("TrapArea") as Area3D
	if trap_area == null:
		trap_area = Area3D.new()
		trap_area.name = "TrapArea"
		trap_area.monitoring = true
		trap_area.monitorable = false
		add_child(trap_area)

	trap_collision = trap_area.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if trap_collision == null:
		trap_collision = CollisionShape3D.new()
		trap_collision.name = "CollisionShape3D"
		trap_area.add_child(trap_collision)

	if not trap_area.body_entered.is_connected(_on_trap_body_entered):
		trap_area.body_entered.connect(_on_trap_body_entered)
	if not trap_area.body_exited.is_connected(_on_trap_body_exited):
		trap_area.body_exited.connect(_on_trap_body_exited)

	_update_trap_shape()


func _rebuild_hole() -> void:
	if not is_inside_tree():
		return

	_ensure_core_nodes()
	var bowl_mesh: ArrayMesh = _create_bowl_mesh()
	bowl_mesh_instance.mesh = bowl_mesh
	bowl_mesh_instance.material_override = _create_bowl_material()
	# Keep the top open so the bowl reads clearly and marbles stay visible inside it.
	aperture_mesh_instance.mesh = _create_blend_ring_mesh()
	aperture_mesh_instance.material_override = _create_ground_blend_material()
	aperture_mesh_instance.position = Vector3.ZERO
	bowl_collision.shape = bowl_mesh.create_trimesh_shape()
	_update_bottom_stop_shape()
	_update_seam_guards()
	_update_floor_supports()
	_update_side_shell()
	_update_field_skirt()
	physics_material_override = _create_bowl_physics_material()

	if not Engine.is_editor_hint():
		_ensure_trap_area()
		_update_trap_shape()


func _update_trap_shape() -> void:
	if trap_collision == null:
		return

	var shape := CylinderShape3D.new()
	shape.radius = max(pocket_radius * 0.82, 0.32)
	shape.height = 0.2
	trap_collision.shape = shape
	trap_collision.position = Vector3(0.0, -depth + bottom_stop_lift + bottom_stop_height * 0.35, 0.0)


func _update_bottom_stop_shape() -> void:
	if bottom_stop_collision == null:
		return

	var shape := CylinderShape3D.new()
	shape.radius = max(pocket_radius * bottom_stop_radius_scale, 0.24)
	shape.height = max(bottom_stop_height, 0.05)
	bottom_stop_collision.shape = shape
	bottom_stop_collision.position = Vector3(0.0, -depth + bottom_stop_lift, 0.0)


func _update_seam_guards() -> void:
	if seam_guard_root == null:
		return

	for child in seam_guard_root.get_children():
		child.queue_free()

	if not seam_guard_enabled:
		return

	var segment_count: int = max(seam_guard_segments, 8)
	var ring_radius: float = outer_radius + seam_guard_outer_bias
	var segment_arc: float = TAU * ring_radius / float(segment_count)
	var tangential_length: float = max(segment_arc * 1.08, seam_guard_radial_thickness * 1.8)
	var radial_thickness: float = seam_guard_radial_thickness

	for segment_index in range(segment_count):
		var guard := CollisionShape3D.new()
		guard.name = "SeamGuard%d" % segment_index

		var shape := BoxShape3D.new()
		shape.size = Vector3(radial_thickness, seam_guard_height, tangential_length)
		guard.shape = shape

		var angle: float = TAU * float(segment_index) / float(segment_count)
		var radial_direction := Vector3(cos(angle), 0.0, sin(angle))
		var tangent_direction := Vector3(-sin(angle), 0.0, cos(angle))
		var basis := Basis(radial_direction, Vector3.UP, tangent_direction)
		guard.transform = Transform3D(
			basis,
			radial_direction * ring_radius + Vector3.UP * seam_guard_y_offset
		)
		seam_guard_root.add_child(guard)


func _update_floor_supports() -> void:
	if floor_support_root == null:
		return

	for child in floor_support_root.get_children():
		child.queue_free()

	if not floor_support_enabled:
		return

	var support_outer: float = max(floor_support_outer_radius, outer_radius + 0.02)
	var support_inner: float = max(outer_radius - floor_support_inner_overlap, 0.1)
	var strip_thickness: float = max(support_outer - support_inner, 0.04)
	var center_offset: float = support_inner + strip_thickness * 0.5
	var y_center: float = floor_support_y_offset

	_add_floor_support("NorthSupport", Vector3(0.0, y_center, center_offset), Vector3(support_outer * 2.0, floor_support_height, strip_thickness))
	_add_floor_support("SouthSupport", Vector3(0.0, y_center, -center_offset), Vector3(support_outer * 2.0, floor_support_height, strip_thickness))
	_add_floor_support("EastSupport", Vector3(center_offset, y_center, 0.0), Vector3(strip_thickness, floor_support_height, support_inner * 2.0))
	_add_floor_support("WestSupport", Vector3(-center_offset, y_center, 0.0), Vector3(strip_thickness, floor_support_height, support_inner * 2.0))


func _add_floor_support(node_name: String, position: Vector3, size: Vector3) -> void:
	var support := CollisionShape3D.new()
	support.name = node_name
	var shape := BoxShape3D.new()
	shape.size = size
	support.shape = shape
	support.position = position
	floor_support_root.add_child(support)


func _update_side_shell() -> void:
	if side_shell_mesh_instance == null or side_shell_collision_root == null:
		return

	for child in side_shell_collision_root.get_children():
		child.queue_free()

	if not side_shell_enabled:
		side_shell_mesh_instance.visible = false
		side_shell_mesh_instance.mesh = null
		side_shell_mesh_instance.material_override = null
		return

	side_shell_mesh_instance.visible = true
	side_shell_mesh_instance.mesh = _create_side_shell_mesh()
	side_shell_mesh_instance.material_override = _create_side_shell_material()

	var segment_count: int = max(radial_segments, 12)
	var inner_radius: float = outer_radius + side_shell_outer_bias
	var outer_radius_value: float = inner_radius + side_shell_thickness
	var center_radius: float = (inner_radius + outer_radius_value) * 0.5
	var shell_height: float = depth + side_shell_height_padding
	var segment_arc: float = TAU * center_radius / float(segment_count)
	var tangential_length: float = max(segment_arc * 1.04, side_shell_thickness * 1.5)
	var y_center: float = lip_height - shell_height * 0.5

	for segment_index in range(segment_count):
		var wall := CollisionShape3D.new()
		wall.name = "SideShell%d" % segment_index

		var shape := BoxShape3D.new()
		shape.size = Vector3(side_shell_thickness, shell_height, tangential_length)
		wall.shape = shape

		var angle: float = TAU * float(segment_index) / float(segment_count)
		var radial_direction := Vector3(cos(angle), 0.0, sin(angle))
		var tangent_direction := Vector3(-sin(angle), 0.0, cos(angle))
		var basis := Basis(radial_direction, Vector3.UP, tangent_direction)
		wall.transform = Transform3D(
			basis,
			radial_direction * center_radius + Vector3.UP * y_center
		)
		side_shell_collision_root.add_child(wall)


func _update_field_skirt() -> void:
	if field_skirt_mesh_instance == null or field_skirt_collision == null:
		return

	if not field_skirt_enabled:
		field_skirt_mesh_instance.visible = false
		field_skirt_mesh_instance.mesh = null
		field_skirt_mesh_instance.material_override = null
		field_skirt_collision.shape = null
		return

	var safe_half_extents := Vector2(
		maxf(field_skirt_half_extents.x, outer_radius + 0.08),
		maxf(field_skirt_half_extents.y, outer_radius + 0.08)
	)
	var minimum_half_extent: float = minf(safe_half_extents.x, safe_half_extents.y)
	var inner_radius: float = minf(
		outer_radius + side_shell_outer_bias + field_skirt_inner_radius_padding,
		minimum_half_extent - 0.04
	)
	inner_radius = maxf(inner_radius, outer_radius + 0.02)

	var top_y: float = lip_height + field_skirt_top_offset
	var bottom_y: float = top_y - field_skirt_thickness
	var field_skirt_mesh: ArrayMesh = _create_field_skirt_mesh(inner_radius, safe_half_extents, top_y, bottom_y)

	field_skirt_mesh_instance.visible = true
	field_skirt_mesh_instance.mesh = field_skirt_mesh
	field_skirt_mesh_instance.material_override = _create_field_skirt_material()
	field_skirt_collision.shape = field_skirt_mesh.create_trimesh_shape()


func _create_bowl_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var ring_points: Array[Dictionary] = _build_ring_profile()
	var bottom_y: float = - depth
	var bottom_radius: float = pocket_radius
	var segment_count: int = max(radial_segments, 12)

	for ring_index in range(ring_points.size() - 1):
		var outer_ring: Dictionary = ring_points[ring_index]
		var inner_ring: Dictionary = ring_points[ring_index + 1]
		var outer_radius_value: float = outer_ring["radius"]
		var inner_radius_value: float = inner_ring["radius"]
		var outer_y: float = outer_ring["y"]
		var inner_y: float = inner_ring["y"]

		for segment_index in range(segment_count):
			var angle_a: float = TAU * float(segment_index) / float(segment_count)
			var angle_b: float = TAU * float(segment_index + 1) / float(segment_count)

			var outer_a := Vector3(cos(angle_a) * outer_radius_value, outer_y, sin(angle_a) * outer_radius_value)
			var outer_b := Vector3(cos(angle_b) * outer_radius_value, outer_y, sin(angle_b) * outer_radius_value)
			var inner_a := Vector3(cos(angle_a) * inner_radius_value, inner_y, sin(angle_a) * inner_radius_value)
			var inner_b := Vector3(cos(angle_b) * inner_radius_value, inner_y, sin(angle_b) * inner_radius_value)

			_add_triangle(st, outer_a, outer_b, inner_b)
			_add_triangle(st, outer_a, inner_b, inner_a)

	var center := Vector3(0.0, bottom_y, 0.0)
	for segment_index in range(segment_count):
		var angle_a: float = TAU * float(segment_index) / float(segment_count)
		var angle_b: float = TAU * float(segment_index + 1) / float(segment_count)
		var rim_a := Vector3(cos(angle_a) * bottom_radius, bottom_y, sin(angle_a) * bottom_radius)
		var rim_b := Vector3(cos(angle_b) * bottom_radius, bottom_y, sin(angle_b) * bottom_radius)
		_add_triangle(st, center, rim_b, rim_a)

	st.generate_normals()
	return st.commit()


func _create_blend_ring_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var inner_radius: float = outer_radius * 0.98
	var outer_radius_value: float = outer_radius + blend_ring_outer_padding
	var ring_y: float = -0.05
	var segment_count: int = max(radial_segments, 12)

	for segment_index in range(segment_count):
		var angle_a: float = TAU * float(segment_index) / float(segment_count)
		var angle_b: float = TAU * float(segment_index + 1) / float(segment_count)

		var inner_a := Vector3(cos(angle_a) * inner_radius, ring_y, sin(angle_a) * inner_radius)
		var inner_b := Vector3(cos(angle_b) * inner_radius, ring_y, sin(angle_b) * inner_radius)
		var outer_a := Vector3(cos(angle_a) * outer_radius_value, ring_y, sin(angle_a) * outer_radius_value)
		var outer_b := Vector3(cos(angle_b) * outer_radius_value, ring_y, sin(angle_b) * outer_radius_value)

		_add_triangle(st, outer_a, outer_b, inner_b)
		_add_triangle(st, outer_a, inner_b, inner_a)

	st.generate_normals()
	return st.commit()


func _create_side_shell_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var inner_radius: float = outer_radius + side_shell_outer_bias
	var outer_radius_value: float = inner_radius + side_shell_thickness
	var top_y: float = lip_height
	var bottom_y: float = top_y - (depth + side_shell_height_padding)
	var segment_count: int = max(radial_segments, 12)

	for segment_index in range(segment_count):
		var angle_a: float = TAU * float(segment_index) / float(segment_count)
		var angle_b: float = TAU * float(segment_index + 1) / float(segment_count)

		var outer_top_a := Vector3(cos(angle_a) * outer_radius_value, top_y, sin(angle_a) * outer_radius_value)
		var outer_top_b := Vector3(cos(angle_b) * outer_radius_value, top_y, sin(angle_b) * outer_radius_value)
		var outer_bottom_a := Vector3(cos(angle_a) * outer_radius_value, bottom_y, sin(angle_a) * outer_radius_value)
		var outer_bottom_b := Vector3(cos(angle_b) * outer_radius_value, bottom_y, sin(angle_b) * outer_radius_value)

		var inner_top_a := Vector3(cos(angle_a) * inner_radius, top_y, sin(angle_a) * inner_radius)
		var inner_top_b := Vector3(cos(angle_b) * inner_radius, top_y, sin(angle_b) * inner_radius)
		var inner_bottom_a := Vector3(cos(angle_a) * inner_radius, bottom_y, sin(angle_a) * inner_radius)
		var inner_bottom_b := Vector3(cos(angle_b) * inner_radius, bottom_y, sin(angle_b) * inner_radius)

		# Outer wall.
		_add_triangle(st, outer_top_a, outer_top_b, outer_bottom_b)
		_add_triangle(st, outer_top_a, outer_bottom_b, outer_bottom_a)

		# Inner wall.
		_add_triangle(st, inner_top_a, inner_bottom_b, inner_top_b)
		_add_triangle(st, inner_top_a, inner_bottom_a, inner_bottom_b)

		# Top cap.
		_add_triangle(st, outer_top_a, inner_top_b, outer_top_b)
		_add_triangle(st, outer_top_a, inner_top_a, inner_top_b)

		# Bottom cap.
		_add_triangle(st, outer_bottom_a, outer_bottom_b, inner_bottom_b)
		_add_triangle(st, outer_bottom_a, inner_bottom_b, inner_bottom_a)

	st.generate_normals()
	return st.commit()


func _create_field_skirt_mesh(inner_radius: float, half_extents: Vector2, top_y: float, bottom_y: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var segment_count: int = max(radial_segments, 24)

	for segment_index in range(segment_count):
		var angle_a: float = TAU * float(segment_index) / float(segment_count)
		var angle_b: float = TAU * float(segment_index + 1) / float(segment_count)

		var inner_top_a := Vector3(cos(angle_a) * inner_radius, top_y, sin(angle_a) * inner_radius)
		var inner_top_b := Vector3(cos(angle_b) * inner_radius, top_y, sin(angle_b) * inner_radius)
		var inner_bottom_a := Vector3(inner_top_a.x, bottom_y, inner_top_a.z)
		var inner_bottom_b := Vector3(inner_top_b.x, bottom_y, inner_top_b.z)

		var outer_top_a := _get_field_skirt_outer_point(angle_a, half_extents, top_y)
		var outer_top_b := _get_field_skirt_outer_point(angle_b, half_extents, top_y)
		var outer_bottom_a := Vector3(outer_top_a.x, bottom_y, outer_top_a.z)
		var outer_bottom_b := Vector3(outer_top_b.x, bottom_y, outer_top_b.z)

		# Top surface that fills the square cutout corners around the hole.
		_add_triangle(st, outer_top_a, outer_top_b, inner_top_b)
		_add_triangle(st, outer_top_a, inner_top_b, inner_top_a)

		# Bottom surface closes the mesh so the filler reads as solid from low angles.
		_add_triangle(st, outer_bottom_a, inner_bottom_b, outer_bottom_b)
		_add_triangle(st, outer_bottom_a, inner_bottom_a, inner_bottom_b)

		# Outer wall along the square cutout boundary.
		_add_triangle(st, outer_top_a, outer_top_b, outer_bottom_b)
		_add_triangle(st, outer_top_a, outer_bottom_b, outer_bottom_a)

		# Inner wall where the field filler meets the bowl rim.
		_add_triangle(st, inner_top_a, inner_bottom_b, inner_top_b)
		_add_triangle(st, inner_top_a, inner_bottom_a, inner_bottom_b)

	st.generate_normals()
	return st.commit()


func _get_field_skirt_outer_point(angle: float, half_extents: Vector2, y: float) -> Vector3:
	var direction := Vector2(cos(angle), sin(angle))
	var x_distance: float = INF if absf(direction.x) < 0.0001 else half_extents.x / absf(direction.x)
	var z_distance: float = INF if absf(direction.y) < 0.0001 else half_extents.y / absf(direction.y)
	var travel_distance: float = minf(x_distance, z_distance)
	return Vector3(direction.x * travel_distance, y, direction.y * travel_distance)


func _create_aperture_mesh() -> PrimitiveMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = max(entry_radius * 0.88, 0.24)
	mesh.bottom_radius = mesh.top_radius
	mesh.height = 0.04
	mesh.radial_segments = max(radial_segments, 24)
	return mesh


func _build_ring_profile() -> Array[Dictionary]:
	var ring_points: Array[Dictionary] = []
	ring_points.append({"radius": outer_radius + lip_width, "y": lip_height})
	ring_points.append({"radius": outer_radius, "y": 0.0})
	ring_points.append({"radius": outer_radius * 0.985, "y": - 0.03})
	ring_points.append({"radius": entry_radius, "y": - depth * 0.16})
	ring_points.append({"radius": lerpf(entry_radius, neck_radius, 0.5), "y": - depth * 0.38})
	ring_points.append({"radius": neck_radius, "y": - depth * 0.62})
	ring_points.append({"radius": lerpf(neck_radius, pocket_radius, 0.55), "y": - depth * 0.84})
	ring_points.append({"radius": pocket_radius, "y": - depth})
	return ring_points


func _add_triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)


func _create_bowl_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = hole_color
	material.roughness = 0.92
	material.metallic = 0.0
	material.emission_enabled = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _create_ground_blend_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(
		ground_blend_color.r,
		ground_blend_color.g,
		ground_blend_color.b,
		0.12
	)
	material.roughness = 0.98
	material.metallic = 0.0
	material.emission_enabled = false
	return material


func _create_aperture_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.015, 0.03, 0.02, 1.0)
	material.roughness = 1.0
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _create_side_shell_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = ground_blend_color.darkened(0.06)
	material.roughness = 0.94
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _create_field_skirt_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(ground_blend_color.r, ground_blend_color.g, ground_blend_color.b, 1.0)
	material.roughness = 0.97
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _create_bowl_physics_material() -> PhysicsMaterial:
	var material := PhysicsMaterial.new()
	material.friction = 1.2
	material.bounce = 0.0
	return material


func _on_trap_body_entered(body: Node) -> void:
	if not (body is RigidBody3D):
		return

	var rigid_body := body as RigidBody3D
	if trapped_bodies.has(rigid_body):
		return

	body_damp_restore[rigid_body.get_instance_id()] = {
		"linear_damp": rigid_body.linear_damp,
		"angular_damp": rigid_body.angular_damp
	}
	rigid_body.linear_damp = maxf(rigid_body.linear_damp, trapped_linear_damp)
	rigid_body.angular_damp = maxf(rigid_body.angular_damp, trapped_angular_damp)
	trapped_bodies.append(rigid_body)


func _on_trap_body_exited(body: Node) -> void:
	if not (body is RigidBody3D):
		return

	var rigid_body := body as RigidBody3D
	_restore_body_damp(rigid_body)
	trapped_bodies.erase(rigid_body)


func _restore_body_damp(body: RigidBody3D) -> void:
	var key := body.get_instance_id()
	if not body_damp_restore.has(key):
		return

	var original: Dictionary = body_damp_restore[key]
	body.linear_damp = original.get("linear_damp", body.linear_damp)
	body.angular_damp = original.get("angular_damp", body.angular_damp)
	body_damp_restore.erase(key)
