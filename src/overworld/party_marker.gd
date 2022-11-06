extends MapMarker

var party: Party

enum PartyMarkerState {
	UNSELECTED,
	SELECTED,
}
var state: PartyMarkerState

func select(map: Map) -> void:
	set_state_selected(map)

func set_state_selected(map: Map) -> void:
	print("Party state: Selected")
	state = PartyMarkerState.SELECTED
	var adjacent_cells = map.geometry.adjacent_cells(coordinate())
	map.add_highlights(adjacent_cells, Color.LIGHT_BLUE)
	map.set_state_unit_controlled(adjacent_cells)
	

func from_party(party: Party) -> void:
	self.party = party
