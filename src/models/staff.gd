class_name Staff
extends Equipment

class StaffFeature extends Feature:
	var staff_attacks: Array[Attack]
	var staff_spells: Array[Spell]
	
	func _init(_display_name: String, _attacks: Array[Attack], _spells: Array[Spell]):
		staff_attacks = _attacks
		staff_spells = _spells
		super(_display_name)
	
	func attacks() -> Array[Attack]:
		return staff_attacks
	
	func spells() -> Array[Spell]:
		return staff_spells

func _init(_display_name: String, _weight: int, _attacks: Array[Attack], _spells: Array[Spell]):
	self.equipable_slots = [[E.EquipmentSlot.MAIN_HAND], [E.EquipmentSlot.OFF_HAND]]
	super(_display_name, _weight, StaffFeature.new(_display_name, _attacks, _spells))
