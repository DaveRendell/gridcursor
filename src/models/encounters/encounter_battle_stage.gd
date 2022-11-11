class_name EncounterBattleStage extends EncounterStage

const BATTLE_SCENE = preload("res://src/battle/Battle.tscn")

var battle_map_scene: PackedScene
var victory_stage: String

func _init(_battle_map_scene: PackedScene, _victory_stage: String):
	battle_map_scene = _battle_map_scene
	victory_stage = _victory_stage

func render(encounter: Encounter):
	var container = SubViewportContainer.new()
	var battle_viewport = Viewport.new()
	var battle_scene = BATTLE_SCENE.instantiate()
	battle_viewport.add_child(battle_scene)
	container.add_child(battle_viewport)
	
	
	
	battle_viewport.size = DisplayServer.window_get_size()
	container.size = DisplayServer.window_get_size()
	battle_scene.setup_map(battle_map_scene, encounter.party)
	
	
	# TODO connect to battle victory signal, change stage
	
	return container
