class_name RollResult

var rolls: Array[int]
var modifier: int

func _init(_rolls: Array, _modifier: int):
	rolls = _rolls
	modifier = _modifier
	

func total() -> int:
	var out = 0
	for roll in rolls:
		out += roll
	out += modifier
	return out

func _to_string():
	var out = "("
	for i in rolls.size():
		out += rolls[i]
		if i != rolls.size() - 1:
			out += ","
	out += " + "
	out += modifier
	out += " = "
	out += total()
	return out
