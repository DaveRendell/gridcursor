class_name Attack

var min_range: int
var max_range: int
var can_attack_after_moving: bool

func _init(min_range: int, max_range: int, can_attack_after_moving: bool):
	self.min_range = min_range
	self.max_range = max_range
	self.can_attack_after_moving = can_attack_after_moving
