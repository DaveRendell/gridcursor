extends MapMarker

var party: Party

enum PartyMarkerState {
	UNSELECTED,
	SELECTED,
}
var state: PartyMarkerState

func select(map: Map) -> void:
	set_state_selected(map)

func set_state_unselected(map: Map):
	print("Party state: Not Selected")
	state = PartyMarkerState.UNSELECTED
	map.clear_highlights()
	map.set_state_nothing_selected()
	for sprite in $Sprites.get_children():
		sprite.animation = "default"
		sprite.scale = Vector2i(1, 1)

func set_state_selected(map: Map) -> void:
	print("Party state: Selected")
	state = PartyMarkerState.SELECTED
	var adjacent_cells = map.geometry.adjacent_cells(coordinate())
	var valid_movement_cells = adjacent_cells.filter(func(cell):
		var terrain = map.terrain.at(cell)
		var movement_cost = terrain.foot_movement_cost
		return movement_cost >=0 and movement_cost <= party.marches_remaining)
	
	map.add_highlights(valid_movement_cells, Color.LIGHT_BLUE)
	map.set_state_unit_controlled(valid_movement_cells)
	var result = await map.click
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		set_state_unselected(map)
	else:
		var clicked_cell = map.cursor
		map.clear_highlights()
		await animate_movement_to_cell(map, clicked_cell)
		var terrain = map.terrain.at(clicked_cell)
		party.marches_remaining -= terrain.foot_movement_cost
		update_position(map, clicked_cell)
		
		set_state_unselected(map)
		await map.check_for_encounters(party, clicked_cell)
		
		if party.marches_remaining <= 0:
			await map.nighttime_encounter(party, clicked_cell)
			party.marches_remaining = 4
		
func update_position(map: Map, cell: Vector2i):
	x = cell.x
	y = cell.y
	
	map.update_parties()

func animate_movement_to_cell(map: Map, cell: Vector2i):
	var position_change
	var tween = create_tween()
	for sprite in $Sprites.get_children():
		if cell.y == y:
			sprite.animation = "left"
			if cell.x > x:
				sprite.scale = Vector2i(-1, 1)
		else:
			sprite.animation = "down"
			if cell.y > y:
				sprite.scale = Vector2i(-1, 1)
		sprite.frame = randi_range(0, 5)
	
	tween.tween_property(self, "position", map.geometry.cell_centre_position(cell), 1)
	await tween.finished

func from_party(party: Party) -> void:
	self.party = party
	set_number_of_sprites(party.characters.size())

func set_number_of_sprites(number: int) -> void:
	var frames = preload("res://src/overworld/party_marker_frames.tres")
	for sprite in $Sprites.get_children():
		sprite.queue_free()
	var offset = Vector2.ZERO
	var spacing = 6 * Vector2.UP
	var rotation = 0
	for i in number:
		var sprite = AnimatedSprite2D.new()
		sprite.frames = frames
		sprite.position = offset
		sprite.playing = true
		
		offset = Vector2.ZERO + spacing.rotated(rotation)
		rotation += randf_range(0.75, 1.25) * TAU / (number - 1)
		
		$Sprites.add_child(sprite)
		
		
