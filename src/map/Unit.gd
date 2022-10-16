extends "res://src/grid/GridNode.gd"
class_name Unit

export var movement = 6
export var movement_type = "foot"
var attacks = [
	Attack.new("Greatsword", 1, 1),
	#Attack.new("Shortbow", 2, 6),
]

export var team = 0

enum UnitState {
	UNSELECTED,
	SELECTED,
	ACTION_SELECT,
	ATTACK_SELECT,
	ATTACK_CONFIRM,
	DONE,
}
var unit_state: int = 0

var remaining_movement_at_cell: CoordinateMap = null
var default_attack_sources: CoordinateMap = null
var all_attack_sources: CoordinateMap = null
var movement_options: CoordinateList = null
var empty_movement_options: CoordinateList = null
var attack_options: CoordinateList = null

var new_menu = preload("res://src/menu/Menu.tscn")

func _ready():
	if team == 0:
		$AnimatedSprite.animation = "purple"
	if team == 1:
		$AnimatedSprite.animation = "yellow"

func select(map: Map):
	if unit_state == UnitState.UNSELECTED and map.current_turn == team:
		calculate_options(map)
		state_to_selected(map, CoordinateList.new([coordinate()]))

func state_to_unselected(map: Map):
	unit_state = UnitState.UNSELECTED
	modulate = Color(1, 1, 1, 1)
	map.clear_highlights()
	map.path = CoordinateList.new([coordinate()])

func state_to_selected(map: Map, initial_path: CoordinateList):
	print("Unit state: Selected")
	unit_state = UnitState.SELECTED

	var all_options = empty_movement_options.concat(attack_options)
	
	# Set map to display possible movement options and show movement path
	map.clear_highlights()
	map.add_highlights(movement_options, Color.lightblue)
	map.add_highlights(attack_options, Color.lightpink)
	map.path = initial_path
	map.connect("cursor_move", self, "handle_cursor_move")
	
	var movement_selected = wait_for_cell_option_select(map, all_options)
	var result = yield(map, "click")
	movement_selected.resume()	
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		# Unselect unit
		map.disconnect("cursor_move", self, "handle_cursor_move")
		state_to_unselected(map)
	else:
		var clicked_cell = map.cursor
		if movement_options.has(clicked_cell):
			# Animate movement along movement path, then move to action select
			var path = map.path
			map.disconnect("cursor_move", self, "handle_cursor_move")
			var tween = animate_movement_along_path(map)
			yield(tween, "finished")
			state_to_action_select(map, path)
		if attack_options.has(clicked_cell):
			var path: CoordinateList
			if map.path.size() == 0:
				map.path = map.path.append(coordinate())
			if all_attack_sources.at(clicked_cell).has(map.path.last()):
				path = map.path
			else:
				path = get_path_to_coords(map, default_attack_sources.at(clicked_cell))
			map.path = path
			map.disconnect("cursor_move", self, "handle_cursor_move")
			var tween = animate_movement_along_path(map)
			yield(tween, "finished")
			state_to_attack_confirm(map, path)
			

func state_to_action_select(map: Map, path: CoordinateList):
	print("Unit state: Action select")
	unit_state = UnitState.ACTION_SELECT
	var new_location = path.last()
	
	var attack_options = valid_attacks(map, new_location)
	
	var menu_options = ["Wait", "Cancel"]
	if attack_options.non_empty_coordinates().size() > 0:
		menu_options.push_front("Attack")
	
	var menu = new_menu.instance()
	menu.set_options(menu_options)
	menu.position = Vector2(map.grid_size, 0)
	menu.z_index = 10
	add_child(menu)
	var option = yield(menu, "option_selected")
	menu.queue_free()
	
	if option == "Cancel":
		position = map.position_from_coordinates(path.at(0))
		yield(get_tree(), "idle_frame")
		state_to_selected(map, path)
	if option == "Wait":
		update_position(map, new_location)
		state_to_done(map)
	if option == "Attack":
		state_to_attack_select(map, path, new_location)

func state_to_attack_select(map: Map, path: CoordinateList, new_location: Coordinate):
	print("Unit state: Attack select")
	unit_state = UnitState.ATTACK_SELECT
	var attack_options = CoordinateList.new(valid_attacks(map, new_location).non_empty_coordinates())
	map.clear_highlights()
	map.add_highlights(attack_options, Color.lightpink)
	
	var attack_selected = wait_for_cell_option_select(map, attack_options)
	var result = yield(map, "click")
	attack_selected.resume()
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		state_to_action_select(map, path)
	else:
		state_to_attack_confirm(map, path)

