static func encounter() -> Encounter:
	return Encounter.new({
		"start": EncounterTextStage.new(
			"It's night time. Due to the state of development of this game, nothing happens.",
			[
				EndEncounterOption.new("Sweet dreams")
			] as Array[EncounterOption]
		)
	})
