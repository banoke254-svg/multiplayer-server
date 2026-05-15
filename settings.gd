extends PopupPanel

const GLASS_BUTTON_EFFECTS = preload("res://glass_button_effects.gd")

@onready var master_slider: Slider = $Background/VBoxContainer/MasterContainer/MasterSlider
@onready var music_slider: Slider = $Background/VBoxContainer/MusicContainer/MusicSlider
@onready var sfx_slider: Slider = $Background/VBoxContainer/SFXContainer/SFXSlider
@onready var back_button: Button = $Background/VBoxContainer/BackButton

func _ready():
	if master_slider:
		master_slider.value = 0.5
		master_slider.connect("value_changed", Callable(self, "_on_master_slider_changed"))
	if music_slider:
		music_slider.value = 0.5
		music_slider.connect("value_changed", Callable(self, "_on_music_slider_changed"))
	if sfx_slider:
		sfx_slider.value = 0.5
		sfx_slider.connect("value_changed", Callable(self, "_on_sfx_slider_changed"))
	if back_button:
		back_button.pressed.connect(func(): visible = false)
	GLASS_BUTTON_EFFECTS.apply_to_tree(self)

func _on_master_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
