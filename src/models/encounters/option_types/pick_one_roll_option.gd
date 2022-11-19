class_name PickOneRollOption extends RollOption

var simple_menu_scene = preload("res://src/ui/SimpleMenu.tscn")

func select(encounter: Encounter, node: Node) -> void:
	var popup_menu = simple_menu_scene.instantiate()
	var characters = encounter.party.characters
	
	for i in characters.size():
		var character = characters[i]
		var text = "%s (+%s)" % [character.display_name, character.stats[stat]]
		popup_menu.add_item(text, i)
	
	popup_menu.set_focused_item(0)
	
	node.add_child(popup_menu)
	popup_menu.popup_centered()

	var id = await popup_menu.id_pressed
	popup_menu.queue_free()
	
	if id != characters.size():
		var character = characters[id]
		var roll_result = character.roll_skill(stat, skills)
		var success = roll_result.total() >= roll_target
		var next_stage_id = success_stage_id if success else failure_stage_id
		var next_stage = encounter.stages[next_stage_id]
		
		var roll_results = []
		for _c in characters:
			roll_results.append(null)
		roll_results[id] = roll_result
		
		next_stage.roll_results = roll_results
		next_stage.roll_success = success
		next_stage.roll_target = roll_target
		encounter.set_stage(next_stage_id)
