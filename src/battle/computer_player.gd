class_name ComputerPlayer

class UnitTurnComplete:
	signal complete

static func execute_turn(map: Map) -> void:
	var units = get_units(map)
	
	for unit in units:
		var unit_turn = UnitTurnComplete.new()
		execute_unit_turn(unit, map, unit_turn)
		await unit_turn.complete
	
	map.next_turn.emit()

static func get_units(map: Map) -> Array:
	var units = []
	for cell in map.node_array().non_empty_coordinates():
		var unit = map.node_array().at(cell) as Unit
		if unit.team == map.current_turn:
			units.append(unit)
	return units

static func execute_unit_turn(unit: Unit, map: Map, unit_turn: UnitTurnComplete) -> void:
	map.get_node("Cursor").position = map.geometry.cell_centre_position(unit.coordinate())
	unit.calculate_options(map)
	
	if unit.attack_options.size() > 0:
		# For now, arbitrarily pick first result in list
		# TODO: Decide what the "best" attack to make is
		var attack_option = unit.attack_options.front()
		var target = map.node_array().at(attack_option)
		var attack_source = unit.default_attack_sources.at(attack_option)
		print(unit.character.attacks())
		print(attack_source)
		var attack = unit.character.attacks()[attack_source.attack_id]
		
		map.path = unit.get_path_to_coords(map, attack_source.source)
		var animation = unit.animate_movement_along_path(map)
		await animation.finished
		
		await unit.perform_attack(map, target, attack)
		
		unit.update_position(map, attack_source.source)
	else:
		# Move closer to enemies
		# TODO: think a bit more about where to move
		var paths_to_enemies = paths_to_enemies(unit, map)
		var nearest_distance = INF
		var best_location: Vector2i
		
		for path in paths_to_enemies:
			var distance_to_enemy = unit.distance_to_cell.at(path.back())
			var furthest_reachable_point = last_movement_option_in_path(unit, path)
			var distance_at_furthest_reachable_point = unit.distance_to_cell.at(furthest_reachable_point)
			var distance_remaining = distance_to_enemy - distance_at_furthest_reachable_point
			
			if distance_remaining < nearest_distance:
				nearest_distance = distance_remaining
				best_location = furthest_reachable_point
		
		if best_location:
			map.path = unit.get_path_to_coords(map, best_location)
			var animation = unit.animate_movement_along_path(map)
			await animation.finished
		
			unit.update_position(map, best_location)
	
	unit.set_state_done(map)
	# Brief pause for effect...
	await unit.get_tree().create_timer(0.25).timeout
	unit_turn.emit_signal("complete", unit)

static func last_movement_option_in_path(unit: Unit, path: Array[Vector2i]) -> Vector2i:
	return path.filter(func(coordinate):
		return unit.empty_movement_options.has(coordinate)
	).back()

static func paths_to_enemies(unit: Unit, map: Map) -> Array:
	var out = []
	for coordinate in map.node_array().non_empty_coordinates():
		var enemy = map.node_array().at(coordinate) as Unit
		if enemy and enemy.team != unit.team and !enemy.character.is_down():
			var adjacent_cells = map.geometry.adjacent_cells(coordinate)
			var closest_cell
			var closest_distance = INF
			for cell in adjacent_cells:
				var distance_to_cell = unit.distance_to_cell.at(cell)
				print(unit.distance_to_cell)
				if closest_distance != null:
					if (distance_to_cell and distance_to_cell < closest_distance):
						closest_cell = cell
						closest_distance = distance_to_cell
			
			out.append(unit.get_path_to_coords(map, closest_cell))
				
	return out
