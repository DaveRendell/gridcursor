class_name Ancestry

var display_name: String
var skin_tones: Array
var skin_sprites: Dictionary
	

func _init(_display_name: String, _skin_tones: Array, _skin_sprites: Dictionary):
	display_name = _display_name
	skin_tones = _skin_tones
	skin_sprites = _skin_sprites

enum SkinTones {
	HUMAN_1,
	HUMAN_2,
	HUMAN_3,
	HUMAN_4,
	HUMAN_5,
	HUMAN_6,
	HUMAN_7,
	LIGHT_BLUE
}

const HUMAN_SKIN_TONES = [
	SkinTones.HUMAN_1,
	SkinTones.HUMAN_2,
	SkinTones.HUMAN_3,
	SkinTones.HUMAN_4,
	SkinTones.HUMAN_5,
	SkinTones.HUMAN_6,
	SkinTones.HUMAN_7,
]

static func human():
	return Ancestry.new(
		"Human",
		HUMAN_SKIN_TONES,
		{})

static func elf():
	return Ancestry.new(
		"Elf",
		HUMAN_SKIN_TONES + [SkinTones.LIGHT_BLUE],
		{
			7: Image.load_from_file("res://img/characters/humanoid/layer_7_addons/pointy_ears.png")
		})
