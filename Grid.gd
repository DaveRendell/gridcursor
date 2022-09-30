extends Node2D

export var grid_size: int = 32
export var grid_width: int = 20
export var grid_height: int = 20

var width = grid_width * grid_size
var height = grid_height * grid_size

# Cursor properties
var cursor_x: int = 0
var cursor_y: int = 0
var mouse_in_grid = false
var scrolling: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	draw_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Cursor.position = position_from_coordinates(cursor_x, cursor_y)
	
# Returns the relative position of an object at the given grid coordinates
# Should be overwritten to match the coordinate system of this grid
func position_from_coordinates(x: int, y: int) -> Vector2:
	return Vector2(x * grid_size, y * grid_size)

# Takes a relative position and returns the 2D grid coordinates in an array
# Should be overwritten to match the coordinate system of this grid
func coordinates_from_position(p: Vector2) -> Array:
	return [p.x / grid_size, p.y / grid_size]

# Draw the grid for this coordinate system
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

func set_position_to_mouse_cursor():
	var mouse_relative_position = get_global_mouse_position() - global_position
	var coords = coordinates_from_position(mouse_relative_position)
	cursor_x = coords[0]
	cursor_y = coords[1]

func _input(event):
	if event.is_action_pressed("ui_up") and cursor_y > 0:
		cursor_y -= 1
		$Cursor/ScrollStartTimer.start()
	if event.is_action_pressed("ui_down") and cursor_y < grid_height - 1:
		cursor_y += 1
		$Cursor/ScrollStartTimer.start()
	if event.is_action_pressed("ui_left") and cursor_x > 0:
		cursor_x -= 1
		$Cursor/ScrollStartTimer.start()
	if event.is_action_pressed("ui_right") and cursor_x < grid_width - 1:
		cursor_x += 1
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
		cursor_y -= 1
	if Input.is_action_pressed("ui_down") and cursor_y < grid_height - 1:
		cursor_y += 1
	if Input.is_action_pressed("ui_left") and cursor_x > 0:
		cursor_x -= 1
	if Input.is_action_pressed("ui_right") and cursor_x < grid_width - 1:
		cursor_x += 1

func click_position(x, y):
	print("Clicked grid position %d %d" % [x, y])


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
