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

var zoom_level = 3

var new_toast = preload("res://src/ui/Toast.tscn")
var theme = preload("res://src/ui/theme.tres")

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
	draw_grid()

func _draw():
	for coordinate in highlights.coordinates():
		var colour = highlights.at(coordinate)
		if colour:
			draw_colored_polygon(cell_corners(coordinate), colour)
	if path.size() > 1:
		var color = Color.coral
		for i in range(1, path.size()):
			var from = cell_centre_position(path.at(i - 1))
			var to = cell_centre_position(path.at(i))

			draw_line(from, to, color, grid_size * 0.5, true)
			draw_circle(from, grid_size * 0.25, color)
		var last_point = cell_centre_position(path.last())
		var second_last_point = cell_centre_position(path.at(-2))
		var rotation = (last_point - second_last_point).angle()
		var arrow_head_points = [
			last_point + grid_size * Vector2(-0.25, -0.5).rotated(rotation),
			last_point + grid_size * Vector2(0.25, 0).rotated(rotation),
			last_point + grid_size * Vector2(-0.25, 0.5).rotated(rotation),
		]
		draw_colored_polygon(arrow_head_points, color)

func distance(coordinate_1: Coordinate, coordinate_2: Coordinate) -> int:
	push_error("Implement distance in inheriting class")
	return 0

func add_highlight(coordinate: Coordinate, colour: Color):
	highlights.set_value(coordinate, colour)
	update()

func add_highlights(coordinates: CoordinateList, colour: Color):
	colour.a = 0.3
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
			var popup_menu = PopupMenu.new()
			
			var options = ["End turn", "Cancel"]
			for i in options.size():
				var option = options[i]
				popup_menu.add_item(option, i)
			
			display_menu(popup_menu)
			
			var id = yield(popup_menu, "id_pressed")
			var option = options[id]
			
			if option == "End turn":
				next_turn()
			set_active(true)

func display_menu(popup_menu: PopupMenu) -> void:
	popup_menu.theme = theme
	popup_menu.popup_exclusive = true
	popup_menu.rect_scale = Vector2(zoom_level, zoom_level)
	popup_menu.set_current_index(0)
	set_active(false)
	
	yield(get_tree(), "idle_frame")
	$PopupLayer.add_child(popup_menu)
	popup_menu.popup_centered()
	
	yield(popup_menu, "id_pressed")
	popup_menu.queue_free()
	popup_menu.hide()

func draw_nodes():
	for node in $GridNodes.get_children():
		var grid_node = (node as GridNode)
		node.position = position_from_coordinates(grid_node.coordinate())

# Draw the grid for this coordinate system
func draw_grid():
	push_error("Implement draw_grid in inheriting scene")

func next_turn():
	emit_signal("next_turn")

func display_toast(text: String, delay: float = 1.0):
	var toasts_container = $PopupLayer/Toasts
	var toast = new_toast.instance()
	toast.rect_scale = Vector2(zoom_level, zoom_level)
	toast.add_text(text)
	toasts_container.add_child(toast)
	toasts_container.move_child(toast, 0)
	
	toasts_container.rect_position = Vector2(0, -(zoom_level * toast.rect_size.y))
	var animation = get_tree().create_tween()
	animation.tween_property(toasts_container, "rect_position", Vector2.ZERO, 0.25)
	
	get_tree().create_timer(delay).connect("timeout", toast, "delete", [Vector2.LEFT])
	
	return toast

