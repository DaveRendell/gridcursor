class_name Humanoid extends Character

var appearance_details: AppearanceDetails

class AppearanceDetails:
	var skin_tone: int
	
	func _init(_skin_tone: int):
		skin_tone = _skin_tone

func _init(
	_display_name: String,
	_appearance_details: AppearanceDetails,
	_might: int = 0,
	_precision: int = 0,
	_knowledge: int = 0,
	_wit: int = 0
):
	appearance_details = _appearance_details
	var _sprite = generate_sprite()
	super(_display_name, _sprite, _might, _precision, _knowledge, _wit)

func generate_sprite() -> AnimatedSprite2D:
	var clothes_sprites = equipment.clothing.sprite_sheets as Dictionary if equipment else Dictionary()
	
	# Layer 0 - Skin
	var base_skin = Image.load_from_file("res://img/characters/humanoid/layer_0_skin/base.png")
	var skin_palette = Image.load_from_file("res://img/characters/humanoid/layer_0_skin/skin_palette.png")
	
	var image = SpriteUtils.recolour_image(base_skin, skin_palette, appearance_details.skin_tone)
	
	# Layer 1 - Shoes
	var shoes_sprite = clothes_sprites[1]\
		if clothes_sprites.has(1)\
		else Image.load_from_file("res://img/characters/humanoid/layer_1_shoes/ShoesBrown.png")
	image.blend_rect(shoes_sprite, Rect2i(Vector2i.ZERO, shoes_sprite.get_size()), Vector2i.ZERO)
	
	# Layer 2 - Clothes
	var clothes_sprite = clothes_sprites[2]\
		if clothes_sprites.has(2)\
		else Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/BasicBlack.png")
	image.blend_rect(clothes_sprite, Rect2i(Vector2i.ZERO, clothes_sprite.get_size()), Vector2i.ZERO)
	# Layer 3 - Gloves
	if clothes_sprites.has(3):
		var gloves_sprite = clothes_sprites[3]
		image.blend_rect(gloves_sprite, Rect2i(Vector2i.ZERO, gloves_sprite.get_size()), Vector2i.ZERO)
	# Layer 4 - Hairstyle
	
	# Layer 5 - Eyes
	
	# Layer 6 - Headgears
	if clothes_sprites.has(6):
		var headgear_sprite = clothes_sprites[6]
		image.blend_rect(headgear_sprite, Rect2i(Vector2i.ZERO, headgear_sprite.get_size()), Vector2i.ZERO)
	
	# Layer 7 - Add-ons
	
	return PunyCharacterSprite.character_sprite(ImageTexture.create_from_image(image))

func equip(slot: String, item: Equipment) -> void:
	super(slot, item)
	if slot == "clothing":
		sprite = generate_sprite()
