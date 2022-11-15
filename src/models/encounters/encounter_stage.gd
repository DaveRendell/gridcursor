class_name EncounterStage

var roll_result: RollResult

class RollResult:
	var success: bool
	var rolls: Dictionary
	func _init(_success: bool, _rolls: Dictionary):
		success = _success
		rolls = _rolls

func render(encounter: Encounter):
	return Node.new()
