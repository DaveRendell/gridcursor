class_name BeastForm

var beast_name: String
var beast_sprite: AnimatedSprite2D
var beast_might: int
var beast_precision: int

func _init(
	_beast_name: String,
	_beast_sprite: AnimatedSprite2D,
	_beast_might: int,
	_beast_precision: int
):
	beast_name = _beast_name
	beast_sprite = _beast_sprite
	beast_might = _beast_might
	beast_precision = _beast_precision

func create_beast(human_form: Character) -> Character:
	return BeastFormCharacter.new(
		beast_name,
		beast_sprite,
		beast_might,
		beast_precision,
		human_form
	)

class BeastFormCharacter extends Character:
	var human_form: Character
	func _init(
		beast_name: String,
		sprite: AnimatedSprite2D,
		might: int,
		precision: int,
		_human_form: Character
	):
		human_form = _human_form
		super(
			"%s (%s form)" % [human_form.display_name, beast_name],
			sprite,
			might,
			precision,
			human_form.stats[E.Stat.KNOWLEDGE],
			human_form.stats[E.Stat.WIT],
		)
	
	func max_hp():
		return 2 * stats[E.Stat.MIGHT] + stats[E.Stat.PRECISION]
	
	func features():
		return human_form.crests + human_form.temporary_effects + [BeastFeature.new(human_form)]
	
	func attacks():
		return [Attack.new("Bite", 1, 1, [E.Stat.MIGHT], 5)]
	
	func spells():
		return []
	
	func songs():
		return []
	
	func beast_forms():
		return []
	

class BeastFeature extends Feature:
	var human_character: Character
	func _init(_human_character):
		human_character = _human_character
		super("Beast")
	
	func battle_actions() -> Array:
		return [EndBeastFormAction.new(human_character)]
	
	func on_knocked_down(map: BattleMap, unit: Unit) -> void:
		var new_unit: Unit = map.add_character(human_character, unit.coordinate(), unit.team)
		map.clear_highlights()
		map.set_state_nothing_selected()
		new_unit.set_state_done(map)
		unit.queue_free()

class EndBeastFormAction extends BattleAction:
	var human_character: Character
	func _init(_human_character):
		human_character = _human_character
		super("End beast form")
	
	func perform_action(map: BattleMap, unit: Unit, path: Array[Vector2i]) -> void:
		var new_unit: Unit = map.add_character(human_character, path.back(), unit.team)
		map.clear_highlights()
		map.set_state_nothing_selected()
		new_unit.set_state_done(map)
		unit.queue_free()
