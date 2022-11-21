extends Node2D

func _ready():
	var hair_id = 13
	var gender = "M"
	var count = 9
	SpriteUtils.generate_palette([
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sBlack.png" % [hair_id, gender, count]),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sBlond.png" % [hair_id, gender, count]),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sBlue.png" % [hair_id, gender, count]),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sBrown.png" % [hair_id, gender, count]),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sCyan.png" % [hair_id, gender, count]),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sGray.png" % [hair_id, gender, count]),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sGreen.png" % [hair_id, gender, count]),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sMagenta.png" % [hair_id, gender, count]),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sRed.png" % [hair_id, gender, count]),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sWhite.png" % [hair_id, gender, count]),
		Image.load_from_file("res://img/characters/humanoid/layer_4_hairstyle/hair_%s/%sHairStyle%sYellow.png" % [hair_id, gender, count]),
	], "res://img/characters/humanoid/layer_4_hairstyle/hair_%s/palette.png" % [hair_id])
