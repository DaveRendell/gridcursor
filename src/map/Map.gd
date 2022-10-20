extends "res://src/grid/Grid.gd"
class_name Map
# A grid that represents a map, with player interactable objects on it.

signal next_turn

var terrain_grid: CoordinateMap = CoordinateMap.new(grid_width, grid_height, [], 0)
var highlights: CoordinateMap = CoordinateMap.new(grid_width, grid_height, [], null)
var path = CoordinateList.new()

var terrain_types = []

var teams = 2
var current_turn = 0

var new_menu = preload("res://src/menu/Menu.tscn")
var new_toast = preload("res://src/PopupDialog.tscn")

func _ready() -> void:
	var file = File.new()
	file.open("res://data/terrain.json", File.READ)
	terrain_types = parse_json(file.get_as_text())
	terrain_grid.set_value(Coordinate.new(5, 5), 2)
	terrain_grid.set_value(Coordinate.new(5, 6), 2)
	terrain_grid.set_value(Coordinate.new(6, 6), 2)
	terrain_grid.set_value(Coordinate.new(7, 7), 3)
	terrain_grid.set_value(Coordinate.new(7, 8), 3)
	
	draw_nodes()

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
			colour.a = 0.6
			draw_colored_polygon(cell_corners(coordinate), colour, PoolVector2Array(), null, null, true)
	if path.size() > 0:
		for i in range(1, path.size()):
			var from = cell_centre_position(path.at(i - 1))
			var to = cell_centre_position(path.at(i))

			draw_line(from, to, Color.coral, grid_size * 0.5, true)
	
	draw_grid()

func distance(coordinate_1: Coordinate, coordinate_2: Coordinate) -> int:
	push_error("Implement distance in inheriting class")
	return 0

func add_highlight(coordinate: Coordinate, colour: Color):
	highlights.set_value(coordinate, colour)
	update()

func add_highlights(coordinates: CoordinateList, colour: Color):
	for coordinate in coordinates.to_array():
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

func click_position(coordinate: Coordinate):
	if active:
		print("Clicked grid position %s" % [coordinate])
		if send_clicks_as_signal:
			if !clickable_cells or clickable_cells.has(coordinate):
				print("Cursor on clickable cell, emitting click signal")
				emit_signal("click", self)
			else:
				print("Cursor on non clickable cell, ignoring...")
		else:
			for child in $GridNodes.get_children():
				var node = child as GridNode
				if node and node.has_method("select"):
					if node.coordinate().equals(coordinate):
						return node.select(self)
			# If no unit selected
			var menu = new_menu.instance()
			menu.set_options([
				MenuOption.new("end_turn", "End turn"),
				MenuOption.new("cancel", "Cancel"),
			])
			menu.position = position_from_coordinates(cursor) + Vector2(grid_size, 0)
			menu.z_index = 10
			add_child(menu)
			set_active(false)
			var option = yield(menu, "option_selected")
			
			menu.queue_free()
			if option == "end_turn":
				next_turn()
			yield(get_tree(), "idle_frame")
			set_active(true)

func draw_nodes():
	for node in $GridNodes.get_children():
		var grid_node = (node as GridNode)
		node.position = position_from_coordinates(grid_node.coordinate())

# Draw the grid for this coordinate system
func draw_grid():
	push_error("Implement draw_grid in inheriting scene")

func next_turn():
	emit_signal("next_turn")

func display_toast(text: String, delay: float = 1.0) -> Popup:
	var toast = new_toast.instance()
	toast.get_node("CenterContainer/Label").text = text
	add_child(toast)
	toast.popup_centered()
	var timer = get_tree().create_timer(delay)
	timer.connect("timeout", toast, "queue_free")
	return toast
	
