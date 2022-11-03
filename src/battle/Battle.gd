extends Node2D

var teams = 2

var map_scene = preload("res://src/battle/BattleMap.tscn")
var map: BattleMap

var party: Party

func _ready():
	setup_map()

func setup_map() -> void:
	map = map_scene.instantiate()
	party = Party.new()
	var party_spawn_location = Vector2i(13, 9)
	var mobs = CoordinateMap.new(map.grid_width, map.grid_height)
	
	mobs.set_value(Vector2i(11, 10), Blobber.new())
	mobs.set_value(Vector2i(9, 8), Blobber.new())
	mobs.set_value(Vector2i(9, 11), Blobber.new())
	mobs.set_value(Vector2i(7, 9), Blobber.new())
	mobs.set_value(Vector2i(16, 6), Blobber.new())
	mobs.set_value(Vector2i(13, 7), Blobber.new())
	mobs.set_value(Vector2i(14, 15), Blobber.new())
	mobs.set_value(Vector2i(11, 14), Blobber.new())
	
	map.add_party(party_spawn_location, party)
	map.add_mobs(mobs)
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
