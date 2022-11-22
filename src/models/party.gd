class_name Party

const FORMATION_DIMENSIONS = Vector2i(3, 3)

var characters: Array[Character]
var formation: CoordinateMap

var marches_remaining: int = 4

func _init():
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
	var mage_robes = Clothing.new("Mage robes", 1, null, {
		2: Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/BasicRed.png"),
		6: Image.load_from_file("res://img/characters/humanoid/layer_6_headgears/EsperHoodRed.png"),
	})
	var scout_tunic = Clothing.new("Mage robes", 1, null, {
		2: Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/LeatherTunic.png"),
		6: Image.load_from_file("res://img/characters/humanoid/layer_6_headgears/ArcherHatGreen.png"),
	})

	var shield = Shield.new("Buckler", 4, 1)
	
	var skirmisher = Skirmisher.new()
	var song_of_fortitude = SongOfFortitude.new()
	var beast_form_wolf = BeastFormWolf.new()

	var reginald = Humanoid.new("Reginald", Ancestry.human(), Humanoid.AppearanceDetails.new(5, 1, E.HairColour.GRAY), 3, 2, 1, 1)
	reginald.equip("main_hand", sword)
	reginald.equip("off_hand", shield)
	reginald.equip("clothing", steel_armour)
	
	var yanil = Humanoid.new("Yanil", Ancestry.human(), Humanoid.AppearanceDetails.new(2, 7, E.HairColour.RED), 0, 2, 3, 2)
	yanil.equip("main_hand", staff)
	yanil.equip("clothing", mage_robes)
	yanil.crests = [song_of_fortitude]
	
	var myla = Humanoid.new("Myla", Ancestry.elf(), Humanoid.AppearanceDetails.new(7, 1, E.HairColour.WHITE), 1, 3, 2, 1)
	myla.equip("main_hand", short_bow)
	#myla.equip("clothing", scout_tunic)
	myla.crests = [beast_form_wolf]

	###
	
	characters = [reginald, yanil, myla]
	formation = CoordinateMap.new(FORMATION_DIMENSIONS.x, FORMATION_DIMENSIONS.y)
	formation.set_value(Vector2i(0, 0), reginald)
	formation.set_value(Vector2i(1, 1), yanil)
	formation.set_value(Vector2i(0, 2), myla)
