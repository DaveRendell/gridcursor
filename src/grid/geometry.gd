# Describes the geometry of a grid map - e.g. square, hex, isometric...
class_name Geometry

func cell_centre_position(coordinate: Vector2i) -> Vector2:
	push_error("Not implemented")
	return Vector2.ZERO

func cell_containing_position(point: Vector2) -> Vector2i:
	push_error("Not implemented")
	return Vector2i.ZERO

func distance(coordinate_1: Vector2i, coordinate_2: Vector2i) -> int:
	push_error("Not implemented")
	return 0

func adjacent_cells(coordinate: Vector2i) -> Array[Vector2i]:
	push_error("Not implemented")
	return []

func cell_corners(coordinate: Vector2i) -> Array[Vector2]:
	push_error("Not implemented")
	return []
