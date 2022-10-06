extends "res://GridNode.gd"


func select(grid):
	grid.send_clicks_as_signal = true
	grid.add_highlight(x + 1, y, Color.aquamarine)
	grid.connect("click", self, "handle_grid_click")
	
func handle_grid_click(grid):
	print("well here we are at %d %d (%d, %d)" % [grid.cursor_x, grid.cursor_y, x, y])
	print((grid.cursor_x == x + 1) and (grid.cursor_y == y))
	if (grid.cursor_x == x + 1) and (grid.cursor_y == y):
		x = x + 1
		grid.draw_nodes()
		grid.clear_highlights()
		grid.send_clicks_as_signal = false
		grid.disconnect("click", self, "handle_grid_click")
