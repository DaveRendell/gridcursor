extends Node2D

var teams = 2

var map_scene = preload("res://src/battle/BattleMap.tscn")
var map: BattleMap

func _ready():
	map = map_scene.instantiate()
	
	###
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
	
	map.add_character(reginald, Vector2i(13, 9))
	map.add_character(yanil, Vector2i(14, 10))
	map.add_character(tobias, Vector2i(16, 11))
	map.add_blob(11, 10)
	map.add_blob(9, 8)
	map.add_blob(9, 11)
	map.add_blob(7, 9)
	map.add_blob(16, 6)
	map.add_blob(13, 7)
	map.add_blob(14, 15)
	map.add_blob(11, 14)
	
	map.add_big_blob(7, 12)
	###
	
	add_child(map)
	map.connect("next_turn",Callable(self,"next_turn"))


func next_turn():
	map.set_state_in_menu()
	map.current_turn = (map.current_turn + 1) % teams
	
	var message: String
	if map.current_turn == 1:
		message = "Monster's turn"
	else:
		message = "Player's turn"
	var toast = map.display_toast(message)
	await toast.tree_exiting
	
	for child in map.get_node("GridNodes").get_children():
		if child.has_method("set_state_unselected"):
			child.set_state_unselected(map)
	
	if map.current_turn == 0:
		print("Player turn starter")
		map.set_state_nothing_selected()
	else:
		print("CPU turn started")
		ComputerPlayer.execute_turn(map)
