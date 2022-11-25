class_name Ancestry

var display_name: String
var skin_tones: Array
var skin_coloured_add_ons: Array[Image]
var alternate_base: Image
	

func _init(_display_name: String, _skin_coloured_add_ons: Array[Image], _skin_tones: Array, _alternate_base: Image = null):
	display_name = _display_name
	skin_coloured_add_ons = _skin_coloured_add_ons
	alternate_base = _alternate_base
	skin_tones = _skin_tones

enum SkinTones {
	HUMAN_1,
	HUMAN_2,
	HUMAN_3,
	HUMAN_4,
	HUMAN_5,
	HUMAN_6,
	HUMAN_7,
	LIGHT_BLUE,
	PURPLE,
	GREEN,
	YELLOW_GREEN,
	RED
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
		[],
		HUMAN_SKIN_TONES)

static func elf():
	return Ancestry.new(
		"Elf",
		[Image.load_from_file("res://img/characters/humanoid/layer_7_addons/pointy_ears.png")],
		HUMAN_SKIN_TONES + [SkinTones.LIGHT_BLUE, SkinTones.PURPLE])

static func dwarf():
	return Ancestry.new(
		"Dwarf",
		[],
		HUMAN_SKIN_TONES)

static func goblin():
	return Ancestry.new(
		"Goblin",
		[Image.load_from_file("res://img/characters/humanoid/layer_7_addons/pointy_ears.png")],
		[SkinTones.GREEN, SkinTones.YELLOW_GREEN])

static func orc():
	return Ancestry.new(
		"Orc",
		[Image.load_from_file("res://img/characters/humanoid/layer_7_addons/thick_jaw.png")],
		[SkinTones.GREEN])

static func skeleton():
	return Ancestry.new(
		"Skeleton",
		[],
		HUMAN_SKIN_TONES,
		Image.load_from_file("res://img/characters/humanoid/layer_0_skin/skeleton.png"))
