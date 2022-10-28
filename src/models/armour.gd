class_name Armour
extends Equipment

var base_defence: int

func _init(
	display_name: String,
	weight: int,
	base_defence: int
):
	super(display_name, weight)
	self.equipable_slots = ["clothing"]
	self.base_defence = base_defence

func set_base_defence() -> int:
	return base_defence
