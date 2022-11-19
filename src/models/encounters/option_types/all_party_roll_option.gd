class_name AllPartyRollOption extends RollOption

func _init(
	_stat: E.Stat,
	_skills: Array[String],
	_success_stage_id: String,
	_failure_stage_id: String,
	_roll_target: int
):
	super(_stat, _skills, _success_stage_id, _failure_stage_id, _roll_target)

func is_success(roll_results: Array[RollResult]) -> bool:
	return true

func select(encounter: Encounter) -> void:
	var roll_results = []
	for i in encounter.party.characters.size():
		var character = encounter.party.characters[i]
		roll_results.append(character.roll_skill(stat, skills))
	var next_stage_id = success_stage_id if is_success(roll_results) else failure_stage_id
	var next_stage = encounter.stages[next_stage_id]
	next_stage.roll_results = roll_results
	next_stage.roll_success = is_success(roll_results)
	encounter.set_stage(next_stage_id)

func render(encounter: Encounter, focus: bool = false) -> Node:
	var button = Button.new()
	button.text = text
	button.pressed.connect(func(): select(encounter))
	if focus:
		button.ready.connect(func(): button.grab_focus())
	return button
