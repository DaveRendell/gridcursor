extends Node2D

var teams = 2
var map: BattleMap

func _ready():
	pass

func setup_map(map_scene: PackedScene, party: Party) -> void:
	map = map_scene.instantiate()
	map.add_party(party)
	
	add_child(map)
	map.connect("next_turn",Callable(self,"next_turn"))

func next_turn():
	map.set_state_in_menu()
	
	for unit in map.list_units().filter(func(u): return u.team == map.current_turn):
		for feature in unit.character.features():
			feature.end_of_turn(map, unit)
		for effect in unit.character.temporary_effects:
			if effect.expires_at == TemporaryEffect.ExpiresAt.END_OF_TURN:
				unit.character.temporary_effects.erase(effect)
	
	map.current_turn = (map.current_turn + 1) % teams
	
	for unit in map.list_units().filter(func(u): return u.team == map.current_turn):
		for feature in unit.character.features():
			feature.start_of_turn(map, unit)
	
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
