class_name Mob
extends Character

var attack: Attack

func _init(
	display_name: String,
	sprite: AnimatedSprite2D,
	might: int,
	precision: int,
	knowledge: int,
	wit: int,
	attack: Attack
):
	super(display_name, sprite, might, precision, knowledge, wit)
	self.attack = attack
	self.die_when_downed = true

func attacks() -> Array:
	return [attack]
