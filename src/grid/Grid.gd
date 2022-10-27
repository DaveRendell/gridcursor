extends Node2D

class_name Grid
# Scene representing a scene containing a grid of user interactable objects, e.g.
# a menu, a battle map, a hex grid...
# This scene is abstract, and must have various methods implemented by 
# inheriting scenes

export var grid_size: int = 16
export var grid_width: int = 20
export var grid_height: int = 20

# Cursor properties
var cursor: Coordinate = Coordinate.new(0, 0)
var mouse_in_grid = false
var scrolling: bool = false

var clickable_cells: CoordinateList = null

signal click
signal cursor_move

enum GridState {
	NOTHING_SELECTED, # Cursor active, select units on click
	IN_MENU, # Hide cursor, accept no input
	UNIT_CONTROLLED # Input passed to selected unit, limited options for selection
}
var state = GridState.NOTHING_SELECTED

func set_state_nothing_selected() -> void:
	print("Grid state: Nothing Selected")
	state = GridState.NOTHING_SELECTED
	
	$Cursor.visible = true
	clickable_cells = null

func set_state_in_menu() -> void:
	print("Grid state: In Menu")
	state = GridState.IN_MENU
	
	$Cursor.visible = false
	clickable_cells = null

func set_state_unit_controlled(clickable_cells: CoordinateList) -> void:
	print("Grid state: Unit Controlled")
	state = GridState.UNIT_CONTROLLED
	
	$Cursor.visible = true
	self.clickable_cells = clickable_cells

# Returns the relative position of an object at the given grid coordinates
# Should be overwritten to match the coordinate system of this grid
func position_from_coordinates(coordinate: Coordinate) -> Vector2:
	push_error("Implement position_from_coordinates in inheriting scene")
	return Vector2.ZERO

func cell_centre_position(coordinate: Coordinate) -> Vector2:
	push_error("Implement cell_centre_position in inheriting scene")
	return Vector2.ZERO

# Takes a relative position and returns the 2D grid coordinates in an array
# Should be overwritten to match the coordinate system of this grid
func coordinates_from_position(p: Vector2) -> Coordinate:
	push_error("Implement coordinates_from_position in inheriting scene")
	return Coordinate.new(0, 0)

func set_position_to_mouse_cursor() -> void:
	var mouse_relative_position = get_global_mouse_position() - global_position
	var coordinate = coordinates_from_position(mouse_relative_position)
	if not cursor.equals(coordinate):
		cursor = coordinate.trim(grid_width, grid_height)
		if state == GridState.UNIT_CONTROLLED:
			emit_signal("cursor_move", self)
		$Cursor.position = position_from_coordinates(cursor)

func move_cursor(dx: int, dy: int):
	cursor = cursor.add_x(dx).add_y(dy)
	if state == GridState.UNIT_CONTROLLED:
		emit_signal("cursor_move", self)
	$Cursor.position = position_from_coordinates(cursor)

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
			
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
			set_position_to_mouse_cursor()
			click_position(cursor)
		
		if event.is_action_pressed("ui_cancel")\
		|| (event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.is_pressed()):
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

func click_position(coordinate: Coordinate):
	push_error("Implement click_position in inheriting scene")

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
