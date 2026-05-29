extends Node3D

@export_file("*.tscn") var main_scene_path: String = "res://main.tscn"

const DRAG_THRESHOLD: float = 50.0
const TUTORIAL_HAND_TEXTURE_PATH: String = "res://ui/tutorial_hand.png"
const GUIDE_HAND_SIZE := Vector2(170.0, 220.0)
const GUIDE_HAND_TOUCH_OFFSET := Vector2(39.0, 33.0)

@onready var marble: Node3D = get_node_or_null("Marble")
@onready var instruction_label: Label = get_node("TutorialUI/InstructionLabel") as Label
@onready var skip_button: Button = get_node("TutorialUI/SkipButton") as Button
@onready var start_button: Button = get_node("TutorialUI/StartButton") as Button
@onready var ghost_hand: TextureRect = get_node("TutorialUI/GhostHand") as TextureRect
@onready var arrow: TextureRect = get_node("TutorialUI/Arrow") as TextureRect

# ✅ NEW (blur background)
var is_dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var drag_end: Vector2 = Vector2.ZERO
var drag_distance: float = 0.0
var drag_primed_for_release: bool = false
var last_drag_vector: Vector2 = Vector2.ZERO
var current_step: int = 0

var steps: Array[String] = [
	"Drag back to aim",
	"Release to shoot",
	"Reach the goal to win"
]

var guide_tween: Tween
var arrow_tween: Tween

func _ready() -> void:
	_build_guide_textures()
	_style_ui()

	start_button.hide()
	skip_button.pressed.connect(_on_skip_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)

	# ✅ Pause game for tutorial
	get_tree().paused = true

	update_tutorial()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_start = event.position
			drag_end = event.position
		else:
			if not is_dragging:
				return
			is_dragging = false
			drag_end = event.position
			drag_distance = drag_start.distance_to(drag_end)
			last_drag_vector = drag_end - drag_start
			check_drag_complete()

	elif event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			drag_start = event.position
			drag_end = event.position
		else:
			if not is_dragging:
				return
			is_dragging = false
			drag_end = event.position
			drag_distance = drag_start.distance_to(drag_end)
			last_drag_vector = drag_end - drag_start
			check_drag_complete()

	elif event is InputEventMouseMotion:
		if is_dragging:
			drag_end = event.position
			drag_distance = drag_start.distance_to(drag_end)
			_update_live_drag_guide()

	elif event is InputEventScreenDrag:
		if is_dragging:
			drag_end = event.position
			drag_distance = drag_start.distance_to(drag_end)
			_update_live_drag_guide()

func check_drag_complete() -> void:
	if current_step == 0:
		if drag_distance > DRAG_THRESHOLD and last_drag_vector.y > 0.0:
			drag_primed_for_release = true
			next_step()

	elif current_step == 1:
		if drag_primed_for_release and drag_distance > DRAG_THRESHOLD:
			drag_primed_for_release = false
			next_step()

func next_step() -> void:
	current_step += 1
	current_step = clampi(current_step, 0, steps.size() - 1)
	update_tutorial()

func update_tutorial() -> void:
	_stop_guide_tweens()
	instruction_label.text = steps[current_step]

	# ✅ Keep blur active during tutorial

	if current_step == 0:
		show_drag_guide()

	elif current_step == 1:
		show_release_guide()

	elif current_step == 2:
		show_win_info()
		start_button.show()

func show_drag_guide() -> void:
	ghost_hand.show()
	arrow.hide()
	ghost_hand.size = GUIDE_HAND_SIZE
	ghost_hand.pivot_offset = GUIDE_HAND_TOUCH_OFFSET
	ghost_hand.scale = Vector2.ONE
	ghost_hand.modulate = Color(1.0, 1.0, 1.0, 0.86)
	_set_ghost_hand_at_touch(Vector2(860, 360))

	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(ghost_hand, "position", Vector2(760, 450) - GUIDE_HAND_TOUCH_OFFSET, 1.0)
	guide_tween.tween_property(ghost_hand, "position", Vector2(860, 360) - GUIDE_HAND_TOUCH_OFFSET, 0.5)

