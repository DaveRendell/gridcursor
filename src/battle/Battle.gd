extends Node2D

var teams = 2

var map_scene = preload("res://src/map/SquareGrid.tscn")
var map: Map

func _ready():
	map = map_scene.instance()
	add_child(map)
	map.connect("next_turn", self, "next_turn")


func next_turn():
	map.active = false
	map.current_turn = (map.current_turn + 1) % teams
	for child in map.get_node("GridNodes").get_children():
		if child.has_method("state_to_unselected"):
			child.state_to_unselected(map)
			var message: String
			if map.current_turn == 1:
				message = "Monster's turn"
			else:
				message = "Player's turn"
			var toast = map.display_toast(message)
			yield(toast, "tree_exited")
			
			if map.current_turn == 0:
				map.active = true
			else:
				next_turn()
