class_name RollOption extends EncounterOption

var stat: E.Stat
var skills: Array[String]
var success_stage_id: String
var failure_stage_id: String
var roll_target: int

func _init(
	_text: String,
	_stat: E.Stat,
	_skills: Array[String],
	_success_stage_id: String,
	_failure_stage_id: String,
	_roll_target: int
):
	text = _text
	stat = _stat
	skills = _skills
	success_stage_id = _success_stage_id
	failure_stage_id = _failure_stage_id
	roll_target = _roll_target
