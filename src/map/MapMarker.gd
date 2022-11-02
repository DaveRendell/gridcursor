extends Node2D

class_name MapMarker
# Represents an object checked a `Grid`

# Position checked grid
@export var x: int
@export var y: int

@export var width: int = 1
@export var height: int = 1

func coordinate() -> Vector2i:
	return Vector2i(x, y)

func cells(at: Vector2i = coordinate()) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for i in width:
		for j in height:
			out.append(Vector2i(at.x + i, at.y + j))
	return out
	
