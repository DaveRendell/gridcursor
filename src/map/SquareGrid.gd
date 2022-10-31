extends "res://src/map/Map.gd"

var new_unit = preload("res://src/map/Unit.tscn")

func _ready():
	geometry = SquareGeometry.new(grid_size, grid_width, grid_height)
	super()
	
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
	reginald_unit.from_char(reginald, 0, Vector2i(13, 9))
	yanil_unit.from_char(yanil, 0, Vector2i(14, 10))
	tobias_unit.from_char(tobias, 0, Vector2i(16, 11))
	
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
	var blob1 = Mob.new("Blobber", slime_sprite_1, 10, 0, 0, 0, Attack.new("Slime", 1, 1, [0], 4))
	var blob1_unit = new_unit.instantiate()
	blob1_unit.from_char(blob1, 1, Vector2i(x, y))
	$GridNodes.add_child(blob1_unit)

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
