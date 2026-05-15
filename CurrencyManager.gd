extends Node

signal currency_changed(coins: int, gold: int)

const SAVE_PATH: String = "user://currency.save"

var coins: int = 0
var gold: int = 0


func _ready() -> void:
	load_data()


func add_coins(amount: int) -> int:
	if amount <= 0:
		return get_coins()
	coins += amount
	_save_and_emit()
	return get_coins()


func add_s_coins(amount: int) -> int:
	return add_coins(amount)


func add_purchased_gold(amount: int) -> int:
	if amount <= 0:
		return get_gold()
	gold += amount
	_save_and_emit()
	return get_gold()


func spend_coins(amount: int) -> bool:
	if amount < 0 or coins < amount:
		return false
	coins -= amount
	_save_and_emit()
	return true


func spend_s_coins(amount: int) -> bool:
	return spend_coins(amount)


func spend_gold(amount: int) -> bool:
	if amount < 0 or gold < amount:
		return false
	gold -= amount
	_save_and_emit()
	return true


func get_coins() -> int:
	return max(coins, 0)


func get_s_coins() -> int:
	return get_coins()


func get_gold() -> int:
	return max(gold, 0)


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var data: Dictionary = parsed
	coins = max(int(data.get("coins", 0)), 0)
	gold = max(int(data.get("gold", 0)), 0)


func save_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return

	file.store_string(JSON.stringify({
		"coins": get_coins(),
		"gold": get_gold()
	}))


func _save_and_emit() -> void:
	save_data()
	currency_changed.emit(get_coins(), get_gold())
