extends "res://src/grid/Grid.gd"

signal option_selected

var options = [
	"Option 1",
	"Option 2",
	"Option 3",
]
var width = 100
var height = grid_size * options.size()

# Called when the node enters the scene tree for the first time.
func _ready():
	grid_width = 1
	grid_height = options.size()
	draw_grid()

func _init(options: Array):
	self.options = options
	height = grid_size * options.size()
	update()

func click_position(coordinate: Coordinate):
	var option = options[coordinate.y]
	print("menu clicking")
	emit_signal("option_selected", option)

func position_from_coordinates(coordinate: Coordinate) -> Vector2:
	return Vector2(0, coordinate.y * grid_size)

func coordinates_from_position(p: Vector2) -> Coordinate:
	return Coordinate.new(0, p.y / grid_size)

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
		var container = CenterContainer.new()
		container.rect_size = Vector2(width, grid_size)
		var text = Label.new()
		text.text = option
		text.add_color_override("font_color", Color.black)
		text.set_align(Label.ALIGN_LEFT)
		text.set_valign(Label.VALIGN_CENTER)
		container.add_child(text)
		rect.add_child(container)
		add_child(rect)
