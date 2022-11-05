extends Map

func _ready():
	grid_size = 28
	geometry = HexGeometry.new(grid_size, grid_width, grid_height)
	super()

func draw_grid():
	print("Draw grid")
	# Set background dimensions
	var map_size = geometry.map_dimensions()
	$Background.size = map_size
	
	for i in grid_width:
		for j in grid_height:
			var cell = Vector2i(i, j)
			var corners = geometry.cell_corners(cell)
			# Close the loop
			corners.append(corners.front())
			var colour = Color.RED
			var line = Line2D.new()
			line.width = 1
			line.default_color = Color.DARK_SLATE_GRAY
			line.default_color.a = 0.1
			corners.map(func(corner): line.add_point(corner))
			add_child(line)
			
