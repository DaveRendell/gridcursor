extends Window

const FAIL_COLOUR = Color.LIGHT_CORAL
const SUCCESS_COLOR = Color.LIGHT_GREEN

func _ready():
	popup_window = false
	exclusive = true
	transient = false
	popup_centered()

func set_encounter_stage(encounter: Encounter) -> void:
	var stage = encounter.get_current_stage()
	if stage.roll_results:
		var roll_label = $Panel/ScrollContainer/Contents/RollResult as Label
		if stage.roll_success:
			roll_label.text = "Success"
			roll_label.add_theme_color_override("font_color", SUCCESS_COLOR)
		else:
			roll_label.text = "Failure"
			roll_label.add_theme_color_override("font_color", FAIL_COLOUR)
		var non_empty_roll_results = stage.roll_results.filter(func(r): return r != null)
		for i in non_empty_roll_results.size():
			var roll_result = non_empty_roll_results[i]
			#if roll_result:
			var character = encounter.party.characters[i]
			var label = Label.new()
			var result_text = "Success" if roll_result.total() >= stage.roll_target else "Failure"
			label.text = "%s: rolled %s (%s)" % [
				character.display_name,
				roll_result.total(),
				result_text]
			$Panel/ScrollContainer/Contents.add_child(label)
			$Panel/ScrollContainer/Contents.move_child(label, i)
	else:
		$Panel/ScrollContainer/Contents/RollResult.queue_free()
	
	$Panel/ScrollContainer/Contents/Description.text = stage.description	
	for i in range(0, stage.options.size()):
		var option = stage.options[i]
		var focus = i == 0
		var button = option.render(encounter, self, focus)
		$Panel/ScrollContainer/Contents.add_child(button)
	
	$Panel/ScrollContainer/Contents/Button.queue_free()
	
	child_controls_changed()



