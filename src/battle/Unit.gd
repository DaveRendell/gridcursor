class_name Unit extends MapMarker

var character: Character

const move_option_color = Color.LIGHT_BLUE
const attack_option_color = Color.RED

@export var movement = 6
@export var movement_type = "foot"

@export var team = 0
var battle_menu_scene = preload("res://src/ui/BattleMenu.tscn")

enum UnitState {
	UNSELECTED,
	SELECTED,
	ACTION_SELECT,
	ATTACK_SELECT,
	ATTACK_CONFIRM,
	DONE,
}
var unit_state: int = 0

var sprite: AnimatedSprite2D

# Calculated checked unit select
var distance_to_cell: CoordinateMap = null
var default_attack_sources: CoordinateMap = null
var all_attack_sources: CoordinateMap = null
var movement_options: Array[Vector2i] = []
var empty_movement_options: Array[Vector2i] = []
var attack_options: Array[Vector2i] = []

func from_char(character: Character, team: int, coordinate: Vector2i):
	self.character = character
	self.team = team
	self.x = coordinate.x
	self.y = coordinate.y
	self.width = character.width
	self.height = character.height
	sprite = character.sprite
	
	$HPBar.scale = Vector2(width, height)
	$HPBar.offset = (width - 1) * Vector2(4, 4)
	
	add_child(sprite)

func select(map: Map):
	if unit_state == UnitState.UNSELECTED and map.current_turn == team:
		if !character.is_down():
			calculate_options(map)
			set_state_selected(map, [coordinate()])

func set_state_unselected(map: Map):
	unit_state = UnitState.UNSELECTED
	modulate = Color(1, 1, 1, 1)
	map.clear_highlights()
	map.path = [coordinate()]
	

func set_state_selected(map: Map, initial_path: Array[Vector2i]):
	print("Unit state: Selected")
	unit_state = UnitState.SELECTED
	
	set_sprite_animation("default")

	var all_options: Array[Vector2i] = empty_movement_options + attack_options
	
	# Set map to display possible movement options and show movement path
	map.clear_highlights()
	
	map.add_highlights(movement_options, move_option_color)
	map.add_highlights(attack_options, attack_option_color)
	map.path = initial_path
	map.connect("cursor_move",Callable(self,"handle_cursor_move"))
	
	map.set_state_unit_controlled(all_options)
	var result = await map.click
	map.set_state_in_menu()
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		# Unselect unit
		map.disconnect("cursor_move",Callable(self,"handle_cursor_move"))
		set_state_unselected(map)
		map.set_state_nothing_selected()
	else:
		var clicked_cell = map.cursor
		if movement_options.has(clicked_cell):
			# Animate movement along movement path, then move to action select
			var path = map.path.duplicate()
			if map.path.size() == 0:
				map.path.append(coordinate())
			map.disconnect("cursor_move",Callable(self,"handle_cursor_move"))
			var tween = animate_movement_along_path(map)
			await tween.finished
			set_state_action_select(map, path)
		if attack_options.has(clicked_cell):
			var path: Array[Vector2i] = []
			if map.path.size() == 0:
				map.path.append(coordinate())
			if all_attack_sources.at(clicked_cell).has(map.path.back()):
				path = map.path.duplicate()
			else:
				path = get_path_to_coords(map, default_attack_sources.at(clicked_cell))
			map.path = path.duplicate()
			map.disconnect("cursor_move",Callable(self,"handle_cursor_move"))
			var tween = animate_movement_along_path(map)
			await tween.finished
			set_state_attack_confirm(map, path)
			

func set_state_action_select(map: Map, path: Array[Vector2i]):
	print("Unit state: Action select")
	unit_state = UnitState.ACTION_SELECT
	var new_location = path.back()
	
	map.clear_highlights()
	
	map.add_highlights(movement_options, move_option_color)
	map.add_highlights(attack_options, attack_option_color)
	
	var current_attack_options = valid_attacks(map, new_location)
	
	var popup_menu = battle_menu_scene.instantiate()
	var options = ["Wait", "Cancel"]
	if character.spells().size() > 0:
		options.push_front("Spells")
	if current_attack_options.non_empty_coordinates().size() > 0:
		options.push_front("Attack")
	
	for i in options.size():
		popup_menu.add_item(options[i], i)
	
	map.display_menu(popup_menu)

	var id = await popup_menu.id_pressed
	var option = options[id]
	
	if option == "Cancel":
		position = map.geometry.cell_centre_position(path.front())
		await get_tree().process_frame
		set_state_selected(map, path)
	if option == "Wait":
		update_position(map, new_location)
		set_state_done(map)
	if option == "Attack":
		set_state_attack_select(map, path, new_location)
	if option == "Spells":
		set_state_spell_select(map, path)

