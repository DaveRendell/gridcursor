extends "res://GridNode.gd"

export var movement = 6
export var movement_type = "foot"
export var team = 0

func _ready():
	if team == 0:
		$AnimatedSprite.animation = "purple"
	if team == 1:
		$AnimatedSprite.animation = "yellow"

func select(grid):
	var options = movement_options(grid)
	grid.send_clicks_as_signal = true
	for option in options:
		grid.add_highlight(option[0], option[1], Color.aquamarine)
	
	grid.connect("click", self, "handle_grid_click")
	grid.connect("cursor_move", self, "handle_cursor_move")

func handle_grid_click(grid):
	var options = movement_options(grid)
	var node_array = grid.node_array()
	
	var is_option = options.has([grid.cursor_x, grid.cursor_y])
	var node = node_array[grid.cursor_x][grid.cursor_y]
	var space_occupied = node != null
	
	if is_option and not space_occupied:
		var tween = get_tree().create_tween()
		for i in range(1, grid.path.size()):
			var pos = grid.position_from_coordinates(grid.path[i][0], grid.path[i][1])
			tween.tween_property(self, "position", pos, 0.1)
		tween.connect("finished", self, "update_position", [grid, grid.cursor_x, grid.cursor_y])
		grid.path = []
		grid.update()
		grid.disconnect("click", self, "handle_grid_click")
		grid.disconnect("cursor_move", self, "handle_cursor_move")

func update_position(grid, c_x, c_y):
	x = c_x
	y = c_y
	
	grid.draw_nodes()
	grid.clear_highlights()
	grid.send_clicks_as_signal = false
	grid.path = []
	

func handle_cursor_move(grid):
	var c_x = grid.cursor_x
	var c_y = grid.cursor_y
	var options = movement_options(grid)
	
	if !options.has([c_x, c_y]):
		grid.path = []
		grid.update()
		return
		
	if grid.path.size() > 0:
		var already_on_path = grid.path.find([c_x, c_y])
		if already_on_path >= 0:
			grid.path = grid.path.slice(0, already_on_path)
			grid.update()
			return
		var path_end = grid.path[-1]
		var adjacent_cells = grid.get_adjacent_cells(path_end[0], path_end[1])
		var c_node = grid.node_array()[c_x][c_y]
		var enemy_in_cell = (c_node != null) and (c_node.team != team)
		if adjacent_cells.has([c_x, c_y]) and !enemy_in_cell:
			var manual_path = grid.path.duplicate()
			manual_path.append([c_x, c_y])
			if movement_cost_of_path(grid, manual_path) <= movement:
				grid.path = manual_path
				grid.update()
				return
	var auto_path = get_path_to_coords(grid, grid.cursor_x, grid.cursor_y)
	if auto_path.size() > 0:
		grid.path = auto_path
		grid.update()

func calculate_movement(grid):
	# Generate grid containing movement free at each tile, initialise with all -1
	var remaining_movement = []
	remaining_movement.resize(grid.grid_width)
	for i in grid.grid_width:
		var col = []
		col.resize(grid.grid_height)
		for j in grid.grid_height:
			col[j] = -1
		remaining_movement[i] = col
	var node_array = grid.node_array()
	
	remaining_movement[x][y] = movement
	var updates = [[x, y]]
	
	while updates.size() > 0:
		var new_updates = []
		for u in updates:
			var u_x = u[0]
			var u_y = u[1]
			var u_remain = remaining_movement[u_x][u_y]
			
			var adjacent_cells = grid.get_adjacent_cells(u_x, u_y)
			for a in adjacent_cells:
				var a_x = a[0]
				var a_y = a[1]
				var a_cost = movement_cost_of_cell(grid, a_x, a_y)
				if a_cost >= 0:
					var a_remain = u_remain - a_cost					
					if a_remain > remaining_movement[a_x][a_y]:
						remaining_movement[a_x][a_y] = a_remain
						new_updates.append(a)
		updates = new_updates
	
	return remaining_movement

func movement_options(grid):
	var remaining_movement = calculate_movement(grid)
	var options = []
	for i in grid.grid_width: 
		for j in grid.grid_height:
			if remaining_movement[i][j] > -1:
				options.append([i, j])
	return options

func movement_cost_of_cell(grid, i, j):
	var terrain = grid.terrain_grid[i][j]
	var node = grid.node_array()[i][j]
	if (node != null) and (node.team != team):
		return -1
	if grid.terrain_types[terrain]["movement"].has(movement_type):
		return grid.terrain_types[terrain]["movement"][movement_type]
	return -1

func get_path_to_coords(grid, i, j):
	var remaining_movement = calculate_movement(grid)
	if remaining_movement[i][j] < 0:
		return []
	
	var out = [[i, j]]
	var u_x = i
	var u_y = j
	var u_remain = remaining_movement[i][j]
	while (u_x != x) or (u_y != y):
		var adjacent_cells = grid.get_adjacent_cells(u_x, u_y)
		var u_cost = movement_cost_of_cell(grid, u_x, u_y)
		for a in adjacent_cells:
			var a_x = a[0]
			var a_y = a[1]
			var a_node = grid.node_array()[a_x][a_y]
			if (a_node == null) or (a_node.team == team):
				var a_remain = remaining_movement[a_x][a_y]
				if a_remain == u_remain + u_cost:
					out.append([a_x, a_y])
					u_x = a_x
					u_y = a_y
					u_remain = a_remain
					break
	out.invert()
	return out

func movement_cost_of_path(grid, p: Array):
	var cost = 0
	for i in range(1, p.size()):
		cost += movement_cost_of_cell(grid, p[i][0], p[i][1])
	return cost
	
