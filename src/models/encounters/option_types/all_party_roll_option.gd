class_name AllPartyRollOption extends RollOption

func _init(
	_text: String,
	_stat: E.Stat,
	_skills: Array[String],
	_success_stage_id: String,
	_failure_stage_id: String,
	_roll_target: int
):
	super(_text, _stat, _skills, _success_stage_id, _failure_stage_id, _roll_target)

func is_success(roll_results) -> bool:
	return true

func select(encounter: Encounter, node: Node) -> void:
	var roll_results = encounter.party.characters.map(func(character):
		return character.roll_skill(stat, skills))
	var success = is_success(roll_results)
	var next_stage_id = success_stage_id if success else failure_stage_id
	var next_stage = encounter.stages[next_stage_id]
	next_stage.roll_results = roll_results
	next_stage.roll_success = success
	next_stage.roll_target = roll_target
	encounter.set_stage(next_stage_id)
