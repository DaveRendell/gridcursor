class_name Coordinate
# Class for holding a coordinate in a `Grid`. Contains x (horizontal) and 
# y (vertical) co-ordinates.

var x: int
var y: int

func _init(x: int, y: int):
	self.x = x
	self.y = y

func _to_string() -> String:
	return "(x: %d, y: %d)" % [x, y]

func equals(other: Coordinate) -> bool:
	return (x == other.x) and (y == other.y)

func trim(max_width: int, max_height: int) -> Coordinate:
	return get_script().new(
		max(0, min(x, max_width - 1)),
		max(0, min(y, max_height - 1)))

func add_x(dx: int) -> Coordinate:
	return get_script().new(x + dx, y)

func add_y(dy: int) -> Coordinate:
	return get_script().new(x, y + dy)

func is_in(array: Array) -> bool:
	for item in array:
		var coordinate = item as Coordinate
		if coordinate and self.equals(coordinate):
			return true
	return false
