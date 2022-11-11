const BATTLE_MAP = preload("res://src/battle/battlemaps/ForestBlobAttack.tscn")

static func encounter() -> Encounter:
	return Encounter.new({
		"start": EncounterTextStage.new(
			"You are trekking through the forest, when you hear the terrible squelching of approaching blobbers",
			[
				ChangeStageOption.new("Attack them while their guard is down!", "fight"),
				ChangeStageOption.new("Flee before they spot you", "flee")
			] as Array[EncounterOption]
		),
		"fight": EncounterBattleStage.new(BATTLE_MAP, "post_victory"),
		"post_victory": EncounterTextStage.new(
			"Blobbers defeated, you continue on your quest",
			[
				EndEncounterOption.new("Continue")
			] as Array[EncounterOption]
		),
		"flee": EncounterTextStage.new(
			"Like cowards, you flee the deadly slime monsters",
			[
				EndEncounterOption.new("There is a quiet courage in a prudent retreat!")
			] as Array[EncounterOption]
		)
	})	
