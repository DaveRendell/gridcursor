extends "res://src/grid/Grid.gd"
class_name Map
# A grid that represents a map, with player interactable objects checked it.

signal next_turn

var terrain_grid: CoordinateMap = CoordinateMap.new(grid_width, grid_height, [], 0)
var highlights: CoordinateMap = CoordinateMap.new(grid_width, grid_height, [], null)
var path: Array[Vector2i] = []

var terrain_types = []

var teams = 2
var current_turn = 0

var zoom_level = 1.0

var new_toast = preload("res://src/ui/Toast.tscn")
var theme = preload("res://src/ui/theme.tres")
var tpk_popup_scene = preload("res://src/map/TPKPopup.tscn")
var victory_screen_scene = preload("res://src/map/VictoryScreen.tscn")
var battle_menu_scene = preload("res://src/ui/BattleMenu.tscn")

func _ready() -> void:
	var file = FileAccess.open("res://data/terrain.json", FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	terrain_types = test_json_conv.get_data()
	terrain_grid.set_value(Vector2i(5, 5), 2)
	terrain_grid.set_value(Vector2i(5, 6), 2)
	terrain_grid.set_value(Vector2i(6, 6), 2)
	terrain_grid.set_value(Vector2i(7, 7), 3)
	terrain_grid.set_value(Vector2i(7, 8), 3)
	
	draw_nodes()
	draw_grid()

func _draw():
	for coordinate in highlights.coordinates():
		var colour = highlights.at(coordinate)
		if colour:
			draw_colored_polygon(cell_corners(coordinate), colour)
	if path.size() > 1:
		var color = Color.CORAL
		for i in range(1, path.size()):
			var from = cell_centre_position(path[i - 1])
			var to = cell_centre_position(path[i])

			draw_line(from,to,color,grid_size * 0.5)
			draw_circle(from, grid_size * 0.25, color)
		var last_point = cell_centre_position(path.back())
		var second_last_point = cell_centre_position(path[-2])
		var rotation = (last_point - second_last_point).angle()
		var arrow_head_points = [
			last_point + grid_size * Vector2(-0.25, -0.5).rotated(rotation),
			last_point + grid_size * Vector2(0.25, 0).rotated(rotation),
			last_point + grid_size * Vector2(-0.25, 0.5).rotated(rotation),
		]
		draw_colored_polygon(arrow_head_points, color)

func distance(coordinate_1: Vector2i, coordinate_2: Vector2i) -> int:
	push_error("Implement distance in inheriting class")
	return 0

func add_highlight(coordinate: Vector2i, colour: Color):
	highlights.set_value(coordinate, colour)
	queue_redraw()

func add_highlights(coordinates: Array[Vector2i], colour: Color):
	colour.a = 0.3
	for coordinate in coordinates:
		highlights.set_value(coordinate, colour)
	queue_redraw()

func get_adjacent_cells(coordinate: Vector2i) -> Array[Vector2i]:
	push_error("Implement get_adjacent_cells in inheriting scene")
	return []

func cell_corners(coordinate: Vector2i):
	push_error("Implement cell_corners in inheriting scene")

func node_array() -> CoordinateMap:
	return CoordinateMap.new(grid_width, grid_height, $GridNodes.get_children(), null)

func clear_highlights():
	highlights = CoordinateMap.new(grid_width, grid_height, [], null)
	queue_redraw()

func click_position(coordinate: Vector2i):
	if state == GridState.NOTHING_SELECTED:
		print("Clicked grid position %s" % [coordinate])
		for child in $GridNodes.get_children():
				var node = child as GridNode
				if node and node.has_method("select"):
					if node.coordinate() == coordinate:
						return node.select(self)
		# If no unit selected
		var popup_menu = battle_menu_scene.instantiate()
		
		var options = ["End turn", "Cancel"]
		for i in options.size():
			var option = options[i]
			popup_menu.add_item(option, i)
		
		display_menu(popup_menu)
		popup_menu.popup_hide.connect(set_state_nothing_selected)
		
		var id = await popup_menu.id_pressed
		var option = options[id]
		
		if option == "End turn":
			next_turn.emit()
		if option == "Cancel":
			set_state_nothing_selected()
	if state == GridState.UNIT_CONTROLLED:
		print("Clicked grid position %s" % [coordinate])
		if clickable_cells.has(coordinate):
			emit_signal("click", self)

func display_menu(popup_menu: BattleMenu) -> void:
	popup_menu.set_focused_item(0)
	set_state_in_menu()
	
	$PopupLayer.add_child(popup_menu)
	popup_menu.popup_centered()
	
	await popup_menu.id_pressed
	popup_menu.queue_free()

func draw_nodes():
	for node in $GridNodes.get_children():
		var grid_node = (node as GridNode)
		node.position = position_from_coordinates(grid_node.coordinate())

# Draw the grid for this coordinate system
func draw_grid():
	push_error("Implement draw_grid in inheriting scene")


func display_toast(text: String, delay: float = 1.0):
	var toasts_container = $PopupLayer/Toasts
	var toast = new_toast.instantiate()
	toast.scale = Vector2(zoom_level, zoom_level)
	toast.add_text(text)
	toasts_container.add_child(toast)
	toasts_container.move_child(toast, 0)
	
	toasts_container.position = Vector2(0, -(zoom_level * toast.size.y))
	var animation = get_tree().create_tween()
	animation.tween_property(toasts_container, "position", Vector2.ZERO, 0.25)
	
	get_tree().create_timer(delay).connect("timeout",Callable(toast,"delete").bind(Vector2.LEFT))
	
	return toast

func check_win_condition():
	var player_unit_count = 0
	var enemy_unit_count = 0
	for unit in $GridNodes.get_children():
		if !unit.character.is_down():
			if unit.team == 0:
				player_unit_count += 1
			else:
				enemy_unit_count += 1
	if player_unit_count == 0:
		set_state_in_menu()
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.BLACK, 1.0)
		await tween.finished

		var tpk_popup = tpk_popup_scene.instantiate()
		$PopupLayer.add_child(tpk_popup)
		tpk_popup.popup_centered()
		
		print("TPK")
	elif enemy_unit_count == 0:
		set_state_in_menu()
		var victory_popup = victory_screen_scene.instantiate()
		$PopupLayer.add_child(victory_popup)
		victory_popup.popup_centered()
		
		print("A winner is you")
