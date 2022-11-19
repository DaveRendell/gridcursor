class_name EncounterOption

var text: String

func select(encounter: Encounter, node: Node) -> void:
	pass

func render(encounter: Encounter, node: Node, focus: bool) -> Node:
	var button = Button.new()
	button.text = text
	button.pressed.connect(func(): select(encounter, node))
	if focus:
		button.ready.connect(func(): button.grab_focus())
	return button
