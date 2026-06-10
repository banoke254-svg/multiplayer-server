extends Node

const BUTTON_CLICK_SOUND_PATH: String = "res://ui/sounds/button_click.wav"
const SFX_BUS_NAME: String = "SFX"
const BUTTON_REPEAT_GUARD_MSEC: int = 120

var click_player: AudioStreamPlayer
var last_button_click_msec: Dictionary = {}


func _ready() -> void:
	_ensure_audio_bus(SFX_BUS_NAME)
	click_player = AudioStreamPlayer.new()
	click_player.name = "ButtonClickSoundPlayer"
	click_player.bus = SFX_BUS_NAME if AudioServer.get_bus_index(SFX_BUS_NAME) != -1 else "Master"
	click_player.volume_db = 2.0
	click_player.stream = _load_click_stream()
	add_child(click_player)

	_bind_button_tree(get_tree().root)
	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)


func _ensure_audio_bus(bus_name: String, send_bus_name: String = "Master") -> void:
	if bus_name == "" or AudioServer.get_bus_index(bus_name) != -1:
		return

	var bus_index: int = AudioServer.bus_count
	AudioServer.add_bus(bus_index)
	AudioServer.set_bus_name(bus_index, bus_name)
	if AudioServer.get_bus_index(send_bus_name) != -1:
		AudioServer.set_bus_send(bus_index, send_bus_name)


func _load_click_stream() -> AudioStream:
	if ResourceLoader.exists(BUTTON_CLICK_SOUND_PATH):
		var stream: AudioStream = ResourceLoader.load(BUTTON_CLICK_SOUND_PATH) as AudioStream
		if stream != null:
			return stream
	return _make_fallback_click_stream()


func _make_fallback_click_stream() -> AudioStreamWAV:
	var sample_rate: int = 44100
	var duration_seconds: float = 0.085
	var sample_count: int = int(float(sample_rate) * duration_seconds)
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)

	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var fade: float = 1.0 - (float(i) / float(sample_count))
		var wave: float = sin(TAU * 1450.0 * t) * fade
		var value: int = int(clamp(wave * 22000.0, -32768.0, 32767.0))
		data[i * 2] = value & 0xff
		data[i * 2 + 1] = (value >> 8) & 0xff

	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream


func _on_node_added(node: Node) -> void:
	_bind_button_tree(node)


func _bind_button_tree(node: Node) -> void:
	_register_button(node)
	for child in node.get_children():
		_bind_button_tree(child)


func _register_button(node: Node) -> void:
	var button: BaseButton = node as BaseButton
	if button == null:
		return
	if button.has_meta("button_click_audio_bound"):
		return

	button.set_meta("button_click_audio_bound", true)
	button.gui_input.connect(_on_button_gui_input.bind(button))


func _on_button_gui_input(event: InputEvent, button: BaseButton) -> void:
	if button == null or button.disabled:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_play_for_button(button)
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_play_for_button(button)


func _play_for_button(button: BaseButton) -> void:
	var instance_id: int = button.get_instance_id()
	var now: int = Time.get_ticks_msec()
	var last_click: int = int(last_button_click_msec.get(instance_id, -BUTTON_REPEAT_GUARD_MSEC))
	if now - last_click < BUTTON_REPEAT_GUARD_MSEC:
		return

	last_button_click_msec[instance_id] = now
	_play_click()


func _play_click() -> void:
	if click_player == null or click_player.stream == null:
		return
	click_player.stop()
	click_player.pitch_scale = 1.0
	click_player.play()
