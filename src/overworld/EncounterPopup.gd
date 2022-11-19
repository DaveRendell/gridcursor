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
		var roll_result = stage.roll_results
		var roll_label = $Panel/ScrollContainer/Contents/RollResult as Label
		if stage.roll_success:
			roll_label.text = "Success"
			roll_label.add_theme_color_override("font_color", SUCCESS_COLOR)
		else:
			roll_label.text = "Failure"
			roll_label.add_theme_color_override("font_color", FAIL_COLOUR)
		# TODO: Add party roll results here
	else:
		$Panel/ScrollContainer/Contents/RollResult.queue_free()
	
	$Panel/ScrollContainer/Contents/Description.text = stage.description
	
	# Can't get the focus to work unless I handle the first button like this, very annoying
	var first_option = stage.options.front()
	var first_button: Button = $Panel/ScrollContainer/Contents/Button
	first_button.text = first_option.text
	first_button.pressed.connect(func(): first_option.select(encounter))
	first_button.grab_focus()
	
	for i in range(0, stage.options.size()):
		var option = stage.options[i]
		var focus = i == 0
		var button = option.render(encounter, focus)
		$Panel/ScrollContainer/Contents.add_child(button)
	
	$Panel/ScrollContainer/Contents/Button.queue_free()
	
	child_controls_changed()



