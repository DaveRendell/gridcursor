extends Node2D

func _ready():
	SpriteUtils.generate_palette([
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1Black.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1Blond.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1Blue.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1Brown.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1Cyan.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1Gray.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1Green.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1Magenta.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1Red.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1White.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_1/FHairStyle1Yellow.png"),
	], "res://img/characters/humanoid/layer_4_hairstyle/hair_1/palette.png")
