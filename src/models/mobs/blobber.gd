class_name Blobber extends Mob

const SPRITE_SHEET = preload("res://img/characters/Slime.png")

func _init():
	var name = "Blobber"
	var sprite = PunyCharacterSprite.slime_sprite(SPRITE_SHEET)
	var might = 3
	var precision = 0
	var knowledge = 0
	var wit = 0
	var attack = Attack.new("Slime", 1, 1, [0], 4)
	
	super(
		name,
		sprite,
		might, precision, knowledge, wit,
		attack)
