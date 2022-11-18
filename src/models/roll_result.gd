class_name RollResult

var rolls: Array[int]
var modifier: int

func _init(_rolls: Array[int], _modifier: int):
	rolls = _rolls
	modifier = _modifier
	

func total() -> int:
	var out = 0
	for roll in rolls:
		out += roll
	out += modifier
	return out
