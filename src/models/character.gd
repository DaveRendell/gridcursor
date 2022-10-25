class_name Character

var display_name: String
var sprite: AnimatedSprite

# Might, Precision, Knowledge, Wit
var stats = [0, 0, 0, 0]

var hp: int = 1

var equipment: CharacterEquipment

var die_when_downed = false

class CharacterEquipment:
	func _init():
		pass
	var main_hand: Equipment
	var off_hand: Equipment
	var clothing: Equipment
	
	func to_array() -> Array:
		var all = [main_hand, off_hand, clothing]
		var out = []
		for equipment in all:
			if all:
				out.append(equipment)
		return out

func _init(
	display_name: String,
	sprite: AnimatedSprite,
	might: int = 0,
	precision: int = 0,
	knowledge: int = 0,
	wit: int = 0
):
	self.display_name = display_name
	self.stats = [might, precision, knowledge, wit]
	self.hp = max_hp()
	self.equipment = CharacterEquipment.new()
	self.sprite = sprite

func max_hp() -> int:
	return int(max(2 * stats[0] + stats[1] + stats[2] + stats[3], 1))

func defence() -> int:
	var base_defence: int = 7
	var defence_boost = 0
	
	for x in equipment.to_array():
		var item = x as Equipment
		if item:
			base_defence = max(base_defence, item.set_base_defence())
			defence_boost += item.set_defence_boost()
	
	return base_defence + stats[1] + defence_boost

func equip(slot: String, item: Equipment) -> void:
	if slot == "dual_hand":
		equipment.main_hand = item
		equipment.off_hand = null
	else:
		equipment.set(slot, item)

func attacks() -> Array:
	var attacks = []
	for x in equipment.to_array():
		var item = x as Equipment
		if item:
			attacks.append_array(item.get_attacks())
	return attacks

func spells() -> Array:
	var spells = []
	for x in equipment.to_array():
		var item = x as Equipment
		if item:
			spells.append_array(item.get_spells())
	return spells

func take_damage(damage: int) -> void:
	hp = max(0, hp - damage)

func is_down() -> bool:
	return hp <= 0
