class_name Weapon
extends Equipment

class WeaponFeature extends Feature:
	var attack: Attack
	
	func _init(
		weapon_name: String,
		attacking_stats: Array,
		damage: int,
		min_range: int = 1,
		max_range: int = 1,
		animation = "attack"
	):
		attack = Attack.new(
			weapon_name,
			min_range,
			max_range,
			attacking_stats,
			damage,
			animation)
		super(weapon_name)
	
	func attacks() -> Array[Attack]:
		return [attack]

func _init(
	display_name: String,
	weight: int,
	attacking_stats: Array,
	damage: int,
	min_range: int = 1,
	max_range: int = 1,
	is_two_handed = false,
	animation = "attack"
):	
	if is_two_handed:
		self.equipable_slots = [[E.EquipmentSlot.MAIN_HAND, E.EquipmentSlot.OFF_HAND]]
	else:
		self.equipable_slots = [[E.EquipmentSlot.MAIN_HAND], [E.EquipmentSlot.OFF_HAND]]
	
	super(display_name, weight, WeaponFeature.new(
		display_name,
		attacking_stats,
		damage,
		min_range,
		max_range,
		animation
	))
