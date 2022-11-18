class_name ChangeStageOption extends SingleRouteOption

var stage: String

func _init(_text: String, _stage: String):
	text = _text
	stage = _stage

func select(encounter: Encounter) -> void:
	var next_stage = encounter.stages[stage] as EncounterStage # QQ, just for testing
	next_stage.roll_results = {} # QQ, just for testing
	encounter.set_stage(stage)

