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
		
		map.path = unit.get_path_to_coords(map, attack_source.source)
		var animation = unit.animate_movement_along_path(map)
		yield(animation, "finished")
		
		var popup = unit.perform_attack(map, target, attack)
		yield(unit.sprite, "animation_finished")
		
		unit.update_position(map, attack_source.source)
	else:
		# Move closer to enemies - fairly rudimental for now, just finds the
		# spot that uses all its movement range that puts it closest to an
		# enemy as the bird flies
		# TODO: avoid getting stuck behind walls
		# TODO: think a bit more about where to move
		var edge_of_movement_range = edge_of_movement_range(unit)
		var nearest_distance = INF
		var best_location: Coordinate
		for cell in edge_of_movement_range.to_array():
			var nearest_distance_at_cell = distance_to_nearest_enemy(cell, unit, map)
			if nearest_distance_at_cell < nearest_distance:
				nearest_distance = nearest_distance_at_cell
				best_location = cell
		
		if best_location:
			map.path = unit.get_path_to_coords(map, best_location)
			var animation = unit.animate_movement_along_path(map)
			yield(animation, "finished")
		
			unit.update_position(map, best_location)
	
	unit.state_to_done(map)
	# Brief pause for effect...
	yield(unit.get_tree().create_timer(0.25), "timeout")	
	return unit_turn.emit_signal("complete", unit)

static func edge_of_movement_range(unit: Unit) -> CoordinateList:
	var out = []
	for coordinate in unit.remaining_movement_at_cell.coordinates():
		if unit.remaining_movement_at_cell.at(coordinate) == 0:
			out.append(coordinate)
	return CoordinateList.new(out)

static func distance_to_nearest_enemy(position: Coordinate, unit: Unit, map: Map) -> int:
	var nearest_distance = INF
	for child in map.get_node("GridNodes").get_children():
		var other_unit = child as Unit
		if other_unit and other_unit.team != unit.team:
			var distance = map.distance(unit.coordinate(), other_unit.coordinate())
			nearest_distance = min(nearest_distance, distance)
	return nearest_distance
			
