extends Node2D

# Set by parent object
var grid_size: int
var grid_width: int
var grid_height: int
var grid_global_position: Vector2

var x: int = 0
var y: int = 0

var using_mouse = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x = x * grid_size
	position.y = y * grid_size
	if using_mouse:
		set_position_to_mouse_cursor()

func _input(event):
	if event.is_action_pressed("ui_up") and y > 0:
		y -= 1
		using_mouse = false
	if event.is_action_pressed("ui_down") and y < grid_height - 1:
		y += 1
		using_mouse = false
	if event.is_action_pressed("ui_left") and x > 0:
		x -= 1
		using_mouse = false
	if event.is_action_pressed("ui_right") and x < grid_width - 1:
		x += 1
		using_mouse = false


func set_position_to_mouse_cursor():
	var mouse_relative_position = get_global_mouse_position() - grid_global_position
	x = mouse_relative_position.x / grid_size
	y = mouse_relative_position.y / grid_size


func _on_Background_mouse_entered():
	using_mouse = true


func _on_Background_mouse_exited():
	using_mouse = false
