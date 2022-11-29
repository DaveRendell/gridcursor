

static func with_colour(colour: Color) -> Image:
	var image = Image.load_from_file("res://img/characters/humanoid/layer_6_headgears/shadow_hood/base.png")
	var base_colours = Image.load_from_file("res://img/characters/humanoid/layer_6_headgears/shadow_hood/colours.png")
	var colours = [
		colour.darkened(0.6),
		colour.darkened(0.4),
		colour,
		colour.lightened(0.3)
	]
	var palette_map = SpriteUtils.generate_palette_map(base_colours, 0)
	
	for coordinate in SpriteUtils.get_pixel_coordinates(image):
		var base_colour = image.get_pixelv(coordinate)
		if palette_map.has(base_colour):
			var palette_index = palette_map[base_colour]
			var new_colour = colours[palette_index]
			image.set_pixelv(coordinate, new_colour)
	
	return image
