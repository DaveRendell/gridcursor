class_name DiceTexture

const D6_SPRITE_SHEET = preload("res://img/ui/d6.png")

static func d6(side: int) -> Texture2D:
	var texture = AtlasTexture.new()
	texture.atlas = D6_SPRITE_SHEET
	texture.region = Rect2(side * 16, 0, 16, 16)
	return texture
