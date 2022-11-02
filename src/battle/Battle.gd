extends Node2D

var teams = 2

var map_scene = preload("res://src/battle/BattleMap.tscn")
var map: BattleMap
var party_spawn_location = Vector2i(13, 9)
var party: Party

func _ready():
	map = map_scene.instantiate()
	party = Party.new()
	
	map.add_party(party_spawn_location, party)
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
