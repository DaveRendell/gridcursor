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
	var new_array = array.duplicate()
	new_array.append([coordinate.x, coordinate.y])
	return get_script().new(new_array)

func size() -> int:
	return array.size()

func has(coordinate: Coordinate) -> bool:
	return array.has([coordinate.x, coordinate.y])

func slice(start: int, end: int) -> CoordinateList:
	var new_array = []
	for i in range(0, end - start):
		new_array[i] = array[start + i]
	return get_script().new(new_array)

func remove(position: int) -> CoordinateList:
	var new_array = array.duplicate()
	new_array.remove(position)
	return get_script().new(new_array)

func last() -> Coordinate:
	return at(array.size() - 1)
		
