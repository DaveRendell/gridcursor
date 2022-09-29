extends Node2D

export var grid_size: int = 32
export var grid_width: int = 8
export var grid_height: int = 7

var width = grid_width * grid_size
var height = grid_height * grid_size


# Called when the node enters the scene tree for the first time.
func _ready():
	$Cursor.grid_size = grid_size
	$Cursor.grid_width = grid_width
	$Cursor.grid_height = grid_height
	$Cursor.grid_global_position = global_position
	draw_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if (event.is_action_pressed("ui_accept"))\
	|| (event is InputEventMouseButton and event.is_pressed()):
		click_position($Cursor.x, $Cursor.y)


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
