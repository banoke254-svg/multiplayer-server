extends RefCounted
class_name GlassButtonEffects

const HOVER_SCALE: Vector2 = Vector2(1.03, 1.03)
const PRESSED_SCALE: Vector2 = Vector2(0.97, 0.97)
const NORMAL_SCALE: Vector2 = Vector2.ONE


static func apply_to_tree(root: Node) -> void:
	if root == null:
		return
	if root is BaseButton:
		_wire_button(root as BaseButton)
	for child in root.get_children():
		apply_to_tree(child)


static func _wire_button(button: BaseButton) -> void:
	if button == null or button.has_meta("glass_fx_ready"):
		return
	button.set_meta("glass_fx_ready", true)
	button.mouse_entered.connect(func() -> void:
		if button.disabled:
			return
		_animate_button(button, HOVER_SCALE)
	)
	button.mouse_exited.connect(func() -> void:
		if button.button_pressed:
			return
		_animate_button(button, NORMAL_SCALE)
	)
	button.button_down.connect(func() -> void:
		if button.disabled:
			return
		_animate_button(button, PRESSED_SCALE)
	)
	button.button_up.connect(func() -> void:
		if button.disabled:
			return
		var target: Vector2 = HOVER_SCALE if button.get_global_rect().has_point(button.get_global_mouse_position()) else NORMAL_SCALE
		_animate_button(button, target)
	)


static func _animate_button(button: BaseButton, target_scale: Vector2) -> void:
	button.pivot_offset = button.size * 0.5
	var tween: Tween = button.get_meta("glass_fx_tween", null) as Tween
	if tween != null and tween.is_valid():
		tween.kill()
	tween = button.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, 0.08)
	button.set_meta("glass_fx_tween", tween)
