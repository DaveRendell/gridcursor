extends "res://src/map/Map.gd"

var width = grid_width * grid_size
var height = grid_height * grid_size

var new_unit = preload("res://src/map/Unit.tscn")

func _ready():
	super()
	var view_size = get_viewport().size
	var width = grid_size * grid_width
	var height = grid_size * grid_height
	var h_margin = max(0, (view_size.x / zoom_level - width) / 2)
	var v_margin = max(0, (view_size.y / zoom_level - height) / 2)
	var camera = $Cursor/Camera
	camera.zoom = Vector2(zoom_level, zoom_level)
	camera.limit_left = -h_margin
	camera.limit_right = width + h_margin
	camera.limit_top = -v_margin
	camera.limit_bottom = height + v_margin
	
	var h_drag_margin = 1 - (4 * zoom_level * grid_size / view_size.x)
	var v_drag_margin = 1 - (4 * zoom_level * grid_size / view_size.y)
	camera.drag_left_margin = h_drag_margin
	camera.drag_right_margin = h_drag_margin
	camera.drag_top_margin = v_drag_margin
	camera.drag_bottom_margin = v_drag_margin
	camera.position = Vector2(grid_size / 2, grid_size / 2)
	
	for coordinate in terrain_grid.coordinates():
		var cell = $Tiles/TerrainTypes.get_cell_source_id(0, Vector2i(coordinate.x, coordinate.y))
		terrain_grid.set_value(coordinate, cell)
	
	var blue_soldier_sprite_sheet = preload("res://img/characters/Soldier-Blue.png")
	var blue_soldier_sprite = PunyCharacterSprite.character_sprite(blue_soldier_sprite_sheet)
	var red_mage_sprite_sheet = preload("res://img/characters/Mage-Red.png")
	var red_mage_sprite = PunyCharacterSprite.character_sprite(red_mage_sprite_sheet)
	var green_archer_sprite_sheet = preload("res://img/characters/Archer-Green.png")
	var green_archer_sprite= PunyCharacterSprite.character_sprite(green_archer_sprite_sheet)
	var slime_sprite_sheet = preload("res://img/characters/Slime.png")
	var slime_sprite_1 = PunyCharacterSprite.slime_sprite(slime_sprite_sheet)
	var slime_sprite_2 = PunyCharacterSprite.slime_sprite(slime_sprite_sheet)
	
	var sword = Weapon.new("Sword", 5, [0], 3, 1, 1, false, "sword")
	var short_bow = Weapon.new("Short bow", 5, [1], 2, 2, 8, true, "bow")
	var great_sword = Weapon.new("Greatsword", 10, [1], 5, 1, 1, true, "sword")
	var staff = Staff.new(
		"Fire Rod",
		3,
		[Attack.new("Firebolt", 1, 4, [3], 3, "staff")],
		[Teleport.new(), Fireball.new()]
		)

	var leather_armour = Armour.new("Leather armour", 5, 8)

	var shield = Shield.new("Buckler", 4, 1)

	var reginald = Character.new("Reginald", blue_soldier_sprite, 3, 2, 1, 1)
	reginald.equip("main_hand", sword)
	reginald.equip("off_hand", shield)
	reginald.equip("clothing", leather_armour)
	
	var yanil = Character.new("Yanil", red_mage_sprite, 0, 2, 3, 2)
	yanil.equip("main_hand", staff)
	
	var tobias = Character.new("Tobias", green_archer_sprite, 1, 3, 2, 1)
	tobias.equip("main_hand", short_bow)
	
	var reginald_unit = new_unit.instantiate()
	var yanil_unit = new_unit.instantiate()
	var tobias_unit = new_unit.instantiate()
	reginald_unit.from_char(reginald, 0, Coordinate.new(13, 9))
	yanil_unit.from_char(yanil, 0, Coordinate.new(14, 10))
	tobias_unit.from_char(tobias, 0, Coordinate.new(16, 11))
	
	$GridNodes.add_child(reginald_unit)
	$GridNodes.add_child(yanil_unit)
	$GridNodes.add_child(tobias_unit)
	add_blob(11, 10)
	add_blob(9, 8)
	add_blob(9, 11)
	add_blob(7, 9)
	add_blob(16, 6)
	add_blob(13, 7)
	add_blob(14, 15)
	add_blob(11, 14)
	
	draw_nodes()

func add_blob(x: int, y: int):
	var slime_sprite_sheet = preload("res://img/characters/Slime.png")
	var slime_sprite_1 = PunyCharacterSprite.slime_sprite(slime_sprite_sheet)
	var blob1 = Mob.new("Blobber", slime_sprite_1, 2, 0, 0, 0, Attack.new("Slime", 1, 1, [0], 4))
	var blob1_unit = new_unit.instantiate()
	blob1_unit.from_char(blob1, 1, Coordinate.new(x, y))
	$GridNodes.add_child(blob1_unit)

func position_from_coordinates(coordinate: Coordinate) -> Vector2:
	return Vector2(coordinate.x * grid_size, coordinate.y * grid_size)

func cell_centre_position(coordinate: Coordinate) -> Vector2:
	return position_from_coordinates(coordinate) + Vector2(0.5 * grid_size, 0.5 * grid_size)

func coordinates_from_position(p: Vector2) -> Coordinate:
	return Coordinate.new(p.x / grid_size, p.y / grid_size)

func distance(coordinate_1: Coordinate, coordinate_2: Coordinate) -> int:
	return int(abs(coordinate_1.x - coordinate_2.x) + abs(coordinate_1.y - coordinate_2.y))

func draw_grid():
	# Set background dimensions
	$Background.size = Vector2(width, height)
	
	# Draw vertical lines
	for i in (grid_width - 1):
		var offset = grid_size * (i + 1)
		var line = Line2D.new()
		line.width = 1
		line.default_color = Color.DARK_SLATE_GRAY
		line.default_color.a = 0.2
		line.add_point(Vector2(offset, 0))
		line.add_point(Vector2(offset, height))
		add_child(line)
	# Draw horizontal lines
	for i in (grid_height - 1):
		var offset = grid_size * (i + 1)
		var line = Line2D.new()
		line.width = 1
		line.default_color = Color.DARK_SLATE_GRAY
		line.default_color.a = 0.2
		line.add_point(Vector2(0, offset))
		line.add_point(Vector2(width, offset))
		add_child(line)

func get_adjacent_cells(coordinate: Coordinate) -> CoordinateList:
	var output = []
	if (coordinate.y - 1) >= 0:
		output.append(coordinate.add_y(-1))
	if (coordinate.y + 1) < grid_height:
		output.append(coordinate.add_y(1))
	if (coordinate.x - 1) >= 0:
		output.append(coordinate.add_x(-1))
	if (coordinate.x + 1) < grid_width:
		output.append(coordinate.add_x(1))
	return CoordinateList.new(output)

func cell_corners(coordinate: Coordinate):
	var start = position_from_coordinates(coordinate)
	return PackedVector2Array([
		start,
		start + Vector2(grid_size, 0),
		start + Vector2(grid_size, grid_size),
		start + Vector2(0, grid_size)
	])
