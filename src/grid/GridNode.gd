extends Node2D

class_name GridNode
# Represents an object on a `Grid`

# Position on grid
export var x: int
export var y: int

func coordinate() -> Coordinate:
	return Coordinate.new(x, y)
