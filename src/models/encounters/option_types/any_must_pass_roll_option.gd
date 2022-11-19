class_name AnyMustPassRollOption extends AllPartyRollOption

func is_success(roll_results) -> bool:
	return roll_results.any(func(roll_result: RollResult):
		return roll_result.total() >= roll_target)
