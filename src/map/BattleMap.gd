class_name BattleMap extends "res://src/map/Map.gd"

var new_unit = preload("res://src/map/Unit.tscn")

func _ready():
	geometry = SquareGeometry.new(grid_size, grid_width, grid_height)
	super()
	
	set_terrain_types()
	draw_nodes()

func set_terrain_types() -> void:
	for coordinate in terrain_grid.coordinates():
		var cell = $Tiles/TerrainTypes.get_cell_source_id(0, Vector2i(coordinate.x, coordinate.y))
		terrain_grid.set_value(coordinate, cell)

func add_character(character: Character, coordinate: Vector2i) -> void:
	var unit = new_unit.instantiate()
	unit.from_char(character, 0, coordinate)
	$GridNodes.add_child(unit)
	update_units()

func add_blob(x: int, y: int):
	var slime_sprite_sheet = preload("res://img/characters/Slime.png")
	var slime_sprite = PunyCharacterSprite.slime_sprite(slime_sprite_sheet)
	var blob = Mob.new("Blobber", slime_sprite, 10, 0, 0, 0, Attack.new("Slime", 1, 1, [0], 4))
	var blob_unit = new_unit.instantiate()
	blob_unit.from_char(blob, 1, Vector2i(x, y))
	$GridNodes.add_child(blob_unit)
	update_units()

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
