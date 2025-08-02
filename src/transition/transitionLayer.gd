extends Node

@onready var animationPlayer = $AnimationPlayer;
@onready var mainDisplay = get_parent().get_node("MainDisplay");

var nextScene = null;

func _ready():
	animationPlayer.play("gameStart");

func start_transition_and_change_scene(pathToScene):
	mainDisplay.process_mode = Node.PROCESS_MODE_DISABLED
	nextScene = pathToScene
	animationPlayer.play("start");

func end_transition():
	mainDisplay.process_mode = Node.PROCESS_MODE_INHERIT
	animationPlayer.play("end");

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "start" && nextScene != null:
		Global.change_scene(nextScene)
		end_transition();
	elif anim_name == "end":
		Global.transition_complete.emit()
