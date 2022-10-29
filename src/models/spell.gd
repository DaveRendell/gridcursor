class_name Spell

var display_name

func _init(display_name: String):
	self.display_name = display_name

func battle_action(map: Map, caster: Unit, path: Array[Vector2i]) -> void:
	push_error("Implement battle action")
