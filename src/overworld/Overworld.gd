extends Node2D

var party = Party.new()

func _ready():
	$Map.add_party(party, Vector2i(3, 4))
	$Map.draw_nodes()
