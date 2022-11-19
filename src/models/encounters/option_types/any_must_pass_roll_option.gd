class_name AnyMustPassRollOption extends AllPartyRollOption

func is_success(roll_results: Array[RollResult]) -> bool:
	return roll_results.any(func(roll_result: RollResult):
		roll_result.total() >= roll_target)
