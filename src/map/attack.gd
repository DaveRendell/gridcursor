class_name Attack

var name: String
var min_range: int
var max_range: int

func _init(name: String, min_range: int, max_range: int):
	self.name = name
	self.min_range = min_range
	self.max_range = max_range

func can_attack_distance(distance: int) -> bool:
	return min_range <= distance and max_range >= distance
