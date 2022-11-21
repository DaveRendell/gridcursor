class_name PunyCharacterSprite

# https://godotengine.org/qa/134445/how-to-add-frames-from-a-sprite-sheet-in-code
static func character_sprite(sprite_sheet: Texture2D) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	var frames = SpriteFrames.new()
	
	add_animation(frames, sprite_sheet, "default", 0, [0, 1], 2.5)
	
	add_directional_animation(frames, sprite_sheet, "", [1, 2, 3, 4])
	add_directional_animation(frames, sprite_sheet, "sword_", [5, 6, 7, 8], 10.0)
	add_directional_animation(frames, sprite_sheet, "bow_", [9, 10, 11, 12], 10.0)
	add_directional_animation(frames, sprite_sheet, "staff_", [13, 14, 15], 10.0)
	add_directional_animation(frames, sprite_sheet, "attack_", [16, 17, 18], 10.0)
	
	add_animation(frames, sprite_sheet, "damage", 0, [19, 20])
	add_animation(frames, sprite_sheet, "knocked_down", 0, [21, 22, 23], 10.0)
	
	add_spin_animation(frames, sprite_sheet)

	sprite.frames = frames
	sprite.play()
	return sprite

static func slime_sprite(sprite_sheet: Texture2D) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	var frames = SpriteFrames.new()
	
	add_animation(frames, sprite_sheet, "default", 0, [0, 1], 2.5)
	add_animation(frames, sprite_sheet, "down", 0, [2, 3, 4, 5], 7.0)
	add_animation(frames, sprite_sheet, "right", 0, [2, 3, 4, 5], 7.0)
	add_animation(frames, sprite_sheet, "up", 0, [2, 3, 4, 5], 7.0)
	add_animation(frames, sprite_sheet, "left", 0, [2, 3, 4, 5], 7.0)
	
	add_animation(frames, sprite_sheet, "attack_down", 0, [2, 2, 2, 2, 3, 4, 5], 8.0)
	add_animation(frames, sprite_sheet, "attack_right", 0, [2, 2, 2, 2, 3, 4, 5], 8.0)
	add_animation(frames, sprite_sheet, "attack_up", 0, [2, 2, 2, 2, 3, 4, 5], 8.0)
	add_animation(frames, sprite_sheet, "attack_left", 0, [2, 2, 2, 2, 3, 4, 5], 8.0)
	
	add_animation(frames, sprite_sheet, "damage", 0, [6, 7, 8])
	add_animation(frames, sprite_sheet, "knocked_down", 0, [9, 10, 11, 12, 13], 10.0)

	sprite.frames = frames
	sprite.play()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return sprite

static func add_directional_animation(
	frames: SpriteFrames,
	sprite_sheet: Texture2D,
	prefix: String,
	cells: Array[int],
	speed: float = 5.0
) -> void:
	add_animation(frames, sprite_sheet, prefix + "down", 0, cells, speed)
	add_animation(frames, sprite_sheet, prefix + "right", 2, cells, speed)
	add_animation(frames, sprite_sheet, prefix + "up", 4, cells, speed)
	add_animation(frames, sprite_sheet, prefix + "left", 6, cells, speed)

static func add_animation(
	frames: SpriteFrames,
	sprite_sheet: Texture2D,
	name: String,
	row: int,
	cells: Array,
	speed: float = 5.0
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
	sprite_sheet: Texture2D
) -> void:
	var sprite_size = 32
	
	frames.add_animation("spin")
	for i in 8:
		var frame_texture = AtlasTexture.new()
		frame_texture.atlas = sprite_sheet
		frame_texture.region = Rect2(18 * sprite_size, i * sprite_size, sprite_size, sprite_size)
		frames.add_frame("spin", frame_texture, i)
	frames.set_animation_speed("spin", 5)
