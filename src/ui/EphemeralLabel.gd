extends Label

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "position", 8 * Vector2.UP, 0.5).as_relative()
	tween.tween_callback(Callable(self,"queue_free"))
