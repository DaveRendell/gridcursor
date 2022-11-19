const BATTLE_MAP = preload("res://src/battle/battlemaps/ForestBlobAttack.tscn")

static func encounter() -> Encounter:
	return Encounter.new({
		"start": EncounterTextStage.new(
			"You are trekking through the forest, when you hear the terrible squelching of approaching blobbers",
			[
				ChangeStageOption.new("Attack them while their guard is down!", "fight"),
				ChangeStageOption.new("Flee before they spot you", "flee"),
				AllMustPassRollOption.new(
					"Hide (all must pass stealth check)",
					E.Stat.PRECISION, ["stealth"], "stealth_success", "stealh_failure", 6),
			] as Array[EncounterOption]
		),
		"fight": EncounterBattleStage.new(BATTLE_MAP, {
			E.BattleResult.VICTORY: "post_victory",
			E.BattleResult.TPK: "post_loss",
		}),
		"post_victory": EncounterTextStage.new(
			"Blobbers defeated, you continue on your quest",
			[
				EndEncounterOption.new("Continue")
			] as Array[EncounterOption]
		),
		"post_loss": EncounterTextStage.new(
			"Oh no, you're a scrub.",
			[
				EndEncounterOption.new("Continue")
			] as Array[EncounterOption]
		),
		"flee": EncounterTextStage.new(
			"Like cowards, you flee the deadly slime monsters",
			[
				EndEncounterOption.new("There is a quiet courage in a prudent retreat!")
			] as Array[EncounterOption]
		),
		"stealth_success": EncounterTextStage.new(
			"You hide in the underbrush, and the blobbers squelch by without noticing you",
			[
				EndEncounterOption.new("Continue")
			]
		),
		"stealh_failure": EncounterTextStage.new(
			"As you scramble to find a hiding place, the squelching masses launch their attack",
			[
				ChangeStageOption.new("Fight!", "fight")
			]
		),
	})	
