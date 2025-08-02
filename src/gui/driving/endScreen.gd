class_name EndScreen;
extends CenterContainer;

func _on_retry_button_pressed() -> void:
	Global.change_scene_with_transition("res://src/track/Track.tscn")

func _on_menu_button_pressed() -> void:
	Global.change_scene_with_transition("res://src/gui/menu/MainMenu.tscn")