func show_release_guide() -> void:
	ghost_hand.show()
	arrow.hide()
	ghost_hand.size = GUIDE_HAND_SIZE
	ghost_hand.pivot_offset = GUIDE_HAND_TOUCH_OFFSET
	ghost_hand.scale = Vector2.ONE
	ghost_hand.modulate = Color(1.0, 1.0, 1.0, 0.86)
	_set_ghost_hand_at_touch(Vector2(760, 430))

	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(ghost_hand, "scale", Vector2(0.92, 0.92), 0.18)
	guide_tween.tween_property(ghost_hand, "scale", Vector2.ONE, 0.18)
	guide_tween.tween_property(ghost_hand, "modulate:a", 0.3, 0.24)
	guide_tween.tween_property(ghost_hand, "modulate:a", 0.86, 0.24)

func show_win_info() -> void:
	ghost_hand.hide()
	arrow.hide()

func _on_start_button_pressed() -> void:
	end_tutorial()

func _on_skip_button_pressed() -> void:
	end_tutorial()

# ✅ NEW (clean finish)
func end_tutorial() -> void:
	instruction_label.hide()
	ghost_hand.hide()
	arrow.hide()
	start_button.hide()

	get_tree().paused = false

	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("mark_tutorial_done"):
		game_manager.call("mark_tutorial_done")

	_change_to_main_scene()

func _change_to_main_scene() -> void:
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("stop_menu_music"):
		game_manager.call("stop_menu_music")
	if main_scene_path != "" and ResourceLoader.exists(main_scene_path):
		get_tree().change_scene_to_file(main_scene_path)

func _stop_guide_tweens() -> void:
	if guide_tween != null:
		guide_tween.kill()
		guide_tween = null
	if arrow_tween != null:
		arrow_tween.kill()
		arrow_tween = null

func _build_guide_textures() -> void:
	ghost_hand.texture = _load_tutorial_hand_texture()
	ghost_hand.size = GUIDE_HAND_SIZE
	ghost_hand.pivot_offset = GUIDE_HAND_TOUCH_OFFSET
	ghost_hand.modulate = Color(1.0, 1.0, 1.0, 0.86)
	arrow.texture = _make_arrow_texture()
	arrow.modulate = Color(1.0, 0.85, 0.36, 0.95)

func _style_ui() -> void:
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	instruction_label.modulate = Color(0.96, 0.98, 1.0, 1.0)

	for button in [skip_button, start_button]:
		button.custom_minimum_size = Vector2(180, 56)

func _set_ghost_hand_at_touch(touch_position: Vector2) -> void:
	ghost_hand.position = touch_position - GUIDE_HAND_TOUCH_OFFSET

func _load_tutorial_hand_texture() -> Texture2D:
	var image: Image = Image.new()
	if image.load(TUTORIAL_HAND_TEXTURE_PATH) == OK:
		return ImageTexture.create_from_image(image)
	return _make_hand_texture()

func _update_live_drag_guide() -> void:
	if ghost_hand == null or arrow == null or current_step > 1:
		return
	_stop_guide_tweens()
	ghost_hand.show()
	arrow.hide()
	ghost_hand.scale = Vector2.ONE
	ghost_hand.modulate = Color(1.0, 1.0, 1.0, 0.92)
	_set_ghost_hand_at_touch(drag_end)
	var drag_vector: Vector2 = drag_end - drag_start
	if drag_vector.length() > 6.0:
		return

func _make_hand_texture() -> ImageTexture:
	var image: Image = Image.create(72, 72, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in range(72):
		for x in range(72):
			var uv: Vector2 = Vector2(x, y) / 71.0
			var palm: float = 1.0 if Vector2((uv.x - 0.5) / 0.18, (uv.y - 0.68) / 0.18).length() <= 1.0 else 0.0
			var finger: float = 1.0 if abs(uv.x - 0.5) < 0.06 and uv.y > 0.18 and uv.y < 0.68 else 0.0
			var thumb: float = 1.0 if Vector2((uv.x - 0.34) / 0.12, (uv.y - 0.54) / 0.08).length() <= 1.0 else 0.0
			var alpha: float = maxf(palm, maxf(finger, thumb))
			if alpha > 0.0:
				image.set_pixel(x, y, Color(0.92, 0.96, 1.0, alpha))
	return ImageTexture.create_from_image(image)

func _make_arrow_texture() -> ImageTexture:
	var image: Image = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in range(96):
		for x in range(96):
			var uv: Vector2 = Vector2(x, y) / 95.0
			var shaft: bool = abs(uv.x - 0.5) < 0.09 and uv.y > 0.28 and uv.y < 0.82
			var head: bool = uv.y <= 0.34 and abs(uv.x - 0.5) < (0.26 - uv.y * 0.55)
			if shaft or head:
				image.set_pixel(x, y, Color(1, 1, 1, 1))
	return ImageTexture.create_from_image(image)
