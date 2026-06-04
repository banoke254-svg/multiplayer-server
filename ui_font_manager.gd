extends Node

const LOCAL_GAME_FONT_PATHS: Array[String] = [
	"res://fonts/bangokz.ttf",
	"res://fonts/bangokz.otf",
	"res://fonts/BANGOKZ.ttf",
	"res://fonts/BANGOKZ.otf",
	"res://fonts/bangers.ttf",
	"res://fonts/bangers.otf",
	"res://fonts/Bangers-Regular.ttf",
	"res://fonts/Bangers-Regular.otf",
	"res://fonts/RAVIE.TTF",
	"res://fonts/Ravie.ttf",
	"res://fonts/bank_gothic.ttf",
	"res://fonts/bank_gothic.otf",
	"res://fonts/BankGothic.ttf",
	"res://fonts/BankGothic.otf"
]

const GAME_FONT_SYSTEM_NAMES: Array[String] = [
	"BANGOKZ",
	"Bangokz",
	"Bangers",
	"Showcard Gothic",
	"Ravie",
	"Snap ITC",
	"Jokerman",
	"Impact",
	"Algerian",
	"Stencil",
	"Bank Gothic",
	"BankGothic Md BT",
	"Bank Gothic Medium",
	"BankGothic",
	"Copperplate Gothic Bold",
	"Copperplate Gothic Light",
	"Century Gothic",
	"Bahnschrift",
	"Arial"
]

const THEME_TYPES: Array[StringName] = [
	&"Button",
	&"CheckBox",
	&"CheckButton",
	&"ItemList",
	&"Label",
	&"LineEdit",
	&"MenuButton",
	&"OptionButton",
	&"PopupMenu",
	&"ProgressBar",
	&"RichTextLabel",
	&"TabBar",
	&"TabContainer",
	&"TextEdit",
	&"Tree"
]

const FONT_ITEMS: Array[StringName] = [
	&"font",
	&"normal_font",
	&"bold_font",
	&"italics_font",
	&"bold_italics_font",
	&"mono_font"
]

const TEXT_OUTLINE_COLOR: Color = Color(0.33, 0.05, 0.78, 0.82)
const TEXT_SHADOW_COLOR: Color = Color(0.74, 0.34, 1.0, 0.38)

var game_font: Font


func _ready() -> void:
	game_font = _make_game_font(700)
	_apply_font_to_project_theme()
	get_tree().node_added.connect(_on_node_added)
	call_deferred("_apply_font_to_tree")


func get_game_font(weight: int = 700) -> Font:
	if game_font == null:
		game_font = _make_game_font(weight)
	return game_font


func get_bank_gothic_font(weight: int = 700) -> Font:
	return get_game_font(weight)


func _make_game_font(weight: int) -> Font:
	for font_path in LOCAL_GAME_FONT_PATHS:
		if not ResourceLoader.exists(font_path):
			continue
		var loaded_font: Font = load(font_path) as Font
		if loaded_font != null:
			return loaded_font

	var system_font := SystemFont.new()
	system_font.font_names = PackedStringArray(GAME_FONT_SYSTEM_NAMES)
	system_font.font_weight = weight
	system_font.subpixel_positioning = 0
	return system_font


func _apply_font_to_project_theme() -> void:
	var glass_theme: Theme = load("res://GlassTheme.tres") as Theme
	if glass_theme == null or game_font == null:
		return

	glass_theme.default_font = game_font
	for theme_type in THEME_TYPES:
		glass_theme.set_font(&"font", theme_type, game_font)
		glass_theme.set_color(&"font_outline_color", theme_type, TEXT_OUTLINE_COLOR)
		glass_theme.set_color(&"font_shadow_color", theme_type, TEXT_SHADOW_COLOR)
		glass_theme.set_constant(&"outline_size", theme_type, 2)
		glass_theme.set_constant(&"shadow_offset_x", theme_type, 1)
		glass_theme.set_constant(&"shadow_offset_y", theme_type, 1)
	for font_item in FONT_ITEMS:
		glass_theme.set_font(font_item, &"RichTextLabel", game_font)


func _on_node_added(node: Node) -> void:
	call_deferred("_apply_font_to_node", node)


func _apply_font_to_tree() -> void:
	var root: Window = get_tree().root
	if root == null:
		return
	_apply_font_recursive(root)


func _apply_font_recursive(node: Node) -> void:
	_apply_font_to_node(node)
	for child in node.get_children():
		_apply_font_recursive(child)


func _apply_font_to_node(node: Node) -> void:
	if game_font == null or node == null or not is_instance_valid(node):
		return

	var control := node as Control
	if control != null:
		for font_item in FONT_ITEMS:
			control.add_theme_font_override(font_item, game_font)
		_apply_text_effect_to_control(control)
		return

	var label_3d := node as Label3D
	if label_3d != null:
		label_3d.font = game_font
		return

	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null:
		var text_mesh := mesh_instance.mesh as TextMesh
		if text_mesh != null:
			text_mesh.font = game_font


func _apply_text_effect_to_control(control: Control) -> void:
	if control == null:
		return
	if not (control is Label or control is Button or control is MenuButton or control is OptionButton or control is ProgressBar or control is RichTextLabel or control is CheckBox or control is CheckButton or control is TabBar):
		return

	control.add_theme_color_override(&"font_outline_color", TEXT_OUTLINE_COLOR)
	control.add_theme_color_override(&"font_shadow_color", TEXT_SHADOW_COLOR)
	control.add_theme_constant_override(&"outline_size", 2)
	control.add_theme_constant_override(&"shadow_offset_x", 1)
	control.add_theme_constant_override(&"shadow_offset_y", 1)
