extends "res://src/grid/GridNode.gd"
class_name Unit

export var movement = 6
export var movement_type = "foot"
export var team = 0

var movement_remaining: CoordinateMap = null

var new_menu = preload("res://src/menu/Menu.tscn")

func _ready():
	if team == 0:
		$AnimatedSprite.animation = "purple"
	if team == 1:
		$AnimatedSprite.animation = "yellow"

func select(grid):
	var options = movement_options(grid)
	grid.send_clicks_as_signal = true
	for option in options.to_array():
		grid.add_highlight(option, Color.aquamarine)
	
	grid.connect("click", self, "handle_grid_click")
	grid.connect("cursor_move", self, "handle_cursor_move")

func handle_grid_click(map: Map):
	var coordinate = map.cursor
	var options = movement_options(map)
	var node_array = map.node_array()
	
	var is_option = options.has(coordinate)
	var node = node_array.at(coordinate)
	var space_occupied = node != null
	
	if is_option and not space_occupied:
		var tween = animate_movement_along_path(map)
		var path = map.path
		map.path = CoordinateList.new([])
		map.update()
		map.set_active(false)
		
		yield(tween, "finished")
		
		var menu = new_menu.instance()
		menu.set_options(["Wait", "Cancel"])
		menu.position = Vector2(map.grid_size, 0)
		add_child(menu)
		var option = yield(menu, "option_selected")
		
		if option == "Wait":
			menu.queue_free()
			update_position(map, coordinate)
		if option == "Cancel":
			menu.queue_free()
			map.path = path
			map.update()
			position = map.position_from_coordinates(coordinate())
			yield(get_tree(), "idle_frame")
			map.set_active(true)
			

func animate_movement_along_path(map: Map) -> SceneTreeTween:
	var tween = get_tree().create_tween()
	for i in range(1, map.path.size()):
		var pos = map.position_from_coordinates(map.path.at(i))
		tween.tween_property(self, "position", pos, 0.1)
	return tween

func update_position(map: Map, coordinate: Coordinate):
	x = coordinate.x
	y = coordinate.y
	
	map.draw_nodes()
	map.clear_highlights()
	map.send_clicks_as_signal = false
	map.disconnect("click", self, "handle_grid_click")
	map.disconnect("cursor_move", self, "handle_cursor_move")
	map.path = CoordinateList.new()
	movement_remaining = null
	yield(get_tree(), "idle_frame")
	map.set_active(true)
	

func handle_cursor_move(map: Map):
	var options = movement_options(map)
	
	if !options.has(map.cursor):
		map.path = CoordinateList.new([])
		map.update()
		return
		
	if map.path.size() > 0:
		var already_on_path = map.path.find(map.cursor)
		if already_on_path >= 0:
			map.path = map.path.slice(0, already_on_path)
			map.update()
			return
		var path_end = map.path.last()
		var adjacent_cells = map.get_adjacent_cells(path_end)
		var c_node = map.node_array().at(map.cursor)
		var enemy_in_cell = (c_node != null) and (c_node.team != team)
		if adjacent_cells.has(map.cursor) and !enemy_in_cell:
			var manual_path = map.path.append(map.cursor)
			if movement_cost_of_path(map, manual_path) <= movement:
				map.path = manual_path
				map.update()
				return
	var auto_path = get_path_to_coords(map, map.cursor)
	if auto_path.size() > 0:
		map.path = auto_path
		map.update()

func calculate_movement(map: Map) -> CoordinateMap:
	# Lazy load
	if movement_remaining:
		return movement_remaining
	
	# Generate grid containing movement free at each tile, initialise with all -1
	var remaining_movement = CoordinateMap.new(map.grid_width, map.grid_height, [], -1)
	var node_array = map.node_array()
	
	remaining_movement.set_value(coordinate(), movement)
	var updates = CoordinateList.new([coordinate()])
	
	while updates.size() > 0:
		var new_updates = CoordinateList.new([])
		for u in updates.to_array():
			var u_remain = remaining_movement.at(u)
			var adjacent_cells = map.get_adjacent_cells(u)
			
			for a in adjacent_cells.to_array():
				var a_cost = movement_cost_of_cell(map, a)
				if a_cost >= 0:
					var a_remain = u_remain - a_cost					
					if a_remain > remaining_movement.at(a):
						remaining_movement.set_value(a, a_remain)
						new_updates = new_updates.append(a)
		updates = new_updates
	
	return remaining_movement

func movement_options(map: Map) -> CoordinateList:
	var remaining_movement = calculate_movement(map)
	var options = []
	for coordinate in remaining_movement.coordinates():
		if remaining_movement.at(coordinate)> -1:
			options.append(coordinate)
	return CoordinateList.new(options)

func movement_cost_of_cell(map: Map, coordinate: Coordinate) -> int:
	var terrain: int = map.terrain_grid.at(coordinate)
	var node: Unit = map.node_array().at(coordinate)
	if (node != null) and (node.team != team):
		return -1
	if map.terrain_types[terrain]["movement"].has(movement_type):
		return map.terrain_types[terrain]["movement"][movement_type]
	return -1

func get_path_to_coords(map: Map, coordinate: Coordinate) -> CoordinateList:
	var remaining_movement = calculate_movement(map)
	if remaining_movement.at(coordinate) < 0:
		return CoordinateList.new()
	
	var out = CoordinateList.new([coordinate])
	var u = coordinate
	var u_remain = remaining_movement.at(coordinate)
	while !u.equals(coordinate()):
		var adjacent_cells = map.get_adjacent_cells(u)
		var u_cost = movement_cost_of_cell(map, u)
		for a in adjacent_cells.to_array():
			var a_node = map.node_array().at(a)
			if (a_node == null) or (a_node.team == team):
				var a_remain = remaining_movement.at(a)
				if a_remain == u_remain + u_cost:
					out = out.append(a)
					u = a
					u_remain = a_remain
					break
	out = out.reverse()
	return out

func movement_cost_of_path(map: Map, p: CoordinateList):
	var cost = 0
	for i in range(1, p.size()):
		cost += movement_cost_of_cell(map, p.at(i))
	return cost