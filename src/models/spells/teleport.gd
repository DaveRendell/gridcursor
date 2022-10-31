class_name Teleport
extends Spell

const spell_range = 10
const highlight_colour = Color.LIGHT_GREEN

func _init():
	super("Teleport")

func battle_action(map: Map, caster: Unit, path: Array[Vector2i]) -> void:
	var teleport_options: Array[Vector2i] = []
	for coordinate in map.terrain_grid.coordinates():
		if map.geometry.distance(path.back(), coordinate) <= spell_range\
		and caster.movement_cost_of_cell(map, coordinate) >= 0:
			teleport_options.append(coordinate)
	
	map.clear_highlights()
	map.add_highlights(teleport_options, highlight_colour)
	

	map.set_state_unit_controlled(teleport_options)
	var result = await map.click
	map.set_state_in_menu()
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		map.clear_highlights()
		caster.set_state_spell_select(map, path)
	else:
		map.clear_highlights()
		var destination_coordinates = map.cursor
		var animation = caster.get_tree().create_tween()
		var small_size = 4.0 / map.grid_size
		var high_point = Vector2(0, -100 * map.grid_size)
		var destination = map.geometry.cell_centre_position(destination_coordinates)
		map.set_state_in_menu()
		
		caster.sprite.animation = "spin"
		
		animation.tween_property(caster.sprite, "speed_scale", 10.0, 0.5)
		animation.tween_property(caster, "modulate", Color.GREEN, 0.5)
		animation.tween_property(caster, "position", caster.position + high_point, 0.7)
		animation.tween_property(caster, "position", destination + high_point, 0.01)
		animation.tween_property(caster, "position", destination, 0.7)
		animation.tween_property(caster, "modulate", Color.WHITE, 0.5)
		animation.tween_property(caster.sprite, "speed_scale", 1.0, 0.5)
		animation.tween_property(caster.sprite, "speed_scale", 1, 1)
		await animation.finished
		caster.sprite.animation = "default"
		caster.update_position(map, destination_coordinates)
		caster.set_state_done(map)
	
