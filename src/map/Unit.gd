extends "res://src/grid/GridNode.gd"
class_name Unit

export var movement = 6
export var movement_type = "foot"
var attacks = [Attack.new(1, 1, true)]

export var team = 0

enum UnitState {
	UNSELECTED,
	SELECTED,
	ACTION_SELECT,
	ATTACK_SELECT,
	DONE,
}
var unit_state: int = 0

# States
# 0: Non selected
	# On select -> selected
# 1: Selected
	# Highlight movable areas
	# Update path on cursor move
	# click movement option -> (animated) action_select
	# click attack option -> (animated) action_select with preselected attack, no wait option?
	# click other option -> #0
# 2: Action select
	# Menu with options
	# Wait -> finished
	# Cancel -> #1
	# Attack -> #3 attack_select
# 3: Attack select
	# Highlight attackable units from moved position
	# Click non attack option -> #2
	# Click attack option -> (attack, then) #4
#4 Done

var movement_remaining: CoordinateMap = null

var new_menu = preload("res://src/menu/Menu.tscn")

func _ready():
	if team == 0:
		$AnimatedSprite.animation = "purple"
	if team == 1:
		$AnimatedSprite.animation = "yellow"

func select(map: Map):
	if unit_state == UnitState.UNSELECTED and map.current_turn == team:
		state_to_selected(map, CoordinateList.new())

func state_to_unselected(map: Map):
	unit_state = UnitState.UNSELECTED
	modulate = Color(1, 1, 1, 1)
	map.clear_highlights()
	map.path = CoordinateList.new()

func state_to_selected(map: Map, initial_path: CoordinateList):
	unit_state = UnitState.SELECTED
	var movement_options = movement_options(map)
	
	# Set map to display possibly movement options and show movement path
	map.clear_highlights()
	map.add_highlights(movement_options, Color.aqua)
	map.path = initial_path
	map.connect("cursor_move", self, "handle_cursor_move")
	
	var movement_selected = wait_for_cell_option_select(map, movement_options)
	var result = yield(map, "click")
	movement_selected.resume()
	
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		# Unselect unit
		map.disconnect("cursor_move", self, "handle_cursor_move")
		state_to_unselected(map)
	else:
		# Animate movement along movement path, then move to action select
		var path = map.path
		var tween = animate_movement_along_path(map)
		yield(tween, "finished")
		state_to_action_select(map, path)

func state_to_action_select(map: Map, path: CoordinateList):
	unit_state = UnitState.ACTION_SELECT
	var new_location = map.cursor
	var attack_options = get_attack_options(map, new_location) # TODO: Get options from all attacks
	
	var menu_options = ["Wait", "Cancel"]
	if attack_options.size() > 0:
		menu_options.push_front("Attack")
	
	var menu = new_menu.instance()
	menu.set_options(menu_options)
	menu.position = Vector2(map.grid_size, 0)
	menu.z_index = 10
	add_child(menu)
	var option = yield(menu, "option_selected")
	menu.queue_free()
	
	if option == "Cancel":
		yield(get_tree(), "idle_frame")
		state_to_selected(map, path)
	if option == "Wait":
		update_position(map, new_location)
		state_to_done(map)
	if option == "Attack":
		state_to_attack_select(map, path, new_location)

func state_to_attack_select(map: Map, path: CoordinateList, new_location: Coordinate):
	unit_state = UnitState.ATTACK_SELECT
	var attack_options = get_attack_options(map, new_location)
	var initial_position = coordinate()
	update_position(map, new_location)
	map.clear_highlights()
	map.add_highlights(attack_options, Color.lightpink)
	
	var attack_selected = wait_for_cell_option_select(map, attack_options)
	var result = yield(map, "click")
	attack_selected.resume()
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		update_position(map, initial_position)
		state_to_action_select(map, path)
	else:
		var attacked_node = map.node_array().at(map.cursor)
		attacked_node.queue_free() # TODO: damage rather than instadeath
		state_to_done(map)

func state_to_done(map: Map):
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

func get_attack_options(map: Map, coordinate: Coordinate) -> CoordinateList:
	var attack = attacks[0] # TODO use all attacks
	var out = CoordinateList.new()
	var node_array = map.node_array()
	for target_coordinate in node_array.coordinates():
		var node = node_array.at(target_coordinate)
		if node and node.team != team:
			var distance = map.distance(coordinate, target_coordinate)
			if distance >= attack.min_range and distance <= attack.max_range:
				out = out.append(target_coordinate)
	return out

func animate_movement_along_path(map: Map) -> SceneTreeTween:
	var tween = get_tree().create_tween()
	if map.path.size() == 0:
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
	movement_remaining = null
	yield(get_tree(), "idle_frame")
	map.set_active(true)
	

func handle_cursor_move(map: Map):
	var options = movement_options(map)
	
	if !options.has(map.cursor):
		map.path = CoordinateList.new([])
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

func calculate_movement(map: Map) -> CoordinateMap:
	# Lazy load
	if movement_remaining:
		return movement_remaining
	
	# Generate grid containing movement free at each tile, initialise with all -1
	var remaining_movement = CoordinateMap.new(map.grid_width, map.grid_height, [], -1)
	var node_array = map.node_array()
	
	remaining_movement.set_value(coordinate(), movement)
	var updates = CoordinateList.new([coordinate()])
	
	while updates.size() > 0:
		var new_updates = CoordinateList.new([])
		for u in updates.to_array():
			var u_remain = remaining_movement.at(u)
			var adjacent_cells = map.get_adjacent_cells(u)
			
			for a in adjacent_cells.to_array():
				var a_cost = movement_cost_of_cell(map, a)
				if a_cost >= 0:
					var a_remain = u_remain - a_cost					
					if a_remain > remaining_movement.at(a):
						remaining_movement.set_value(a, a_remain)
						new_updates = new_updates.append(a)
		updates = new_updates
	
	return remaining_movement

func movement_options(map: Map) -> CoordinateList:
	var remaining_movement = calculate_movement(map)
	var options = []
	for coordinate in remaining_movement.coordinates():
		if remaining_movement.at(coordinate) > -1:
			options.append(coordinate)
	return CoordinateList.new(options)

func movement_cost_of_cell(map: Map, coordinate: Coordinate) -> int:
	var terrain: int = map.terrain_grid.at(coordinate)
	var node: Unit = map.node_array().at(coordinate)
	if (node != null) and (node.team != team):
		return -1
	if map.terrain_types[terrain]["movement"].has(movement_type):
		return map.terrain_types[terrain]["movement"][movement_type]
	return -1

func get_path_to_coords(map: Map, coordinate: Coordinate) -> CoordinateList:
	var remaining_movement = calculate_movement(map)
	if remaining_movement.at(coordinate) < 0:
		return CoordinateList.new()
	
	var out = CoordinateList.new([coordinate])
	var u = coordinate
	var u_remain = remaining_movement.at(coordinate)
	while !u.equals(coordinate()):
		var adjacent_cells = map.get_adjacent_cells(u)
		var u_cost = movement_cost_of_cell(map, u)
		for a in adjacent_cells.to_array():
			var a_node = map.node_array().at(a)
			if (a_node == null) or (a_node.team == team):
				var a_remain = remaining_movement.at(a)
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
