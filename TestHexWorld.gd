extends "res://HexGrid.gd"


func click_position(x, y):
	print("hexworld click")
	$Menu.visible = true
	$Menu.active = true
	active = false
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Menu_option_selected(option):
	$Menu.visible = false
	$Menu.active = false
	print(option)
	yield(get_tree(), "idle_frame")
	active = true
