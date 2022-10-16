class_name Attack

var name: String
var min_range: int
var max_range: int
var attacking_stats: Array
var damage: int

func _init(name: String, min_range: int, max_range: int, attacking_stats: Array, damage: int):
	self.name = name
	self.min_range = min_range
	self.max_range = max_range
	self.attacking_stats = attacking_stats
	self.damage = damage

func can_attack_distance(distance: int) -> bool:
	return min_range <= distance and max_range >= distance
