class_name Song

var display_name: String
var range: int
var effect: TemporaryEffect
var label_text: String
var label_colour: Color
var highlight_colour: Color

func _init(
	_display_name: String,
	_range: int,
	_effect: TemporaryEffect,
	_label_text: String,
	_label_colour: Color,
	_highlight_colour: Color
):
	display_name = _display_name
	range = _range
	effect = _effect
	label_text = _label_text
	label_colour = _label_colour
	highlight_colour = _highlight_colour

func perform_effect(map: BattleMap, musician: Unit, position: Vector2i) -> void:
	for cell in map.terrain.coordinates():
		if map.geometry.distance(cell, position) <= range:
			map.add_highlight(cell, highlight_colour)
	
	for unit in map.units_in_aoe(position, range):
		if unit.team == musician.team:
			var already_has_effect = unit.character.temporary_effects.filter(func(temp_effect):
				return temp_effect.display_name == effect.display_name).size() > 0
			if !already_has_effect:
				unit.character.add_temporary_effect(effect)
				unit.display_label(label_text, label_colour)
	
	await map.get_tree().create_timer(0.75).timeout
	
	map.clear_highlights()
