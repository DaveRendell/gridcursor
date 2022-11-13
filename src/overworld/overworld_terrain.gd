class_name OverworldTerrain

var name: String
var foot_movement_cost: int

func _init(_name: String, _foot_movement_cost: int):
	name = _name
	foot_movement_cost = _foot_movement_cost

static func get_terrain(id: int) -> OverworldTerrain:
	var overworld_terrain_types = {
		1: OverworldTerrain.new("Plains", 1),
		2: OverworldTerrain.new("Forest", 2),
		3: OverworldTerrain.new("Hills", 3),
		4: OverworldTerrain.new("Mountains", 4),
		5: OverworldTerrain.new("Town", 1),
		6: OverworldTerrain.new("Sea", -1),
	}
	return overworld_terrain_types[id]
