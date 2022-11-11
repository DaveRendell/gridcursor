extends Node2D

var encounter: Encounter

func set_encounter(_encounter: Encounter) -> void:
	encounter = _encounter
	update_display()
	encounter.stage_changed.connect(update_display)
	encounter.end_encounter.connect(queue_free)

func update_display():
	for child in get_children():
		child.queue_free()
	
	var stage = encounter.get_current_stage()
	var viewport_rect = get_viewport_rect()
	var rendered_stage = stage.render(encounter)
	add_child(rendered_stage)
