extends "res://GridNode.gd"

export var movement = 6


func select(grid):
	var options = movement_options(grid)
	grid.send_clicks_as_signal = true
	for option in options:
		grid.add_highlight(option[0], option[1], Color.aquamarine)
	
	grid.connect("click", self, "handle_grid_click")

func handle_grid_click(grid):
	var options = movement_options(grid)
	
	if options.has([grid.cursor_x, grid.cursor_y]):
		x = grid.cursor_x
		y = grid.cursor_y
		
		grid.draw_nodes()
		grid.clear_highlights()
		grid.send_clicks_as_signal = false
		grid.disconnect("click", self, "handle_grid_click")

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
				# TODO update with terrain based movement cost
				var a_remain = u_remain - 1
				
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