func state_to_attack_confirm(map: Map, path: CoordinateList):
	print("Unit state: Attack confirm")
	unit_state = UnitState.ATTACK_CONFIRM
	var attacked_node = map.node_array().at(map.cursor)
	
	var menu_options = ["999% Damage", "Cancel"]
	
	var menu = new_menu.instance()
	menu.set_options(menu_options)
	menu.position = map.position_from_coordinates(map.cursor)\
		+ Vector2(map.grid_size, 0)\
		- map.position_from_coordinates(coordinate())
	menu.z_index = 10
	add_child(menu)
	map.set_active(false)
	var option = yield(menu, "option_selected")
	menu.queue_free()
	map.set_active(true)
	
	if option == "999% Damage":
		attacked_node.queue_free() # TODO: damage rather than instadeath
		update_position(map, path.last())
		state_to_done(map)
	if option == "Cancel":
		position = map.position_from_coordinates(path.at(0))
		yield(get_tree(), "idle_frame")
		state_to_selected(map, path)
	

func state_to_done(map: Map):
	print("Unit state: Done")
	unit_state == UnitState.DONE
	modulate = Color(0.5, 0.5, 0.5, 1.0)
	map.clear_highlights()

func wait_for_cell_option_select(
	map: Map,
	options: CoordinateList
) -> void:
	map.set_active(true)
	map.send_clicks_as_signal = true
	map.clickable_cells = options

	yield()
	
	map.send_clicks_as_signal = false
	map.clickable_cells = null	

func animate_movement_along_path(map: Map) -> SceneTreeTween:
	var tween = get_tree().create_tween()
	if map.path.size() <= 1:
		tween.tween_interval(0)
	for i in range(1, map.path.size()):
		var pos = map.position_from_coordinates(map.path.at(i))
		tween.tween_property(self, "position", pos, 0.1)
	map.path = CoordinateList.new()
	map.set_active(false)
	map.update()
	return tween

func update_position(map: Map, coordinate: Coordinate):
	x = coordinate.x
	y = coordinate.y
	
	map.draw_nodes()
	map.clear_highlights()
	map.send_clicks_as_signal = false
	map.disconnect("cursor_move", self, "handle_cursor_move")
	map.path = CoordinateList.new()
	
	remaining_movement_at_cell = null
	default_attack_sources = null
	all_attack_sources = null
	movement_options = null
	empty_movement_options = null
	attack_options = null
	
	yield(get_tree(), "idle_frame")
	map.set_active(true)
	

func handle_cursor_move(map: Map):
	if attack_options.has(map.cursor):
		if map.path.size() > 0\
		and empty_movement_options.has(map.path.last())\
		and all_attack_sources.at(map.cursor).has(map.path.last()):
			return
		else:
			var cell_to_end_path_at = default_attack_sources.at(map.cursor).source
			var auto_path = get_path_to_coords(map, cell_to_end_path_at)
			if auto_path.size() > 0:
				map.path = auto_path
				map.update()
				return
	
	if !movement_options.has(map.cursor):
		map.path = CoordinateList.new([coordinate()])
		map.update()
		return
		
	if map.path.size() > 0:
		var already_on_path = map.path.find(map.cursor)
		if already_on_path >= 0:
			map.path = map.path.slice(0, already_on_path)
			map.update()
			return
		var path_end = map.path.last()
		var adjacent_cells = map.get_adjacent_cells(path_end)
		var c_node = map.node_array().at(map.cursor)
		var enemy_in_cell = (c_node != null) and (c_node.team != team)
		if adjacent_cells.has(map.cursor) and !enemy_in_cell:
			var manual_path = map.path.append(map.cursor)
			if movement_cost_of_path(map, manual_path) <= movement:
				map.path = manual_path
				map.update()
				return
	var auto_path = get_path_to_coords(map, map.cursor)
	if auto_path.size() > 0:
		map.path = auto_path
		map.update()

