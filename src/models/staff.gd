class_name Staff
extends Equipment

var attacks: Array
var spells: Array

func _init(display_name: String, weight: int, attacks: Array, spells: Array).(display_name, weight):
	self.attacks = attacks
	self.spells = spells
	self.equipable_slots = ["main_hand"]
	
func get_attacks() -> Array:
	return attacks

func get_spells() -> Array:
	return spells
