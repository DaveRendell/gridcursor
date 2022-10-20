extends "res://src/map/Map.gd"

var width = grid_width * grid_size
var height = grid_height * grid_size

var new_unit = preload("res://src/map/Unit.tscn")

func _ready():
	var blue_soldier_sprite_sheet = preload("res://img/characters/Soldier-Blue.png")
	var blue_soldier_sprite = PunyCharacterSprite.character_sprite(blue_soldier_sprite_sheet)
	var slime_sprite_sheet = preload("res://img/characters/Slime.png")
	var slime_sprite_1 = PunyCharacterSprite.slime_sprite(slime_sprite_sheet)
	var slime_sprite_2 = PunyCharacterSprite.slime_sprite(slime_sprite_sheet)
	
	var sword = Weapon.new("Sword", 5, [0], 3)
	var short_bow = Weapon.new("Short bow", 5, [1], 2, 2, 8)
	var great_sword = Weapon.new("Greatsword", 10, [1], 5, 1, 1, true)

	var leather_armour = Armour.new("Leather armour", 5, 8)

	var shield = Shield.new("Buckler", 4, 1)

	var reginald = Character.new("Reginald", blue_soldier_sprite, 3, 2, 1, 1)
	reginald.equip("main_hand", sword)
	reginald.equip("off_hand", shield)
	reginald.equip("clothing", leather_armour)
	
	var blob1 = Mob.new("Blobber", slime_sprite_1, 0, 0, 0, 0, Attack.new("Slime", 1, 1, [1], 2))
	var blob2 = Mob.new("Blobber", slime_sprite_2, 0, 0, 0, 0, Attack.new("Slime", 1, 1, [1], 2))
	
	var reginald_unit = new_unit.instance()
	var blob1_unit = new_unit.instance()
	var blob2_unit = new_unit.instance()
	reginald_unit.from_char(reginald, 0, Coordinate.new(5, 6))
	blob1_unit.from_char(blob1, 1, Coordinate.new(5, 7))
	blob2_unit.from_char(blob2, 1, Coordinate.new(0, 0))
	
	$GridNodes.add_child(reginald_unit)
	$GridNodes.add_child(blob1_unit)
	$GridNodes.add_child(blob2_unit)
	
	draw_nodes()


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
	$Background.rect_size = Vector2(width, height)
	
	# Draw vertical lines
	for i in (grid_width - 1):
		var offset = grid_size * (i + 1)
		var line = Line2D.new()
		line.width = 1
		line.default_color = Color.darkslategray
		line.add_point(Vector2(offset, 0))
		line.add_point(Vector2(offset, height))
		add_child(line)
	# Draw horizontal lines
	for i in (grid_height - 1):
		var offset = grid_size * (i + 1)
		var line = Line2D.new()
		line.width = 1
		line.default_color = Color.darkslategray
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
	return PoolVector2Array([
		start,
		start + Vector2(grid_size, 0),
		start + Vector2(grid_size, grid_size),
		start + Vector2(0, grid_size)
	])
