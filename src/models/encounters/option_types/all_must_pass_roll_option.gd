class_name AllMustPassRollOption extends AllPartyRollOption

func is_success(roll_results) -> bool:
	return roll_results.all(func(roll_result):
		return roll_result.total() >= roll_target)
