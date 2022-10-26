extends Popup

func _ready():
	popup_centered()
	$TPK/T.modulate.a = 0
	$TPK/P.modulate.a = 0
	$TPK/K.modulate.a = 0
	$YoureDead.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($TPK/T, "modulate", Color.white, 0.75)
	tween.tween_interval(0.25)
	tween.tween_property($TPK/P, "modulate", Color.white, 0.75)
	tween.tween_interval(0.25)
	tween.tween_property($TPK/K, "modulate", Color.white, 0.75)
	tween.tween_interval(0.5)
	tween.tween_property($YoureDead, "modulate", Color.white, 0.75)
	tween.play()
	
