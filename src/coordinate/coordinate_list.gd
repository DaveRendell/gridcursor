class_name CoordinateList
# Class for a list of `Vector2i` objects. Unlike Godot's standard Array class,
# this class is intended to be used as an immutable object.
# Motivation for not just using as array is the need for a `has` method that
# doesn't compare by reference.

var array: Array

func _init(from: Array = []):
	for item in from:
		var coordinate = item as Vector2i
		if coordinate:
			array.append([coordinate.x, coordinate.y])

func at(i: int) -> Vector2i:
	return Vector2i(array[i][0], array[i][1])

func append(coordinate: Vector2i) -> CoordinateList:
	var new_array = to_array()
	new_array.append(coordinate)
	return get_script().new(new_array)

func size() -> int:
	return array.size()

func has(coordinate: Vector2i) -> bool:
	return array.has([coordinate.x, coordinate.y])

func slice(start: int, end: int) -> CoordinateList:
	var coords = []
	for i in range(start, end + 1):
		var coordinate = at(i)
		coords.append(coordinate)
	return get_script().new(coords)

func remove_at(position: int) -> CoordinateList:
	var new_array = array.duplicate()
	new_array.remove_at(position)
	return get_script().new(new_array)

func last() -> Vector2i:
	return at(array.size() - 1)

func find(coordinate: Vector2i) -> int:
	return array.find([coordinate.x, coordinate.y])

func reverse() -> CoordinateList:
	var new_array = to_array()
	new_array.reverse()
	return get_script().new(new_array)

func concat(other: CoordinateList) -> CoordinateList:
	var out = to_array()
	out.append_array(other.to_array())
	return get_script().new(out)

func to_array() -> Array:
	var output = []
	for item in array:
		output.append(Vector2i(item[0], item[1]))
	return output

func _to_string():
	var output = "CoordList(["
	for coord in to_array():
		output += coord._to_string()
	output += "])"
	return output
