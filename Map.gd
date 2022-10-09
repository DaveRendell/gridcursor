extends "res://Grid.gd"
class_name Map

var terrain_grid: Array
var highlights: Array = []
var path = []

var terrain_types = []

func _ready() -> void:
	var file = File.new()
	file.open("res://terrain.json", File.READ)
	terrain_types = parse_json(file.get_as_text())
	terrain_grid = empty_grid(0)
	terrain_grid[5][5] = 2
	terrain_grid[5][6] = 2
	terrain_grid[6][6] = 2
	terrain_grid[7][7] = 3
	terrain_grid[7][8] = 3
	var a = Coordinate.new(5, 6)
	print(a)

func _draw():
	for i in grid_width:
		for j in grid_height:
			var terrain = terrain_grid[i][j]
			var colour: Color = Color.black
			if terrain == 0:
				colour = Color.lightgreen
			if terrain == 1:
				colour = Color.lightgray
			if terrain == 2:
				colour = Color.darkgreen
			if terrain == 3:
				colour = Color.aqua
			draw_colored_polygon(cell_corners(i, j), colour, PoolVector2Array(), null, null, true)
	for highlight in highlights:
		var x = highlight[0]
		var y = highlight[1]
		var colour = highlight[2]
		colour.a = 0.4
		draw_colored_polygon(cell_corners(x, y), colour, PoolVector2Array(), null, null, true)
	if path.size() > 0:
		for i in range(1, path.size()):
			var from = cell_centre_position(path[i - 1][0], path[i - 1][1])
			var to = cell_centre_position(path[i][0], path[i][1])

			draw_line(from, to, Color.coral, grid_size * 0.5, true)
	
	draw_grid()
	draw_nodes()

func add_highlight(x: int, y: int, colour: Color):
	highlights.append([x, y, colour])
	update()

func get_adjacent_cells(x: int, y: int):
	push_error("Implement get_adjacent_cells in inheriting scene")

func cell_corners(x: int, y: int):
	push_error("Implement cell_corners in inheriting scene")

func node_array():
	var output = []
	output.resize(grid_width)
	for i in grid_height:
		var col = []
		col.resize(grid_height)
		output[i] = col
	for node in $GridNodes.get_children():
		output[node.x][node.y] = node
	return output

func clear_highlights():
	highlights = []
	update()

func draw_nodes():
	for node in $GridNodes.get_children():
		var grid_node = (node as GridNode)
		node.position = position_from_coordinates(grid_node.x, grid_node.y)

# Draw the grid for this coordinate system
func draw_grid():
	push_error("Implement draw_grid in inheriting scene")
