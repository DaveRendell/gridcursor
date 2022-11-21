class_name SkirmisherAction extends PostAttackAction
func _init():
	super("Skirmish")

func is_allowed(map: BattleMap, unit: Unit, path: Array[Vector2i]) -> bool:
	var used_movement = unit.movement_cost_of_path(map, path)
	return used_movement < unit.movement

func perform_action(map: BattleMap, unit: Unit, path: Array[Vector2i]) -> void:
	var used_movement = unit.movement_cost_of_path(map, path)
	var movement_remaining = unit.movement - used_movement
	unit.calculate_options(map, movement_remaining)
	unit.attack_options = []
	
	map.clear_highlights()
	map.add_highlights(unit.movement_options, unit.move_option_color)
	map.path = []
	map.connect("cursor_move", Callable(unit, "handle_cursor_move").bind(movement_remaining))
	
	map.set_state_unit_controlled(unit.empty_movement_options)
	print(map.click.get_connections())
	var result = await map.click
	map.set_state_in_menu()
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		unit.set_state_post_attack_action_select(map, path)
	else:
		var clicked_cell = map.cursor
		if map.path.size() == 0:
			map.path.append(unit.coordinate())
		map.disconnect("cursor_move", Callable(unit, "handle_cursor_move"))
		var tween = unit.animate_movement_along_path(map)
		await tween.finished
		unit.update_position(map, clicked_cell)
		unit.set_state_done(map)

