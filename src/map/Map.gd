class_name Map extends Node2D
# A grid that represents a map, with player interactable objects checked it.

signal click
signal cursor_move


@export var grid_size: int = 16
@export var grid_width: int = 20
@export var grid_height: int = 20

var geometry: Geometry

# Cursor properties
var cursor: Vector2i = Vector2i(0, 0)
var mouse_in_grid = false
var scrolling: bool = false

var highlights: CoordinateMap = CoordinateMap.new(grid_width, grid_height)
var clickable_cells: Array[Vector2i] = []

enum GridState {
	NOTHING_SELECTED, # Cursor active, select units checked click
	IN_MENU, # Hide cursor, accept no input
	UNIT_CONTROLLED # Input passed to selected unit, limited options for selection
}
var state = GridState.NOTHING_SELECTED

var new_toast = preload("res://src/ui/Toast.tscn")
var theme = preload("res://src/ui/theme.tres")
var tpk_popup_scene = preload("res://src/battle/TPKPopup.tscn")
var victory_screen_scene = preload("res://src/battle/VictoryScreen.tscn")
var battle_menu_scene = preload("res://src/ui/BattleMenu.tscn")

func _ready() -> void:
	setup_camera()
	draw_nodes()
	draw_grid()

func _draw():
	for coordinate in highlights.coordinates():
		var colour = highlights.at(coordinate)
		if colour:
			draw_colored_polygon(geometry.cell_corners(coordinate), colour)

func set_state_nothing_selected() -> void:
	print("Grid state: Nothing Selected")
	state = GridState.NOTHING_SELECTED
	
	$Cursor.visible = true
	clickable_cells = []

func set_state_in_menu() -> void:
	print("Grid state: In Menu")
	state = GridState.IN_MENU
	
	$Cursor.visible = false
	clickable_cells = []

func set_state_unit_controlled(clickable_cells: Array[Vector2i]) -> void:
	print("Grid state: Unit Controlled")
	state = GridState.UNIT_CONTROLLED
	
	$Cursor.visible = true
	self.clickable_cells = clickable_cells

func set_position_to_mouse_cursor() -> void:
	var mouse_relative_position = get_global_mouse_position() - global_position
	var coordinate = geometry.cell_containing_position(mouse_relative_position)
	if not cursor == coordinate:
		cursor = coordinate.clamp(Vector2i.ZERO, Vector2i(grid_width, grid_height))
		if state == GridState.UNIT_CONTROLLED:
			emit_signal("cursor_move", self)
		$Cursor.position = geometry.cell_centre_position(cursor)

func move_cursor(dx: int, dy: int):
	cursor = cursor + Vector2i(dx, dy)
	if state == GridState.UNIT_CONTROLLED:
		emit_signal("cursor_move", self)
	$Cursor.position = geometry.cell_centre_position(cursor)

func _input(event):
	if state == GridState.NOTHING_SELECTED or state == GridState.UNIT_CONTROLLED:
		if event.is_action_pressed("ui_up") and cursor.y > 0:
			move_cursor(0, -1)
			$Cursor/ScrollStartTimer.start()
		if event.is_action_pressed("ui_down") and cursor.y < grid_height - 1:
			move_cursor(0, 1)
			$Cursor/ScrollStartTimer.start()
		if event.is_action_pressed("ui_left") and cursor.x > 0:
			move_cursor(-1, 0)
			$Cursor/ScrollStartTimer.start()
		if event.is_action_pressed("ui_right") and cursor.x < grid_width - 1:
			move_cursor(1, 0)
			$Cursor/ScrollStartTimer.start()
		
		if event.is_action_released("ui_up") \
		or event.is_action_released("ui_down")\
		or event.is_action_released("ui_left")\
		or event.is_action_released("ui_right"):
			$Cursor/ScrollStartTimer.stop()
			$Cursor/ScrollTickTimer.stop()
			scrolling = false
		
		if event is InputEventMouseMotion and mouse_in_grid:
			set_position_to_mouse_cursor()
			
		if event.is_action_pressed("ui_accept"):
			click_position(cursor)
			
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.is_pressed():
			set_position_to_mouse_cursor()
			click_position(cursor)
		
		if event.is_action_pressed("ui_cancel")\
		|| (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and !event.is_pressed()):
			emit_signal("click", "cancel")


func scroll_cursor():
	if Input.is_action_pressed("ui_up") and cursor.y > 0:
		move_cursor(0, -1)
	if Input.is_action_pressed("ui_down") and cursor.y < grid_height - 1:
		move_cursor(0, 1)
	if Input.is_action_pressed("ui_left") and cursor.x > 0:
		move_cursor(-1, 0)
	if Input.is_action_pressed("ui_right") and cursor.x < grid_width - 1:
		move_cursor(1, 0)

func setup_camera():
	var map_size = geometry.map_dimensions()
	var view_size = get_viewport().size
	var width = grid_size * grid_width
	var height = grid_size * grid_height
	var h_margin = max(0, (view_size.x / 3 - map_size.x) / 2)
	var v_margin = max(0, (view_size.y / 3 - map_size.y) / 2)
	var camera = $Cursor/Camera
	camera.limit_left = -h_margin
	camera.limit_right = width + h_margin
	camera.limit_top = -v_margin
	camera.limit_bottom = height + v_margin
	
	var h_drag_margin = 1 - (12 * grid_size / view_size.x)
	var v_drag_margin = 1 - (12 * grid_size / view_size.y)
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

func click_position(coordinate: Vector2i):
	if state == GridState.NOTHING_SELECTED:
		print("Clicked grid position %s" % [coordinate])
		for child in $GridNodes.get_children():
				var node = child as MapMarker
				if node and node.has_method("select"):
					if node.cells().has(coordinate):
						return node.select(self)
		# If no unit selected
		click_empty_cell()
	if state == GridState.UNIT_CONTROLLED:
		print("Clicked grid position %s" % [coordinate])
		if clickable_cells.has(coordinate):
			emit_signal("click", self)

func click_empty_cell():
	pass

func display_menu(popup_menu: BattleMenu) -> void:
	popup_menu.set_focused_item(0)
	set_state_in_menu()
	
	$PopupLayer.add_child(popup_menu)
	popup_menu.popup_centered()
	
	await popup_menu.id_pressed
	popup_menu.queue_free()

func draw_nodes():
	for node in $GridNodes.get_children():
		var map_marker = (node as MapMarker)
		node.position = geometry.cell_centre_position(map_marker.coordinate())

# Draw the grid for this coordinate system
func draw_grid():
	push_error("Implement draw_grid in inheriting scene")


func display_toast(text: String, delay: float = 1.0):
	var toasts_container = $PopupLayer/Toasts
	var toast = new_toast.instantiate()
	toast.add_text(text)
	toasts_container.add_child(toast)
	toasts_container.move_child(toast, 0)
	
	toasts_container.position = Vector2(0, -toast.size.y)
	var animation = get_tree().create_tween()
	animation.tween_property(toasts_container, "position", Vector2.ZERO, 0.25)
	
	get_tree().create_timer(delay).connect("timeout",Callable(toast,"delete").bind(Vector2.LEFT))
	
	return toast



# Signals
func _on_ScrollStartTimer_timeout():
	scrolling = true
	$Cursor/ScrollTickTimer.start()
	scroll_cursor()


func _on_ScrollTickTimer_timeout():
	scroll_cursor()


func _on_background_mouse_entered():
	mouse_in_grid = true


func _on_background_mouse_exited():
	mouse_in_grid = false
