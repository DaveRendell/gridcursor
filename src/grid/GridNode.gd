extends Node2D

class_name GridNode
# Represents an object checked a `Grid`

# Position checked grid
@export var x: int
@export var y: int

func coordinate() -> Coordinate:
	return Coordinate.new(x, y)
