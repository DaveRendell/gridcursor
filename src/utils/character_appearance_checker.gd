extends Panel

var character: Humanoid

func _ready():
	character = Humanoid.new("test",
		Ancestry.human(),
		Humanoid.AppearanceDetails.new(
			0,
			0,
			E.HairColour.BLACK,
			0,
			0
		), 3, 2, 1, 1)
	set_ancestry(0)
	update_preview()
	$Preview/AnimatedSprite2D.play()
	
	var ancestry_menu: PopupMenu = $Controls/Ancestry.get_popup()
	ancestry_menu.id_pressed.connect(set_ancestry)

func update_preview():
	var sprite = character.generate_sprite()
	$Preview/AnimatedSprite2D.frames = sprite.frames

func set_ancestry(id: int) -> void:
	var ancestries = [
		Ancestry.human(),
		Ancestry.elf(),
		Ancestry.dwarf(),
		Ancestry.goblin(),
		Ancestry.orc(),
		Ancestry.skeleton(),
	]
	
	character.ancestry = ancestries[id]
	update_preview()
	var skintone_control = $Controls/SkinTone/SpinBox as SpinBox
	skintone_control.min_value = character.ancestry.skin_tones.front()
	skintone_control.max_value = character.ancestry.skin_tones.back()
	skintone_control.value = clamp(skintone_control.value, skintone_control.min_value, skintone_control.max_value)
	
	$Controls/Ancestry.text = "Ancestry: %s" % [character.ancestry.display_name]

func _on_skin_tone_value_changed(value):
	character.appearance_details.skin_tone = int(value)
	update_preview()

func _on_hair_style_value_changed(value):
	character.appearance_details.hair_style = int(value)
	update_preview()

func _on_hair_colour_value_changed(value):
	character.appearance_details.hair_colour = int(value)
	update_preview()

func _on_beard_style_value_changed(value):
	character.appearance_details.beard_style = int(value)
	update_preview()

func _on_clothes_colour_value_changed(value):
	character.appearance_details.base_clothes_colour = int(value)
	update_preview()


func _on_spin_button_pressed():
	var sprite = $Preview/AnimatedSprite2D as AnimatedSprite2D
	sprite.animation = "spin"
	sprite.speed_scale = 2.5
	await sprite.animation_finished
	sprite.animation = "default"
	sprite.speed_scale = 1
