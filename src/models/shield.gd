class_name Shield
extends Equipment

class ShieldFeature extends Feature:
	var boost: int
	
	func _init(_display_name: String, _defence_boost: int):
		boost = _defence_boost
		super(_display_name)
	
	func defence_boost() -> int:
		return boost

func _init(
	display_name: String,
	weight: int,
	defence_boost: int
):
	self.equipable_slots = ["off_hand"]
	super(display_name, weight, ShieldFeature.new(display_name, defence_boost))
