extends Node

const SIM_SECONDS: float = 35.0
const REPORT_INTERVAL: float = 5.0

var elapsed: float = 0.0
var report_elapsed: float = 0.0
var frame_count: int = 0
var physics_samples: Array[float] = []
var process_samples: Array[float] = []


func _ready() -> void:
	var scene: PackedScene = load("res://main.tscn") as PackedScene
	if scene == null:
		printerr("SIM_FAIL main.tscn could not be loaded")
		get_tree().quit(1)
		return

	var instance: Node = scene.instantiate()
	add_child(instance)
	print("SIM_START seconds=%s scene=%s" % [SIM_SECONDS, instance.name])


func _process(delta: float) -> void:
	elapsed += delta
	report_elapsed += delta
	frame_count += 1

	process_samples.append(float(Performance.get_monitor(Performance.TIME_PROCESS)))
	physics_samples.append(float(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)))

	if report_elapsed >= REPORT_INTERVAL:
		report_elapsed = 0.0
		_print_report(false)

	if elapsed >= SIM_SECONDS:
		_print_report(true)
		get_tree().quit(0)


func _print_report(final_report: bool) -> void:
	var node_count: int = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var object_count: int = int(Performance.get_monitor(Performance.OBJECT_COUNT))
	var resource_count: int = int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	var fps: float = Engine.get_frames_per_second()
	var avg_process_ms: float = _average(process_samples) * 1000.0
	var avg_physics_ms: float = _average(physics_samples) * 1000.0
	var label: String = "SIM_FINAL" if final_report else "SIM_TICK"
	print("%s t=%.1f frames=%d fps=%.1f process_ms=%.3f physics_ms=%.3f nodes=%d objects=%d resources=%d" % [
		label,
		elapsed,
		frame_count,
		fps,
		avg_process_ms,
		avg_physics_ms,
		node_count,
		object_count,
		resource_count
	])
	process_samples.clear()
	physics_samples.clear()


func _average(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	var total: float = 0.0
	for value in values:
		total += value
	return total / float(values.size())
