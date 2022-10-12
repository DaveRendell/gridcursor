extends "res://src/grid/Grid.gd"
class_name Map
# A grid that represents a map, with player interactable objects on it.

var terrain_grid: CoordinateMap = CoordinateMap.new(grid_width, grid_height, [], 0)
var highlights: CoordinateMap = CoordinateMap.new(grid_width, grid_height, [], null)
var path = CoordinateList.new()

var terrain_types = []

func _ready() -> void:
	var file = File.new()
	file.open("res://data/terrain.json", File.READ)
	terrain_types = parse_json(file.get_as_text())
	terrain_grid.set_value(Coordinate.new(5, 5), 2)
	terrain_grid.set_value(Coordinate.new(5, 6), 2)
	terrain_grid.set_value(Coordinate.new(6, 6), 2)
	terrain_grid.set_value(Coordinate.new(7, 7), 3)
	terrain_grid.set_value(Coordinate.new(7, 8), 3)

func _draw():
	for coordinate in terrain_grid.coordinates():
		var terrain = terrain_grid.at(coordinate)
		var colour: Color = Color.black
		if terrain == 0:
			colour = Color.lightgreen
		if terrain == 1:
			colour = Color.lightgray
		if terrain == 2:
			colour = Color.darkgreen
		if terrain == 3:
			colour = Color.aqua
		draw_colored_polygon(cell_corners(coordinate), colour, PoolVector2Array(), null, null, true)
	for coordinate in highlights.coordinates():
		var colour = highlights.at(coordinate)
		if colour:
			colour.a = 0.4
			draw_colored_polygon(cell_corners(coordinate), colour, PoolVector2Array(), null, null, true)
	if path.size() > 0:
		for i in range(1, path.size()):
			var from = cell_centre_position(path.at(i - 1))
			var to = cell_centre_position(path.at(i))

			draw_line(from, to, Color.coral, grid_size * 0.5, true)
	
	draw_grid()
	draw_nodes()

func distance(coordinate_1: Coordinate, coordinate_2: Coordinate) -> int:
	push_error("Implement distance in inheriting class")
	return 0

func add_highlight(coordinate: Coordinate, colour: Color):
	highlights.set_value(coordinate, colour)
	update()

func get_adjacent_cells(coordinate: Coordinate) -> CoordinateList:
	push_error("Implement get_adjacent_cells in inheriting scene")
	return CoordinateList.new([])

func cell_corners(coordinate: Coordinate):
	push_error("Implement cell_corners in inheriting scene")

func node_array() -> CoordinateMap:
	return CoordinateMap.new(grid_width, grid_height, $GridNodes.get_children(), null)

func clear_highlights():
	highlights = CoordinateMap.new(grid_width, grid_height, [], null)
	update()

func draw_nodes():
	for node in $GridNodes.get_children():
		var grid_node = (node as GridNode)
		node.position = position_from_coordinates(grid_node.coordinate())

# Draw the grid for this coordinate system
func draw_grid():
	push_error("Implement draw_grid in inheriting scene")
