extends "res://src/grid/Grid.gd"

class_name Menu

signal option_selected

var options = [
	MenuOption.new("option_1", "Option 1"),
	MenuOption.new("option_2", "Option 2"),
	MenuOption.new("option_3", "Option 3"),
]
var width = 100
var height = grid_size

# Called when the node enters the scene tree for the first time.
func _ready():
	grid_width = 1
	grid_height = options.size()
	draw_grid()

func set_options(options: Array = [
	MenuOption.new("option_1", "Option 1"),
	MenuOption.new("option_2", "Option 2"),
	MenuOption.new("option_3", "Option 3"),
]):
	self.options = options
	height = grid_size * options.size()
	update()

func click_position(coordinate: Coordinate):
	var option = options[coordinate.y]
	print("menu clicking")
	emit_signal("option_selected", option.id)

func position_from_coordinates(coordinate: Coordinate) -> Vector2:
	return Vector2(0, coordinate.y * grid_size)

func coordinates_from_position(p: Vector2) -> Coordinate:
	return Coordinate.new(0, p.y / grid_size)

func cell_centre_position(coordinate: Coordinate) -> Vector2:
	return Vector2(width / 2, (coordinate.y + 0.5) * grid_size)

func draw_grid():
	$Background.rect_size = Vector2(width, height)
	for i in options.size():
		var option = options[i]
		var rect = ColorRect.new()
		if i % 2:
			rect.color = Color.antiquewhite
		else:
			rect.color = Color.bisque
		rect.rect_size = Vector2(width, grid_size)
		rect.rect_position = Vector2(0, i * grid_size)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var container = CenterContainer.new()
		container.rect_size = Vector2(width, grid_size)
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var text = Label.new()
		text.text = option.display_name
		text.add_color_override("font_color", Color.black)
		text.set_align(Label.ALIGN_LEFT)
		text.set_valign(Label.VALIGN_CENTER)
		container.add_child(text)
		rect.add_child(container)
		add_child(rect)
