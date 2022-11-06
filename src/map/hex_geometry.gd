class_name HexGeometry extends Geometry

var grid_size: int
var grid_width: int
var grid_height: int

# The length of a spoke from hex centre to a corner. Set automatically from
# grid_size
var hex_size: int

func _init(_grid_size: int, _grid_width: int, _grid_height: int):
	self.grid_size = _grid_size
	self.grid_width = _grid_width
	self.grid_height = _grid_height
	hex_size = float(grid_size) / sqrt(3)

func cell_centre_position(coordinate: Vector2i) -> Vector2:
	var out = Vector2(coordinate.x * grid_size, coordinate.y * 1.5 * hex_size)
	if coordinate.y % 2:
		out.x += 0.5 * grid_size
	return out + Vector2(0.5 * grid_size, hex_size)

func cell_containing_position(point: Vector2) -> Vector2i:
	var coords = pixel_to_offset_hex(
		point.x - 0.5 * grid_size,
		point.y- 0.5 * grid_size)
	return Vector2i(coords[0], coords[1])

func distance(coordinate_1: Vector2i, coordinate_2: Vector2i) -> int:
	var hex_1 = offset_to_cube(coordinate_1.x, coordinate_1.y)
	var hex_2 = offset_to_cube(coordinate_2.x, coordinate_2.y)
	return int(
		abs(hex_1[0] - hex_2[0])
		+ abs(hex_1[1] - hex_2[1])
		+ abs(hex_1[2] - hex_2[2])
	)

func adjacent_cells(coordinate: Vector2i) -> Array[Vector2i]:
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
	return output

func cell_corners(coordinate: Vector2i) -> Array[Vector2]:
	var start = cell_centre_position(coordinate) - Vector2(0, hex_size)
	return [
		start,
		start + Vector2(0.5 * grid_size, 0.5 * hex_size),
		start + Vector2(0.5 * grid_size, 1.5 * hex_size),
		start + Vector2(0, 2.0 * hex_size),
		start + Vector2(-0.5 * grid_size, 1.5 * hex_size),
		start + Vector2(-0.5 * grid_size, 0.5 * hex_size)
	]

func map_dimensions() -> Vector2:
	return Vector2(grid_size * (grid_width + 1), 2 * hex_size * (grid_height))

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
