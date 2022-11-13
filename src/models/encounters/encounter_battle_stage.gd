class_name EncounterBattleStage extends EncounterStage

const BATTLE_SCENE = preload("res://src/battle/Battle.tscn")

var battle_map_scene: PackedScene
var next_stages: Dictionary

func _init(_battle_map_scene: PackedScene, _next_stages: Dictionary):
	battle_map_scene = _battle_map_scene
	next_stages = _next_stages

func render(encounter: Encounter):
	var container = SubViewportContainer.new()
	var battle_viewport = SubViewport.new()
	var battle_scene = BATTLE_SCENE.instantiate()
	battle_viewport.add_child(battle_scene)
	container.add_child(battle_viewport)
	
	battle_viewport.size = DisplayServer.window_get_size() / 2
	container.size = DisplayServer.window_get_size() / 2
	container.stretch = true
	battle_scene.setup_map(battle_map_scene, encounter.party)
	
	# TODO handle loss
	battle_scene.map.battle_finished.connect(func(battle_result):
		encounter.set_stage(next_stages[battle_result]))
	
	return container
