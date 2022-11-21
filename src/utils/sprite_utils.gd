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

static func generate_palette(images: Array[Image], output_path: String):
	var base_image = images[0]
	var recolours = images.slice(1, images.size())
	
	var palette = {}
	for coordinate in get_pixel_coordinates(base_image):
		var colour = base_image.get_pixelv(coordinate)
		if colour.a and !palette.has(colour):
			var entry = []
			for recolour in recolours:
				entry.append(recolour.get_pixelv(coordinate))
			palette[colour] = entry
	
	# Delete any colours that are the same for all recolours
	for colour in palette.keys():
		if palette[colour].all(func(c): return c == colour):
			palette.erase(colour)
	
	var palette_image = Image.new()
	palette_image.create(palette.size(), images.size(), false, base_image.get_format())
	for i in palette.size():
		var base_colour = palette.keys()[i]
		palette_image.set_pixel(i, 0, base_colour)
		var new_colours = palette[base_colour]
		for j in new_colours.size():
			palette_image.set_pixel(i, j + 1, new_colours[j])
	
	palette_image.save_png(output_path)