func set_state_attack_select(map: Map, path: Array[Vector2i], new_location: Vector2i):
	print("Unit state: Attack select")
	unit_state = UnitState.ATTACK_SELECT
	var attack_options: Array[Vector2i] = valid_attacks(map, new_location).non_empty_coordinates()
	map.clear_highlights()
	map.add_highlights(attack_options, attack_option_color)
	
	map.set_state_unit_controlled(attack_options)
	var result = await map.click
	map.set_state_in_menu()
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		set_state_action_select(map, path)
	else:
		set_state_attack_confirm(map, path)

func set_state_attack_confirm(map: Map, path: Array[Vector2i]):
	print("Unit state: Attack confirm")
	unit_state = UnitState.ATTACK_CONFIRM
	var attacked_node = map.units.at(map.cursor)
	
	
	var popup_menu = battle_menu_scene.instantiate()
	for i in character.attacks().size():
		var attack: Attack = character.attacks()[i]
		var can_attack = false
		for cell in cells(path.back()):
			var distance_to_target = map.geometry.distance(cell, map.cursor)
			if attack.can_attack_distance(distance_to_target):
				can_attack = true
				break
		if can_attack:
			popup_menu.add_item(attack.name, i)
	popup_menu.add_item("Cancel")
	
	map.display_menu(popup_menu)
	var id = await popup_menu.id_pressed

	if id == character.attacks().size():
		# Cancel selected
		position = map.geometry.cell_centre_position(path.front())
		await get_tree().process_frame
		set_state_selected(map, path)
	else:
		var attack = character.attacks()[id]
		perform_attack(map, attacked_node, attack)
		await sprite.animation_finished
		update_position(map, path.back())
		set_state_done(map)	

func set_state_spell_select(map: Map, path: Array[Vector2i]):
	var popup_menu = battle_menu_scene.instantiate()
	for i in character.spells().size():
		var spell = character.spells()[i]
		popup_menu.add_item(spell.display_name, i)
	popup_menu.add_item("Cancel")
	
	map.display_menu(popup_menu)
	var id = await popup_menu.id_pressed
	
	if id == character.spells().size():
		# Cancel selected
		await get_tree().process_frame
		set_state_action_select(map, path)
	else:
		var spell = character.spells()[id]
		spell.battle_action(map, self, path)

func set_state_done(map: Map):
	print("Unit state: Done")
	unit_state == UnitState.DONE
	modulate = Color(0.5, 0.5, 0.5, 1.0)
	map.clear_highlights()
	
	await get_tree().process_frame
	map.set_state_nothing_selected()

func perform_attack(map: Map, target: Unit, attack: Attack) -> void:
	print("Attacking using %s" % [attack.name])
	var best_stat = -1
	for stat in attack.attacking_stats:
		if character.stats[stat] > character.stats[best_stat]:
			best_stat = stat
	
	var angle_to_target = (target.position - position).angle()
	# 0 = 0 = right
	# 90 = tau / 4 = down
	# 180 = tau / 2 = left
	# 270 = 3tau / 4 = up
	# round(angle * 4 / tau) % 4
	var directions = ["right", "down", "left", "up"]
	var direction = directions[int(round(angle_to_target * 4 / TAU)) % 4]
	sprite.animation = "%s_%s" % [attack.animation, direction]
	await sprite.animation_finished
	sprite.animation = "default"
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var d1 = rng.randi_range(1, 6)
	var d2 = rng.randi_range(1, 6)
	var roll = d1 + d2 + character.stats[best_stat]
	var def = target.character.defence()
	
	var toast = map.display_toast("", 3.0)
	toast.add_text("%s:" % [character.display_name], Color.SKY_BLUE)
	toast.add_text("Rolled")
	toast.add_icon(DiceTexture.d6(d1))
	toast.add_icon(DiceTexture.d6(d2))
	toast.add_text("+ %s = %s" % [character.stats[best_stat], roll])
	
	if roll >= def:
		target.take_damage(attack.damage, map)
		await get_tree().process_frame
		map.update_units()
	else:
		target.display_label("miss")

