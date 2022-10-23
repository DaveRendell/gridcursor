class_name Toast
extends MarginContainer

func add_text(text: String, colour: Color = Color.white) -> void:
	var label = Label.new()
	label.text = text
	label.add_color_override("font_color", colour)
	$MarginContainer/Content.add_child(label)

func add_icon(texture: Texture) -> void:
	var rect = TextureRect.new()
	rect.texture = texture
	$MarginContainer/Content.add_child(rect)

func delete(direction: Vector2) -> void:
	emit_signal("hide")
	var animation = get_tree().create_tween()
	animation.tween_property(self, "rect_position", 500 * direction, 0.5).as_relative()
	yield(animation, "finished")
	queue_free()
