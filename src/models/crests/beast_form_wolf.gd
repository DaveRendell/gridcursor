class_name BeastFormWolf extends Crest

func _init():
	display_name = "Beast Form: Wolf"

func beast_forms():
	return [BeastForm.new(
		"Wolf",
		create_wolf_sprite(),
		3,
		2
	)]

func create_wolf_sprite() -> AnimatedSprite2D:
	var wolf_sheet = preload("res://img/characters/wolf_gray_full.png")
	var wag_sheet = preload("res://img/characters/wolf_tailwag_full.png")
	var sprite = AnimatedSprite2D.new()
	var frames = SpriteFrames.new()
	
	PunyCharacterSprite.add_animation(frames, wag_sheet, "default", 0, [0, 1, 2, 1], 2.5)
	PunyCharacterSprite.add_animation(frames, wolf_sheet, "down", 0, [0, 1, 2, 1], 7.5)
	PunyCharacterSprite.add_animation(frames, wolf_sheet, "left", 1, [0, 1, 2, 1], 7.5)
	PunyCharacterSprite.add_animation(frames, wolf_sheet, "right", 2, [0, 1, 2, 1], 7.5)
	PunyCharacterSprite.add_animation(frames, wolf_sheet, "up", 3, [0, 1, 2, 1], 7.5)
	PunyCharacterSprite.add_animation(frames, wolf_sheet, "attack_down", 0, [5, 4, 3, 3, 3], 5)
	PunyCharacterSprite.add_animation(frames, wolf_sheet, "attack_left", 1, [5, 4, 3, 3, 3], 5)
	PunyCharacterSprite.add_animation(frames, wolf_sheet, "attack_right", 2, [3, 4, 5, 5, 5], 5)
	PunyCharacterSprite.add_animation(frames, wolf_sheet, "attack_up", 3, [3, 4, 5, 5, 5], 5)
	
	sprite.frames = frames
	sprite.play()
	sprite.offset = Vector2(0, -8)
	return sprite
