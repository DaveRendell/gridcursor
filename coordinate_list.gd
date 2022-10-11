class_name CoordinateList
# Class for a list of `Coordinate` objects. Unlike Godot's standard Array class,
# this class is intended to be used as an immutable object.
# Motivation for not just using as array is the need for a `has` method that
# doesn't compare by reference.

var array: Array

func _init(from: Array = []):
	for item in from:
		var coordinate = item as Coordinate
		if coordinate:
			array.append([coordinate.x, coordinate.y])

func at(i: int) -> Coordinate:
	return Coordinate.new(array[i][0], array[i][1])

func append(coordinate: Coordinate) -> CoordinateList:
	var new_array = to_array()
	new_array.append(coordinate)
	return get_script().new(new_array)

func size() -> int:
	return array.size()

func has(coordinate: Coordinate) -> bool:
	return array.has([coordinate.x, coordinate.y])

func slice(start: int, end: int) -> CoordinateList:
	var new_list = get_script().new()
	for i in range(0, end - start):
		new_list = new_list.append(array[start + i])
	return new_list

func remove(position: int) -> CoordinateList:
	var new_array = array.duplicate()
	new_array.remove(position)
	return get_script().new(new_array)

func last() -> Coordinate:
	return at(array.size() - 1)

func find(coordinate: Coordinate) -> int:
	return array.find([coordinate.x, coordinate.y])

func reverse() -> CoordinateList:
	var new_array = to_array()
	new_array.invert()
	return get_script().new(new_array)

func to_array() -> Array:
	var output = []
	for item in array:
		output.append(Coordinate.new(item[0], item[1]))
	return output
		
