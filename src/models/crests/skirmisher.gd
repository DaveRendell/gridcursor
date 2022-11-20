class_name Skirmisher extends Crest

func _init():
	display_name = "Skirmisher"

class SkirmisherAction extends PostAttackAction:
	func _init():
		super("Skirmish")
	
	func is_allowed(map: BattleMap, unit: Unit, path: Array[Vector2i]) -> bool:
		var used_movement = unit.movement_cost_of_path(map, path)
		return used_movement < unit.movement

	func action(map: BattleMap, unit: Unit, path: Array[Vector2i]) -> void:
		var used_movement = unit.movement_cost_of_path(map, path)
		unit.calculate_options(map, unit.movement - used_movement)
		unit.attack_options = []
		
		map.clear_highlights()	
		map.add_highlights(unit.movement_options, unit.move_option_color)
		map.path = []
		map.connect("cursor_move", Callable(unit, "handle_cursor_move"))
		
		map.set_state_unit_controlled(unit.empty_movement_options)
		var result = await map.click
		map.set_state_in_menu()
		
		if typeof(result) == TYPE_STRING and result == "cancel":
			unit.set_state_post_attack_action_select(map, path)
			return
		else:
			var clicked_cell = map.cursor
			if map.path.size() == 0:
				map.path.append(unit.coordinate())
			map.disconnect("cursor_move",Callable(self,"handle_cursor_move"))
			var tween = unit.animate_movement_along_path(map)
			await tween.finished
			unit.update_position(map, clicked_cell)
			unit.set_state_done(map)

func post_attack_actions() -> Array:
	return [SkirmisherAction.new()]
