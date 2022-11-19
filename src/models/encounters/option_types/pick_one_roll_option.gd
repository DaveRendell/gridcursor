class_name PickOneRollOption extends RollOption

var simple_menu_scene = preload("res://src/ui/SimpleMenu.tscn")

func select(encounter: Encounter) -> void:
	var popup_menu = simple_menu_scene.instantiate()
	var options = ["Set-up camp", "Cancel"]
	
	for i in options.size():
		popup_menu.add_item(options[i], i)
	
	popup_menu.set_focused_item(0)
	

	var id = await popup_menu.id_pressed
	popup_menu.queue_free()
	var option = options[id]
