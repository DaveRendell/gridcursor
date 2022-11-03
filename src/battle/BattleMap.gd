class_name BattleMap extends "res://src/map/Map.gd"

var new_unit = preload("res://src/battle/Unit.tscn")

signal next_turn

var terrain_grid: CoordinateMap = CoordinateMap.new(grid_width, grid_height, [], 0)
var units: CoordinateMap = CoordinateMap.new(grid_width, grid_height)
var path: Array[Vector2i] = []

var terrain_types = []

var teams = 2
var current_turn = 0

func _ready():
	geometry = SquareGeometry.new(grid_size, grid_width, grid_height)
	super()
	
	set_terrain_types()
	place_mobs()
	draw_nodes()

func _draw():
	super()
	if path.size() > 1:
		var color = Color.CORAL
		for i in range(1, path.size()):
			var from = geometry.cell_centre_position(path[i - 1])
			var to = geometry.cell_centre_position(path[i])

			draw_line(from,to,color,grid_size * 0.5)
			draw_circle(from, grid_size * 0.25, color)
		var last_point = geometry.cell_centre_position(path.back())
		var second_last_point = geometry.cell_centre_position(path[-2])
		var rotation = (last_point - second_last_point).angle()
		var arrow_head_points = [
			last_point + grid_size * Vector2(-0.25, -0.5).rotated(rotation),
			last_point + grid_size * Vector2(0.25, 0).rotated(rotation),
			last_point + grid_size * Vector2(-0.25, 0.5).rotated(rotation),
		]
		draw_colored_polygon(arrow_head_points, color)

func set_terrain_types() -> void:
	var file = FileAccess.open("res://data/terrain.json", FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	terrain_types = test_json_conv.get_data()
	var location = $LocationData.get_child(0) as Location
	
	for coordinate in terrain_grid.coordinates():
		var terrain_id = location.get_terrain_id_at(coordinate)
		terrain_grid.set_value(coordinate, terrain_id)

func click_empty_cell():
	var popup_menu = battle_menu_scene.instantiate()
		
	var options = ["End turn", "Cancel"]
	for i in options.size():
		var option = options[i]
		popup_menu.add_item(option, i)
	
	display_menu(popup_menu)
	popup_menu.popup_hide.connect(set_state_nothing_selected)
	
	var id = await popup_menu.id_pressed
	var option = options[id]
	
	if option == "End turn":
		next_turn.emit()
	if option == "Cancel":
		set_state_nothing_selected()

func add_character(character: Character, coordinate: Vector2i, team: E.Team) -> void:
	var unit = new_unit.instantiate()
	unit.from_char(character, team, coordinate)
	$GridNodes.add_child(unit)
	update_units()

func place_mobs() -> void:
	for child in $MobMarkers.get_children():
		var mob_marker = child as MobMarker
		if mob_marker:
			var coordinate = Vector2i(mob_marker.position / grid_size)
			var mob = mob_marker.character_script.new()
			add_character(mob, coordinate, E.Team.MONSTERS)
			mob_marker.queue_free()

func add_party(party: Party) -> void:
	var coordinate = Vector2i($PartySpawn.position / grid_size)
	$PartySpawn.visible = false
	for position in party.formation.non_empty_coordinates():
		var character = party.formation.at(position) as Character
		add_character(character, coordinate + position, E.Team.PLAYERS)

func draw_grid():
	# Set background dimensions
	var map_size = geometry.map_dimensions()
	$Background.size = map_size
	
	# Draw vertical lines
	for i in (grid_width - 1):
		var offset = grid_size * (i + 1)
		var line = Line2D.new()
		line.width = 1
		line.default_color = Color.DARK_SLATE_GRAY
		line.default_color.a = 0.2
		line.add_point(Vector2(offset, 0))
		line.add_point(Vector2(offset, map_size.y))
		add_child(line)
	# Draw horizontal lines
	for i in (grid_height - 1):
		var offset = grid_size * (i + 1)
		var line = Line2D.new()
		line.width = 1
		line.default_color = Color.DARK_SLATE_GRAY
		line.default_color.a = 0.2
		line.add_point(Vector2(0, offset))
		line.add_point(Vector2(map_size.x, offset))
		add_child(line)

func update_units() -> void:
	units = CoordinateMap.new(grid_width, grid_height, $GridNodes.get_children(), null)

func check_win_condition():
	var player_unit_count = 0
	var enemy_unit_count = 0
	for unit in $GridNodes.get_children():
		if !unit.character.is_down():
			if unit.team == 0:
				player_unit_count += 1
			else:
				enemy_unit_count += 1
	if player_unit_count == 0:
		set_state_in_menu()
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.BLACK, 1.0)
		await tween.finished

		var tpk_popup = tpk_popup_scene.instantiate()
		$PopupLayer.add_child(tpk_popup)
		tpk_popup.popup_centered()
		
		print("TPK")
	elif enemy_unit_count == 0:
		set_state_in_menu()
		var victory_popup = victory_screen_scene.instantiate()
		$PopupLayer.add_child(victory_popup)
		victory_popup.popup_centered()
		
		print("A winner is you")
