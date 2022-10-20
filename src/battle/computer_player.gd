class_name ComputerPlayer

static func execute_turn(map: Map) -> void:
	var units = get_units(map)
	
	for unit in units:
		execute_unit_turn(unit, map)
	
	
	
	map.next_turn()

static func get_units(map: Map) -> Array:
	var units = []
	for cell in map.node_array().non_empty_coordinates():
		var unit = map.node_array().at(cell) as Unit
		if unit.team == map.current_turn:
			units.append(unit)
	return units

static func execute_unit_turn(unit: Unit, map: Map) -> void:
	unit.state_to_done(map)
