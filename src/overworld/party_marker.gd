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
	map.add_highlights(adjacent_cells, Color.LIGHT_BLUE)
	map.set_state_unit_controlled(adjacent_cells)
	var result = await map.click
	
	if typeof(result) == TYPE_STRING and result == "cancel":
		set_state_unselected(map)
	else:
		var clicked_cell = map.cursor
		map.clear_highlights()
		await animate_movement_to_cell(map, clicked_cell)
		update_position(map, clicked_cell)
		check_for_encounters(map, clicked_cell)
		set_state_unselected(map)
		
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

func check_for_encounters(map: Map, cell: Vector2i) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rolls = []
	var number_of_encounter_dice = 3
	for i in number_of_encounter_dice:
		rolls.append(rng.randi_range(1, 6))
	print("Random encounter rolls: %s" % str(rolls))
	
	if rolls.any(func(result): return result == 6):
		print("Random encounter happens")
	else:
		print("No encounter happens")

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
		
		
