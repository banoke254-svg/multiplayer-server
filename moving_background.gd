extends ColorRect

@export var speed: float = 0.02
@export var star_scale: float = 120.0
@export var bg_color: Color = Color(0.02, 0.02, 0.06)
@export var star_color: Color = Color(1, 1, 1)
@export var star_threshold: float = 0.995
@export var star_brightness: float = 0.8

func _ready() -> void:
	material = ShaderMaterial.new()
	material.shader = load("res://shaders/moving_background.gdshader")
	(material as ShaderMaterial).set_shader_parameter("speed", speed)
	(material as ShaderMaterial).set_shader_parameter("scale", star_scale)
	(material as ShaderMaterial).set_shader_parameter("bg_color", bg_color)
	(material as ShaderMaterial).set_shader_parameter("star_color", star_color)
	(material as ShaderMaterial).set_shader_parameter("star_threshold", star_threshold)
	(material as ShaderMaterial).set_shader_parameter("star_brightness", star_brightness)