var ephemeral_label_scene = preload("res://src/ui/EphemeralLabel.tscn")
func display_label(text: String, colour: Color = Color.WHITE):
	var label = ephemeral_label_scene.instantiate()
	label.text = text
	label.add_theme_color_override("font_color", colour)
	add_child(label)

func animate_movement_along_path(map: Map) -> Tween:
	var tween = get_tree().create_tween()
	if map.path.size() <= 1:
		tween.tween_interval(0)
	for i in range(1, map.path.size()):
		var from = map.geometry.cell_centre_position(map.path[i - 1])
		var to = map.geometry.cell_centre_position(map.path[i])
		var direction: String
		if from.y == to.y:
			if from.x < to.x:
				direction = "right"
			else:
				direction = "left"
		elif from.y < to.y:
			direction = "down"
		else:
			direction = "up"
		tween.tween_callback(Callable(self,"set_sprite_animation").bind(direction))
		tween.tween_property(self, "position", to, 0.15)
	map.path = [coordinate()]
	map.queue_redraw()
	return tween

func update_position(map: Map, coordinate: Vector2i):
	x = coordinate.x
	y = coordinate.y
	
	map.update_units()
	map.draw_nodes()
	map.clear_highlights()
	map.disconnect("cursor_move",Callable(self,"handle_cursor_move"))
	map.path = []
	
	set_sprite_animation("default")
	
	distance_to_cell = null
	default_attack_sources = null
	all_attack_sources = null
	movement_options = []
	empty_movement_options = []
	attack_options = []

func handle_cursor_move(map: Map):
	if attack_options.has(map.cursor):
		if map.path.size() > 0\
		and empty_movement_options.has(map.path.back())\
		and all_attack_sources.at(map.cursor).has(map.path.back()):
			return
		else:
			var cell_to_end_path_at = default_attack_sources.at(map.cursor).source
			var auto_path = get_path_to_coords(map, cell_to_end_path_at)
			if auto_path.size() > 0:
				map.path = auto_path
				map.queue_redraw()
				return
	
	if !movement_options.has(map.cursor):
		map.path = [coordinate()]
		map.queue_redraw()
		return
		
	if map.path.size() > 0:
		var already_on_path = map.path.find(map.cursor)
		if already_on_path >= 0:
			map.path = map.path.slice(0, already_on_path + 1)
			map.queue_redraw()
			return
		var path_end = map.path.back()
		var adjacent_cells = map.geometry.adjacent_cells(path_end)
		var c_node = map.units.at(map.cursor)
		var enemy_in_cell = (c_node != null) and (c_node.team != team)
		if adjacent_cells.has(map.cursor) and !enemy_in_cell:
			var manual_path: Array[Vector2i] = map.path + [map.cursor]
			if movement_cost_of_path(map, manual_path) <= movement:
				map.path = manual_path
				map.queue_redraw()
				return
	var auto_path = get_path_to_coords(map, map.cursor)
	if auto_path.size() > 0:
		map.path = auto_path
		map.queue_redraw()

# CoordinateMap to array of sorted attack inds from position u
func valid_attacks(map: Map, position: Vector2i) -> CoordinateMap:
	var out = CoordinateMap.new(map.grid_width, map.grid_height)
	for unit_coordinate in map.units.non_empty_coordinates():
		var unit: Unit = map.units.at(unit_coordinate)
		if unit.team != team and !unit.character.is_down():
			var attacks_in_range = []
			for i in character.attacks().size():
				var attack = character.attacks()[i]
				for cell in cells(position):
					if attack.can_attack_distance(map.geometry.distance(cell, unit_coordinate)):
						attacks_in_range.append(i)
						break
			if attacks_in_range.size() > 0:
				out.set_value(unit_coordinate, attacks_in_range)
	return out

class AttackSource:
	var attack_id: int
	var source: Vector2i
	func _init(attack_id: int,source: Vector2i):
		self.attack_id = attack_id
		self.source = source

