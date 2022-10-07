extends "res://Grid.gd"

var width = grid_width * grid_size
var height = grid_height * grid_size

func position_from_coordinates(x: int, y: int) -> Vector2:
	return Vector2(x * grid_size, y * grid_size)

func coordinates_from_position(p: Vector2) -> Array:
	return [p.x / grid_size, p.y / grid_size]

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

func add_highlight(x: int, y: int, color: Color):
	var r = ColorRect.new()
	r.rect_position = position_from_coordinates(x, y)
	r.rect_size = Vector2(grid_size, grid_size)
	r.color = color
	r.show_behind_parent = true
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Highlights.add_child(r)

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
