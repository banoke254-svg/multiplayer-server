@tool
class_name ShowroomMarbleSlot
extends Marker3D

enum SlotRole {
	SELECTED,
	FIXED
}

@export var slot_role: SlotRole = SlotRole.FIXED
@export var marble_id: String = ""
@export_range(0.05, 20.0, 0.01) var scale_multiplier: float = 1.0
@export var apply_showroom_effects: bool = true
@export var halo_enabled: bool = true
@export var enable_float: bool = false
@export_range(0.0, 2.0, 0.01) var float_amplitude: float = 0.08
@export_range(0.0, 8.0, 0.01) var float_speed: float = 1.0
@export var enable_spin: bool = false
@export_range(-8.0, 8.0, 0.01) var spin_speed: float = 0.35


func _enter_tree() -> void:
	if not is_in_group("showroom_marble_slots"):
		add_to_group("showroom_marble_slots")


func is_selected_slot() -> bool:
	return slot_role == SlotRole.SELECTED


func get_slot_marble_id() -> String:
	return marble_id.strip_edges()
