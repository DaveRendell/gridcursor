class_name SingleRouteOption extends EncounterOption

func select(encounter: Encounter) -> void:
	pass

func render(encounter: Encounter, focus: bool = false) -> Node:
	var button = Button.new()
	button.text = text
	button.pressed.connect(func(): select(encounter))
	if focus:
		button.ready.connect(func(): button.grab_focus())
	return button
