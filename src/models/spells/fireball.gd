class_name Fireball
extends Spell

var spell_range = 7
var aoe_radius = 2

var target_colour = Color.green
var aoe_colour = Color.red

var explosion_scene = preload("res://img/battle/effects/Explosion.tscn")

func _init().("Fireball"):
	pass

func battle_action(map: Map, caster: Unit, path: CoordinateList) -> void:
	var possible_targets = []
	for coordinate in map.terrain_grid.coordinates():
		if map.distance(path.last(), coordinate) <= spell_range:
			possible_targets.append(coordinate)
	var targets = CoordinateList.new(possible_targets)
	apply_highlights(map, targets)
	
	map.connect("cursor_move", self, "apply_highlights", [targets])
	var target_selected = caster.wait_for_cell_option_select(map, targets)
	var result = yield(map, "click")
	target_selected.resume()
	map.disconnect("cursor_move", self, "apply_highlights")
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		map.clear_highlights()
		caster.state_to_spell_select(map, path)
	else:
		map.clear_highlights()
		var target = map.cursor
		
		var aoe = calculate_aoe(map, target)
		var hit_units = []
		for coordinate in map.node_array().non_empty_coordinates():
			if aoe.has(coordinate):
				hit_units.append(map.node_array().at(coordinate))
		for unit in hit_units:
			unit.take_damage(3, map)
		
		var explosion = explosion_scene.instance()
		explosion.position = map.cell_centre_position(target)
		map.add_child(explosion)
		yield(explosion, "animation_finished")
		explosion.queue_free()
		caster.update_position(map, path.last())
		caster.state_to_done(map)
		
func apply_highlights(map: Map, targets: CoordinateList) -> void:
	map.clear_highlights()
	map.add_highlights(targets, target_colour)
	if targets.has(map.cursor):
		map.add_highlights(calculate_aoe(map, map.cursor), aoe_colour)
	

func calculate_aoe(map: Map, target: Coordinate) -> CoordinateList:
	var aoe = []
	for coordinate in map.terrain_grid.coordinates():
		if map.distance(map.cursor, coordinate) <= aoe_radius:
			aoe.append(coordinate)
	return CoordinateList.new(aoe)
