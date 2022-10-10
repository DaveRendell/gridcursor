class_name CoordinateMap


var data: Array = []

func _init(width: int = 0, height: int = 0, default = null):
	data.resize(width)
	for i in width:
		var col = []
		col.resize(height)
		for j in height:
			col[j] = default
		data[i] = col

func at(coordinate: Coordinate):
	return data[coordinate.x][coordinate.y]
	
