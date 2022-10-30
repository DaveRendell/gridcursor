class_name BattleMenu extends PopupMenu


func _ready():
	set_focused_item(0)

# If user clicks outside menu, and last item in list is "Cancel", select
# that item.
func _on_popup_hide():
	var last_index = item_count - 1
	var last_item_text = get_item_text(last_index)
	if last_item_text == "Cancel":
		var id = get_item_id(last_index)
		index_pressed.emit(last_index)
		id_pressed.emit(id)

