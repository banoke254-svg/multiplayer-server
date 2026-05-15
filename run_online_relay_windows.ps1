param(
    [int]$Port = 24580,
    [string]$Godot = "C:\Users\LENOVO\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64.exe"
)

& $Godot --headless --path . res://online_relay_server.tscn -- --port=$Port
