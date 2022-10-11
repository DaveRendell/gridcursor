class_name CoordinateMap
# Custom collection for storing a layer of objects on a grid, e.g. terrain types
# or units on a map

var data: Array = []

func _init(width: int = 0, height: int = 0, grid_nodes: Array = [], default = 0):
	data.resize(width)
	for i in width:
		var col = []
		col.resize(height)
		for j in height:
			col[j] = default
		data[i] = col
	for item in grid_nodes:
		var grid_node = item as GridNode
		if grid_node:
			data[grid_node.x][grid_node.y] = grid_node

func at(coordinate: Coordinate):
	return data[coordinate.x][coordinate.y]

func set_value(coordinate: Coordinate, value) -> void:
	data[coordinate.x][coordinate.y] = value

func coordinates() -> Array:
	var out = []
	for i in data.size():
		for j in data[0].size():
			out.append(Coordinate.new(i, j))
	return out