extends Node2D

func _ready():
	#SpriteUtils.generate_palette([
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/Demon1.png"),
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/Human1.png"),
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/Human2.png"),
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/Human3.png"),
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/Human4.png"),
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/Human5.png"),
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/Human6.png"),
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/Human7.png"),
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/NightElf1.png"),
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/Orc1.png"),
	#	Image.load_from_file("res://img/characters/humanoid/layer_0_skin/Orc2.png"),
	#], "res://img/characters/humanoid/layer_0_skin/new_palette.png")
	var jaw = Image.load_from_file("res://img/characters/humanoid/layer_7_addons/thick_jaw.png")
	var palette = Image.load_from_file("res://img/characters/humanoid/layer_0_skin/skin_palette.png")
	
	var out = SpriteUtils.recolour_image(jaw, palette, 0, 9)
	out.save_png("res://img/characters/humanoid/layer_7_addons/thick_jaw_r.png")
