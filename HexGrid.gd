extends "res://Grid.gd"

# Magic hexagon number
var q = float(grid_size) / (2 * sqrt(3))
var hex_size = float(grid_size) / sqrt(3)
var u_axis = grid_size * Vector2(1, 0)

func position_from_coordinates(x: int, y: int) -> Vector2:
	var out = Vector2(x * grid_size, y * 1.5 * hex_size)
	if y % 2:
		out.x += 0.5 * grid_size
	return out
	
	
# QQ: Still not quite right
func coordinates_from_position(p: Vector2) -> Array:
	var coords = pixel_to_offset_hex(p.x - 0.5 * grid_size, p.y- 0.5 * grid_size)
	return coords


func draw_grid():
	# Set background dimensions
	$Background.rect_size = Vector2(width, height)
		
	for i in grid_width:
		for j in grid_height:
			var hex = Line2D.new()
			hex.width = 1
			hex.default_color = Color.darkslategray
			hex.antialiased = false
			
			hex.add_point(Vector2(0, 0))
			hex.add_point(Vector2(0.5 * grid_size, 0.5 * hex_size))
			hex.add_point(Vector2(0.5 * grid_size, 1.5 * hex_size))
			hex.add_point(Vector2(0, 2.0 * hex_size))
			hex.add_point(Vector2(-0.5 * grid_size, 1.5 * hex_size))
			hex.add_point(Vector2(-0.5 * grid_size, 0.5 * hex_size))
			hex.add_point(Vector2(0, 0))
			hex.position = position_from_coordinates(i, j) + 0.5 * grid_size * Vector2.RIGHT
			add_child(hex)

# https://www.redblobgames.com/grids/hexagons/
func cube_to_offset(q, r, s):
	var x = q + (r - (r&1)) / 2
	var y = r
	return [x, y]

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
