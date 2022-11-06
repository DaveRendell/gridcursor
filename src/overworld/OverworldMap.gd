extends Map

var parties: CoordinateMap

func _ready():
	grid_size = 32
	grid_height = 7
	grid_width = 7
	geometry = HexGeometry.new(grid_size, grid_width, grid_height)
	super()
	
	parties = CoordinateMap.new(grid_width, grid_height)

func draw_grid():
	# Set background dimensions
	var map_size = geometry.map_dimensions()
	$Background.size = map_size
	
	for i in grid_width:
		for j in grid_height:
			var cell = Vector2i(i, j)
			var corners = geometry.cell_corners(cell)
			# Close the loop
			corners.append(corners.front())
			var line = Line2D.new()
			line.width = 1
			line.default_color = Color.DARK_SLATE_GRAY
			line.default_color.a = 0.1
			corners.map(func(corner): line.add_point(corner))
			add_child(line)
			
func add_party(party: Party, coordinate: Vector2i) -> void:
	var party_marker_scene = preload("res://src/overworld/party_marker.tscn")
	var party_marker = party_marker_scene.instantiate()
	party_marker.from_party(party)
	party_marker.x = coordinate.x
	party_marker.y = coordinate.y
	$GridNodes.add_child(party_marker)
	
