class_name EncounterTextStage extends EncounterStage

var description: String
var options: Array[EncounterOption]

func _init(_description: String, _options):
	description = _description
	options = _options
