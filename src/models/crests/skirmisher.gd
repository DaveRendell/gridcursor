class_name Skirmisher extends Crest

func _init():
	display_name = "Skirmisher"

func post_attack_actions() -> Array:
	var action = SkirmisherAction.new()
	return [action]
