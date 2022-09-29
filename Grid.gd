extends Node2D

export var grid_size: int = 32
export var grid_width: int = 8
export var grid_height: int = 7

var width = grid_width * grid_size
var height = grid_height * grid_size

# Cursor properties
var cursor_x: int = 0
var cursor_y: int = 0
var using_mouse = false


# Called when the node enters the scene tree for the first time.
func _ready():
	draw_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Cursor.position.x = cursor_x * grid_size
	$Cursor.position.y = cursor_y * grid_size
	if using_mouse:
		set_position_to_mouse_cursor()


func set_position_to_mouse_cursor():
	var mouse_relative_position = get_global_mouse_position() - global_position
	cursor_x = mouse_relative_position.x / grid_size
	cursor_y = mouse_relative_position.y / grid_size


func _input(event):
	if event.is_action_pressed("ui_up") and cursor_y > 0:
		cursor_y -= 1
		using_mouse = false
	if event.is_action_pressed("ui_down") and cursor_y < grid_height - 1:
		cursor_y += 1
		using_mouse = false
	if event.is_action_pressed("ui_left") and cursor_x > 0:
		cursor_x -= 1
		using_mouse = false
	if event.is_action_pressed("ui_right") and cursor_x < grid_width - 1:
		cursor_x += 1
		using_mouse = false
	
	if (event.is_action_pressed("ui_accept"))\
	|| (event is InputEventMouseButton and event.is_pressed()):
		click_position(cursor_x, cursor_y)


func click_position(x, y):
	print("Clicked grid position %d %d" % [x, y])


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


# Signals
func _on_Background_mouse_entered():
	using_mouse = true


func _on_Background_mouse_exited():
	using_mouse = false
