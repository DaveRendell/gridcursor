class_name Equipment
extends Item

var equipable_slots: Array = []

func _init(
	display_name: String,
	weight: int
).(display_name, weight):
	pass

func set_base_defence() -> int:
	return 0

func set_defence_boost() -> int:
	return 0

func get_attacks() -> Array:
	return []
