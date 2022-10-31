class_name SquareGeometry extends Geometry

var grid_size: int
var grid_width: int
var grid_height: int

func _init(_grid_size: int, _grid_width: int, _grid_height: int):
	self.grid_size = _grid_size
	self.grid_width = _grid_width
	self.grid_height = _grid_height

func cell_centre_position(coordinate: Vector2i) -> Vector2:
	return grid_size * (Vector2(coordinate) + Vector2(0.5, 0.5)) 

func cell_containing_position(point: Vector2) -> Vector2i:
	return Vector2i(point.x / grid_size, point.y / grid_size)

func distance(coordinate_1: Vector2i, coordinate_2: Vector2i) -> int:
	var d_x = absi(coordinate_1.x - coordinate_2.x)
	var d_y = absi(coordinate_1.y - coordinate_2.y)
	return d_x + d_y

func adjacent_cells(coordinate: Vector2i) -> Array[Vector2i]:
	var directions = [
		Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP
	]
	return directions\
		.map(func(direction): return coordinate + direction)\
		.filter(func(cell): return cell.x >= 0 and cell.x < grid_width)\
		.filter(func(cell): return cell.y >= 0 and cell.y < grid_height)

func cell_corners(coordinate: Vector2i) -> Array[Vector2]:
	var corner_coordinates = [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)
	]
	return corner_coordinates\
		.map(func(corner): return coordinate + corner)\
		.map(func(corner_coordinate): return grid_size * Vector2(corner_coordinate))

func map_dimensions() -> Vector2:
	return Vector2(grid_size * grid_width, grid_size * grid_height)
