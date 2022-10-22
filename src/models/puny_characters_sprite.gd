class_name PunyCharacterSprite

# https://godotengine.org/qa/134445/how-to-add-frames-from-a-sprite-sheet-in-code
static func character_sprite(sprite_sheet: Texture) -> AnimatedSprite:
	sprite_sheet.flags = 0
	var sprite = AnimatedSprite.new()
	var frames = SpriteFrames.new()
	
	add_animation(frames, sprite_sheet, "default", 0, [0, 1], 2.5)
	add_animation(frames, sprite_sheet, "down", 0, [0, 2, 0, 3])
	add_animation(frames, sprite_sheet, "right", 2, [0, 2, 0, 3])
	add_animation(frames, sprite_sheet, "up", 4, [0, 2, 0, 3])
	add_animation(frames, sprite_sheet, "left", 6, [0, 2, 0, 3])
	
	add_spin_animation(frames, sprite_sheet)

	sprite.frames = frames
	sprite.position = Vector2(8, 8)
	sprite.play()
	return sprite

static func slime_sprite(sprite_sheet: Texture) -> AnimatedSprite:
	sprite_sheet.flags = 0
	var sprite = AnimatedSprite.new()
	var frames = SpriteFrames.new()
	
	add_animation(frames, sprite_sheet, "default", 0, [0, 1], 2.5)
	add_animation(frames, sprite_sheet, "down", 0, [0, 1, 2, 3, 4, 5], 7.0)
	add_animation(frames, sprite_sheet, "right", 0, [0, 1, 2, 3, 4, 5], 7.0)
	add_animation(frames, sprite_sheet, "up", 0, [0, 1, 2, 3, 4, 5], 7.0)
	add_animation(frames, sprite_sheet, "left", 0, [0, 1, 2, 3, 4, 5], 7.0)

	sprite.frames = frames
	sprite.position = Vector2(7, 8)
	sprite.play()
	return sprite

static func add_animation(
	frames: SpriteFrames,
	sprite_sheet: Texture,
	name: String,
	row: int,
	cells: Array,
	speed: float = 5
) -> void:
	var sprite_size = 32
	
	frames.add_animation(name)
	var y = row * sprite_size
	
	for i in cells.size():
		var x = cells[i] * sprite_size
		var frame_texture = AtlasTexture.new()
		frame_texture.atlas = sprite_sheet
		frame_texture.region = Rect2(x, y, sprite_size, sprite_size)
		frames.add_frame(name, frame_texture, i)

	frames.set_animation_speed(name, speed)

static func add_spin_animation(
	frames: SpriteFrames,
	sprite_sheet: Texture
) -> void:
	var sprite_size = 32
	
	frames.add_animation("spin")
	for i in 8:
		var frame_texture = AtlasTexture.new()
		frame_texture.atlas = sprite_sheet
		frame_texture.region = Rect2(0, i * sprite_size, sprite_size, sprite_size)
		frames.add_frame("spin", frame_texture, i)
	frames.set_animation_speed("spin", 5)
