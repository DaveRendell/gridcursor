class_name Party

const FORMATION_DIMENSIONS = Vector2i(3, 3)

var characters: Array[Character]
var formation: CoordinateMap

var marches_remaining: int = 4

func _init():
	# Hardcoded for now
	var blue_soldier_sprite_sheet = preload("res://img/characters/Paladin.png")
	var blue_soldier_sprite = PunyCharacterSprite.character_sprite(blue_soldier_sprite_sheet)
	var red_mage_sprite_sheet = preload("res://img/characters/Esper-Red.png")
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
		[Teleport.new() as Spell, Fireball.new() as Spell]
		)

	var steel_armour = Armour.new("Steel armour", 5, 8, {
		1: Image.load_from_file("res://img/characters/humanoid/layer_1_shoes/IronBoots.png"),
		2: Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/SteelArmour.png"),
		3: Image.load_from_file("res://img/characters/humanoid/layer_3_gloves/IronGloves.png"),
		6: Image.load_from_file("res://img/characters/humanoid/layer_6_headgears/SoldierSteelHelmRed.png")
	})

	var shield = Shield.new("Buckler", 4, 1)
	
	var skirmisher = Skirmisher.new()

	var reginald = Character.new("Reginald", blue_soldier_sprite, 3, 2, 1, 1)
	reginald.equip("main_hand", sword)
	reginald.equip("off_hand", shield)
	reginald.equip("clothing", steel_armour)
	
	var yanil = Character.new("Yanil", red_mage_sprite, 0, 2, 3, 2)
	yanil.equip("main_hand", staff)
	
	var tobias = Character.new("Tobias", green_archer_sprite, 1, 3, 2, 1)
	tobias.equip("main_hand", short_bow)
	tobias.crests = [skirmisher]
	
	var skin_tone = 2
	var larry = Humanoid.new("Lara", Humanoid.AppearanceDetails.new(skin_tone, 7, E.HairColour.BLUE), 1, 2, 3, 2)
	#larry.equip("clothing", steel_armour)
	larry.equip("main_hand", sword)
	###
	
	characters = [reginald, yanil, tobias, larry]
	formation = CoordinateMap.new(FORMATION_DIMENSIONS.x, FORMATION_DIMENSIONS.y)
	formation.set_value(Vector2i(0, 0), reginald)
	formation.set_value(Vector2i(1, 1), yanil)
	formation.set_value(Vector2i(0, 2), tobias)
	formation.set_value(Vector2i(2, 0), larry)
