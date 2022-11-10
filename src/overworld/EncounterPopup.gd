extends PopupPanel

func _ready():
	popup_window = false
	exclusive = true
	transient = false
	popup_centered()
	$MarginContainer/ScrollContainer/Contents/Button.grab_focus()

func set_encounter_stage(encounter: Encounter) -> void:
	var stage = encounter.get_current_stage()
	$MarginContainer/ScrollContainer/Contents/Label.text = stage.description
	
	# Can't get the focus to work unless I handle the first button like this, very annoying
	var first_option = stage.options.front()
	var first_button: Button = $MarginContainer/ScrollContainer/Contents/Button
	first_button.text = first_option.text
	first_button.pressed.connect(func(): first_option.select(encounter))
	first_button.grab_focus()
	
	for i in range(1, stage.options.size()):
		var option = stage.options[i]
		var button = first_button.duplicate()
		button.text = option.text
		button.pressed.connect(func(): option.select(encounter))
		$MarginContainer/ScrollContainer/Contents.add_child(button)
	
	child_controls_changed()



