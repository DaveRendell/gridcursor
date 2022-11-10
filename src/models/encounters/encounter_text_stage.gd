class_name EncounterTextStage extends EncounterStage

const POPUP_SCENE = preload("res://src/overworld/EncounterPopup.tscn")

var description: String
var options: Array[EncounterOption]

func _init(_description: String, _options):
	description = _description
	options = _options

func render(encounter: Encounter):
	var popup = POPUP_SCENE.instantiate()
	popup.set_encounter_stage(encounter)
	return popup
