extends PopupPanel

func _ready():
	popup_window = false

func _on_button_pressed():
	hide()
	queue_free()
