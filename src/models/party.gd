class_name Party

const FORMATION_DIMENSIONS = Vector2i(3, 3)

var characters: Array[Character]
var formation: CoordinateMap

func _init():
	# Hardcoded for now
	var blue_soldier_sprite_sheet = preload("res://img/characters/Soldier-Blue.png")
	var blue_soldier_sprite = PunyCharacterSprite.character_sprite(blue_soldier_sprite_sheet)
	var red_mage_sprite_sheet = preload("res://img/characters/Mage-Red.png")
	var red_mage_sprite = PunyCharacterSprite.character_sprite(red_mage_sprite_sheet)
	var green_archer_sprite_sheet = preload("res://img/characters/Archer-Green.png")
	var green_archer_sprite= PunyCharacterSprite.character_sprite(green_archer_sprite_sheet)
	var slime_sprite_sheet = preload("res://img/characters/Slime.png")
	var slime_sprite_1 = PunyCharacterSprite.slime_sprite(slime_sprite_sheet)
	var slime_sprite_2 = PunyCharacterSprite.slime_sprite(slime_sprite_sheet)
	
	var sword = Weapon.new("Sword", 5, [0], 3, 1, 1, false, "sword")
	var short_bow = Weapon.new("Short bow", 5, [1], 2, 2, 8, true, "bow")
	var great_sword = Weapon.new("Greatsword", 10, [1], 5, 1, 1, true, "sword")
	var staff = Staff.new(
		"Fire Rod",
		3,
		[Attack.new("Firebolt", 1, 4, [3], 3, "staff")],
		[Teleport.new(), Fireball.new()]
		)

	var leather_armour = Armour.new("Leather armour", 5, 8)

	var shield = Shield.new("Buckler", 4, 1)

	var reginald = Character.new("Reginald", blue_soldier_sprite, 3, 2, 1, 1)
	reginald.equip("main_hand", sword)
	reginald.equip("off_hand", shield)
	reginald.equip("clothing", leather_armour)
	
	var yanil = Character.new("Yanil", red_mage_sprite, 0, 2, 3, 2)
	yanil.equip("main_hand", staff)
	
	var tobias = Character.new("Tobias", green_archer_sprite, 1, 3, 2, 1)
	tobias.equip("main_hand", short_bow)
	###
	
	characters = [reginald, yanil, tobias]
	formation = CoordinateMap.new(FORMATION_DIMENSIONS.x, FORMATION_DIMENSIONS.y)
	formation.set_value(Vector2i(0, 0), reginald)
	formation.set_value(Vector2i(1, 1), yanil)
	formation.set_value(Vector2i(0, 2), tobias)
