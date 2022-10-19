class_name Mob
extends Character

var attack: Attack

func _init(
	display_name: String,
	sprite: AnimatedSprite,
	might: int,
	precision: int,
	knowledge: int,
	wit: int,
	attack: Attack
).(display_name, sprite, might, precision, knowledge, wit):
	self.attack = attack

func attacks() -> Array:
	return [attack]
