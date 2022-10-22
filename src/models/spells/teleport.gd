class_name Teleport
extends Spell

const spell_range = 10
const highlight_colour = Color.lightgreen

func _init().("Teleport"):
	pass

func battle_action(map: Map, caster: Unit, path: CoordinateList) -> void:
	var teleport_options = []
	for coordinate in map.terrain_grid.coordinates():
		if map.distance(path.last(), coordinate) <= spell_range\
		and caster.movement_cost_of_cell(map, coordinate) >= 0:
			teleport_options.append(coordinate)
	
	map.clear_highlights()
	map.add_highlights(CoordinateList.new(teleport_options), highlight_colour)
	
	var attack_selected = caster.wait_for_cell_option_select(map, CoordinateList.new(teleport_options))
	var result = yield(map, "click")
	attack_selected.resume()
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		map.clear_highlights()
		caster.state_to_spell_select(map, path)
	else:
		map.clear_highlights()
		var destination_coordinates = map.cursor
		var animation = caster.get_tree().create_tween()
		var small_size = 4.0 / map.grid_size
		var high_point = Vector2(0, -100 * map.grid_size)
		var destination = map.position_from_coordinates(destination_coordinates)
		map.set_active(false)
		
		caster.sprite.animation = "spin"
		
		animation.tween_property(caster.sprite, "speed_scale", 10.0, 0.5)
		animation.tween_property(caster, "modulate", Color.green, 0.5)
		animation.tween_property(caster, "position", caster.position + high_point, 0.7)
		animation.tween_property(caster, "position", destination + high_point, 0.01)
		animation.tween_property(caster, "position", destination, 0.7)
		animation.tween_property(caster, "modulate", Color.white, 0.5)
		animation.tween_property(caster.sprite, "speed_scale", 1.0, 0.5)
		animation.tween_property(caster.sprite, "speed_scale", 1, 1)
		yield(animation, "finished")
		caster.sprite.animation = "default"
		caster.update_position(map, destination_coordinates)
		caster.state_to_done(map)
	
