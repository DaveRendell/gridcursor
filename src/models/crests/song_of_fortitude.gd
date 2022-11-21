class_name SongOfFortitude extends Crest

func _init():
	display_name = "Song of Fortitude"

var active = false
const RANGE = 3

func battle_actions() -> Array:
	return [] if active else [PlaySongOfFortitude.new(self)]

func end_of_battle(unit: Unit) -> void:
	active = false

func start_of_turn(map: BattleMap, unit: Unit) -> void:
	if active:
		buff_nearby_units(map, unit, unit.coordinate())

func buff_nearby_units(map: BattleMap, unit: Unit, position: Vector2i) -> void:
	for other_unit in map.list_units():
		if other_unit.team == unit.team and map.geometry.distance(other_unit.coordinate(), position) <= RANGE:
			other_unit.character.temporary_effects.append(SongOfFortitudeBuff.new())
			other_unit.display_label("+3 DEF", Color.LIGHT_BLUE)

class SongOfFortitudeBuff extends TemporaryEffect:
	func _init():
		super("Buff (Song of Fortitude)", TemporaryEffect.ExpiresAt.END_OF_TURN)

	func defence_boost():
		return 3

class PlaySongOfFortitude extends BattleAction:
	var charm: SongOfFortitude
	func _init(_charm: SongOfFortitude):
		charm = _charm
		super("Play Song of Fortitude")
		
	func is_allowed(map: BattleMap, unit: Unit, path: Array[Vector2i]) -> bool:
		return !charm.active

	func perform_action(map: BattleMap, unit: Unit, path: Array[Vector2i]) -> void:
		charm.active = true
		charm.buff_nearby_units(map, unit, path.back())
		unit.set_state_action_select(map, path, false)
