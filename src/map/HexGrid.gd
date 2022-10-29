extends "res://src/map/Map.gd"

var width = grid_width * grid_size
var height = grid_height * grid_size

# Magic hexagon number
var q = float(grid_size) / (2 * sqrt(3))
var hex_size = float(grid_size) / sqrt(3)
var u_axis = grid_size * Vector2(1, 0)

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
	
	var blob1 = Mob.new("Blob", slime_sprite_1, 0, 0, 0, 0, Attack.new("Slime", 1, 1, [1], 2))
	var blob2 = Mob.new("Blob", slime_sprite_2, 0, 0, 0, 0, Attack.new("Slime", 1, 1, [1], 2))
	
	var reginald_unit = new_unit.instantiate()
	var blob1_unit = new_unit.instantiate()
	var blob2_unit = new_unit.instantiate()
	reginald_unit.from_char(reginald, 0, Vector2i(5, 6))
	blob1_unit.from_char(blob1, 1, Vector2i(5, 7))
	blob2_unit.from_char(blob2, 1, Vector2i(5, 8))
	
	$GridNodes.add_child(reginald_unit)
	$GridNodes.add_child(blob1_unit)
	$GridNodes.add_child(blob2_unit)
	
	draw_nodes()

func position_from_coordinates(coordinate: Vector2i) -> Vector2:
	var out = Vector2(coordinate.x * grid_size, coordinate.y * 1.5 * hex_size)
	if coordinate.y % 2:
		out.x += 0.5 * grid_size
	return out
	
func distance(coordinate_1: Vector2i, coordinate_2: Vector2i) -> int:
	var hex_1 = offset_to_cube(coordinate_1.x, coordinate_1.y)
	var hex_2 = offset_to_cube(coordinate_2.x, coordinate_2.y)
	return int(
		abs(hex_1[0] - hex_2[0])
		+ abs(hex_1[1] - hex_2[1])
		+ abs(hex_1[2] - hex_2[2])
	)

func coordinates_from_position(p: Vector2) -> Vector2i:
	var coords = pixel_to_offset_hex(p.x - 0.5 * grid_size, p.y- 0.5 * grid_size)
	return Vector2i(coords[0], coords[1])

func cell_centre_position(coordinate: Vector2i) -> Vector2:
	return position_from_coordinates(coordinate) + Vector2(0.5 * grid_size, hex_size)

func draw_grid():
	# Set background dimensions
	$Background.size = Vector2(width, height)
		
	for i in grid_width:
		for j in grid_height:
			var hex = Line2D.new()
			hex.width = 1
			hex.default_color = Color.DARK_SLATE_GRAY
			hex.antialiased = false
			
			hex.add_point(Vector2(0, 0))
			hex.add_point(Vector2(0.5 * grid_size, 0.5 * hex_size))
			hex.add_point(Vector2(0.5 * grid_size, 1.5 * hex_size))
			hex.add_point(Vector2(0, 2.0 * hex_size))
			hex.add_point(Vector2(-0.5 * grid_size, 1.5 * hex_size))
			hex.add_point(Vector2(-0.5 * grid_size, 0.5 * hex_size))
			hex.add_point(Vector2(0, 0))
			hex.position = position_from_coordinates(Vector2i(i, j)) + 0.5 * grid_size * Vector2.RIGHT
			add_child(hex)

func get_adjacent_cells(coordinate: Vector2i) -> CoordinateList:
	var cube_coords = offset_to_cube(coordinate.x, coordinate.y)
	var unbounded_neighbours = [
		cube_to_offset(cube_coords[0], cube_coords[1] - 1, cube_coords[2] + 1),
		cube_to_offset(cube_coords[0], cube_coords[1] + 1, cube_coords[2] - 1),
		cube_to_offset(cube_coords[0] - 1, cube_coords[1], cube_coords[2] + 1),
		cube_to_offset(cube_coords[0] + 1, cube_coords[1], cube_coords[2] - 1),
		cube_to_offset(cube_coords[0] - 1, cube_coords[1] + 1, cube_coords[2]),
		cube_to_offset(cube_coords[0] + 1, cube_coords[1] - 1, cube_coords[2])
	]
	var output = []
	for neighbour in unbounded_neighbours:
		if neighbour[0] >= 0 and neighbour[0] < grid_width\
		and neighbour[1] >= 0 and neighbour[1] < grid_height:
			output.append(Vector2i(neighbour[0], neighbour[1]))
	return CoordinateList.new(output)

func cell_corners(coordinate: Vector2i):
	var start = position_from_coordinates(coordinate) + Vector2(0.5 * grid_size, 0)
	return PackedVector2Array([
		start,
		start + Vector2(0.5 * grid_size, 0.5 * hex_size),
		start + Vector2(0.5 * grid_size, 1.5 * hex_size),
		start + Vector2(0, 2.0 * hex_size),
		start + Vector2(-0.5 * grid_size, 1.5 * hex_size),
		start + Vector2(-0.5 * grid_size, 0.5 * hex_size)
	])

# https://www.redblobgames.com/grids/hexagons/
func cube_to_offset(q, r, s):
	var x = q + (r - (r&1)) / 2
	var y = r
	return [x, y]

func offset_to_cube(x, y):
	var q = x - (y - (y&1)) / 2
	var r = y
	var s = - q - r
	return [q, r, s]
	
func pixel_to_offset_hex(x, y):
	var cube_coords = pixel_to_pointy_hex(x, y)
	return cube_to_offset(cube_coords[0], cube_coords[1], cube_coords[2])

func pixel_to_pointy_hex(x, y):
	var q = ((sqrt(3)/3) * x - (1.0/3) * y) / hex_size
	var r = (2.0/3 * y) / hex_size
	return cube_round(q, r, -q-r)

func cube_round(fq, fr, fs):
	var q = int(round(fq))
	var r = int(round(fr))
	var s = int(round(fs))
	
	var dq = abs(q - fq)
	var dr = abs(r - fr)
	var ds = abs(s - fs)
	
	if dq > dr and dq > ds:
		q = -r-s
	elif dr > ds:
		r = -q-s
	else:
		s = -q-r
	return [q, r, s]
