extends PopupPanel

var encounter: Encounter

func _ready():
	popup_window = false

func set_encounter(_encounter: Encounter) -> void:
	encounter = _encounter
	set_contents_from_encounter()
	encounter.stage_changed.connect(set_contents_from_encounter)
	encounter.end_encounter.connect(end)

func set_contents_from_encounter() -> void:
	for child in $Contents.get_children():
		child.queue_free()
		PopupPanel
	
	var stage: EncounterStage = encounter.get_current_stage()
	var text_stage = stage as EncounterTextStage
	if text_stage:
		add_text_stage_contents(text_stage)
	
	child_controls_changed()

func end() -> void:
	hide()
	queue_free()

func add_text_stage_contents(stage: EncounterTextStage) -> void:
	var label = Label.new()
	label.text = stage.description
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	$Contents.add_child(label)
	
	for option in stage.options:
		var button = Button.new()
		button.text = option.text
		button.pressed.connect(func(): option.select(encounter))
		$Contents.add_child(button)
