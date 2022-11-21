class_name SpriteUtils

static func recolour_image(base: Image, palette: Image, row: int) -> Image:
	var new_image = base.duplicate() as Image
	var palette_map = generate_palette_map(palette)
	for coordinate in get_pixel_coordinates(base):
		var base_colour = base.get_pixelv(coordinate)
		if palette_map.has(base_colour):
			var palette_column = palette_map[base_colour]
			var new_colour = palette.get_pixel(palette_column, row)
			new_image.set_pixelv(coordinate, new_colour)
	return new_image
	
# Returns all the pixel coordinate of the image as an array for iterating over.
static func get_pixel_coordinates(image: Image) -> Array[Vector2i]:
	var width = image.get_width()
	var height = image.get_height()
	var out = [] as Array[Vector2i]
	for i in width:
		for j in height:
			out.append(Vector2i(i, j))
	return out

# Returns a dictionary mapping a colour in the base palette to its column in
# the palette.
static func generate_palette_map(palette: Image) -> Dictionary:
	var out = {}
	var width = palette.get_width()
	for i in width:
		var colour = palette.get_pixel(i, 0)
		out[colour] = i
	return out
