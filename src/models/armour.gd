class_name Armour
extends Equipment

class ArmourFeature extends Feature:
	var defence: int
	
	func _init(display_name: String, base_defence: int):
		defence = base_defence
		super(display_name)
	
	func base_defence() -> int:
		return defence

func _init(
	display_name: String,
	weight: int,
	base_defence: int
):
	self.equipable_slots = ["clothing"]
	super(display_name, weight, ArmourFeature.new(display_name, base_defence))
