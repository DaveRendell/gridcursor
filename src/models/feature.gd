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
