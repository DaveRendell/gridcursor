class_name Shield
extends Equipment

var defence_boost: int

func _init(
	display_name: String,
	weight: int,
	defence_boost: int
).(display_name, weight):
	self.equipable_slots = ["off_hand"]
	self.defence_boost = defence_boost

func set_defence_boost() -> int:
	return defence_boost
