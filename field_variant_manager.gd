extends Node

const BASE_GROUND_VISUALS: PackedStringArray = [
	"GroundNorth",
	"GroundSouth",
	"GroundLeft",
	"GroundRight"
]

const BASE_GROUND_COLLIDERS: PackedStringArray = [
	"CollisionShape3D",
	"CollisionShape3D2",
	"CollisionShape3D3",
	"CollisionShape3D4"
]

var variant_root: Node3D


func _ready() -> void:
	_apply_selected_field_variant()


func _apply_selected_field_variant() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null or not customization.has_method("get_selected_field_preset"):
		return

	var field_preset: Dictionary = customization.call("get_selected_field_preset")
	var runtime_scene_path: String = str(field_preset.get("runtime_scene_path", ""))
	var use_variant: bool = runtime_scene_path != "" and ResourceLoader.exists(runtime_scene_path)

	_set_base_ground_visuals_enabled(not use_variant)
	_set_base_ground_colliders_enabled(true)
	_clear_variant()

	if not use_variant:
		return

	var packed_scene: PackedScene = load(runtime_scene_path) as PackedScene
	if packed_scene == null:
		return

	var scene_instance: Node3D = packed_scene.instantiate() as Node3D
	if scene_instance == null:
		return

	_disable_variant_collision_generation(scene_instance)
	_strip_variant_collisions(scene_instance)

	var parent_root: Node3D = get_parent() as Node3D
	if parent_root == null:
		return

	variant_root = Node3D.new()
	variant_root.name = "FieldVariantRoot"
	parent_root.add_child(variant_root)
	variant_root.add_child(scene_instance)
	call_deferred("_strip_active_variant_collisions")


func _set_base_ground_visuals_enabled(enabled: bool) -> void:
	var ground: Node = get_parent().get_node_or_null("Ground")
	if ground == null:
		return

	for visual_name in BASE_GROUND_VISUALS:
		var visual: Node3D = ground.get_node_or_null(str(visual_name)) as Node3D
		if visual != null:
			visual.visible = enabled


func _set_base_ground_colliders_enabled(enabled: bool) -> void:
	var ground: Node = get_parent().get_node_or_null("Ground")
	if ground == null:
		return

	for collider_name in BASE_GROUND_COLLIDERS:
		var collider: CollisionShape3D = ground.get_node_or_null(str(collider_name)) as CollisionShape3D
		if collider != null:
			collider.disabled = not enabled


func _clear_variant() -> void:
	if variant_root != null and is_instance_valid(variant_root):
		variant_root.queue_free()
	variant_root = null


func _strip_active_variant_collisions() -> void:
	if variant_root == null or not is_instance_valid(variant_root):
		return
	_strip_variant_collisions(variant_root)


func _strip_variant_collisions(root: Node) -> void:
	for child in root.get_children():
		if child is CollisionObject3D or child is CollisionShape3D or child is CollisionPolygon3D:
			child.queue_free()
			continue
		_strip_variant_collisions(child)


func _disable_variant_collision_generation(root: Node) -> void:
	_set_node_property_if_present(root, "generate_mesh_collisions", false)
	_set_node_property_if_present(root, "add_ground_collision_box", false)
	_set_node_property_if_present(root, "generate_obstacle_colliders", false)

	for child in root.get_children():
		_disable_variant_collision_generation(child)


func _set_node_property_if_present(node: Object, property_name: String, value: Variant) -> void:
	for property in node.get_property_list():
		if str(property.get("name", "")) == property_name:
			node.set(property_name, value)
			return
