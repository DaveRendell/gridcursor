class_name Humanoid extends Character

var ancestry: Ancestry
var appearance_details: AppearanceDetails

class AppearanceDetails:
	var skin_tone: int
	var hair_style: int
	var hair_colour: int
	var beard_style: int
	var base_clothes_colour: int
	
	func _init(
		_skin_tone: int,
		_hair_style: int,
		_hair_colour: int,
		_beard_style: int,
		_base_clothes_colour: int
	):
		skin_tone = _skin_tone
		hair_style = _hair_style
		hair_colour = _hair_colour
		beard_style = _beard_style
		base_clothes_colour = _base_clothes_colour

func _init(
	_display_name: String,
	_ancestry: Ancestry,
	_appearance_details: AppearanceDetails,
	_might: int = 0,
	_precision: int = 0,
	_knowledge: int = 0,
	_wit: int = 0
):
	ancestry = _ancestry
	appearance_details = _appearance_details
	var _sprite = generate_sprite()
	super(_display_name, _sprite, _might, _precision, _knowledge, _wit)

func generate_sprite() -> AnimatedSprite2D:
	var clothes_sprites = equipment.clothing.sprite_sheets as Dictionary if equipment and equipment.clothing else Dictionary()
	
	# Layer 0 - Skin
	var image: Image
	var skin_palette = Image.load_from_file("res://img/characters/humanoid/layer_0_skin/skin_palette.png")
	if ancestry.alternate_base:
		image = ancestry.alternate_base
	else:
		var base_skin = Image.load_from_file("res://img/characters/humanoid/layer_0_skin/base.png")
		
		image = SpriteUtils.recolour_image(base_skin, skin_palette, appearance_details.skin_tone)
	
	# Layer 1 - Shoes
	var shoes_sprite = clothes_sprites[1]\
		if clothes_sprites.has(1)\
		else Image.load_from_file("res://img/characters/humanoid/layer_1_shoes/ShoesBrown.png")
	image.blend_rect(shoes_sprite, Rect2i(Vector2i.ZERO, shoes_sprite.get_size()), Vector2i.ZERO)
	
	# Layer 2 - Clothes
	var clothes_sprite
	if clothes_sprites.has(2):
		clothes_sprite = clothes_sprites[2]
	else:
		var base_clothes_sprite = Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/basic/base.png")
		var palette = Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/basic/palette.png")
		clothes_sprite = SpriteUtils.recolour_image(base_clothes_sprite, palette, appearance_details.base_clothes_colour)
	image.blend_rect(clothes_sprite, Rect2i(Vector2i.ZERO, clothes_sprite.get_size()), Vector2i.ZERO)
	
	# Layer 3 - Gloves
	if clothes_sprites.has(3):
		var gloves_sprite = clothes_sprites[3]
		image.blend_rect(gloves_sprite, Rect2i(Vector2i.ZERO, gloves_sprite.get_size()), Vector2i.ZERO)
		
	# Layer 4 - Hairstyle
	var hair_palette = Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/palette.png")
	
	if appearance_details.hair_style > 0: # Zero is bald
		var base_hair = Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/base.png" % [appearance_details.hair_style])
		var hair_sprite = SpriteUtils.recolour_image(base_hair, hair_palette, appearance_details.hair_colour)
		image.blend_rect(hair_sprite, Rect2i(Vector2i.ZERO, hair_sprite.get_size()), Vector2i.ZERO)
	
	if appearance_details.beard_style > 0: # Zero is clean shaven
		var base_beard = Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/beards/%s.png" % [appearance_details.beard_style])
		var beard_sprite = SpriteUtils.recolour_image(base_beard, hair_palette, appearance_details.hair_colour)
		image.blend_rect(beard_sprite, Rect2i(Vector2i.ZERO, beard_sprite.get_size()), Vector2i.ZERO)
	
	# Layer 5 - Eyes
	
	# Layer 6 - Headgears
	if clothes_sprites.has(6):
		var headgear_sprite = clothes_sprites[6]
		image.blend_rect(headgear_sprite, Rect2i(Vector2i.ZERO, headgear_sprite.get_size()), Vector2i.ZERO)
	
	# Layer 7 - Add-ons
	for add_on in ancestry.skin_coloured_add_ons:
		var recoloured_addon_sprite = SpriteUtils.recolour_image(add_on, skin_palette, appearance_details.skin_tone)
		image.blend_rect(recoloured_addon_sprite, Rect2i(Vector2i.ZERO, recoloured_addon_sprite.get_size()), Vector2i.ZERO)
	
	return PunyCharacterSprite.character_sprite(ImageTexture.create_from_image(image))

func equip(slot: String, item: Equipment) -> void:
	super(slot, item)
	if slot == "clothing":
		sprite = generate_sprite()
