class_name Encounter

signal stage_changed
signal end_encounter

var party: Party
var stages: Dictionary
var current_stage_id: String

func _init(_stages: Dictionary):
	stages = _stages
	current_stage_id = stages.keys().front()

func set_stage(stage_id: String) -> void:
	current_stage_id = stage_id
	stage_changed.emit()

func get_current_stage() -> EncounterStage:
	return stages.get(current_stage_id) as EncounterStage
