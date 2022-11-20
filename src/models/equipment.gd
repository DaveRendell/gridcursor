class_name Equipment
extends Item

var equipable_slots: Array = []
var feature: Feature

func _init(
	_display_name: String,
	_weight: int,
	_feature: Feature
):
	feature = _feature
	super(_display_name, _weight)