func calculate_options(map: Map) -> void:
	distance_to_cell = CoordinateMap.new(map.grid_width, map.grid_width) # -> int
	default_attack_sources = CoordinateMap.new(map.grid_width, map.grid_height) # -> AttackSource
	all_attack_sources = CoordinateMap.new(map.grid_width, map.grid_height, [], [])
	movement_options = []
	empty_movement_options = [coordinate()]
	attack_options = []
	
	distance_to_cell.set_value(coordinate(), 0)
	var updates = [coordinate()]
	
	while updates.size() > 0:
		var new_updates = []
		for u in updates:
			var u_distance = distance_to_cell.at(u)
			
			# Add to movement options if valid
			if u_distance <= movement:
				movement_options.append(u)
				var space_free = true
				for cell in cells(u):
					if map.units.at(cell) != null:
						space_free = false
				if space_free:
					empty_movement_options.append(u)
			
				# If U is empty, check attacks from u
				if empty_movement_options.has(u):
					var attack_targets = valid_attacks(map, u)
					for attack_target in attack_targets.non_empty_coordinates():
						attack_options.append(attack_target)
						all_attack_sources.set_value(attack_target, all_attack_sources.at(attack_target) + [u])
						var best_attack = attack_targets.at(attack_target)[0]
						var existing_attacks_at_target: AttackSource = default_attack_sources.at(attack_target)
						
						if !existing_attacks_at_target:
							default_attack_sources.set_value(attack_target, AttackSource.new(best_attack, u))
						else:
							if existing_attacks_at_target.attack_id < best_attack:
								default_attack_sources.set_value(attack_target, AttackSource.new(best_attack, u))
							elif existing_attacks_at_target.attack_id == best_attack\
							and u_distance < distance_to_cell.at(existing_attacks_at_target.source):
								default_attack_sources.set_value(attack_target, AttackSource.new(best_attack, u))

			# Calculate adjacent movment options
			var adjacent_cells = map.geometry.adjacent_cells(u)
			for a in adjacent_cells:
				var a_cost = movement_cost_of_cell(map, a)
				if a_cost >= 0:
					var a_distance = u_distance + a_cost
					if distance_to_cell.at(a) == null or a_distance < distance_to_cell.at(a):
						distance_to_cell.set_value(a, a_distance)
						new_updates.append(a)
		updates = new_updates

func movement_cost_of_cell(map: Map, coordinate: Vector2i) -> int:
	var highest_cost = -1
	for i in width:
		for j in height:
			var cell = coordinate + Vector2i(i, j)
			if cell.clamp(Vector2i.ZERO, Vector2i(map.grid_width - 1, map.grid_height - 1)) != cell:
				# If part of the unit would move off the map, cannot move here
				return -1
			var terrain: int = map.terrain_grid.at(cell)
			var node: Unit = map.units.at(cell)
			if (node != null) and (node.team != team):
				# If any cell is enemy occupied, cannot move here
				return -1
			elif terrain == -1:
				highest_cost = maxi(highest_cost, 1)
			elif map.terrain_types[terrain]["movement"].has(movement_type):
				var cost =  map.terrain_types[terrain]["movement"][movement_type]
				highest_cost = maxi(highest_cost, cost)
			else:
				# If any cell is impassable, cannot move here
				return -1
	return highest_cost

func get_path_to_coords(map: Map, coordinate: Vector2i) -> Array[Vector2i]:	
	var out = [coordinate]
	var u = coordinate
	var u_distance = distance_to_cell.at(coordinate)
	while u != coordinate():
		var adjacent_cells = map.geometry.adjacent_cells(u)
		var u_cost = movement_cost_of_cell(map, u)
		for a in adjacent_cells:
			var a_node = map.units.at(a)
			if (a_node == null) or (a_node.team == team):
				var a_distance = distance_to_cell.at(a)
				if a_distance == u_distance - u_cost:
					out.append(a)
					u = a
					u_distance = a_distance
					break
	out.reverse()
	return out

func movement_cost_of_path(map: Map, p: Array[Vector2i]) -> int:
	var cost = 0
	for i in range(1, p.size()):
		cost += movement_cost_of_cell(map, p[i])
	return cost

func set_sprite_animation(animation: String) -> void:
	if animation != sprite.animation:
		sprite.animation = animation

func take_damage(damage: int, map: Map) -> void:
	character.take_damage(damage)
	display_label("-%s" % [damage], Color.LIGHT_CORAL)
	
	$HPBar.visible = true
	$HPBar.frame = round((float(character.hp) / character.max_hp()) * 14)
	
	sprite.animation = "damage"
	await sprite.animation_finished
	
	if character.is_down():
		sprite.animation = "knocked_down"
		await sprite.animation_finished
		map.check_win_condition()
		if character.die_when_downed:
			queue_free()
			tree_exited.connect(map.update_units)
		else:
			$HPBar.visible = false
			sprite.stop()
			sprite.frame = 1
	else:
		sprite.animation = "default"

