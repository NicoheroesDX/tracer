extends Node

signal transition_complete;

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
