class_name BattleTerrain

var name: String
var movement_costs: Dictionary

func _init(_name: String, _movement_costs: Dictionary):
	name = _name
	movement_costs = _movement_costs

static func get_terrain(id: int) -> BattleTerrain:
	var battle_terrain_types = {
		-1: BattleTerrain.new("Flat terrain", {
			E.MovementType.FOOT: 1
		}),
		0: BattleTerrain.new("Foliage", {
			E.MovementType.FOOT: 2
		}),
		1: BattleTerrain.new("Cliff", {
		}),
		2: BattleTerrain.new("Deep Water", {
		})
	}
	return battle_terrain_types[id]
