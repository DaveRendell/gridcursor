class_name Character

var display_name: String
var sprite: AnimatedSprite2D

var width = 1
var height = 1

# Might, Precision, Knowledge, Wit
var stats = [0, 0, 0, 0]

var hp: int = 1

var equipment: CharacterEquipment
var crests: Array[Crest] = [] as Array[Crest]
var temporary_effects: Array[Feature] = [] as Array[Feature]

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
	sprite: AnimatedSprite2D,
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
	
	for f in features():
		base_defence = max(base_defence, f.base_defence())
		defence_boost += f.defence_boost()
	
	return base_defence + stats[1] + defence_boost

func equip(slot: String, item: Equipment) -> void:
	if slot == "dual_hand":
		equipment.main_hand = item
		equipment.off_hand = null
	else:
		equipment.set(slot, item)

func features() -> Array[Feature]:
	var feats = [] as Array[Feature]
	
	for item in equipment.to_array():
		var equipped = item as Equipment
		if equipped and equipped.feature:
			feats.append(equipped.feature)
	feats.append_array(crests)
	feats.append_array(temporary_effects)
	return feats

func attacks() -> Array:
	var attacks = []
	for f in features():
		attacks.append_array(f.attacks())
	return attacks

func spells() -> Array:
	var spells = []
	for f in features():
		spells.append_array(f.spells())
	return spells

func post_attack_actions() -> Array:
	var actions = []
	for f in features():
		actions.append_array(f.post_attack_actions())
	return actions

func roll_skill(stat: E.Stat, skills: Array[String] = [] as Array[String]) -> RollResult:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var d1 = rng.randi_range(1, 6)
	var d2 = rng.randi_range(1, 6)
	
	var result = RollResult.new([d1, d2], stats[stat])
	print(display_name + " rolled " + str(result.total()))
	return result

func take_damage(damage: int) -> void:
	hp = max(0, hp - damage)

func is_down() -> bool:
	return hp <= 0
