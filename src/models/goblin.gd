class_name Goblin
extends Character

func _init().("Goblin", 2, 3, 0, 0):
	equipment.main_hand = Weapon.new("Shortsword", 5, [0, 1], 3)
