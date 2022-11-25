extends Node2D

func _ready():
	SpriteUtils.generate_palette([
		Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/basic/BasicBlack.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/basic/BasicBlue.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/basic/BasicCyan.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/basic/BasicGreen.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/basic/BasicPurple.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/basic/BasicRed.png"),
		Image.load_from_file("res://img/characters/humanoid/layer_2_clothes/basic/BasicYellow.png"),
	], "res://img/characters/humanoid/layer_2_clothes/palette.png")

