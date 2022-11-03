class_name Location extends Node2D

func _ready():
	$TerrainTypes.visible = false

func get_terrain_id_at(coordinate: Vector2i) -> int:
	return $TerrainTypes.get_cell_source_id(0, coordinate)

