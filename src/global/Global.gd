extends Node

signal transition_complete;

func toggle_music(is_playing: bool):
	var music_player = get_tree().root.get_node("MainScene").get_node("RaceMusic")
	if (music_player != null):
		if is_playing and not music_player.playing:
			music_player.play();
		elif not is_playing:
			music_player.stop();

func change_scene_with_transition(pathToScene):
	var transitionLayer = get_tree().root.get_node("MainScene").get_node("TransitionLayer")
	if (transitionLayer != null):
		transitionLayer.start_transition_and_change_scene(pathToScene)
	else:
		change_scene(pathToScene)

func change_scene(pathToScene):
	var mainScene = get_tree().root.get_node("MainScene").get_node("MainDisplay")
	var transitionLayer = get_tree().root.get_node("MainScene").get_node("TransitionLayer")
	
	if (mainScene != null):
		var removable = mainScene.get_child(0)
		removable.queue_free()
		
		var scene_to_instantiate = load(pathToScene)
		var instantiated_scene = scene_to_instantiate.instantiate()
		
		mainScene.add_child(instantiated_scene)
