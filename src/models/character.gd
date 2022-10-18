class_name Character

var display_name: String
var sprite_sheet = preload("res://img/characters/Mage-Red.png")

# Might, Precision, Knowledge, Wit
var stats = [0, 0, 0, 0]

var hp: int = 1

var equipment: CharacterEquipment

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
	might: int = 0,
	precision: int = 0,
	knowledge: int = 0,
	wit: int = 0
):
	self.display_name = display_name
	self.stats = [might, precision, knowledge, wit]
	self.hp = max_hp()
	self.equipment = CharacterEquipment.new()

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
			attacks.append_array(x.get_attacks())
	return attacks

func sprite() -> AnimatedSprite:
	return PunyCharacterSprite.from_file(sprite_sheet)
