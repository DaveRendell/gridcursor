class_name OverworldMap extends Map

var encounter_scene = preload("res://src/overworld/EncounterDisplay.tscn")
var party_marker_scene = preload("res://src/overworld/party_marker.tscn")

var parties: CoordinateMap
var terrain: CoordinateMap

func _ready():
	grid_size = 32
	grid_height = 7
	grid_width = 7
	geometry = HexGeometry.new(grid_size, grid_width, grid_height)
	super()
	
	parties = CoordinateMap.new(grid_width, grid_height)
	setup_terrain()

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
	var party_marker_scene = load("res://src/overworld/party_marker.tscn")
	var party_marker = party_marker_scene.instantiate()
	party_marker.from_party(party)
	party_marker.x = coordinate.x
	party_marker.y = coordinate.y
	$GridNodes.add_child(party_marker)
	update_parties()

func setup_terrain():
	terrain = CoordinateMap.new(grid_width, grid_height)
	for i in grid_width:
		for j in grid_height:
			var terrain_id = $TileMap.get_cell_atlas_coords(0, Vector2i(i, j)).x
			terrain.set_value(Vector2i(i, j), OverworldTerrain.get_terrain(terrain_id))


func check_for_encounters(party: Party, cell: Vector2i) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rolls = []
	var number_of_encounter_dice = 3
	for i in number_of_encounter_dice:
		rolls.append(rng.randi_range(1, 6))
	print("Random encounter rolls: %s" % str(rolls))
	
	if rolls.any(func(result): return result == 6):
		print("Random encounter happens")
		var forest_blob_attack = preload("res://src/models/encounters/encounter_instances/forest_blob_attack.gd")
		await run_encounter(party, forest_blob_attack.encounter())
	else:
		print("No encounter happens")

func nighttime_encounter(party: Party, cell: Vector2i) -> void:
	print("Random encounter happens")
	var night_encounter = preload("res://src/models/encounters/encounter_instances/night_encounter.gd")
	await run_encounter(party, night_encounter.encounter())

func run_encounter(party: Party, encounter: Encounter) -> void:
	var encounter_display = encounter_scene.instantiate()
	encounter.party = party
	encounter_display.set_encounter(encounter)
	
	$PopupLayer.add_child(encounter_display)

	set_state_in_menu()
	await encounter.end_encounter
	set_state_nothing_selected()

func update_parties():
	parties = CoordinateMap.new(grid_width, grid_height, $GridNodes.get_children(), null)
