extends Node2D

func _on_button_pressed() -> void:
	Global.change_scene_with_transition("res://src/track/Track.tscn")
