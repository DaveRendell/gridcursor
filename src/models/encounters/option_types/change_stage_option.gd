class_name ChangeStageOption extends EncounterOption

var stage: String

func _init(_text: String, _stage: String):
	text = _text
	stage = _stage

func select(encounter: Encounter) -> void:
	var next_stage = encounter.stages[stage] as EncounterStage
	next_stage.roll_result = EncounterStage.RollResult.new(false, {"Rollo": [3, 4]})
	encounter.set_stage(stage)
