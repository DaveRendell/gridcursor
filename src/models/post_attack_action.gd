class_name PostAttackAction

var display_name

func _init(_display_name):
	display_name = _display_name

func is_allowed(map: BattleMap, unit: Unit, path: Array[Vector2i]) -> bool:
	return true

func action(map: BattleMap, unit: Unit, path: Array[Vector2i]) -> void:
	pass
