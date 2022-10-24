class_name Weapon
extends Equipment

enum Stat {
	MIGHT,
	PRECISION,
	KNOWLEDGE,
	WIT,
}

var attacking_stats: Array # of Stat enum (int)
var damage: int
var min_range: int
var max_range: int
var animation: String

func _init(
	display_name: String,
	weight: int,
	attacking_stats: Array,
	damage: int,
	min_range: int = 1,
	max_range: int = 1,
	is_two_handed = false,
	animation = "attack"
).(display_name, weight):
	self.attacking_stats = attacking_stats
	self.damage = damage
	self.min_range = min_range
	self.max_range = max_range
	if is_two_handed:
		self.equipable_slots = ["both_hands"]
	else:
		self.equipable_slots = ["main_hand", "off_hand"]
	self.animation = animation

func get_attacks() -> Array:
	return [Attack.new(display_name, min_range, max_range, attacking_stats, damage, animation)]
