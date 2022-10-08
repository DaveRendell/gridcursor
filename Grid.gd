extends Node2D

class_name Grid

export var grid_size: int = 32
export var grid_width: int = 20
export var grid_height: int = 20

var terrain_grid: Array
var highlights: Array = []

var terrain_types = []

# Cursor properties
export var active = true
var cursor_x: int = 0
var cursor_y: int = 0
var mouse_in_grid = false
var scrolling: bool = false

var send_clicks_as_signal = false
signal click

var transparent: bool = false

func make_transparent():
	transparent = true
	$Background.visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	file.open("res://terrain.json", File.READ)
	terrain_types = parse_json(file.get_as_text())

	terrain_grid = empty_grid(0)
	terrain_grid[5][5] = 2
	terrain_grid[5][6] = 2
	terrain_grid[6][6] = 2
	
	draw_grid()
	draw_nodes()

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

# Takes a relative position and returns the 2D grid coordinates in an array
# Should be overwritten to match the coordinate system of this grid
func coordinates_from_position(p: Vector2) -> Array:
	push_error("Implement coordinates_from_position in inheriting scene")
	return []

# Draw the grid for this coordinate system
func draw_grid():
	push_error("Implement draw_grid in inheriting scene")

func _draw():
	for i in grid_width:
		for j in grid_height:
			var terrain = terrain_grid[i][j]
			var colour: Color = Color.black
			if terrain == 0:
				colour = Color.lightgreen
			if terrain == 2:
				colour = Color.darkgreen
			draw_colored_polygon(cell_corners(i, j), colour, PoolVector2Array(), null, null, true)
	for highlight in highlights:
		var x = highlight[0]
		var y = highlight[1]
		var colour = highlight[2]
		colour.a = 0.3
		draw_colored_polygon(cell_corners(x, y), colour, PoolVector2Array(), null, null, true)

func set_position_to_mouse_cursor():
	var mouse_relative_position = get_global_mouse_position() - global_position
	var coords = coordinates_from_position(mouse_relative_position)
	cursor_x = coords[0]
	cursor_y = coords[1]

func add_highlight(x: int, y: int, colour: Color):
	highlights.append([x, y, colour])
	update()

func get_adjacent_cells(x: int, y: int):
	push_error("Implement get_adjacent_cells in inheriting scene")

func cell_corners(x: int, y: int):
	push_error("Implement cell_corners in inheriting scene")

func node_array():
	var output = []
	output.resize(grid_width)
	for i in grid_height:
		var col = []
		col.resize(grid_height)
		output[i] = col
	for node in $GridNodes.get_children():
		output[node.x][node.y] = node
	return output
	
func _input(event):
	if active:
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
	if send_clicks_as_signal:
		print("Sending grid click as signal")
		emit_signal("click", self)
	else:
		print("Looking for selectable grid node")
		for node in $GridNodes.get_children():
			if node.has_method("select"):
				if node.x == x and node.y == y:
					node.select(self)

func clear_highlights():
	highlights = []
	update()

# QQ
func add_grid_node(node):
	$GridNodes.add_child(node)

func get_nodes():
	$GridNodes.get_children()

func draw_nodes():
	print($GridNodes.get_child_count())
	for node in $GridNodes.get_children():
		var grid_node = (node as GridNode)
		node.position = position_from_coordinates(grid_node.x, grid_node.y)
	
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