# CoordinateMap to array of sorted attack inds from position u
func valid_attacks(map: Map, position: Coordinate) -> CoordinateMap:
	var out = CoordinateMap.new(map.grid_width, map.grid_height)
	for unit_coordinate in map.node_array().non_empty_coordinates():
		var unit: Unit = map.node_array().at(unit_coordinate)
		if unit.team != team:
			var attacks_in_range = []
			for i in attacks.size():
				var attack = attacks[i]
				if attack.can_attack_distance(map.distance(position, unit_coordinate)):
					attacks_in_range.append(i)
			if attacks_in_range.size() > 0:
				out.set_value(unit_coordinate, attacks_in_range)
	return out

class AttackSource:
	var attack_id: int
	var source: Coordinate
	func _init(attack_id: int, source: Coordinate):
		self.attack_id = attack_id
		self.source = source

func calculate_options(map: Map) -> void:
	remaining_movement_at_cell = CoordinateMap.new(map.grid_width, map.grid_width, [], -1) # -> int
	default_attack_sources = CoordinateMap.new(map.grid_width, map.grid_height) # -> AttackSource
	all_attack_sources = CoordinateMap.new(map.grid_width, map.grid_height, [], CoordinateList.new()) # -> CoordinateList
	movement_options = CoordinateList.new()
	empty_movement_options = CoordinateList.new([coordinate()])
	attack_options = CoordinateList.new()
	
	remaining_movement_at_cell.set_value(coordinate(), movement)
	var updates = CoordinateList.new([coordinate()])
	
	while updates.size() > 0:
		var new_updates = []
		for u in updates.to_array():
			var u_remain = remaining_movement_at_cell.at(u)
			
			# Add to movement options if valid
			if u_remain >= 0:
				movement_options = movement_options.append(u)
				if !map.node_array().at(u):
					empty_movement_options = empty_movement_options.append(u)
			
			# Check attacks from u
			var attack_targets = valid_attacks(map, u)
			for attack_target in attack_targets.non_empty_coordinates():
				attack_options = attack_options.append(attack_target)
				all_attack_sources.set_value(attack_target, all_attack_sources.at(attack_target).append(u))
				var best_attack = attack_targets.at(attack_target)[0]
				var existing_attacks_at_target: AttackSource = default_attack_sources.at(attack_target)
				
				if !map.node_array().at(u)\
				and (!existing_attacks_at_target\
					or (existing_attacks_at_target.attack_id > best_attack)\
					or u_remain > remaining_movement_at_cell.at(existing_attacks_at_target.source)):
					default_attack_sources.set_value(attack_target, AttackSource.new(best_attack, u))
			
			# Calculate adjacent movment options
			var adjacent_cells = map.get_adjacent_cells(u)
			for a in adjacent_cells.to_array():
				var a_cost = movement_cost_of_cell(map, a)
				if a_cost >= 0:
					var a_remain = u_remain - a_cost
					if a_remain > remaining_movement_at_cell.at(a):
						remaining_movement_at_cell.set_value(a, a_remain)
						new_updates.append(a)
		updates = CoordinateList.new(new_updates)

func movement_cost_of_cell(map: Map, coordinate: Coordinate) -> int:
	var terrain: int = map.terrain_grid.at(coordinate)
	var node: Unit = map.node_array().at(coordinate)
	if (node != null) and (node.team != team):
		return -1
	if map.terrain_types[terrain]["movement"].has(movement_type):
		return map.terrain_types[terrain]["movement"][movement_type]
	return -1

func get_path_to_coords(map: Map, coordinate: Coordinate) -> CoordinateList:
	
	if remaining_movement_at_cell.at(coordinate) < 0:
		return CoordinateList.new([coordinate])
	
	var out = CoordinateList.new([coordinate])
	var u = coordinate
	var u_remain = remaining_movement_at_cell.at(coordinate)
	while !u.equals(coordinate()):
		var adjacent_cells = map.get_adjacent_cells(u)
		var u_cost = movement_cost_of_cell(map, u)
		for a in adjacent_cells.to_array():
			var a_node = map.node_array().at(a)
			if (a_node == null) or (a_node.team == team):
				var a_remain = remaining_movement_at_cell.at(a)
				if a_remain == u_remain + u_cost:
					out = out.append(a)
					u = a
					u_remain = a_remain
					break
	out = out.reverse()
	return out

func movement_cost_of_path(map: Map, p: CoordinateList):
	var cost = 0
	for i in range(1, p.size()):
		cost += movement_cost_of_cell(map, p.at(i))
	return cost
