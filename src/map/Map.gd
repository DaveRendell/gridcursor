extends "res://src/grid/Grid.gd"
class_name Map
# A grid that represents a map, with player interactable objects checked it.

signal next_turn

var terrain_grid: CoordinateMap = CoordinateMap.new(grid_width, grid_height, [], 0)
var units: CoordinateMap = CoordinateMap.new(grid_width, grid_height)
var highlights: CoordinateMap = CoordinateMap.new(grid_width, grid_height)
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
	
	setup_camera()
	draw_nodes()
	draw_grid()

func _draw():
	for coordinate in highlights.coordinates():
		var colour = highlights.at(coordinate)
		if colour:
			draw_colored_polygon(geometry.cell_corners(coordinate), colour)
	if path.size() > 1:
		var color = Color.CORAL
		for i in range(1, path.size()):
			var from = geometry.cell_centre_position(path[i - 1])
			var to = geometry.cell_centre_position(path[i])

			draw_line(from,to,color,grid_size * 0.5)
			draw_circle(from, grid_size * 0.25, color)
		var last_point = geometry.cell_centre_position(path.back())
		var second_last_point = geometry.cell_centre_position(path[-2])
		var rotation = (last_point - second_last_point).angle()
		var arrow_head_points = [
			last_point + grid_size * Vector2(-0.25, -0.5).rotated(rotation),
			last_point + grid_size * Vector2(0.25, 0).rotated(rotation),
			last_point + grid_size * Vector2(-0.25, 0.5).rotated(rotation),
		]
		draw_colored_polygon(arrow_head_points, color)

func setup_camera():
	var map_size = geometry.map_dimensions()
	var view_size = get_viewport().size
	var width = grid_size * grid_width
	var height = grid_size * grid_height
	var h_margin = max(0, (view_size.x / 3 - map_size.x) / 2)
	var v_margin = max(0, (view_size.y / 3 - map_size.y) / 2)
	var camera = $Cursor/Camera
	camera.zoom = Vector2(zoom_level, zoom_level)
	camera.limit_left = -h_margin
	camera.limit_right = width + h_margin
	camera.limit_top = -v_margin
	camera.limit_bottom = height + v_margin
	
	var h_drag_margin = 1 - (12 * zoom_level * grid_size / view_size.x)
	var v_drag_margin = 1 - (12 * zoom_level * grid_size / view_size.y)
	camera.drag_left_margin = h_drag_margin
	camera.drag_right_margin = h_drag_margin
	camera.drag_top_margin = v_drag_margin
	camera.drag_bottom_margin = v_drag_margin
	camera.position = Vector2(grid_size / 2, grid_size / 2)

func add_highlight(coordinate: Vector2i, colour: Color):
	highlights.set_value(coordinate, colour)
	queue_redraw()

func add_highlights(coordinates: Array[Vector2i], colour: Color):
	colour.a = 0.3
	for coordinate in coordinates:
		highlights.set_value(coordinate, colour)
	queue_redraw()

func clear_highlights():
	highlights = CoordinateMap.new(grid_width, grid_height, [], null)
	queue_redraw()

func update_units() -> void:
	units = CoordinateMap.new(grid_width, grid_height, $GridNodes.get_children(), null)

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
		node.position = geometry.cell_centre_position(grid_node.coordinate())

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
