class_name Fireball
extends Spell

var spell_range = 7
var aoe_radius = 2

var target_colour = Color.GREEN
var aoe_colour = Color.RED

var explosion_scene = preload("res://img/battle/effects/Explosion.tscn")

func _init():
	super("Fireball")

func battle_action(map: Map, caster: Unit, path: Array[Vector2i]) -> void:
	var possible_targets: Array[Vector2i] = []
	for coordinate in map.terrain_grid.coordinates():
		if map.distance(path.back(), coordinate) <= spell_range:
			possible_targets.append(coordinate)
	var targets = possible_targets
	apply_highlights(map, targets)
	
	map.connect("cursor_move",Callable(self,"apply_highlights").bind(targets))
	map.set_state_unit_controlled(targets)
	var result = await map.click
	map.set_state_in_menu()
	map.disconnect("cursor_move",Callable(self,"apply_highlights"))
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		map.clear_highlights()
		caster.set_state_spell_select(map, path)
	else:
		map.clear_highlights()
		var target = map.cursor
		
		var aoe = calculate_aoe(map, target)
		var hit_units = []
		for coordinate in map.node_array().non_empty_coordinates():
			if aoe.has(coordinate):
				var unit = map.node_array().at(coordinate)
				if !unit.character.is_down():
					hit_units.append(map.node_array().at(coordinate))
		for unit in hit_units:
			unit.take_damage(3, map)
		
		var explosion = explosion_scene.instantiate()
		explosion.position = map.geometry.cell_centre_position(target)
		map.add_child(explosion)
		await explosion.animation_finished
		explosion.queue_free()
		caster.update_position(map, path.back())
		caster.set_state_done(map)
		
func apply_highlights(map: Map, targets: Array[Vector2i]) -> void:
	map.clear_highlights()
	map.add_highlights(targets, target_colour)
	if targets.has(map.cursor):
		map.add_highlights(calculate_aoe(map, map.cursor), aoe_colour)
	

func calculate_aoe(map: Map, target: Vector2i) -> Array[Vector2i]:
	var aoe = []
	for coordinate in map.terrain_grid.coordinates():
		if map.geometry.distance(map.cursor, coordinate) <= aoe_radius:
			aoe.append(coordinate)
	return aoe
