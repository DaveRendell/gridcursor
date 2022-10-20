class_name ComputerPlayer

class UnitTurnComplete:
	signal complete

static func execute_turn(map: Map) -> void:
	var units = get_units(map)
	
	for unit in units:
		var unit_turn = UnitTurnComplete.new()
		execute_unit_turn(unit, map, unit_turn)
		yield(unit_turn, "complete")
	
	map.next_turn()

static func get_units(map: Map) -> Array:
	var units = []
	for cell in map.node_array().non_empty_coordinates():
		var unit = map.node_array().at(cell) as Unit
		if unit.team == map.current_turn:
			units.append(unit)
	return units

static func execute_unit_turn(unit: Unit, map: Map, unit_turn: UnitTurnComplete) -> void:
	unit.calculate_options(map)
	
	if unit.attack_options.size() > 0:
		# For now, arbitrarily pick first result in list
		# TODO: Decide what the "best" attack to make is
		var attack_option = unit.attack_options.at(0)
		var target = map.node_array().at(attack_option)
		var attack_source = unit.default_attack_sources.at(attack_option)
		print(unit.character.attacks())
		print(attack_source)
		var attack = unit.character.attacks()[attack_source.attack_id]
		var path = unit.get_path_to_coords(map, attack_source.source)
		
		map.path = path
		var animation = unit.animate_movement_along_path(map)
		yield(animation, "finished")
		
		var popup = unit.perform_attack(map, target, attack)
		yield(popup, "tree_exited")
		
		unit.update_position(map, path.last())
		
	unit.state_to_done(map)
	# Brief pause for effect...
	yield(unit.get_tree().create_timer(0.25), "timeout")	
	return unit_turn.emit_signal("complete", unit)
