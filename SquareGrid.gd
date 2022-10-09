extends "res://Map.gd"

var width = grid_width * grid_size
var height = grid_height * grid_size

func position_from_coordinates(x: int, y: int) -> Vector2:
	return Vector2(x * grid_size, y * grid_size)

func cell_centre_position(x: int, y: int) -> Vector2:
	return position_from_coordinates(x, y) + Vector2(0.5 * grid_size, 0.5 * grid_size)

func coordinates_from_position(p: Vector2) -> Coordinate:
	return Coordinate.new(p.x / grid_size, p.y / grid_size)

func draw_grid():
	# Set background dimensions
	$Background.rect_size = Vector2(width, height)
	
	# Draw vertical lines
	for i in (grid_width - 1):
		var offset = grid_size * (i + 1)
		var line = Line2D.new()
		line.width = 1
		line.default_color = Color.darkslategray
		line.add_point(Vector2(offset, 0))
		line.add_point(Vector2(offset, height))
		add_child(line)
	# Draw horizontal lines
	for i in (grid_height - 1):
		var offset = grid_size * (i + 1)
		var line = Line2D.new()
		line.width = 1
		line.default_color = Color.darkslategray
		line.add_point(Vector2(0, offset))
		line.add_point(Vector2(width, offset))
		add_child(line)

func get_adjacent_cells(x: int, y: int):
	var output = []
	if (y - 1) >= 0:
		output.append([x, y - 1])
	if (y + 1) < grid_height:
		output.append([x, y + 1])
	if (x - 1) >= 0:
		output.append([x - 1, y])
	if (x + 1) < grid_width:
		output.append([x + 1, y])
	return output

func cell_corners(x: int, y: int):
	var start = position_from_coordinates(x, y)
	return PoolVector2Array([
		start,
		start + Vector2(grid_size, 0),
		start + Vector2(grid_size, grid_size),
		start + Vector2(0, grid_size)
	])
