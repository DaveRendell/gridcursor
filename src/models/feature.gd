class_name Feature

var display_name: String

func _init(_display_name):
	display_name = _display_name

func base_defence() -> int:
	return 0

func defence_boost() -> int:
	return 0

func attacks() -> Array[Attack]:
	return []

func spells() -> Array[Spell]:
	return []

func battle_actions() -> Array:
	return []

func post_attack_actions() -> Array:
	return []

func end_of_battle(unit: Unit) -> void:
	pass

func start_of_turn(map: BattleMap, unit: Unit) -> void:
	pass

func end_of_turn(map: BattleMap, unit: Unit) -> void:
	pass
