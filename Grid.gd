extends Node2D

class_name Grid

export var grid_size: int = 32
export var grid_width: int = 20
export var grid_height: int = 20

# Cursor properties
export var active = true
var cursor_x: int = 0
var cursor_y: int = 0
var mouse_in_grid = false
var scrolling: bool = false

var send_clicks_as_signal = false
signal click
signal cursor_move


func empty_grid(value = null):
	var grid = []
	grid.resize(grid_width)
	for i in grid_width:
		var col = []
		col.resize(grid_height)
		for j in grid_height:
			col[j] = value
		grid[i] = col
	return grid

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Cursor.position = position_from_coordinates(cursor_x, cursor_y)
	
# Returns the relative position of an object at the given grid coordinates
# Should be overwritten to match the coordinate system of this grid
func position_from_coordinates(x: int, y: int) -> Vector2:
	push_error("Implement position_from_coordinates in inheriting scene")
	return Vector2.ZERO

func cell_centre_position(x: int, y: int) -> Vector2:
	push_error("Implement cell_centre_position in inheriting scene")
	return Vector2.ZERO

# Takes a relative position and returns the 2D grid coordinates in an array
# Should be overwritten to match the coordinate system of this grid
func coordinates_from_position(p: Vector2) -> Array:
	push_error("Implement coordinates_from_position in inheriting scene")
	return []

func set_position_to_mouse_cursor():
	var mouse_relative_position = get_global_mouse_position() - global_position
	var coords = coordinates_from_position(mouse_relative_position)
	if (cursor_x != coords[0]) or (cursor_y != coords[1]):
		cursor_x = max(0, min(coords[0], grid_width - 1))
		cursor_y = max(0, min(coords[1], grid_height - 1))
		if send_clicks_as_signal:
			emit_signal("cursor_move", self)

func move_cursor(d_x: int, d_y: int):
	cursor_x += d_x
	cursor_y += d_y
	if send_clicks_as_signal:
		emit_signal("cursor_move", self)

func _input(event):
	if active:
		if event.is_action_pressed("ui_up") and cursor_y > 0:
			move_cursor(0, -1)
			$Cursor/ScrollStartTimer.start()
		if event.is_action_pressed("ui_down") and cursor_y < grid_height - 1:
			move_cursor(0, 1)
			$Cursor/ScrollStartTimer.start()
		if event.is_action_pressed("ui_left") and cursor_x > 0:
			move_cursor(-1, 0)
			$Cursor/ScrollStartTimer.start()
		if event.is_action_pressed("ui_right") and cursor_x < grid_width - 1:
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
		
		if (event.is_action_pressed("ui_accept"))\
		|| (event is InputEventMouseButton and event.is_pressed()):
			click_position(cursor_x, cursor_y)


func scroll_cursor():
	if Input.is_action_pressed("ui_up") and cursor_y > 0:
		move_cursor(0, -1)
	if Input.is_action_pressed("ui_down") and cursor_y < grid_height - 1:
		move_cursor(0, 1)
	if Input.is_action_pressed("ui_left") and cursor_x > 0:
		move_cursor(-1, 0)
	if Input.is_action_pressed("ui_right") and cursor_x < grid_width - 1:
		move_cursor(1, 0)

func click_position(x, y):
	print("Clicked grid position %d %d" % [x, y])
	if send_clicks_as_signal:
		emit_signal("click", self)
	else:
		for node in $GridNodes.get_children():
			if node.has_method("select"):
				if node.x == x and node.y == y:
					node.select(self)

	
# Signals
func _on_Background_mouse_entered():
	mouse_in_grid = true


func _on_Background_mouse_exited():
	mouse_in_grid = false


func _on_ScrollStartTimer_timeout():
	scrolling = true
	$Cursor/ScrollTickTimer.start()
	scroll_cursor()


func _on_ScrollTickTimer_timeout():
	scroll_cursor()
