class_name CoordinateMap
# Custom collection for storing a layer of objects checked a grid, e.g. terrain types
# or units checked a map

var width: int
var height: int
var data: Array = []

func _init(
	width: int = 0,
	height: int = 0,
	map_markers: Array = [],
	default = null
):
	data.resize(width)
	for i in width:
		var col = []
		col.resize(height)
		for j in height:
			col[j] = default
		data[i] = col
	for child in map_markers:
		var grid_node = child as MapMarker
		if grid_node:
			for cell in grid_node.cells():
				data[cell.x][cell.y] = grid_node

func at(coordinate: Vector2i):
	return data[coordinate.x][coordinate.y]

func set_value(coordinate: Vector2i, value) -> void:
	data[coordinate.x][coordinate.y] = value

func coordinates() -> Array:
	var out = []
	for i in data.size():
		for j in data[0].size():
			out.append(Vector2i(i, j))
	return out

func non_empty_coordinates() -> Array:
	var out = []
	for i in data.size():
		for j in data[0].size():
			if data[i][j]:
				out.append(Vector2i(i, j))
	return out

func _to_string() -> String:
	var out = ""
	for row in data:
		for value in row:
			out += str(value)
		out += "\n"
	return out
