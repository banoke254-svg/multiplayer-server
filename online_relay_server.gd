extends Node

const DEFAULT_PORT: int = 24580


func _ready() -> void:
	var lan: Node = get_node_or_null("/root/LanMultiplayer")
	if lan == null or not lan.has_method("start_online_relay_server"):
		push_error("LanMultiplayer autoload is required for the online relay server.")
		get_tree().quit(1)
		return

	var error: Error = lan.call("start_online_relay_server", _get_port_from_args())
	if error != OK:
		get_tree().quit(1)


func _get_port_from_args() -> int:
	var args: PackedStringArray = OS.get_cmdline_args()
	for index in range(args.size()):
		if args[index] == "--port" and index + 1 < args.size() and args[index + 1].is_valid_int():
			return clampi(int(args[index + 1]), 1024, 65535)
		if args[index].begins_with("--port="):
			var value: String = args[index].substr(7)
			if value.is_valid_int():
				return clampi(int(value), 1024, 65535)
	var environment_port: String = OS.get_environment("PORT")
	if environment_port.is_valid_int():
		return clampi(int(environment_port), 1024, 65535)
	return DEFAULT_PORT
