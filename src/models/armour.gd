class_name Armour
extends Clothing

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
	base_defence: int,
	_sprite_sheets: Dictionary
):
	super(display_name, weight, ArmourFeature.new(display_name, base_defence), _sprite_sheets)
