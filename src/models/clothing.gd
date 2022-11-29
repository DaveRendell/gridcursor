class_name Clothing extends Equipment

var sprite_sheets: Dictionary

func _init(
	_display_name: String,
	_weight: int,
	_feature: Feature,
	_sprite_sheets: Dictionary
):
	self.equipable_slots = [[E.EquipmentSlot.HEAD_GEAR, E.EquipmentSlot.BODY, E.EquipmentSlot.SHOES]]
	self.sprite_sheets = _sprite_sheets
	super(_display_name, _weight, _feature)
