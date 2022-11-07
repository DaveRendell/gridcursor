class_name EndEncounterOption extends EncounterOption

func _init(_text: String):
	text = _text

func select(encounter: Encounter) -> void:
	encounter.end_encounter.emit()
