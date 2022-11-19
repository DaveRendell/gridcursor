class_name ChangeStageOption extends EncounterOption

var stage: String

func _init(_text: String, _stage: String):
	text = _text
	stage = _stage

func select(encounter: Encounter, node: Node) -> void:
	encounter.set_stage(stage)

